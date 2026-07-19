import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps speech-to-text (microphone) and text-to-speech (read aloud).
/// Fail-safe: if the device mic is unavailable the app keeps working.
class SpeechService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool sttReady = false;
  bool listening = false;

  Future<void> init() async {
    try {
      sttReady = await _stt.initialize();
    } catch (_) {
      sttReady = false;
    }
    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  bool get isListening => _stt.isListening;

  /// Starts listening; each partial/final result is sent to [onWords].
  Future<bool> listen(void Function(String words) onWords) async {
    if (!sttReady) return false;
    try {
      listening = true;
      await _stt.listen(
        onResult: (r) => onWords(r.recognizedWords),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        partialResults: true,
      );
      return true;
    } catch (_) {
      listening = false;
      return false;
    }
  }

  Future<void> stopListening() async {
    listening = false;
    try {
      await _stt.stop();
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.speak(text.trim());
    } catch (_) {}
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
