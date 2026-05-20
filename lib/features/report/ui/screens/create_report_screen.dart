import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/app_theme.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  int _currentStep = 0;
  bool _isCheckingLocation = false;
  bool _serviceEnabled = false;
  LocationPermission _permission = LocationPermission.denied;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _checkLocationState();
  }

  Future<void> _checkLocationState() async {
    if (_isCheckingLocation) {
      return;
    }
    setState(() {
      _isCheckingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      setState(() {
        _serviceEnabled = serviceEnabled;
        _permission = permission;
      });

      if (serviceEnabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _position = position;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLocation = false;
        });
      }
    }
  }

  Future<void> _requestLocation() async {
    if (_isCheckingLocation) {
      return;
    }
    setState(() {
      _isCheckingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
      }

      final refreshedService = await Geolocator.isLocationServiceEnabled();
      setState(() {
        _serviceEnabled = refreshedService;
        _permission = permission;
      });

      if (refreshedService &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _position = position;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLocation = false;
        });
      }
    }
  }

  bool get _isLocationReady {
    return _serviceEnabled &&
        _permission != LocationPermission.denied &&
        _permission != LocationPermission.deniedForever &&
        _position != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 28),
              Expanded(child: _buildStepContent(context)),
              const SizedBox(height: 16),
              _buildFooterAction(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              minHeight: 10,
              backgroundColor: const Color(0xFFF5E3C7),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
            ),
          ),
        ),
        const SizedBox(width: 36),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context) {
    if (_currentStep == 0) {
      return _isLocationReady
          ? _buildLocationActiveState(context)
          : _buildLocationInactiveState(context);
    }
    if (_currentStep == 1) {
      return _buildPhotoStep(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLocationInactiveState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'LANGKAH 1/3',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Konfirmasi titik\nlokasi',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SvgPicture.asset(
          'public/konfirmasi-titik-lokasi-unactive.svg',
          height: 220,
        ),
        const Spacer(),
        _buildLocationStatusCard(
          context,
          title: 'Lokasi mati',
          description: 'Izinkan untuk membagikan\nlokasi untuk melanjutkan',
          buttonLabel: 'Izinkan',
          onPressed: _isCheckingLocation ? null : _requestLocation,
        ),
      ],
    );
  }

  Widget _buildLocationActiveState(BuildContext context) {
    final position = _position!;
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'LANGKAH 1/3',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Konfirmasi titik\nlokasi',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SvgPicture.asset(
          'public/konfirmasi titik lokasi aktif.svg',
          height: 220,
        ),
        const Spacer(),
        _buildLocationStatusCard(
          context,
          title: 'Lokasi aktif',
          description:
              'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
          buttonLabel: 'Perbarui',
          onPressed: _isCheckingLocation ? null : _checkLocationState,
        ),
      ],
    );
  }

  Widget _buildFooterAction(BuildContext context) {
    final isNextEnabled = _currentStep != 0 || _isLocationReady;
    final label = _currentStep == 1 ? 'Tambahkan' : 'Konfirmasi';
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isNextEnabled
            ? () {
                if (_currentStep == 0) {
                  setState(() {
                    _currentStep = 1;
                  });
                }
              }
            : null,
        child: Text(label),
      ),
    );
  }

  Widget _buildPhotoStep(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'LANGKAH 2/3',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tambahkan foto\nfasilitas umum',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: Image.asset(
              'public/Tambah foto fasilitas umum.svg',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.image,
                  size: 160,
                  color: AppTheme.border,
                );
              },
            ),
          ),
        ),
        _buildPhotoHintCard(context),
      ],
    );
  }

  Widget _buildPhotoHintCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.crop_free, color: AppTheme.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pastikan gambar jelas',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin kami akan menganalisis foto untuk\nvalidasi laporan anda',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard(
    BuildContext context, {
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback? onPressed,
  }) {
    final isActive = title.toLowerCase().contains('aktif');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(
              isActive ? Icons.location_on : Icons.location_off,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.surface,
              foregroundColor: AppTheme.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.border),
              ),
            ),
            child: _isCheckingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
