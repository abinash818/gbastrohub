import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/gp_vaasthu_service.dart';
import 'package:astrology_flutter/services/vaasthu_one_page_pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'astrologer_name': 'Dr. Karunagaran',
      'astrologer_company': 'GB ASTRO வாஸ்து மையம்',
      'astrologer_phone': '9787067910',
      'astrologer_address': 'சென்னை, தமிழ்நாடு',
    });
  });

  test('Generate Vaasthu 1-Page PDF bytes', () async {
    final result = GpVaasthuService.calculateKuzhi(
      region: GpVaasthuRegion.madurai,
      l1Ft: 30,
      l1In: 0,
      w1Ft: 20,
      w1In: 0,
      ownerNakshatra: 1, // Ashwini
      ownerRasi: 1, // Mesham
    );

    final bytes = await VaasthuOnePagePdfService.generate(
      result: result,
      region: GpVaasthuRegion.madurai,
      ownerNakshatraIndex: 1,
      ownerRasiIndex: 1,
    );

    expect(bytes, isNotEmpty);
    expect(bytes.length, greaterThan(1000));
    print('Generated Vaasthu PDF size: ${bytes.length} bytes');
  });
}
