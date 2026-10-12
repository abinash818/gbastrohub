import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/astro_engine/astro_engine.dart';
import 'package:astrology_flutter/services/maitra_dhanishta_service.dart';

class MaitraMuhurthamSlot {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String nakshatra;
  final String lagna;
  final String weekday;
  final bool isTuesday;
  final String ratingText;

  MaitraMuhurthamSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.nakshatra,
    required this.lagna,
    required this.weekday,
    required this.isTuesday,
    required this.ratingText,
  });

  @override
  String toString() {
    return 'MaitraSlot: ${date.year}-${date.month}-${date.day} ($weekday) $nakshatra + $lagna from ${startTime.hour}:${startTime.minute} to ${endTime.hour}:${endTime.minute} [$ratingText]';
  }
}

List<MaitraMuhurthamSlot> findMaitraMuhurthamsFast(DateTime fromDate, double lat, double lon, int daysToScan) {
  final engine = AstroEngine();
  final List<MaitraMuhurthamSlot> results = [];
  const weekdaysTamil = ["ஞாயிறு", "திங்கள்", "செவ்வாய்", "புதன்", "வியாழன்", "வெள்ளி", "சனி"];

  for (int dayOffset = 0; dayOffset < daysToScan; dayOffset++) {
    final curDate = fromDate.add(Duration(days: dayOffset));
    final midnight = DateTime(curDate.year, curDate.month, curDate.day, 0, 0);
    final night = DateTime(curDate.year, curDate.month, curDate.day, 23, 59);

    final moon0 = engine.calculatePlanetLongitude(midnight, 1);
    final moon24 = engine.calculatePlanetLongitude(night, 1);
    final nak0 = (moon0 / (360.0 / 27.0)).floor() % 27;
    final nak24 = (moon24 / (360.0 / 27.0)).floor() % 27;

    bool mightHaveAshwini = (nak0 == 0 || nak24 == 0 || (nak0 == 26 && (nak24 == 0 || nak24 == 1)));
    bool mightHaveAnuradha = (nak0 == 16 || nak24 == 16 || (nak0 == 15 && nak24 >= 16));

    if (!mightHaveAshwini && !mightHaveAnuradha) continue;

    final lagna0 = engine.calculateLagna(midnight, lat, lon);

    List<int> targetRanges = [];
    if (mightHaveAshwini) {
      double diff = (15.0 - lagna0 + 360) % 360;
      int estMin = (diff * 4).round();
      for (int m = estMin - 80; m <= estMin + 80; m += 5) {
        int norm = (m + 1440) % 1440;
        if (!targetRanges.contains(norm)) targetRanges.add(norm);
      }
    }
    if (mightHaveAnuradha) {
      double diff = (225.0 - lagna0 + 360) % 360;
      int estMin = (diff * 4).round();
      for (int m = estMin - 80; m <= estMin + 80; m += 5) {
        int norm = (m + 1440) % 1440;
        if (!targetRanges.contains(norm)) targetRanges.add(norm);
      }
    }
    targetRanges.sort();

    DateTime? slotStart;
    DateTime? slotEnd;
    String activeNak = "";
    String activeLagna = "";

    for (int min in targetRanges) {
      final t = midnight.add(Duration(minutes: min));
      final lagnaDeg = engine.calculateLagna(t, lat, lon);
      final lagnaRasi = (lagnaDeg / 30.0).floor() % 12;
      final moonDeg = engine.calculatePlanetLongitude(t, 1);
      final moonNak = (moonDeg / (360.0 / 27.0)).floor() % 27;

      bool isMatch = false;
      String currentNakName = "";
      String currentLagnaName = "";

      if (lagnaRasi == 0 && moonNak == 0) {
        isMatch = true;
        currentNakName = "அஸ்வினி";
        currentLagnaName = "மேஷ லக்னம்";
      } else if (lagnaRasi == 7 && moonNak == 16) {
        isMatch = true;
        currentNakName = "அனுஷம்";
        currentLagnaName = "விருச்சிக லக்னம்";
      }

      if (isMatch) {
        if (slotStart == null) {
          slotStart = t;
          activeNak = currentNakName;
          activeLagna = currentLagnaName;
        }
        slotEnd = t.add(const Duration(minutes: 5));
      } else {
        if (slotStart != null && slotEnd != null) {
          int wkIdx = curDate.weekday == 7 ? 0 : curDate.weekday;
          bool isTue = wkIdx == 2;
          results.add(MaitraMuhurthamSlot(
            date: curDate,
            startTime: slotStart,
            endTime: slotEnd,
            nakshatra: activeNak,
            lagna: activeLagna,
            weekday: weekdaysTamil[wkIdx],
            isTuesday: isTue,
            ratingText: isTue ? "100% மகா உத்தமம்" : "75% உத்தமம்",
          ));
          slotStart = null;
          slotEnd = null;
        }
      }
    }

    if (slotStart != null && slotEnd != null) {
      int wkIdx = curDate.weekday == 7 ? 0 : curDate.weekday;
      bool isTue = wkIdx == 2;
      results.add(MaitraMuhurthamSlot(
        date: curDate,
        startTime: slotStart,
        endTime: slotEnd,
        nakshatra: activeNak,
        lagna: activeLagna,
        weekday: weekdaysTamil[wkIdx],
        isTuesday: isTue,
        ratingText: isTue ? "100% மகா உத்தமம்" : "75% உத்தமம்",
      ));
    }
  }

  return results;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test findMaitraMuhurthamsFast for next 60 days', () {
    final sw = Stopwatch()..start();
    final start = DateTime(2026, 10, 10);
    final slots = findMaitraMuhurthamsFast(start, 13.0827, 80.2707, 60);
    sw.stop();
    print("Found ${slots.length} upcoming slots in ${sw.elapsedMilliseconds} ms:");
    for (var s in slots) {
      print(s);
    }
    expect(slots.isNotEmpty, isTrue);
    expect(sw.elapsedMilliseconds < 500, isTrue); // Must take under 500ms!
  });

  test('Test getMonthMaitraMuhurthams and getMonthDhanishtaDays with Local Cache', () async {
    // 1st run: calculates and saves to cache
    final sw1 = Stopwatch()..start();
    final mSlots1 = await MaitraDhanishtaService.getMonthMaitraMuhurthams(2026, 10, 13.0827, 80.2707);
    final dSlots1 = await MaitraDhanishtaService.getMonthDhanishtaDays(2026, 10, 13.0827, 80.2707);
    sw1.stop();
    print("1st run (Calculate + Save Cache): Maitra ${mSlots1.length}, Dhanishta ${dSlots1.length} in ${sw1.elapsedMilliseconds} ms");

    expect(mSlots1.isNotEmpty, isTrue);
    expect(dSlots1.isNotEmpty, isTrue);

    // 2nd run: loads directly from cache in 0 ms!
    final sw2 = Stopwatch()..start();
    final mSlots2 = await MaitraDhanishtaService.getMonthMaitraMuhurthams(2026, 10, 13.0827, 80.2707);
    final dSlots2 = await MaitraDhanishtaService.getMonthDhanishtaDays(2026, 10, 13.0827, 80.2707);
    sw2.stop();
    print("2nd run (Read from Local Cache): in ${sw2.elapsedMilliseconds} ms (Instant 0ms!)");

    expect(mSlots2.length, equals(mSlots1.length));
    expect(dSlots2.length, equals(dSlots1.length));
    expect(sw2.elapsedMilliseconds <= 5, isTrue); // Instant retrieval!
  });
}
