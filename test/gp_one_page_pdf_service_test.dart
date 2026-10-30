import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/gp_one_page_pdf_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/astro_special_calculations_service.dart';

void main() {
  test('GbOnePagePdfService and extreme degrees calculation', () {
    expect(GbOnePagePdfService, isNotNull);

    final planetLons = {
      'Sun': 131.78,     // Simmam 11:47
      'Moon': 326.47,    // Kumbam 26:28
      'Mars': 293.08,    // Magaram 23:05
      'Mercury': 204.83, // Thulam 24:50
      'Jupiter': 119.77, // Kadagam 29:46
      'Venus': 213.37,   // Thulam 03:22
      'Saturn': 345.20,  // Meenam 15:12
      'Rahu': 301.97,    // Kumbam 01:58
      'Ketu': 121.97,    // Simmam 01:58
    };

    final extCalc = AstroSpecialCalculationsService.calculateExtremeDegreePlanets(planetLons);
    expect(extCalc['lowest']['planet'], equals('Ketu'));
    expect(extCalc['lowest']['planet_tamil'], equals('கேது'));
    expect(extCalc['lowest']['deg_formatted'], equals('01:58'));
    expect(extCalc['highest']['planet'], equals('Jupiter'));
    expect(extCalc['highest']['planet_tamil'], equals('குரு'));
    expect(extCalc['highest']['deg_formatted'], equals('29:46'));
  });
}
