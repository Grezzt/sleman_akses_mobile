import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = HomeController(HomeRepository(HomeRemoteDataSource()));
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleman Akses')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
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
                          child: _buildCategoryChips(context, categories),
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
                  selectedColor: colorScheme.secondary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
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
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: () => _showLocationDetails(context, location),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
              color: colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ),
      );
    }).toList();
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
