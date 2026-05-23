import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleman_akses_mobile/core/theme/app_theme.dart';

class SystemResponseDialog extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String description;
  final String buttonText;
  final bool isLoading;
  final String? imagePath;
  final Color? shadowColor;
  final VoidCallback onButtonPressed;

  const SystemResponseDialog({
    Key? key,
    required this.isSuccess,
    this.isLoading = false,
    required this.title,
    required this.description,
    required this.buttonText,
    this.imagePath,
    this.shadowColor,
    required this.onButtonPressed,
  }) : super(key: key);

  factory SystemResponseDialog.success({
    required String title,
    required String description,
    String buttonText = 'Lanjutkan',
    String? imagePath,
    Color? shadowColor,
    required VoidCallback onButtonPressed,
  }) {
    return SystemResponseDialog(
      isSuccess: true,
      title: title,
      description: description,
      buttonText: buttonText,
      imagePath: imagePath,
      shadowColor: shadowColor,
      onButtonPressed: onButtonPressed,
    );
  }

  factory SystemResponseDialog.error({
    required String title,
    required String description,
    String buttonText = 'Kembali',
    String? imagePath,
    Color? shadowColor,
    required VoidCallback onButtonPressed,
  }) {
    return SystemResponseDialog(
      isSuccess: false,
      title: title,
      description: description,
      buttonText: buttonText,
      imagePath: imagePath,
      shadowColor: shadowColor,
      onButtonPressed: onButtonPressed,
    );
  }

  factory SystemResponseDialog.loading({
    String title = 'Sedang Mengunggah...',
    String description = 'Tunggu sebentar yaa, laporan Anda sedang dikirim.',
    String? imagePath,
    Color? shadowColor,
  }) {
    return SystemResponseDialog(
      isSuccess: true,
      isLoading: true,
      title: title,
      description: description,
      buttonText: '',
      imagePath: imagePath,
      shadowColor: shadowColor,
      onButtonPressed: () {},
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
          boxShadow: [
            BoxShadow(
              color: shadowColor ?? AppTheme.border, // changed from dark shadow to gray
              offset: const Offset(4, 4),
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
    final defaultAsset = isSuccess
        ? 'public/konfirmasi-titik-lokasi-unactive.svg'
        : 'public/maskot-nangis.svg';
    final assetPath = imagePath ?? defaultAsset;

    return SvgPicture.asset(
      assetPath,
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
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.secondary, // use secondary shadow
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: AppTheme.primary, // changed to primary button
                foregroundColor: AppTheme.surface,
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
