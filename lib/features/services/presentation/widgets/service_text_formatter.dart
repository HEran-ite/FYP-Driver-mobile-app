library;

String formatServiceLabel(String raw) {
  final cleaned = raw.trim().replaceAll(RegExp(r'[_-]+'), ' ');
  if (cleaned.isEmpty) return raw;

  final words = cleaned
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .toList();
  return words.join(' ');
}

