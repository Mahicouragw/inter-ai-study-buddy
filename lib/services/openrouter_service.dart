import 'dart:convert';
import 'package:http/http.dart' as http;

/// Dedicated OpenRouter service - supports 300+ models via one key
/// Key format: sk-or-v1-... from https://openrouter.ai/keys
/// Default model: anthropic/claude-opus-4.5 (fast, cheap, good for study)
/// Alternatives: anthropic/claude-3.5-sonnet, google/gemini-2.0-flash-001, openai/gpt-4o
class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<String> generate({
    required String apiKey,
    required String prompt,
    String? system,
    String model = 'anthropic/claude-opus-4.5',
    double temperature = 0.4,
  }) async {
    final messages = <Map<String, String>>[];
    if (system != null && system.isNotEmpty) {
      messages.add({'role': 'system', 'content': system});
    }
    messages.add({'role': 'user', 'content': prompt});

    final res = await http.post(
      Uri.parse(_baseUrl),
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

    if (res.statusCode != 200) {
      throw Exception('OpenRouter error ${res.statusCode}: ${res.body.substring(0, 500)}');
    }

    final data = jsonDecode(res.body);
    return data['choices'][0]['message']['content'] as String;
  }
}
