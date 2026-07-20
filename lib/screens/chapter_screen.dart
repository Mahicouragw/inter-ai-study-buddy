import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';
import '../services/app_state.dart';
import '../utils/study_utils.dart';
import '../widgets/qa_tile.dart';
import 'flashcards_screen.dart';

/// Chapter detail with three tabs: Learn (key points), Questions (2M/10M),
/// and Official PDFs (TSBIE model papers & study material).
class ChapterScreen extends StatelessWidget {
  final Subject subject;
  const ChapterScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${subject.emoji} ${subject.name}'),
          actions: [
            IconButton(
              tooltip: 'Revise with flashcards',
              icon: const Icon(Icons.style_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => FlashcardsScreen(subject: subject)),
              ),
            ),
          ],
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Learn'),
            Tab(icon: Icon(Icons.help_outline), text: 'Questions'),
            Tab(icon: Icon(Icons.picture_as_pdf_outlined), text: 'PDFs'),
          ]),
        ),
        body: TabBarView(children: [
          _LearnTab(subject: subject),
          _QuestionsTab(subject: subject),
          _PdfTab(subject: subject),
        ]),
      ),
    );
  }
}

class _LearnTab extends StatelessWidget {
  final Subject subject;
  const _LearnTab({required this.subject});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        for (final ch in subject.chapters)
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(ch.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              children: [
                for (final p in ch.keyPoints)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.fiber_manual_record, size: 12),
                    title: Text(p),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Questions tab with smart filters: All / ⭐ Priority / 🔖 Saved / ❌ Pending.
class _QuestionsTab extends StatefulWidget {
  final Subject subject;
  const _QuestionsTab({required this.subject});

  @override
  State<_QuestionsTab> createState() => _QuestionsTabState();
}

class _QuestionsTabState extends State<_QuestionsTab> {
  static const _filters = ['All', '⭐ Priority', '🔖 Saved', '❌ Pending'];
  String _filter = 'All';

  bool _accept(AppState state, String kind, int index, bool priority) {
    final key = qaKey(widget.subject.id, kind, index);
    switch (_filter) {
      case '⭐ Priority':
        return priority;
      case '🔖 Saved':
        return state.isBookmarked(key);
      case '❌ Pending':
        return !state.isLearnedQa(key);
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = widget.subject;
    final priShort = spreadIndices(s.shortAnswers.length, 8).toSet();
    final priEssay = spreadIndices(s.essays.length, 5).toSet();

    final shortItems = <Widget>[];
    for (var i = 0; i < s.shortAnswers.length; i++) {
      if (_accept(state, 'S', i, priShort.contains(i))) {
        shortItems.add(QaTile(
            subject: s,
            kind: 'S',
            index: i,
            qa: s.shortAnswers[i],
            isPriority: priShort.contains(i)));
      }
    }
    final essayItems = <Widget>[];
    for (var i = 0; i < s.essays.length; i++) {
      if (_accept(state, 'E', i, priEssay.contains(i))) {
        essayItems.add(QaTile(
            subject: s,
            kind: 'E',
            index: i,
            qa: s.essays[i],
            isPriority: priEssay.contains(i)));
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ---- smart filter chips ----
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Row(children: [
            for (final f in _filters)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                ),
              ),
          ]),
        ),
        if (_filter == '⭐ Priority')
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
            child: Text(
              'Priority set = must-do questions spread across every chapter. '
              'Finish these first!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (shortItems.isEmpty && essayItems.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _filter == '🔖 Saved'
                  ? 'No saved questions here yet. Expand any question and tap "Save 🔖".'
                  : _filter == '❌ Pending'
                      ? 'Everything is learned in this subject. Amazing! 🎉'
                      : 'Nothing to show.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        if (shortItems.isNotEmpty) ...[
          _sectionHeader(context, '⭐ 2-Mark Questions (${shortItems.length})'),
          ...shortItems,
        ],
        if (essayItems.isNotEmpty) ...[
          _sectionHeader(
              context, '⭐ 5 / 10-Mark Essay Questions (${essayItems.length})'),
          ...essayItems,
        ],
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

/// Official PDFs — every link opens a document hosted by the Telangana
/// Board of Intermediate Education (TSBIE) itself. No third-party sites.
class _PdfTab extends StatelessWidget {
  final Subject subject;
  const _PdfTab({required this.subject});

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.verified_outlined, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Official TSBIE PDF — free for students',
                        style: Theme.of(context).textTheme.titleSmall)),
              ]),
              const SizedBox(height: 8),
              Text(subject.pdfLabel),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open official PDF'),
                onPressed: () => _open(subject.pdfUrl),
              ),
            ]),
          ),
        ),
        for (final link in subject.extraLinks)
          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: Text(link.label),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => _open(link.url),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'All documents open directly from the Telangana Board of '
          'Intermediate Education (TSBIE) — the official exam board. No '
          'third-party websites. If the board website is under maintenance '
          'and a PDF does not load, try again later or use the model papers '
          'page link above.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
