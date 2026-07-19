// Core data models for the Inter AI Study Buddy app.

/// A short question-answer pair (2-mark / 5-mark style).
class QA {
  final String q;
  final String a;
  const QA(this.q, this.a);
}

/// A multiple-choice question with an explanation.
class MCQ {
  final String q;
  final List<String> options;
  final int answer; // index into options
  final String explanation;
  const MCQ(this.q, this.options, this.answer, this.explanation);
}

/// A chapter/lesson with quick revision key points.
class Chapter {
  final String title;
  final List<String> keyPoints;
  const Chapter(this.title, this.keyPoints);
}

/// A named external link (official textbook pages, model papers, etc.).
class NamedLink {
  final String label;
  final String url;
  const NamedLink(this.label, this.url);
}

/// A full subject for a given Intermediate year.
class Subject {
  final String id;
  final String name;
  final String emoji;
  final int year; // 1 or 2
  final List<Chapter> chapters;
  final String pdfUrl;
  final String pdfLabel;
  final List<NamedLink> extraLinks;
  final List<QA> shortAnswers; // 2-mark Q&A
  final List<QA> essays; // 5/10-mark Q&A
  final List<MCQ> mcqs;

  const Subject({
    required this.id,
    required this.name,
    required this.emoji,
    required this.year,
    required this.chapters,
    required this.pdfUrl,
    required this.pdfLabel,
    this.extraLinks = const [],
    this.shortAnswers = const [],
    this.essays = const [],
    this.mcqs = const [],
  });
}

/// An English vocabulary word with Telugu gloss.
class VocabWord {
  final String word;
  final String pos; // part of speech
  final String meaning;
  final String telugu;
  final String example;
  const VocabWord(this.word, this.pos, this.meaning, this.telugu, this.example);
}
