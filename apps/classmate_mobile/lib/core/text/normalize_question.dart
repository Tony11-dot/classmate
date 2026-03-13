String normalizeQuestionText(String input) {
  var s = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  s = s.replaceAllMapped(RegExp(r'(?<!\n)\n(?!\n)'), (_) => ' ');

  s = s.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
  return s.trim();
}
