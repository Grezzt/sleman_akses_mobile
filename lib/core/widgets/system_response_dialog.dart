import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleman_akses_mobile/core/theme/app_theme.dart';

class SystemResponseDialog extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const SystemResponseDialog({
    Key? key,
    required this.isSuccess,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onButtonPressed,
  }) : super(key: key);

  factory SystemResponseDialog.success({
    required String title,
    required String description,
    String buttonText = 'Lanjutkan',
    required VoidCallback onButtonPressed,
  }) {
    return SystemResponseDialog(
      isSuccess: true,
      title: title,
      description: description,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  factory SystemResponseDialog.error({
    required String title,
    required String description,
    String buttonText = 'Kembali',
    required VoidCallback onButtonPressed,
  }) {
    return SystemResponseDialog(
      isSuccess: false,
      title: title,
      description: description,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect screen width to make layout responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1F2937),
            width: 3,
          ), // Dark border
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1F2937), // Solid dark shadow
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: isSmallScreen
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMascot(),
                  const SizedBox(height: 16),
                  _buildContent(context),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildMascot(),
                  const SizedBox(width: 24),
                  Expanded(child: _buildContent(context)),
                ],
              ),
      ),
    );
  }

  Widget _buildMascot() {
    return SvgPicture.asset(
      isSuccess
          ? 'public/konfirmasi-titik-lokasi-unactive.svg'
          : 'public/maskot-nangis.svg',
      height: 140,
      fit: BoxFit.contain,
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textOnsurface,
            fontFamily: 'KitRounded', // using the app font
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4B5563), // textMuted
            fontFamily: 'KitRounded',
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFD1D5DB), // gray shadow for button
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: AppTheme.secondary,
              foregroundColor: AppTheme.primary,
              elevation: 0,
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
