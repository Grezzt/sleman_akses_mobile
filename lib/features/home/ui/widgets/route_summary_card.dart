import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/navigation_step.dart';

class RouteSummaryCard extends StatelessWidget {
  final RouteData routeData;
  final VoidCallback onStartLiveNav;
  final VoidCallback onClose;

  const RouteSummaryCard({
    super.key,
    required this.routeData,
    required this.onStartLiveNav,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary, width: 1),
                ),
                child: const Icon(
                  Icons.route,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeData.placeName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rute Ditemukan • ${routeData.formattedDistance} (~${routeData.formattedDuration})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textMuted),
                onPressed: onClose,
                tooltip: 'Tutup Rute',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tombol Mulai Navigasi Langsung
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.secondary,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onStartLiveNav,
              icon: const Icon(Icons.navigation, size: 20),
              label: const Text(
                'Mulai Navigasi Langsung',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.surface,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
