import 'package:flutter/material.dart';
import 'package:sleman_akses_mobile/core/theme/app_theme.dart';
import 'package:sleman_akses_mobile/features/home/data/models/map_location.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FacilityDetailScreen extends StatelessWidget {
  final MapLocation location;

  const FacilityDetailScreen({super.key, required this.location});

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '-';
    final dateObj = DateTime.tryParse(timestamp);
    if (dateObj == null) return timestamp;

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${dateObj.day} ${months[dateObj.month - 1]} ${dateObj.year}';
  }

  @override
  Widget build(BuildContext context) {
    final List<String> photoUrls = location.photoUrl.isNotEmpty
        ? location.photoUrl.split(',')
        : [];

    final coordsString =
        '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Fasilitas'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Utama (Besar, tanpa terpotong)
            if (photoUrls.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.border,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                  color: Colors.white, // background putih untuk contain
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 350, // Lebih besar
                        child: PageView.builder(
                          itemCount: photoUrls.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: photoUrls[index].trim(),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain, // Tanpa terpotong
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholderImage(),
                            );
                          },
                        ),
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
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
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
                                      'Geser foto (${photoUrls.length})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
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
                ),
              )
            else
              Container(
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: AppTheme.border,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildPlaceholderImage(),
                ),
              ),

            const SizedBox(height: 24),

            // Nama & Alamat Fasilitas
            _buildSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          location.placeName.isNotEmpty
                              ? location.placeName
                              : 'Fasilitas Tanpa Nama',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (location.facilityType.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            location.facilityType.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          color: AppTheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location.address.isNotEmpty
                              ? location.address
                              : 'Alamat belum tersedia',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info Card (Tanggal Publikasi, Koordinat, Dilaporkan)
            _buildSectionCard(
              child: Column(
                children: [
                  _buildInfoRow(
                      'Tgl. Publikasi',
                      _formatDate(location.publishDate),
                      isBold: true),
                  const Divider(height: 24, color: AppTheme.border),
                  _buildMapMinimap(location.latitude, location.longitude),
                  const Divider(height: 24, color: AppTheme.border),
                  _buildInfoRow(
                      'Dilaporkan Oleh',
                      location.reportedBy.isNotEmpty
                          ? location.reportedBy
                          : '-',
                      isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Fasilitas yang Tersedia
            const Text(
              'Rincian Fasilitas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (location.facilities.isEmpty)
              const Text(
                'Belum ada data fasilitas detail.',
                style: TextStyle(color: AppTheme.textMuted),
              )
            else
              ...location.facilities.map((fac) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildFacilityItem(
                    context,
                    title: fac.category,
                    isActive: fac.available,
                  ),
                );
              }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.black12,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.black26,
        size: 50,
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.border,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityItem(
    BuildContext context, {
    required String title,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = isActive ? Icons.accessible : Icons.block;
    final iconColor = isActive ? colorScheme.primary : AppTheme.border;
    final textColor = isActive ? AppTheme.textPrimary : AppTheme.textMuted;
    final bgColor = isActive ? AppTheme.secondary : AppTheme.surface;
    final borderColor = isActive ? AppTheme.primary : AppTheme.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (isActive)
            const Icon(
              Icons.check_circle,
              color: AppTheme.primary,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildMapMinimap(double lat, double lng) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Koordinat GPS',
          style: TextStyle(
            color: AppTheme.textMuted,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=${dotenv.env['MAPTILER_KEY'] ?? ''}',
                  userAgentPackageName: 'id.sleman.akses',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
