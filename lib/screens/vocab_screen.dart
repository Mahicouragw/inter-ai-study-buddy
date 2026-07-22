import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/vocabulary.dart';
import '../models.dart';
import '../services/app_state.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';

/// English vocabulary builder: flashcards + meaning quiz + AI word explorer.
class VocabScreen extends StatefulWidget {
  const VocabScreen({super.key});

  @override
  State<VocabScreen> createState() => _VocabScreenState();
}

class _VocabScreenState extends State<VocabScreen> {
  final _rand = Random();
  int _card = 0;
  bool _flipped = false;

  // quiz state
  VocabWord? _quizWord;
  List<String> _quizOptions = [];
  String? _quizChosen;
  int _quizScore = 0;
  int _quizRound = 0;

  void _nextCard([bool random = false]) => setState(() {
        _card = random
            ? _rand.nextInt(vocabulary.length)
            : (_card + 1) % vocabulary.length;
        _flipped = false;
      });

  void _newQuizRound() {
    final w = vocabulary[_rand.nextInt(vocabulary.length)];
    final others = vocabulary.where((v) => v.word != w.word).toList()..shuffle(_rand);
    setState(() {
      _quizWord = w;
      _quizOptions = ([w.meaning] + others.take(3).map((e) => e.meaning).toList())
        ..shuffle(_rand);
      _quizChosen = null;
    });
  }

  Future<void> _aiWords() async {
    final state = context.read<AppState>();
    if (!state.hasKey) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Add OpenRouter (sk-or-v1-...) or Gemini key for AI.')));
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      var topic = 'useful for Intermediate board exams';
      final last = vocabulary[_rand.nextInt(vocabulary.length)].word;
      final text = await GeminiService().generate(
        apiKey: state.geminiKey,
        system: 'You are an English vocabulary coach for Indian students.',
        prompt: 'Give 5 new advanced English words $topic (do NOT repeat "$last"). '
            'For each: word (part of speech) - simple meaning - Telugu meaning - '
            'one short example sentence. One word per line.',
      );
      if (!mounted) return;
      Navigator.pop(context); // close loader
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('✨ 5 Fresh AI Words'),
          content: SingleChildScrollView(child: SelectableText(text)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Nice!'))
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final learned = state.learnedWords.length;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vocabulary 🔤  ($learned/${vocabulary.length} learned)'),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.style_outlined), text: 'Flashcards'),
            Tab(icon: Icon(Icons.quiz_outlined), text: 'Meaning Quiz'),
          ]),
          actions: [
            IconButton(
                tooltip: 'Speak word',
                icon: const Icon(Icons.volume_up_outlined),
                onPressed: () => context
                    .read<SpeechService>()
                    .speak(vocabulary[_card].word)),
            if (state.hasKey)
              IconButton(
                  tooltip: 'Generate 5 AI words',
                  icon: const Icon(Icons.auto_awesome),
                  onPressed: _aiWords),
          ],
        ),
        body: TabBarView(children: [
          _buildFlashcards(state),
          _buildQuiz(),
        ]),
      ),
    );
  }

  Widget _buildFlashcards(AppState state) {
    final w = vocabulary[_card];
    final learned = state.learnedWords.contains(w.word);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text('Card ${_card + 1} of ${vocabulary.length}',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _flipped = !_flipped),
            child: Card(
              color: _flipped
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _flipped
                      ? Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(w.meaning,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(w.telugu,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Text('💬 ${w.example}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ])
                      : Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(w.word,
                              style: Theme.of(context).textTheme.displaySmall),
                          const SizedBox(height: 6),
                          Chip(label: Text(w.pos)),
                          const SizedBox(height: 10),
                          Text('tap to flip 🔄',
                              style: Theme.of(context).textTheme.bodySmall),
                        ]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FilledButton.tonalIcon(
            onPressed: () {
              state.toggleLearned(w.word);
              _nextCard();
            },
            icon: Icon(learned ? Icons.check_circle : Icons.check),
            label: Text(learned ? 'Learned ✔' : 'I know this'),
          ),
          FilledButton.tonalIcon(
            onPressed: _nextCard,
            icon: const Icon(Icons.skip_next),
            label: const Text('Next'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => _nextCard(true),
            icon: const Icon(Icons.shuffle),
            label: const Text('Shuffle'),
          ),
        ]),
      ]),
    );
  }

  Widget _buildQuiz() {
    if (_quizWord == null) {
      return Center(
        child: FilledButton.icon(
          onPressed: _newQuizRound,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Meaning Quiz'),
        ),
      );
    }
    final w = _quizWord!;
    final answered = _quizChosen != null;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Round ${_quizRound + 1}  •  Score: $_quizScore',
          style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 10),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Text(w.word, style: Theme.of(context).textTheme.headlineMedium),
            Text('(${w.pos})  •  ${w.telugu}',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
      Text('Pick the correct meaning:',
          style: Theme.of(context).textTheme.titleSmall),
      for (final opt in _quizOptions)
        Card(
          color: answered
              ? opt == w.meaning
                  ? Colors.green.shade100
                  : opt == _quizChosen
                      ? Colors.red.shade100
                      : null
              : null,
          child: ListTile(
            title: Text(opt),
            onTap: answered
                ? null
                : () => setState(() {
                      _quizChosen = opt;
                      if (opt == w.meaning) _quizScore++;
                    }),
          ),
        ),
      if (answered)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: FilledButton.icon(
            onPressed: () {
              setState(() => _quizRound++);
              _newQuizRound();
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next Round'),
          ),
        ),
    ]);
  }
}
