import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Verify Dasa for Namakkal 05-09-2026 20:09:20', () async {
    await KPService.init();

    final dt = DateTime(2026, 9, 5, 20, 9, 20);
    // Namakkal coordinates: 11.2189 N, 78.1674 E
    final results = await KPService.calculateChart(
      'NamakkalTest',
      dt,
      11.2189,
      78.1674,
      5.5,
      yearLength: 365.25,
      siderealModeIndex: 0, // Lahiri (Thirukanitha)
    );

    print('\n=======================================================');
    print('NAMAKKAL TEST RESULTS FOR 05-09-2026 20:09:20');
    print('=======================================================');

    final moon = results['planet_details']['moon'];
    print('Moon Rasi: ${moon['rasi']}');
    print('Moon Deg: ${moon['longitude']} (DMS: ${KPService.formatAbsoluteDegreesDMS(moon['longitude'])})');
    print('Moon Nakshatra: ${moon['nakshatra']} Padam: ${moon['pada']}');

    print('\nDasa Balance from KPService:');
    print('Lord: ${results['dasa_balance_lord']}');
    print('Dasa Balance: ${results['dasa_balance']}');
    print('Dasa Balance Tamil: ${results['dasa_balance_tamil']}');
    print('Dasa Balance (Y: ${results['dasa_balance_y']}, M: ${results['dasa_balance_m']}, D: ${results['dasa_balance_d']})');

    final dasaList = results['dasa'] as List<dynamic>;
    final firstDasa = dasaList[0];
    print('First Dasa Map: lord=${firstDasa['lord']}, balanceStr=${firstDasa['balanceStr']}');

    final pancha = results['panchangam'];
    print('\nPanchangam:');
    print('Tamil Year: ${pancha['tamil_year']}');
    print('Tamil Month: ${pancha['tamil_month']} ${pancha['tamil_date']}');
    print('Vara: ${pancha['vara']}');
    print('Tithi: ${pancha['tithi']}');
    print('Nakshatra: ${pancha['nakshatra']}');
    print('Yoga: ${pancha['yoga']}');
    print('Karana: ${pancha['karana']}');
    print('Paksha: ${pancha['paksha']}');
    print('Sunrise: ${pancha['sunrise']}');
    print('Sunset: ${pancha['sunset']}');
  });
}
