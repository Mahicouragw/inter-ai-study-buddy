import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';

/// Chapter detail with three tabs: Learn (key points), Questions (2M/10M),
/// and Textbook (official PDF page links).
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
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Learn'),
            Tab(icon: Icon(Icons.help_outline), text: 'Questions'),
            Tab(icon: Icon(Icons.picture_as_pdf_outlined), text: 'Textbook'),
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

class _QuestionsTab extends StatelessWidget {
  final Subject subject;
  const _QuestionsTab({required this.subject});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text('⭐ 2-Mark Questions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        for (final qa in subject.shortAnswers)
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
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text('⭐ 5 / 10-Mark Essay Questions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        for (final qa in subject.essays)
          Card(
            child: ExpansionTile(
              title: Text(qa.q),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(qa.a,
                          style: const TextStyle(height: 1.45))),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PdfTab extends StatelessWidget {
  final Subject subject;
  const _PdfTab({required this.subject});

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
                    child: Text('Official free textbook (Govt. of Telangana)',
                        style: Theme.of(context).textTheme.titleSmall)),
              ]),
              const SizedBox(height: 8),
              Text(subject.pdfLabel),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Textbook PDF'),
                onPressed: () => launchUrl(Uri.parse(subject.pdfUrl),
                    mode: LaunchMode.externalApplication),
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
              onTap: () => launchUrl(Uri.parse(link.url),
                  mode: LaunchMode.externalApplication),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Note: PDFs open from the official Telangana Open School (TOSS) / TSBIE websites, which publish Intermediate textbooks free for students. They are not re-hosted by this app.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
