import 'package:flutter/material.dart';

import '../../logic/home_controller.dart';
import '../../data/datasources/home_local_data_source.dart';
import '../../data/home_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(HomeRepository(HomeLocalDataSource()));
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleman Akses')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: _controller.message,
                  builder: (context, message, _) {
                    return Text(
                      message,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Jumlah klik:'),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: _controller.counter,
                  builder: (context, value, _) {
                    return Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.displaySmall,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
