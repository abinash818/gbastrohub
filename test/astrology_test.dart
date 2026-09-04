import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
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

  test('Calculate & Print Ashtakavarga for Ref DOB 01-01-2026 06:05 AM Tirupur', () async {
    await KPService.init();
    final dt = DateTime(2026, 1, 1, 6, 5);
    final results = await KPService.calculateChart("Jan1Test", dt, 11.1085, 77.3411, 5.5);
    
    print("\n=======================================================");
    print("CHARTS & ASHTAKAVARGA FOR: 01-01-2026, 06:05 AM, TIRUPUR");
    print("=======================================================");
    
    final pDetails = results['planet_details'] as Map<String, dynamic>;
    pDetails.forEach((k, v) {
      print("${k.toUpperCase()}: ${v['rasi']} (${v['longitude'].toStringAsFixed(2)}°)");
    });
    
    final Map<String, double> planetLons = {};
    pDetails.forEach((k, v) {
      String pKey = k[0].toUpperCase() + k.substring(1);
      planetLons[pKey] = v['longitude'];
    });
    double lagnaLon = pDetails['lagna']['longitude'];

    final av = KPService.calculateAshtakavargaMap(planetLons, lagnaLon);
    print("\n--- SARVASHTAKAVARGA (337 Points) ---");
    print("Sarva Total: ${av['total']} => Sum: ${(av['total'] as List<int>).reduce((a, b) => a + b)}");
    
    final List<String> signNames = ["மேஷ", "ரிஷ", "மிது", "கட", "சிம்", "கன்", "துலா", "விரு", "தனு", "மக", "கும்", "மீன"];
    print("\nSign-wise Sarvashtakavarga:");
    for (int i = 0; i < 12; i++) {
      print("  ${signNames[i]} (${KPService.SIGNS[i]}): ${av['total'][i]}");
    }

    print("\n--- INDIVIDUAL BAVs ---");
    (av['individual'] as Map<String, dynamic>).forEach((p, pts) {
      print("  $p: $pts (Sum: ${(pts as List<int>).reduce((a, b) => a + b)})");
    });
    print("=======================================================\n");
  });

  test('Calculate & Print Ashtakavarga for Ref DOB 01-12-2026 06:00 AM Chennai', () async {
    await KPService.init();
    final dt = DateTime(2026, 12, 1, 6, 0);
    final results = await KPService.calculateChart("Dec1Test", dt, 13.0827, 80.2707, 5.5);
    
    print("\n=======================================================");
    print("CHARTS & ASHTAKAVARGA FOR: 01-12-2026, 06:00 AM, CHENNAI");
    print("=======================================================");
    
    final pDetails = results['planet_details'] as Map<String, dynamic>;
    pDetails.forEach((k, v) {
      print("${k.toUpperCase()}: ${v['rasi']} (${v['longitude'].toStringAsFixed(2)}°)");
    });
    
    final Map<String, double> planetLons = {};
    pDetails.forEach((k, v) {
      String pKey = k[0].toUpperCase() + k.substring(1);
      planetLons[pKey] = v['longitude'];
    });
    double lagnaLon = pDetails['lagna']['longitude'];

    final av = KPService.calculateAshtakavargaMap(planetLons, lagnaLon);
    print("\n--- SARVASHTAKAVARGA (337 Points) ---");
    print("Sarva Total: ${av['total']} => Sum: ${(av['total'] as List<int>).reduce((a, b) => a + b)}");
    
    final List<String> signNames = ["மேஷ", "ரிஷ", "மிது", "கட", "சிம்", "கன்", "துலா", "விரு", "தனு", "மக", "கும்", "மீன"];
    print("\nSign-wise Sarvashtakavarga:");
    for (int i = 0; i < 12; i++) {
      print("  ${signNames[i]} (${KPService.SIGNS[i]}): ${av['total'][i]}");
    }

    print("\n--- INDIVIDUAL BAVs ---");
    (av['individual'] as Map<String, dynamic>).forEach((p, pts) {
      print("  $p: $pts (Sum: ${(pts as List<int>).reduce((a, b) => a + b)})");
    });
    print("=======================================================\n");
  });

  test('Calculate & Print Ashtakavarga for Ref DOB 14-04-2026 5:59 PM Tirupur', () async {
    await KPService.init();
    final dt = DateTime(2026, 4, 14, 17, 59);
    // Tirupur: Lat 11.1085, Lon 77.3411
    final results = await KPService.calculateChart("TirupurTest", dt, 11.1085, 77.3411, 5.5);
    
    print("\n=======================================================");
    print("CHARTS & ASHTAKAVARGA FOR: 14-04-2026, 5:59 PM, TIRUPUR");
    print("=======================================================");
    
    final pDetails = results['planet_details'] as Map<String, dynamic>;
    pDetails.forEach((k, v) {
      print("${k.toUpperCase()}: ${v['rasi']} (${v['longitude'].toStringAsFixed(2)}°)");
    });
    
    final Map<String, double> planetLons = {};
    pDetails.forEach((k, v) {
      String pKey = k[0].toUpperCase() + k.substring(1);
      planetLons[pKey] = v['longitude'];
    });
    double lagnaLon = pDetails['lagna']['longitude'];

    final av = KPService.calculateAshtakavargaMap(planetLons, lagnaLon);
    print("\n--- SARVASHTAKAVARGA (337 Points) ---");
    print("Sarva Total: ${av['total']} => Sum: ${(av['total'] as List<int>).reduce((a, b) => a + b)}");
    
    final List<String> signNames = ["மேஷ", "ரிஷ", "மிது", "கட", "சிம்", "கன்", "துலா", "விரு", "தனு", "மக", "கும்", "மீன"];
    print("\nSign-wise Sarvashtakavarga:");
    for (int i = 0; i < 12; i++) {
      print("  ${signNames[i]} (${KPService.SIGNS[i]}): ${av['total'][i]}");
    }

    print("\n--- INDIVIDUAL BAVs ---");
    (av['individual'] as Map<String, dynamic>).forEach((p, pts) {
      print("  $p: $pts (Sum: ${(pts as List<int>).reduce((a, b) => a + b)})");
    });
    print("=======================================================\n");
  });

  test('Calculate & Print Ashtakavarga for Ref DOB 03-09-2026 10:30 AM Chennai', () async {
    await KPService.init();
    final dt = DateTime(2026, 9, 3, 10, 30);
    final results = await KPService.calculateChart("RefTest", dt, 13.0827, 80.2707, 5.5);
    
    print("\n=======================================================");
    print("CHARTS & ASHTAKAVARGA FOR: 03-09-2026, 10:30 AM, CHENNAI");
    print("=======================================================");
    
    final pDetails = results['planet_details'] as Map<String, dynamic>;
    pDetails.forEach((k, v) {
      print("${k.toUpperCase()}: ${v['rasi']} (${v['longitude'].toStringAsFixed(2)}°)");
    });
    
    final Map<String, double> planetLons = {};
    pDetails.forEach((k, v) {
      String pKey = k[0].toUpperCase() + k.substring(1);
      planetLons[pKey] = v['longitude'];
    });
    double lagnaLon = pDetails['lagna']['longitude'];

    final av = KPService.calculateAshtakavargaMap(planetLons, lagnaLon);
    print("\n--- SARVASHTAKAVARGA (337 Points) ---");
    print("Sarva Total: ${av['total']} => Sum: ${(av['total'] as List<int>).reduce((a, b) => a + b)}");
    
    final List<String> signNames = ["மேஷ", "ரிஷ", "மிது", "கட", "சிம்", "கன்", "துலா", "விரு", "தனு", "மக", "கும்", "மீன"];
    print("\nSign-wise Sarvashtakavarga:");
    for (int i = 0; i < 12; i++) {
      print("  ${signNames[i]} (${KPService.SIGNS[i]}): ${av['total'][i]}");
    }

    print("\n--- INDIVIDUAL BAVs ---");
    (av['individual'] as Map<String, dynamic>).forEach((p, pts) {
      print("  $p: $pts (Sum: ${(pts as List<int>).reduce((a, b) => a + b)})");
    });
    
    print("\n--- DETAIL CONTRIBUTORS FOR MOON & LAGNA ---");
    Map<String, int> planetPositions = {}; 
    planetLons.forEach((name, lon) { planetPositions[name] = (lon / 30).floor() % 12; });
    planetPositions['Lagna'] = (lagnaLon / 30).floor() % 12;
    
    // Moon
    print("\nMoon Contributor Points (Signs: Ar, Ta, Ge, Ca, Le, Vi, Li, Sc, Sa, Cp, Aq, Pi):");
    final mRules = {
      'Sun': [3,6,7,8,10,11], 'Moon': [1,3,6,7,10,11], 'Mars': [2,3,5,6,9,10,11], 
      'Mercury': [1,3,4,5,7,8,10,11], 'Jupiter': [1,4,7,8,10,11,12], 
      'Venus': [3,4,5,7,9,10,11], 'Saturn': [3,5,6,11], 'Lagna': [3,6,10,11]
    };
    mRules.forEach((refP, houses) {
      int refPos = planetPositions[refP]!;
      List<int> pts = List.filled(12, 0);
      for (int h in houses) pts[(refPos + h - 1) % 12] = 1;
      print("  From $refP (Pos: ${KPService.SIGNS[refPos]}): $pts");
    });

    // Lagna
    print("\nLagna Contributor Points:");
    final lRules = {
      'Sun': [3,4,6,10,11,12], 'Moon': [3,6,10,11], 'Mars': [1,3,6,10,11], 
      'Mercury': [1,2,4,6,8,10,11], 'Jupiter': [1,2,4,5,6,7,9,10,11], 
      'Venus': [1,2,3,4,5,8,9,11], 'Saturn': [1,3,4,6,10,11], 'Lagna': [3,6,10,11]
    };
    lRules.forEach((refP, houses) {
      int refPos = planetPositions[refP]!;
      List<int> pts = List.filled(12, 0);
      for (int h in houses) pts[(refPos + h - 1) % 12] = 1;
      print("  From $refP (Pos: ${KPService.SIGNS[refPos]}): $pts");
    });
    print("=======================================================\n");
  });

  test('Verify Ashtakavarga 337 points Sarva and 49 points Lagna calculation', () async {
    Map<String, double> planetLons = {
      'Sun': 350.0,
      'Moon': 190.0,
      'Mars': 280.0,
      'Mercury': 340.0,
      'Jupiter': 45.0,
      'Venus': 320.0,
      'Saturn': 310.0,
    };
    double lagnaLon = 75.0;

    final av = KPService.calculateAshtakavargaMap(planetLons, lagnaLon);
    final ind = av['individual'] as Map<String, dynamic>;
    expect(ind['Sun'].fold(0, (a, b) => a + b), equals(48));
    expect(ind['Moon'].fold(0, (a, b) => a + b), equals(49));
    expect(ind['Mars'].fold(0, (a, b) => a + b), equals(39));
    expect(ind['Mercury'].fold(0, (a, b) => a + b), equals(54));
    expect(ind['Jupiter'].fold(0, (a, b) => a + b), equals(56));
    expect(ind['Venus'].fold(0, (a, b) => a + b), equals(52));
    expect(ind['Saturn'].fold(0, (a, b) => a + b), equals(39));
    expect(ind['Lagna'].fold(0, (a, b) => a + b), equals(49));

    // Sarvashtakavarga total must always be the 337 points of the 7 classical planets
    final List<int> total = av['total'];
    int sum = total.fold(0, (a, b) => a + b);
    expect(sum, equals(337));
    expect(av['individual'].containsKey('Lagna'), isTrue);
  });

  test('Verify Vimshottari Dasa & Bhukti elapsed offset and active Bhukti at birth', () async {
    await KPService.init();

    // Chart: 03-09-2026, 15:16 IST.
    // Moon in Taurus at 04°33' (Longitude = 30° + 4.55° = 34.55°)
    // Krittika nakshatra (Sun Dasa = 6 years)
    final birthDt = DateTime(2026, 9, 3, 15, 16);
    final results = await KPService.calculateChart("DasaTest", birthDt, 13.0827, 80.2707, 5.5);

    final dasaList = results['dasa'] as List<dynamic>;
    expect(dasaList.length, equals(9));

    final firstDasa = dasaList[0];
    expect(firstDasa['lord'], equals('Sun'));
    expect(firstDasa['start'], equals(birthDt));

    // Full start must be before birth date by the elapsed time
    final DateTime fullStart = firstDasa['fullStart'];
    expect(fullStart.isBefore(birthDt), isTrue);

    // End of Sun Dasa should be around Feb 2029 (~2.45 years from birth)
    final DateTime firstEnd = firstDasa['end'];
    expect(firstEnd.year, equals(2029));
    expect(firstEnd.month, equals(2));

    // Check Subperiods (Bhuktis) of Sun Dasa from birth
    final bhuktis = firstDasa['subPeriods'] as List<dynamic>;
    expect(bhuktis.length, equals(4)); // Surviving Bhuktis from birth: Saturn, Mercury, Ketu, Venus
    expect(bhuktis[0]['lord'], equals('Saturn'));
    expect(bhuktis[1]['lord'], equals('Mercury'));
    expect(bhuktis[2]['lord'], equals('Ketu'));
    expect(bhuktis[3]['lord'], equals('Venus'));

    // The first active Bhukti must start on birth date and the last Bhukti must end at firstEnd
    expect(bhuktis[0]['start'], equals(birthDt));
    expect(bhuktis[3]['end'], equals(firstEnd));

    // At birth date (03-09-2026), the active Bhukti is Saturn!
    expect(bhuktis[0]['lord'], equals('Saturn'));

    // Check 2nd Dasa is Moon for 10 years
    final secondDasa = dasaList[1];
    expect(secondDasa['lord'], equals('Moon'));
    expect(secondDasa['start'], equals(firstEnd));
    expect(secondDasa['end'].year, equals(firstEnd.year + 10));
  });
}
