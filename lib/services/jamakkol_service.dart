import 'kp_service.dart';

class JamakkolService {
  static const List<String> JAMAKKOL_PLANETS = [
    "Sun", "Mars", "Jupiter", "Mercury", "Venus", "Saturn", "Moon", "Rahu"
  ];

  static const Map<String, String> JAMAKKOL_TAMIL_SHORT = {
    "Sun": "சூரியன்", "Mars": "செவ்வாய்", "Jupiter": "குரு", "Mercury": "புதன்",
    "Venus": "சுக்கிரன்", "Saturn": "சனி", "Moon": "சந்திரன்", "Rahu": "ராகு"
  };

  static const Map<String, String> JAMAKKOL_TAMIL_ALT = {
    "Sun": "சூரியன்", "Mars": "செவ்வாய்", "Jupiter": "குரு", "Mercury": "புதன்",
    "Venus": "சுக்கிரன்", "Saturn": "சனி", "Moon": "சந்திரன்", "Rahu": "ராகு"
  };

  static const Map<String, String> JAMAKKOL_ENGLISH_SHORT = {
    "Sun": "Sun", "Mars": "Mar", "Jupiter": "Jup", "Mercury": "Mer",
    "Venus": "Ven", "Saturn": "Sat", "Moon": "Mon", "Rahu": "Rah"
  };

  static const Map<String, String> JAMAKKOL_HINDI_SHORT = {
    "Sun": "सू", "Mars": "मं", "Jupiter": "गु", "Mercury": "बु",
    "Venus": "शु", "Saturn": "श", "Moon": "चं", "Rahu": "रा"
  };

  // Rasi Kathir (Strength) values according to Jamakkol
  static const Map<String, int> RASI_KATHIR = {
    "Aries": 7, "Taurus": 8, "Gemini": 5, "Cancer": 3,
    "Leo": 7, "Virgo": 11, "Libra": 2, "Scorpio": 4,
    "Sagittarius": 6, "Capricorn": 8, "Aquarius": 8, "Pisces": 27
  };

  // Alternative Rasi Kathir values
  static const Map<String, int> RASI_KATHIR_ALT = {
    "Aries": 8, "Taurus": 8, "Gemini": 5, "Cancer": 3,
    "Leo": 8, "Virgo": 11, "Libra": 2, "Scorpio": 4,
    "Sagittarius": 6, "Capricorn": 8, "Aquarius": 8, "Pisces": 27
  };

  // Kiraga Kathir (Planet Strength) values
  static const Map<String, int> PLANET_KATHIR = {
    "Sun": 5, "Moon": 21, "Mars": 7, "Mercury": 9,
    "Jupiter": 10, "Venus": 16, "Saturn": 4, "Rahu": 4, "Kavi": 0
  };

  // Alternative Kiraga Kathir values
  static const Map<String, int> PLANET_KATHIR_ALT = {
    "Sun": 5, "Moon": 21, "Mars": 8, "Mercury": 16,
    "Jupiter": 10, "Venus": 20, "Saturn": 4, "Rahu": 4, "Kavi": 0
  };

  static int getPlanetMultiplier(String planet, String sign) {
    if (planet == "Rahu" || planet == "பாம்பு" || planet == "ராகு") {
      // ராகு/பாம்பு (ராகு/கேது): எப்போதும் 4 கதிர்கள் மட்டுமே
      return 1;
    }
    if (UCHAM[planet] == sign) {
      return 3; // உச்சம் = அடிப்படை கதிர் x 3
    }
    if (AATCHI[planet]?.contains(sign) ?? false) {
      return 2; // ஆட்சி = அடிப்படை கதிர் x 2
    }
    if (NEECHAM[planet] == sign) {
      return 0; // நீசம் = அடிப்படை கதிர் x 0 = 0
    }
    // நட்பு / பகை / சமம் / பொது நிலை = அடிப்படை கதிர் x 1
    return 1;
  }

  static String getPlanetMultiplierStatus(String planet, String sign, {String langCode = 'ta'}) {
    if (planet == "Rahu" || planet == "பாம்பு") {
      return langCode == 'en' ? "Snake" : (langCode == 'hi' ? "राहु" : "பாம்பு");
    }
    if (UCHAM[planet] == sign) {
      return langCode == 'en' ? "Exalted (x3)" : (langCode == 'hi' ? "उच्च" : "உச்சம்");
    }
    if (AATCHI[planet]?.contains(sign) ?? false) {
      return langCode == 'en' ? "Own (x2)" : (langCode == 'hi' ? "स्वग्रही" : "ஆட்சி");
    }
    if (NEECHAM[planet] == sign) {
      return langCode == 'en' ? "Debilitated (x0)" : (langCode == 'hi' ? "नीच" : "நீசம்");
    }
    return langCode == 'en' ? "Friend/Neutral (x1)" : (langCode == 'hi' ? "सम" : "நட்பு/சமம்");
  }

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
    // 90 minutes = 45 degrees (0.5 deg/min) moving in reverse (anti-clockwise / இடஞ்சுழி)
    double degMoved = totalElapsedMinutes * 0.5;

    for (int i = 0; i < 8; i++) {
        String pName = JAMAKKOL_PLANETS[(startIdx + i) % 8];
        // Jamakkol outer planets move in reverse (anti-clockwise / இடஞ்சுழி):
        // 45 degrees per jamam backwards: 0°, 315°, 270°, 225°, 180°, 135°, 90°, 45°
        // and decrement degrees as time advances
        double rawDeg = (360.0 - (45.0 * i) - degMoved);
        double finalDeg = (rawDeg % 360.0 + 360.0) % 360.0;
        planetDegrees[pName] = finalDeg;
        
        int signIdx = (finalDeg / 30.0).floor() % 12;
        String signName = KPService.SIGNS[signIdx];
        double degInSign = finalDeg % 30.0;
        int d = degInSign.floor();
        int m = ((degInSign - d) * 60).floor();
        String degStr = d.toString();
        String minStr = m.toString().padLeft(2, '0');
        if (borderPlanets.containsKey(signName)) {
          borderPlanets[signName] = "${borderPlanets[signName]}\n${namingMap[pName]} $degStr:$minStr";
        } else {
          borderPlanets[signName] = "${namingMap[pName]} $degStr:$minStr";
        }
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

    final namingMap = langCode == 'en' ? JAMAKKOL_ENGLISH_SHORT : (langCode == 'hi' ? JAMAKKOL_HINDI_SHORT : JAMAKKOL_TAMIL_SHORT);

    // Map each sign to the Jamakkol outer planet situated in it (from outer['planet_degrees'])
    Map<String, String> planetInSign = {};
    if (results['outer']?['planet_degrees'] != null) {
      (results['outer']['planet_degrees'] as Map).forEach((p, deg) {
        int sIdx = ((deg as num) / 30.0).floor() % 12;
        planetInSign[KPService.SIGNS[sIdx]] = p.toString();
      });
    }

    // Helper to evaluate a sign's kathir
    Map<String, dynamic> evaluateSignKathir(String signName) {
      int rasiK = RASI_KATHIR[signName] ?? 0;
      int rasiKAlt = RASI_KATHIR_ALT[signName] ?? rasiK;
      String rasiDisplay = (rasiK == rasiKAlt) ? "$rasiK" : "$rasiK/$rasiKAlt";

      String? pName = planetInSign[signName];
      int planetK = 0;
      int planetKAlt = 0;
      int multiplier = 0;
      String status = "";
      String planetLabel = "";
      String planetDisplay = "0";

      if (pName != null) {
        planetLabel = namingMap[pName] ?? pName;
        multiplier = getPlanetMultiplier(pName, signName);
        status = getPlanetMultiplierStatus(pName, signName, langCode: langCode);
        int baseK = PLANET_KATHIR[pName] ?? 0;
        int baseKAlt = PLANET_KATHIR_ALT[pName] ?? baseK;

        if (pName == "Rahu") {
          planetK = 4;
          planetKAlt = 4;
          planetDisplay = "4 ($planetLabel)";
        } else {
          planetK = baseK * multiplier;
          planetKAlt = baseKAlt * multiplier;
          if (multiplier == 0) {
            planetDisplay = "0 ($planetLabel $status)";
          } else if (planetK == planetKAlt) {
            planetDisplay = "$planetK ($planetLabel" + (status.isNotEmpty ? " $status" : "") + ")";
          } else {
            planetDisplay = "$planetK/$planetKAlt ($planetLabel" + (status.isNotEmpty ? " $status" : "") + ")";
          }
        }
      }

      int total = rasiK + planetK;
      int totalAlt = rasiKAlt + planetKAlt;
      String totalDisplay = (total == totalAlt)
          ? "$total"
          : "$total/$totalAlt";

      return {
        'sign': signName,
        'signTamil': KPService.TAMIL_SIGNS[signName] ?? signName,
        'rasi': rasiK,
        'rasiAlt': rasiKAlt,
        'rasiDisplay': rasiDisplay,
        'planet': pName,
        'planetLabel': planetLabel,
        'planetStatus': status,
        'planetMultiplier': multiplier,
        'planetKathir': planetK,
        'planetKathirAlt': planetKAlt,
        'planetDisplay': planetDisplay,
        'total': total,
        'totalAlt': totalAlt,
        'totalDisplay': totalDisplay,
      };
    }

    // 1. Key Features: Udayam, Arudam, Kavippu
    String udayamSign = KPService.SIGNS[udayamIdx % 12];
    var udayamData = evaluateSignKathir(udayamSign);
    analysis['udayam'] = {
      'label': langCode == 'en' ? 'Udayam' : (langCode == 'hi' ? 'उदय' : 'உதயம்'),
      'sign': udayamSign,
      'rasi': udayamData['rasi'],
      'rasiDisplay': udayamData['rasiDisplay'],
      'lord': udayamData['planetDisplay'],
      'planetDisplay': udayamData['planetDisplay'],
      'total': udayamData['total'],
      'totalAlt': udayamData['totalAlt'],
      'totalDisplay': udayamData['totalDisplay'],
    };

    String arudamSign = KPService.SIGNS[arudamIdx % 12];
    var arudamData = evaluateSignKathir(arudamSign);
    analysis['arudam'] = {
      'label': langCode == 'en' ? 'Arudam' : (langCode == 'hi' ? 'आरूढ़' : 'ஆரூடம்'),
      'sign': arudamSign,
      'rasi': arudamData['rasi'],
      'rasiDisplay': arudamData['rasiDisplay'],
      'lord': arudamData['planetDisplay'],
      'planetDisplay': arudamData['planetDisplay'],
      'total': arudamData['total'],
      'totalAlt': arudamData['totalAlt'],
      'totalDisplay': arudamData['totalDisplay'],
    };

    String kaviSign = KPService.SIGNS[kaviIdx % 12];
    var kaviData = evaluateSignKathir(kaviSign);
    analysis['kavi'] = {
      'label': langCode == 'en' ? 'Kavippu' : (langCode == 'hi' ? 'कविप्पु' : 'கவிப்பு'),
      'sign': kaviSign,
      'rasi': kaviData['rasi'],
      'rasiDisplay': kaviData['rasiDisplay'],
      'lord': kaviData['planetDisplay'],
      'planetDisplay': kaviData['planetDisplay'],
      'total': kaviData['total'],
      'totalAlt': kaviData['totalAlt'],
      'totalDisplay': kaviData['totalDisplay'],
    };

    // Current Jamam Planet
    String jamamP = results['outer']?['current_jamam_planet'] ?? "Sun";
    int jamamBase = PLANET_KATHIR[jamamP] ?? 0;
    int jamamBaseAlt = PLANET_KATHIR_ALT[jamamP] ?? jamamBase;
    String jamamSign = "";
    if (results['outer']?['planet_degrees']?[jamamP] != null) {
      double jdeg = (results['outer']['planet_degrees'][jamamP] as num).toDouble();
      jamamSign = KPService.SIGNS[(jdeg / 30.0).floor() % 12];
    }
    int jamamMult = jamamSign.isNotEmpty ? getPlanetMultiplier(jamamP, jamamSign) : 1;
    int jamamK = (jamamP == "Rahu") ? 4 : (jamamBase * jamamMult);
    int jamamKAlt = (jamamP == "Rahu") ? 4 : (jamamBaseAlt * jamamMult);
    String jamamStatus = jamamSign.isNotEmpty ? getPlanetMultiplierStatus(jamamP, jamamSign, langCode: langCode) : "";
    String jamamDisplay = (jamamK == jamamKAlt) 
        ? "$jamamK" 
        : "$jamamK/$jamamKAlt";

    analysis['jamam'] = {
      'label': langCode == 'en' ? 'Jamam Planet' : (langCode == 'hi' ? 'जामम ग्रह' : 'ஜாமக் கிரகம்'),
      'planet': namingMap[jamamP] ?? jamamP,
      'sign': jamamSign,
      'status': jamamStatus,
      'total': jamamK,
      'totalAlt': jamamKAlt,
      'totalDisplay': jamamDisplay,
    };

    // 2. All 12 Bhavas starting from Udayam (1 to 12)
    List<Map<String, dynamic>> bhavas = [];
    Map<String, String> rasiKathirMap = {};
    Map<String, int> rasiKathirIntMap = {};

    for (int i = 0; i < 12; i++) {
      int sIdx = (udayamIdx + i) % 12;
      String sName = KPService.SIGNS[sIdx];
      var bData = evaluateSignKathir(sName);
      bData['bhava'] = i + 1;
      bData['isUdayam'] = (i == 0);
      bData['isArudam'] = (sIdx == arudamIdx % 12);
      bData['isKavi'] = (sIdx == kaviIdx % 12);
      bhavas.add(bData);
    }

    // Populate rasiKathirMap for all 12 signs in zodiac order
    for (var sName in KPService.SIGNS) {
      var sData = evaluateSignKathir(sName);
      rasiKathirMap[sName] = sData['totalDisplay'];
      rasiKathirIntMap[sName] = sData['total'];
    }

    analysis['bhavas'] = bhavas;
    analysis['rasi_kathir_map'] = rasiKathirMap;
    analysis['rasi_kathir_int_map'] = rasiKathirIntMap;

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

    // Helper: Nakshatra and Pada Info
    Map<String, dynamic> getNakshatraInfo(double lon) {
      lon = lon % 360;
      if (lon < 0) lon += 360;
      int absolutePada = (lon / (360.0 / 108.0)).floor();
      int nakIdx = (absolutePada / 4).floor() % 27;
      int padaNum = (absolutePada % 4) + 1;
      return {
        'nakshatra': KPService.NAKSHATRAS[nakIdx],
        'pada': padaNum,
        'lord': KPService.VIMSHOTTARI_LORDS[nakIdx % 9],
        'absolute_pada': absolutePada,
      };
    }

    // Helper: Lordship string relative to Udayam
    String getLordshipString(String planet, int refSignIdx) {
      if (planet == "Rahu" || planet == "Ketu" || planet == "Maanthi" || planet == "பாம்பு") return "-";
      List<int> ruledSigns = [];
      SIGN_LORDS.forEach((sign, lord) {
        if (lord.toLowerCase() == planet.toLowerCase()) {
          ruledSigns.add(KPService.SIGNS.indexOf(sign));
        }
      });
      if (ruledSigns.isEmpty) return "-";
      List<int> houses = ruledSigns.map((sIdx) => ((sIdx - refSignIdx + 12) % 12) + 1).toList();
      houses.sort();
      return houses.join("/");
    }

    // 1. Planet contacting Udayam (உதயம் தொடர்பு கொள்ளும் கிரகம் - Forward / வலஞ்சுழி)
    // Udayam moves forward (increasing degrees). Finds the first planet ahead in the forward path.
    String? contactingPlanet;
    double minUdayamForwardDist = 360.0;
    double contactingPlanetDeg = 0.0;
    planetDegrees.forEach((p, deg) {
      double forwardDist = (deg - udayamAbsDeg) % 360.0;
      if (forwardDist < 0) forwardDist += 360.0;
      if (forwardDist < minUdayamForwardDist) {
        minUdayamForwardDist = forwardDist;
        contactingPlanet = p;
        contactingPlanetDeg = deg;
      }
    });

    List<Map<String, dynamic>> udayamContacts = [];
    if (contactingPlanet != null) {
      int pSign = (contactingPlanetDeg / 30.0).floor() % 12;
      udayamContacts.add({
        'planet': contactingPlanet,
        'deg': contactingPlanetDeg,
        'house': ((pSign - udayamIdx + 12) % 12) + 1,
        'lordship': getLordshipString(contactingPlanet!, udayamIdx),
      });
    }

    // 2. Udayam star pada (உதயம் நின்ற நட்சத்திர பாதம்)
    final udayamStar = getNakshatraInfo(udayamAbsDeg);
    final udayamStarMap = {
      'deg': udayamAbsDeg,
      'nakshatra': udayamStar['nakshatra'],
      'pada': udayamStar['pada'],
      'lord': udayamStar['lord'],
      'lordship': getLordshipString(udayamStar['lord'], udayamIdx),
    };

    // 3. Planet that crossed Udayam (உதயத்தை கடந்த கிரகம் - Behind Udayam in forward path)
    String? crossedPlanet;
    double crossedMinBehindDist = 360.0;
    double crossedDeg = 0.0;
    planetDegrees.forEach((p, pDeg) {
      double behindDist = (udayamAbsDeg - pDeg) % 360.0;
      if (behindDist < 0) behindDist += 360.0;
      if (behindDist > 0.0001 && behindDist < crossedMinBehindDist) {
        crossedMinBehindDist = behindDist;
        crossedPlanet = p;
        crossedDeg = pDeg;
      }
    });
    final crossedPlanetMap = crossedPlanet != null ? {
      'planet': crossedPlanet,
      'deg': crossedDeg,
      'lordship': getLordshipString(crossedPlanet!, udayamIdx),
    } : null;

    // 4. Arudam House (ஆருடம் உள்ள பாவம்)
    double arudamAbsDegVal = (results['outer']?['arudam_abs_deg'] ?? 0.0).toDouble();
    String arudamLord = SIGN_LORDS[KPService.SIGNS[arudamIdx % 12]] ?? "Sun";
    final arudamStar = getNakshatraInfo(arudamAbsDegVal);
    final arudamHouseMap = {
      'house': ((arudamIdx - udayamIdx + 12) % 12) + 1,
      'lord': arudamLord,
      'lordship': getLordshipString(arudamLord, udayamIdx),
      'deg': arudamAbsDegVal,
      'nakshatra': arudamStar['nakshatra'],
      'pada': arudamStar['pada'],
    };

    // 5. Planet contacting Arudam (ஆருடம் தொடர்பு கொள்ளும் கிரகம் - Forward / வலஞ்சுழி)
    String? approachingArudamPlanet;
    double approachingArudamMinDiff = 360.0;
    double approachingArudamDeg = 0.0;
    planetDegrees.forEach((p, pDeg) {
      double forwardDist = (pDeg - arudamAbsDegVal) % 360.0;
      if (forwardDist < 0) forwardDist += 360.0;
      if (forwardDist < approachingArudamMinDiff) {
        approachingArudamMinDiff = forwardDist;
        approachingArudamPlanet = p;
        approachingArudamDeg = pDeg;
      }
    });
    final approachingArudamStar = approachingArudamPlanet != null ? getNakshatraInfo(approachingArudamDeg) : null;
    final arudamContactMap = approachingArudamPlanet != null ? {
      'planet': approachingArudamPlanet,
      'deg': approachingArudamDeg,
      'nakshatra': approachingArudamStar!['nakshatra'],
      'pada': approachingArudamStar['pada'],
    } : null;

    // 6. Kavippu House (கவிப்புள்ள பாவம்)
    double kaviAbsDeg = (30.0 - (arudamAbsDegVal % 30.0)) + (kaviIdx * 30.0);
    kaviAbsDeg = (kaviAbsDeg % 360.0 + 360.0) % 360.0;
    final kaviStar = getNakshatraInfo(kaviAbsDeg);
    final kaviHouseMap = {
      'house': ((kaviIdx - udayamIdx + 12) % 12) + 1,
      'deg': kaviAbsDeg,
      'nakshatra': kaviStar['nakshatra'],
      'pada': kaviStar['pada'],
    };

    // 7. Planet covered by Kavippu (கவிக்கப்படும் கிரகம் - Reverse / இடஞ்சுழி)
    // Kavippu covers in reverse (decreasing degrees). The first planet in reverse path is chosen.
    String? kaviPlanet;
    double minKaviReverseDist = 360.0;
    double kaviPlanetDeg = 0.0;
    planetDegrees.forEach((p, pDeg) {
      double reverseDist = (kaviAbsDeg - pDeg) % 360.0;
      if (reverseDist < 0) reverseDist += 360.0;
      if (reverseDist < minKaviReverseDist) {
        minKaviReverseDist = reverseDist;
        kaviPlanet = p;
        kaviPlanetDeg = pDeg;
      }
    });

    final kaviPlanetStar = kaviPlanet != null ? getNakshatraInfo(kaviPlanetDeg) : null;
    final kaviPlanetMap = kaviPlanet != null ? {
      'planet': kaviPlanet,
      'deg': kaviPlanetDeg,
      'lordship': getLordshipString(kaviPlanet!, udayamIdx),
      'nakshatra': kaviPlanetStar!['nakshatra'],
      'pada': kaviPlanetStar['pada'],
    } : null;

    // 8. Arudam Lord's House (ஆருடாதிபதி நின்ற பாவம்)
    double arudamLordDeg = 0.0;
    int arudamLordRasiIdx = 0;
    if (planetDegrees.containsKey(arudamLord)) {
      arudamLordDeg = planetDegrees[arudamLord] ?? 0.0;
      arudamLordRasiIdx = (arudamLordDeg / 30.0).floor() % 12;
    } else if (results['outer']?['planet_degrees']?[arudamLord] != null) {
      arudamLordDeg = (results['outer']['planet_degrees'][arudamLord] as num).toDouble();
      arudamLordRasiIdx = (arudamLordDeg / 30.0).floor() % 12;
    } else if (results['inner']?['planet_details'] != null) {
      (results['inner']['planet_details'] as Map).forEach((pKey, pVal) {
        if (pKey.toString().toLowerCase() == arudamLord.toLowerCase()) {
          arudamLordDeg = (pVal['longitude'] ?? 0.0).toDouble();
          arudamLordRasiIdx = KPService.SIGNS.indexOf(pVal['rasi'] ?? "Aries");
          if (arudamLordRasiIdx < 0) {
            arudamLordRasiIdx = (arudamLordDeg / 30.0).floor() % 12;
          }
        }
      });
    }
    int arudamLordHouse = ((arudamLordRasiIdx - udayamIdx + 12) % 12) + 1;

    // Udayam Lord's House (உதயாதிபதி நின்ற பாவம்)
    String udayamLord = SIGN_LORDS[KPService.SIGNS[udayamIdx % 12]] ?? "Sun";
    int udayamLordRasiIdx = 0;
    if (planetDegrees.containsKey(udayamLord)) {
      double udeg = planetDegrees[udayamLord] ?? 0.0;
      udayamLordRasiIdx = (udeg / 30.0).floor() % 12;
    } else if (results['outer']?['planet_degrees']?[udayamLord] != null) {
      double udeg = (results['outer']['planet_degrees'][udayamLord] as num).toDouble();
      udayamLordRasiIdx = (udeg / 30.0).floor() % 12;
    } else if (results['inner']?['planet_details'] != null) {
      (results['inner']['planet_details'] as Map).forEach((pKey, pVal) {
        if (pKey.toString().toLowerCase() == udayamLord.toLowerCase()) {
          udayamLordRasiIdx = KPService.SIGNS.indexOf(pVal['rasi'] ?? "Aries");
          if (udayamLordRasiIdx < 0) {
            double udeg = (pVal['longitude'] ?? 0.0).toDouble();
            udayamLordRasiIdx = (udeg / 30.0).floor() % 12;
          }
        }
      });
    }
    int udayamLordHouse = ((udayamLordRasiIdx - udayamIdx + 12) % 12) + 1;

    // 10. Udayam vs Arudam (உதயம் vs ஆருடம்)
    int udayamVsArudam = ((arudamIdx - udayamIdx + 12) % 12) + 1;

    // 11. Udayam vs Kavippu (உதயம் vs கவிப்பு)
    int udayamVsKavi = ((kaviIdx - udayamIdx + 12) % 12) + 1;

    // 12. Arudam vs Udayam (ஆருடம் vs உதயம்)
    int arudamVsUdayam = ((udayamIdx - arudamIdx + 12) % 12) + 1;

    // 13. Arudam vs Kavippu (ஆருடம் vs கவிப்பு)
    int arudamVsKavi = ((kaviIdx - arudamIdx + 12) % 12) + 1;

    // 11. 8th Lord (அஷ்டமாதிபதி)
    int eighthSignIdx = (udayamIdx + 7) % 12;
    String eighthLord = SIGN_LORDS[KPService.SIGNS[eighthSignIdx]] ?? "Sun";
    int eighthLordRasiIdx = 0;
    if (results['inner']?['planet_details'] != null) {
      (results['inner']['planet_details'] as Map).forEach((pKey, pVal) {
        if (pKey.toString().toLowerCase() == eighthLord.toLowerCase()) {
          eighthLordRasiIdx = KPService.SIGNS.indexOf(pVal['rasi'] ?? "Aries");
        }
      });
    }
    int eighthLordHouse = ((eighthLordRasiIdx - udayamIdx + 12) % 12) + 1;
    final eighthLordMap = {
      'lord': eighthLord,
      'house': eighthLordHouse,
    };

    // 12. Badhakadhipathi (பாதகாதிபதி)
    int badhakaOffset = 10; // default movable (11th house is offset 10)
    int uType = udayamIdx % 3;
    if (uType == 0) badhakaOffset = 10; // Movable: 11th
    else if (uType == 1) badhakaOffset = 8; // Fixed: 9th
    else badhakaOffset = 6; // Dual: 7th
    
    int badhakaSignIdx = (udayamIdx + badhakaOffset) % 12;
    String badhakaLord = SIGN_LORDS[KPService.SIGNS[badhakaSignIdx]] ?? "Sun";
    int badhakaLordRasiIdx = 0;
    if (results['inner']?['planet_details'] != null) {
      (results['inner']['planet_details'] as Map).forEach((pKey, pVal) {
        if (pKey.toString().toLowerCase() == badhakaLord.toLowerCase()) {
          badhakaLordRasiIdx = KPService.SIGNS.indexOf(pVal['rasi'] ?? "Aries");
        }
      });
    }
    int badhakaLordHouse = ((badhakaLordRasiIdx - udayamIdx + 12) % 12) + 1;
    final badhakaLordMap = {
      'lord': badhakaLord,
      'house': badhakaLordHouse,
      'type_offset': badhakaOffset + 1,
    };

    // 14. Sootchuma Rasi (சூட்சும ராசி)
    // உதயத்திலிருந்து ஆருட அதிபதி நிற்கும் எண்ணிக்கையை ஆருட அதிபதியிலிருந்து எண்ணி வரும் ராசி சூட்சும ராசி
    int countSigns = ((arudamLordRasiIdx - udayamIdx + 12) % 12) + 1;
    int sootchumaRasiIdx = (arudamLordRasiIdx + countSigns - 1) % 12;

    final sootchumaMap = {
      'rasi': KPService.SIGNS[sootchumaRasiIdx],
      'count': countSigns,
    };

    // 15. Outer Planet Ucham / Neecham (உச்சம் / நீச்சம்)
    List<String> uchamPlanets = [];
    List<String> neechamPlanets = [];
    planetDegrees.forEach((p, deg) {
      if (p != "Rahu" && p != "Ketu" && p != "பாம்பு" && p != "Maanthi") {
        String sign = KPService.SIGNS[(deg / 30.0).floor() % 12];
        if (UCHAM[p] == sign) {
          uchamPlanets.add(p);
        } else if (NEECHAM[p] == sign) {
          neechamPlanets.add(p);
        }
      }
    });

    // 16. Rasi Parivarthanai (இராசிப் பரிவர்த்தனை)
    List<String> parivarthana = [];
    List<Map<String, String>> parivarthanaDetails = [];
    Map<String, String> planetInSign = {};
    planetDegrees.forEach((p, deg) {
      if (p != "Rahu" && p != "Ketu" && p != "பாம்பு" && p != "Maanthi") {
        planetInSign[p] = KPService.SIGNS[(deg / 30.0).floor() % 12];
      }
    });
    List<String> keys = planetInSign.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      for (int j = i + 1; j < keys.length; j++) {
        String p1 = keys[i];
        String p2 = keys[j];
        String s1 = planetInSign[p1]!;
        String s2 = planetInSign[p2]!;
        if (SIGN_LORDS[s1] == p2 && SIGN_LORDS[s2] == p1) {
          parivarthana.add("$p1-$p2");
          int s1Idx = KPService.SIGNS.indexOf(s1);
          int s2Idx = KPService.SIGNS.indexOf(s2);
          String signA, signB, planetA, planetB;
          if (s2Idx <= s1Idx) {
            signA = s2;
            planetA = p1;
            signB = s1;
            planetB = p2;
          } else {
            signA = s1;
            planetA = p2;
            signB = s2;
            planetB = p1;
          }
          parivarthanaDetails.add({
            'planet1': planetA,
            'planet2': planetB,
            'sign1': signA,
            'sign2': signB,
          });
        }
      }
    }

    return {
      'udayam_contact': udayamContacts,
      'udayam_star': udayamStarMap,
      'crossed_planet': crossedPlanetMap,
      'arudam_house_details': arudamHouseMap,
      'arudam_contact': arudamContactMap,
      'kavi_house_details': kaviHouseMap,
      'kavi_planet_details': kaviPlanetMap,
      'arudam_lord_house': arudamLordHouse,
      'udayam_lord_house': udayamLordHouse,
      'udayam_vs_arudam': udayamVsArudam,
      'udayam_vs_kavi': udayamVsKavi,
      'arudam_vs_udayam': arudamVsUdayam,
      'arudam_vs_kavi': arudamVsKavi,
      'eighth_lord_details': eighthLordMap,
      'badhaka_lord_details': badhakaLordMap,
      'parivarthana': parivarthana,
      'parivarthana_details': parivarthanaDetails,
      'sootchuma_details': sootchumaMap,
      'ucham_planets': uchamPlanets,
      'neecham_planets': neechamPlanets,
    };
  }
  static const Map<String, List<String>> GOWRI_TYPES = {
    'ta': ["அமிர்தம்", "சுகம்", "லாபம்", "தனம்", "உத்தியோகம்", "ரோகம்", "சோரம்", "விஷம்"],
    'en': ["Amirtham", "Sugam", "Labam", "Dhanam", "Uthiyogam", "Rogam", "Soram", "Visham"],
    'hi': ["अमृतम", "सुखम", "लाभम", "धनम", "उद्योगाम", "रोगम", "सोरम", "विषम"]
  };

  static const Map<int, List<int>> GOWRI_DAY_SEQ = {
    0: [4, 0, 5, 2, 3, 1, 6, 7], // Sun: உத்தி, அமிர்தம், ரோகம், லாபம், தனம், சுகம், சோரம், விஷம்
    1: [0, 7, 5, 2, 3, 1, 6, 4], // Mon: அமிர்தம், விஷம், ரோகம், லாபம், தனம், சுகம், சோரம், உத்தி
    2: [5, 2, 3, 1, 6, 4, 7, 0], // Tue: ரோகம், லாபம், தனம், சுகம், சோரம், உத்தி, விஷம், அமிர்தம்
    3: [2, 3, 1, 6, 7, 4, 0, 5], // Wed: லாபம், தனம், சுகம், சோரம், விஷம், உத்தி, அமிர்தம், ரோகம்
    4: [3, 1, 6, 4, 0, 7, 5, 2], // Thu: தனம், சுகம், சோரம், உத்தி, அமிர்தம், விஷம், ரோகம், லாபம்
    5: [1, 6, 4, 7, 0, 5, 2, 3], // Fri: சுகம், சோரம், உத்தி, விஷம், அமிர்தம், ரோகம், லாபம், தனம்
    6: [6, 4, 7, 0, 5, 2, 3, 1], // Sat: சோரம், உத்தி, விஷம், அமிர்தம், ரோகம், லாபம், தனம், சுகம்
  };

  static const Map<int, List<int>> GOWRI_NIGHT_SEQ = {
    0: [3, 1, 6, 7, 4, 0, 5, 2], // Sun: தனம், சுகம், சோரம், விஷம், உத்தி, அமிர்தம், ரோகம், லாபம்
    1: [1, 6, 4, 0, 7, 5, 2, 3], // Mon: சுகம், சோரம், உத்தி, அமிர்தம், விஷம், ரோகம், லாபம், தனம்
    2: [6, 4, 7, 0, 5, 2, 3, 1], // Tue: சோரம், உத்தி, விஷம், அமிர்தம், ரோகம், லாபம், தனம், சுகம்
    3: [4, 0, 5, 2, 3, 1, 6, 7], // Wed: உத்தி, அமிர்தம், ரோகம், லாபம், தனம், சுகம், சோரம், விஷம்
    4: [0, 7, 5, 2, 3, 1, 6, 4], // Thu: அமிர்தம், விஷம், ரோகம், லாபம், தனம், சுகம், சோரம், உத்தி
    5: [5, 2, 3, 1, 6, 4, 7, 0], // Fri: ரோகம், லாபம், தனம், சுகம், சோரம், உத்தி, விஷம், அமிர்தம்
    6: [2, 3, 1, 6, 4, 7, 0, 5], // Sat: லாபம், தனம், சுகம், சோரம், உத்தி, விஷம், அமிர்தம், ரோகம்
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
    if (dt.isBefore(sunrise)) {
      weekday = (weekday - 1 + 7) % 7;
    }

    int gowriIdx = isDay ? GOWRI_DAY_SEQ[weekday]![currentSegment] : GOWRI_NIGHT_SEQ[weekday]![currentSegment];

    // Rahu, Yama, Gulika, Artha Segments (Day only)
    Map<String, int> daySegments = {
      'rahu': [7, 1, 6, 4, 5, 3, 2][weekday], // 0-indexed segment
      'yama': [4, 3, 2, 1, 0, 6, 5][weekday],
      'kuli': [6, 5, 4, 3, 2, 1, 0][weekday],
      'artha': [3, 2, 1, 0, 6, 5, 4][weekday],
    };

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

  static bool isPlanetCombust(String planetName, double planetLon, double sunLon, bool isRetro) {
    if (planetName == 'Sun' || planetName == 'Rahu' || planetName == 'Ketu' || planetName == 'Maanthi' || planetName == 'Lagna') {
      return false;
    }
    double diff = (planetLon - sunLon).abs();
    if (diff > 180) diff = 360 - diff;

    if (planetName == 'Moon') return diff < 12.0;
    if (planetName == 'Mars') return diff < 17.0;
    if (planetName == 'Mercury') return diff < (isRetro ? 12.0 : 14.0);
    if (planetName == 'Jupiter') return diff < 11.0;
    if (planetName == 'Venus') return diff < (isRetro ? 8.0 : 10.0);
    if (planetName == 'Saturn') return diff < 15.0;

    return false;
  }
}

class SubPlanetResult {
  final String name;
  final int rasi;      // 1 to 12
  final double degree; // 0.0 to 30.0

  SubPlanetResult({required this.name, required this.rasi, required this.degree});
}

class JamakkolSubPlanets {
  final bool isDay;
  final int currentYama;
  final SubPlanetResult marana;
  final SubPlanetResult rahu;
  final SubPlanetResult mrityu;
  final SubPlanetResult yamagandan;

  JamakkolSubPlanets({
    required this.isDay,
    required this.currentYama,
    required this.marana,
    required this.rahu,
    required this.mrityu,
    required this.yamagandan,
  });
}

JamakkolSubPlanets calculateAllJamakkolSubPlanets({
  required DateTime currentTime,
  required DateTime sunrise,
  required DateTime sunset,
  required DateTime nextSunrise,
  required DateTime prevSunset,
  required double sunLon,
}) {
  bool isDay = !currentTime.isBefore(sunrise) && currentTime.isBefore(sunset);

  DateTime astroDay = currentTime.isBefore(sunrise)
      ? sunrise.subtract(const Duration(days: 1))
      : sunrise;
  int weekday = astroDay.weekday % 7; // 0=Sunday, 1=Monday, ..., 6=Saturday

  DateTime startTime;
  DateTime endTime;
  if (isDay) {
    startTime = sunrise;
    endTime = sunset;
  } else {
    if (!currentTime.isBefore(sunset)) {
      startTime = sunset;
      endTime = nextSunrise;
    } else {
      startTime = prevSunset;
      endTime = sunrise;
    }
  }

  double totalDurationSeconds = endTime.difference(startTime).inSeconds.toDouble();
  double elapsedTimeSeconds = currentTime.difference(startTime).inSeconds.toDouble();
  if (elapsedTimeSeconds < 0) elapsedTimeSeconds = 0;
  if (elapsedTimeSeconds > totalDurationSeconds) elapsedTimeSeconds = totalDurationSeconds;

  double elapsedFraction = elapsedTimeSeconds / totalDurationSeconds;

  // 1 Yama = 1/8th of total day or night duration
  int currentYama = (elapsedFraction * 8).floor() + 1;
  if (currentYama < 1) currentYama = 1;
  if (currentYama > 8) currentYama = 8;

  // Individual Base Rasi Tables (0:Aries, 1:Taurus, ..., 11:Pisces)
  // Weekdays: 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat

  // பகல் நேர 1-ஆம் ஜாம தொடக்க ராசிகள்
  const List<int> maranaDayBases = [8,  0, 6, 3,  5, 1,  8]; // Sat: Sg(8)  -> Yama 4 = Pi(11)

  // இரவு நேர 1-ஆம் ஜாம தொடக்க ராசிகள்
  const List<int> maranaNightBases = [6, 4, 4, 8, 7, 7, 4]; // Mon:Le(4), Tue:Le(4), Wed:Sg(8), Thu:Sc(7)

  int baseMarana = isDay ? maranaDayBases[weekday] : maranaNightBases[weekday];

  // Degree Offset Calculation per subplanet, weekday, period, and yama
  double getSubPlanetOffset(String name, int weekday, bool isDay, int yama) {
    if (isDay) {
      if (weekday == 3) { // Wednesday Day
        if (name == "Marana") return -6.0;
      } else if (weekday == 1) { // Monday Day
        if (name == "Marana") return 12.0;
      } else if (weekday == 6) { // Saturday Day
        if (name == "Marana") return 12.0;
      }
    } else { // Night
      if (weekday == 1) { // Monday Night
        if (name == "Marana") return -24.0;
      } else if (weekday == 2) { // Tuesday Night
        if (name == "Marana") return 12.0;
      } else if (weekday == 3) { // Wednesday Night
        if (name == "Marana") return 6.0;
      } else if (weekday == 4) { // Thursday Night
        if (name == "Marana") return 12.0;
      }
    }

    if (name == "Marana") return 12.0;
    return 0.0;
  }

  // Degrees derived from Sun's longitude in its current sign
  double sunDeg = (sunLon % 30.0 + 30.0) % 30.0;
  double maranaDeg = (sunDeg + getSubPlanetOffset("Marana", weekday, isDay, currentYama) + 30.0) % 30.0;

  // இராகு காலம் (ரா.கா) கணிதம்:
  // இராகு (பகல்) ஆளுமை பாகை அளவு:
  // ஞா = +180°, தி = +36°, செ = +156°, பு = +108°, வி = +132°, வெ = +84°, சனி = +60°
  // Weekdays: 0=ஞா (Sun), 1=தி (Mon), 2=செ (Tue), 3=பு (Wed), 4=வி (Thu), 5=வெ (Fri), 6=சனி (Sat)
  const List<double> rahuDayDegrees = [180.0, 36.0, 156.0, 108.0, 132.0, 84.0, 60.0];

  // இராகு (இரவு) பாகை அளவுகள்:
  // ஞா = +264°, தி = +288°, செ = +240°, பு = +0°, வி = +216°, வெ = +336°, சனி = +312°
  const List<double> rahuNightDegrees = [264.0, 288.0, 240.0, 0.0, 216.0, 336.0, 312.0];

  double rahuOffset = isDay ? rahuDayDegrees[weekday] : rahuNightDegrees[weekday];

  // சூரியன் இருக்கும் ராசி மற்றும் ராசிக்குள் உள்ள பாகை
  int sunRasiIndex = (sunLon / 30.0).floor() % 12;
  double sunDegInSign = (sunLon % 30.0 + 30.0) % 30.0;

  // சூரியன் பாகையுடன் கிழமையின் ராகு பாகையைக் கூட்டி,
  // வந்த விடையை சூரியன் இருக்கும் ராசியில் இருந்து எண்ணிப் போடுதல் (ராசி 30 பாகை வீதம்)
  double totalRahuSum = sunDegInSign + rahuOffset;
  int signsToAdd = (totalRahuSum / 30.0).floor();
  int rahuRasiIndex = (sunRasiIndex + signsToAdd) % 12;
  double rahuDegree = (totalRahuSum % 30.0 + 30.0) % 30.0;
  int rahuRasiNumber = rahuRasiIndex + 1; // 1 to 12

  final rahuResult = SubPlanetResult(
    name: "Rahu",
    rasi: rahuRasiNumber,
    degree: rahuDegree,
  );

  // மிருத்யு (மிரு) கணிதம்:
  // மிருத்யு (பகல்) ஆளுமை பாகை அளவுகள்:
  // ஞா = +60°, தி = +36°, செ = +12°, பு = +156°, வி = +132°, வெ = +108°, சனி = +84°
  // Weekdays: 0=ஞா (Sun), 1=தி (Mon), 2=செ (Tue), 3=பு (Wed), 4=வி (Thu), 5=வெ (Fri), 6=சனி (Sat)
  const List<double> mrityuDayDegrees = [60.0, 36.0, 12.0, 156.0, 132.0, 108.0, 84.0];

  // மிருத்யு (இரவு) பாகை அளவுகள்:
  // ஞா = +312°, தி = +288°, செ = +264°, பு = +240°, வி = +216°, வெ = +192°, சனி = +336°
  const List<double> mrityuNightDegrees = [312.0, 288.0, 264.0, 240.0, 216.0, 192.0, 336.0];

  double mrityuOffset = isDay ? mrityuDayDegrees[weekday] : mrityuNightDegrees[weekday];

  // சூரியன் பாகையுடன் கிழமையின் மிருத்யு பாகையைக் கூட்டி,
  // வந்த விடையை சூரியன் இருக்கும் ராசியில் இருந்து எண்ணிப் போடுதல் (ராசி 30 பாகை வீதம்)
  double totalMrityuSum = sunDegInSign + mrityuOffset;
  int mrityuSignsToAdd = (totalMrityuSum / 30.0).floor();
  int mrityuRasiIndex = (sunRasiIndex + mrityuSignsToAdd) % 12;
  double mrityuDegree = (totalMrityuSum % 30.0 + 30.0) % 30.0;
  int mrityuRasiNumber = mrityuRasiIndex + 1; // 1 to 12

  final mrityuResult = SubPlanetResult(
    name: "Mrityu",
    rasi: mrityuRasiNumber,
    degree: mrityuDegree,
  );

  // எமகண்டன் (யம) கணிதம்:
  // எமகண்டன் (பகல்) ஆளுமை பாகை அளவுகள்:
  // ஞா = +108°, தி = +84°, செ = +60°, பு = +36°, வி = +12°, வெ = +156°, சனி = +132°
  // Weekdays: 0=ஞா (Sun), 1=தி (Mon), 2=செ (Tue), 3=பு (Wed), 4=வி (Thu), 5=வெ (Fri), 6=சனி (Sat)
  const List<double> yamaDayDegrees = [108.0, 84.0, 60.0, 36.0, 12.0, 156.0, 132.0];

  // எமகண்டன் (இரவு) பாகை அளவுகள்:
  // ஞா = +192°, தி = +336°, செ = +312°, பு = +288°, வி = +264°, வெ = +240°, சனி = +216°
  const List<double> yamaNightDegrees = [192.0, 336.0, 312.0, 288.0, 264.0, 240.0, 216.0];

  double yamaOffset = isDay ? yamaDayDegrees[weekday] : yamaNightDegrees[weekday];

  // சூரியன் பாகையுடன் கிழமையின் எமகண்ட பாகையைக் கூட்டி,
  // வந்த விடையை சூரியன் இருக்கும் ராசியில் இருந்து எண்ணிப் போடுதல் (ராசி 30 பாகை வீதம்)
  double totalYamaSum = sunDegInSign + yamaOffset;
  int yamaSignsToAdd = (totalYamaSum / 30.0).floor();
  int yamaRasiIndex = (sunRasiIndex + yamaSignsToAdd) % 12;
  double yamaDegree = (totalYamaSum % 30.0 + 30.0) % 30.0;
  int yamaRasiNumber = yamaRasiIndex + 1; // 1 to 12

  final yamaResult = SubPlanetResult(
    name: "Yamagandan",
    rasi: yamaRasiNumber,
    degree: yamaDegree,
  );

  SubPlanetResult calculateSubPlanet(String name, int baseRasiIndex, double degree) {
    int targetRasiIndex = (baseRasiIndex + (currentYama - 1)) % 12;
    int targetRasiNumber = targetRasiIndex + 1; // 1 to 12
    return SubPlanetResult(
      name: name,
      rasi: targetRasiNumber,
      degree: degree,
    );
  }

  return JamakkolSubPlanets(
    isDay: isDay,
    currentYama: currentYama,
    marana: calculateSubPlanet("Marana", baseMarana, maranaDeg),
    rahu: rahuResult,
    mrityu: mrityuResult,
    yamagandan: yamaResult,
  );
}

