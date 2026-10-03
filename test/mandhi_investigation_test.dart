import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Check Mandhi for the 3 user screenshots', () async {
    await KPService.init();

    // Case 1: 28-09-2026 03:05:00 Namakkal
    // Expected: Taurus (ரிஷபம்) 10°
    final dt1 = DateTime(2026, 9, 28, 3, 5, 0);
    final res1 = await KPService.calculateChart('Case1', dt1, 11.2189, 78.1674, 5.5, siderealModeIndex: 0);
    final m1 = res1['planet_details']['maanthi'];
    print('Case 1 (28-09-2026 03:05:00): Mandhi = ${m1['rasi']} ${(m1['longitude'] % 30).toStringAsFixed(2)}° (Total: ${m1['longitude'].toStringAsFixed(2)}°)');

    // Case 2: 16-09-2026 23:30:00 Namakkal
    // Expected: Leo (சிம்மம்) 5°
    final dt2 = DateTime(2026, 9, 16, 23, 30, 0);
    final res2 = await KPService.calculateChart('Case2', dt2, 11.2189, 78.1674, 5.5, siderealModeIndex: 0);
    final m2 = res2['planet_details']['maanthi'];
    print('Case 2 (16-09-2026 23:30:00): Mandhi = ${m2['rasi']} ${(m2['longitude'] % 30).toStringAsFixed(2)}° (Total: ${m2['longitude'].toStringAsFixed(2)}°)');

    // Case 4: User screenshot: 17-09-2026 21:55:00 Namakkal
    final dt4 = DateTime(2026, 9, 17, 21, 55, 0);
    for (int method = 0; method <= 4; method++) {
      await SettingsService.saveMaandiMethod(method);
      final res4 = await KPService.calculateChart('Case4', dt4, 11.2189, 78.1674, 5.5, siderealModeIndex: 0);
      final m4 = res4['planet_details']['maanthi'];
      print('Method $method: Mandhi = ${m4['rasi']} ${(m4['longitude'] % 30).toStringAsFixed(2)}° (Total: ${m4['longitude'].toStringAsFixed(2)}°)');
    }
  });
}
