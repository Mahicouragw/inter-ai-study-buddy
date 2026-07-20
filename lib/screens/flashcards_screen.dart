import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../services/speech_service.dart';
import '../utils/study_utils.dart';
import 'subjects_screen.dart';

class _Card {
  final String kind; // 'S' or 'E'
  final int index;
  final QA qa;
  const _Card(this.kind, this.index, this.qa);
}

/// Subject picker shown before starting a flashcard session.
class FlashcardsSubjectPicker extends StatelessWidget {
  const FlashcardsSubjectPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final subjects = subjectsForYear(state.year);
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards 🃏')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Text(
              'Pick a subject to revise. Read the question, guess the answer '
              'in your mind, then flip the card and check yourself.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          for (final s in subjects)
            Card(
              child: ListTile(
                leading: Text(s.emoji, style: const TextStyle(fontSize: 30)),
                title: Text(s.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${s.shortAnswers.length + s.essays.length} cards • ✅ '
                    '${context.watch<AppState>().learnedCountFor(s.id)} learned'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => FlashcardsScreen(subject: s)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Swipe-free, TalkBack-first flashcard revision.
class FlashcardsScreen extends StatefulWidget {
  final Subject subject;
  const FlashcardsScreen({super.key, required this.subject});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  static const _filters = ['All', '⭐ Priority', '🔖 Saved', '❌ Pending'];

  String _filter = 'All';
  List<_Card> _order = [];
  int _i = 0;
  bool _showAnswer = false;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void dispose() {
    if (_speaking) {
      context.read<SpeechService>().stopSpeaking();
    }
    super.dispose();
  }

  List<int> _priorityShort() =>
      spreadIndices(widget.subject.shortAnswers.length, 8);
  List<int> _priorityEssays() =>
      spreadIndices(widget.subject.essays.length, 5);

  void _rebuild() {
    final state = context.read<AppState>();
    final s = widget.subject;
    final priS = _priorityShort().toSet();
    final priE = _priorityEssays().toSet();
    final cards = <_Card>[];
    for (var i = 0; i < s.shortAnswers.length; i++) {
      if (_accept(state, 'S', i, priS.contains(i))) {
        cards.add(_Card('S', i, s.shortAnswers[i]));
      }
    }
    for (var i = 0; i < s.essays.length; i++) {
      if (_accept(state, 'E', i, priE.contains(i))) {
        cards.add(_Card('E', i, s.essays[i]));
      }
    }
    setState(() {
      _order = cards;
      _i = 0;
      _showAnswer = false;
    });
  }

  bool _accept(AppState state, String kind, int index, bool isPriority) {
    final key = qaKey(widget.subject.id, kind, index);
    switch (_filter) {
      case '⭐ Priority':
        return isPriority;
      case '🔖 Saved':
        return state.isBookmarked(key);
      case '❌ Pending':
        return !state.isLearnedQa(key);
      default:
        return true;
    }
  }

  void _announce(String msg) {
    // ignore: deprecated_member_use -- multi-window replacement API is not
    // available on all Android targets this app supports; announce works.
    SemanticsService.announce(msg, TextDirection.ltr);
  }

  Future<void> _stopSpeech() async {
    if (_speaking) {
      await context.read<SpeechService>().stopSpeaking();
      if (mounted) setState(() => _speaking = false);
    }
  }

  Future<void> _listen() async {
    final card = _order[_i];
    final speech = context.read<SpeechService>();
    if (_speaking) {
      await _stopSpeech();
      return;
    }
    setState(() => _speaking = true);
    await speech.speak(
        'Question. ${card.qa.q}. Answer. ${card.qa.a}');
    if (mounted) setState(() => _speaking = false);
  }

  void _goTo(int index) {
    _stopSpeech();
    setState(() {
      _i = index;
      _showAnswer = false;
    });
    _announce('Card ${_i + 1} of ${_order.length}. Question: ${_order[_i].qa.q}');
  }

  Future<void> _next({required bool knewIt}) async {
    if (knewIt) {
      final card = _order[_i];
      final key = qaKey(widget.subject.id, card.kind, card.index);
      if (!context.read<AppState>().isLearnedQa(key)) {
        context.read<AppState>().toggleLearnedQa(key);
      }
    }
    if (_i + 1 >= _order.length) {
      _stopSpeech();
      setState(() {
        _i = _order.length; // completed
        _showAnswer = false;
      });
      _announce('Flashcards finished. Great work!');
      return;
    }
    _goTo(_i + 1);
  }

  void _shuffle() {
    _stopSpeech();
    final list = List<_Card>.from(_order)..shuffle();
    setState(() {
      _order = list;
      _i = 0;
      _showAnswer = false;
    });
    _announce('Cards shuffled. Card 1 of ${list.length}.');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject.emoji} Flashcards'),
        actions: [
          IconButton(
            tooltip: 'Shuffle cards',
            icon: const Icon(Icons.shuffle),
            onPressed: _order.isEmpty ? null : _shuffle,
          ),
        ],
      ),
      body: Column(children: [
        // ---- filter chips ----
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(children: [
            for (final f in _filters)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) {
                    _stopSpeech();
                    setState(() => _filter = f);
                    _rebuild();
                    _announce('$f filter selected.');
                  },
                ),
              ),
          ]),
        ),
        const SizedBox(height: 4),
        Expanded(child: _buildBody(state)),
      ]),
    );
  }

  Widget _buildBody(AppState state) {
    if (_order.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _filter == '🔖 Saved'
                ? 'No saved questions yet.\nOpen Subjects → Questions and tap "Save 🔖" on the ones you want here.'
                : _filter == '❌ Pending'
                    ? 'Everything is marked learned in this subject. Amazing! 🎉'
                    : 'No cards available.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }
    if (_i >= _order.length) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text('All ${_order.length} cards done!',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.replay),
            label: const Text('Restart'),
            onPressed: () => _goTo(0),
          ),
        ]),
      );
    }
    final card = _order[_i];
    final key = qaKey(widget.subject.id, card.kind, card.index);
    final bookmarked = state.isBookmarked(key);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          liveRegion: true,
          label:
              'Card ${_i + 1} of ${_order.length}. ${_showAnswer ? "Answer shown." : "Question shown."}',
          child: Text(
            'Card ${_i + 1} / ${_order.length}${card.kind == 'E' ? '  •  essay' : '  •  short'}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('❓ ${card.qa.q}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (_showAnswer) ...[
                const Divider(height: 28),
                Text('✅ ${card.qa.a}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.45)),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 12),
        if (!_showAnswer)
          FilledButton.icon(
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16)),
            icon: const Icon(Icons.flip),
            label: const Text('Show answer', style: TextStyle(fontSize: 17)),
            onPressed: () {
              setState(() => _showAnswer = true);
              _announce('Answer. ${card.qa.a}');
            },
          )
        else ...[
          FilledButton.icon(
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.check_circle_outline),
            label:
                const Text('I knew it ✅', style: TextStyle(fontSize: 17)),
            onPressed: () => _next(knewIt: true),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.replay),
            label: const Text('Needs revision 🔁',
                style: TextStyle(fontSize: 17)),
            onPressed: () => _next(knewIt: false),
          ),
        ],
        const SizedBox(height: 12),
        OverflowBar(spacing: 4, alignment: MainAxisAlignment.center, children: [
          TextButton.icon(
            icon: Icon(_speaking
                ? Icons.stop_circle_outlined
                : Icons.volume_up_outlined),
            label: Text(_speaking ? 'Stop' : 'Listen 🔊'),
            onPressed: _listen,
          ),
          TextButton.icon(
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
            label: Text(bookmarked ? 'Saved 🔖' : 'Save 🔖'),
            onPressed: () => state.toggleBookmark(key),
          ),
        ]),
      ],
    );
  }
}
