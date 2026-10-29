import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Local Horoscope & Prasannam Storage format test', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final horoscope = {
      'id': '1730000001',
      'name': 'முருகன்',
      'gender': 'male',
      'date': '1995-05-15T10:30:00.000',
      'place': 'சென்னை',
      'latitude': 13.0827,
      'longitude': 80.2707,
      'timezone': 5.5,
    };

    final prasannam = {
      'id': '1730000002',
      'name': 'கேள்வி 1',
      'date': '2026-10-28T19:00:00.000',
      'place': 'மதுரை',
      'lat': 9.9252,
      'lon': 78.1198,
      'tz': 5.5,
      'ayanamsa': 'KP New',
    };

    // Store in SharedPreferences
    await prefs.setStringList('saved_horoscopes', [jsonEncode(horoscope)]);
    await prefs.setStringList('saved_jamakkol_prasannams', [jsonEncode(prasannam)]);

    // Read back and verify
    final horoscopes = prefs.getStringList('saved_horoscopes')!;
    final prasannams = prefs.getStringList('saved_jamakkol_prasannams')!;

    expect(horoscopes.length, 1);
    expect(prasannams.length, 1);

    final decodedH = jsonDecode(horoscopes.first) as Map<String, dynamic>;
    final decodedP = jsonDecode(prasannams.first) as Map<String, dynamic>;

    expect(decodedH['name'], 'முருகன்');
    expect(decodedH['latitude'], 13.0827);

    expect(decodedP['name'], 'கேள்வி 1');
    expect(decodedP['lat'], 9.9252);
  });
}
