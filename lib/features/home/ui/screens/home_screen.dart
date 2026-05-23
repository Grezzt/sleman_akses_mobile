import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sleman_akses_mobile/core/theme/app_theme.dart';
import 'package:sleman_akses_mobile/core/widgets/system_response_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:provider/provider.dart';

import '../../../report/ui/screens/report_history_screen.dart';
import '../../../auth/logic/auth_controller.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/home_repository.dart';
import '../../data/models/facility_category.dart';
import '../../data/models/map_facility.dart';
import '../../data/models/map_location.dart';
import '../../logic/home_controller.dart';

final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: homeScreenKey);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final MapController _mapController = MapController();
  LatLng? _deviceLocation;
  bool _isLocating = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(HomeRepository(HomeRemoteDataSource()));
    _controller.load();
    _requestAndFetchLocation(moveCamera: true, zoom: 14.0);

    // Fetch profile data
    Future.microtask(() {
      if (mounted) {
        context.read<AuthController>().fetchProfile();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildExploreTab(context),
            _buildFacilitiesTab(context),
            _buildPlaceholderTab(context, 'Berita'),
            const ReportHistoryScreen(),
            _buildProfileTab(context),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.accessible),
            selectedIcon: Icon(Icons.accessible),
            label: 'Fasilitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'Berita',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void openLocationOnMap(double lat, double lng) {
    setState(() {
      _selectedIndex = 0; // Explore tab
    });

    // We need to wait for the map to be rendered before moving the camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(LatLng(lat, lng), 16.5);

      // Find the location in the list to show details
      try {
        final loc = _controller.locations.value.firstWhere(
          (l) => l.latitude == lat && l.longitude == lng,
        );
        _showLocationDetails(context, loc);
      } catch (e) {
        // Handle if location not found
      }
    });
  }

  Widget _buildExploreTab(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _controller.errorMessage,
          builder: (context, errorMessage, __) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (errorMessage != null) {
              return _buildErrorState(context, errorMessage);
            }

            return ValueListenableBuilder<List<MapLocation>>(
              valueListenable: _controller.locations,
              builder: (context, locations, ___) {
                return ValueListenableBuilder<List<FacilityCategory>>(
                  valueListenable: _controller.categories,
                  builder: (context, categories, ____) {
                    final mapTilerKey = dotenv.env['MAPTILER_KEY'] ?? '';
                    if (mapTilerKey.isEmpty) {
                      return _buildErrorState(
                        context,
                        'MAPTILER_KEY belum di-set pada .env',
                      );
                    }

                    if (locations.isEmpty) {
                      return _buildEmptyState(
                        context,
                        'Belum ada fasilitas dipublikasikan.',
                      );
                    }

                    final filteredLocations = _controller.filterLocations(
                      locations,
                      categories,
                    );
                    final searchedLocations = _applySearchFilter(
                      filteredLocations,
                      _searchQuery,
                    );
                    final selectedCategoryName = _resolveSelectedCategoryName(
                      categories,
                    );

                    return Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _resolveInitialCenter(locations),
                            initialZoom: 13.2,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$mapTilerKey',
                              userAgentPackageName: 'id.sleman.akses',
                            ),
                            if (_deviceLocation != null)
                              MarkerLayer(markers: [_buildDeviceMarker()]),
                            MarkerLayer(
                              markers: _buildMarkers(
                                context,
                                searchedLocations,
                                selectedCategoryName,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchRow(context),
                              const SizedBox(height: 12),
                              _buildCategoryChips(context, categories),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FloatingActionButton.small(
                                heroTag: 'fab-location',
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                onPressed: () {
                                  _requestAndFetchLocation(moveCamera: true);
                                },
                                child: _isLocating
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppTheme.primary,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.my_location,
                                        color: AppTheme.primary,
                                      ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppTheme.secondary,
                                      blurRadius: 0,
                                      offset: Offset(4, 4),
                                    ),
                                  ],
                                ),
                                child: FloatingActionButton(
                                  heroTag: 'fab-report',
                                  elevation: 0,
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: AppTheme.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/report/create',
                                    );
                                  },
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFacilitiesTab(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.isLoading,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _controller.errorMessage,
          builder: (context, errorMessage, __) {
            if (isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (errorMessage != null) {
              return _buildErrorState(context, errorMessage);
            }

            return ValueListenableBuilder<List<MapLocation>>(
              valueListenable: _controller.locations,
              builder: (context, locations, ___) {
                return ValueListenableBuilder<List<FacilityCategory>>(
                  valueListenable: _controller.categories,
                  builder: (context, categories, ____) {
                    if (locations.isEmpty) {
                      return _buildEmptyState(
                        context,
                        'Belum ada fasilitas dipublikasikan.',
                      );
                    }

                    final filteredLocations = _controller.filterLocations(
                      locations,
                      categories,
                    );
                    final searchedLocations = _applySearchFilter(
                      filteredLocations,
                      _searchQuery,
                    );

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchRow(context),
                              const SizedBox(height: 12),
                              _buildCategoryChips(context, categories),
                            ],
                          ),
                        ),
                        Expanded(
                          child: searchedLocations.isEmpty
                              ? _buildEmptyState(
                                  context,
                                  'Fasilitas tidak ditemukan.',
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount: searchedLocations.length,
                                  itemBuilder: (context, index) {
                                    final location = searchedLocations[index];
                                    return _buildFacilityCard(
                                      context,
                                      location,
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFacilityCard(BuildContext context, MapLocation location) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final photoUrls = location.photoUrl.isNotEmpty
        ? location.photoUrl.split(',')
        : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.border,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLocationDetails(context, location),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: photoUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrls[0].trim(),
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            location.placeName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (location.status.isNotEmpty)
                          _buildBadge(
                            label: _statusLabel(location.status),
                            background: _statusColor(
                              colorScheme,
                              location.status,
                            ),
                            foreground: colorScheme.onPrimary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.address,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppTheme.textMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (location.facilities
                        .where((f) => f.available)
                        .isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: location.facilities
                            .where((f) => f.available)
                            .map(
                              (f) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _resolveFacilityIcon(f.category),
                                      size: 14,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      f.category,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.black54),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        final user = auth.user;
        final initials = user != null ? _getInitials(user.fullName) : 'U';

        // Default hardcoded stats for now as they are not available in the API
        final totalDikirim = 12;
        final totalDisetujui = 10;
        final totalDitolak = 2;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6), // Light grey background
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 40, bottom: 80),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  // Edit profile action
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7DE64), // Lime green
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.fullName ?? 'Memuat...',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.border,
                              blurRadius: 0,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              totalDikirim.toString(),
                              'Laporan Dikirim',
                              AppTheme.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            _buildStatItem(
                              totalDisetujui.toString(),
                              'Disetujui',
                              AppTheme.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            _buildStatItem(
                              totalDitolak.toString(),
                              'Ditolak',
                              AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60), // Space for the overlapping card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profil',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildProfileMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Ubah Kata Sandi',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildProfileMenuItem(
                          icon: Icons.notifications_none,
                          title: 'Pengaturan Notifikasi',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildProfileMenuItem(
                          icon: Icons.info_outline,
                          title: 'Tentang Aplikasi',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildProfileMenuItem(
                          icon: Icons.shield_outlined,
                          title: 'Kebijakan Privasi',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthController>().logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Keluar',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _buildPlaceholderTab(BuildContext context, String label) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.load,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(
    BuildContext context,
    List<FacilityCategory> categories,
  ) {
    return ValueListenableBuilder<int?>(
      valueListenable: _controller.selectedCategoryId,
      builder: (context, selectedId, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final chipItems = <FacilityCategory?>[null, ...categories];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: chipItems.map((category) {
              final isSelected =
                  (category?.id == selectedId) ||
                  (category == null && selectedId == null);
              final label = category?.name ?? 'Semua';

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: AppTheme.secondary,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: colorScheme.primary,
                    backgroundColor: AppTheme.surface,
                    checkmarkColor: AppTheme.surface,
                    elevation: 0,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.transparent, width: 0),
                    ),
                    onSelected: (_) {
                      _controller.setSelectedCategory(category?.id);
                      setState(() {});
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Marker> _buildMarkers(
    BuildContext context,
    List<MapLocation> locations,
    String selectedCategoryName,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return locations.map((location) {
      final iconData = _resolveMarkerIcon(location, selectedCategoryName);
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 48,
        height: 60,
        rotate: true,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _showLocationDetails(context, location),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Icon(
                Icons.location_on,
                color: colorScheme.primary,
                size: 48,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              Positioned(
                top: 7,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(iconData, color: colorScheme.primary, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSearchRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      _searchQuery = value;
                    });
                  }
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari fasilitas di Sleman...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildIconActionButton(context, Icons.notifications_none),
        const SizedBox(width: 12),
        _buildIconActionButton(context, Icons.person_outline),
      ],
    );
  }

  Widget _buildIconActionButton(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: colorScheme.primary),
    );
  }

  IconData _resolveMarkerIcon(
    MapLocation location,
    String selectedCategoryName,
  ) {
    MapFacility? selectedFacility;
    if (selectedCategoryName.isNotEmpty) {
      selectedFacility = location.facilities.firstWhere(
        (facility) =>
            facility.category.toLowerCase().trim() ==
            selectedCategoryName.toLowerCase().trim(),
        orElse: () =>
            const MapFacility(category: '', iconMarker: '', available: false),
      );
      if (selectedFacility.category.isEmpty) {
        selectedFacility = null;
      }
    }

    final preferredFacility =
        selectedFacility ??
        location.facilities.firstWhere(
          (facility) => facility.available == true,
          orElse: () => location.facilities.isNotEmpty
              ? location.facilities.first
              : const MapFacility(
                  category: '',
                  iconMarker: '',
                  available: false,
                ),
        );

    return _resolveFacilityIcon(preferredFacility.category);
  }

  String _resolveSelectedCategoryName(List<FacilityCategory> categories) {
    final selectedId = _controller.selectedCategoryId.value;
    if (selectedId == null) {
      return '';
    }
    final selected = categories.firstWhere(
      (category) => category.id == selectedId,
      orElse: () => const FacilityCategory(id: -1, name: '', iconMarker: ''),
    );
    return selected.name;
  }

  IconData _resolveFacilityIcon(String category) {
    final normalized = category.toLowerCase().trim();
    if (normalized.contains('ramp')) {
      return Icons.accessible;
    }
    if (normalized.contains('toilet')) {
      return Icons.wc;
    }
    if (normalized.contains('parkir')) {
      return Icons.local_parking;
    }
    if (normalized.contains('lift') || normalized.contains('elevator')) {
      return Icons.elevator;
    }
    return Icons.location_on;
  }

  List<MapLocation> _applySearchFilter(
    List<MapLocation> locations,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return locations;
    }

    return locations.where((location) {
      final name = location.placeName.toLowerCase();
      final address = location.address.toLowerCase();
      final facilityMatch = location.facilities.any(
        (facility) => facility.category.toLowerCase().contains(normalized),
      );
      return name.contains(normalized) ||
          address.contains(normalized) ||
          facilityMatch;
    }).toList();
  }

  Marker _buildDeviceMarker() {
    final location = _deviceLocation ?? const LatLng(0, 0);
    return Marker(
      point: location,
      width: 46,
      height: 46,
      rotate: true,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primary, width: 2),
        ),
        child: const Icon(Icons.navigation, color: AppTheme.primary, size: 22),
      ),
    );
  }

  Future<void> _requestAndFetchLocation({
    bool moveCamera = false,
    double? zoom,
  }) async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Aktifkan layanan lokasi untuk melihat posisi.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationError('Izin lokasi ditolak.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _deviceLocation = location;
      });

      if (moveCamera) {
        _mapController.move(location, zoom ?? 16.5);
      }
    } catch (_) {
      _showLocationError('Gagal mengambil lokasi perangkat.');
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _showLocationError(String message) {
    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SystemResponseDialog.error(
        title: 'Lokasi Error',
        description: message,
        onButtonPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showLocationDetails(BuildContext context, MapLocation location) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatefulBuilder(
                  builder: (context, setSheetState) {
                    final photoUrls = location.photoUrl.isNotEmpty
                        ? location.photoUrl.split(',')
                        : [];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: photoUrls.isNotEmpty
                                ? PageView.builder(
                                    itemCount: photoUrls.length,
                                    onPageChanged: (index) {
                                      setSheetState(() {
                                        // This will only work if we keep track of index, but since we define the variable inside _showLocationDetails (we can't easily without editing above), we can just use a PageController or skip dynamic text and just use an indicator if needed, but actually we can define the variable outside StatefulBuilder.
                                        // Wait, I will just do a simple PageView without text indicator to keep it extremely simple and avoid rewriting the signature. People can naturally swipe. Or better, let me use a dot indicator by just mapping over it?
                                        // Let me just declare a local variable `int currentPhotoIndex = 0;` inside the builder? No, it resets on setState.
                                        // I'll just use PageView, it's enough.
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return CachedNetworkImage(
                                        imageUrl: photoUrls[index].trim(),
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) {
                                          return Container(
                                            color: Colors.black12,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.black12,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: location.facilityType.isNotEmpty
                                ? _buildBadge(
                                    label: location.facilityType.toUpperCase(),
                                    background: colorScheme.secondary,
                                    foreground: colorScheme.primary,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: location.status.isNotEmpty
                                ? _buildBadge(
                                    label: _statusLabel(location.status),
                                    background: _statusColor(
                                      colorScheme,
                                      location.status,
                                    ),
                                    foreground: colorScheme.onPrimary,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (photoUrls.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.swipe,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Geser untuk melihat ${photoUrls.length} foto',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (location.placeName.isNotEmpty)
                  Text(
                    location.placeName,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (location.placeName.isNotEmpty) const SizedBox(height: 8),
                if (location.address.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location.address,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (location.address.isNotEmpty) const SizedBox(height: 8),
                if (location.reportedBy.isNotEmpty)
                  Text(
                    'Dilaporkan oleh ${location.reportedBy}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMuted,
                    ),
                  ),
                if (location.placeName.isNotEmpty ||
                    location.address.isNotEmpty ||
                    location.reportedBy.isNotEmpty)
                  const SizedBox(height: 20),
                Text(
                  'Fitur Aksesibilitas',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (_controller.categories.value.isEmpty)
                  Text('Belum ada data fasilitas.', style: textTheme.bodyMedium)
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _controller.categories.value.map((category) {
                      final match = location.facilities.firstWhere(
                        (facility) =>
                            facility.category.toLowerCase().trim() ==
                            category.name.toLowerCase().trim(),
                        orElse: () => const MapFacility(
                          category: '',
                          iconMarker: '',
                          available: false,
                        ),
                      );
                      final isAvailable =
                          match.category.isNotEmpty && match.available == true;
                      final icon = isAvailable ? Icons.accessible : Icons.block;
                      final iconColor = isAvailable
                          ? colorScheme.primary
                          : AppTheme.border;
                      final textColor = isAvailable
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted;
                      final iconData = _resolveFacilityIcon(category.name);

                      return Container(
                        width: (MediaQuery.of(context).size.width - 64) / 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? AppTheme.secondary
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isAvailable
                                  ? AppTheme.primary
                                  : AppTheme.border,
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(iconData, color: iconColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.primary,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation),
                    label: const Text('Rute Navigasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: AppTheme.primary,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                ),
                if (_selectedIndex != 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.secondary,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => SystemResponseDialog.success(
                            title: 'Menuju Lokasi',
                            description:
                                'Mari lanjutkan, Kami akan menampilkan lokasi nya!',
                            buttonText: 'Lanjutkan',
                            onButtonPressed: () {
                              Navigator.pop(context); // Tutup dialog
                              Navigator.pop(context); // Tutup bottom sheet
                              openLocationOnMap(
                                location.latitude,
                                location.longitude,
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Lihat di Peta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.surface,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement navigasi detail lengkap fasilitas
                    },
                    child: Text(
                      'Lihat Detail Lengkap',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge({
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    final normalized = status.toLowerCase().trim();
    if (normalized == 'active') {
      return 'AKTIF';
    }
    if (normalized == 'inactive') {
      return 'NONAKTIF';
    }
    if (normalized.isEmpty) {
      return 'STATUS';
    }
    return normalized.toUpperCase();
  }

  Color _statusColor(ColorScheme scheme, String status) {
    final normalized = status.toLowerCase().trim();
    if (normalized == 'inactive') {
      return AppTheme.error;
    }
    return scheme.primary;
  }

  LatLng _resolveInitialCenter(List<MapLocation> locations) {
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
    return const LatLng(-7.801194, 110.364917);
  }
}
