import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/maitra_dhanishta_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Abhijit Muhurtham Calculation Tests', () {
    test('Calculates 8th muhurtham (7/15 to 8/15 of daytime)', () {
      // 06:00:00 to 18:00:00 = 12 hours (720 mins). Each muhurtham is 48 mins.
      // 7 * 48 = 336 mins = 5h 36m after 6:00 => 11:36 AM.
      // 8 * 48 = 384 mins = 6h 24m after 6:00 => 12:24 PM.
      final date = DateTime(2026, 10, 17); // Saturday
      final sunrise = DateTime(2026, 10, 17, 6, 0);
      final sunset = DateTime(2026, 10, 17, 18, 0);

      final slot = MaitraDhanishtaService.calculateAbhijitMuhurthamForDate(date, sunrise, sunset);

      expect(slot.date, equals(date));
      expect(slot.startTime.hour, equals(11));
      expect(slot.startTime.minute, equals(36));
      expect(slot.endTime.hour, equals(12));
      expect(slot.endTime.minute, equals(24));
      expect(slot.isWednesday, isFalse);
      expect(slot.isAuspicious, isTrue);
      expect(slot.ratingText, contains('100% மகா உத்தம'));
      expect(slot.formattedTime, equals('11:36 AM - 12:24 PM'));
    });

    test('Wednesday is flagged as dosha / non-auspicious', () {
      final wednesday = DateTime(2026, 10, 14); // Wednesday
      final sunrise = DateTime(2026, 10, 14, 6, 0);
      final sunset = DateTime(2026, 10, 14, 18, 0);

      final slot = MaitraDhanishtaService.calculateAbhijitMuhurthamForDate(wednesday, sunrise, sunset);

      expect(slot.isWednesday, isTrue);
      expect(slot.isAuspicious, isFalse);
      expect(slot.ratingText, contains('புதன்கிழமை தோஷம்'));
    });

    test('JSON serialization / deserialization works correctly', () {
      final date = DateTime(2026, 10, 17);
      final sunrise = DateTime(2026, 10, 17, 6, 5);
      final sunset = DateTime(2026, 10, 17, 17, 55);

      final slot = MaitraDhanishtaService.calculateAbhijitMuhurthamForDate(date, sunrise, sunset);
      final json = slot.toJson();
      final fromJson = AbhijitMuhurthamSlot.fromJson(json);

      expect(fromJson.date, equals(slot.date));
      expect(fromJson.startTime, equals(slot.startTime));
      expect(fromJson.endTime, equals(slot.endTime));
      expect(fromJson.isWednesday, equals(slot.isWednesday));
      expect(fromJson.isAuspicious, equals(slot.isAuspicious));
      expect(fromJson.ratingText, equals(slot.ratingText));
    });
  });
}
