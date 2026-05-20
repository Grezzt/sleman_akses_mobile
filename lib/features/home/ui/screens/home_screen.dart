import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sleman_akses_mobile/core/theme/app_theme.dart';

import '../../data/datasources/home_remote_data_source.dart';
import '../../data/home_repository.dart';
import '../../data/models/facility_category.dart';
import '../../data/models/map_location.dart';
import '../../logic/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  LatLng? _deviceLocation;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(HomeRepository(HomeRemoteDataSource()));
    _controller.load();
    _requestAndFetchLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildExploreTab(context),
            _buildPlaceholderTab(context, 'Fasilitas'),
            _buildPlaceholderTab(context, 'Berita'),
            _buildPlaceholderTab(context, 'Laporan'),
            _buildPlaceholderTab(context, 'Profil'),
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
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Report',
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
                                filteredLocations,
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
                              FloatingActionButton(
                                heroTag: 'fab-report',
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
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: colorScheme.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: const StadiumBorder(
                    side: BorderSide(color: AppTheme.primary, width: 1),
                  ),
                  onSelected: (_) {
                    _controller.setSelectedCategory(category?.id);
                  },
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
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return locations.map((location) {
      final markerIcon = _resolveMarkerIcon(location);
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 52,
        height: 52,
        child: GestureDetector(
          onTap: () => _showLocationDetails(context, location),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: markerIcon,
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

  Widget _resolveMarkerIcon(MapLocation location) {
    final url = location.facilities.isNotEmpty
        ? location.facilities.first.iconMarker
        : '';
    if (url.isEmpty) {
      return const Icon(Icons.location_on, color: AppTheme.primary);
    }

    return ClipOval(
      child: Image.network(
        url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.location_on, color: AppTheme.primary);
        },
      ),
    );
  }

  Marker _buildDeviceMarker() {
    final location = _deviceLocation ?? const LatLng(0, 0);
    return Marker(
      point: location,
      width: 46,
      height: 46,
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

  Future<void> _requestAndFetchLocation({bool moveCamera = false}) async {
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
        _mapController.move(location, 16.5);
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showLocationDetails(BuildContext context, MapLocation location) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detail Fasilitas', style: textTheme.titleLarge),
                const SizedBox(height: 12),
                if (location.photoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      location.photoUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 180,
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                if (location.photoUrl.isNotEmpty) const SizedBox(height: 12),
                Text(
                  'Dilaporkan oleh ${location.reportedBy}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Publish: ${location.publishDate}',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text('Fasilitas', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                if (location.facilities.isEmpty)
                  Text('Belum ada data fasilitas.', style: textTheme.bodyMedium)
                else
                  ...location.facilities.map((facility) {
                    final icon = facility.available
                        ? Icons.check_circle
                        : Icons.cancel;
                    final color = facility.available
                        ? Colors.green
                        : Colors.redAccent;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              facility.category,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  LatLng _resolveInitialCenter(List<MapLocation> locations) {
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    }
    return const LatLng(-7.801194, 110.364917);
  }
}
