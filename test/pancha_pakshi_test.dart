import 'package:flutter_test/flutter_test.dart';
import '../lib/services/astro_special_calculations_service.dart';

void main() {
  test('Pancha Pakshi Valarpirai vs Theypirai test', () {
    final now = DateTime(2026, 10, 20, 10, 0); // Tuesday
    final sunrise = DateTime(2026, 10, 20, 6, 0);

    // 1. Ashwini (idx 0)
    final ashwiniShukla = AstroSpecialCalculationsService.calculatePanchaPakshi(
      nakshatraIdx: 0,
      currentDt: now,
      sunrise: sunrise,
      isShuklaPaksha: true,
    );
    final ashwiniKrishna = AstroSpecialCalculationsService.calculatePanchaPakshi(
      nakshatraIdx: 0,
      currentDt: now,
      sunrise: sunrise,
      isShuklaPaksha: false,
    );

    print('Ashwini Shukla: ${ashwiniShukla['pakshi']}');
    print('Ashwini Krishna: ${ashwiniKrishna['pakshi']}');
    expect(ashwiniShukla['pakshi'], 'வல்லூறு');
    expect(ashwiniKrishna['pakshi'], 'மயில்');

    // 2. Revati (idx 26)
    final revatiShukla = AstroSpecialCalculationsService.calculatePanchaPakshi(
      nakshatraIdx: 26,
      currentDt: now,
      sunrise: sunrise,
      isShuklaPaksha: true,
    );
    final revatiKrishna = AstroSpecialCalculationsService.calculatePanchaPakshi(
      nakshatraIdx: 26,
      currentDt: now,
      sunrise: sunrise,
      isShuklaPaksha: false,
    );
    print('Revati Shukla: ${revatiShukla['pakshi']}');
    print('Revati Krishna: ${revatiKrishna['pakshi']}');
    expect(revatiShukla['pakshi'], 'மயில்');
    expect(revatiKrishna['pakshi'], 'வல்லூறு');

    // 3. Uthiram (idx 11)
    final uthiramShukla = AstroSpecialCalculationsService.calculatePanchaPakshi(
      nakshatraIdx: 11,
      currentDt: now,
      sunrise: sunrise,
      isShuklaPaksha: true,
    );
    final uthiramKrishna = AstroSpecialCalculationsService.calculatePanchaPakshi(
      nakshatraIdx: 11,
      currentDt: now,
      sunrise: sunrise,
      isShuklaPaksha: false,
    );
    print('Uthiram Shukla: ${uthiramShukla['pakshi']}');
    print('Uthiram Krishna: ${uthiramKrishna['pakshi']}');
    expect(uthiramShukla['pakshi'], 'காகம்');
    expect(uthiramKrishna['pakshi'], 'காகம்');
  });
}
