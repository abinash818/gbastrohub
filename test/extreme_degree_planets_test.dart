import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/astro_special_calculations_service.dart';

void main() {
  group('Extreme Degree Planets (அதிக & குறைந்த பாகை பெற்ற கிரகம்) Tests', () {
    test('User Example: Rahu and Ketu tied at 28° - Rahu lord Mercury (22°) > Ketu lord Jupiter (19°)', () {
      // 01-06-1977 Chennai example from user prompt & image:
      // Sun in Taurus (index 1) at 17° -> lon = 30*1 + 17 = 47.0
      // Moon in Scorpio (index 7) at 8° -> lon = 30*7 + 8 = 218.0
      // Mars in Aries (index 0) at 2° -> lon = 30*0 + 2 = 2.0
      // Mercury in Aries (index 0) at 22° -> lon = 30*0 + 22 = 22.0
      // Jupiter in Taurus (index 1) at 19° -> lon = 30*1 + 19 = 49.0
      // Venus in Aries (index 0) at 2.5° -> lon = 30*0 + 2.5 = 2.5
      // Saturn in Cancer (index 3) at 18° -> lon = 30*3 + 18 = 108.0
      // Rahu in Virgo (index 5) at 28.0° -> lon = 30*5 + 28 = 178.0
      // Ketu in Pisces (index 11) at 28.0° -> lon = 30*11 + 28 = 358.0

      final planetLons = {
        'Sun': 47.0,
        'Moon': 218.0,
        'Mars': 2.0,
        'Mercury': 22.0,
        'Jupiter': 49.0,
        'Venus': 2.5,
        'Saturn': 108.0,
        'Rahu': 178.0,
        'Ketu': 358.0,
      };

      final result = AstroSpecialCalculationsService.calculateExtremeDegreePlanets(planetLons);

      // Highest should be Rahu (because Rahu lord Mercury 22° > Ketu lord Jupiter 19°)
      final highest = result['highest'];
      expect(highest['planet'], 'Rahu');
      expect(highest['planet_tamil'], 'ராகு');
      expect(highest['tie_breaker'], true);
      expect(result['highest_display'], contains('ராகு'));
      expect(result['highest_display'], contains('புதன்'));

      // Lowest should be Mars (2.0° in Aries)
      final lowest = result['lowest'];
      expect(lowest['planet'], 'Mars');
      expect(lowest['planet_tamil'], 'செவ்வாய்');
      expect(result['lowest_display'], contains('செவ்வாய்'));
    });

    test('Regular Highest: Jupiter at 29.59° is highest', () {
      final planetLons = {
        'Sun': 15.0,
        'Moon': 10.0,
        'Mars': 5.0,
        'Mercury': 8.0,
        'Jupiter': 30 * 8 + 29.59, // 29.59° in Dhanusu
        'Venus': 1.0,
        'Saturn': 12.0,
        'Rahu': 30 * 1 + 25.0,
        'Ketu': 30 * 7 + 25.0,
      };

      final result = AstroSpecialCalculationsService.calculateExtremeDegreePlanets(planetLons);
      final highest = result['highest'];
      expect(highest['planet'], 'Jupiter');
      expect(highest['planet_tamil'], 'குரு');
      expect(highest['tie_breaker'], false);

      final lowest = result['lowest'];
      expect(lowest['planet'], 'Venus');
      expect(lowest['planet_tamil'], 'சுக்கிரன்');
    });

    test('Rahu and Ketu tied at lowest degree (1.5°) - Ketu lord lower resolves to Ketu', () {
      // Rahu in Leo (index 4, lord Sun at 20°) at 1.5°
      // Ketu in Aquarius (index 10, lord Saturn at 5°) at 1.5°
      // Others all > 1.5°
      final planetLons = {
        'Sun': 30 * 4 + 20.0,     // 20°
        'Moon': 30 * 2 + 10.0,    // 10°
        'Mars': 30 * 0 + 15.0,    // 15°
        'Mercury': 30 * 1 + 18.0, // 18°
        'Jupiter': 30 * 8 + 22.0, // 22°
        'Venus': 30 * 3 + 12.0,   // 12°
        'Saturn': 30 * 9 + 5.0,   // 5° (Saturn is Ketu's sign lord)
        'Rahu': 30 * 4 + 1.5,     // 1.5°
        'Ketu': 30 * 10 + 1.5,    // 1.5°
      };

      final result = AstroSpecialCalculationsService.calculateExtremeDegreePlanets(planetLons);

      // Lowest should be Ketu because Saturn (5°) < Sun (20°)
      final lowest = result['lowest'];
      expect(lowest['planet'], 'Ketu');
      expect(lowest['planet_tamil'], 'கேது');
      expect(lowest['tie_breaker'], true);
      expect(result['lowest_display'], contains('கேது'));
      expect(result['lowest_display'], contains('சனி'));
    });
  });

  group('Aagami Grahas (ஆகமி கிரகம்) Tests', () {
    test('Aagami Grahas calculation: 01-06-1977 Chennai example', () {
      final planetLons = {
        'Sun': 47.0,     // Rohini (Moon)
        'Moon': 218.0,   // Anuradha (Saturn)
        'Mars': 2.0,     // Ashwini (Ketu)
        'Mercury': 22.0, // Bharani (Venus)
        'Jupiter': 49.0, // Rohini (Moon)
        'Venus': 2.5,    // Ashwini (Ketu)
        'Saturn': 108.0, // Ashlesha (Mercury)
        'Rahu': 178.0,   // Chitra (Mars)
        'Ketu': 358.0,   // Revati (Mercury)
      };

      final aagami = AstroSpecialCalculationsService.calculateAagamiPlanets(planetLons);

      // In this chart:
      // Star lords occupied: Moon, Saturn, Ketu, Venus, Mercury, Mars.
      // Unoccupied star lords: Sun, Jupiter, Rahu.
      expect(aagami['aagami_planets'], contains('Sun'));
      expect(aagami['aagami_planets'], contains('Jupiter'));
      expect(aagami['aagami_planets'], contains('Rahu'));

      // Star lords that ARE occupied should NOT be Aagami
      expect(aagami['aagami_planets'], isNot(contains('Moon')));
      expect(aagami['aagami_planets'], isNot(contains('Mercury')));
      expect(aagami['aagami_planets'], isNot(contains('Ketu')));

      // Display text in Tamil
      expect(aagami['display_text'], contains('சூரியன்'));
      expect(aagami['display_text'], contains('குரு'));
      expect(aagami['display_text'], contains('ராகு'));
    });
  });
}
