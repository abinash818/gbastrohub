import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Verify Ashtakavarga with Lagna Switch OFF (Aadhiguru) vs ON (Book Lagna) across reference charts', () async {
    await KPService.init();

    // ── Chart 1: 03-09-2026 10:30 AM Chennai ───────────────────────────────
    final dt1 = DateTime(2026, 9, 3, 10, 30);
    
    // 1. Test when Switch is OFF (Uses Aadhiguru Ashtakavarga rules)
    await SettingsService.saveIncludeLagnaAshtakavarga(false);
    final resOff1 = await KPService.calculateChart("User1", dt1, 13.0827, 80.2707, 5.5);
    final avOff1 = resOff1['ashtakavarga'];
    final indOff1 = (avOff1['individual'] as Map).cast<String, dynamic>();

    expect(avOff1['includeLagna'], isFalse);
    expect(indOff1.containsKey('Lagna'), isFalse);
    expect(indOff1.length, equals(7)); // Only 7 planets
    expect(indOff1['Sun'], equals([5, 3, 4, 4, 2, 5, 3, 3, 5, 4, 3, 7]));
    expect(indOff1['Moon'], equals([3, 5, 4, 6, 5, 0, 5, 3, 3, 4, 6, 5]));
    expect(indOff1['Mars'], equals([2, 3, 5, 3, 2, 3, 5, 1, 6, 4, 0, 5]));
    expect(indOff1['Mercury'], equals([4, 4, 7, 4, 4, 2, 5, 3, 7, 6, 4, 4]));
    expect(indOff1['Jupiter'], equals([5, 4, 6, 5, 6, 5, 3, 5, 2, 5, 5, 5]));
    expect(indOff1['Venus'], equals([4, 6, 6, 4, 4, 1, 5, 5, 5, 5, 4, 3]));
    expect(indOff1['Saturn'], equals([2, 5, 3, 4, 5, 2, 3, 3, 2, 3, 1, 6]));

    // 2. Test when Switch is ON (Uses Book Lagna Ashtakavarga rules)
    await SettingsService.saveIncludeLagnaAshtakavarga(true);
    final resOn1 = await KPService.calculateChart("User1", dt1, 13.0827, 80.2707, 5.5);
    final avOn1 = resOn1['ashtakavarga'];
    final indOn1 = (avOn1['individual'] as Map).cast<String, dynamic>();

    expect(avOn1['includeLagna'], isTrue);
    expect(indOn1.containsKey('Lagna'), isTrue);
    expect(indOn1.length, equals(8)); // 7 planets + Lagna
    expect(avOn1['total'], equals([25, 30, 34, 30, 29, 19, 28, 23, 30, 32, 22, 35]));
    expect(indOn1['Lagna'], equals([3, 5, 5, 4, 5, 1, 4, 5, 4, 5, 2, 6]));
    expect(indOn1['Moon'], equals([3, 5, 3, 6, 6, 0, 5, 3, 3, 5, 5, 5]));
    expect(indOn1['Venus'], equals([4, 6, 6, 4, 4, 2, 4, 5, 5, 5, 4, 3]));
    expect(indOn1['Saturn'], equals([2, 5, 3, 4, 5, 2, 3, 3, 2, 3, 1, 6]));

    // ── Chart 3: 01-12-2026 6:00 AM Chennai (Switch ON - user reference) ───
    final dt3 = DateTime(2026, 12, 1, 6, 0);
    await SettingsService.saveIncludeLagnaAshtakavarga(true);
    final resOn3 = await KPService.calculateChart("User3", dt3, 13.0827, 80.2707, 5.5);
    final avOn3 = resOn3['ashtakavarga'];
    expect(avOn3['total'], equals([22, 27, 41, 23, 35, 33, 21, 25, 25, 31, 27, 27]));
    expect(avOn3['individual']['Moon'], equals([5, 6, 5, 3, 7, 4, 3, 1, 3, 7, 4, 1]));

    // ── Chart 4: 01-01-2026 6:05 AM Tirupur (Switch ON - user reference) ────
    final dt4 = DateTime(2026, 1, 1, 6, 5);
    await SettingsService.saveIncludeLagnaAshtakavarga(true);
    final resOn4 = await KPService.calculateChart("User4", dt4, 11.1085, 77.3411, 5.5);
    final avOn4 = resOn4['ashtakavarga'];
    expect(avOn4['total'], equals([26, 31, 21, 27, 23, 32, 46, 21, 25, 28, 25, 32]));
    expect(avOn4['individual']['Moon'], equals([4, 5, 4, 5, 2, 6, 6, 1, 2, 4, 6, 4]));
  });
}
