import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/astro_special_calculations_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';

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

    test('D6 (Shashtamsha) exactly matches textbook table for male and female signs', () {
      // Odd sign: Aries (0)
      // 0-5° -> Aries (0)
      // 5-10° -> Gemini (2)
      // 10-15° -> Leo (4)
      // 15-20° -> Libra (6)
      // 20-25° -> Sagittarius (8)
      // 25-30° -> Aquarius (10)
      expect(KPService.calculateVargaSignForTest(2.5, 6), equals(0));  // Aries
      expect(KPService.calculateVargaSignForTest(7.5, 6), equals(2));  // Gemini
      expect(KPService.calculateVargaSignForTest(12.5, 6), equals(4)); // Leo
      expect(KPService.calculateVargaSignForTest(17.5, 6), equals(6)); // Libra
      expect(KPService.calculateVargaSignForTest(22.5, 6), equals(8)); // Sagittarius
      expect(KPService.calculateVargaSignForTest(27.5, 6), equals(10));// Aquarius

      // Even sign: Taurus (1) [longitude 30-60]
      // 0-5° (lon 32.5) -> Taurus (1)
      // 5-10° (lon 37.5) -> Cancer (3)
      // 10-15° (lon 42.5) -> Virgo (5)
      // 15-20° (lon 47.5) -> Scorpio (7)
      // 20-25° (lon 52.5) -> Capricorn (9)
      // 25-30° (lon 57.5) -> Pisces (11)
      expect(KPService.calculateVargaSignForTest(32.5, 6), equals(1));  // Taurus
      expect(KPService.calculateVargaSignForTest(37.5, 6), equals(3));  // Cancer
      expect(KPService.calculateVargaSignForTest(42.5, 6), equals(5));  // Virgo
      expect(KPService.calculateVargaSignForTest(47.5, 6), equals(7));  // Scorpio
      expect(KPService.calculateVargaSignForTest(52.5, 6), equals(9));  // Capricorn
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
  });
}
