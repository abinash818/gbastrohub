import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/astro_special_calculations_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/astro_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AstroSpecialCalculationsService Tests', () {
    test('Indu Lagna calculation matches classical rules', () {
      // Example: Lagna in Mesha (0), 9th house is Dhanus (Jupiter, 10 rays).
      // Moon in Vrishabha (1), 9th house is Makara (Saturn, 1 ray).
      // Total rays = 10 + 1 = 11 rays.
      // Remainder = 11 % 12 = 11.
      // Indu Lagna from Moon (Vrishabha, index 1): 1 + 11 - 1 = 11 (Meena / Pisces).
      double lagnaLon = 15.0; // Aries
      double moonLon = 45.0;  // Taurus

      final res = AstroSpecialCalculationsService.calculateInduLagna(lagnaLon, moonLon);
      expect(res['total_rays'], equals(11));
      expect(res['rasi_index'], equals(11)); // Meena
      expect(res['rasi_name'], equals('Pisces'));
      expect(res['rasi_tamil'], equals('மீனம்'));
    });

    test('Fortuna calculation correctly alternates day and night births', () {
      double lagnaLon = 30.0;
      double sunLon = 60.0;
      double moonLon = 120.0;

      // Day birth: Lagna + Moon - Sun = 30 + 120 - 60 = 90
      final dayRes = AstroSpecialCalculationsService.calculateFortuna(lagnaLon, sunLon, moonLon, true);
      expect(dayRes['longitude'], equals(90.0));

      // Night birth: Lagna + Sun - Moon = 30 + 60 - 120 + 360 = 330
      final nightRes = AstroSpecialCalculationsService.calculateFortuna(lagnaLon, sunLon, moonLon, false);
      expect(nightRes['longitude'], equals(330.0));
    });

    test('Upagraha formula satisfies classical identity: Upaketu + 30° == Sun', () {
      double sunLon = 85.5;
      DateTime dt = DateTime(2026, 9, 1, 10, 30);
      final upagrahas = AstroSpecialCalculationsService.calculateUpagrahas(sunLon, dt, "06:00");

      double upaketuLon = upagrahas['உபகேது (Upaketu)']['longitude'];
      double checkSun = (upaketuLon + 30.0) % 360.0;

      expect(checkSun, closeTo(sunLon, 0.0001));
    });

    test('Yogi and Avayogi calculations verify 6th nakshatra distance', () {
      double sunLon = 45.0;
      double moonLon = 90.0;

      final yogiAvayogi = AstroSpecialCalculationsService.calculateYogiAvayogi(sunLon, moonLon);
      double yogiLon = yogiAvayogi['yogi']['longitude'];
      double avayogiLon = yogiAvayogi['avayogi']['longitude'];

      double diff = (avayogiLon - yogiLon + 360.0) % 360.0;
      expect(diff, closeTo(186.6666, 0.01));
    });

    test('Jaimini Karakas correctly sorts 7 planets by degree in descending order', () {
      Map<String, double> planetLons = {
        'Sun': 28.5,      // 28.5 deg
        'Moon': 35.2,     // 5.2 deg
        'Mars': 84.1,     // 24.1 deg
        'Mercury': 118.9, // 28.9 deg -> Highest!
        'Jupiter': 130.0, // 10.0 deg
        'Venus': 181.2,   // 1.2 deg -> Lowest!
        'Saturn': 225.4,  // 15.4 deg
      };

      final karakas = AstroSpecialCalculationsService.calculateJaiminiKarakas(planetLons);
      expect(karakas['atmakaraka']['planet'], equals('Mercury')); // 28.9°
      expect(karakas['darakaraka']['planet'], equals('Venus'));   // 1.2°
    });

    test('Nazhigai and Hours converter accuracy', () {
      // 10 hours = 25 Nazhigai
      // 25 Nazhigai = 10 Hours
      final hRes = AstroSpecialCalculationsService.convertNazhigaiToHours(25, 0);
      expect(hRes, equals(10.0));
    });

    test('D6 (Shashtamsha) exactly matches standard Parashari table for male and female signs', () {
      // Odd sign: Aries (0) or Gemini (2)
      // 0-5° -> Aries (0)
      // 5-10° -> Taurus (1)
      // 10-15° -> Gemini (2)
      // 15-20° -> Cancer (3)
      // 20-25° -> Leo (4)
      // 25-30° -> Virgo (5)
      expect(KPService.calculateVargaSignForTest(2.5, 6), equals(0));  // Aries
      expect(KPService.calculateVargaSignForTest(7.5, 6), equals(1));  // Taurus
      expect(KPService.calculateVargaSignForTest(12.5, 6), equals(2)); // Gemini
      expect(KPService.calculateVargaSignForTest(17.5, 6), equals(3)); // Cancer
      expect(KPService.calculateVargaSignForTest(22.5, 6), equals(4)); // Leo
      expect(KPService.calculateVargaSignForTest(27.5, 6), equals(5)); // Virgo

      // Even sign: Taurus (1) [longitude 30-60]
      // 0-5° (lon 32.5) -> Libra (6)
      // 5-10° (lon 37.5) -> Scorpio (7)
      // 10-15° (lon 42.5) -> Sagittarius (8)
      // 15-20° (lon 47.5) -> Capricorn (9)
      // 20-25° (lon 52.5) -> Aquarius (10)
      // 25-30° (lon 57.5) -> Pisces (11)
      expect(KPService.calculateVargaSignForTest(32.5, 6), equals(6));  // Libra
      expect(KPService.calculateVargaSignForTest(37.5, 6), equals(7));  // Scorpio
      expect(KPService.calculateVargaSignForTest(42.5, 6), equals(8));  // Sagittarius
      expect(KPService.calculateVargaSignForTest(47.5, 6), equals(9));  // Capricorn
      expect(KPService.calculateVargaSignForTest(52.5, 6), equals(10)); // Aquarius
      expect(KPService.calculateVargaSignForTest(57.5, 6), equals(11)); // Pisces
    });

    test('D12 (Dwadasamsha) exactly matches textbook table', () {
      // For Taurus (1) [lon 30-60]:
      // 1: 0-2.5° -> Taurus (1) (1st sign)
      // 2: 2.5-5.0° -> Gemini (2) (2nd sign)
      // 3: 5.0-7.5° -> Cancer (3) (3rd sign)
      // ...
      // 12: 27.5-30° -> Aries (0) (12th sign)
      expect(KPService.calculateVargaSignForTest(31.0, 12), equals(1));
      expect(KPService.calculateVargaSignForTest(33.0, 12), equals(2));
      expect(KPService.calculateVargaSignForTest(36.0, 12), equals(3));
      expect(KPService.calculateVargaSignForTest(58.0, 12), equals(0));
    });

    test('All Vargas D1 to D60 comply with classical BPHS rules', () {
      // Test lon = 14° in Aries (0, Movable, Odd, Fire)
      // D1: Aries (0)
      expect(KPService.calculateVargaSignForTest(14.0, 1), equals(0));
      // D2: 14° in Odd sign -> Leo (4)
      expect(KPService.calculateVargaSignForTest(14.0, 2), equals(4));
      // D3: 14° (10-20°) -> 5th house -> Leo (4)
      expect(KPService.calculateVargaSignForTest(14.0, 3), equals(4));
      // D4: 14° (7.5-15°) -> 4th house -> Cancer (3)
      expect(KPService.calculateVargaSignForTest(14.0, 4), equals(3));
      // D5: 14° (12-18°, part 2 in Odd) -> Sag (8)
      expect(KPService.calculateVargaSignForTest(14.0, 5), equals(8));
      // D6: 14° (10-15°, part 2 in Odd) -> Gemini (2)
      expect(KPService.calculateVargaSignForTest(14.0, 6), equals(2));
      // D7: 14° (12.85-17.14°, part 3 in Odd) -> Cancer (3)
      expect(KPService.calculateVargaSignForTest(14.0, 7), equals(3));
      // D8: 14° (11.25-15°, part 3 in Movable) -> Cancer (3)
      expect(KPService.calculateVargaSignForTest(14.0, 8), equals(3));
      // D9: 14° (13.33-16.66°, part 4 in Movable) -> Leo (4)
      expect(KPService.calculateVargaSignForTest(14.0, 9), equals(4));
      // D10: 14° (12-15°, part 4 in Odd) -> Leo (4)
      expect(KPService.calculateVargaSignForTest(14.0, 10), equals(4));
      // D12: 14° (12.5-15°, part 5) -> Virgo (5)
      expect(KPService.calculateVargaSignForTest(14.0, 12), equals(5));
      // D16: 14° (part 7 in Movable: 13.125-15°) -> Scorpio (7)
      expect(KPService.calculateVargaSignForTest(14.0, 16), equals(7));
      // D20: 14° (part 9 in Movable: 13.5-15°) -> Capricorn (9)
      expect(KPService.calculateVargaSignForTest(14.0, 20), equals(9));
      // D24: 14° (part 11 in Odd starting from Leo: 13.75-15°) -> Cancer (3)
      expect(KPService.calculateVargaSignForTest(14.0, 24), equals(3));
      // D27: 14° (part 12 in Fire starting from Aries: 13.33-14.44°) -> Aries (0)
      expect(KPService.calculateVargaSignForTest(14.0, 27), equals(0));
      // D30: 14° (10-18° in Odd) -> Sagittarius (8)
      expect(KPService.calculateVargaSignForTest(14.0, 30), equals(8));
      // D40: 14° (part 18 in Odd starting from Aries: 13.5-14.25°) -> Libra (6)
      expect(KPService.calculateVargaSignForTest(14.0, 40), equals(6));
      // D45: 14° (part 21 in Movable starting from Aries: 14.0-14.66°) -> Capricorn (9)
      expect(KPService.calculateVargaSignForTest(14.0, 45), equals(9));
      // D60: 14° (part 28 starting from Aries: 14.0-14.5°) -> Leo (4)
      expect(KPService.calculateVargaSignForTest(14.0, 60), equals(4));

      // Test lon = 44° in Taurus (1, Fixed, Even, Earth)
      // D1: Taurus (1)
      expect(KPService.calculateVargaSignForTest(44.0, 1), equals(1));
      // D2: 14° in Even sign -> Cancer (3)
      expect(KPService.calculateVargaSignForTest(44.0, 2), equals(3));
      // D3: 14° (10-20°) -> 5th from Taurus -> Virgo (5)
      expect(KPService.calculateVargaSignForTest(44.0, 3), equals(5));
      // D4: 14° (7.5-15°) -> 4th from Taurus -> Leo (4)
      expect(KPService.calculateVargaSignForTest(44.0, 4), equals(4));
      // D5: 14° (12-18°, part 2 in Even) -> Pisces (11)
      expect(KPService.calculateVargaSignForTest(44.0, 5), equals(11));
      // D6: 14° (10-15°, part 2 in Even starting from Libra=6) -> Sagittarius (8)
      expect(KPService.calculateVargaSignForTest(44.0, 6), equals(8));
      // D7: 14° (12.85-17.14°, part 3 in Even starting from 7th from Taurus = Scorpio=7) -> Aquarius (10)
      expect(KPService.calculateVargaSignForTest(44.0, 7), equals(10));
      // D8: 14° (11.25-15°, part 3 in Fixed starting from Sag=8) -> Pisces (11)
      expect(KPService.calculateVargaSignForTest(44.0, 8), equals(11));
      // D9: 14° (13.33-16.66°, part 4 in Fixed starting from Capricorn=9) -> Taurus (1)
      expect(KPService.calculateVargaSignForTest(44.0, 9), equals(1));
      // D10: 14° (12-15°, part 4 in Even starting from Capricorn=9) -> Taurus (1)
      expect(KPService.calculateVargaSignForTest(44.0, 10), equals(1));
      // D12: 14° (12.5-15°, part 5 starting from Taurus=1) -> Libra (6)
      expect(KPService.calculateVargaSignForTest(44.0, 12), equals(6));
      // D16: 14° (part 7 in Fixed starting from Leo=4) -> Pisces (11)
      expect(KPService.calculateVargaSignForTest(44.0, 16), equals(11));
      // D20: 14° (part 9 in Fixed starting from Sag=8) -> Virgo (5)
      expect(KPService.calculateVargaSignForTest(44.0, 20), equals(5));
      // D24: 14° (part 11 in Even starting from Cancer=3) -> Gemini (2)
      expect(KPService.calculateVargaSignForTest(44.0, 24), equals(2));
      // D27: 14° (part 12 in Earth starting from Cancer=3) -> Cancer (3)
      expect(KPService.calculateVargaSignForTest(44.0, 27), equals(3));
      // D30: 14° (12-20° in Even) -> Pisces (11)
      expect(KPService.calculateVargaSignForTest(44.0, 30), equals(11));
      // D40: 14° (part 18 in Even starting from Libra=6) -> Aries (0)
      expect(KPService.calculateVargaSignForTest(44.0, 40), equals(0));
      // D45: 14° (part 21 in Fixed starting from Leo=4) -> Taurus (1)
      expect(KPService.calculateVargaSignForTest(44.0, 45), equals(1));
      // D60: 14° (part 28 starting from Taurus=1) -> Virgo (5)
      expect(KPService.calculateVargaSignForTest(44.0, 60), equals(5));
    });

    test('Chandrashtama correctly computes 8th sign and 17th star', () {
      // Moon in Ashwini (Aries, index 0, star index 0)
      double moonLon = 5.0;
      final ch = AstroSpecialCalculationsService.calculateChandrashtama(moonLon);
      expect(ch['rasi_index'], equals(7)); // Scorpio (8th sign)
      expect(ch['rasi_tamil'], equals('விருச்சிகம்'));
      expect(ch['direct_star_index'], equals(16)); // Anuradha / அனுஷம் (17th star)
      expect(ch['direct_star_tamil'], equals('அனுஷம்'));
      expect(ch['direct_text'], equals('அனுஷம் (17-வது நட்சத்திரம்)'));
    });

    test('60 Tamil Years all have Sri prefix and 40th year is Sri Parabhava', () {
      expect(KPService.TAMIL_YEARS_60.length, equals(60));
      for (var year in KPService.TAMIL_YEARS_60) {
        expect(year.startsWith("ஸ்ரீ"), isTrue, reason: "$year must start with ஸ்ரீ");
      }
      expect(KPService.TAMIL_YEARS_60[39], equals("ஸ்ரீ பராபவ"));
    });

    test('Combustion calculation correctly detects planets within classical orbs', () {
      double sunLon = 100.0;
      // Mars direct: orb is 17°
      expect(KPService.isPlanetCombust('Mars', 115.0, sunLon, false), isTrue); // 15° diff <= 17°
      expect(KPService.isPlanetCombust('Mars', 120.0, sunLon, false), isFalse); // 20° diff > 17°

      // Mars retro: orb is 8°
      expect(KPService.isPlanetCombust('Mars', 106.0, sunLon, true), isTrue); // 6° diff <= 8°
      expect(KPService.isPlanetCombust('Mars', 110.0, sunLon, true), isFalse); // 10° diff > 8°

      // Jupiter: orb is 11°
      expect(KPService.isPlanetCombust('Jupiter', 110.0, sunLon, false), isTrue); // 10° diff <= 11°
      expect(KPService.isPlanetCombust('Jupiter', 115.0, sunLon, false), isFalse); // 15° diff > 11°
    });

    test('Karana Tamil map matches classical 11 names with Taitila as தைதுலை', () {
      expect(KPService.TAMIL_KARANAS['Taitila'], equals('தைதுலை'));
      expect(KPService.TAMIL_KARANAS['Vishti'], equals('பத்திரை (விஷ்டி)'));
      expect(KPService.TAMIL_KARANAS['Kimstughna'], equals('கிம்துக்கினம்'));
      expect(KPService.TAMIL_KARANAS['Bava'], equals('பவம்'));
    });

    test('formatDegrees returns DD:MM compact format', () {
      expect(KPService.formatDegrees(4.8), equals('04:48'));
      expect(KPService.formatDegrees(19.8333), equals('19:50'));
      expect(KPService.formatDegrees(21.7), equals('21:42'));
    });

    test('Vainasika Dosha Pada correctly calculates 88th pada from Janma pada', () {
      // Example: Moon in Ashwini 1st pada (lon: 1.0, padaGlobalIdx: 0)
      // 88th pada from 0: (0 + 87) % 108 = 87.
      // Nakshatra index = 87 / 4 = 21 (Uttarashada / உத்திராடம்)
      // Pada = (87 % 4) + 1 = 4th pada
      // Rasi = 87 / 9 = 9 (Capricorn / மகரம்)
      double moonLon = 1.0;
      Map<String, double> planetLons = {
        'Sun': 295.0, // Capricorn (in 88th pada: 87 * 3.3333 = 290.0 to 293.33 -> wait, 87 * 3.3333333333 = 290.0)
      };

      final vainasika = AstroSpecialCalculationsService.calculateVainasikaPada(moonLon, planetLons);
      expect(vainasika['janma_nakshatra'], equals('அஸ்வினி'));
      expect(vainasika['janma_pada'], equals(1));
      expect(vainasika['vainasika_nakshatra'], equals('திருவோணம்'));
      expect(vainasika['vainasika_pada'], equals(4));
      expect(vainasika['vainasika_rasi_tamil'], equals('மகரம்'));
      expect(vainasika['vainasika_nak_lord_tamil'], equals('சந்திரன்'));
    });

    test('Kala Pagai 9 pairs correctly detected', () {
      DateTime birthDt = DateTime(1990, 1, 1);
      List<dynamic> dasaList = [
        {
          'lord': 'Saturn',
          'start': DateTime(1990, 1, 1),
          'end': DateTime(2009, 1, 1),
          'subPeriods': [
            {
              'lord': 'Mars',
              'start': DateTime(2000, 1, 1),
              'end': DateTime(2001, 2, 1),
            },
            {
              'lord': 'Jupiter',
              'start': DateTime(2001, 2, 1),
              'end': DateTime(2003, 8, 1),
            }
          ]
        }
      ];

      final kpRes = AstroSpecialCalculationsService.checkKalaPagai(dasaList: dasaList, birthDt: birthDt);
      final warnings = kpRes['warnings'] as List;
      expect(warnings.length, equals(1));
      expect(warnings[0]['pair'], equals('Saturn-Mars'));
      expect(warnings[0]['dasa_tamil'], equals('சனி'));
      expect(warnings[0]['bhukthi_tamil'], equals('செவ்வாய்'));
    });

    test('Kala Natpu & Pagai Age matrix properly evaluates native age', () {
      DateTime birthDt = DateTime(2020, 1, 1);
      List<dynamic> dasaList = [
        {
          'lord': 'Mercury',
          'start': DateTime(2024, 1, 1), // age 4
          'end': DateTime(2032, 1, 1),   // age 12
        }
      ];

      final res = AstroSpecialCalculationsService.checkKalaNatpuAndPagaiAges(dasaList: dasaList, birthDt: birthDt);
      final timeline = res['timeline'] as List;
      expect(timeline.length, equals(1));
      expect(timeline[0]['status_type'], equals('natpu'));
      expect(timeline[0]['status'], contains('காலநட்பு'));
    });

    test('Pancha Patchi and Padu Patchi calculate correctly for Shukla and Krishna Paksha', () {
      // Shukla Paksha (பூர்வபட்சம்):
      // வல்லூறு: வியாழன், சனி | ஆந்தை: ஞாயிறு, வெள்ளி | காகம்: திங்கள் | கோழி: செவ்வாய் | மயில்: புதன்
      expect(AstroUtils.getPaduPatchi(0, true), equals("ஆந்தை"));   // ஞாயிறு
      expect(AstroUtils.getPaduPatchi(1, true), equals("காகம்"));   // திங்கள்
      expect(AstroUtils.getPaduPatchi(2, true), equals("கோழி"));    // செவ்வாய்
      expect(AstroUtils.getPaduPatchi(3, true), equals("மயில்"));    // புதன்
      expect(AstroUtils.getPaduPatchi(4, true), equals("வல்லூறு")); // வியாழன்
      expect(AstroUtils.getPaduPatchi(5, true), equals("ஆந்தை"));   // வெள்ளி
      expect(AstroUtils.getPaduPatchi(6, true), equals("வல்லூறு")); // சனி

      // Krishna Paksha (அமரபட்சம்):
      // வல்லூறு: செவ்வாய் | ஆந்தை: திங்கள் | காகம்: ஞாயிறு | கோழி: வியாழன், சனி | மயில்: புதன், வெள்ளி
      expect(AstroUtils.getPaduPatchi(0, false), equals("காகம்"));   // ஞாயிறு
      expect(AstroUtils.getPaduPatchi(1, false), equals("ஆந்தை"));   // திங்கள்
      expect(AstroUtils.getPaduPatchi(2, false), equals("வல்லூறு")); // செவ்வாய்
      expect(AstroUtils.getPaduPatchi(3, false), equals("மயில்"));    // புதன்
      expect(AstroUtils.getPaduPatchi(4, false), equals("கோழி"));    // வியாழன்
      expect(AstroUtils.getPaduPatchi(5, false), equals("மயில்"));    // வெள்ளி
      expect(AstroUtils.getPaduPatchi(6, false), equals("கோழி"));    // சனி
    });

    test('Mudakku Rasi and Nakshatra matches textbook table for all 27 nakshatras', () {
      // 1. Ashwini (0 * 13.333 + 5 deg = 5.0 deg) -> Pooram (10), Simmam (4), Venus
      var res = AstroSpecialCalculationsService.calculateMudakku(5.0);
      expect(res['sun_nakshatra'], equals('Ashwini'));
      expect(res['nakshatra'], equals('Purvaphalguni'));
      expect(res['rasi'], equals('Leo'));
      expect(res['lord'], equals('Venus'));

      // 6. Ardra (5 * 13.333 + 5 deg = 71.66 deg) -> Ardra (5), Mithunam (2), Rahu
      res = AstroSpecialCalculationsService.calculateMudakku(71.66);
      expect(res['sun_nakshatra'], equals('Arudra'));
      expect(res['nakshatra'], equals('Arudra'));
      expect(res['rasi'], equals('Gemini'));
      expect(res['lord'], equals('Rahu'));

      // 12. Uthiram (11 * 13.333 + 5 deg = 151.66 deg) -> Revathi (26), Meenam (11), Mercury
      res = AstroSpecialCalculationsService.calculateMudakku(151.66);
      expect(res['sun_nakshatra'], equals('Uttaraphalguni'));
      expect(res['nakshatra'], equals('Revati'));
      expect(res['rasi'], equals('Pisces'));
      expect(res['lord'], equals('Mercury'));

      // 27. Revathi (26 * 13.333 + 5 deg = 351.66 deg) -> Uthiram (11), Simmam (4), Sun
      res = AstroSpecialCalculationsService.calculateMudakku(351.66);
      expect(res['sun_nakshatra'], equals('Revati'));
      expect(res['nakshatra'], equals('Uttaraphalguni'));
      expect(res['rasi'], equals('Leo'));
      expect(res['lord'], equals('Sun'));
    });

    test('Amirthathi Yogam verifies textbook matching results for sample days and stars', () {
      // Sunday (0/7) + Bharani (1) -> Prabalarishtam
      expect(KPService.calculateAmirthathiYogaForTest(7, 1), equals("பிரபலாரிட்ட யோகம்"));

      // Sunday (0/7) + Revati (26) -> Amirtha
      expect(KPService.calculateAmirthathiYogaForTest(7, 26), equals("அமிர்த யோகம்"));

      // Monday (1) + Poorattathi (24) -> Marana
      expect(KPService.calculateAmirthathiYogaForTest(1, 24), equals("மரண யோகம்"));

      // Thursday (4) + Pooram (10) -> Marana
      expect(KPService.calculateAmirthathiYogaForTest(4, 10), equals("மரண யோகம்"));

      // Thursday (4) + Uthiram (11) -> Siddha
      expect(KPService.calculateAmirthathiYogaForTest(4, 11), equals("சித்த யோகம்"));

      // Friday (5) + Pooram (10) -> Amirtha
      expect(KPService.calculateAmirthathiYogaForTest(5, 10), equals("அமிர்த யோகம்"));

      // Saturday (6) + Revati (26) -> Prabalarishtam
      expect(KPService.calculateAmirthathiYogaForTest(6, 26), equals("பிரபலாரிட்ட யோகம்"));
    });

    test('Dasa Nalvar (Bodhaka, Vedhaka, Pachaka, Karaka) correctly matches classical rules', () {
      // 1. Sun Dasa
      var sunNalvar = AstroSpecialCalculationsService.getDasaNalvar('Sun')!;
      expect(sunNalvar['bodhaka']['planet'], equals('Mars'));
      expect(sunNalvar['bodhaka']['house'], equals(7));
      expect(sunNalvar['vedhaka']['planet'], equals('Venus'));
      expect(sunNalvar['vedhaka']['house'], equals(11));
      expect(sunNalvar['pachaka']['planet'], equals('Saturn'));
      expect(sunNalvar['pachaka']['house'], equals(6));
      expect(sunNalvar['karaka']['planet'], equals('Jupiter'));
      expect(sunNalvar['karaka']['house'], equals(9));

      // 2. Moon Dasa
      var moonNalvar = AstroSpecialCalculationsService.getDasaNalvar('Moon')!;
      expect(moonNalvar['bodhaka']['planet'], equals('Mars'));
      expect(moonNalvar['bodhaka']['house'], equals(9));
      expect(moonNalvar['vedhaka']['planet'], equals('Sun'));
      expect(moonNalvar['vedhaka']['house'], equals(3));
      expect(moonNalvar['pachaka']['planet'], equals('Venus'));
      expect(moonNalvar['pachaka']['house'], equals(5));
      expect(moonNalvar['karaka']['planet'], equals('Saturn'));
      expect(moonNalvar['karaka']['house'], equals(11));

      // 3. Saturn Dasa
      var saturnNalvar = AstroSpecialCalculationsService.getDasaNalvar('Saturn')!;
      expect(saturnNalvar['bodhaka']['planet'], equals('Moon'));
      expect(saturnNalvar['bodhaka']['house'], equals(11));
      expect(saturnNalvar['vedhaka']['planet'], equals('Mars'));
      expect(saturnNalvar['vedhaka']['house'], equals(7));
      expect(saturnNalvar['pachaka']['planet'], equals('Venus'));
      expect(saturnNalvar['pachaka']['house'], equals(3));
      expect(saturnNalvar['karaka']['planet'], equals('Jupiter'));
      expect(saturnNalvar['karaka']['house'], equals(6));
    });

    test('DNA Nakshatra Karma registry precisely maps all 27 nakshatras', () {
      // Sun (4 stars): Ashwini, Ashlesha, Anuradha, Purva Bhadrapada
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('அஸ்வினி'), equals('Sun'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('ஆயில்யம்'), equals('Sun'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('அனுஷம்'), equals('Sun'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('பூரட்டாதி'), equals('Sun'));

      // Moon (4 stars): Bharani, Magha, Jyeshtha, Uttara Bhadrapada
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('பரணி'), equals('Moon'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('மகம்'), equals('Moon'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('கேட்டை'), equals('Moon'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('உத்தரட்டாதி'), equals('Moon'));

      // Mars (4 stars): Krittika, Purva Phalguni, Mula, Revati
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('கார்த்திகை'), equals('Mars'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('பூரம்'), equals('Mars'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('மூலம்'), equals('Mars'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('ரேவதி'), equals('Mars'));

      // Mercury (3 stars): Rohini, Uttara Phalguni, Purvashada
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('ரோகிணி'), equals('Mercury'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('உத்திரம்'), equals('Mercury'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('பூராடம்'), equals('Mercury'));

      // Jupiter (3 stars): Mrigashirsha, Hasta, Uttarashada
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('மிருகசீரிடம்'), equals('Jupiter'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('அஸ்தம்'), equals('Jupiter'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('உத்திராடம்'), equals('Jupiter'));

      // Venus (3 stars): Ardra, Chitra, Shravana
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('திருவாதிரை'), equals('Venus'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('சித்திரை'), equals('Venus'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('திருவோணம்'), equals('Venus'));

      // Saturn (3 stars): Punarvasu, Swati, Dhanishta
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('புனர்பூசம்'), equals('Saturn'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('சுவாதி'), equals('Saturn'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('அவிட்டம்'), equals('Saturn'));

      // Rahu (3 stars): Pushya, Vishakha, Shatabhisha
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('பூசம்'), equals('Rahu'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('விசாகம்'), equals('Rahu'));
      expect(AstroSpecialCalculationsService.getDnaPlanetFromNakshatra('சதயம்'), equals('Rahu'));
    });
  });
}
