/// Converts Western Arabic numerals (1, 2, 3) to Eastern Arabic numerals (١, ٢, ٣).
String convertToEasternArabicNumerals(String input) {
  const western = <String>['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = <String>['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  String result = input; // Work on a mutable copy
  for (int i = 0; i < western.length; i++) {
    result = result.replaceAll(western[i], eastern[i]);
  }
  return result;
}
