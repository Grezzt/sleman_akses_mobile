import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/logic/auth_controller.dart';
import '../../auth/ui/screens/login_screen.dart';
import '../../home/ui/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final Future<void> _loadFuture;
  late final AnimationController _progressController;
  bool _ready = false;
  bool _goHome = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    final auth = context.read<AuthController>();
    _loadFuture = auth.loadFromStorage();
    _loadFuture.then((_) async {
      if (!mounted) return;
      setState(() {
        _ready = true;
        _goHome = auth.isAuthenticated;
      });
      await _progressController.forward();
      if (!mounted) return;
      final next = _goHome ? const HomeScreen() : const LoginScreen();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => next));
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            SvgPicture.asset(
              'public/Logo Image_margin.svg',
              width: 132,
              height: 132,
            ),
            const SizedBox(height: 16),
            Text(
              'SlemanAkses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.surface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pusat Fasilitas Umum Ramah',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.surface.withOpacity(0.9),
              ),
            ),
            Text(
              'Disabilitas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.surface.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kabupaten Sleman',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.surface.withOpacity(0.85),
              ),
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 72),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _ready ? _progressController.value : null,
                    minHeight: 4,
                    backgroundColor: AppTheme.surface.withOpacity(0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.secondary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
