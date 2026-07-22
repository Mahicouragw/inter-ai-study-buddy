import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiException implements Exception {
  final String message;
  const GeminiException(this.message);
  @override
  String toString() => message;
}

/// Unified AI service: supports Gemini (AIza...) and OpenRouter (sk-or-v1-...) + OpenAI
/// Get free Gemini key at https://aistudio.google.com/app/apikey
/// Get OpenRouter key at https://openrouter.ai/keys (supports GPT-4o, Claude, Gemini via one key)
class GeminiService {
  static const List<String> _models = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash-latest',
  ];
  static const String _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Generates text; automatically detects provider by key prefix
  Future<String> generate({
    required String apiKey,
    required String prompt,
    String? system,
    double temperature = 0.4,
  }) async {
    final key = apiKey.trim();
    // OpenRouter detection: sk-or-v1-...
    if (key.startsWith('sk-or-v1-') || key.startsWith('sk-or-')) {
      return await _callOpenRouter(key, prompt, system, temperature);
    }
    // OpenAI direct key (sk-...) detection: treat as OpenAI via OpenRouter compatible path
    if (key.startsWith('sk-') && !key.startsWith('sk-or-')) {
      // Could be OpenAI or OpenRouter legacy, try OpenRouter first with openai model
      try {
        return await _callOpenRouter(key, prompt, system, temperature);
      } catch (_) {
        // fallback to Gemini logic? but key is not Gemini, so will fail - rethrow
        rethrow;
      }
    }

    // Otherwise assume Gemini (AIza...)
    String lastError = 'Could not reach Gemini. Check your internet.';
    for (final model in _models) {
      try {
        return await _callGemini(model, key, prompt, system, temperature);
      } on _ModelUnavailable {
        lastError = 'Trying another model...';
        continue;
      } on GeminiException catch (e) {
        lastError = e.message;
        rethrow;
      } catch (_) {
        lastError = 'Network error. Check your internet connection.';
      }
    }
    throw GeminiException(lastError);
  }

  // --- OpenRouter implementation (supports GPT-4o, Claude, Gemini via one key) ---
  Future<String> _callOpenRouter(String apiKey, String prompt, String? system, double temperature) async {
    final uri = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    
    // Default model - good balance for study buddy: gpt-4o-mini is fast & cheap, or use claude-3.5-sonnet for better reasoning
    const model = 'anthropic/claude-3-opus'; // can also be 'anthropic/claude-3.5-sonnet' or 'google/gemini-2.0-flash-001'
    
    final messages = <Map<String, String>>[];
    if (system != null && system.isNotEmpty) {
      messages.add({'role': 'system', 'content': system});
    }
    messages.add({'role': 'user', 'content': prompt});

    http.Response res;
    try {
      res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/Mahicouragw/inter-ai-study-buddy',
          'X-Title': 'Inter AI Study Buddy',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': 2000,
        }),
      ).timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const GeminiException('Network error calling OpenRouter. Check internet.');
    }

    if (res.statusCode == 200) {
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final content = data['choices']?[0]?['message']?['content'];
        if (content is String && content.trim().isNotEmpty) {
          return content.trim();
        }
        throw const GeminiException('OpenRouter returned empty reply.');
      } catch (e) {
        if (e is GeminiException) rethrow;
        throw GeminiException('Failed to parse OpenRouter response: $e');
      }
    }

    if (res.statusCode == 401 || res.statusCode == 403) {
      var msg = 'OpenRouter rejected API key (HTTP ${res.statusCode}). Check key in Settings.';
      try {
        final err = jsonDecode(res.body);
        final m = err['error']?['message'];
        if (m is String && m.isNotEmpty) msg = m;
      } catch (_) {}
      if (msg.toLowerCase().contains('api key') || msg.toLowerCase().contains('unauthorized')) {
        msg = 'Invalid OpenRouter API key. Get key at openrouter.ai/keys and paste in Settings. Your key should start with sk-or-v1-';
      }
      throw GeminiException(msg);
    }
    if (res.statusCode == 429) {
      throw const GeminiException('OpenRouter quota exhausted. Wait or add credits at openrouter.ai.');
    }
    throw GeminiException('OpenRouter error (HTTP ${res.statusCode}): ${res.body.substring(0, 500)}');
  }

  Future<String> _callGemini(String model, String apiKey, String prompt,
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
        msg = 'Invalid Gemini API key. Create a free key at aistudio.google.com and paste it in Settings. Or use OpenRouter key (sk-or-v1-...) which also works!';
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
