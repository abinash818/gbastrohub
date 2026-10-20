import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/astro_special_calculations_service.dart';

void main() {
  group('Maanthi (Mandi) Dignity Tests', () {
    test('Aatchi (Own Houses) - Kanni (Virgo), Makaram (Capricorn)', () {
      expect(KPService.getPlanetDignity('Maanthi', 'Virgo'), 'ஆட்சி');
      expect(KPService.getPlanetDignity('Maanthi', 'Capricorn'), 'ஆட்சி');
      expect(KPService.getPlanetDignity('Maanthi', 'கன்னி'), 'ஆட்சி');
      expect(KPService.getPlanetDignity('Maanthi', 'மகரம்'), 'ஆட்சி');
    });

    test('Ucham (Exaltation) - Dhanusu (Sagittarius), Mesham (Aries)', () {
      expect(KPService.getPlanetDignity('Maanthi', 'Sagittarius'), 'உச்சம்');
      expect(KPService.getPlanetDignity('Maanthi', 'Aries'), 'உச்சம்');
      expect(KPService.getPlanetDignity('Maanthi', 'தனுசு'), 'உச்சம்');
      expect(KPService.getPlanetDignity('Maanthi', 'மேஷம்'), 'உச்சம்');
    });

    test('Natpu (Friends) - Viruchigam (Scorpio), Kadagam (Cancer)', () {
      expect(KPService.getPlanetDignity('Maanthi', 'Scorpio'), 'நட்பு');
      expect(KPService.getPlanetDignity('Maanthi', 'Cancer'), 'நட்பு');
      expect(KPService.getPlanetDignity('Maanthi', 'விருச்சிகம்'), 'நட்பு');
      expect(KPService.getPlanetDignity('Maanthi', 'கடகம்'), 'நட்பு');
    });

    test('Neecham (Debilitation) - Mithunam (Gemini), Thulam (Libra)', () {
      expect(KPService.getPlanetDignity('Maanthi', 'Gemini'), 'நீசம்');
      expect(KPService.getPlanetDignity('Maanthi', 'Libra'), 'நீசம்');
      expect(KPService.getPlanetDignity('Maanthi', 'மிதுனம்'), 'நீசம்');
      expect(KPService.getPlanetDignity('Maanthi', 'துலாம்'), 'நீசம்');
    });

    test('Pagai (Enemies) - Rishabam (Taurus), Simmam (Leo), Meenam (Pisces), Kumbam (Aquarius)', () {
      expect(KPService.getPlanetDignity('Maanthi', 'Taurus'), 'பகை');
      expect(KPService.getPlanetDignity('Maanthi', 'Leo'), 'பகை');
      expect(KPService.getPlanetDignity('Maanthi', 'Pisces'), 'பகை');
      expect(KPService.getPlanetDignity('Maanthi', 'Aquarius'), 'பகை');
      expect(KPService.getPlanetDignity('Maanthi', 'ரிஷபம்'), 'பகை');
      expect(KPService.getPlanetDignity('Maanthi', 'சிம்மம்'), 'பகை');
      expect(KPService.getPlanetDignity('Maanthi', 'மீனம்'), 'பகை');
      expect(KPService.getPlanetDignity('Maanthi', 'கும்பம்'), 'பகை');
    });
  });

  group('Rahu Dignity Tests', () {
    test('Aatchi - Kumbam (Aquarius) and Mithunam (Gemini Moolatrikona)', () {
      expect(KPService.getPlanetDignity('Rahu', 'Aquarius'), 'ஆட்சி');
      expect(KPService.getPlanetDignity('Rahu', 'Gemini'), 'ஆட்சி');
      expect(KPService.getPlanetDignity('Rahu', 'கும்பம்'), 'ஆட்சி');
      expect(KPService.getPlanetDignity('Rahu', 'மிதுனம்'), 'ஆட்சி');
    });

    test('Ucham (Exaltation) - Viruchigam (Scorpio)', () {
      expect(KPService.getPlanetDignity('Rahu', 'Scorpio'), 'உச்சம்');
      expect(KPService.getPlanetDignity('Rahu', 'விருச்சிகம்'), 'உச்சம்');
    });

    test('Neecham (Debilitation) - Rishabam (Taurus)', () {
      expect(KPService.getPlanetDignity('Rahu', 'Taurus'), 'நீசம்');
      expect(KPService.getPlanetDignity('Rahu', 'ரிஷபம்'), 'நீசம்');
    });

    test('Natpu (Friends) - Kanni, Thulam, Dhanusu, Makaram, Meenam', () {
      expect(KPService.getPlanetDignity('Rahu', 'Virgo'), 'நட்பு');
      expect(KPService.getPlanetDignity('Rahu', 'Libra'), 'நட்பு');
      expect(KPService.getPlanetDignity('Rahu', 'Sagittarius'), 'நட்பு');
      expect(KPService.getPlanetDignity('Rahu', 'Capricorn'), 'நட்பு');
      expect(KPService.getPlanetDignity('Rahu', 'Pisces'), 'நட்பு');
    });

    test('Pagai (Enemies) - Mesham, Kadagam, Simmam', () {
      expect(KPService.getPlanetDignity('Rahu', 'Aries'), 'பகை');
      expect(KPService.getPlanetDignity('Rahu', 'Cancer'), 'பகை');
      expect(KPService.getPlanetDignity('Rahu', 'Leo'), 'பகை');
    });
  });

  group('Avasthas dignity tests', () {
    test('calculatePlanetaryAvasthas returns correct status for Rahu & Maanthi', () {
      // Rahu in Aquarius (305 deg) -> Aatchi
      // Maanthi in Virgo (155 deg) -> Aatchi
      final avasthas = AstroSpecialCalculationsService.calculatePlanetaryAvasthas({
        'Rahu': 305.0,
        'Maanthi': 155.0,
      }, 0.0);
      final list = avasthas['detailed_list'] as List;
      final rahuItem = list.firstWhere((e) => e['planet'] == 'Rahu');
      final maanthiItem = list.firstWhere((e) => e['planet'] == 'Maanthi');
      expect(rahuItem['status'], 'ஆட்சி');
      expect(maanthiItem['status'], 'ஆட்சி');
    });
  });
}
