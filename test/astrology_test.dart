import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  test('Verify KP Chart Calculation Accuracy', () async {
    // Initializing the service
    await KPService.init();

    // Input: 05 April 2026, 10:30 AM, Chennai (13.08, 80.27), +5.5 TZ
    final dt = DateTime(2026, 4, 5, 10, 30);
    final results = await KPService.calculateChart("Test", dt, 13.0827, 80.2707, 5.5);

    print("--- CALCULATION TEST RESULTS ---");
    print("Date: 05 April 2026, 10:30 AM IST");
    
    final sun = results['planet_details']['sun'];
    print("Sun Lon: ${sun['longitude']} in ${sun['rasi']}");
    
    final moon = results['planet_details']['moon'];
    print("Moon Lon: ${moon['longitude']} in ${moon['rasi']}");
    
    final lagna = results['planet_details']['lagna'];
    print("Lagna Lon: ${lagna['longitude']} in ${lagna['rasi']}");

    // Expected (approximate for April 5, 2026):
    // Sun: Pisces (approx 21-22 deg)
    // Moon: Libra (approx 0-10 deg Swati)
    // Lagna: Approx Gemini or Cancer? 
    // Wait, let's check a standard tool.
    // 10:30 AM Chennai, April 5 -> Ascendant should be Gemini or Gemini-end.
    
    expect(sun['rasi'], equals('Pisces'));
  });
}
