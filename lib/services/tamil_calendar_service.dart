import 'astro_utils.dart';
import 'tamil_calendar_data.dart';

class TamilCalendarService {
  final Map<int, String> weekdayIndex = {
    0: 'F',
    1: 'Sa',
    2: 'Su',
    3: 'M',
    4: 'Tu',
    5: 'W',
    6: 'Th',
  };

  final Map<String, int> tamNyAnchorDateGreg = {
    "year": 2025,
    "month": 4,
    "day": 14,
  };

  Map<int, int> getMonthDays(int year) {
    // 1. Check for overrides first (Source of Truth from document)
    if (TAMIL_MONTH_OVERRIDES.containsKey(year)) {
      Map<int, int> monthDays = {};
      final overrides = TAMIL_MONTH_OVERRIDES[year]!;

      // Calculate month lengths from start dates
      for (int m = 1; m <= 11; m++) {
        if (overrides.containsKey(m) && overrides.containsKey(m + 1)) {
          // Get JDN for start of this month and next month
          // Months 1-9 are April-Dec, 10-12 are Jan-March of NEXT Gregorian year usually?
          // NO, the document format is: month index (1=Chithirai) -> day of THAT English Month/Year.
          // Let's look at document:
          // 1951: Chithirai(1) is 14/4, Vaikasi(2) is 15/5... Thai(10) is 14/1/1952.
          // So Month 1-9 are year X, Month 10-12 are year X+1.

          int currGMonth = (m + 3) > 12 ? (m + 3) - 12 : (m + 3);
          int currGYear = (m + 3) > 12 ? year + 1 : year;

          int nextM = m + 1;
          int nextGMonth = (nextM + 3) > 12 ? (nextM + 3) - 12 : (nextM + 3);
          int nextGYear = (nextM + 3) > 12 ? year + 1 : year;

          if (overrides.containsKey(m) && overrides.containsKey(m + 1)) {
            int jdn1 = getJDN(currGYear, currGMonth, overrides[m]!);
            int jdn2 = getJDN(nextGYear, nextGMonth, overrides[m + 1]!);
            monthDays[m] = jdn2 - jdn1;
          }
        }
      }

      // For month 12 (Panguni), we need Chithirai 1 of NEXT year
      if (monthDays.length == 11 &&
          TAMIL_MONTH_OVERRIDES.containsKey(year + 1)) {
        final nextOverrides = TAMIL_MONTH_OVERRIDES[year + 1]!;
        if (overrides.containsKey(12) && nextOverrides.containsKey(1)) {
          int jdn1 = getJDN(year + 1, 3, overrides[12]!);
          int jdn2 = getJDN(year + 1, 4, nextOverrides[1]!);
          monthDays[12] = jdn2 - jdn1;
        }
      }

      // If we successfully derived all 12 month lengths, return it
      if (monthDays.length == 12) {
        int total = monthDays.values.reduce((a, b) => a + b);
        return {0: total, ...monthDays};
      }
    }

    // 2. Fallback to calculation
    double cumulativeYearKaliDays = AstroUtils.getCumulativeKaliDays(year);

    Map<int, int> monthStartWDIndex = {};
    for (int month = 1; month <= 13; month++) {
      double foundationVal;
      if (month == 1) {
        foundationVal = cumulativeYearKaliDays;
      } else if (month == 13) {
        foundationVal = AstroUtils.getCumulativeKaliDays(year + 1);
      } else {
        foundationVal =
            cumulativeYearKaliDays + getYearBoundedDaysSunStyle(month);
      }
      monthStartWDIndex[month] = foundationVal.round() % 7;
    }

    Map<int, int> monthDays = {};
    for (int i = 1; i <= 12; i++) {
      int currWD = monthStartWDIndex[i]!;
      int nextWD = monthStartWDIndex[i + 1]!;
      int remDays = (nextWD - currWD + 7) % 7;
      monthDays[i] = 28 + remDays;
    }

    int totalYearDays = monthDays.values.reduce((a, b) => a + b);
    return {0: totalYearDays, ...monthDays};
  }

  double getYearBoundedDaysSunStyle(int month) {
    const monthLength = {
      2: {'day': 30, 'naaligai': 55, 'vinaaligai': 32},
      3: {'day': 62, 'naaligai': 19, 'vinaaligai': 44},
      4: {'day': 93, 'naaligai': 56, 'vinaaligai': 22},
      5: {'day': 125, 'naaligai': 24, 'vinaaligai': 34},
      6: {'day': 156, 'naaligai': 26, 'vinaaligai': 44},
      7: {'day': 186, 'naaligai': 54, 'vinaaligai': 6},
      8: {'day': 216, 'naaligai': 48, 'vinaaligai': 13},
      9: {'day': 246, 'naaligai': 18, 'vinaaligai': 37},
      10: {'day': 275, 'naaligai': 39, 'vinaaligai': 30},
      11: {'day': 305, 'naaligai': 6, 'vinaaligai': 46},
      12: {'day': 334, 'naaligai': 55, 'vinaaligai': 10},
    };
    if (month == 1) return 0;
    var m = monthLength[month]!;
    return m['day']!.toDouble() +
        (m['naaligai']! / 60.0) +
        (m['vinaaligai']! / 3600.0);
  }

  Map<String, dynamic>? engToTamDate(
    Map<String, dynamic> engDate, {
    DateTime? birthTime,
    DateTime? sunriseTime,
  }) {
    int gYear = engDate['year'];
    int gMonth = engDate['month'];
    int gDay = engDate['day'];

    int inputJDN = getJDN(gYear, gMonth, gDay);

    // Adjustment for Hindu/Tamil day starting at Sunrise
    if (birthTime != null && sunriseTime != null) {
      // Create comparison objects for the same day to compare only HH:mm
      final bMinutes = birthTime.hour * 60 + birthTime.minute;
      final sMinutes = sunriseTime.hour * 60 + sunriseTime.minute;

      if (bMinutes < sMinutes) {
        inputJDN -= 1;
      }
    }

    int anchorJDN = getJDN(
      tamNyAnchorDateGreg['year']!,
      tamNyAnchorDateGreg['month']!,
      tamNyAnchorDateGreg['day']!,
    );

    int jdnDaysDiff = inputJDN - anchorJDN;
    int yearsElapsed = 0;

    if (jdnDaysDiff < 0) {
      for (
        int year = tamNyAnchorDateGreg['year']! - 1;
        year >= gYear - 1;
        year--
      ) {
        var yearInfo = getMonthDays(year);
        jdnDaysDiff += yearInfo[0]!;
        yearsElapsed--;
        if (jdnDaysDiff >= 0) break;
      }
    } else {
      for (int year = tamNyAnchorDateGreg['year']!; year < gYear + 1; year++) {
        var yearInfo = getMonthDays(year);
        if (jdnDaysDiff >= yearInfo[0]!) {
          jdnDaysDiff -= yearInfo[0]!;
          yearsElapsed++;
        } else {
          break;
        }
      }
    }

    int remainingDays = jdnDaysDiff;
    int tamilYear = tamNyAnchorDateGreg['year']! + yearsElapsed;

    int exactYearDays = remainingDays;

    var monthLengths = getMonthDays(tamilYear);
    int tamilMonth = 1;
    for (int m = 1; m <= 12; m++) {
      int len = monthLengths[m]!;
      if (remainingDays >= len) {
        remainingDays -= len;
      } else {
        tamilMonth = m;
        break;
      }
    }
    int tamilDay = remainingDays + 1;

    int kaliYear = tamilYear + 3101;

    // Salivahana Shaka Year
    int salivahanaYear = kaliYear - 3179;

    // Kollam Year (Kerala/Kanyakumari Era)
    // Boundary at Chingam 1 (approx Aug 17)
    int kollamYear = (gMonth > 8 || (gMonth == 8 && gDay >= 17))
        ? gYear - 824
        : gYear - 825;

    // Hijri Year (Islamic Era) Approximation
    double hijriDecimal = (gYear - 621.57) * 1.0307;
    int hijriYear = hijriDecimal.floor();

    return {
      'year': tamilYear,
      'month': tamilMonth,
      'day': tamilDay,
      'kaliYear': kaliYear,
      'salivahanaYear': salivahanaYear,
      'kollamYear': kollamYear,
      'pasaliYear': (gMonth >= 7) ? gYear - 590 : gYear - 591,
      'hijriYear': hijriYear,
      'yearBoundedDays': remainingDays,
      'exactYearDays': exactYearDays,
    };
  }

  static int getJDN(int year, int month, int day) {
    int a = (14 - month) ~/ 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    int jdn =
        day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
    return jdn;
  }
}
