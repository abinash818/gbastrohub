class MatchingResult {
  final String name;
  final String result; // உத்தமம், மத்திமம், அதமம்
  final String detail; // Additional info
  final double points; // 0.0, 0.5, 1.0

  final String girlValue;
  final String boyValue;

  MatchingResult({
    required this.name,
    required this.result,
    required this.detail,
    required this.points,
    this.girlValue = "",
    this.boyValue = "",
  });

  @override
  String toString() {
    return "$name: $result ($detail)";
  }
}
