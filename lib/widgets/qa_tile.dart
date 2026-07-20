import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../services/speech_service.dart';
import '../utils/study_utils.dart';

/// Shared TalkBack-friendly question card used by the Questions tab,
/// Search results and the Bookmarks screen.
///
/// Tap to expand the answer. Inside: 🔊 Listen, 🔖 Save, ✅ Mark learned.
class QaTile extends StatefulWidget {
  final Subject subject;
  final String kind; // 'S' short answer, 'E' essay
  final int index;
  final QA qa;
  final bool isPriority;
  final String? subtitleLabel;

  const QaTile({
    super.key,
    required this.subject,
    required this.kind,
    required this.index,
    required this.qa,
    this.isPriority = false,
    this.subtitleLabel,
  });

  @override
  State<QaTile> createState() => _QaTileState();
}

class _QaTileState extends State<QaTile> {
  bool _speaking = false;

  String get _key => qaKey(widget.subject.id, widget.kind, widget.index);

  @override
  void dispose() {
    if (_speaking) {
      context.read<SpeechService>().stopSpeaking();
    }
    super.dispose();
  }

  Future<void> _toggleSpeak() async {
    final speech = context.read<SpeechService>();
    if (_speaking) {
      await speech.stopSpeaking();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    await speech.speak('Question. ${widget.qa.q}. Answer. ${widget.qa.a}');
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bookmarked = state.isBookmarked(_key);
    final learned = state.isLearnedQa(_key);
    final flags = <String>[
      if (widget.isPriority) '⭐ Priority',
      if (bookmarked) '🔖 Saved',
      if (learned) '✅ Learned',
    ];
    final subtitleParts = <String>[
      if (widget.subtitleLabel != null) widget.subtitleLabel!,
      if (flags.isNotEmpty) flags.join('  •  '),
    ];
    return Card(
      child: ExpansionTile(
        title: Text(widget.qa.q),
        subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join('\n')),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.qa.a, style: const TextStyle(height: 1.45)),
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.start,
            spacing: 4,
            children: [
              TextButton.icon(
                icon: Icon(_speaking
                    ? Icons.stop_circle_outlined
                    : Icons.volume_up_outlined),
                label: Text(_speaking ? 'Stop' : 'Listen'),
                onPressed: _toggleSpeak,
              ),
              TextButton.icon(
                icon: Icon(
                    bookmarked ? Icons.bookmark : Icons.bookmark_border),
                label: Text(bookmarked ? 'Saved' : 'Save'),
                onPressed: () => state.toggleBookmark(_key),
              ),
              TextButton.icon(
                icon: Icon(learned
                    ? Icons.check_circle
                    : Icons.check_circle_outline),
                label: Text(learned ? 'Learned ✓' : 'Mark learned'),
                onPressed: () => state.toggleLearnedQa(_key),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
