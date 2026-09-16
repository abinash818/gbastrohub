import 'package:flutter_test/flutter_test.dart';

class SubPlanetResult {
  final String name;
  final int rasi; // 1 முதல் 12 (1: மேஷம் ... 12: மீனம்)
  final double degree; // ராசிக்குள் உள்ள பாகை (0.00° முதல் 30.00°)
  final String formattedDegree; // பாகை மற்றும் கலை (Deg° Min')

  SubPlanetResult({
    required this.name,
    required this.rasi,
    required this.degree,
    required this.formattedDegree,
  });

  @override
  String toString() => '$name: ராசி $rasi @ $formattedDegree';
}

class JamakkolSubPlanetsTest {
  static Map<String, SubPlanetResult> calculate({
    required DateTime currentTime,
    required DateTime sunrise,
    required DateTime sunset,
    required double sunLongitude,
    required int weekday,
  }) {
    bool isDay = currentTime.isAfter(sunrise) && currentTime.isBefore(sunset);

    double totalDurationSeconds;
    double elapsedTimeSeconds;

    if (isDay) {
      totalDurationSeconds = sunset.difference(sunrise).inSeconds.toDouble();
      elapsedTimeSeconds = currentTime.difference(sunrise).inSeconds.toDouble();
    } else {
      DateTime nextSunrise = sunrise.isBefore(currentTime) 
          ? sunrise.add(const Duration(days: 1)) 
          : sunrise;
      DateTime prevSunset = sunset.isAfter(currentTime) 
          ? sunset.subtract(const Duration(days: 1)) 
          : sunset;

      totalDurationSeconds = nextSunrise.difference(prevSunset).inSeconds.toDouble();
      elapsedTimeSeconds = currentTime.difference(prevSunset).inSeconds.toDouble();
    }

    // 1. நடப்பு ஜாமம் (1 முதல் 8 வரை)
    double elapsedFraction = elapsedTimeSeconds / totalDurationSeconds;
    int currentYama = (elapsedFraction * 8).floor() + 1;
    if (currentYama < 1) currentYama = 1;
    if (currentYama > 8) currentYama = 8;

    // 2. சரிபார்க்கப்பட்ட ஆரம்ப ராசி அட்டவணைகள் (0:மேஷம், 1:ரிஷபம் ... 11:மீனம்)
    // Weekdays: 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat

    // பகல் நேர 1-ஆம் ஜாம தொடக்க ராசிகள்
    const List<int> rahuDayBases   = [9, 11, 7, 4, 6, 2, 10]; // Sat: Aq(10) -> Yama 4 = Ta(1)
    const List<int> miruDayBases   = [7, 11, 3, 1, 11, 9, 11]; // Sat: Pi(11) -> Yama 4 = Ge(2)
    const List<int> yamaDayBases   = [6,  1, 2, 0, 10, 8,  1]; // Sat: Ta(1)  -> Yama 4 = Le(4)
    const List<int> maranaDayBases = [8,  0, 6, 3,  5, 1,  8]; // Sat: Sg(8)  -> Yama 4 = Pi(11)

    // இரவு நேர 1-ஆம் ஜாம தொடக்க ராசிகள்
    const List<int> rahuNightBases   = [2, 4, 4, 9, 3, 7, 4]; // Mon:Le(4), Tue:Le(4), Wed:Cp(9), Thu:Ca(3)
    const List<int> miruNightBases   = [0, 4, 4, 4, 3, 2, 5]; // Mon:Le(4), Tue:Le(4), Wed:Le(4), Thu:Ca(3)
    const List<int> yamaNightBases   = [11, 9, 7, 6, 6, 1, 6]; // Mon:Cp(9), Tue:Sc(7), Wed:Li(6), Thu:Li(6)
    const List<int> maranaNightBases = [6, 3, 3, 7, 7, 7, 4]; // Mon:Ca(3), Tue:Ca(3), Wed:Sc(7), Thu:Sc(7)

    int baseRahu   = isDay ? rahuDayBases[weekday]   : rahuNightBases[weekday];
    int baseMrityu = isDay ? miruDayBases[weekday]   : miruNightBases[weekday];
    int baseYama   = isDay ? yamaDayBases[weekday]   : yamaNightBases[weekday];
    int baseMarana = isDay ? maranaDayBases[weekday] : maranaNightBases[weekday];

    // 3. சூரியன் நின்ற ராசிக்குள் உள்ள பாகை (0.0° முதல் 30.0°)
    double sunSignDeg = (sunLongitude % 30.0 + 30.0) % 30.0;

    // 4. பாகைக் கணக்கீட்டு விதிகள்
    double rahuDeg   = sunSignDeg;
    double miruDeg   = (sunSignDeg - 6.0 + 30.0) % 30.0;
    double yamaDeg   = (sunSignDeg - 18.0 + 30.0) % 30.0;
    double maranaDeg = (sunSignDeg - 18.0 + 30.0) % 30.0;

    // 5. ராசி மற்றும் பாகையை இணைக்கும் துணைச் சார்பு
    SubPlanetResult buildResult(String name, int baseRasiIndex, double degree) {
      int targetRasiIndex = (baseRasiIndex + (currentYama - 1)) % 12;
      int targetRasiNumber = targetRasiIndex + 1; // 1 to 12

      int deg = degree.floor();
      int min = ((degree - deg) * 60).round();
      if (min == 60) {
        deg += 1;
        min = 0;
      }
      String formatted = '${deg.toString().padLeft(2, '0')}.${min.toString().padLeft(2, '0')}';

      return SubPlanetResult(
        name: name,
        rasi: targetRasiNumber,
        degree: degree,
        formattedDegree: formatted,
      );
    }

    return {
      'ரா.கா': buildResult('ராகு காலம்', baseRahu, rahuDeg),
      'மிரு': buildResult('மிருத்யு', baseMrityu, miruDeg),
      'யம': buildResult('எமகண்டன்', baseYama, yamaDeg),
      'மாந்': buildResult('மாந்தி/மாரணம்', baseMarana, maranaDeg),
    };
  }
}

void main() {
  const List<String> tamilRasis = [
    "மேஷம்", "ரிஷபம்", "மிதுனம்", "கடகம்",
    "சிம்மம்", "கன்னி", "துலாம்", "விருச்சிகம்",
    "தனுசு", "மகரம்", "கும்பம்", "மீனம்"
  ];

  void printResults(String title, Map<String, SubPlanetResult> res) {
    print('\n======================================================');
    print(title);
    print('------------------------------------------------------');
    res.forEach((key, sp) {
      String rasi = tamilRasis[sp.rasi - 1];
      print('${sp.name.padRight(15)} : $rasi (${sp.rasi}) @ ${sp.formattedDegree}');
    });
  }

  test('Test Case: Tue 14-04-2026 11:59:59 PM (Tuesday Night Yama 4)', () {
    final res = JamakkolSubPlanetsTest.calculate(
      currentTime: DateTime(2026, 4, 14, 23, 59, 59),
      sunrise: DateTime(2026, 4, 14, 6, 7, 0),
      sunset: DateTime(2026, 4, 14, 18, 29, 0),
      sunLongitude: 0.59, // Mesham 00.41°
      weekday: 2, // Tuesday
    );
    printResults('Tue 14-04-2026 11:59:59 PM (Tuesday Night Yama 4)', res);
  });

  test('Test Case: Wed 16-09-2026 06:12:00 AM (Wednesday Day Yama 1)', () {
    final res = JamakkolSubPlanetsTest.calculate(
      currentTime: DateTime(2026, 9, 16, 6, 12, 0),
      sunrise: DateTime(2026, 9, 16, 6, 8, 0),
      sunset: DateTime(2026, 9, 16, 18, 19, 0),
      sunLongitude: 148.95, // Simmam 28.57°
      weekday: 3, // Wednesday
    );
    printResults('Wed 16-09-2026 06:12:00 AM (Wednesday Day Yama 1)', res);
  });

  test('Test Case: Sat 21-03-2026 12:01:59 PM (Saturday Day Yama 4)', () {
    final res = JamakkolSubPlanetsTest.calculate(
      currentTime: DateTime(2026, 3, 21, 12, 1, 59),
      sunrise: DateTime(2026, 3, 21, 6, 22, 0),
      sunset: DateTime(2026, 3, 21, 18, 29, 0),
      sunLongitude: 336.31, // Meenam 06.31°
      weekday: 6, // Saturday
    );
    printResults('Sat 21-03-2026 12:01:59 PM (Saturday Day Yama 4)', res);
  });

  test('Test Case: Thu 10-09-2026 07:37:25 PM (Thursday Night Yama 1)', () {
    final res = JamakkolSubPlanetsTest.calculate(
      currentTime: DateTime(2026, 9, 10, 19, 37, 25),
      sunrise: DateTime(2026, 9, 10, 6, 8, 0),
      sunset: DateTime(2026, 9, 10, 18, 23, 0),
      sunLongitude: 143.75, // Simmam 23.45°
      weekday: 4, // Thursday
    );
    printResults('Thu 10-09-2026 07:37:25 PM (Thursday Night Yama 1)', res);
  });
}
