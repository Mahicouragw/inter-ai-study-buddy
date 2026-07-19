import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);
  @override
  String toString() => message;
}

/// Thin REST client for the Google Gemini free API.
/// Get a free key at https://aistudio.google.com/app/apikey
class GeminiService {
  static const List<String> _models = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
  ];
  static const String _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Generates text; automatically falls back across available models.
  Future<String> generate({
    required String apiKey,
    required String prompt,
    String? system,
    double temperature = 0.4,
  }) async {
    String lastError = 'Could not reach Gemini. Check your internet.';
    for (final model in _models) {
      try {
        return await _call(model, apiKey, prompt, system, temperature);
      } on _ModelUnavailable {
        lastError = 'Trying another model...';
        continue; // try the next model
      } on GeminiException catch (e) {
        lastError = e.message;
        rethrow;
      } catch (_) {
        lastError = 'Network error. Check your internet connection.';
      }
    }
    throw GeminiException(lastError);
  }

  Future<String> _call(String model, String apiKey, String prompt,
      String? system, double temperature) async {
    final uri = Uri.parse('$_base/$model:generateContent?key=$apiKey');
    final body = <String, dynamic>{
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {'temperature': temperature},
    };
    if (system != null && system.isNotEmpty) {
      body['systemInstruction'] = {
        'parts': [
          {'text': system}
        ]
      };
    }

    http.Response res;
    try {
      res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 45));
    } catch (_) {
      throw const GeminiException('Network error. Check your internet.');
    }

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = data['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final parts = candidates[0]?['content']?['parts'];
        if (parts is List) {
          final text = parts
              .map((p) => (p is Map && p['text'] is String) ? p['text'] : '')
              .where((t) => t.toString().isNotEmpty)
              .join('\n')
              .trim();
          if (text.isNotEmpty) return text;
        }
      }
      throw const GeminiException('Gemini returned an empty reply.');
    }

    if (res.statusCode == 404) throw const _ModelUnavailable();
    if (res.statusCode == 400 || res.statusCode == 401 || res.statusCode == 403) {
      var msg = 'Gemini rejected the request (HTTP ${res.statusCode}).';
      try {
        final err = jsonDecode(res.body);
        final m = err['error']?['message'];
        if (m is String && m.isNotEmpty) msg = m;
      } catch (_) {}
      if (msg.toLowerCase().contains('api key') ||
          msg.toUpperCase().contains('API_KEY_INVALID')) {
        msg = 'Invalid Gemini API key. Create a free key at aistudio.google.com and paste it in Settings.';
      }
      throw GeminiException(msg);
    }
    if (res.statusCode == 429) {
      throw const GeminiException(
          'Free quota exhausted. Wait a minute and try again.');
    }
    throw GeminiException('Gemini error (HTTP ${res.statusCode}). Try again.');
  }
}

class _ModelUnavailable implements GeminiException {
  const _ModelUnavailable();
  @override
  final String message = 'Model unavailable';
  @override
  String toString() => message;
}
