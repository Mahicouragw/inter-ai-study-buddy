import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global application state persisted with SharedPreferences.
class AppState extends ChangeNotifier {
  static const _kYear = 'year';
  static const _kGeminiKey = 'gemini_key';
  static const _kTts = 'tts_enabled';
  static const _kScores = 'best_scores';
  static const _kLearned = 'learned_words';

  int year = 1;
  bool ttsEnabled = true;
  String geminiKey = '';
  final Map<String, int> bestScores = {};
  final Set<String> learnedWords = {};

  bool get hasKey => geminiKey.trim().isNotEmpty;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    year = p.getInt(_kYear) ?? 1;
    ttsEnabled = p.getBool(_kTts) ?? true;
    geminiKey = p.getString(_kGeminiKey) ?? '';
    final rawScores = p.getString(_kScores) ?? '{}';
    try {
      final decoded = jsonDecode(rawScores) as Map<String, dynamic>;
      bestScores
        ..clear()
        ..addAll(decoded.map((k, v) => MapEntry(k, (v as num).toInt())));
    } catch (_) {/* ignore corrupt data */}
    learnedWords
      ..clear()
      ..addAll(p.getStringList(_kLearned) ?? const []);
    notifyListeners();
  }

  Future<void> _save(SharedPreferences p) async {
    await p.setInt(_kYear, year);
    await p.setBool(_kTts, ttsEnabled);
    await p.setString(_kGeminiKey, geminiKey);
    await p.setString(_kScores, jsonEncode(bestScores));
    await p.setStringList(_kLearned, learnedWords.toList());
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await _save(p);
  }

  void setYear(int y) {
    if (y == year) return;
    year = y;
    _persist();
    notifyListeners();
  }

  void setTts(bool v) {
    ttsEnabled = v;
    _persist();
    notifyListeners();
  }

  /// Saves the Gemini API key locally on the device only.
  void setGeminiKey(String key) {
    geminiKey = key.trim();
    _persist();
    notifyListeners();
  }

  Future<void> saveBestScore(String subjectId, int score, int total) async {
    final best = bestScores[subjectId] ?? 0;
    final pct = total == 0 ? 0 : ((score / total) * 100).round();
    if (pct > best) {
      bestScores[subjectId] = pct;
      await _persist();
      notifyListeners();
    }
  }

  void toggleLearned(String word) {
    if (!learnedWords.remove(word)) learnedWords.add(word);
    _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    year = 1;
    ttsEnabled = true;
    geminiKey = '';
    bestScores.clear();
    learnedWords.clear();
    notifyListeners();
  }
}
