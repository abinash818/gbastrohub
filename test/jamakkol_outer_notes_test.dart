import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  group('Jamakkol Outer Planets Notes 15 & 16 Tests', () {
    test('Verify Note 15 (Ucham / Neecham) with Sun exalted and Jupiter debilitated', () {
      // Sun at 10 deg (Aries - Exalted)
      // Jupiter at 280 deg (Capricorn - Debilitated)
      // Mars at 45 deg (Taurus - Neutral)
      final planetDegrees = {
        'Sun': 10.0,
        'Jupiter': 280.0,
        'Mars': 45.0,
        'Moon': 120.0,
        'Mercury': 60.0,
        'Venus': 30.0,
        'Saturn': 140.0,
        'Rahu': 310.0,
      };

      final results = {
        'udayam_idx': 0,
        'arudam_idx': 0,
        'kavi_idx': 0,
        'outer': {
          'planet_degrees': planetDegrees,
          'udayam_abs_deg': 10.0,
          'arudam_abs_deg': 10.0,
        },
      };

      final notes = JamakkolService.calculateNotes(results, langCode: 'ta');
      final ucham = notes['ucham_planets'] as List<String>;
      final neecham = notes['neecham_planets'] as List<String>;

      expect(ucham, contains('Sun'));
      expect(neecham, contains('Jupiter'));

      // In Tamil
      String uchamTamil = ucham.map((p) => KPService.TAMIL_PLANETS[p] ?? p).join(", ");
      String neechamTamil = neecham.map((p) => KPService.TAMIL_PLANETS[p] ?? p).join(", ");
      expect(uchamTamil, 'சூரியன்');
      expect(neechamTamil, 'குரு');

      String row15Display = "உச்சம் _ $uchamTamil\nநீச்சம் _ $neechamTamil";
      expect(row15Display, "உச்சம் _ சூரியன்\nநீச்சம் _ குரு");
    });

    test('Verify Note 16 (Rasi Parivarthanai) with Mercury in Libra and Venus in Virgo', () {
      // Mercury in Libra (195 deg) - ruled by Venus
      // Venus in Virgo (165 deg) - ruled by Mercury
      final planetDegrees = {
        'Mercury': 195.0, // Libra (index 6)
        'Venus': 165.0,   // Virgo (index 5)
        'Sun': 10.0,
        'Moon': 70.0,
        'Mars': 100.0,
        'Jupiter': 250.0,
        'Saturn': 320.0,
        'Rahu': 350.0,
      };

      final results = {
        'udayam_idx': 0,
        'arudam_idx': 0,
        'kavi_idx': 0,
        'outer': {
          'planet_degrees': planetDegrees,
          'udayam_abs_deg': 10.0,
          'arudam_abs_deg': 10.0,
        },
      };

      final notes = JamakkolService.calculateNotes(results, langCode: 'ta');
      final pDetails = notes['parivarthana_details'] as List<Map<String, String>>;

      expect(pDetails.isNotEmpty, true);
      expect(pDetails.first['sign1'], 'Virgo');
      expect(pDetails.first['sign2'], 'Libra');
      expect(pDetails.first['planet1'], 'Mercury');
      expect(pDetails.first['planet2'], 'Venus');

      // Check formatting in Tamil
      String s1Name = KPService.TAMIL_SIGNS[pDetails.first['sign1']] ?? '';
      String s2Name = KPService.TAMIL_SIGNS[pDetails.first['sign2']] ?? '';
      String p1Name = KPService.TAMIL_PLANETS[pDetails.first['planet1']] ?? '';
      String p2Name = KPService.TAMIL_PLANETS[pDetails.first['planet2']] ?? '';

      String row16Display = "${s1Name}_${s2Name}\n$p1Name $p2Name";
      expect(row16Display, "கன்னி_துலாம்\nபுதன் சுக்கிரன்");
    });
  });
}
