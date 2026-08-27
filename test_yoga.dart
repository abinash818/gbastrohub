void main() {
  const List<String> NAKSHATRAS = [
    "அசுவனி", "பரணி", "கிருத்திகை", "ரோகிணி", "மிருகசீர்ஷம்", "திருவாதிரை",
    "புனர்பூசம்", "பூசம்", "ஆயில்யம்", "மகம்", "பூரம்", "உத்திரம்",
    "அஸ்தம்", "சித்திரை", "சுவாதி", "விசாகம்", "அனுஷம்", "கேட்டை",
    "மூலம்", "பூராடம்", "உத்திராடம்", "திருவோணம்", "அவிட்டம்", "சதயம்",
    "பூரட்டாதி", "உத்திரட்டாதி", "ரேவதி"
  ];

  String _getAmirthaYoga(int weekday, String nakshatra) {
    const List<List<String>> table = [
      // Sun (0)
      ["S", "P", "S", "S", "S", "S", "S", "S", "S", "M", "S", "A", "A", "S", "S", "M", "M", "M", "S", "S", "A", "A", "S", "S", "S", "A", "A"],
      // Mon (1)
      ["S", "S", "M", "A", "A", "S", "S", "S", "S", "M", "S", "S", "S", "P", "A", "M", "S", "S", "S", "S", "M", "A", "S", "S", "M", "S", "A"],
      // Tue (2)
      ["S", "S", "S", "A", "S", "M", "A", "S", "S", "S", "S", "A", "S", "S", "S", "M", "S", "S", "A", "S", "P", "A", "A", "M", "M", "S", "S"],
      // Wed (3)
      ["S", "S", "A", "S", "S", "S", "S", "S", "S", "S", "A", "S", "A", "S", "A", "S", "S", "S", "M", "S", "A", "S", "P", "M", "A", "S", "M"],
      // Thu (4)
      ["M", "S", "S", "S", "S", "M", "A", "A", "S", "A", "S", "M", "S", "S", "A", "S", "S", "M", "S", "A", "S", "S", "S", "P", "S", "S", "S"],
      // Fri (5)
      ["M", "S", "S", "M", "M", "S", "S", "M", "M", "M", "S", "S", "A", "S", "S", "S", "S", "S", "A", "S", "S", "M", "S", "M", "P", "S", "A"],
      // Sat (6)
      ["S", "S", "A", "A", "S", "S", "S", "S", "M", "A", "S", "M", "M", "M", "A", "S", "S", "S", "S", "S", "S", "S", "S", "A", "M", "S", "P"]
    ];

    int nakIdx = NAKSHATRAS.indexOf(nakshatra);
    if (nakIdx == -1) return "சித்த யோகம்";
    
    String code = table[weekday % 7][nakIdx];
    print("Weekday: $weekday (mod 7: ${weekday % 7}), Nakshatra: $nakshatra (idx: $nakIdx) -> Code: $code");
    switch (code) {
      case "A": return "அமிர்த யோகம்";
      case "S": return "சித்த யோகம்";
      case "M": return "மரண யோகம்";
      case "P": return "பிரபலாரிஷ்ட யோகம்";
      default: return "சித்த யோகம்";
    }
  }

  print("Result for Saturday (6), Avittam: " + _getAmirthaYoga(6, "அவிட்டம்"));
  print("Result for Sunday (7), Avittam: " + _getAmirthaYoga(7, "அவிட்டம்"));
  
  // Is it possible weekday in Dart evaluates differently?
  var dt = DateTime(2026, 7, 4);
  print("Dart DateTime(2026, 7, 4).weekday: ${dt.weekday}");
  print("Result using dt.weekday: " + _getAmirthaYoga(dt.weekday, "அவிட்டம்"));
}
