import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Verify Dasa & Bhukti Calculations for 07-09-2026 11:29 AM Chennai', () async {
    await KPService.init();

    final dt = DateTime(2026, 9, 7, 11, 29);

    for (double yLen in [360.0, 365.25]) {
      print('\n========================================');
      print('TESTING YEAR LENGTH: $yLen');
      print('========================================');

      final results = await KPService.calculateChart(
        'User_Sep7',
        dt,
        13.0827,
        80.2707,
        5.5,
        yearLength: yLen,
        siderealModeIndex: 0, // Lahiri
      );

      final moon = results['planet_details']['moon'];
      print('Moon: ${moon['rasi']} ${moon['longitude']}° Star: ${moon['nakshatra']} Padam: ${moon['padam']}');

      final dasaList = results['dasa'] as List<dynamic>;
      final firstDasa = dasaList[0];
      print('First Dasa Lord: ${firstDasa['lord']}');
      print('First Dasa Start (Birth): ${firstDasa['start']}');
      print('First Dasa Theoretical Full Start: ${firstDasa['fullStart']}');
      print('First Dasa End: ${firstDasa['end']}');
      print('First Dasa BalanceStr: ${firstDasa['balanceStr']} (Y: ${firstDasa['balance_y']}, M: ${firstDasa['balance_m']}, D: ${firstDasa['balance_d']})');
      print('First Dasa GarbhaSelStr: ${firstDasa['garbhaSelStr']} (Y: ${firstDasa['garbha_y']}, M: ${firstDasa['garbha_m']}, D: ${firstDasa['garbha_d']})');

      expect(firstDasa['lord'], equals('Jupiter'));
      expect(firstDasa['balance_y'], equals(4));
      expect(firstDasa['balance_m'], equals(9));
      expect(firstDasa['balance_d'], equals(28));

      // Check Bhuktis
      final bhuktis = firstDasa['subPeriods'] as List<dynamic>;
      print('Active Bhuktis from birth:');
      for (var b in bhuktis) {
        print('  ${b['lord']}: ${b['start']} -> ${b['end']} | Balance: ${b['balanceStr']}');
      }

      final firstBhukti = bhuktis.first;
      expect(firstBhukti['lord'], equals('Sun'));
      expect(firstBhukti['balance_y'], equals(0));
      expect(firstBhukti['balance_m'], equals(1));
      // In 360d or 365.25d, days is around 28-29 days
      expect(firstBhukti['balance_d'], greaterThanOrEqualTo(28));
      expect(firstBhukti['balance_d'], lessThanOrEqualTo(30));

      if (yLen == 360.0) {
        // With 360 days, Jupiter Dasa ends in June 2031
        expect(firstDasa['end'].year, equals(2031));
        expect(firstDasa['end'].month, equals(6));
      } else {
        // With 365.25 days, Jupiter Dasa ends in July 2031
        expect(firstDasa['end'].year, equals(2031));
        expect(firstDasa['end'].month, equals(7));
      }
    }
  });

  test('Verify Default Settings Fallback in KPService.calculateChart', () async {
    await KPService.init();

    // Set preference to 360.0
    await SettingsService.saveDasaYearLength(360.0);

    final dt = DateTime(2026, 9, 7, 11, 29);
    // Call without passing yearLength
    final results = await KPService.calculateChart('TestFallback', dt, 13.0827, 80.2707, 5.5);

    expect(results['year_length'], equals(360.0));
    final dasaList = results['dasa'] as List<dynamic>;
    expect(dasaList[0]['end'].month, equals(6)); // June 2031
  });
}
