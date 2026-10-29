import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Save and retrieve Jamakkol Prasannam in SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final testPrasannam = {
      'id': '123456789',
      'name': 'மேற்கு திசை பார்த்த வீடு வாங்கலாமா',
      'date': DateTime(2026, 10, 28, 15, 21, 51).toIso8601String(),
      'place': 'Chennai (சென்னை)',
      'lat': 13.0827,
      'lon': 80.2707,
      'tz': 5.5,
      'arudam_idx': 3,
      'udayam': 'மீனம்',
      'arudam': 'மிதுனம்',
      'kavippu': 'கன்னி',
      'ayanamsa': 'Lahari 1940',
    };

    List<String> list = prefs.getStringList('saved_jamakkol_prasannams') ?? [];
    list.add(jsonEncode(testPrasannam));
    await prefs.setStringList('saved_jamakkol_prasannams', list);

    final retrieved = prefs.getStringList('saved_jamakkol_prasannams');
    expect(retrieved, isNotNull);
    expect(retrieved!.length, 1);

    final decoded = jsonDecode(retrieved.first) as Map<String, dynamic>;
    expect(decoded['name'], 'மேற்கு திசை பார்த்த வீடு வாங்கலாமா');
    expect(decoded['place'], 'Chennai (சென்னை)');
    expect(decoded['arudam_idx'], 3);
  });
}
