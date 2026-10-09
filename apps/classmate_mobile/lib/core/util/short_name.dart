/// First name for tight spots (group previews, chips), WhatsApp-style. A
/// leading title keeps the word after it, so a teacher reads "Ms. Golan", not
/// "Ms.".
String shortName(String fullName) {
  final words = fullName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  if (words.length > 1 && words.first.endsWith('.')) return '${words[0]} ${words[1]}';
  return words.first;
}
