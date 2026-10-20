import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/astro_special_calculations_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  group('Hora and Sub-Hora Calculations Test', () {
    test('Verify 5 Sub-Horas weekday sequence for all 7 planets as per user prompt', () {
      final sunrise = DateTime(2026, 10, 17, 6, 6);
      
      // Check Saturday (weekday = 6)
      final tableSat = AstroSpecialCalculationsService.getHoraAndSubHoraTable(6, sunrise);
      expect(tableSat.length, 24);

      // 1st Hora on Saturday is Saturn (சனி)
      final saturnHora = tableSat[0];
      expect(saturnHora['lord'], 'Saturn');
      expect(saturnHora['lord_tamil'], 'சனி');
      expect(saturnHora['start_time'], '06:06');
      expect(saturnHora['end_time'], '07:06');

      final saturnSubHoras = saturnHora['sub_horas'] as List<Map<String, dynamic>>;
      expect(saturnSubHoras.length, 5);

      // 1. சனி உப ஓரை: 6.06 to 6.18
      expect(saturnSubHoras[0]['lord_tamil'], 'சனி');
      expect(saturnSubHoras[0]['start_time'], '06:06');
      expect(saturnSubHoras[0]['end_time'], '06:18');

      // 2. சூரியன் உப ஓரை: 6.18 to 6.30
      expect(saturnSubHoras[1]['lord_tamil'], 'சூரியன்');
      expect(saturnSubHoras[1]['start_time'], '06:18');
      expect(saturnSubHoras[1]['end_time'], '06:30');

      // 3. சந்திரன் உப ஓரை: 6.30 to 6.42
      expect(saturnSubHoras[2]['lord_tamil'], 'சந்திரன்');
      expect(saturnSubHoras[2]['start_time'], '06:30');
      expect(saturnSubHoras[2]['end_time'], '06:42');

      // 4. செவ்வாய் உப ஓரை: 6.42 to 6.54
      expect(saturnSubHoras[3]['lord_tamil'], 'செவ்வாய்');
      expect(saturnSubHoras[3]['start_time'], '06:42');
      expect(saturnSubHoras[3]['end_time'], '06:54');

      // 5. புதன் உப ஓரை: 6.54 to 7.06
      expect(saturnSubHoras[4]['lord_tamil'], 'புதன்');
      expect(saturnSubHoras[4]['start_time'], '06:54');
      expect(saturnSubHoras[4]['end_time'], '07:06');
    });

    test('Verify all 7 hora sub-hora sequences match prompt rules', () {
      final sunrise = DateTime(2026, 10, 18, 6, 0); // Sunday
      final tableSun = AstroSpecialCalculationsService.getHoraAndSubHoraTable(7, sunrise);

      // Sun hora (index 0)
      final sunSub = (tableSun[0]['sub_horas'] as List).map((s) => s['lord_tamil']).toList();
      expect(sunSub, ['சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'புதன்', 'குரு']);

      // Venus hora (index 1 on Sunday)
      final venSub = (tableSun[1]['sub_horas'] as List).map((s) => s['lord_tamil']).toList();
      expect(venSub, ['சுக்கிரன்', 'சனி', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்']);

      // Mercury hora (index 2 on Sunday)
      final merSub = (tableSun[2]['sub_horas'] as List).map((s) => s['lord_tamil']).toList();
      expect(merSub, ['புதன்', 'குரு', 'சுக்கிரன்', 'சனி', 'சூரியன்']);

      // Moon hora (index 3 on Sunday)
      final moonSub = (tableSun[3]['sub_horas'] as List).map((s) => s['lord_tamil']).toList();
      expect(moonSub, ['சந்திரன்', 'செவ்வாய்', 'புதன்', 'குரு', 'சுக்கிரன்']);

      // Saturn hora (index 4 on Sunday)
      final satSub = (tableSun[4]['sub_horas'] as List).map((s) => s['lord_tamil']).toList();
      expect(satSub, ['சனி', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'புதன்']);

      // Jupiter hora (index 5 on Sunday)
      final jupSub = (tableSun[5]['sub_horas'] as List).map((s) => s['lord_tamil']).toList();
      expect(jupSub, ['குரு', 'சுக்கிரன்', 'சனி', 'சூரியன்', 'சந்திரன்']);

      // Mars hora (index 6 on Sunday)
      final marsSub = (tableSun[6]['sub_horas'] as List).map((s) => s['lord_tamil']).toList();
      expect(marsSub, ['செவ்வாய்', 'புதன்', 'குரு', 'சுக்கிரன்', 'சனி']);
    });

    test('Birth time hora & sub-hora calculation: Namakkal example 17/10/26 06:59 AM', () {
      final birthDt = DateTime(2026, 10, 17, 6, 59);
      final panchaSunrise = "06:06 AM";
      // Weekday: Saturday = 6
      final horaResult = KPService.calculateBirthHoraAndSubHora(panchaSunrise, birthDt, 6);
      expect(horaResult, 'சனி - புத');
    });

    test('Birth time hora & sub-hora audio example: Sun Hora + Moon Sub-Hora', () {
      final birthDt = DateTime(2026, 10, 18, 6, 15);
      final panchaSunrise = "06:00 AM";
      // Weekday: Sunday = 7
      final horaResult = KPService.calculateBirthHoraAndSubHora(panchaSunrise, birthDt, 7);
      expect(horaResult, 'சூரி - சந்');
    });
  });
}
