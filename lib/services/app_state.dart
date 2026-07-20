import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/study_utils.dart';

/// Global application state persisted with SharedPreferences.
class AppState extends ChangeNotifier {
  static const _kYear = 'year';
  static const _kGeminiKey = 'gemini_key';
  static const _kTts = 'tts_enabled';
  static const _kScores = 'best_scores';
  static const _kLearned = 'learned_words';
  static const _kBookmarks = 'bookmarked_qas';
  static const _kLearnedQa = 'learned_qas';
  static const _kThemeMode = 'theme_mode';
  static const _kStreak = 'study_streak';
  static const _kLastStudyDay = 'last_study_day';

  /// Tentative start of the next TSBIE Intermediate Public Examinations.
  /// (IPE is usually held in late February / March; treated as tentative.)
  static final DateTime examDate = DateTime(2027, 3, 1);

  int year = 1;
  bool ttsEnabled = true;
  String geminiKey = '';
  ThemeMode themeMode = ThemeMode.system;
  final Map<String, int> bestScores = {};
  final Set<String> learnedWords = {};

  /// 🔖 Question bookmarks (qaKey format: `subjectId:kind:index`).
  final Set<String> bookmarkedQas = {};

  /// ✅ Questions the student marked as learned.
  final Set<String> learnedQas = {};

  /// 🔥 Consecutive-day study streak.
  int studyStreak = 0;

  /// Last calendar day (yyyy-mm-dd) with study activity.
  String lastStudyDay = '';

  bool get hasKey => geminiKey.trim().isNotEmpty;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    year = p.getInt(_kYear) ?? 1;
    ttsEnabled = p.getBool(_kTts) ?? true;
    geminiKey = p.getString(_kGeminiKey) ?? '';
    final themeIdx = p.getInt(_kThemeMode) ?? 0;
    themeMode = themeIdx >= 0 && themeIdx < ThemeMode.values.length
        ? ThemeMode.values[themeIdx]
        : ThemeMode.system;
    studyStreak = p.getInt(_kStreak) ?? 0;
    lastStudyDay = p.getString(_kLastStudyDay) ?? '';
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
    bookmarkedQas
      ..clear()
      ..addAll(p.getStringList(_kBookmarks) ?? const []);
    learnedQas
      ..clear()
      ..addAll(p.getStringList(_kLearnedQa) ?? const []);
    notifyListeners();
  }

  Future<void> _save(SharedPreferences p) async {
    await p.setInt(_kYear, year);
    await p.setBool(_kTts, ttsEnabled);
    await p.setString(_kGeminiKey, geminiKey);
    await p.setInt(_kThemeMode, themeMode.index);
    await p.setInt(_kStreak, studyStreak);
    await p.setString(_kLastStudyDay, lastStudyDay);
    await p.setString(_kScores, jsonEncode(bestScores));
    await p.setStringList(_kLearned, learnedWords.toList());
    await p.setStringList(_kBookmarks, bookmarkedQas.toList());
    await p.setStringList(_kLearnedQa, learnedQas.toList());
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await _save(p);
  }

  static String _dayStamp(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Days left until the tentative exam date; null once it has passed.
  int? get daysToExam {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(examDate.year, examDate.month, examDate.day);
    final d = target.difference(today).inDays;
    return d >= 0 ? d : null;
  }

  /// Records study activity for today and grows the day-streak.
  /// Safe to call many times — only the first call each day counts.
  void markStudyToday() {
    final now = DateTime.now();
    final today = _dayStamp(now);
    if (lastStudyDay == today) return;
    final yesterday = _dayStamp(DateTime(now.year, now.month, now.day - 1));
    studyStreak = (lastStudyDay == yesterday) ? studyStreak + 1 : 1;
    lastStudyDay = today;
    _persist();
    notifyListeners();
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

  void setThemeMode(ThemeMode m) {
    if (m == themeMode) return;
    themeMode = m;
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
    markStudyToday();
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
    markStudyToday();
    _persist();
    notifyListeners();
  }

  // ---- 🔖 Question bookmarks ----
  bool isBookmarked(String key) => bookmarkedQas.contains(key);

  void toggleBookmark(String key) {
    if (!bookmarkedQas.remove(key)) bookmarkedQas.add(key);
    _persist();
    notifyListeners();
  }

  // ---- ✅ Learned questions ----
  bool isLearnedQa(String key) => learnedQas.contains(key);

  void toggleLearnedQa(String key) {
    if (!learnedQas.remove(key)) {
      learnedQas.add(key);
      markStudyToday();
    }
    _persist();
    notifyListeners();
  }

  /// How many questions of one subject are marked learned.
  int learnedCountFor(String subjectId) =>
      learnedQas.where((k) => keyBelongsTo(k, subjectId)).length;

  /// How many questions of one subject are bookmarked.
  int bookmarkCountFor(String subjectId) =>
      bookmarkedQas.where((k) => keyBelongsTo(k, subjectId)).length;

  Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    year = 1;
    ttsEnabled = true;
    geminiKey = '';
    themeMode = ThemeMode.system;
    studyStreak = 0;
    lastStudyDay = '';
    bestScores.clear();
    learnedWords.clear();
    bookmarkedQas.clear();
    learnedQas.clear();
    notifyListeners();
  }
}
