import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/system_response_dialog.dart';
import 'success_report_screen.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class ReportDraft {
  static final ReportDraft _instance = ReportDraft._internal();
  factory ReportDraft() => _instance;
  ReportDraft._internal();

  int currentStep = 0;
  Position? position;
  final List<XFile> photos = [];
  bool hasRamp = false;
  bool hasElevator = false;
  bool hasDisabledToilet = false;
  bool hasDisabledParking = false;

  void clear() {
    currentStep = 0;
    position = null;
    photos.clear();
    hasRamp = false;
    hasElevator = false;
    hasDisabledToilet = false;
    hasDisabledParking = false;
  }
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final ReportDraft _draft = ReportDraft();

  bool _isCheckingLocation = false;
  bool _serviceEnabled = false;
  LocationPermission _permission = LocationPermission.denied;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  int get _currentStep => _draft.currentStep;
  set _currentStep(int value) => _draft.currentStep = value;

  Position? get _position => _draft.position;
  set _position(Position? value) => _draft.position = value;

  List<XFile> get _photos => _draft.photos;

  bool get _hasRamp => _draft.hasRamp;
  set _hasRamp(bool value) => _draft.hasRamp = value;

  bool get _hasElevator => _draft.hasElevator;
  set _hasElevator(bool value) => _draft.hasElevator = value;

  bool get _hasDisabledToilet => _draft.hasDisabledToilet;
  set _hasDisabledToilet(bool value) => _draft.hasDisabledToilet = value;

  bool get _hasDisabledParking => _draft.hasDisabledParking;
  set _hasDisabledParking(bool value) => _draft.hasDisabledParking = value;


  @override
  void initState() {
    super.initState();
    if (_position == null) {
      _checkLocationState();
    }
  }

  Future<void> _pickPhotos() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picked == null) {
      return;
    }
    setState(() {
      _photos.add(picked);
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
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
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        setState(() {
          _currentStep--;
        });
      },
      child: Scaffold(
      backgroundColor: AppTheme.surface,
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
    ));
  }

  Widget _buildTopBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              minHeight: 10,
              backgroundColor: AppTheme.textMuted,
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
    if (_currentStep == 2) {
      return _buildConfirmationStep(context);
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
            color: AppTheme.textOnsurface,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SvgPicture.asset(
          'public/konfirmasi-titik-lokasi-unactive.svg',
          fit: BoxFit.contain,
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
            color: AppTheme.textOnsurface,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SvgPicture.asset(
          'public/konfirmasi titik lokasi aktif.svg',
          fit: BoxFit.contain,
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
    final isStepThree = _currentStep == 2;
    if (isStepThree) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.border,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text('Kembali Tambah Foto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
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
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Kirim laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    }

    final isNextEnabled = _currentStep != 0 || _isLocationReady;
    final isStepTwo = _currentStep == 1;
    final label = isStepTwo ? 'Unggah Foto Lainnya' : 'Konfirmasi';
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              onPressed: isNextEnabled
                  ? () {
                      if (_currentStep == 0) {
                        setState(() {
                          _currentStep = 1;
                        });
                        return;
                      }
                      if (_currentStep == 1) {
                        _pickPhotos();
                        return;
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: AppTheme.surface,
                backgroundColor: AppTheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          if (isStepTwo && _photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.primary,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 2;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text('Lanjut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoStep(BuildContext context) {
    if (_photos.isNotEmpty) {
      return _buildPhotoConfirmState(context);
    }

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
            color: AppTheme.textOnsurface,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Center(
            child: SvgPicture.asset(
              'public/Tambah foto fasilitas umum.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        _buildPhotoHintCard(context),
      ],
    );
  }

  Widget _buildPhotoConfirmState(BuildContext context) {
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
          'Konfirmasi foto\nfasilitas umum',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textOnsurface,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: _photos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.file(File(photo.path), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoHintCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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

  Future<String?> _uploadToCloudinary(String filePath) async {
    const cloudName = 'debmlrrkg';
    const apiKey = '195725588395627';
    const apiSecret = 'ic2RR5Cu9EqJmtQJSVQDDMk-X2M';

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signatureString = 'timestamp=$timestamp$apiSecret';
    final bytes = utf8.encode(signatureString);
    final signature = sha1.convert(bytes).toString();

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['signature'] = signature
      ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonMap = jsonDecode(responseData);
      return jsonMap['secure_url'];
    }
    return null;
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SystemResponseDialog.loading(),
    );

    try {
      List<String> uploadedUrls = [];
      for (var photo in _photos) {
        final url = await _uploadToCloudinary(photo.path);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      if (uploadedUrls.isEmpty && _photos.isNotEmpty) {
        throw Exception('Gagal mengunggah foto ke server penyimpanan.');
      }

      final uri = Uri.parse('${ApiClient.baseUrl}/reports');
      final request = http.MultipartRequest('POST', uri);

      final headers = Map<String, String>.from(ApiClient.headers);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      if (_position != null) {
        request.fields['latitude'] = _position!.latitude.toString();
        request.fields['longitude'] = _position!.longitude.toString();
      }

      // ID references: 1: Ramp, 2: Toilet Difabel, 3: Parkir Difabel, 4: Lift
      request.fields['categories[0][id]'] = '1';
      request.fields['categories[0][available]'] = _hasRamp ? '1' : '0';

      request.fields['categories[1][id]'] = '4';
      request.fields['categories[1][available]'] = _hasElevator ? '1' : '0';

      request.fields['categories[2][id]'] = '2';
      request.fields['categories[2][available]'] = _hasDisabledToilet
          ? '1'
          : '0';

      request.fields['categories[3][id]'] = '3';
      request.fields['categories[3][available]'] = _hasDisabledParking
          ? '1'
          : '0';

      request.fields['photo_url'] = uploadedUrls.join(',');

      final response = await request.send();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          _draft.clear(); // Clear the draft upon success
          Navigator.pop(context); // Dismiss loading dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SuccessReportScreen(
                hasRamp: _hasRamp,
                hasElevator: _hasElevator,
                hasDisabledToilet: _hasDisabledToilet,
                hasDisabledParking: _hasDisabledParking,
              ),
            ),
          );
        }
      } else {
        final respStr = await response.stream.bytesToString();
        if (mounted) {
          Navigator.pop(context); // Dismiss loading dialog
          showDialog(
            context: context,
            builder: (context) => SystemResponseDialog.error(
              title: 'Gagal Kirim Laporan',
              description: 'Status: ${response.statusCode}\n$respStr',
              onButtonPressed: () => Navigator.pop(context),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        showDialog(
          context: context,
          builder: (context) => SystemResponseDialog.error(
            title: 'Terjadi Kesalahan',
            description: e.toString(),
            onButtonPressed: () => Navigator.pop(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildConfirmationStep(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'LANGKAH 3/3',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Konfirmasi data',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textOnsurface,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_photos.length > 2)
                  Transform.translate(
                    offset: const Offset(-24, 12),
                    child: Transform.rotate(
                      angle: -0.15,
                      child: _buildStackedPhoto(_photos[2].path),
                    ),
                  ),
                if (_photos.length > 1)
                  Transform.translate(
                    offset: const Offset(24, 6),
                    child: Transform.rotate(
                      angle: 0.15,
                      child: _buildStackedPhoto(_photos[1].path),
                    ),
                  ),
                if (_photos.isNotEmpty) _buildStackedPhoto(_photos[0].path),
                if (_photos.isEmpty) _buildStackedPhoto(''),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${_photos.length} foto diunggah',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            'Pilih Ketersediaan Fasilitas',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
              children: [
                _buildCheckboxTile(
                  title: 'Terdapat Ramp',
                  value: _hasRamp,
                  icon: Icons.accessible_forward,
                  onChanged: (val) => setState(() => _hasRamp = val ?? false),
                ),
                _buildCheckboxTile(
                  title: 'Terdapat Lift',
                  value: _hasElevator,
                  icon: Icons.elevator,
                  onChanged: (val) =>
                      setState(() => _hasElevator = val ?? false),
                ),
                _buildCheckboxTile(
                  title: 'Toilet Difabel',
                  value: _hasDisabledToilet,
                  icon: Icons.wc,
                  onChanged: (val) =>
                      setState(() => _hasDisabledToilet = val ?? false),
                ),
                _buildCheckboxTile(
                  title: 'Parkir Khusus Difabel',
                  value: _hasDisabledParking,
                  icon: Icons.local_parking,
                  onChanged: (val) =>
                      setState(() => _hasDisabledParking = val ?? false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedPhoto(String path) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surface, width: 4),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.border,
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: path.isEmpty
            ? Container(color: Colors.grey[300])
            : Image.file(File(path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required IconData icon,
    required ValueChanged<bool?> onChanged,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: AppTheme.border, width: 1.5),
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary),
        ),
        secondary: Icon(icon, color: AppTheme.primary),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppTheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
      ),
    );
  }
}
