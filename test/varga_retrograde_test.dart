import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  test('Verify retrograde planets have (வ) in Varga charts, excluding Rahu and Ketu', () {
    // Mock planet longitudes
    final Map<String, double> planetLons = {
      'Sun': 180.0,
      'Moon': 210.0,
      'Mars': 45.0,
      'Mercury': 195.0,
      'Jupiter': 75.0,
      'Venus': 120.0,
      'Saturn': 345.0,
      'Rahu': 315.0,
      'Ketu': 135.0,
    };
    final double lagnaLon = 15.0;

    // Saturn and Venus are retrograde. Rahu and Ketu are also marked isRetro: true by astronomy.
    final Map<String, dynamic> planetInfo = {
      'Sun': {'isRetro': false},
      'Moon': {'isRetro': false},
      'Mars': {'isRetro': false},
      'Mercury': {'isRetro': false},
      'Jupiter': {'isRetro': false},
      'Venus': {'isRetro': true},
      'Saturn': {'isRetro': true},
      'Rahu': {'isRetro': true},
      'Ketu': {'isRetro': true},
    };

    final vargas = KPService.calculateAllVargasForTest(planetLons, lagnaLon, planetInfo);

    // Check in Rasi (D1)
    final d1 = vargas['ராசி\n(D1)'] as Map<String, List<String>>;
    final allD1Planets = d1.values.expand((list) => list).toList();

    // Saturn and Venus must have (வ)
    expect(allD1Planets.contains('சனி (வ)'), isTrue, reason: 'Saturn should have (வ)');
    expect(allD1Planets.contains('சுக் (வ)'), isTrue, reason: 'Venus should have (வ)');

    // Rahu and Ketu must NOT have (வ)
    expect(allD1Planets.contains('ராகு'), isTrue, reason: 'Rahu should not have (வ)');
    expect(allD1Planets.contains('ராகு (வ)'), isFalse, reason: 'Rahu should not have (வ)');
    expect(allD1Planets.contains('கேது'), isTrue, reason: 'Ketu should not have (வ)');
    expect(allD1Planets.contains('கேது (வ)'), isFalse, reason: 'Ketu should not have (வ)');

    // Direct planets like Sun, Moon, Mars must NOT have (வ)
    expect(allD1Planets.contains('சூரி'), isTrue);
    expect(allD1Planets.contains('சூரி (வ)'), isFalse);
    expect(allD1Planets.contains('சந்'), isTrue);
    expect(allD1Planets.contains('செவ்'), isTrue);

    // Check in Hora (D2)
    final d2 = vargas['ஹோரை\n(D2)'] as Map<String, List<String>>;
    final allD2Planets = d2.values.expand((list) => list).toList();
    expect(allD2Planets.contains('சனி (வ)'), isTrue);
    expect(allD2Planets.contains('சுக் (வ)'), isTrue);
    expect(allD2Planets.contains('ராகு'), isTrue);
    expect(allD2Planets.contains('கேது'), isTrue);
  });
}
