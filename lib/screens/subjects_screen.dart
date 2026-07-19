import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/year1_subjects.dart';
import '../data/year2_subjects.dart';
import '../models.dart';
import '../services/app_state.dart';
import 'chapter_screen.dart';

/// Lists all six subjects for the currently selected Inter year.
List<Subject> subjectsForYear(int year) =>
    year == 1 ? year1Subjects : year2Subjects;

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final subjects = subjectsForYear(state.year);
    return Scaffold(
      appBar: AppBar(title: Text('Inter ${state.year == 1 ? "1st" : "2nd"} Year Subjects')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: subjects.length,
        itemBuilder: (context, i) {
          final s = subjects[i];
          return Card(
            child: ListTile(
              leading: Text(s.emoji, style: const TextStyle(fontSize: 30)),
              title: Text(s.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  '${s.chapters.length} units • ${s.shortAnswers.length} short Qs • ${s.mcqs.length} MCQs'),
              trailing: Wrap(spacing: 4, children: [
                IconButton(
                  tooltip: 'Open official textbook PDF',
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: () => launchUrl(Uri.parse(s.pdfUrl),
                      mode: LaunchMode.externalApplication),
                ),
                const Icon(Icons.chevron_right),
              ]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChapterScreen(subject: s)),
              ),
            ),
          );
        },
      ),
    );
  }
}
