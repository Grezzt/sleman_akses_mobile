import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../data/onboarding_storage.dart';
import '../../auth/ui/screens/login_screen.dart';
import '../../home/ui/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.goHome});

  final bool goHome;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingStorage _storage = OnboardingStorage();
  int _pageIndex = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      imageAsset: 'public/onboarding slide 1.svg',
      title: 'Temukan Fasilitas Ramah Difabel',
      description:
          'Cari dan temukan berbagai fasilitas umum seperti ramp, lift, dan toilet aksesibel di sekitar Anda dengan mudah.',
    ),
    _OnboardingPage(
      imageAsset: 'public/onboarding slide 2.svg',
      title: 'Laporkan Fasilitas di Sekitarmu',
      description:
          'Bantu sesama dengan melaporkan dan menandai lokasi fasilitas aksesibel baru di peta melalui fitur crowdsourcing kami.',
    ),
    _OnboardingPage(
      imageAsset: 'public/onboarding slide 3.svg',
      title: 'Bersama Wujudkan Sleman Inklusif',
      description:
          'Kontribusi Anda membantu pemerintah dalam meningkatkan infrastruktur inklusif untuk mewujudkan Sleman yang ramah bagi semua.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await _storage.setCompleted();
    if (!mounted) return;
    final next = widget.goHome ? const HomeScreen() : const LoginScreen();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  void _nextPage() {
    if (_pageIndex >= _pages.length - 1) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _pageIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20, top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Column(
                    children: [
                      Expanded(
                        flex: 35,
                        child: Center(
                          child: SvgPicture.asset(
                            page.imageAsset,
                            width: 260,
                            height: 260,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 65,
                        child: _OnboardingCard(
                          title: page.title,
                          description: page.description,
                          pageIndex: _pageIndex,
                          pageCount: _pages.length,
                          isLast: isLast,
                          onNext: _nextPage,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  final String imageAsset;
  final String title;
  final String description;
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.title,
    required this.description,
    required this.pageIndex,
    required this.pageCount,
    required this.isLast,
    required this.onNext,
  });

  final String title;
  final String description;
  final int pageIndex;
  final int pageCount;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textMuted,
              height: 1.6,
            ),
          ),
          const Spacer(),
          const SizedBox(height: 26),
          _PageIndicator(index: pageIndex, count: pageCount),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(
                isLast ? 'Mulai' : 'Lanjut',
                style: const TextStyle(
                  color: AppTheme.surface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 10,
          width: isActive ? 34 : 10,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.border,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
