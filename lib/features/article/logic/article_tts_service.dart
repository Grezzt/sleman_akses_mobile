import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsPlayerState { stopped, playing, paused }

class ArticleTtsService extends ChangeNotifier {
  ArticleTtsService() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();

  TtsPlayerState _state = TtsPlayerState.stopped;
  List<String> _segments = [];
  int _currentIndex = 0;
  double _speedMultiplier = 1.0;
  bool _isSummaryIncluded = false;
  bool _isPluginAvailable = true;
  String? _errorMessage;

  // Getters
  TtsPlayerState get state => _state;
  bool get isPlaying => _state == TtsPlayerState.playing;
  bool get isPaused => _state == TtsPlayerState.paused;
  bool get isStopped => _state == TtsPlayerState.stopped;
  int get currentIndex => _currentIndex;
  int get totalSegments => _segments.length;
  double get speedMultiplier => _speedMultiplier;
  bool get isSummaryIncluded => _isSummaryIncluded;
  bool get isPluginAvailable => _isPluginAvailable;
  String? get errorMessage => _errorMessage;

  String get statusText {
    if (!_isPluginAvailable) {
      return 'TTS butuh restart penuh aplikasi (re-run)';
    }
    if (_errorMessage != null) {
      return _errorMessage!;
    }
    if (isStopped) return 'Siap mendengarkan';
    if (isPaused) return 'Dijeda';

    if (_isSummaryIncluded && _currentIndex == 0) {
      return 'Membacakan: Ringkasan (${_currentIndex + 1}/$totalSegments)';
    }

    final paraNum = _isSummaryIncluded ? _currentIndex : _currentIndex + 1;
    final totalPara = _isSummaryIncluded ? totalSegments - 1 : totalSegments;
    return 'Membacakan: Paragraf $paraNum ($paraNum/$totalPara)';
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('id-ID');
      await _flutterTts.setSpeechRate(0.48 * _speedMultiplier);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        if (_state != TtsPlayerState.playing) {
          _state = TtsPlayerState.playing;
          notifyListeners();
        }
      });

      _flutterTts.setCompletionHandler(() {
        _playNext();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('[TTS] Native error: $msg');
        if (_state == TtsPlayerState.playing) {
          _playNext();
        }
      });

      _flutterTts.setCancelHandler(() {
        if (_state == TtsPlayerState.playing) {
          _state = TtsPlayerState.stopped;
          notifyListeners();
        }
      });

      _isPluginAvailable = true;
    } on MissingPluginException catch (e) {
      debugPrint('[TTS] Plugin not registered in native build: $e');
      _isPluginAvailable = false;
      _errorMessage = 'Harap stop dan jalankan ulang (re-run) aplikasi.';
      notifyListeners();
    } catch (e) {
      debugPrint('[TTS] Init failed: $e');
    }
  }

  Future<void> startReading({
    String? summary,
    required List<String> paragraphs,
    int startIndex = 0,
  }) async {
    if (!_isPluginAvailable) {
      notifyListeners();
      return;
    }

    await stop();

    _segments = [];
    _isSummaryIncluded = summary != null && summary.trim().isNotEmpty;
    if (_isSummaryIncluded) {
      _segments.add(summary!.trim());
    }
    _segments.addAll(paragraphs.where((p) => p.trim().isNotEmpty));

    if (_segments.isEmpty) return;

    _currentIndex = startIndex.clamp(0, _segments.length - 1);
    _state = TtsPlayerState.playing;
    _errorMessage = null;
    notifyListeners();

    await _speakCurrent();
  }

  Future<void> _speakCurrent() async {
    if (!_isPluginAvailable) return;
    if (_currentIndex >= _segments.length) {
      await stop();
      return;
    }

    final text = _segments[_currentIndex];
    notifyListeners();

    try {
      await _flutterTts.setSpeechRate(0.48 * _speedMultiplier);
      await _flutterTts.speak(text);
    } on MissingPluginException catch (e) {
      debugPrint('[TTS] MissingPluginException during speak: $e');
      _isPluginAvailable = false;
      _errorMessage = 'Harap stop dan jalankan ulang (re-run) aplikasi.';
      _state = TtsPlayerState.stopped;
      notifyListeners();
    } catch (e) {
      debugPrint('[TTS] Speak error: $e');
    }
  }

  Future<void> _playNext() async {
    if (_state != TtsPlayerState.playing) return;

    if (_currentIndex + 1 < _segments.length) {
      _currentIndex++;
      await _speakCurrent();
    } else {
      await stop();
    }
  }

  Future<void> pause() async {
    if (_state != TtsPlayerState.playing) return;
    try {
      await _flutterTts.pause();
    } catch (_) {
      try {
        await _flutterTts.stop();
      } catch (_) {}
    }
    _state = TtsPlayerState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_state != TtsPlayerState.paused) return;
    _state = TtsPlayerState.playing;
    notifyListeners();
    await _speakCurrent();
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _state = TtsPlayerState.stopped;
    _currentIndex = 0;
    notifyListeners();
  }

  Future<void> jumpToParagraph(int index) async {
    if (index < 0 || index >= _segments.length) return;
    _currentIndex = index;
    _state = TtsPlayerState.playing;
    notifyListeners();
    await _speakCurrent();
  }

  Future<void> setSpeed(double multiplier) async {
    _speedMultiplier = multiplier;
    notifyListeners();

    if (_state == TtsPlayerState.playing && _isPluginAvailable) {
      try {
        await _flutterTts.setSpeechRate(0.48 * _speedMultiplier);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    try {
      _flutterTts.stop();
    } catch (_) {}
    super.dispose();
  }
}
