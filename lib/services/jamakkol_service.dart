import 'kp_service.dart';

class JamakkolService {
  static const List<String> JAMAKKOL_PLANETS = [
    "Sun", "Mars", "Jupiter", "Mercury", "Venus", "Saturn", "Moon", "Rahu"
  ];

  static const Map<String, String> JAMAKKOL_TAMIL_SHORT = {
    "Sun": "சூரி", "Mars": "செ", "Jupiter": "குரு", "Mercury": "புத",
    "Venus": "சுக்", "Saturn": "சனி", "Moon": "சந்", "Rahu": "பாம்பு"
  };

  static const Map<String, String> JAMAKKOL_TAMIL_ALT = {
    "Sun": "கதிர்", "Mars": "சேய்", "Jupiter": "பொன்", "Mercury": "மால்",
    "Venus": "புகர்", "Saturn": "மந்தன்", "Moon": "மதி", "Rahu": "பாம்பு"
  };

  static const Map<String, String> JAMAKKOL_ENGLISH_SHORT = {
    "Sun": "Sun", "Mars": "Mar", "Jupiter": "Jup", "Mercury": "Mer",
    "Venus": "Ven", "Saturn": "Sat", "Moon": "Mon", "Rahu": "Rah"
  };

  static const Map<String, String> JAMAKKOL_HINDI_SHORT = {
    "Sun": "सू", "Mars": "मं", "Jupiter": "गु", "Mercury": "बु",
    "Venus": "शु", "Saturn": "श", "Moon": "चं", "Rahu": "रा"
  };

  // Rasi Kathir (Strength) values
  static const Map<String, int> RASI_KATHIR = {
    "Aries": 7, "Taurus": 8, "Gemini": 5, "Cancer": 3,
    "Leo": 7, "Virgo": 11, "Libra": 2, "Scorpio": 4,
    "Sagittarius": 9, "Capricorn": 11, "Aquarius": 8, "Pisces": 6
  };

  // Kiraga Kathir (Planet Strength) values
  static const Map<String, int> PLANET_KATHIR = {
    "Sun": 5, "Moon": 14, "Mars": 8, "Mercury": 5,
    "Jupiter": 10, "Venus": 7, "Saturn": 1, "Rahu": 1, "Kavi": 0 // placeholder
  };

  // Sign Lords for Lord Kathir calculation
  static const Map<String, String> SIGN_LORDS = {
    "Aries": "Mars", "Taurus": "Venus", "Gemini": "Mercury", "Cancer": "Moon",
    "Leo": "Sun", "Virgo": "Mercury", "Libra": "Venus", "Scorpio": "Mars",
    "Sagittarius": "Jupiter", "Capricorn": "Saturn", "Aquarius": "Saturn", "Pisces": "Jupiter"
  };

  static const Map<int, String> DAY_LORDS = {
    0: "Sun", 1: "Moon", 2: "Mars", 3: "Mercury",
    4: "Jupiter", 5: "Venus", 6: "Saturn"
  };

  static const Map<String, List<String>> AATCHI = {
    "Sun": ["Leo"], "Moon": ["Cancer"], "Mars": ["Aries", "Scorpio"],
    "Mercury": ["Gemini", "Virgo"], "Jupiter": ["Sagittarius", "Pisces"],
    "Venus": ["Taurus", "Libra"], "Saturn": ["Capricorn", "Aquarius"]
  };

  static const Map<String, String> UCHAM = {
    "Sun": "Aries", "Moon": "Taurus", "Mars": "Capricorn", "Mercury": "Virgo",
    "Jupiter": "Cancer", "Venus": "Pisces", "Saturn": "Libra"
  };

  static const Map<String, String> NEECHAM = {
    "Sun": "Libra", "Moon": "Scorpio", "Mars": "Cancer", "Mercury": "Pisces",
    "Jupiter": "Capricorn", "Venus": "Virgo", "Saturn": "Aries"
  };

  static const Map<int, int> SOORYA_VEETHI = {
    0: 1, 1: 0, 2: 0, 3: 0, 4: 0, 5: 1,
    6: 1, 7: 2, 8: 2, 9: 2, 10: 2, 11: 1
  };

  static Map<String, dynamic> calculate(
    DateTime dt,
    DateTime sunrise,
    double lat,
    double lon,
    double timezone,
    int solarMonthIdx, {
    double? sunLongitude,
    bool useAltNaming = false,
    String langCode = 'ta',
    int udayamMethod = 0,
    DateTime? sunset,
  }) {
    // Use astrological day (day starts at 6 AM)
    DateTime adjustedDt = dt;
    if (dt.hour < 6) {
      adjustedDt = dt.subtract(const Duration(days: 1));
    }
    
    // Reference: Starts at 6:00 AM of the astrological day
    DateTime sixAM = DateTime(adjustedDt.year, adjustedDt.month, adjustedDt.day, 6, 0, 0);
    double elapsedMinutes = dt.difference(sixAM).inSeconds / 60.0;
    
    int weekday = adjustedDt.weekday % 7; // 0=Sun, 1=Mon... 
    String dayLord = DAY_LORDS[weekday] ?? "Sun";
    int startIdx = JAMAKKOL_PLANETS.indexOf(dayLord);

    Map<String, double> planetDegrees = {};
    Map<String, String> borderPlanets = {};
    final namingMap = langCode == 'en' ? JAMAKKOL_ENGLISH_SHORT : (langCode == 'hi' ? JAMAKKOL_HINDI_SHORT : (useAltNaming ? JAMAKKOL_TAMIL_ALT : JAMAKKOL_TAMIL_SHORT));

    double totalElapsedMinutes = dt.difference(sixAM).inSeconds / 60.0;
    double degMoved = totalElapsedMinutes * 0.5;

    for (int i = 0; i < 8; i++) {
        String pName = JAMAKKOL_PLANETS[(startIdx + i) % 8];
        double rawDeg = (360.0 - (45.0 * i) - degMoved);
        double finalDeg = (rawDeg % 360.0 + 360.0) % 360.0;
        planetDegrees[pName] = finalDeg;
        
        // Map 45-degree segments exclusively to the 8 valid Jamakkol signs
        int segment = (finalDeg / 45.0).floor();
        if (segment >= 8) segment = 7;
        
        // 0-45: Aries(0), 45-90: Gemini(2), 90-135: Cancer(3), 135-180: Virgo(5)
        // 180-225: Libra(6), 225-270: Sagittarius(8), 270-315: Capricorn(9), 315-360: Pisces(11)
        List<int> customSigns = [0, 2, 3, 5, 6, 8, 9, 11];
        int signIdx = customSigns[segment];
        
        String signName = KPService.SIGNS[signIdx];
        int d = finalDeg.floor();
        // borderPlanets[signName] = "${namingMap[pName]}\u00A0${d.toString().padLeft(3, '0')}°";
        // User screenshot 3 has format: "Guru 333°"
        borderPlanets[signName] = "${namingMap[pName]} ${d.toString().padLeft(3, '0')}°";
    }

    // 2. Arudam Logic (Remains same - moves 1 sign every 5 mins from 6 AM)
    double totalSeconds = dt.minute * 60.0 + dt.second;
    int arudamSignIdx = (totalSeconds / 300).floor() % 12;
    double arudamDegreeInSign = (totalSeconds % 300) / 10.0;
    double arudamAbsDeg = (arudamSignIdx * 30.0) + arudamDegreeInSign;

    // 3. Udayam Logic (Sun-based simplified Jamakkol Udayam)
    double udayamAbsDeg;
    bool calculatedIsDay = (sunset != null)
        ? (dt.isAfter(sunrise) && dt.isBefore(sunset))
        : (dt.hour >= 6 && dt.hour < 18);

    double startSunLon = sunLongitude ?? (solarMonthIdx * 30.0);

    if (udayamMethod == 1 && sunset != null) {
      if (calculatedIsDay) {
        double dayLengthSeconds = sunset.difference(sunrise).inSeconds.toDouble();
        double elapsedSeconds = dt.difference(sunrise).inSeconds.toDouble();
        double degMovedUdy = (elapsedSeconds / dayLengthSeconds) * 360.0;
        
        // Calculate Sun's longitude at Sunrise
        double elapsedDays = sunrise.difference(dt).inSeconds / 86400.0;
        double sunLonAtSunrise = startSunLon + elapsedDays * 0.9856;
        
        udayamAbsDeg = sunLonAtSunrise + degMovedUdy;
      } else {
        // Nighttime
        DateTime startOfNight;
        DateTime endOfNight;
        if (dt.isBefore(sunrise)) {
          DateTime prevSunset = sunset.subtract(const Duration(days: 1));
          startOfNight = prevSunset;
          endOfNight = sunrise;
        } else {
          DateTime nextSunrise = sunrise.add(const Duration(days: 1));
          startOfNight = sunset;
          endOfNight = nextSunrise;
        }
        double nightLengthSeconds = endOfNight.difference(startOfNight).inSeconds.toDouble();
        double elapsedSeconds = dt.difference(startOfNight).inSeconds.toDouble();
        double degMovedUdy = (elapsedSeconds / nightLengthSeconds) * 360.0;
        
        // Calculate Sun's longitude at Sunset
        double elapsedDays = startOfNight.difference(dt).inSeconds / 86400.0;
        double sunLonAtSunset = startSunLon + elapsedDays * 0.9856;
        
        udayamAbsDeg = sunLonAtSunset + degMovedUdy;
      }
    } else {
      udayamAbsDeg = startSunLon + (elapsedMinutes / (12 * 60.0)) * 360.0;
    }
    udayamAbsDeg = (udayamAbsDeg % 360.0 + 360.0) % 360.0;
    int udayamSignIdx = (udayamAbsDeg / 30).floor();

    // 4. Current Jamam Planet
    int currentJamamIdx = (elapsedMinutes / 90.0).floor() % 8;
    String currentJamamPlanet = JAMAKKOL_PLANETS[(startIdx + currentJamamIdx) % 8];

    return {
      'border_planets': borderPlanets,
      'planet_degrees': planetDegrees,
      'current_jamam_planet': currentJamamPlanet,
      'is_day': calculatedIsDay,
      'arudam_sign_idx': arudamSignIdx,
      'arudam_abs_deg': arudamAbsDeg,
      'udayam_abs_deg': udayamAbsDeg,
      'udayam_idx': udayamSignIdx,
      'soorya_veethi_idx': SOORYA_VEETHI[solarMonthIdx] ?? 0
    };
  }

  static int calculateKavippu(int udayamIdx, int arudamIdx, int sooryaVeethiIdx) {
    int n = (sooryaVeethiIdx - arudamIdx) % 12;
    if (n < 0) n += 12;
    return (udayamIdx + n) % 12;
  }

  static Map<String, dynamic> calculateStrengthAnalysis(Map<String, dynamic> results, {String langCode = 'ta'}) {
    Map<String, dynamic> analysis = {};
    int udayamIdx = results['udayam_idx'] ?? 0;
    int arudamIdx = results['arudam_idx'] ?? 0;
    int kaviIdx = results['kavi_idx'] ?? 0;

    String udayamSign = KPService.SIGNS[udayamIdx % 12];
    String udayamLord = SIGN_LORDS[udayamSign] ?? "Sun";
    int udayamRasiK = RASI_KATHIR[udayamSign] ?? 0;
    int udayamLordK = PLANET_KATHIR[udayamLord] ?? 0;
    analysis['udayam'] = {'label': 'உதயம்', 'total': udayamRasiK + udayamLordK, 'rasi': udayamRasiK, 'lord': udayamLordK};

    String arudamSign = KPService.SIGNS[arudamIdx % 12];
    String arudamLord = SIGN_LORDS[arudamSign] ?? "Sun";
    int arudamRasiK = RASI_KATHIR[arudamSign] ?? 0;
    int arudamLordK = PLANET_KATHIR[arudamLord] ?? 0;
    analysis['arudam'] = {'label': 'ஆரூடம்', 'total': arudamRasiK + arudamLordK, 'rasi': arudamRasiK, 'lord': arudamLordK};

    String kaviSign = KPService.SIGNS[kaviIdx % 12];
    String kaviLord = SIGN_LORDS[kaviSign] ?? "Sun";
    int kaviRasiK = RASI_KATHIR[kaviSign] ?? 0;
    int kaviLordK = PLANET_KATHIR[kaviLord] ?? 0;
    analysis['kavi'] = {'label': langCode == 'en' ? 'Kavippu' : (langCode == 'hi' ? 'कविप्पु' : 'கவிப்பு'), 'total': kaviRasiK + kaviLordK, 'rasi': kaviRasiK, 'lord': kaviLordK};

    String jamamP = results['outer']?['current_jamam_planet'] ?? "Sun";
    int jamamK = PLANET_KATHIR[jamamP] ?? 0;
    final namingMap = langCode == 'en' ? JAMAKKOL_ENGLISH_SHORT : (langCode == 'hi' ? JAMAKKOL_HINDI_SHORT : JAMAKKOL_TAMIL_SHORT);
    analysis['jamam'] = {'label': langCode == 'en' ? 'Jamam Planet' : (langCode == 'hi' ? 'जामम ग्रह' : 'ஜாமக் கிரகம்'), 'planet': namingMap[jamamP] ?? jamamP, 'total': jamamK};
    return analysis;
  }

  static Map<String, dynamic> calculateNotes(Map<String, dynamic> results, {String langCode = 'ta'}) {
    int udayamIdx = results['udayam_idx'] ?? 0;
    int arudamIdx = results['arudam_idx'] ?? 0;
    int kaviIdx = results['kavi_idx'] ?? 0;
    
    double udayamAbsDeg = (results['outer']?['udayam_abs_deg'] ?? 0.0).toDouble();
    Map<String, double> planetDegrees = {};
    if (results['outer']?['planet_degrees'] != null) {
      (results['outer']['planet_degrees'] as Map).forEach((k, v) {
        planetDegrees[k.toString()] = (v ?? 0.0).toDouble();
      });
    }

    // 1. Arudam and Kavi House (Relative to Udayam)
    int arudamHouse = ((arudamIdx - udayamIdx + 12) % 12) + 1;
    int kaviHouse = ((kaviIdx - udayamIdx + 12) % 12) + 1;

    // 2. Planet covered by Kavi (Degree based proximity)
    double arudamAbsDegVal = (results['outer']?['arudam_abs_deg'] ?? 0.0).toDouble();
    // In Jamakkol, Kavippu degree is relative to Arudam. 
    // Usually: DegOfKavippu = 30.0 - (ArudamDegree % 30.0) + (KaviSignIdx * 30.0)
    double kaviAbsDeg = (30.0 - (arudamAbsDegVal % 30.0)) + (kaviIdx * 30.0);
    kaviAbsDeg = (kaviAbsDeg % 360.0 + 360.0) % 360.0;

    String kaviPlanet = "-";
    double minDiffKavi = 360.0;
    final namingMap = langCode == 'en' ? JAMAKKOL_ENGLISH_SHORT : (langCode == 'hi' ? JAMAKKOL_HINDI_SHORT : JAMAKKOL_TAMIL_SHORT);
    planetDegrees.forEach((p, deg) {
      double diff = (deg - kaviAbsDeg).abs();
      if (diff > 180) diff = 360 - diff;
      if (diff < minDiffKavi) {
        minDiffKavi = diff;
        kaviPlanet = namingMap[p] ?? p;
      }
    });

    // 3. Udayam Lord House
    String udayamSign = KPService.SIGNS[udayamIdx % 12];
    String udayamLord = SIGN_LORDS[udayamSign] ?? "Sun";
    int udayamLordIdx = 0;
    if (results['inner']?['planet_details'] != null) {
      (results['inner']['planet_details'] as Map).forEach((pKey, pVal) {
        if (pKey.toString().toLowerCase() == udayamLord.toLowerCase()) {
          udayamLordIdx = KPService.SIGNS.indexOf(pVal['rasi'] ?? "Aries");
        }
      });
    }
    int udayamLordHouse = ((udayamLordIdx - udayamIdx + 12) % 12) + 1;

    // 4. Planets relative to Udayam (In Udhayam, Passed, Approaching)
    // Jamakkol planets move backwards (360 -> 0)
    String? inUdhayamPlanet;
    double inUdhayamMinDiff = 360.0;
    
    String? passedPlanet;
    double passedMinDiff = 360.0;
    
    String? approachingPlanet;
    double approachingMinDiff = 360.0;

    planetDegrees.forEach((p, pDeg) {
      String pName = namingMap[p] ?? p;
      int pSignIdx = (pDeg / 30).floor();
      
      double diff = (pDeg - udayamAbsDeg).abs();
      if (diff > 180) diff = 360 - diff;

      if (diff <= 10.0 || pSignIdx == (udayamIdx % 12)) {
        if (diff < inUdhayamMinDiff) {
          inUdhayamMinDiff = diff;
          inUdhayamPlanet = pName;
        }
      } else {
        // Since planets move backwards, higher degree means approaching, lower means passed
        // A simple way to check approaching vs passed considering wrap-around:
        double relDeg = pDeg - udayamAbsDeg;
        if (relDeg < -180) relDeg += 360;
        if (relDeg > 180) relDeg -= 360;

        if (relDeg > 0) {
          if (relDeg < approachingMinDiff) {
            approachingMinDiff = relDeg;
            approachingPlanet = pName;
          }
        } else {
          double absRelDeg = relDeg.abs();
          if (absRelDeg < passedMinDiff) {
            passedMinDiff = absRelDeg;
            passedPlanet = pName;
          }
        }
      }
    });

    String inUdhayamStr = inUdhayamPlanet ?? "-";
    String towards = approachingPlanet ?? "-";
    String passed = passedPlanet ?? "-";

    // 5. Planet Status (Aatchi, Ucham, Neecham)
    List<Map<String, String>> planetStatus = [];
    Map<String, String> planetInSign = {};
    
    planetDegrees.forEach((p, deg) {
      int signIdx = (deg / 30).floor();
      String sign = KPService.SIGNS[signIdx];
      planetInSign[p] = sign;
      
      String status = "";
      if (AATCHI[p]?.contains(sign) ?? false) status = langCode == 'en' ? "Own" : (langCode == 'hi' ? "स्वग्रही" : "ஆட்சி");
      else if (UCHAM[p] == sign) status = langCode == 'en' ? "Exalted" : (langCode == 'hi' ? "उच्च" : "உச்சம்");
      else if (NEECHAM[p] == sign) status = langCode == 'en' ? "Debilitated" : (langCode == 'hi' ? "नीच" : "நீச்சம்");
      
      if (status.isNotEmpty) {
        planetStatus.add({'planet': namingMap[p] ?? p, 'status': status});
      }
    });

    // 6. Parivarthana Yoga
    List<String> parivarthana = [];
    List<String> keys = planetInSign.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      for (int j = i + 1; j < keys.length; j++) {
        String p1 = keys[i];
        String p2 = keys[j];
        String s1 = planetInSign[p1]!;
        String s2 = planetInSign[p2]!;
        if (SIGN_LORDS[s1] == p2 && SIGN_LORDS[s2] == p1) {
          parivarthana.add("${namingMap[p1]!} - ${namingMap[p2]!}");
        }
      }
    }

    return {
      'arudam_house': arudamHouse,
      'kavi_house': kaviHouse,
      'kavi_planet': kaviPlanet,
      'udayathipathi_house': udayamLordHouse,
      'in_udhayam': inUdhayamStr,
      'towards_planet': towards,
      'passed_planet': passed,
      'planet_status': planetStatus,
      'parivarthana': parivarthana,
    };
  }
  static const Map<String, List<String>> GOWRI_TYPES = {
    'ta': ["அமிர்தம்", "சுகம்", "லாபம்", "தனம்", "உத்தியோகம்", "ரோகம்", "சோரம்", "விஷம்"],
    'en': ["Amirtham", "Sugam", "Labam", "Dhanam", "Uthiyogam", "Rogam", "Soram", "Visham"],
    'hi': ["अमृतम", "सुखम", "लाभम", "धनम", "उद्योगाम", "रोगम", "सोरम", "विषम"]
  };

  static const Map<int, List<int>> GOWRI_DAY_SEQ = {
    0: [4, 0, 5, 2, 3, 1, 7, 6], // Sun
    1: [0, 5, 2, 3, 1, 7, 6, 4], // Mon
    2: [5, 2, 3, 1, 7, 6, 4, 0], // Tue
    3: [2, 3, 1, 7, 6, 4, 0, 5], // Wed
    4: [3, 1, 7, 6, 4, 0, 5, 2], // Thu
    5: [1, 7, 6, 4, 0, 5, 2, 3], // Fri
    6: [7, 6, 4, 0, 5, 2, 3, 1], // Sat
  };

  static const Map<int, List<int>> GOWRI_NIGHT_SEQ = {
    0: [0, 4, 7, 0, 5, 2, 3, 1], // Sun (approx)
    1: [7, 0, 5, 2, 3, 1, 6, 4], // Mon
    2: [6, 4, 7, 0, 5, 2, 3, 1], // Tue
    3: [4, 7, 0, 5, 2, 3, 1, 6], // Wed
    4: [3, 1, 6, 4, 7, 0, 5, 2], // Thu
    5: [2, 3, 1, 6, 4, 7, 0, 5], // Fri
    6: [1, 6, 4, 7, 0, 5, 2, 3], // Sat
  };

  static Map<String, dynamic> calculateCurrentSegments(DateTime dt, DateTime sunrise, DateTime sunset, {String langCode = 'ta'}) {
    bool isDay = dt.isAfter(sunrise) && dt.isBefore(sunset);
    double totalMinutes;
    DateTime startTime;
    if (isDay) {
      totalMinutes = sunset.difference(sunrise).inMinutes.toDouble();
      startTime = sunrise;
    } else {
      DateTime nextSunrise = sunrise.add(const Duration(days: 1));
      if (dt.isBefore(sunrise)) {
        // Birth is early morning before sunrise
        DateTime prevSunset = sunset.subtract(const Duration(days: 1));
        totalMinutes = sunrise.difference(prevSunset).inMinutes.toDouble();
        startTime = prevSunset;
      } else {
        totalMinutes = nextSunrise.difference(sunset).inMinutes.toDouble();
        startTime = sunset;
      }
    }

    double segmentSeconds = (totalMinutes * 60) / 8.0;
    int currentSegment = (dt.difference(startTime).inSeconds / segmentSeconds).floor();
    if (currentSegment < 0) currentSegment = 0;
    if (currentSegment > 7) currentSegment = 7;
    int weekday = dt.weekday % 7;

    int gowriIdx = isDay ? GOWRI_DAY_SEQ[weekday]![currentSegment] : GOWRI_NIGHT_SEQ[weekday]![currentSegment];

    // Rahu, Yama, Gulika, Artha Segments (Day only)
    Map<String, int> daySegments = {
      'rahu': [7, 1, 6, 4, 5, 3, 2][weekday], // 0-indexed segment
      'yama': [4, 3, 2, 1, 0, 6, 5][weekday],
      'kuli': [6, 5, 4, 3, 2, 1, 0][weekday],
      'artha': [3, 2, 1, 0, 6, 5, 4][weekday],
    };

    if (isDay && currentSegment == daySegments['rahu']) {
      gowriIdx = 7; // Visham
    }

    final gowriList = GOWRI_TYPES[langCode] ?? GOWRI_TYPES['ta']!;
    String status = "-";
    if (isDay) {
      if (currentSegment == daySegments['rahu']) status = langCode == 'en' ? "Rahu" : (langCode == 'hi' ? "राहु" : "இராகு");
      else if (currentSegment == daySegments['yama']) status = langCode == 'en' ? "Yama" : (langCode == 'hi' ? "यमगंडम" : "எமகண்டம்");
      else if (currentSegment == daySegments['kuli']) status = langCode == 'en' ? "Gulika" : (langCode == 'hi' ? "गुलिका" : "குளிகை");
      else if (currentSegment == daySegments['artha']) status = langCode == 'en' ? "Artha" : (langCode == 'hi' ? "अर्थ" : "அர்த்தப்பிரகணன்");
    }

    return {
      'gowri': gowriList[gowriIdx],
      'status': status,
      'segment': currentSegment + 1,
    };
  }
}
