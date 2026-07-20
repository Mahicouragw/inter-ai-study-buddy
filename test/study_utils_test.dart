import 'package:flutter_test/flutter_test.dart';
import 'package:inter_ai_study_buddy/utils/study_utils.dart';
import 'package:inter_ai_study_buddy/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('spreadIndices (priority set)', () {
    test('handles empty and small lists', () {
      expect(spreadIndices(0, 5), isEmpty);
      expect(spreadIndices(3, 8), [0, 1, 2]);
    });

    test('spreads evenly and covers first & last chapter', () {
      final idx = spreadIndices(10, 5);
      expect(idx.first, 0);
      expect(idx.last, 9);
      expect(idx.toSet().length, idx.length); // unique
      expect(idx, List.of(idx)..sort()); // sorted
    });

    test('works for real subject sizes', () {
      for (final n in [6, 7, 9, 13, 21, 40]) {
        final idx = spreadIndices(n, 5);
        expect(idx.first, 0);
        expect(idx.last, n - 1);
        expect(idx.toSet().length, idx.length);
        for (final i in idx) {
          expect(i, greaterThanOrEqualTo(0));
          expect(i, lessThan(n));
        }
      }
    });
  });

  group('qaKey / parseQaKey', () {
    test('roundtrip', () {
      final k = qaKey('eco1', 'E', 4);
      expect(k, 'eco1:E:4');
      final ref = parseQaKey(k)!;
      expect(ref.subjectId, 'eco1');
      expect(ref.kind, 'E');
      expect(ref.index, 4);
    });

    test('rejects malformed keys', () {
      expect(parseQaKey('junk'), isNull);
      expect(parseQaKey('a:b:x'), isNull);
      expect(parseQaKey(''), isNull);
    });

    test('keyBelongsTo', () {
      expect(keyBelongsTo('eco1:S:2', 'eco1'), isTrue);
      expect(keyBelongsTo('eco2:S:2', 'eco1'), isFalse);
      // 'eco1' must not match a subject like 'eco10' (prefix trap)
      expect(keyBelongsTo('eco10:S:2', 'eco1'), isFalse);
    });
  });

  group('AppState streak & toggles', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('study streak counts once per day', () async {
      final s = AppState();
      await s.load();
      expect(s.studyStreak, 0);
      s.markStudyToday();
      expect(s.studyStreak, 1);
      s.markStudyToday(); // same day -> still 1
      expect(s.studyStreak, 1);
    });

    test('bookmark and learned toggles', () async {
      final s = AppState();
      await s.load();
      const key = 'eco1:S:0';
      expect(s.isBookmarked(key), isFalse);
      s.toggleBookmark(key);
      expect(s.isBookmarked(key), isTrue);
      s.toggleBookmark(key);
      expect(s.isBookmarked(key), isFalse);

      s.toggleLearnedQa(key);
      expect(s.isLearnedQa(key), isTrue);
      expect(s.learnedCountFor('eco1'), 1);
      expect(s.studyStreak, 1); // marking learned counts as study
      s.toggleLearnedQa(key); // toggling again removes it
      expect(s.isLearnedQa(key), isFalse);
      expect(s.learnedCountFor('eco1'), 0);
    });

    test('daysToExam is non-negative or null', () async {
      final s = AppState();
      final d = s.daysToExam;
      expect(d == null || d >= 0, isTrue);
    });
  });
}
