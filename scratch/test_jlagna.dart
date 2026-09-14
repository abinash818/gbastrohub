import 'dart:math';

void main() {
  double targetHL = 277.1369; // 9s 07° 08' 13" (Capricorn 07° 08')
  double targetGL = 122.5350; // 4s 02° 32' 06" (Leo 02° 32')

  double elapsedHours = 15.371667; // 15h 22m 18s
  double elapsedGhatis = elapsedHours * 2.5; // 38.4291675

  double sunSunrise = 146.56;   // Sun at sunrise
  double sunBirth = 147.616667; // Sun at birth
  double lagnaBirth = 310.7667; // Lagna at birth

  List<Map<String, dynamic>> bases = [
    {'name': 'SunSunrise', 'val': sunSunrise},
    {'name': 'SunBirth', 'val': sunBirth},
    {'name': 'LagnaBirth', 'val': lagnaBirth},
    {'name': 'Aries0', 'val': 0.0},
  ];

  print("=== SEARCHING HORA LAGNA (Target: $targetHL) ===");
  for (var b in bases) {
    double bVal = b['val']!;
    // Test rates in deg/hour or deg/ghati
    for (double r = 0.5; r <= 360.0; r += 0.5) {
      double resPlus = (bVal + elapsedHours * r) % 360;
      double resMinus = (bVal - elapsedHours * r + 7200) % 360;
      
      if ((resPlus - targetHL).abs() < 1.5) {
        print("PLUS MATCH: Base=${b['name']}, Rate=${r}°/hr => Result=${resPlus.toStringAsFixed(4)} (diff: ${(resPlus-targetHL).toStringAsFixed(4)})");
      }
      if ((resMinus - targetHL).abs() < 1.5) {
        print("MINUS MATCH: Base=${b['name']}, Rate=${r}°/hr => Result=${resMinus.toStringAsFixed(4)} (diff: ${(resMinus-targetHL).toStringAsFixed(4)})");
      }
    }
  }

  print("\n=== SEARCHING GHATIKA LAGNA (Target: $targetGL) ===");
  for (var b in bases) {
    double bVal = b['val']!;
    for (double r = 0.5; r <= 360.0; r += 0.5) {
      double resPlus = (bVal + elapsedHours * r) % 360;
      double resMinus = (bVal - elapsedHours * r + 7200) % 360;
      
      if ((resPlus - targetGL).abs() < 1.5) {
        print("PLUS MATCH: Base=${b['name']}, Rate=${r}°/hr => Result=${resPlus.toStringAsFixed(4)} (diff: ${(resPlus-targetGL).toStringAsFixed(4)})");
      }
      if ((resMinus - targetGL).abs() < 1.5) {
        print("MINUS MATCH: Base=${b['name']}, Rate=${r}°/hr => Result=${resMinus.toStringAsFixed(4)} (diff: ${(resMinus-targetGL).toStringAsFixed(4)})");
      }
    }
  }
}
