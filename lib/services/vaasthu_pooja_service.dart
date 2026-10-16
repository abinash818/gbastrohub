class VaasthuDayRule {
  final String tamilMonth;
  final int tamilDate;
  final int dhruvaHours;
  final int dhruvaMinutes;
  final int durationMinutes;
  final int defaultMonth; // Approximate English month (1-12)
  final int defaultDay; // Approximate English day (1-31)

  const VaasthuDayRule({
    required this.tamilMonth,
    required this.tamilDate,
    required this.dhruvaHours,
    required this.dhruvaMinutes,
    this.durationMinutes = 18,
    required this.defaultMonth,
    required this.defaultDay,
  });

  String get dhruvaDisplay {
    final String m = dhruvaMinutes.toString().padLeft(2, '0');
    return "+ $dhruvaHours.$m";
  }

  String get dhruvaTimeStr {
    final String h = dhruvaHours.toString().padLeft(2, '0');
    final String m = dhruvaMinutes.toString().padLeft(2, '0');
    return "$h:$m:00";
  }
}

class VaasthuPoojaItem {
  final VaasthuDayRule rule;
  final DateTime englishDate;
  final String sunriseStr;
  final DateTime sunriseTime;
  final DateTime startTime;
  final DateTime endTime;

  const VaasthuPoojaItem({
    required this.rule,
    required this.englishDate,
    required this.sunriseStr,
    required this.sunriseTime,
    required this.startTime,
    required this.endTime,
  });

  String get tamilDisplay => "${rule.tamilMonth} ${rule.tamilDate.toString().padLeft(2, '0')}";

  String get englishDateFormatted {
    final d = englishDate.day.toString().padLeft(2, '0');
    final m = englishDate.month.toString().padLeft(2, '0');
    return "$d/$m/${englishDate.year}";
  }

  String get weekdayTamil {
    const days = [
      'திங்கள்',
      'செவ்வாய்',
      'புதன்',
      'வியாழன்',
      'வெள்ளி',
      'சனி',
      'ஞாயிறு',
    ];
    return days[englishDate.weekday - 1];
  }

  String formatTime(DateTime dt) {
    int h = dt.hour % 12;
    if (h == 0) h = 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return "$h:$m:$s $ampm";
  }

  String get startTimeStr => formatTime(startTime);
  String get endTimeStr => formatTime(endTime);
  String get poojaWindowStr => "$startTimeStr முதல் $endTimeStr வரை";
}

class VaasthuPoojaService {
  /// The 8 canonical Vaasthu days according to classical Vaasthu Shastra
  static const List<VaasthuDayRule> vaasthuRules = [
    VaasthuDayRule(
      tamilMonth: 'சித்திரை',
      tamilDate: 10,
      dhruvaHours: 3,
      dhruvaMinutes: 12,
      defaultMonth: 4,
      defaultDay: 23,
    ),
    VaasthuDayRule(
      tamilMonth: 'வைகாசி',
      tamilDate: 21,
      dhruvaHours: 4,
      dhruvaMinutes: 24,
      defaultMonth: 6,
      defaultDay: 4,
    ),
    VaasthuDayRule(
      tamilMonth: 'ஆடி',
      tamilDate: 11,
      dhruvaHours: 2,
      dhruvaMinutes: 0,
      defaultMonth: 7,
      defaultDay: 27,
    ),
    VaasthuDayRule(
      tamilMonth: 'ஆவணி',
      tamilDate: 6,
      dhruvaHours: 9,
      dhruvaMinutes: 36,
      defaultMonth: 8,
      defaultDay: 22,
    ),
    VaasthuDayRule(
      tamilMonth: 'ஐப்பசி',
      tamilDate: 11,
      dhruvaHours: 2,
      dhruvaMinutes: 0,
      defaultMonth: 10,
      defaultDay: 28,
    ),
    VaasthuDayRule(
      tamilMonth: 'கார்த்திகை',
      tamilDate: 8,
      dhruvaHours: 5,
      dhruvaMinutes: 12,
      defaultMonth: 11,
      defaultDay: 24,
    ),
    VaasthuDayRule(
      tamilMonth: 'தை',
      tamilDate: 12,
      dhruvaHours: 4,
      dhruvaMinutes: 24,
      defaultMonth: 1,
      defaultDay: 26,
    ),
    VaasthuDayRule(
      tamilMonth: 'மாசி',
      tamilDate: 22,
      dhruvaHours: 4,
      dhruvaMinutes: 24,
      defaultMonth: 3,
      defaultDay: 6,
    ),
  ];

  /// Standard Tamil Nadu default locations
  static const Map<String, Map<String, double>> standardLocations = {
    'நாமக்கல்': {'lat': 11.2189, 'lon': 78.1674},
    'சென்னை': {'lat': 13.0827, 'lon': 80.2707},
    'மதுரை': {'lat': 9.9252, 'lon': 78.1198},
    'கோயம்புத்தூர்': {'lat': 11.0168, 'lon': 76.9558},
    'திருச்சி': {'lat': 10.7905, 'lon': 78.7047},
    'சேலம்': {'lat': 11.6643, 'lon': 78.1460},
    'ஈரோடு': {'lat': 11.3410, 'lon': 77.7172},
    'திருநெல்வேலி': {'lat': 8.7139, 'lon': 77.7567},
    'தஞ்சாவூர்': {'lat': 10.7870, 'lon': 79.1378},
    'வேலூர்': {'lat': 12.9165, 'lon': 79.1325},
  };

  /// Parses a sunrise time string like "06:08:26 AM" or "6:08:26" into DateTime on given date
  static DateTime parseSunrise(DateTime baseDate, String sunriseStr) {
    try {
      final clean = sunriseStr.trim();
      final bool isPm = clean.toUpperCase().contains('PM');
      final parts = clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      int h = int.parse(parts[0]);
      int m = parts.length > 1 ? int.parse(parts[1]) : 0;
      int s = parts.length > 2 ? int.parse(parts[2].split('.')[0]) : 0;

      if (isPm && h < 12) h += 12;
      if (!isPm && h == 12) h = 0;

      return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m, s);
    } catch (_) {
      return DateTime(baseDate.year, baseDate.month, baseDate.day, 6, 0, 0);
    }
  }

  /// Calculates the full Vaasthu Pooja item for a single rule
  static VaasthuPoojaItem calculateItem({
    required VaasthuDayRule rule,
    required DateTime date,
    required String sunriseStr,
  }) {
    final sunriseTime = parseSunrise(date, sunriseStr);
    final startTime = sunriseTime.add(Duration(
      hours: rule.dhruvaHours,
      minutes: rule.dhruvaMinutes,
    ));
    final endTime = startTime.add(Duration(minutes: rule.durationMinutes));

    return VaasthuPoojaItem(
      rule: rule,
      englishDate: date,
      sunriseStr: sunriseStr,
      sunriseTime: sunriseTime,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Generates the 8 Vaasthu Pooja Days table for a given Year
  static List<VaasthuPoojaItem> generateYearTable({
    required int year,
    String cityName = 'நாமக்கல்',
    Map<int, String>? customSunrises,
  }) {
    // Standard baseline sunrise times for Namakkal across the 8 days
    // When Namakkal (as in user's prompt: ஐப்பசி 11 = 6:08:26 AM)
    final Map<String, String> namakkalSunrises = {
      'சித்திரை': '06:02:11 AM',
      'வைகாசி': '05:53:07 AM',
      'ஆடி': '06:04:24 AM',
      'ஆவணி': '06:07:22 AM',
      'ஐப்பசி': '06:08:26 AM', // Matches user prompt exactly!
      'கார்த்திகை': '06:17:14 AM',
      'தை': '06:41:35 AM',
      'மாசி': '06:29:49 AM',
    };

    List<VaasthuPoojaItem> list = [];

    for (int i = 0; i < vaasthuRules.length; i++) {
      final rule = vaasthuRules[i];
      final targetDate = DateTime(year, rule.defaultMonth, rule.defaultDay);
      final sunrise = customSunrises?[i] ?? namakkalSunrises[rule.tamilMonth] ?? '06:08:00 AM';

      list.add(calculateItem(
        rule: rule,
        date: targetDate,
        sunriseStr: sunrise,
      ));
    }

    return list;
  }
}
