import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../services/gemini_service.dart';

class QuizScreen extends StatefulWidget {
  final Subject subject;
  const QuizScreen({super.key, required this.subject});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<MCQ> _questions = List.of(widget.subject.mcqs);
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _generating = false;
  String? _error;

  MCQ get _current => _questions[_index];
  bool get _answered => _selected != null;
  bool get _finished => _index >= _questions.length;

  void _answer(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      if (i == _current.answer) _score++;
    });
    if (_index == _questions.length - 1) {
      context
          .read<AppState>()
          .saveBestScore('${widget.subject.id}_quiz', _score, _questions.length);
    }
  }

  void _next() => setState(() {
        _index++;
        _selected = null;
      });

  void _restart() => setState(() {
        _index = 0;
        _score = 0;
        _selected = null;
      });

  Future<void> _generateAiQuestions() async {
    final state = context.read<AppState>();
    if (!state.hasKey) {
      setState(() =>
          _error = 'Add your free Gemini key in Settings to generate questions.');
      return;
    }
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final text = await GeminiService().generate(
        apiKey: state.geminiKey,
        temperature: 0.7,
        system:
            'You are a Telangana Intermediate board exam question setter. Reply with ONLY valid JSON.',
        prompt: 'Create 5 multiple-choice questions for the Telangana Intermediate '
            '${widget.subject.name} subject (board exam level). '
            'Return ONLY a JSON array of 5 objects, each: '
            '{"q": "question", "options": ["A","B","C","D"], "answer": 0, "explanation": "one line"}. '
            '"answer" is the 0-based index of the correct option. No markdown, no prose.',
      );
      final start = text.indexOf('[');
      final end = text.lastIndexOf(']');
      if (start < 0 || end <= start) throw 'AI did not return questions.';
      final list = jsonDecode(text.substring(start, end + 1)) as List;
      final newMcqs = <MCQ>[];
      for (final item in list) {
        if (item is! Map) continue;
        final opts = (item['options'] as List?)?.map((e) => '$e').toList();
        final ans = item['answer'];
        if (item['q'] == null || opts == null || opts.length < 2 || ans is! int) {
          continue;
        }
        newMcqs.add(MCQ('${item['q']}', opts, ans.clamp(0, opts.length - 1),
            '${item['explanation'] ?? ''}'));
      }
      if (newMcqs.isEmpty) throw 'Could not parse AI questions.';
      setState(() {
        _questions.addAll(newMcqs);
        _error = '✨ Added ${newMcqs.length} AI questions to this quiz!';
      });
    } catch (e) {
      setState(() => _error = 'AI generation failed: $e');
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult();
    final q = _current;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject.emoji} Quiz'),
        actions: [
          if (context.watch<AppState>().hasKey)
            IconButton(
              tooltip: 'Generate 5 AI questions',
              onPressed: _generating ? null : _generateAiQuestions,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(
              value: (_index + 1) / _questions.length),
          const SizedBox(height: 8),
          Text('Question ${_index + 1} of ${_questions.length}   •   Score: $_score',
              style: Theme.of(context).textTheme.bodySmall),
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(q.q,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < q.options.length; i++) _optionTile(q, i),
          if (_answered) ...[
            const SizedBox(height: 10),
            Card(
              color: _selected == q.answer
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Icon(
                      _selected == q.answer
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      color: _selected == q.answer
                          ? Colors.green
                          : Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Expanded(child: Text(q.explanation)),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _next,
              icon: Icon(_index == _questions.length - 1
                  ? Icons.flag_outlined
                  : Icons.arrow_forward),
              label: Text(
                  _index == _questions.length - 1 ? 'Finish' : 'Next Question'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionTile(MCQ q, int i) {
    Color? bg;
    IconData? icon;
    if (_answered) {
      if (i == q.answer) {
        bg = Colors.green.shade100;
        icon = Icons.check_circle;
      } else if (i == _selected) {
        bg = Colors.red.shade100;
        icon = Icons.cancel;
      }
    }
    return Card(
      color: bg,
      child: ListTile(
        leading: CircleAvatar(
          radius: 14,
          child: Text(String.fromCharCode(65 + i)),
        ),
        title: Text(q.options[i]),
        trailing: icon == null ? null : Icon(icon),
        onTap: () => _answer(i),
      ),
    );
  }

  Widget _buildResult() {
    final total = _questions.length;
    final pct = total == 0 ? 0 : ((_score / total) * 100).round();
    final state = context.watch<AppState>();
    final best = state.bestScores['${widget.subject.id}_quiz'] ?? pct;
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(pct >= 70 ? '🏆' : pct >= 40 ? '👍' : '💪',
                style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text('You scored $_score / $total ($pct%)',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('Your best: $best%',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            FilledButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay),
                label: const Text('Play Again')),
            const SizedBox(height: 10),
            TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Subjects')),
          ]),
        ),
      ),
    );
  }
}
