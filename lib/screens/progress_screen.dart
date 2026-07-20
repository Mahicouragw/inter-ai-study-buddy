import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/vocabulary.dart';
import '../models.dart';
import '../services/app_state.dart';
import 'subjects_screen.dart';

/// Student dashboard: study streak, exam countdown, per-subject progress.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final subjects = subjectsForYear(state.year);
    final days = state.daysToExam;

    var totalQa = 0;
    var totalLearned = 0;
    for (final s in subjects) {
      totalQa += s.shortAnswers.length + s.essays.length;
      totalLearned += state.learnedCountFor(s.id);
    }
    final overall = totalQa == 0 ? 0.0 : totalLearned / totalQa;

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress 📊')),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
        // ---- headline numbers ----
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 8, children: [
                Chip(
                  avatar: const Text('🔥'),
                  label: Text(
                      '${state.studyStreak} day${state.studyStreak == 1 ? '' : 's'} streak'),
                ),
                Chip(
                  avatar: const Text('⏳'),
                  label: Text(days == null
                      ? 'Exam season — all the best! 🎉'
                      : '$days days to IPE March ${AppState.examDate.year} (tentative)'),
                ),
              ]),
              const SizedBox(height: 14),
              Semantics(
                label:
                    'Overall progress for Inter ${state.year == 1 ? "1st" : "2nd"} year: '
                    '${(overall * 100).round()} percent, $totalLearned of $totalQa questions learned.',
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inter ${state.year == 1 ? "1st" : "2nd"} year overall: '
                        '$totalLearned / $totalQa questions learned '
                        '(${(overall * 100).round()}%)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: overall, minHeight: 8),
                    ]),
              ),
            ]),
          ),
        ),

        // ---- per subject ----
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
          child: Text('Subject wise',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        for (final s in subjects) _subjectTile(context, state, s),

        // ---- vocabulary ----
        Card(
          child: ListTile(
            leading: const Text('🔤', style: TextStyle(fontSize: 28)),
            title: const Text('English vocabulary'),
            subtitle: Text(
                '${state.learnedWords.length} of ${vocabulary.length} words learned'),
            trailing: Text(
                '${vocabulary.isEmpty ? 0 : ((state.learnedWords.length / vocabulary.length) * 100).round()}%'),
          ),
        ),

        // ---- quiz bests ----
        if (subjects.any((s) => (state.bestScores[s.id] ?? 0) > 0))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
            child: Text('Best quiz scores',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
        for (final s in subjects)
          if ((state.bestScores[s.id] ?? 0) > 0)
            Card(
              child: ListTile(
                leading: Text(s.emoji, style: const TextStyle(fontSize: 28)),
                title: Text('${s.name} quiz'),
                trailing: Text('${state.bestScores[s.id]}%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tip: streak grows every day you study — finish a quiz, revise '
            'flashcards, or mark questions as learned. Switch year on the Home '
            'screen to see the other year.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ]),
    );
  }

  Widget _subjectTile(BuildContext context, AppState state, Subject s) {
    final total = s.shortAnswers.length + s.essays.length;
    final learned = state.learnedCountFor(s.id);
    final pct = total == 0 ? 0.0 : learned / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Semantics(
          label:
              '${s.name}: $learned of $total questions learned, ${(pct * 100).round()} percent.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(s.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(s.name,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
              Text('${(pct * 100).round()}%'),
            ]),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: pct, minHeight: 8),
            const SizedBox(height: 6),
            Text('✅ $learned / $total questions learned'
                '${state.bookmarkCountFor(s.id) > 0 ? '   •   🔖 ${state.bookmarkCountFor(s.id)} saved' : ''}'),
          ]),
        ),
      ),
    );
  }
}
