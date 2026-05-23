import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';

class SuccessReportScreen extends StatelessWidget {
  final bool hasRamp;
  final bool hasElevator;
  final bool hasDisabledToilet;
  final bool hasDisabledParking;

  const SuccessReportScreen({
    super.key,
    required this.hasRamp,
    required this.hasElevator,
    required this.hasDisabledToilet,
    required this.hasDisabledParking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Top green indicator (from mockup)
              Center(
                child: Container(
                  width: 120,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7DE64), // Lime green from mockup
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Sukses menambahkan\nLaporan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(
                    0xFF131B2F,
                  ), // Dark blue/black color from mockup
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'public/laporan sukses.svg',
                        fit: BoxFit.contain,
                        height: 220,
                      ),
                      const SizedBox(height: 16),
                      Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fasilitas yang Dilaporkan',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            _buildFacilityItem(
                              context,
                              title: 'Terdapat Ramp',
                              icon: Icons.accessible_forward,
                              isActive: hasRamp,
                            ),
                            const SizedBox(height: 16),
                            _buildFacilityItem(
                              context,
                              title: 'Terdapat Lift',
                              icon: Icons.elevator,
                              isActive: hasElevator,
                            ),
                            const SizedBox(height: 16),
                            _buildFacilityItem(
                              context,
                              title: 'Toilet Difabel',
                              icon: Icons.wc,
                              isActive: hasDisabledToilet,
                            ),
                            const SizedBox(height: 16),
                            _buildFacilityItem(
                              context,
                              title: 'Parkir Khusus',
                              icon: Icons.local_parking,
                              isActive: hasDisabledParking,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the home screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isActive,
  }) {
    return Row(
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
    );
  }
}
