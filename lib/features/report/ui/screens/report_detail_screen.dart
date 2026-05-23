import 'package:flutter/material.dart';
import 'package:sleman_akses_mobile/core/theme/app_theme.dart';
import 'package:sleman_akses_mobile/core/widgets/system_response_dialog.dart';
import 'package:sleman_akses_mobile/features/home/ui/screens/home_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailScreen({super.key, required this.report});

  String _formatDate(String? timestamp) {
    if (timestamp == null) return '-';
    final dateObj = DateTime.tryParse(timestamp);
    if (dateObj == null) return '-';

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

  IconData _getFacilityIcon(String? category) {
    if (category == null) return Icons.check_circle;
    final lower = category.toLowerCase();
    if (lower.contains('miring') || lower.contains('ramp'))
      return Icons.accessible;
    if (lower.contains('toilet') ||
        lower.contains('wc') ||
        lower.contains('difabel'))
      return Icons.wc;
    if (lower.contains('lift') || lower.contains('elevator'))
      return Icons.elevator;
    if (lower.contains('parkir')) return Icons.local_parking;
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final status = report['validation_status'] ?? 'pending';
    final isPending = status == 'pending';
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    final mapLocation = report['map_location'];
    final latRaw = mapLocation?['latitude'];
    final lngRaw = mapLocation?['longitude'];

    final latitude = latRaw != null ? double.tryParse(latRaw.toString()) : null;
    final longitude = lngRaw != null
        ? double.tryParse(lngRaw.toString())
        : null;

    final coordsString = latitude != null && longitude != null
        ? '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}'
        : '-';

    final dateString = _formatDate(report['timestamp']);
    final details = report['details'] as List<dynamic>? ?? [];

    final rawImageUrl = report['photo_url'];
    final imageUrl =
        (rawImageUrl != null && !rawImageUrl.toString().contains('example.com'))
        ? rawImageUrl.toString()
        : null;

    final List<String> photoUrls = imageUrl != null ? imageUrl.split(',') : [];

    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    if (isApproved) {
      statusColor = AppTheme.primary;
      statusTitle = 'Laporan Disetujui & Dipublikasikan';
      statusIcon = Icons.check_circle;
    } else if (isRejected) {
      statusColor = AppTheme.error;
      statusTitle = 'Laporan Ditolak';
      statusIcon = Icons.cancel;
    } else {
      statusColor = AppTheme.warning;
      statusTitle = 'Laporan Menunggu Validasi';
      statusIcon = Icons.access_time_filled;
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Laporan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Image with Slider
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
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: PageView.builder(
                          itemCount: photoUrls.length,
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: photoUrls[index].trim(),
                              width: double.infinity,
                              fit: BoxFit.cover,
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
                ),
              )
            else
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
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildPlaceholderImage(),
                ),
              ),
            const SizedBox(height: 24),

            // Info Card (Tanggal, Koordinat)
            _buildSectionCard(
              child: Column(
                children: [
                  _buildInfoRow('Tanggal', dateString, isBold: true),
                  const Divider(height: 24, color: AppTheme.border),
                  if (latitude != null && longitude != null)
                    _buildMapMinimap(latitude, longitude)
                  else
                    _buildInfoRow('Koordinat GPS', coordsString, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fasilitas yang Dilaporkan
            if (details.isNotEmpty) ...[
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fasilitas yang Dilaporkan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...details.map((d) {
                      final isAvailable = d['availability_status'] == true;
                      final category = d['category'] ?? 'Fasilitas';
                      return _buildFacilityItem(
                        context,
                        title: category,
                        icon: _getFacilityIcon(category),
                        isActive: isAvailable,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Catatan Administrator
            if (!isPending &&
                report['evaluation_note'] != null &&
                report['evaluation_note'].toString().isNotEmpty)
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shield,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan Administrator',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${report['evaluation_note']}"',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 100), // spacing for bottom button
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isApproved && latitude != null && longitude != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
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
                          Navigator.pop(
                            context,
                          ); // Tutup halaman detail laporan
                          homeScreenKey.currentState?.openLocationOnMap(
                            latitude,
                            longitude,
                          );
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.map, color: AppTheme.surface),
                  label: const Text(
                    'Lihat di Peta',
                    style: TextStyle(
                      color: AppTheme.surface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFacilityItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.secondary.withOpacity(0.2)
                  : AppTheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 24,
                color: isActive ? AppTheme.primary : AppTheme.error,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF374151), // Gray 700
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary : AppTheme.error,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.black54,
        size: 40,
      ),
    );
  }

  Widget _buildMapMinimap(double lat, double lng) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Koordinat GPS',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
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
