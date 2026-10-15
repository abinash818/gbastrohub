import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  group('Jamakkol Kathir (Ray) Calculation Logic Tests', () {
    test('Verify user example in prompt: Udayam in Libra with 8 planets placed', () {
      // Setup the 8 planets in the signs as per user prompt:
      // Pisces(11): Mercury (330-360) -> e.g. 345°
      // Taurus(1): Jupiter (30-60) -> e.g. 45°
      // Gemini(2): Mars (60-90) -> e.g. 75°
      // Leo(4): Sun (120-150) -> e.g. 135°
      // Virgo(5): Rahu (150-180) -> e.g. 165°
      // Scorpio(7): Moon (210-240) -> e.g. 225°
      // Sagittarius(8): Saturn (240-270) -> e.g. 255°
      // Aquarius(10): Venus (300-330) -> e.g. 315°
      final planetDegrees = {
        'Mercury': 345.0, // Pisces
        'Jupiter': 45.0,  // Taurus
        'Mars': 75.0,     // Gemini
        'Sun': 135.0,     // Leo
        'Rahu': 165.0,    // Virgo
        'Moon': 225.0,    // Scorpio
        'Saturn': 255.0,  // Sagittarius
        'Venus': 315.0,   // Aquarius
      };

      final results = {
        'udayam_idx': 6, // Libra (துலாம் - 1-ஆம் பாவம்)
        'arudam_idx': 6,
        'kavi_idx': 6,
        'outer': {
          'planet_degrees': planetDegrees,
          'current_jamam_planet': 'Sun',
        },
      };

      final analysis = JamakkolService.calculateStrengthAnalysis(results, langCode: 'ta');
      final bhavas = analysis['bhavas'] as List<Map<String, dynamic>>;

      expect(bhavas.length, 12);

      // 1-ஆம் பாவம் (துலாம் - உதயம்): துலாம் கதிர் = 2, ஜாமக் கிரகம் இல்லை = 0, மொத்தம் = 2
      final b1 = bhavas[0];
      expect(b1['bhava'], 1);
      expect(b1['sign'], 'Libra');
      expect(b1['rasi'], 2);
      expect(b1['planetKathir'], 0);
      expect(b1['total'], 2);

      // 2-ஆம் பாவம் (விருச்சிகம்): விருச்சிகம் கதிர் = 4, ஜாமக் கிரகம் (சந்திரன் நீசம்) = 0, மொத்தம் = 4
      final b2 = bhavas[1];
      expect(b2['bhava'], 2);
      expect(b2['sign'], 'Scorpio');
      expect(b2['rasi'], 4);
      expect(b2['planetKathir'], 0); // Neecham Moon -> 0
      expect(b2['total'], 4);

      // 3-ஆம் பாவம் (தனுசு): தனுசு கதிர் = 6, ஜாமக் கிரகம் (சனி நட்பு) = 4, மொத்தம் = 10
      final b3 = bhavas[2];
      expect(b3['bhava'], 3);
      expect(b3['sign'], 'Sagittarius');
      expect(b3['rasi'], 6);
      expect(b3['planetKathir'], 4); // Saturn Natpu -> 4*1 = 4
      expect(b3['total'], 10);

      // 4-ஆம் பாவம் (மகரம்): மகரம் கதிர் = 8, கிரகம் இல்லை = 0, மொத்தம் = 8
      final b4 = bhavas[3];
      expect(b4['bhava'], 4);
      expect(b4['sign'], 'Capricorn');
      expect(b4['rasi'], 8);
      expect(b4['planetKathir'], 0);
      expect(b4['total'], 8);

      // 5-ஆம் பாவம் (கும்பம்): கும்பம் கதிர் = 8, ஜாமக் கிரகம் (சுக்கிரன் நட்பு) = 16 (or 20), மொத்தம் = 24 (or 28)
      final b5 = bhavas[4];
      expect(b5['bhava'], 5);
      expect(b5['sign'], 'Aquarius');
      expect(b5['rasi'], 8);
      expect(b5['planetKathir'], 16);
      expect(b5['planetKathirAlt'], 20);
      expect(b5['total'], 24);
      expect(b5['totalAlt'], 28);

      // 6-ஆம் பாவம் (மீனம்): மீனம் கதிர் = 27, ஜாமக் கிரகம் (புதன் நீசம்) = 0, மொத்தம் = 27
      final b6 = bhavas[5];
      expect(b6['bhava'], 6);
      expect(b6['sign'], 'Pisces');
      expect(b6['rasi'], 27);
      expect(b6['planetKathir'], 0); // Mercury Neecham in Pisces -> 0
      expect(b6['total'], 27);

      // 7-ஆம் பாவம் (மேஷம்): மேஷம் கதிர் = 7 (or 8), கிரகம் இல்லை = 0, மொத்தம் = 7 (or 8)
      final b7 = bhavas[6];
      expect(b7['bhava'], 7);
      expect(b7['sign'], 'Aries');
      expect(b7['rasi'], 7);
      expect(b7['rasiAlt'], 8);
      expect(b7['planetKathir'], 0);
      expect(b7['total'], 7);
      expect(b7['totalAlt'], 8);

      // 8-ஆம் பாவம் (ரிஷபம்): ரிஷபம் கதிர் = 8, ஜாமக் கிரகம் (குரு சமம்/நட்பு) = 10, மொத்தம் = 18
      final b8 = bhavas[7];
      expect(b8['bhava'], 8);
      expect(b8['sign'], 'Taurus');
      expect(b8['rasi'], 8);
      expect(b8['planetKathir'], 10);
      expect(b8['total'], 18);

      // 9-ஆம் பாவம் (மிதுனம்): மிதுனம் கதிர் = 5, ஜாமக் கிரகம் (செவ்வாய் பகை/சமம்) = 7 (or 8), மொத்தம் = 12 (or 13)
      final b9 = bhavas[8];
      expect(b9['bhava'], 9);
      expect(b9['sign'], 'Gemini');
      expect(b9['rasi'], 5);
      expect(b9['planetKathir'], 7);
      expect(b9['planetKathirAlt'], 8);
      expect(b9['total'], 12);
      expect(b9['totalAlt'], 13);

      // 10-ஆம் பாவம் (கடகம்): கடகம் கதிர் = 3, கிரகம் இல்லை = 0, மொத்தம் = 3
      final b10 = bhavas[9];
      expect(b10['bhava'], 10);
      expect(b10['sign'], 'Cancer');
      expect(b10['rasi'], 3);
      expect(b10['planetKathir'], 0);
      expect(b10['total'], 3);

      // 11-ஆம் பாவம் (சிம்மம்): சிம்மம் கதிர் = 7 (or 8), ஜாமக் கிரகம் (சூரியன் ஆட்சி) = 10, மொத்தம் = 17 (or 18)
      final b11 = bhavas[10];
      expect(b11['bhava'], 11);
      expect(b11['sign'], 'Leo');
      expect(b11['rasi'], 7);
      expect(b11['rasiAlt'], 8);
      expect(b11['planetKathir'], 10); // Sun Aatchi -> 5*2 = 10
      expect(b11['total'], 17);
      expect(b11['totalAlt'], 18);

      // 12-ஆம் பாவம் (கன்னி): கன்னி கதிர் = 11, ஜாமக் கிரகம் (பாம்பு) = 4, மொத்தம் = 15
      final b12 = bhavas[11];
      expect(b12['bhava'], 12);
      expect(b12['sign'], 'Virgo');
      expect(b12['rasi'], 11);
      expect(b12['planetKathir'], 4); // Rahu is always 4
      expect(b12['total'], 15);

      // Verify rasiKathirMap values
      final map = analysis['rasi_kathir_map'] as Map<String, String>;
      expect(map['Pisces'], '27');
      expect(map['Aries'], contains('7'));
      expect(map['Taurus'], '18');
      expect(map['Gemini'], contains('12'));
      expect(map['Cancer'], '3');
      expect(map['Leo'], contains('17'));
      expect(map['Virgo'], '15');
      expect(map['Libra'], '2');
      expect(map['Scorpio'], '4');
      expect(map['Sagittarius'], '10');
      expect(map['Capricorn'], '8');
      expect(map['Aquarius'], contains('24'));
    });

    test('Verify multiplier rules: Exalted (x3), Own (x2), Debilitated (x0), Rahu (4)', () {
      // Sun: Ucham Aries (x3 -> 15), Aatchi Leo (x2 -> 10), Neecham Libra (x0 -> 0)
      expect(JamakkolService.getPlanetMultiplier('Sun', 'Aries'), 3);
      expect(JamakkolService.getPlanetMultiplier('Sun', 'Leo'), 2);
      expect(JamakkolService.getPlanetMultiplier('Sun', 'Libra'), 0);
      expect(JamakkolService.getPlanetMultiplier('Sun', 'Taurus'), 1);

      // Moon: Ucham Taurus (x3 -> 63), Aatchi Cancer (x2 -> 42), Neecham Scorpio (x0 -> 0)
      expect(JamakkolService.getPlanetMultiplier('Moon', 'Taurus'), 3);
      expect(JamakkolService.getPlanetMultiplier('Moon', 'Cancer'), 2);
      expect(JamakkolService.getPlanetMultiplier('Moon', 'Scorpio'), 0);

      // Mars: Ucham Capricorn (x3 -> 21/24), Aatchi Aries & Scorpio (x2 -> 14/16), Neecham Cancer (x0 -> 0)
      expect(JamakkolService.getPlanetMultiplier('Mars', 'Capricorn'), 3);
      expect(JamakkolService.getPlanetMultiplier('Mars', 'Aries'), 2);
      expect(JamakkolService.getPlanetMultiplier('Mars', 'Scorpio'), 2);
      expect(JamakkolService.getPlanetMultiplier('Mars', 'Cancer'), 0);

      // Rahu: Always 1 multiplier (constant 4)
      expect(JamakkolService.getPlanetMultiplier('Rahu', 'Taurus'), 1);
      expect(JamakkolService.getPlanetMultiplier('Rahu', 'Scorpio'), 1);
    });

    test('Verify Kavippu reverse coverage and Udayam forward contact as per user audio', () {
      // User scenario:
      // Udayam at 23:05 Aquarius (323.0833°)
      // Rahu at 25:56 Aquarius (325.9333°)
      // Kavippu at 18:41 Taurus (48.6833°)
      // Mars at 25:56 Taurus (55.9333°)
      // Sun at 10:56 Aries (10.9333°)
      final planetDegrees = {
        'Sun': 10.9333,
        'Mars': 55.9333,
        'Rahu': 325.9333,
      };

      final results = {
        'udayam_idx': 10, // Aquarius
        'arudam_idx': 10,
        'kavi_idx': 1,    // Taurus
        'outer': {
          'planet_degrees': planetDegrees,
          'udayam_abs_deg': 323.0833,
          'arudam_abs_deg': 311.3,
        },
      };

      final notes = JamakkolService.calculateNotes(results, langCode: 'ta');

      // 1. Udayam contact: Rahu (25:56) is ahead of Udayam (23:05) in Aquarius
      final uContact = notes['udayam_contact'] as List;
      expect(uContact.isNotEmpty, true);
      expect(uContact.first['planet'], 'Rahu');

      // 2. Kavippu covered planet: Kavippu is at 18:41 Taurus. Mars at 25:56 is BEHIND in reverse path.
      // Next planet in reverse (decreasing degrees) is Sun in Aries (10:56)!
      final kaviPlanet = notes['kavi_planet_details'] as Map;
      expect(kaviPlanet['planet'], 'Sun');

      // 3. If Rahu was at 20:00 Aquarius (< 23:05), Udayam already passed Rahu, next forward is Sun in Aries
      final planetDegrees2 = {
        'Sun': 10.9333,
        'Mars': 55.9333,
        'Rahu': 320.0, // 20:00 Aquarius
      };
      final results2 = {
        'udayam_idx': 10,
        'arudam_idx': 10,
        'kavi_idx': 1,
        'outer': {
          'planet_degrees': planetDegrees2,
          'udayam_abs_deg': 323.0833,
          'arudam_abs_deg': 311.3,
        },
      };
      final notes2 = JamakkolService.calculateNotes(results2, langCode: 'ta');
      final uContact2 = notes2['udayam_contact'] as List;
      expect(uContact2.isNotEmpty, true);
      expect(uContact2.first['planet'], 'Sun');
    });
  });
}
