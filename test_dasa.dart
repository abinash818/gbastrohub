import 'dart:io';

void main() {
  String text = "கேது";
  Map<String, String> tMap = {
    "ராகு": "Rahu",
    "கேது": "Ketu",
    "செவ்வாய்": "Mars",
    "புதன்": "Mercury",
    "குரு": "Jupiter",
    "சுக்கிரன்": "Venus",
    "சனி": "Saturn",
    "சூரியன்": "Sun",
    "சந்திரன்": "Moon"
  };
  
  var sortedKeys = tMap.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
  
  String translated = text;
  for (var ta in sortedKeys) {
    translated = translated.replaceAll(ta, tMap[ta]!);
  }
  
  print("Original: $text");
  print("Translated: $translated");
}
