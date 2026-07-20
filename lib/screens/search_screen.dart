import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../widgets/qa_tile.dart';
import 'subjects_screen.dart';

/// Global search across every question of the selected Inter year.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _Hit {
  final Subject subject;
  final String kind;
  final int index;
  final QA qa;
  const _Hit(this.subject, this.kind, this.index, this.qa);
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Hit> _search(int year) {
    final q = _query.trim().toLowerCase();
    if (q.length < 2) return const [];
    final hits = <_Hit>[];
    for (final s in subjectsForYear(year)) {
      for (var i = 0; i < s.shortAnswers.length; i++) {
        final qa = s.shortAnswers[i];
        if (qa.q.toLowerCase().contains(q) || qa.a.toLowerCase().contains(q)) {
          hits.add(_Hit(s, 'S', i, qa));
        }
      }
      for (var i = 0; i < s.essays.length; i++) {
        final qa = s.essays[i];
        if (qa.q.toLowerCase().contains(q) || qa.a.toLowerCase().contains(q)) {
          hits.add(_Hit(s, 'E', i, qa));
        }
      }
      if (hits.length >= 60) break;
    }
    return hits.take(60).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hits = _search(state.year);
    return Scaffold(
      appBar: AppBar(title: const Text('Search Questions 🔍')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText:
                  'Search Inter ${state.year == 1 ? "1st" : "2nd"} year Q&A',
              hintText: 'e.g. demand, RBI, constitution, journal',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: _query.trim().length < 2
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Type at least 2 letters.\nSearches every 2-mark and 5/10-mark question '
                      'in all six subjects of Inter ${state.year == 1 ? "1st" : "2nd"} year.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              : hits.isEmpty
                  ? Center(
                      child: Text('No matches for "$_query".',
                          style: Theme.of(context).textTheme.titleMedium),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                          child: Semantics(
                            liveRegion: true,
                            child: Text('${hits.length} result(s) for "$_query"',
                                style: Theme.of(context).textTheme.labelLarge),
                          ),
                        ),
                        for (final h in hits)
                          QaTile(
                            subject: h.subject,
                            kind: h.kind,
                            index: h.index,
                            qa: h.qa,
                            subtitleLabel:
                                '${h.subject.emoji} ${h.subject.name} • ${h.kind == 'E' ? "essay" : "short"}',
                          ),
                      ],
                    ),
        ),
      ]),
    );
  }
}
