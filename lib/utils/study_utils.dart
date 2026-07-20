// Small pure helpers used across the study screens.

/// Compact, unique identity for one question inside one subject.
/// Format: `subjectId:kind:index` where kind is `S` (short) or `E` (essay).
String qaKey(String subjectId, String kind, int index) =>
    '$subjectId:$kind:$index';

/// Parsed form of a [qaKey].
class QaRef {
  final String subjectId;
  final String kind; // 'S' short answer, 'E' essay
  final int index;
  const QaRef(this.subjectId, this.kind, this.index);
}

QaRef? parseQaKey(String key) {
  final parts = key.split(':');
  if (parts.length != 3) return null;
  final i = int.tryParse(parts[2]);
  if (i == null) return null;
  return QaRef(parts[0], parts[1], i);
}

/// Picks up to [maxCount] indices spread evenly across a list of [length]
/// items — used for the "Priority set" so every chapter is represented.
List<int> spreadIndices(int length, int maxCount) {
  if (length <= 0 || maxCount <= 0) return const [];
  if (length <= maxCount) return List<int>.generate(length, (i) => i);
  final out = <int>{};
  for (var i = 0; i < maxCount; i++) {
    out.add(((i * (length - 1)) / (maxCount - 1)).round());
  }
  final list = out.toList()..sort();
  return list;
}

/// True when [key] is a qaKey that belongs to [subjectId].
bool keyBelongsTo(String key, String subjectId) =>
    key.startsWith('$subjectId:');
