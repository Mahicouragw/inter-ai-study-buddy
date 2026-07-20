import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/year1_subjects.dart';
import '../data/year2_subjects.dart';
import '../models.dart';
import '../services/app_state.dart';
import '../utils/study_utils.dart';
import '../widgets/qa_tile.dart';

/// All 🔖 saved questions across both Inter years, grouped by subject.
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  static final Map<String, Subject> _byId = {
    for (final s in year1Subjects) s.id: s,
    for (final s in year2Subjects) s.id: s,
  };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Group bookmarks by subject, keeping a stable subject order.
    final grouped = <String, List<QaRef>>{};
    for (final key in state.bookmarkedQas) {
      final ref = parseQaKey(key);
      if (ref == null || !_byId.containsKey(ref.subjectId)) continue;
      grouped.putIfAbsent(ref.subjectId, () => []).add(ref);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Questions 🔖')),
      body: grouped.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nothing saved yet.\n\nOpen any subject → Questions, and tap '
                  '"Save 🔖" on tough questions. They will appear here for '
                  'quick last-minute revision.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                for (final s in _byId.values)
                  if (grouped.containsKey(s.id)) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                      child: Text(
                        '${s.emoji} ${s.name} — Inter '
                        '${s.year == 1 ? "1st" : "2nd"} year',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (final ref in grouped[s.id]!)
                      if ((ref.kind == 'S' &&
                              ref.index < s.shortAnswers.length) ||
                          (ref.kind == 'E' && ref.index < s.essays.length))
                        QaTile(
                          subject: s,
                          kind: ref.kind,
                          index: ref.index,
                          qa: ref.kind == 'S'
                              ? s.shortAnswers[ref.index]
                              : s.essays[ref.index],
                        ),
                  ],
              ],
            ),
    );
  }
}
