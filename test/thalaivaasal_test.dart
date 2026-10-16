import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/thalaivaasal_vaasthu_service.dart';

void main() {
  test('Thalaivaasal Calculation for 17 feet East-facing building', () {
    final result = ThalaivaasalVaasthuService.calculate(
      direction: VaasthuDirection.east,
      feet: 17.0,
      inches: 0.0,
    );

    expect(result.totalFeet, 17.0);
    expect(result.ucchaFeet, 8.5);
    expect(result.onePartFeet, closeTo(1.8888, 0.001));
    expect(result.uttamaStartFeet, closeTo(5.6666, 0.001));
    expect(result.uttamaEndFeet, closeTo(7.5555, 0.001));

    expect(result.startCornerShort, 'ஈசானியம்');
    expect(result.endCornerShort, 'அக்னி');

    final startStr = ThalaivaasalResult.toFeetAndInches(result.uttamaStartFeet);
    final endStr = ThalaivaasalResult.toFeetAndInches(result.uttamaEndFeet);

    expect(startStr, '5 அடி 8 அங்');
    expect(endStr, '7 அடி 7 அங்');
  });

  test('All 4 directions start and end corners', () {
    final east = ThalaivaasalVaasthuService.calculate(direction: VaasthuDirection.east, feet: 20, inches: 0);
    expect(east.startCornerShort, 'ஈசானியம்');
    expect(east.endCornerShort, 'அக்னி');

    final south = ThalaivaasalVaasthuService.calculate(direction: VaasthuDirection.south, feet: 20, inches: 0);
    expect(south.startCornerShort, 'அக்னி');
    expect(south.endCornerShort, 'கன்னி');

    final west = ThalaivaasalVaasthuService.calculate(direction: VaasthuDirection.west, feet: 20, inches: 0);
    expect(west.startCornerShort, 'வாயு');
    expect(west.endCornerShort, 'கன்னி');

    final north = ThalaivaasalVaasthuService.calculate(direction: VaasthuDirection.north, feet: 20, inches: 0);
    expect(north.startCornerShort, 'ஈசானியம்');
    expect(north.endCornerShort, 'வாயு');
  });
}
