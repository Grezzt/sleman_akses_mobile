import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/logic/auth_controller.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/logic/profile_controller.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'features/auth/ui/screens/register_screen.dart';
import 'features/home/ui/screens/home_screen.dart';
import 'features/report/ui/screens/create_report_screen.dart';
import 'features/splash/ui/splash_screen.dart';
import 'core/storage/token_storage.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(
            AuthRepository(AuthRemoteDataSource(), TokenStorage()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileController(ProfileRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Sleman Akses',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(),
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => HomeScreen(),
          '/report/create': (_) => const CreateReportScreen(),
        },
      ),
    );
  }
}
