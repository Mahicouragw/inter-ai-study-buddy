import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import 'settings_screen.dart';
import 'subjects_screen.dart';

/// Generates Telangana-board style model answers for 2, 5 or 10 marks.
/// Works offline by fuzzy-matching the built-in question bank, or live via
/// Gemini when a key is configured.
class ExamAnswerScreen extends StatefulWidget {
  const ExamAnswerScreen({super.key});

  @override
  State<ExamAnswerScreen> createState() => _ExamAnswerScreenState();
}

class _ExamAnswerScreenState extends State<ExamAnswerScreen> {
  final _controller = TextEditingController();
  Subject? _subject;
  int _marks = 5;
  bool _busy = false;
  bool _micOn = false;
  String _result = '';
  List<QA> _offlineMatches = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final q = _controller.text.trim();
    if (q.isEmpty || _busy) return;
    if (_subject == null) {
      setState(() => _result = '⚠️ Please select a subject first.');
      return;
    }
    final state = context.read<AppState>();
    setState(() {
      _busy = true;
      _result = '';
      _offlineMatches = [];
    });

    if (state.hasKey) {
      try {
        final marksRule = _marks == 2
            ? 'Write exactly 4-5 crisp lines: a definition plus 2-3 key points.'
            : _marks == 5
                ? 'Write: a 1-line introduction, 5 numbered points (one line each), and a 1-line conclusion.'
                : 'Write a structured long answer: an introduction paragraph, 6-8 headed points each with a brief 2-line explanation, and a short conclusion. Mention a diagram/table if relevant.';
        final reply = await GeminiService().generate(
          apiKey: state.geminiKey,
          system:
              'You are an expert Telangana State Board (TSBIE) Intermediate '
              'examiner. Write board-exam model answers in simple, correct '
              'student English. Use headings and numbered points. No fluff.',
          prompt: 'Subject: ${_subject!.name} (Intermediate '
              '${_subject!.year == 1 ? "1st" : "2nd"} year).\n'
              'Marks: $_marks\n'
              'Question: "$q"\n\n$marksRule',
        );
        setState(() => _result = reply);
      } catch (e) {
        setState(() => _result = '⚠️ $e');
      } finally {
        setState(() => _busy = false);
      }
      return;
    }

    // ---- Offline fuzzy-match fallback ----
    final words = q
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .toSet();
    final bank = <QA>[..._subject!.shortAnswers, ..._subject!.essays];
    final scored = <MapEntry<QA, int>>[];
    for (final qa in bank) {
      final hay = qa.q.toLowerCase();
      var hits = 0;
      for (final w in words) {
        if (hay.contains(w)) hits++;
      }
      if (hits > 0) scored.add(MapEntry(qa, hits));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    setState(() {
      _offlineMatches = scored.take(3).map((e) => e.key).toList();
      _busy = false;
      if (_offlineMatches.isEmpty) {
        _result = 'No close offline match in this subject\'s question bank. '
            'Add a free Gemini key in Settings to generate any answer live!';
      }
    });
  }

  Future<void> _toggleMic() async {
    final speech = context.read<SpeechService>();
    if (_micOn) {
      await speech.stopListening();
      setState(() => _micOn = false);
      return;
    }
    final ok = await speech
        .listen((s) => setState(() => _controller.text = s));
    setState(() => _micOn = ok);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final subjects = subjectsForYear(state.year);
    // If the year changed, make sure the selected subject still exists in the list.
    if (_subject != null && !subjects.contains(_subject)) _subject = null;
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Answer Writer ✍️')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<Subject>(
            value: _subject,
            decoration: const InputDecoration(
                labelText: 'Subject', prefixIcon: Icon(Icons.book_outlined)),
            items: [
              for (final s in subjects)
                DropdownMenuItem(value: s, child: Text('${s.emoji} ${s.name}')),
            ],
            onChanged: (s) => setState(() => _subject = s),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Marks:  '),
            for (final m in const [2, 5, 10]) ...[
              ChoiceChip(
                label: Text('$m marks'),
                selected: _marks == m,
                onSelected: (_) => setState(() => _marks = m),
              ),
              const SizedBox(width: 8),
            ],
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            IconButton(
              tooltip: 'Speak the question',
              icon: Icon(_micOn ? Icons.mic : Icons.mic_none),
              onPressed: _toggleMic,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'e.g. Explain the law of demand with exceptions',
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_busy
                ? 'Writing model answer…'
                : state.hasKey
                    ? 'Generate with AI'
                    : 'Search Offline Bank'),
          ),
          if (!state.hasKey)
            TextButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
              icon: const Icon(Icons.key_outlined, size: 18),
              label: const Text(
                  'Add free Gemini key for unlimited AI answers'),
            ),
          const SizedBox(height: 12),
          if (_offlineMatches.isNotEmpty) ...[
            Text('Closest offline answers:',
                style: Theme.of(context).textTheme.titleSmall),
            for (final qa in _offlineMatches)
              Card(
                child: ExpansionTile(
                  title: Text(qa.q),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Align(
                          alignment: Alignment.centerLeft, child: Text(qa.a)),
                    ),
                  ],
                ),
              ),
          ],
          if (_result.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model Answer ($_marks marks)',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const Divider(),
                      SelectableText(_result,
                          style: const TextStyle(height: 1.45)),
                    ]),
              ),
            ),
        ],
      ),
    );
  }
}
