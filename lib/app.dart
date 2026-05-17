import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/ui/screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleman Akses',
      theme: AppTheme.build(),
      home: const HomeScreen(),
    );
  }
}
