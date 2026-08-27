import 'dart:math';

class AstroUtils {
  static double getCumulativeKaliDays(int gregorianYear) {
    // Exact Vakya Karana formula used in Python
    return ((210389 * gregorianYear) + 652415052) / 576.0;
  }

  static Map<String, double> getMeshaSankranti(int kaliYear) {
    // Standard Vakya expansion
    double days1 = kaliYear * 365.0;
    
    int q2 = kaliYear ~/ 4;
    int r2 = kaliYear % 4;
    double days2 = q2.toDouble();
    double naligai2 = r2 * 15.0;
    
    // Using -1237 as per user source
    double val3 = (kaliYear * 5.0 - 1237.0) / 576.0;
    int days3 = val3.floor();
    double naligai3 = (val3 - days3) * 60.0;
    
    double totalDays = days1 + days2 + days3;
    double totalNaligai = naligai2 + naligai3;
    
    // For foundation purposes, we need the rounded total days to determine the weekday start
    double cumulativeFloat = totalDays + (totalNaligai / 60.0);
    double roundedDays = cumulativeFloat.roundToDouble();
    
    return {'days': roundedDays, 'naligai': 0.0}; // Returning rounded days as foundation
  }

  static double getCumulativeKaliDaysFromSankranti(int gregorianYear) {
    // Traditional Kali Year: 1 AD is 3102 Kali. 2026 AD is 5127 Kali.
    int kaliYear = gregorianYear + 3101;
    var sankranti = getMeshaSankranti(kaliYear);
    return sankranti['days']! + (sankranti['naligai']! / 60.0);
  }

  static double pythonRound(double value) {
    double floorVal = value.floorToDouble();
    double frac = value - floorVal;
    
    // Near-integer check for precision
    if (frac.abs() < 1e-12) return floorVal;
    if ((1.0 - frac).abs() < 1e-12) return floorVal + 1;

    if (frac < 0.5) return floorVal;
    if (frac > 0.5) return floorVal + 1;
    // frac == 0.5: round to nearest even
    if (floorVal.toInt() % 2 == 0) return floorVal;
    return floorVal + 1;
  }

  static double pmod(double a, double n) {
    return ((a % n) + n) % n;
  }

  static double dmsToDecimalDegrees(double degrees, double minutes, double seconds) {
    return degrees + (minutes / 60.0) + (seconds / 3600.0);
  }

  static double arcSecondsToDecimalDegrees(double arcSeconds) {
    return arcSeconds / 3600.0;
  }

  static double arcMinutesToDecimalDegrees(double arcMinutes) {
    return arcMinutes / 60.0;
  }

  static double monthLengthToDays(Map<String, double> monthLength) {
    double day = monthLength['day']!;
    double naaligai = monthLength['naaligai']!;
    double vinaaligai = monthLength['vinaaligai'] ?? 0;
    return day + (naaligai / 60.0) + (vinaaligai / 3600.0);
  }

  static List<num> toDMS(double decimalDegrees) {
    int degrees = decimalDegrees.toInt();
    double reminder = (decimalDegrees - degrees) * 60;
    int arcMinutes = reminder.toInt();
    double arcSeconds = (reminder - arcMinutes) * 60;
    return [degrees, arcMinutes, arcSeconds];
  }

  static Map<String, dynamic> getCurrentDT() {
    final now = DateTime.now();
    return {
      'year': now.year,
      'month': now.month,
      'day': now.day,
      'hour': now.hour,
      'minute': now.minute
    };
  }

  static double getUjjainOffsetTime(int hour, int minute) {
    const double istToUjjainDiffTimeMinutes = 26.92;
    double istTimeMinutes = (hour * 60.0) + minute;
    double lmtUjjainConvertedMinutes = istTimeMinutes - istToUjjainDiffTimeMinutes;
    double lmtUjjainConvertedOffsetMinutes = lmtUjjainConvertedMinutes - 360; // 360 = 6 hours
    return lmtUjjainConvertedOffsetMinutes / 1440.0;
  }
}

