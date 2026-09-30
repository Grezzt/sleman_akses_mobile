import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceGuidanceService {
  static final VoiceGuidanceService _instance = VoiceGuidanceService._internal();
  factory VoiceGuidanceService() => _instance;
  VoiceGuidanceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool isEnabled = true;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage('id-ID');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('VoiceGuidanceService init error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!isEnabled || text.trim().isEmpty) return;

    try {
      if (!_isInitialized) {
        await init();
      }
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('VoiceGuidanceService speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('VoiceGuidanceService stop error: $e');
    }
  }

  void toggleEnabled() {
    isEnabled = !isEnabled;
    if (!isEnabled) {
      stop();
    }
  }
}
