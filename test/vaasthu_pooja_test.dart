import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/vaasthu_pooja_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Vaasthu Pooja Time calculation for Namakkal on Aippasi 11 (28-10-2026)', () {
    final rule = VaasthuPoojaService.vaasthuRules.firstWhere((r) => r.tamilMonth == 'ஐப்பசி');
    expect(rule.tamilDate, 11);
    expect(rule.dhruvaHours, 2);
    expect(rule.dhruvaMinutes, 0);

    final item = VaasthuPoojaService.calculateItem(
      rule: rule,
      date: DateTime(2026, 10, 28),
      sunriseStr: '6:08:26 AM',
    );

    expect(item.startTimeStr, '8:08:26 AM');
    expect(item.endTimeStr, '8:26:26 AM');
    expect(item.poojaWindowStr, '8:08:26 AM முதல் 8:26:26 AM வரை');
  });

  test('All 8 Vaasthu days generated with proper Dhruva values', () {
    final list = VaasthuPoojaService.generateYearTable(year: 2026);
    expect(list.length, 8);

    // Chithirai 10 (+3.12)
    final chithirai = list.firstWhere((e) => e.rule.tamilMonth == 'சித்திரை');
    expect(chithirai.rule.dhruvaDisplay, '+ 3.12');

    // Aavani 6 (+9.36)
    final aavani = list.firstWhere((e) => e.rule.tamilMonth == 'ஆவணி');
    expect(aavani.rule.dhruvaDisplay, '+ 9.36');

    // Thai 12 (+4.24)
    final thai = list.firstWhere((e) => e.rule.tamilMonth == 'தை');
    expect(thai.rule.dhruvaDisplay, '+ 4.24');
  });

  test('Location change dynamically updates sunrise and pooja times', () async {
    // 1. Namakkal baseline
    final namakkalList = VaasthuPoojaService.generateYearTable(year: 2026, cityName: 'நாமக்கல்');
    final nAippasi = namakkalList.firstWhere((e) => e.rule.tamilMonth == 'ஐப்பசி');

    // 2. Trichy (further East than Namakkal)
    final trichyList = VaasthuPoojaService.generateYearTable(year: 2026, cityName: 'திருச்சி');
    final tAippasi = trichyList.firstWhere((e) => e.rule.tamilMonth == 'ஐப்பசி');

    // Sunrise should be different and earlier in Trichy
    expect(nAippasi.sunriseStr != tAippasi.sunriseStr, true);
    expect(nAippasi.startTimeStr != tAippasi.startTimeStr, true);
    print('Namakkal Aippasi 11: Sunrise=${nAippasi.sunriseStr}, Pooja=${nAippasi.startTimeStr}');
    print('Trichy Aippasi 11: Sunrise=${tAippasi.sunriseStr}, Pooja=${tAippasi.startTimeStr}');

    // 3. Test generateYearTableAsync with AstroEngine for Trichy
    final asyncTrichy = await VaasthuPoojaService.generateYearTableAsync(
      year: 2026,
      cityName: 'திருச்சி',
      lat: 10.7905,
      lon: 78.7047,
    );
    final aAippasi = asyncTrichy.firstWhere((e) => e.rule.tamilMonth == 'ஐப்பசி');
    print('Async Trichy Aippasi 11: Sunrise=${aAippasi.sunriseStr}, Pooja=${aAippasi.startTimeStr}');
    expect(aAippasi.sunriseStr.isNotEmpty, true);
    expect(aAippasi.startTimeStr.isNotEmpty, true);
  });
}

