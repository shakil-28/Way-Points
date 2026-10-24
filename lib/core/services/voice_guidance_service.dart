import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Spoken Voice Guidance Service managing turn-by-turn audio prompts in Bangla & English
class VoiceGuidanceService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isMuted = false;
  static bool _isInitialized = false;
  static String _lastSpokenPrompt = '';

  static bool get isMuted => _isMuted;

  static void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      _tts.stop();
    }
  }

  static Future<void> _initTts() async {
    if (_isInitialized) return;
    try {
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS init note: $e');
    }
  }

  /// Synthesize spoken audio prompt for upcoming turn maneuver
  static Future<void> speakPrompt(String text, {String language = 'Bengali (BD - Farhana)'}) async {
    if (_isMuted || text.isEmpty || text == _lastSpokenPrompt) return;

    _lastSpokenPrompt = text;
    await _initTts();

    final isBangla = language.toLowerCase().contains('bengali') || language.toLowerCase().contains('bangla');
    final langCode = isBangla ? 'bn-BD' : 'en-US';

    try {
      await _tts.setLanguage(langCode);
      await _tts.speak(text);
      debugPrint('🔊 Speaking [$langCode]: $text');
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  static Future<void> stop() async {
    await _tts.stop();
  }

  static void clearPromptHistory() {
    _lastSpokenPrompt = '';
  }
}
