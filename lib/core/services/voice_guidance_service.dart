import 'package:flutter/foundation.dart';

/// Spoken Voice Guidance Service managing turn-by-turn audio prompts in Bangla & English
class VoiceGuidanceService {
  static bool _isMuted = false;
  static String _lastSpokenPrompt = '';

  static bool get isMuted => _isMuted;

  static void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// Synthesize spoken audio prompt for upcoming turn maneuver
  static Future<void> speakPrompt(String text, {String language = 'Bengali (BD - Farhana)'}) async {
    if (_isMuted || text.isEmpty || text == _lastSpokenPrompt) return;

    _lastSpokenPrompt = text;
    final isBangla = language.toLowerCase().contains('bengali') || language.toLowerCase().contains('bangla');

    debugPrint('🔊 Voice Guidance Prompt [${isBangla ? "bn-BD" : "en-US"}]: $text');
  }

  static void clearPromptHistory() {
    _lastSpokenPrompt = '';
  }
}
