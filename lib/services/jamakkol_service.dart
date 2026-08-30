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
      if (planet == "Rahu" || planet == "Ketu" || planet == "Maanthi") return "-";
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

    // 1. Planet contacting Udayam (உதயம் தொடர்பு கொள்ளும் கிரகம்)
    List<Map<String, dynamic>> udayamContacts = [];
    planetDegrees.forEach((p, deg) {
      int pSign = (deg / 30.0).floor() % 12;
      if (pSign == udayamIdx % 12) {
        udayamContacts.add({
          'planet': p,
          'deg': deg,
          'house': ((pSign - udayamIdx + 12) % 12) + 1,
          'lordship': getLordshipString(p, udayamIdx),
        });
      }
    });

    // 2. Udayam star pada (உதயம் நின்ற நட்சத்திர பாதம்)
    final udayamStar = getNakshatraInfo(udayamAbsDeg);
    final udayamStarMap = {
      'deg': udayamAbsDeg,
      'nakshatra': udayamStar['nakshatra'],
      'pada': udayamStar['pada'],
      'lord': udayamStar['lord'],
      'lordship': getLordshipString(udayamStar['lord'], udayamIdx),
    };

    // 3. Planet that crossed Udayam (உதயத்தை கடந்த கிரகம்)
    String? crossedPlanet;
    double crossedMinDiff = 360.0;
    double crossedDeg = 0.0;
    planetDegrees.forEach((p, pDeg) {
      double relDeg = pDeg - udayamAbsDeg;
      if (relDeg < -180) relDeg += 360;
      if (relDeg > 180) relDeg -= 360;
      if (relDeg < 0) {
        double absRel = relDeg.abs();
        if (absRel < crossedMinDiff) {
          crossedMinDiff = absRel;
          crossedPlanet = p;
          crossedDeg = pDeg;
        }
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

    // 5. Planet contacting Arudam (ஆருடம் தொடர்பு கொள்ளும் கிரகம்)
    String? approachingArudamPlanet;
    double approachingArudamMinDiff = 360.0;
    double approachingArudamDeg = 0.0;
    planetDegrees.forEach((p, pDeg) {
      double relDeg = pDeg - arudamAbsDegVal;
      if (relDeg < -180) relDeg += 360;
      if (relDeg > 180) relDeg -= 360;
      if (relDeg > 0) {
        if (relDeg < approachingArudamMinDiff) {
          approachingArudamMinDiff = relDeg;
          approachingArudamPlanet = p;
          approachingArudamDeg = pDeg;
        }
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

    // 7. Planet covered by Kavippu (கவிக்கப்படும் கிரகம்)
    String? kaviPlanet;
    double kaviPlanetDeg = 0.0;
    planetDegrees.forEach((p, pDeg) {
      int pSign = (pDeg / 30.0).floor() % 12;
      if (pSign == kaviIdx % 12) {
        kaviPlanet = p;
        kaviPlanetDeg = pDeg;
      }
    });
    if (kaviPlanet == null) {
      double minDiff = 360.0;
      planetDegrees.forEach((p, pDeg) {
        double diff = (pDeg - kaviAbsDeg).abs();
        if (diff > 180) diff = 360 - diff;
        if (diff < minDiff) {
          minDiff = diff;
          kaviPlanet = p;
          kaviPlanetDeg = pDeg;
        }
      });
    }
    final kaviPlanetStar = kaviPlanet != null ? getNakshatraInfo(kaviPlanetDeg) : null;
    final kaviPlanetMap = kaviPlanet != null ? {
      'planet': kaviPlanet,
      'deg': kaviPlanetDeg,
      'lordship': getLordshipString(kaviPlanet!, udayamIdx),
      'nakshatra': kaviPlanetStar!['nakshatra'],
      'pada': kaviPlanetStar['pada'],
    } : null;

    // 8. Arudam Lord's House (ஆருடாதிபதி நின்ற பாவம்)
    double arudamLordDeg = planetDegrees[arudamLord] ?? 0.0;
    int arudamLordHouse = (((arudamLordDeg / 30.0).floor() - udayamIdx + 12) % 12) + 1;

    // 9. Arudam vs Udayam (ஆருடம் vs உதயம்)
    int arudamVsUdayam = ((udayamIdx - arudamIdx + 12) % 12) + 1;

    // 10. Arudam vs Kavippu (ஆருடம் vs கவிப்பு)
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

    // 13. Rasi Parivarthanai (இராசிப் பரிவர்த்தனை)
    List<String> parivarthana = [];
    Map<String, String> planetInSign = {};
    planetDegrees.forEach((p, deg) {
      planetInSign[p] = KPService.SIGNS[(deg / 30.0).floor() % 12];
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
        }
      }
    }

    // 14. Sootchuma Rasi (சூட்சும ராசி)
    int arudamLordSignIdx = (arudamLordDeg / 30.0).floor() % 12;
    int countSigns = ((arudamLordSignIdx - udayamIdx + 12) % 12) + 1;
    int sootchumaRasiIdx = (arudamLordSignIdx + countSigns - 1) % 12;
    
    // Pada-based Sootchuma Rasi
    int udayamAbsolutePada = udayamStar['absolute_pada'];
    int arudamAbsolutePada = arudamStar['absolute_pada'];
    int countPadas = (arudamAbsolutePada - udayamAbsolutePada + 108) % 108 + 1;
    
    int arudamLordAbsolutePada = (arudamLordDeg / (360.0 / 108.0)).floor() % 108;
    int targetAbsolutePada = (arudamLordAbsolutePada + countPadas - 1) % 108;
    int targetRasiIdx = (targetAbsolutePada / 9).floor() % 12;
    int targetNakIdx = (targetAbsolutePada / 4).floor() % 27;
    int targetPadaNum = (targetAbsolutePada % 4) + 1;
    
    final sootchumaMap = {
      'rasi': KPService.SIGNS[sootchumaRasiIdx],
      'pada_rasi': KPService.SIGNS[targetRasiIdx],
      'pada_nakshatra': KPService.NAKSHATRAS[targetNakIdx],
      'pada_num': targetPadaNum,
    };

    return {
      'udayam_contact': udayamContacts,
      'udayam_star': udayamStarMap,
      'crossed_planet': crossedPlanetMap,
      'arudam_house_details': arudamHouseMap,
      'arudam_contact': arudamContactMap,
      'kavi_house_details': kaviHouseMap,
      'kavi_planet_details': kaviPlanetMap,
      'arudam_lord_house': arudamLordHouse,
      'arudam_vs_udayam': arudamVsUdayam,
      'arudam_vs_kavi': arudamVsKavi,
      'eighth_lord_details': eighthLordMap,
      'badhaka_lord_details': badhakaLordMap,
      'parivarthana': parivarthana,
      'sootchuma_details': sootchumaMap,
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
  final SubPlanetResult rahu;
  final SubPlanetResult yamagandan;
  final SubPlanetResult mrityu;

  JamakkolSubPlanets({
    required this.isDay,
    required this.currentYama,
    required this.rahu,
    required this.yamagandan,
    required this.mrityu,
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

  // 1 Jamam = 90 Minutes (approx 1/8 of total day/night duration)
  int currentJamam = (elapsedFraction * 8).floor() + 1;
  if (currentJamam < 1) currentJamam = 1;
  if (currentJamam > 8) currentJamam = 8;

  double totalMins = elapsedTimeSeconds / 60.0;
  double elapsedMinsInCurrentJamam = totalMins % (totalDurationSeconds / 8.0 / 60.0);

  // Yamagandan and Rahu Kaal Jamam Indices (Sunday=0, Monday=1, ..., Saturday=6)
  final List<int> yamaDayJamams = [5, 4, 3, 2, 1, 7, 6];
  final List<int> yamaNightJamams = [5, 3, 8, 7, 5, 3, 1];
  final List<int> rahuDayJamams = [8, 2, 7, 5, 6, 4, 3];
  final List<int> rahuNightJamams = [5, 1, 6, 4, 7, 3, 2];

  int yamaJ = isDay ? yamaDayJamams[weekday] : yamaNightJamams[weekday];
  int rahuJ = isDay ? rahuDayJamams[weekday] : rahuNightJamams[weekday];

  // Starting base signs (used when C < J)
  final List<int> yamaDayBases = [10, 7, 4, 1, 10, 7, 4];
  final List<int> yamaNightBases = [12, 9, 6, 3, 12, 9, 6];
  final List<int> rahuDayBases = [5, 3, 2, 1, 9, 7, 8];
  final List<int> rahuNightBases = [1, 10, 8, 9, 6, 4, 3];

  int yamaBase = isDay ? yamaDayBases[weekday] : yamaNightBases[weekday];
  int rahuBase = isDay ? rahuDayBases[weekday] : rahuNightBases[weekday];

  // Mrityu Bases (continuous calculation)
  final List<int> mrityuDayBases = [5, 2, 11, 8, 5, 2, 11];
  final List<int> mrityuNightBases = [11, 8, 5, 2, 11, 8, 5];
  int mrityuBase = isDay ? mrityuDayBases[weekday] : mrityuNightBases[weekday];

  // Calculate Yamagandan/Rahu position (using Sun's sign as 1st house, shifts by C - J houses clockwise/adding)
  SubPlanetResult calculateJamamPlanet(String name, int startJamam, int baseSign) {
    int sunSign = (sunLon / 30.0).floor() + 1; // 1 to 12
    double sunDeg = sunLon % 30.0;

    int targetSign = sunSign;
    double targetDeg = sunDeg;

    if (currentJamam < startJamam) {
      targetSign = baseSign;
      targetDeg = sunDeg;
    } else {
      // Moves by (currentJamam - startJamam) signs
      int signsShift = currentJamam - startJamam;
      double degShift = 0.0;
      if (currentJamam == startJamam) {
        degShift = elapsedMinsInCurrentJamam * (30.0 / 90.0); // 20' per minute
      }
      
      double finalLon = ((sunSign - 1) * 30.0 + sunDeg + signsShift * 30.0 + degShift) % 360.0;
      targetSign = (finalLon / 30.0).floor() + 1;
      targetDeg = finalLon % 30.0;
    }

    return SubPlanetResult(name: name, rasi: targetSign, degree: targetDeg);
  }

  // Mrityu continuous clockwise calculation
  double mrityuStartLon = (mrityuBase - 1) * 30.0;
  double mrityuLon = (mrityuStartLon - elapsedFraction * 360.0) % 360.0;
  if (mrityuLon < 0) mrityuLon += 360.0;
  int mrityuRasi = (mrityuLon / 30.0).floor() + 1;
  double mrityuDegree = mrityuLon % 30.0;

  return JamakkolSubPlanets(
    isDay: isDay,
    currentYama: currentJamam,
    rahu: calculateJamamPlanet("Rahu", rahuJ, rahuBase),
    yamagandan: calculateJamamPlanet("Yamagandan", yamaJ, yamaBase),
    mrityu: SubPlanetResult(name: "Mrityu", rasi: mrityuRasi, degree: mrityuDegree),
  );
}

