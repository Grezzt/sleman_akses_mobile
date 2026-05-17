import 'package:flutter/foundation.dart';

import '../data/home_repository.dart';

class HomeController {
  HomeController(this._repository);

  final HomeRepository _repository;

  final ValueNotifier<int> counter = ValueNotifier<int>(0);
  final ValueNotifier<String> message = ValueNotifier<String>('');

  Future<void> load() async {
    message.value = await _repository.getWelcomeMessage();
  }

  void increment() {
    counter.value += 1;
  }

  void dispose() {
    counter.dispose();
    message.dispose();
  }
}
