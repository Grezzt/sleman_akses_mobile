import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/navigation_step.dart';

class NavTopManeuverBar extends StatelessWidget {
  final NavigationStep? step;
  final double distanceToStepMeters;
  final VoidCallback onStop;

  const NavTopManeuverBar({
    super.key,
    required this.step,
    required this.distanceToStepMeters,
    required this.onStop,
  });

  String get _formattedDistance {
    if (distanceToStepMeters < 1000) {
      return '${distanceToStepMeters.round()} M';
    }
    return '${(distanceToStepMeters / 1000).toStringAsFixed(1)} KM';
  }

  @override
  Widget build(BuildContext context) {
    final activeStep = step;
    final iconData = activeStep?.icon ?? Icons.straight;
    final instruction = activeStep?.instruction ?? 'Lanjut ikuti jalan raya';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.border,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Maneuver Icon Badge (Neobrutalism lime badge)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary, width: 1.5),
            ),
            child: Icon(
              iconData,
              size: 28,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Maneuver Info (Distance + Instruction)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'DALAM $_formattedDistance',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  instruction,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Tutup / Keluar Navigasi Cepat
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onStop,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
