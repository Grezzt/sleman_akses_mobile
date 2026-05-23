import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/auth_controller.dart';
import '../../../home/ui/screens/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = context.read<AuthController>().loadFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final auth = context.watch<AuthController>();
        if (auth.isAuthenticated) {
          return HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
