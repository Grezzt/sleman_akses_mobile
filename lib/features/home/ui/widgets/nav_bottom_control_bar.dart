import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NavBottomControlBar extends StatelessWidget {
  final String destinationName;
  final double remainingDistanceMeters;
  final bool followCamera;
  final bool voiceEnabled;
  final VoidCallback onRecenter;
  final VoidCallback onToggleVoice;
  final VoidCallback onStop;

  const NavBottomControlBar({
    super.key,
    required this.destinationName,
    required this.remainingDistanceMeters,
    required this.followCamera,
    required this.voiceEnabled,
    required this.onRecenter,
    required this.onToggleVoice,
    required this.onStop,
  });

  String get _formattedDistance {
    if (remainingDistanceMeters < 1000) {
      return '${remainingDistanceMeters.round()} m';
    }
    return '${(remainingDistanceMeters / 1000).toStringAsFixed(1)} km';
  }

  String get _formattedDuration {
    // Estimasi kecepatan rata-rata perkotaan 30 km/jam (~8.33 m/detik)
    final minutes = (remainingDistanceMeters / 1000 / 30 * 60).round();
    final dur = minutes <= 1 ? 1 : minutes;
    return '$dur mnt';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Floating action buttons (Recenter & Voice toggle)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Voice toggle button
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.border,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  voiceEnabled ? Icons.volume_up : Icons.volume_off,
                  color: voiceEnabled ? AppTheme.primary : AppTheme.textMuted,
                  size: 22,
                ),
                tooltip: voiceEnabled ? 'Matikan Suara' : 'Aktifkan Suara',
                onPressed: onToggleVoice,
              ),
            ),
            const SizedBox(width: 12),
            // Recenter camera button
            Container(
              decoration: BoxDecoration(
                color: followCamera ? AppTheme.secondary : AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.primary,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.navigation,
                  color: AppTheme.primary,
                  size: 22,
                ),
                tooltip: 'Pusatkan Kamera',
                onPressed: onRecenter,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Main Bottom HUD Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.border,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination Title
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      destinationName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats & Selesai button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Distance & Duration Chips
                  Row(
                    children: [
                      _buildMetricChip(
                        icon: Icons.straighten,
                        value: _formattedDistance,
                        label: 'Sisa Jarak',
                      ),
                      const SizedBox(width: 10),
                      _buildMetricChip(
                        icon: Icons.access_time,
                        value: _formattedDuration,
                        label: 'Estimasi',
                      ),
                    ],
                  ),
                  // Button Selesai Neobrutalism
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.primary,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: onStop,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.surface,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
