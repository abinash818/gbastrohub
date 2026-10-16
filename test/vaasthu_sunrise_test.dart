import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Find all 8 Vaasthu dates for 2026', () async {
    await KPService.init();

    final targets = [
      {'name': 'தை', 'date': 12, 'approx': DateTime(2026, 1, 26), 'dhruvaH': 4, 'dhruvaM': 24},
      {'name': 'மாசி', 'date': 22, 'approx': DateTime(2026, 3, 6), 'dhruvaH': 4, 'dhruvaM': 24},
      {'name': 'சித்திரை', 'date': 10, 'approx': DateTime(2026, 4, 23), 'dhruvaH': 3, 'dhruvaM': 12},
      {'name': 'வைகாசி', 'date': 21, 'approx': DateTime(2026, 6, 4), 'dhruvaH': 4, 'dhruvaM': 24},
      {'name': 'ஆடி', 'date': 11, 'approx': DateTime(2026, 7, 27), 'dhruvaH': 2, 'dhruvaM': 0},
      {'name': 'ஆவணி', 'date': 6, 'approx': DateTime(2026, 8, 22), 'dhruvaH': 9, 'dhruvaM': 36},
      {'name': 'ஐப்பசி', 'date': 11, 'approx': DateTime(2026, 10, 28), 'dhruvaH': 2, 'dhruvaM': 0},
      {'name': 'கார்த்திகை', 'date': 8, 'approx': DateTime(2026, 11, 24), 'dhruvaH': 5, 'dhruvaM': 12},
    ];

    print('\n=======================================================');
    print('ALL 8 VAASTHU DAYS FOR NAMAKKAL IN 2026:');
    print('=======================================================');

    for (var t in targets) {
      DateTime approx = t['approx'] as DateTime;
      DateTime? exactDate;
      String? sunriseStr;

      for (int offset = -2; offset <= 2; offset++) {
        final d = approx.add(Duration(days: offset));
        final res = await KPService.calculateChart('V', d, 11.2189, 78.1674, 5.5, yearLength: 365.25, siderealModeIndex: 0);
        final pancha = res['panchangam'];
        if (pancha['tamil_month'] == t['name'] && pancha['tamil_date'] == t['date']) {
          exactDate = d;
          sunriseStr = pancha['sunrise'];
          break;
        }
      }

      print('Target: ${t['name']} ${t['date']} -> Found Date: ${exactDate?.toIso8601String().substring(0, 10)}, Sunrise: $sunriseStr');
    }
  });
}
