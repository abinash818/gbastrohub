import 'dart:io' show Directory, File;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../astro_engine/astro_engine.dart';
import 'package:path_provider/path_provider.dart';
import '../data/nakshatra_data.dart';
import 'settings_service.dart';
import 'astro_special_calculations_service.dart';
import 'shadbala_service.dart';


class KPService {
  static bool _isInit = false;

  static const List<String> SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
  ];

  static const Map<String, String> TAMIL_SIGNS = {
    'Aries': 'மேஷம்', 'Taurus': 'ரிஷபம்', 'Gemini': 'மிதுனம்', 'Cancer': 'கடகம்',
    'Leo': 'சிம்மம்', 'Virgo': 'கன்னி', 'Libra': 'துலாம்', 'Scorpio': 'விருச்சிகம்',
    'Sagittarius': 'தனுசு', 'Capricorn': 'மகரம்', 'Aquarius': 'கும்பம்', 'Pisces': 'மீனம்'
  };

  static const Map<String, String> ENGLISH_SIGNS = {
    'Aries': 'Aries', 'Taurus': 'Taurus', 'Gemini': 'Gemini', 'Cancer': 'Cancer',
    'Leo': 'Leo', 'Virgo': 'Virgo', 'Libra': 'Libra', 'Scorpio': 'Scorpio',
    'Sagittarius': 'Sagittarius', 'Capricorn': 'Capricorn', 'Aquarius': 'Aquarius', 'Pisces': 'Pisces'
  };

  static const Map<String, String> HINDI_SIGNS = {
    'Aries': 'मेष', 'Taurus': 'वृषभ', 'Gemini': 'मिथुन', 'Cancer': 'कर्क',
    'Leo': 'सिंह', 'Virgo': 'कन्या', 'Libra': 'तुला', 'Scorpio': 'वृश्चिक',
    'Sagittarius': 'धनु', 'Capricorn': 'मकर', 'Aquarius': 'कुंभ', 'Pisces': 'मीन'
  };

  static const Map<String, String> ENGLISH_PLANETS = {
    'Sun': 'Sun', 'Moon': 'Moon', 'Mars': 'Mars', 'Mercury': 'Mercury',
    'Jupiter': 'Jupiter', 'Venus': 'Venus', 'Saturn': 'Saturn', 'Rahu': 'Rahu', 'Ketu': 'Ketu',
    'Lagna': 'Lagna', 'Maanthi': 'Maanthi'
  };

  static const Map<String, String> HINDI_PLANETS = {
    'Sun': 'सूर्य', 'Moon': 'चंद्र', 'Mars': 'मंगल', 'Mercury': 'बुध',
    'Jupiter': 'गुरु', 'Venus': 'शुक्र', 'Saturn': 'शनि', 'Rahu': 'राहु', 'Ketu': 'केतु',
    'Lagna': 'लग्न', 'Maanthi': 'मांदी'
  };

  static const Map<String, String> TAMIL_PLANET_SHORT = {
    'Sun': 'சூரி', 'Moon': 'சந்', 'Mars': 'செவ்', 'Mercury': 'புத',
    'Jupiter': 'குரு', 'Venus': 'சுக்', 'Saturn': 'சனி', 'Rahu': 'ராகு', 'Ketu': 'கேது', 'Lagna': 'லக்',
    'Maanthi': 'மாந்'
  };

  static const Map<String, String> ENGLISH_PLANET_SHORT = {
    'Sun': 'Su', 'Moon': 'Mo', 'Mars': 'Ma', 'Mercury': 'Me',
    'Jupiter': 'Ju', 'Venus': 'Ve', 'Saturn': 'Sa', 'Rahu': 'Ra', 'Ketu': 'Ke', 'Lagna': 'Asc',
    'Maanthi': 'Mn'
  };

  static const Map<String, String> HINDI_PLANET_SHORT = {
    'Sun': 'सू', 'Moon': 'चं', 'Mars': 'मं', 'Mercury': 'बु',
    'Jupiter': 'गु', 'Venus': 'शु', 'Saturn': 'श', 'Rahu': 'रा', 'Ketu': 'के', 'Lagna': 'ल',
    'Maanthi': 'मां'
  };


  static const List<String> NAKSHATRAS = [
    "Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashirsha", "Arudra",
    "Punarvasu", "Pushya", "Aslesha", "Magha", "Purvaphalguni", "Uttaraphalguni",
    "Hastha", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshta",
    "Mula", "Purvashada", "Uttarashada", "Shravana", "Dhanishta", "Shatabhisha",
    "Purvabhadrapada", "Uttarabhadrapada", "Revati"
  ];

  static const List<String> SIGN_LORDS = [
    'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury', 
    'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter'
  ];

  static const Map<String, String> TAMIL_PLANETS = {
    'Sun': 'சூரியன்', 'Moon': 'சந்திரன்', 'Mars': 'செவ்வாய்', 'Mercury': 'புதன்',
    'Jupiter': 'குரு', 'Venus': 'சுக்கிரன்', 'Saturn': 'சனி', 'Rahu': 'ராகு', 'Ketu': 'கேது',
    'Lagna': 'லக்னம்', 'Maanthi': 'மாந்தி'
  };

  static const Map<String, String> TAMIL_PLANETS_SHORT = {
    'Sun': 'சூரி', 'Moon': 'சந்', 'Mars': 'செவ்', 'Mercury': 'புத',
    'Jupiter': 'குரு', 'Venus': 'சுக்', 'Saturn': 'சனி', 'Rahu': 'ராகு', 'Ketu': 'கேது',
    'Fortuna': 'பார்ச்', 'Maanthi': 'மா', 'Lagna': 'லக்'
  };

  static const List<String> TAMIL_MONTHS = [
    "சித்திரை", "வைகாசி", "ஆனி", "ஆடி", "ஆவணி", "புரட்டாசி",
    "ஐப்பசி", "கார்த்திகை", "மார்கழி", "தை", "மாசி", "பங்குனி"
  ];

  static const List<String> TAMIL_YEARS_60 = [
    "ஸ்ரீ பிரபவ", "ஸ்ரீ விபவ", "ஸ்ரீ சுக்ல", "ஸ்ரீ பிரமோதூத", "ஸ்ரீ பிரஜோற்பத்தி", "ஸ்ரீ ஆங்கீரச", "ஸ்ரீ ஸ்ரீமுக", "ஸ்ரீ பவ", "ஸ்ரீ யுவ", "ஸ்ரீ தாது",
    "ஸ்ரீ ஈஸ்வர", "ஸ்ரீ வெகுதானிய", "ஸ்ரீ பிரமாதி", "ஸ்ரீ விக்ரம", "ஸ்ரீ விஷு", "ஸ்ரீ சித்திரபானு", "ஸ்ரீ சுபானு", "ஸ்ரீ தாரண", "ஸ்ரீ பார்த்திப", "ஸ்ரீ வியய",
    "ஸ்ரீ சர்வஜித்", "ஸ்ரீ சர்வதாரி", "ஸ்ரீ விரோதி", "ஸ்ரீ விக்ருதி", "ஸ்ரீ கர", "ஸ்ரீ நந்தன", "ஸ்ரீ விஜய", "ஸ்ரீ ஜய", "ஸ்ரீ மன்மத", "ஸ்ரீ துன்முகி",
    "ஸ்ரீ ஹேவிளம்பி", "ஸ்ரீ விளம்பி", "ஸ்ரீ விகாரி", "ஸ்ரீ சார்வரி", "ஸ்ரீ பிலவ", "ஸ்ரீ சுபகிருது", "ஸ்ரீ சோபகிருது", "ஸ்ரீ குரோதி", "ஸ்ரீ விசுவாவசு", "ஸ்ரீ பராபவ",
    "ஸ்ரீ பிலவங்க", "ஸ்ரீ கீலக", "ஸ்ரீ சௌமிய", "ஸ்ரீ சாதாரண", "ஸ்ரீ விரோதிகிருது", "ஸ்ரீ பரிதாபி", "ஸ்ரீ பிரமாதீச", "ஸ்ரீ ஆனந்த", "ஸ்ரீ ராட்சஸ", "ஸ்ரீ நள",
    "ஸ்ரீ பிங்கள", "ஸ்ரீ காளயுக்தி", "ஸ்ரீ சித்தார்த்தி", "ஸ்ரீ ரௌத்திரி", "ஸ்ரீ துன்மதி", "ஸ்ரீ துந்துபி", "ஸ்ரீ ருத்ரோத்காரி", "ஸ்ரீ ரக்தாட்சி", "ஸ்ரீ குரோதன", "ஸ்ரீ அட்சய"
  ];

  static bool isPlanetCombust(String planet, double planetLon, double sunLon, bool isRetro) {
    if (planet == 'Sun' || planet == 'Rahu' || planet == 'Ketu' || planet == 'Lagna' || planet == 'Fortuna' || planet == 'Maanthi') {
      return false;
    }
    double diff = (planetLon - sunLon).abs();
    if (diff > 180) diff = 360 - diff;

    Map<String, double> combustOrbs = {
      'Moon': 12.0,
      'Mars': isRetro ? 8.0 : 17.0,
      'Mercury': isRetro ? 12.0 : 14.0,
      'Jupiter': 11.0,
      'Venus': isRetro ? 8.0 : 10.0,
      'Saturn': 15.0,
    };

    double maxOrb = combustOrbs[planet] ?? 10.0;
    return diff <= maxOrb;
  }

  static const Map<String, String> TAMIL_KARANAS = {
    'Bava': 'பவம்',
    'Balava': 'பாலவம்',
    'Kaulava': 'கௌலவம்',
    'Taitila': 'தைதுலை',
    'Garaja': 'கரசை',
    'Vanija': 'வணிசை',
    'Vishti': 'பத்திரை (விஷ்டி)',
    'Shakuni': 'சகுனி',
    'Chatushpada': 'சதுஷ்பாதம்',
    'Nagawa': 'நாகவம்',
    'Kimstughna': 'கிம்துக்கினம்',
  };

  static const List<String> TAMIL_TITHIS = [
    "பிரதமை", "துவிதியை", "திரிதியை", "சதுர்த்தி", "பஞ்சமி", "சஷ்டி",
    "சப்தமி", "அஷ்டமி", "நவமி", "தசமி", "ஏகாதசி", "துவாதசி",
    "திரயோதசி", "சதுர்த்தசி", "பௌர்ணமி",
    "பிரதமை", "துவிதியை", "திரிதியை", "சதுர்த்தி", "பஞ்சமி", "சஷ்டி",
    "சப்தமி", "அஷ்டமி", "நவமி", "தசமி", "ஏகாதசி", "துவாதசி",
    "திரயோதசி", "சதுர்த்தசி", "அமாவாசை"
  ];

  // 1. Initialize Astro Engine
  static Future<void> init() async {
    if (_isInit) return;
    try {
      await AstroEngine.init();
      _isInit = true;
      // print("KPService: Nithya Engine Initialized Successfully");
    } catch (e) {
      print("KPService Error: $e");
    }
  }

  // 2. Get KP Lords for a specific degree (RL, NL, SL, SSL, SSS)
  static Map<String, String> getKPLords(double longitude) {
    longitude = longitude % 360;
    if (longitude < 0) longitude += 360;
    int signIdx = (longitude / 30).floor();
    String sign = SIGNS[signIdx % 12];
    int nakIdx = (longitude / (360 / 27)).floor();
    String nakshatra = NAKSHATRAS[nakIdx % 27];
    String rl = SIGN_LORDS[signIdx % 12];
    String nl = VIMSHOTTARI_LORDS[nakIdx % 9];
    
    double nakStartDegree = nakIdx * (360 / 27);
    double degInNak = longitude - nakStartDegree;
    
    final slRes = _calculateDeepLord(VIMSHOTTARI_LORDS[nakIdx % 9], degInNak, 800); // 800 mins is total nak span
    String sl = slRes['lord'];
    
    final sslRes = _calculateDeepLord(slRes['lord'], slRes['remDeg'], slRes['spanMins']);
    String ssl = sslRes['lord'];
    
    final sssRes = _calculateDeepLord(sslRes['lord'], sslRes['remDeg'], sslRes['spanMins']);
    String sss = sssRes['lord'];

    return <String, String>{
      'sign': sign,
      'signLord': rl,
      'nakshatra': nakshatra,
      'nakLord': nl,
      'subLord': sl,
      'subSubLord': ssl,
      'subSubSubLord': sss
    };
  }

  static Map<String, dynamic> _calculateDeepLord(String startLord, double degreeOffset, double totalSpanMins) {
    double arcMinutes = degreeOffset * 60;
    int startIndex = VIMSHOTTARI_LORDS.indexOf(startLord);
    double currentMinute = 0;
    for (int i = 0; i < 9; i++) {
        int lordIdx = (startIndex + i) % 9;
        String lordName = VIMSHOTTARI_LORDS[lordIdx];
        int years = VIMSHOTTARI_YEARS[lordName]!;
        double spanMinutes = (years / 120) * totalSpanMins;
        if (arcMinutes <= currentMinute + spanMinutes + 0.00001) {
          return {
            'lord': lordName,
            'remDeg': (arcMinutes - currentMinute) / 60.0,
            'spanMins': spanMinutes
          };
        }
        currentMinute += spanMinutes;
    }
    return {'lord': VIMSHOTTARI_LORDS[(startIndex + 8) % 9], 'remDeg': 0.0, 'spanMins': 1.0};
  }

  static String getPlanetDignity(String planet, String rasi) {
    if (planet == 'Lagna') return "-";
    final Map<String, List<String>> ownHouses = {
      'Sun': ['Leo'], 'Moon': ['Cancer'], 'Mars': ['Aries', 'Scorpio'],
      'Mercury': ['Gemini', 'Virgo'], 'Jupiter': ['Sagittarius', 'Pisces'],
      'Venus': ['Taurus', 'Libra'], 'Saturn': ['Capricorn', 'Aquarius']
    };
    final Map<String, String> exaltation = {
      'Sun': 'Aries', 'Moon': 'Taurus', 'Mars': 'Capricorn',
      'Mercury': 'Virgo', 'Jupiter': 'Cancer', 'Venus': 'Pisces', 'Saturn': 'Libra'
    };
    final Map<String, String> debilitation = {
      'Sun': 'Libra', 'Moon': 'Scorpio', 'Mars': 'Cancer',
      'Mercury': 'Pisces', 'Jupiter': 'Capricorn', 'Venus': 'Virgo', 'Saturn': 'Aries'
    };
    final Map<String, List<String>> friends = { 'Sun': ['Aries', 'Leo', 'Sagittarius', 'Scorpio'], 'Moon': ['Taurus', 'Cancer', 'Pisces'] };
    final Map<String, List<String>> enemies = { 'Sun': ['Taurus', 'Libra', 'Capricorn', 'Aquarius'], 'Moon': ['Scorpio', 'Leo'] };
    if (exaltation[planet] == rasi) return "உச்சம்";
    if (debilitation[planet] == rasi) return "நீசம்";
    if (ownHouses[planet]?.contains(rasi) ?? false) return "ஆட்சி";
    if (friends[planet]?.contains(rasi) ?? false) return "நட்பு";
    if (enemies[planet]?.contains(rasi) ?? false) return "பகை";
    return "சமம்";
  }


  static String formatDegrees(double degrees) {
    double lon = degrees % 30;
    if (lon < 0) lon += 30;
    int d = lon.floor();
    double remM = (lon - d) * 60;
    int m = remM.floor();
    int s = ((remM - m) * 60).round();
    if (s == 60) { m++; s = 0; }
    if (m == 60) { d++; m = 0; }
    return "${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  static String formatDegreesDMS(double degrees) {
    double lon = degrees % 30;
    int d = lon.floor();
    double remM = (lon - d) * 60;
    int m = remM.floor();
    int s = ((remM - m) * 60).round();
    if (s == 60) { m++; s = 0; }
    if (m == 60) { d++; m = 0; }
    return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}' ${s.toString().padLeft(2, '0')}\"";
  }

  static String formatAbsoluteDegrees(double degrees) {
    int d = degrees.floor();
    double remM = (degrees - d) * 60;
    int m = remM.round();
    if (m == 60) { d++; m = 0; }
    return "${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  static String formatAbsoluteDegreesDMS(double degrees) {
    int d = degrees.floor();
    double remM = (degrees - d) * 60;
    int m = remM.floor();
    int s = ((remM - m) * 60).round();
    if (s == 60) { m++; s = 0; }
    if (m == 60) { d++; m = 0; }
    return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}' ${s.toString().padLeft(2, '0')}\"";
  }

  static const List<String> VARA_TAMIL = ["ஞாயிறு", "திங்கள்", "செவ்வாய்", "புதன்", "வியாழன்", "வெள்ளி", "சனி"];
  static const Map<int, Map<String, String>> DAILY_TIMES = {
    1: {'rahu': '07:30 - 09:00', 'yama': '10:30 - 12:00', 'kuli': '13:30 - 15:00'},
    2: {'rahu': '15:00 - 16:30', 'yama': '09:00 - 10:30', 'kuli': '12:00 - 13:30'},
    3: {'rahu': '12:00 - 13:30', 'yama': '07:30 - 09:00', 'kuli': '10:30 - 12:00'},
    4: {'rahu': '13:30 - 15:00', 'yama': '06:00 - 07:30', 'kuli': '09:00 - 10:30'},
    5: {'rahu': '10:30 - 12:00', 'yama': '15:00 - 16:30', 'kuli': '06:00 - 07:30'},
    6: {'rahu': '09:00 - 10:30', 'yama': '13:30 - 15:00', 'kuli': '04:30 - 06:00'},
    7: {'rahu': '16:30 - 18:00', 'yama': '12:00 - 13:30', 'kuli': '15:00 - 16:30'},
  };

  static Future<Map<String, dynamic>> calculateChart(
    String name, DateTime dt, double lat, double lon, double timezone, {
    double yearLength = 365.25, int siderealModeIndex = 0, bool useMeanNodes = true, int ayanamsaOffsetSeconds = 0,
    int? horaryNo,
  }) async {
    if (!_isInit) await init();
    
    final engine = AstroEngine();
    final result = engine.calculate(dt, lat, lon, trueNode: !useMeanNodes, ayanamsaMode: siderealModeIndex);
    
    double jd = result.jd;
    double ayanamsaOffsetDeg = ayanamsaOffsetSeconds / 3600.0;

    // Automatic KP Ayanamsa calculation (if KP-Newcomb is selected and manual offset is 0)
    if (siderealModeIndex == 5 && ayanamsaOffsetSeconds == 0) {
      // Dynamic calculation matching the reference app's precession model
      // 1972 -> 39 seconds
      // 2026 -> 306 seconds
      // Rate = 4.9444 seconds per year
      double yearFraction = dt.year + (dt.month / 12.0) + (dt.day / 365.25);
      double autoOffsetSeconds = 39.0 + (yearFraction - 1972.58) * 4.9444;
      if (autoOffsetSeconds < 0) autoOffsetSeconds = 0;
      ayanamsaOffsetDeg = autoOffsetSeconds / 3600.0;
    }
    
    // KP Ayanamsa is usually smaller than Lahiri. We subtract the offset from Lahiri Ayanamsa.
    double ayanamsa = result.ayanamsa - ayanamsaOffsetDeg;
    
    // debugPrint("Calc Info: Local=$dt (TZ=$timezone) -> JD=$jd");
    // debugPrint("Ayanamsa: $ayanamsa");
    
    Map<String, String> nithyaToTarget = {
      'Su': 'Sun', 'Mo': 'Moon', 'Ma': 'Mars', 'Me': 'Mercury', 'Ju': 'Jupiter', 'Ve': 'Venus', 'Sa': 'Saturn', 'Ra': 'Rahu', 'Ke': 'Ketu'
    };

    Map<String, double> planetLons = {};
    Map<String, Map<String, dynamic>> planetInfo = {};
    for (var p in result.planets) {
      String targetName = nithyaToTarget[p.name] ?? p.name;
      // Since Ayanamsa is subtracted, Sidereal degree increases by the offset.
      double adjustedLon = (p.siderealDegree + ayanamsaOffsetDeg) % 360.0;
      if (adjustedLon < 0) adjustedLon += 360.0;
      planetLons[targetName] = adjustedLon;
      planetInfo[targetName] = {'lon': adjustedLon, 'speed': p.speed, 'isRetro': p.isRetrograde};
    }

    final pancha = await _calculatePanchangam(jd, planetLons, dt, lat, lon, timezone, engine);
    pancha['ayanamsa'] = ayanamsa;
    
    String modeName = "Lahiri";
    if (siderealModeIndex == 1) modeName = "Raman";
    else if (siderealModeIndex == 2) modeName = "KP Old";
    else if (siderealModeIndex == 3) modeName = "KP New";
    else if (siderealModeIndex == 4) modeName = "KP Straight Line";
    else if (siderealModeIndex == 5) modeName = "KP-Newcomb";

    pancha['ayanamsa_name'] = modeName;
    
    // Calculate Maanthi
    double maanthiLon = await _calculateMaanthiLongitude(
      dt, 
      lat, 
      lon, 
      timezone, 
      pancha, 
      engine, 
      ayanamsaMode: siderealModeIndex,
      sunLon: planetLons['Sun'] ?? 0.0,
    );
    maanthiLon = (maanthiLon + ayanamsaOffsetDeg) % 360.0;
    if (maanthiLon < 0) maanthiLon += 360.0;
    planetLons['Maanthi'] = maanthiLon;
    planetInfo['Maanthi'] = {'lon': maanthiLon, 'speed': 0, 'isRetro': false};

    Map<String, dynamic> finalResults = <String, dynamic>{
      'planet_details': <String, dynamic>{}, 'planet_info': planetInfo, 'houses_data': <int, dynamic>{},
      'panchangam': pancha,
      'tob': formatJDToLocalTime(jd, timezone),
      'rasi': <String, List<String>>{}, 'navamsa': <String, List<String>>{}, 'pavagam': <String, List<String>>{},
      'timezone': timezone, 'lat': lat, 'lon': lon
    };

    for (var sign in SIGNS) { finalResults['rasi'][sign] = <String>[]; finalResults['navamsa'][sign] = <String>[]; finalResults['pavagam'][sign] = <String>[]; }
    
    // Manually calculate sidereal cusps using the adjusted ayanamsha
    List<double> siderealCusps = [0.0];
    siderealCusps.addAll(result.houseCuspsSidereal.map((c) {
      double ac = (c + ayanamsaOffsetDeg) % 360.0;
      if (ac < 0) ac += 360.0;
      return ac;
    }));
    siderealCusps.add(siderealCusps[1]); // Cusp 13 == Cusp 1
    
    if (horaryNo != null && horaryNo >= 1 && horaryNo <= 249) {
      double horaryLon = _getHoraryLongitude(horaryNo);
      // In KP Horary, the 1st cusp is fixed at the horary point.
      // The other cusps are calculated relative to this new Ascendant.
      double offset = (horaryLon - siderealCusps[1] + 360) % 360;
      for (int i = 0; i < siderealCusps.length; i++) {
        siderealCusps[i] = (siderealCusps[i] + offset) % 360;
      }
    }
    
    Map<String, List<Map<String, dynamic>>> rasiEntries = {};
    for (var sign in SIGNS) {
      rasiEntries[sign] = [];
    }

    double lagnaLon = siderealCusps[1];
    String lagnaDeg = formatDegrees(lagnaLon);
    finalResults['planet_details']['lagna'] = {
      'longitude': lagnaLon, 'rasi': SIGNS[(lagnaLon / 30).floor() % 12], 'lords': getKPLords(lagnaLon),
      'nakshatra': NAKSHATRAS[(lagnaLon / (360/27)).floor() % 27], 'pada': ((lagnaLon % (360/27)) / (360/108)).floor() + 1
    };
    String lagnaSign = SIGNS[(lagnaLon / 30).floor() % 12];
    rasiEntries[lagnaSign]!.add({
      'deg': lagnaLon % 30,
      'label': "${TAMIL_PLANETS_SHORT['Lagna']!} $lagnaDeg",
    });
    int lagnaNavIdx = ((lagnaLon / 30).floor() * 9 + ((lagnaLon % 30) / (30/9)).floor()) % 12;
    finalResults['navamsa'][SIGNS[lagnaNavIdx]]!.add(TAMIL_PLANETS_SHORT['Lagna']!);

    planetLons.forEach((pName, pLon) {
      String pDeg = formatDegrees(pLon);
      bool isRetro = planetInfo[pName]?['isRetro'] == true;
      bool isCombust = isPlanetCombust(pName, pLon, planetLons['Sun']!, isRetro);

      String flags = "";
      if (isRetro) flags += " (வ)";
      if (isCombust) flags += " (அ)";

      finalResults['planet_details'][pName.toLowerCase()] = {
        'longitude': pLon, 'rasi': SIGNS[(pLon / 30).floor() % 12], 'lords': getKPLords(pLon),
        'nakshatra': NAKSHATRAS[(pLon / (360/27)).floor() % 27], 'pada': ((pLon % (360/27)) / (360/108)).floor() + 1,
        'isRetro': isRetro,
        'isCombust': isCombust,
      };

      String pSign = SIGNS[(pLon / 30).floor() % 12];
      rasiEntries[pSign]!.add({
        'deg': pLon % 30,
        'label': "${TAMIL_PLANETS_SHORT[pName]!}$flags $pDeg",
      });

      int navIdx = ((pLon / 30).floor() * 9 + ((pLon % 30) / (30/9)).floor()) % 12;
      finalResults['navamsa'][SIGNS[navIdx]]!.add("${TAMIL_PLANETS_SHORT[pName]!}$flags");
    });

    // Degree-wise sorting (ascending order) for each Rasi box
    for (var sign in SIGNS) {
      final list = rasiEntries[sign]!;
      list.sort((a, b) => (a['deg'] as double).compareTo(b['deg'] as double));
      finalResults['rasi'][sign] = list.map((e) => e['label'] as String).toList();
    }
    const List<String> ROMAN_BHAVAS = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'];
    for (int i = 1; i <= 12; i++) {
      double hLon = siderealCusps[i];
      finalResults['houses_data'][i] = {
        'longitude': hLon, 
        'lords': getKPLords(hLon),
        'nakshatra': NAKSHATRAS[(hLon / (360/27)).floor() % 27],
        'pada': ((hLon % (360/27)) / (360/108)).floor() + 1
      };
      finalResults['pavagam'][SIGNS[(hLon / 30).floor() % 12]]!.add("${ROMAN_BHAVAS[i - 1]} ${formatDegrees(hLon)}");
    }
    finalResults['pavagam'][SIGNS[(lagnaLon / 30).floor() % 12]]!.add(TAMIL_PLANETS_SHORT['Lagna']!);
    planetLons.forEach((pName, pLon) {
      int houseNum = 0;
      for (int i = 1; i <= 11; i++) {
        if (siderealCusps[i+1] > siderealCusps[i]) { if (pLon >= siderealCusps[i] && pLon < siderealCusps[i+1]) houseNum = i; }
        else { if (pLon >= siderealCusps[i] || pLon < siderealCusps[i+1]) houseNum = i; }
        if (houseNum > 0) break;
      }
      if (houseNum == 0) houseNum = 12;
      planetInfo[pName]!['house'] = houseNum;
      planetInfo[pName]!['lords'] = getKPLords(pLon);
      bool isRetro = planetInfo[pName]?['isRetro'] == true;
      bool isCombust = isPlanetCombust(pName, pLon, planetLons['Sun']!, isRetro);
      String flags = "";
      if (isRetro) flags += " (வ)";
      if (isCombust) flags += " (அ)";
      finalResults['pavagam'][SIGNS[(siderealCusps[houseNum] / 30).floor() % 12]]!.add("${TAMIL_PLANETS_SHORT[pName]!}$flags");
    });
    finalResults['dasa'] = _calculateDasaList(planetLons['Moon']!, dt, yearLength);
    final bool includeLagnaAV = await SettingsService.getIncludeLagnaAshtakavarga();
    finalResults['ashtakavarga'] = _calculateAshtakavarga(planetLons, lagnaLon, includeLagnaAV: includeLagnaAV);
    finalResults['divisional_charts'] = _calculateAllVargas(planetLons, lagnaLon);
    finalResults['significators'] = _calculateSignificators(planetLons, siderealCusps);
    finalResults['old_significators'] = _calculateOldKPSignificators(planetLons, siderealCusps);

    // Calculate Advanced Basics
    final moonDetails = finalResults['planet_details']['moon'];
    final lagnaDetails = finalResults['planet_details']['lagna'];
    String star = moonDetails['nakshatra'];
    
    // Atmakaraka
    finalResults['atmakaraka'] = _calculateAtmakaraka(planetLons);
    
    // Ayanamsa Text
    finalResults['ayanamsa_text'] = "${formatAbsoluteDegreesDMS(ayanamsa)} ($modeName)";

    // Dasa Balance calculation
    double moonLon = planetLons['Moon']!;
    double totalMinutes = moonLon * 60;
    double nakMinutes = totalMinutes % 800;
    int nakIdx = (totalMinutes / 800).floor();
    String startLord = VIMSHOTTARI_LORDS[nakIdx % 9];
    double remainingMinutes = 800 - nakMinutes;
    double totalYears = VIMSHOTTARI_YEARS[startLord]!.toDouble();
    double balanceYears = (remainingMinutes / 800) * totalYears;
    int y = balanceYears.floor();
    double remM = (balanceYears - y) * 12;
    int m = remM.floor();
    int d = ((remM - m) * 30).round();
    finalResults['dasa_balance'] = "${startLord} ${y.toString().padLeft(2, '0')}Y, ${m.toString().padLeft(2, '0')}M, ${d.toString().padLeft(2, '0')}D";
    finalResults['dasa_balance_lord'] = startLord;
    finalResults['dasa_balance_y'] = y;
    finalResults['dasa_balance_m'] = m;
    finalResults['dasa_balance_d'] = d;
    
    // Functional Planets based on Lagna
    finalResults['functional_planets'] = _getFunctionalPlanets(lagnaDetails['rasi']);
    
    // Time calculations
    finalResults['nazhigai'] = _calculateNazhigai(pancha['sunrise'], dt);
    finalResults['hora'] = _calculateHora(pancha['sunrise'], dt, dt.weekday);
    finalResults['special_yoga'] = _getAmirthaYoga(dt.weekday, star);
    
    // Matching Attributes
    final currentNakIdx = NAKSHATRAS.indexOf(star);
    if (currentNakIdx != -1) {
       final nakAttr = NakshatraData.nakshatraDetails[currentNakIdx];
       finalResults['matching_attrs'] = {
         'mirugam': nakAttr['mirugam'],
         'pakshi': nakAttr['pakshi'],
         'ganam': nakAttr['ganam'],
         'yoni': (nakAttr['mirugam']?.contains('பெண்') ?? false) ? "பெண்" : "ஆண்",
         'maram': nakAttr['maram'],
         'rajju': _getRajju(star),
         'naadi': nakAttr['naadi'],
       };
    }

    finalResults['era'] = {
      'kali': dt.year + 3101,
      'kollam': dt.year - 824,
    };

    // 5. Calculate Pars Fortunae (Fortuna)
    bool isDayBirth = true;
    try {
      final srParts = (pancha['sunrise'] ?? "06:00").toString().split(':');
      final ssParts = (pancha['sunset'] ?? "18:00").toString().split(':');
      double srHours = (int.tryParse(srParts[0]) ?? 6) + ((int.tryParse(srParts[1]) ?? 0) / 60.0);
      double ssHours = (int.tryParse(ssParts[0]) ?? 18) + ((int.tryParse(ssParts[1]) ?? 0) / 60.0);
      double birthHours = dt.hour + (dt.minute / 60.0);
      isDayBirth = birthHours >= srHours && birthHours < ssHours;
    } catch (_) {}

    double fortunaLon = isDayBirth
        ? (lagnaLon + planetLons['Moon']! - planetLons['Sun']! + 720) % 360
        : (lagnaLon + planetLons['Sun']! - planetLons['Moon']! + 720) % 360;

    finalResults['planet_details']['fortuna'] = {
      'longitude': fortunaLon, 'rasi': SIGNS[(fortunaLon / 30).floor() % 12], 'lords': getKPLords(fortunaLon),
      'nakshatra': NAKSHATRAS[(fortunaLon / (360/27)).floor() % 27], 'pada': ((fortunaLon % (360/27)) / (360/108)).floor() + 1
    };
    finalResults['planet_info']['Fortuna'] = {'isRetro': false};

    // Special Astrology Calculations (இந்து லக்னம், ஜெமினி லக்னங்கள், யோகி-அவயோகி, காரகங்கள், உபகிரகங்கள்)
    finalResults['indu_lagna'] = AstroSpecialCalculationsService.calculateInduLagna(lagnaLon, planetLons['Moon']!);
    finalResults['fortuna_detailed'] = AstroSpecialCalculationsService.calculateFortuna(lagnaLon, planetLons['Sun']!, planetLons['Moon']!, isDayBirth);
    finalResults['jaimini_lagnas'] = AstroSpecialCalculationsService.calculateJaiminiLagnas(
      lagnaLon: lagnaLon,
      sunLon: planetLons['Sun']!,
      birthDt: dt,
      sunriseStr: pancha['sunrise'] ?? "06:00",
      planetLons: planetLons,
    );

    finalResults['yogi_avayogi'] = AstroSpecialCalculationsService.calculateYogiAvayogi(planetLons['Sun']!, planetLons['Moon']!);
    finalResults['planetary_roles'] = AstroSpecialCalculationsService.calculatePlanetaryRoles(lagnaLon, planetLons);
    finalResults['kala_pagai'] = AstroSpecialCalculationsService.checkKalaPagai(dasaList: finalResults['dasa'] ?? [], birthDt: dt);
    finalResults['vainasika_pada'] = AstroSpecialCalculationsService.calculateVainasikaPada(planetLons['Moon']!, planetLons);
    finalResults['kala_natpu_pagai_age'] = AstroSpecialCalculationsService.checkKalaNatpuAndPagaiAges(dasaList: finalResults['dasa'] ?? [], birthDt: dt);

    finalResults['jaimini_karakas'] = AstroSpecialCalculationsService.calculateJaiminiKarakas(planetLons);
    finalResults['planetary_avasthas'] = AstroSpecialCalculationsService.calculatePlanetaryAvasthas(planetLons, lagnaLon);
    finalResults['parivarthana'] = AstroSpecialCalculationsService.checkParivarthana(planetLons);
    finalResults['visha_amrita'] = AstroSpecialCalculationsService.checkVishaAmritaGhatika(planetLons);
    finalResults['karma_nakshatras'] = AstroSpecialCalculationsService.checkKarmaNakshatras(planetLons['Moon']!, planetLons);
    finalResults['pushkara_navamsa'] = AstroSpecialCalculationsService.checkPushkaraNavamsa(planetLons, lagnaLon);
    finalResults['chandrashtama'] = AstroSpecialCalculationsService.calculateChandrashtama(planetLons['Moon']!);
    finalResults['navatara'] = AstroSpecialCalculationsService.checkNavataraPositions(planetLons['Moon']!, planetLons);

    finalResults['upagrahas'] = AstroSpecialCalculationsService.calculateUpagrahas(planetLons['Sun']!, dt, pancha['sunrise'] ?? "06:00");
    finalResults['lagna_change'] = AstroSpecialCalculationsService.calculateLagnaTimeChange(lagnaLon, dt);

    bool isShukla = ((planetLons['Moon']! - planetLons['Sun']! + 360) % 360) < 180;
    DateTime srDt = DateTime(dt.year, dt.month, dt.day, 6, 0);
    try {
      final srParts = (pancha['sunrise'] ?? "06:00").toString().split(':');
      srDt = DateTime(dt.year, dt.month, dt.day, int.tryParse(srParts[0]) ?? 6, int.tryParse(srParts[1]) ?? 0);
    } catch (_) {}
    finalResults['pancha_pakshi'] = AstroSpecialCalculationsService.calculatePanchaPakshi(
      moonLon: planetLons['Moon']!,
      currentDt: dt,
      sunrise: srDt,
      isShuklaPaksha: isShukla,
    );

    // 6. Complete 6-Fold Shadbala Calculation
    Map<String, dynamic> isRetroMap = {};
    finalResults['planet_info']?.forEach((k, v) {
      if (v is Map && v['isRetro'] == true) {
        isRetroMap[k] = true;
      }
    });

    finalResults['shadbala'] = ShadbalaService.calculateShadbala(
      planetLons: planetLons,
      lagnaLon: lagnaLon,
      birthDt: dt,
      sunriseStr: pancha['sunrise'] ?? "06:00",
      sunsetStr: pancha['sunset'] ?? "18:00",
      planetRetrograde: isRetroMap,
    );

    return finalResults;
  }

  static Future<double> _calculateMaanthiLongitude(
    DateTime dt, 
    double lat, 
    double lon, 
    double timezone, 
    Map<String, dynamic> pancha, 
    AstroEngine engine, 
    {int ayanamsaMode = 0, double sunLon = 0.0}
  ) async {
    try {
      final String sunriseStr = pancha['sunrise'] ?? "06:00 AM";
      final String sunsetStr = pancha['sunset'] ?? "06:00 PM";
      
      DateTime parseTime(String timeStr, DateTime baseDate) {
        final parts = timeStr.split(' ');
        final hms = parts[0].split(':');
        int h = int.parse(hms[0]);
        int m = int.parse(hms[1]);
        int s = hms.length > 2 ? int.parse(hms[2]) : 0;
        if (parts[1] == "PM" && h < 12) h += 12;
        if (parts[1] == "AM" && h == 12) h = 0;
        return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m, s);
      }

      DateTime sunrise = parseTime(sunriseStr, dt);
      DateTime sunset = parseTime(sunsetStr, dt);
      
      bool isDayBirth = dt.isAfter(sunrise) && dt.isBefore(sunset);
      int weekday = dt.weekday % 7; // 0=Sun, 1=Mon, ...

      int maandiMethod = await SettingsService.getMaandiMethod();
      
      // Constant rising ghatikas for day (0=Sun, 1=Mon, ...)
      // Sun: 26, Mon: 22, Tue: 18, Wed: 14, Thu: 10, Fri: 6, Sat: 2
      const List<double> dayGhatikas = [26.0, 22.0, 18.0, 14.0, 10.0, 6.0, 2.0];
      // Constant rising ghatikas for night
      // Sun: 10, Mon: 6, Tue: 2, Wed: 26, Thu: 22, Fri: 18, Sat: 14
      const List<double> nightGhatikas = [10.0, 6.0, 2.0, 26.0, 22.0, 18.0, 14.0];
      
      double constantGhatika = isDayBirth ? dayGhatikas[weekday] : nightGhatikas[weekday];

      if (maandiMethod == 4) {
        // SUN degree + constant rising degree
        double constantDegree = constantGhatika * 6.0; // 60 ghatikas = 360 degrees, so 1 ghatika = 6 degrees
        double startDeg = isDayBirth ? sunLon : (sunLon + 180.0);
        double maanthiLon = (startDeg + constantDegree) % 360.0;
        if (maanthiLon < 0) maanthiLon += 360.0;
        return maanthiLon;
      }

      double durationMinutes;
      DateTime startTime;
      if (isDayBirth) {
        durationMinutes = sunset.difference(sunrise).inMinutes.toDouble();
        startTime = sunrise;
      } else {
        startTime = dt.isBefore(sunrise) ? sunset.subtract(const Duration(days: 1)) : sunset;
        DateTime nextSunrise = sunrise.isAfter(dt) ? sunrise : sunrise.add(const Duration(days: 1));
        durationMinutes = nextSunrise.difference(startTime).inMinutes.toDouble();
      }

      double maanthiOffsetMinutes;
      if (maandiMethod == 0) {
        // ((Ghatikas of day/night * Constant Rising Ghatika) / 30)
        double totalGhatikas = durationMinutes / 24.0;
        double maanthiGhatika = (totalGhatikas * constantGhatika) / 30.0;
        maanthiOffsetMinutes = maanthiGhatika * 24.0;
      } else {
        // 8-part calculations
        int segment;
        if (isDayBirth) {
          segment = (7 - weekday + 7) % 7;
          if (segment == 0) segment = 7;
        } else {
          segment = (3 - weekday + 7) % 7;
          if (segment == 0) segment = 7;
        }
        
        if (maandiMethod == 2) {
          // Middle of Saturn's part
          maanthiOffsetMinutes = (segment - 1 + 0.5) * (durationMinutes / 8.0);
        } else if (maandiMethod == 3) {
          // End of Saturn's part
          maanthiOffsetMinutes = segment * (durationMinutes / 8.0);
        } else {
          // Start of Saturn's part (Default, maandiMethod == 1)
          maanthiOffsetMinutes = (segment - 1) * (durationMinutes / 8.0);
        }
      }

      DateTime maanthiTime = startTime.add(Duration(minutes: maanthiOffsetMinutes.toInt()));
      final res = engine.calculate(maanthiTime, lat, lon, ayanamsaMode: ayanamsaMode);
      return res.lagnaSidereal;
    } catch (e) {
      debugPrint("Maanthi Calc Error: $e");
      return 0.0;
    }
  }

  static Map<String, dynamic> _calculateSignificators(Map<String, double> planetLons, List<double> cusps) {
    Map<String, int> planetOccupancy = <String, int>{};
    Map<String, Map<String, String>> planetLordsMap = {};
    Map<int, Map<String, String>> cuspLordsMap = {};

    // 1. Get Planet House Occupancy and Lords
    planetLons.forEach((pName, pLon) {
      int houseNum = 0;
      for (int i = 1; i <= 11; i++) {
        if (cusps[i+1] > cusps[i]) { if (pLon >= cusps[i] && pLon < cusps[i+1]) houseNum = i; }
        else { if (pLon >= cusps[i] || pLon < cusps[i+1]) houseNum = i; }
        if (houseNum > 0) break;
      }
      if (houseNum == 0) houseNum = 12;
      planetOccupancy[pName] = houseNum;
      planetLordsMap[pName] = getKPLords(pLon);
    });

    // 2. Get Cusp Lords
    for (int i = 1; i <= 12; i++) {
      cuspLordsMap[i] = getKPLords(cusps[i]);
    }

    // 3. Planet Table (அ - ஊ)
    Map<String, dynamic> planetView = {};
    planetLons.forEach((pName, pLon) {
      final lords = planetLordsMap[pName]!;
      final starLord = lords['nakLord']!;

      // ஊ: House the planet is in
      final h_oo = planetOccupancy[pName]!;
      // உ: House the planet's star lord is in
      final starLordFull = TAMIL_PLANETS_SHORT.entries.firstWhere((e) => e.value == starLord, orElse: () => MapEntry(starLord, starLord)).key;
      final h_u = planetOccupancy[starLordFull] ?? 0;
      
      // Lists for other levels
      final h_ee = <int>[]; // ஈ: Planet is Star Lord
      final h_aa = <int>[]; // ஆ: Planet is Sub Lord
      final h_ee_of_sl = <int>[]; // இ: Star Lord is Star Lord
      final h_aa_of_sl = <int>[]; // அ: Star Lord is Sub Lord

      for (int i = 1; i <= 12; i++) {
        final cLords = cuspLordsMap[i]!;
        if (cLords['nakLord'] == TAMIL_PLANETS_SHORT[pName] || cLords['nakLord'] == pName) h_ee.add(i);
        if (cLords['subLord'] == TAMIL_PLANETS_SHORT[pName] || cLords['subLord'] == pName) h_aa.add(i);
        
        if (cLords['nakLord'] == starLord) h_ee_of_sl.add(i);
        if (cLords['subLord'] == starLord) h_aa_of_sl.add(i);
      }

      planetView[pName.toLowerCase()] = {
        'அ': h_aa_of_sl.join(','),
        'ஆ': h_aa.join(','),
        'இ': h_ee_of_sl.join(','),
        'ஈ': h_ee.join(','),
        'உ': h_u == 0 ? "-" : h_u.toString(),
        'ஊ': h_oo.toString(),
      };
    });

    // 4. Bhava Table (அ - ஊ)
    Map<int, Map<String, List<String>>> houseView = {};
    for (int i = 1; i <= 12; i++) {
      final cLords = cuspLordsMap[i]!;
      final sl = cLords['subLord']!;
      final nl = cLords['nakLord']!;

      // ஊ: Planets in this house
      final planetsInHouse = <String>[];
      planetOccupancy.forEach((p, h) { if (h == i) planetsInHouse.add(TAMIL_PLANETS_SHORT[p] ?? p); });

      // உ: Planets whose Star Lord is in this house
      final planetsWhoseSLInHouse = <String>[];
      planetLons.forEach((p, lon) {
        final slOfPShort = planetLordsMap[p]!['nakLord']!;
        final slOfPFull = TAMIL_PLANETS_SHORT.entries.firstWhere((e) => e.value == slOfPShort, orElse: () => MapEntry(slOfPShort, slOfPShort)).key;
        if (planetOccupancy[slOfPFull] == i) planetsWhoseSLInHouse.add(TAMIL_PLANETS_SHORT[p] ?? p);
      });

      // ஈ: Cusp Star Lord
      final h_ee = [nl];

      // ஆ: Cusp Sub Lord
      final h_aa = [sl];

      // இ: Star Lord and Sub Lord of the planet in (ஈ)
      final nlFull = TAMIL_PLANETS_SHORT.entries.firstWhere((e) => e.value == nl, orElse: () => MapEntry(nl, nl)).key;
      final lordsOfNl = planetLordsMap[nlFull];
      final h_ee_lords = lordsOfNl != null ? [lordsOfNl['nakLord']!, lordsOfNl['subLord']!] : <String>[];

      // அ: Star Lord and Sub Lord of the planet in (ஆ)
      final slFull = TAMIL_PLANETS_SHORT.entries.firstWhere((e) => e.value == sl, orElse: () => MapEntry(sl, sl)).key;
      final lordsOfSl = planetLordsMap[slFull];
      final h_aa_lords = lordsOfSl != null ? [lordsOfSl['nakLord']!, lordsOfSl['subLord']!] : <String>[];

      houseView[i] = {
        'அ': h_aa_lords.map((p) => TAMIL_PLANETS_SHORT[p] ?? p).toList(),
        'ஆ': h_aa.map((p) => TAMIL_PLANETS_SHORT[p] ?? p).toList(),
        'இ': h_ee_lords.map((p) => TAMIL_PLANETS_SHORT[p] ?? p).toList(),
        'ஈ': h_ee.map((p) => TAMIL_PLANETS_SHORT[p] ?? p).toList(),
        'உ': planetsWhoseSLInHouse,
        'ஊ': planetsInHouse,
      };
    }

    return { 'planet_view': planetView, 'house_view': houseView };
  }

  static Map<String, dynamic> _calculateOldKPSignificators(Map<String, double> planetLons, List<double> cusps) {
    Map<String, int> planetOccupancy = <String, int>{};
    Map<String, List<int>> planetOwnership = <String, List<int>>{};
    Map<String, String> planetStarLords = {};

    // 1. Occupancy and Star Lords
    planetLons.forEach((pName, pLon) {
      int houseNum = 0;
      for (int i = 1; i <= 11; i++) {
        if (cusps[i+1] > cusps[i]) { if (pLon >= cusps[i] && pLon < cusps[i+1]) houseNum = i; }
        else { if (pLon >= cusps[i] || pLon < cusps[i+1]) houseNum = i; }
        if (houseNum > 0) break;
      }
      if (houseNum == 0) houseNum = 12;
      planetOccupancy[pName] = houseNum;
      planetStarLords[pName] = getKPLords(pLon)['nakLord']!;
    });

    // 2. Ownership
    for (int i = 1; i <= 12; i++) {
      int rasiIdx = (cusps[i] / 30).floor() % 12;
      String lord = SIGN_LORDS[rasiIdx];
      planetOwnership[lord] ??= [];
      planetOwnership[lord]!.add(i);
    }

    // 3. Planet Table View
    Map<String, dynamic> planetView = {};
    planetLons.forEach((pName, pLon) {
      final slShort = planetStarLords[pName]!;
      final slFull = TAMIL_PLANETS_SHORT.entries.firstWhere((e) => e.value == slShort, orElse: () => MapEntry(slShort, slShort)).key;

      planetView[pName.toLowerCase()] = {
        'அ': (planetOccupancy[slFull] ?? 0).toString(),
        'ஆ': (planetOccupancy[pName] ?? 0).toString(),
        'இ': (planetOwnership[slFull] ?? []).join(','),
        'ஈ': (planetOwnership[pName] ?? []).join(','),
      };
    });

    // 4. House Table View
    Map<int, Map<String, List<String>>> houseView = {};
    for (int i = 1; i <= 12; i++) {
      int rasiIdx = (cusps[i] / 30).floor() % 12;
      String owner = SIGN_LORDS[rasiIdx];

      List<String> occupants = [];
      planetOccupancy.forEach((p, h) { if (h == i) occupants.add(TAMIL_PLANETS_SHORT[p] ?? p); });

      List<String> level1 = [];
      planetStarLords.forEach((p, sl) {
        final slFull = TAMIL_PLANETS_SHORT.entries.firstWhere((e) => e.value == sl, orElse: () => MapEntry(sl, sl)).key;
        if (planetOccupancy[slFull] == i) level1.add(TAMIL_PLANETS_SHORT[p] ?? p);
      });

      List<String> level3 = [];
      planetStarLords.forEach((p, sl) {
        final slFull = TAMIL_PLANETS_SHORT.entries.firstWhere((e) => e.value == sl, orElse: () => MapEntry(sl, sl)).key;
        if (slFull == owner) level3.add(TAMIL_PLANETS_SHORT[p] ?? p);
      });

      houseView[i] = {
        'அ': level1,
        'ஆ': occupants,
        'இ': level3,
        'ஈ': [TAMIL_PLANETS_SHORT[owner] ?? owner],
      };
    }

    return { 'planet_view': planetView, 'house_view': houseView };
  }

  static List<Map<String, dynamic>> _calculateDasaList(double moonLon, DateTime birthDt, double yearLength) {
    double totalMinutes = moonLon * 60;
    double nakMinutes = totalMinutes % 800;
    int nakIdx = (totalMinutes / 800).floor();
    String startLord = VIMSHOTTARI_LORDS[nakIdx % 9];
    double remainingMinutes = 800 - nakMinutes;
    double elapsedMinutes = nakMinutes;

    List<Map<String, dynamic>> dasaTimeline = [];
    int lordIdx = VIMSHOTTARI_LORDS.indexOf(startLord);
    double tYears = VIMSHOTTARI_YEARS[startLord]!.toDouble();

    // Full first Dasa duration in milliseconds
    int fullFirstDasaMillis = (tYears * yearLength * 86400000.0).round();
    int elapsedMillis = ((elapsedMinutes / 800.0) * fullFirstDasaMillis).round();
    int remainingMillis = fullFirstDasaMillis - elapsedMillis;

    // Theoretical start of the full first Dasa (before birth)
    DateTime fullFirstDasaStart = birthDt.subtract(Duration(milliseconds: elapsedMillis));
    // End of the first Dasa
    DateTime firstDasaEnd = birthDt.add(Duration(milliseconds: remainingMillis));

    double balanceYears = (remainingMinutes / 800) * tYears;
    int y = balanceYears.floor();
    double remM = (balanceYears - y) * 12;
    int m = remM.floor();
    int d = ((remM - m) * 30).round();
    String balanceStr = "$y வரு, $m மா, $d நா";

    dasaTimeline.add({
      'lord': startLord,
      'start': birthDt,
      'fullStart': fullFirstDasaStart,
      'end': firstDasaEnd,
      'isCurrent': true,
      'balanceStr': balanceStr,
      'subPeriods': _calculateSubPeriods(startLord, fullFirstDasaStart, firstDasaEnd, 2, yearLength, birthDt: birthDt)
    });

    DateTime startTime = firstDasaEnd;
    for (int i = 1; i < 9; i++) {
      String lord = VIMSHOTTARI_LORDS[(lordIdx + i) % 9];
      double y = VIMSHOTTARI_YEARS[lord]!.toDouble();
      int dasaMillis = (y * yearLength * 86400000.0).round();
      DateTime endTime = startTime.add(Duration(milliseconds: dasaMillis));
      dasaTimeline.add({
        'lord': lord,
        'start': startTime,
        'fullStart': startTime,
        'end': endTime,
        'isCurrent': false,
        'subPeriods': _calculateSubPeriods(lord, startTime, endTime, 2, yearLength)
      });
      startTime = endTime;
    }
    return dasaTimeline;
  }

  static const List<String> VIMSHOTTARI_LORDS = ['Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'];
  static const Map<String, int> VIMSHOTTARI_YEARS = {'Ketu': 7, 'Venus': 20, 'Sun': 6, 'Moon': 10, 'Mars': 7, 'Rahu': 18, 'Jupiter': 16, 'Saturn': 19, 'Mercury': 17};

  static List<Map<String, dynamic>> _calculateSubPeriods(
    String parentLord,
    DateTime start,
    DateTime end,
    int level,
    double yearLength, {
    DateTime? birthDt,
  }) {
    if (level > 5) return [];
    List<Map<String, dynamic>> periods = [];
    int startIndex = VIMSHOTTARI_LORDS.indexOf(parentLord);
    Duration totalDuration = end.difference(start);
    DateTime current = start;
    for (int i = 0; i < 9; i++) {
      String subLord = VIMSHOTTARI_LORDS[(startIndex + i) % 9];
      double ratio = VIMSHOTTARI_YEARS[subLord]! / 120.0;
      int pMillis = (totalDuration.inMilliseconds * ratio).floor();
      DateTime subEnd = (i == 8) ? end : current.add(Duration(milliseconds: pMillis));
      if (subEnd.isAfter(end)) subEnd = end;

      DateTime periodStart = current;
      if (birthDt != null) {
        if (subEnd.isBefore(birthDt) || subEnd.isAtSameMomentAs(birthDt)) {
          current = subEnd;
          continue;
        }
        DateTime effectiveStart = periodStart.isBefore(birthDt) ? birthDt : periodStart;
        periods.add({
          'lord': subLord,
          'start': effectiveStart,
          'fullStart': periodStart,
          'end': subEnd,
          'level': level,
          'subPeriods': level < 5
              ? _calculateSubPeriods(subLord, periodStart, subEnd, level + 1, yearLength, birthDt: birthDt)
              : []
        });
      } else {
        periods.add({
          'lord': subLord,
          'start': periodStart,
          'fullStart': periodStart,
          'end': subEnd,
          'level': level,
          'subPeriods': level < 5
              ? _calculateSubPeriods(subLord, periodStart, subEnd, level + 1, yearLength)
              : []
        });
      }
      current = subEnd;
    }
    return periods;
  }

  static Map<String, dynamic> calculateAshtakavargaMap(Map<String, double> planetLons, double lagnaLon, {bool includeLagnaAV = true}) {
    return _calculateAshtakavarga(planetLons, lagnaLon, includeLagnaAV: includeLagnaAV);
  }

  static Map<String, dynamic> _calculateAshtakavarga(Map<String, double> planetLons, double lagnaLon, {bool includeLagnaAV = true}) {
    Map<String, int> planetPositions = {}; planetLons.forEach((name, lon) { planetPositions[name] = (lon / 30).floor() % 12; });
    planetPositions['Lagna'] = (lagnaLon / 30).floor() % 12;
    
    final tables = includeLagnaAV ? _bookLagnaAshtakavargaTables : _defaultAshtakavargaTables;

    Map<String, List<int>> bAV = { 
      'Sun': _getPoints('Sun', planetPositions, tables), 
      'Moon': _getPoints('Moon', planetPositions, tables), 
      'Mars': _getPoints('Mars', planetPositions, tables), 
      'Mercury': _getPoints('Mercury', planetPositions, tables), 
      'Jupiter': _getPoints('Jupiter', planetPositions, tables), 
      'Venus': _getPoints('Venus', planetPositions, tables), 
      'Saturn': _getPoints('Saturn', planetPositions, tables),
    };
    if (includeLagnaAV) {
      bAV['Lagna'] = _getPoints('Lagna', planetPositions, tables);
    }
    
    Map<String, List<int>> trikona = {};
    Map<String, List<int>> ekadipathya = {};
    Map<String, Map<String, int>> pindas = {};

    bAV.forEach((p, points) {
      List<int> tPoints = _trikonaShodhana(List.from(points));
      trikona[p] = tPoints;
      List<int> ePoints = _ekadhipatyaShodhana(List.from(tPoints), planetPositions);
      ekadipathya[p] = ePoints;
      pindas[p] = _calculatePindas(p, ePoints, planetPositions);
    });

    // Sarvashtakavarga is always the sum of the 7 classical planets (Sun to Saturn = 337 points)
    const sevenPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    List<int> total = List.filled(12, 0);
    for (String p in sevenPlanets) {
      final pList = bAV[p]!;
      for (int i = 0; i < 12; i++) {
        total[i] += pList[i];
      }
    }

    return <String, dynamic>{
      'individual': bAV,
      'total': total,
      'trikona': trikona,
      'ekadipathya': ekadipathya,
      'pindas': pindas,
      'includeLagna': includeLagnaAV,
    };
  }

  static List<int> _trikonaShodhana(List<int> points) {
    const triads = [[0, 4, 8], [1, 5, 9], [2, 6, 10], [3, 7, 11]];
    for (var triad in triads) {
      int zeroCount = triad.where((i) => points[i] == 0).length;
      
      // Rule 4: If two signs are zero, or all three are equal, make all three zero.
      if (zeroCount >= 2 || (points[triad[0]] == points[triad[1]] && points[triad[1]] == points[triad[2]])) {
        for (int i in triad) points[i] = 0;
        continue;
      }
      
      // Rule 3: If exactly one sign is zero, no changes.
      if (zeroCount == 1) continue;
      
      // Rule 1 & 2: Make all three equal to the minimum.
      int minVal = triad.map((i) => points[i]).reduce((a, b) => a < b ? a : b);
      for (int i in triad) points[i] = minVal;
    }
    return points;
  }

  static List<int> _ekadhipatyaShodhana(List<int> points, Map<String, int> planetPos) {
    const pairs = [[0, 7], [1, 6], [2, 5], [8, 11], [9, 10]]; // Mars, Venus, Merc, Jup, Sat
    final planetList = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn", "Rahu", "Ketu"];
    for (var pair in pairs) {
      int s1 = pair[0], s2 = pair[1];
      bool p1 = planetPos.entries.any((e) => planetList.contains(e.key) && e.value == s1);
      bool p2 = planetPos.entries.any((e) => planetList.contains(e.key) && e.value == s2);
      
      if (p1 && p2) continue;
      if (points[s1] == 0 || points[s2] == 0) continue;
      
      if (!p1 && !p2) { // Both empty
        int min = points[s1] < points[s2] ? points[s1] : points[s2];
        points[s1] = points[s2] = min;
      } else { // One occupied, one empty
        int occ = p1 ? s1 : s2, emp = p1 ? s2 : s1;
        if (points[emp] > points[occ]) points[emp] = points[occ];
        else points[emp] = 0;
      }
    }
    return points;
  }

  static Map<String, int> _calculatePindas(String planet, List<int> points, Map<String, int> planetPos) {
    const rasiG = [7, 10, 8, 4, 10, 5, 7, 8, 9, 5, 11, 12];
    const grahaG = {'Sun': 5, 'Moon': 5, 'Mars': 8, 'Mercury': 5, 'Jupiter': 10, 'Venus': 7, 'Saturn': 5};
    int rPinda = 0; for (int i = 0; i < 12; i++) rPinda += points[i] * rasiG[i];
    int gPinda = 0; planetPos.forEach((p, pos) { if (grahaG.containsKey(p)) gPinda += points[pos] * grahaG[p]!; });
    return {'rasi': rPinda, 'graha': gPinda, 'total': rPinda + gPinda};
  }

  static List<int> _getPoints(String planet, Map<String, int> pos, Map<String, Map<String, List<int>>> tables) {
    List<int> sar = List.filled(12, 0); 
    final rules = tables[planet] ?? {};
    rules.forEach((refPlanet, goodHouses) { int refPos = pos[refPlanet] ?? 0; for (int h in goodHouses) sar[(refPos + h - 1) % 12]++; });
    return sar;
  }

  static const Map<String, Map<String, List<int>>> _defaultAshtakavargaTables = {
     'Sun': { 'Sun': [1,2,4,7,8,9,10,11], 'Moon': [3,6,10,11], 'Mars': [1,2,4,7,8,9,10,11], 'Mercury': [3,5,6,9,10,11,12], 'Jupiter': [5,6,9,11], 'Venus': [6,7,12], 'Saturn': [1,2,4,7,8,9,10,11], 'Lagna': [3,4,6,10,11,12] },
     'Moon': { 'Sun': [3,6,7,8,10,11], 'Moon': [1,3,6,7,10,11], 'Mars': [2,3,5,6,9,10,11], 'Mercury': [1,3,4,5,7,8,10,11], 'Jupiter': [1,4,7,8,10,11,12], 'Venus': [3,4,5,7,9,10,11], 'Saturn': [3,5,6,11], 'Lagna': [3,6,10,11] },
     'Mars': { 'Sun': [3,5,6,10,11], 'Moon': [3,6,11], 'Mars': [1,2,4,7,8,10,11], 'Mercury': [3,5,6,11], 'Jupiter': [6,10,11,12], 'Venus': [6,8,11,12], 'Saturn': [1,4,7,8,9,10,11], 'Lagna': [1,3,6,10,11] },
     'Mercury': { 'Sun': [5,6,9,11,12], 'Moon': [2,4,6,8,10,11], 'Mars': [1,2,4,7,8,9,10,11], 'Mercury': [1,3,5,6,9,10,11,12], 'Jupiter': [6,8,11,12], 'Venus': [1,2,3,4,5,8,9,11], 'Saturn': [1,2,4,7,8,9,10,11], 'Lagna': [1,2,4,6,8,10,11] },
     'Jupiter': { 'Sun': [1,2,3,4,7,8,9,10,11], 'Moon': [2,5,7,9,11], 'Mars': [1,2,4,7,8,10,11], 'Mercury': [1,2,4,5,6,9,10,11], 'Jupiter': [1,2,3,4,7,8,10,11], 'Venus': [2,5,6,9,10,11], 'Saturn': [3,5,6,12], 'Lagna': [1,2,4,5,6,7,9,10,11] },
     'Venus': { 'Sun': [8,11,12], 'Moon': [1,2,3,4,5,8,9,11,12], 'Mars': [3,5,6,9,11,12], 'Mercury': [3,5,6,9,11], 'Jupiter': [5,8,9,10,11], 'Venus': [1,2,3,4,5,8,9,10,11], 'Saturn': [3,4,5,8,9,10,11], 'Lagna': [1,2,3,4,5,8,9,11] },
     'Saturn': { 'Sun': [1,2,4,7,8,10,11], 'Moon': [3,6,11], 'Mars': [3,5,6,10,11,12], 'Mercury': [6,8,9,10,11,12], 'Jupiter': [5,6,11,12], 'Venus': [6,11,12], 'Saturn': [3,5,6,11], 'Lagna': [1,3,4,6,10,11] }
  };

  static const Map<String, Map<String, List<int>>> _bookLagnaAshtakavargaTables = {
     'Sun': { 'Sun': [1,2,4,7,8,9,10,11], 'Moon': [3,6,10,11], 'Mars': [1,2,4,7,8,9,10,11], 'Mercury': [3,5,6,9,10,11,12], 'Jupiter': [5,6,9,11], 'Venus': [6,7,12], 'Saturn': [1,2,4,7,8,9,10,11], 'Lagna': [3,4,6,10,11,12] },
     'Moon': { 'Sun': [3,6,7,8,10,11], 'Moon': [1,3,6,7,9,10,11], 'Mars': [2,3,5,6,10,11], 'Mercury': [1,3,4,5,7,8,10,11], 'Jupiter': [1,2,4,7,8,10,11], 'Venus': [3,4,5,7,9,10,11], 'Saturn': [3,5,6,11], 'Lagna': [3,6,10,11] },
     'Mars': { 'Sun': [3,5,6,10,11], 'Moon': [3,6,11], 'Mars': [1,2,4,7,8,10,11], 'Mercury': [3,5,6,11], 'Jupiter': [6,10,11,12], 'Venus': [6,8,11,12], 'Saturn': [1,4,7,8,9,10,11], 'Lagna': [1,3,6,10,11] },
     'Mercury': { 'Sun': [5,6,9,11,12], 'Moon': [2,4,6,8,10,11], 'Mars': [1,2,4,7,8,9,10,11], 'Mercury': [1,3,5,6,9,10,11,12], 'Jupiter': [6,8,11,12], 'Venus': [1,2,3,4,5,8,9,11], 'Saturn': [1,2,4,7,8,9,10,11], 'Lagna': [1,2,4,6,8,10,11] },
     'Jupiter': { 'Sun': [1,2,3,4,7,8,9,10,11], 'Moon': [2,5,7,9,11], 'Mars': [1,2,4,7,8,10,11], 'Mercury': [1,2,4,5,6,9,10,11], 'Jupiter': [1,2,3,4,7,8,10,11], 'Venus': [2,5,6,9,10,11], 'Saturn': [3,5,6,12], 'Lagna': [1,2,4,5,6,7,9,10,11] },
     'Venus': { 'Sun': [8,11,12], 'Moon': [1,2,3,4,5,8,9,11,12], 'Mars': [3,4,6,9,11,12], 'Mercury': [3,5,6,9,11], 'Jupiter': [5,8,9,10,11], 'Venus': [1,2,3,4,5,8,9,10,11], 'Saturn': [3,4,5,8,9,10,11], 'Lagna': [1,2,3,4,5,8,9,11] },
     'Saturn': { 'Sun': [1,2,4,7,8,10,11], 'Moon': [3,6,11], 'Mars': [3,5,6,10,11,12], 'Mercury': [6,8,9,10,11,12], 'Jupiter': [5,6,11,12], 'Venus': [6,11,12], 'Saturn': [3,5,6,11], 'Lagna': [1,3,4,6,10,11] },
     'Lagna': { 'Sun': [3,4,6,10,11,12], 'Moon': [3,6,10,11,12], 'Mars': [1,3,6,10,11], 'Mercury': [1,2,4,6,8,10,11], 'Jupiter': [1,2,4,5,6,7,9,10,11], 'Venus': [1,2,3,4,5,8,9], 'Saturn': [1,3,4,6,10,11], 'Lagna': [3,6,10,11] }
  };

  static Map<String, dynamic> _calculateAllVargas(Map<String, double> planetLons, double lagnaLon) {
    List<int> divs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 16, 20, 24, 27, 30, 40, 45, 60];
    List<String> names = [
      "ராசி\n(D1)", "ஹோரை\n(D2)", "திரேக்காணம்\n(D3)", "சதுர்த்தாம்சம்\n(D4)", "பஞ்சாம்சம்\n(D5)", 
      "சஷ்டாம்சம்\n(D6)", "சப்தாம்சம்\n(D7)", "அஷ்டாம்சம்\n(D8)", "நவாம்சம்\n(D9)", "தசாம்சம்\n(D10)", "துவாதசாம்சம்\n(D12)", 
      "சோடசாம்சம்\n(D16)", "விம்சாம்சம்\n(D20)", "சித்தாம்சம்\n(D24)", "நட்சத்திராம்சம்\n(D27)", 
      "திரிம்சாம்சம்\n(D30)", "கவேதாம்சம்\n(D40)", "அட்சவேதாம்சம்\n(D45)", "ஷஷ்டியாம்சம்\n(D60)"
    ];

    Map<String, Map<String, List<String>>> vargas = {};
    for (int i = 0; i < divs.length; i++) {
        Map<String, List<String>> chart = {}; for (var s in SIGNS) chart[s] = [];
        planetLons.forEach((pN, l) { chart[SIGNS[_calculateVargaSign(l, divs[i])]]!.add(TAMIL_PLANETS_SHORT[pN]!); });
        chart[SIGNS[_calculateVargaSign(lagnaLon, divs[i])]]!.add(TAMIL_PLANETS_SHORT['Lagna']!);
        vargas[names[i]] = chart;
    }
    return vargas;
  }

  static int calculateVargaSignForTest(double lon, int division) => _calculateVargaSign(lon, division);

  static int _calculateVargaSign(double lon, int division) {
    int rasiIdx = (lon / 30).floor() % 12;
    double degInRasi = lon % 30;

    switch (division) {
      case 1: // Rasi
        return rasiIdx;
      case 2: // Hora (Standard Parasari)
        bool isOdd = (rasiIdx + 1) % 2 != 0;
        if (isOdd) {
          return (degInRasi < 15) ? 4 : 3; // 4=Leo (Sun), 3=Cancer (Moon)
        } else {
          return (degInRasi < 15) ? 3 : 4; // 3=Cancer, 4=Leo
        }
      case 3: // Drekkana
        int part = (degInRasi / 10).floor();
        return (rasiIdx + (part * 4)) % 12; // Same, 5th, 9th
      case 4: // Chaturthamsha
        int part = (degInRasi / 7.5).floor();
        return (rasiIdx + (part * 3)) % 12; // 1, 4, 7, 10
      case 5: // Panchamsha
        int part = (degInRasi / 6).floor();
        bool isOdd = (rasiIdx + 1) % 2 != 0;
        if (isOdd) {
          const oddPanch = [0, 10, 8, 2, 6]; // Aries (Mars), Aquarius (Saturn), Sagittarius (Jupiter), Gemini (Mercury), Libra (Venus)
          return oddPanch[part % 5];
        } else {
          const evenPanch = [1, 5, 11, 9, 7]; // Taurus (Venus), Virgo (Mercury), Pisces (Jupiter), Capricorn (Saturn), Scorpio (Mars)
          return evenPanch[part % 5];
        }
      case 6: // Shashtamsha (D6) - Tamil textbook rule: Odd signs -> Aries, Gemini, Leo, Libra, Sag, Aqua; Even signs -> Taurus, Cancer, Virgo, Scorpio, Cap, Pisces
        int part = (degInRasi / 5).floor();
        bool isOdd = (rasiIdx + 1) % 2 != 0;
        return (isOdd ? 0 : 1) + (part * 2);
      case 7: // Saptamsha
        int part = (degInRasi / (30/7)).floor();
        bool isOdd = (rasiIdx + 1) % 2 != 0;
        int startRasi = isOdd ? rasiIdx : (rasiIdx + 6) % 12;
        return (startRasi + part) % 12;
      case 8: // Ashtamsha
        int part = (degInRasi / 3.75).floor();
        int group = (rasiIdx % 3); // 0=Movable, 1=Fixed, 2=Dual
        int startRasi = (group == 0) ? 0 : (group == 1 ? 8 : 4); // Ar, Sg, Le
        return (startRasi + part) % 12;
      case 9: // Navamsha (D9)
        int part = (degInRasi / (30 / 9)).floor();
        int group = (rasiIdx % 3); // 0=Movable, 1=Fixed, 2=Dual
        int startRasi = (group == 0) ? rasiIdx : (group == 1 ? (rasiIdx + 8) % 12 : (rasiIdx + 4) % 12);
        return (startRasi + part) % 12;
      case 10: // Dashamsha
        int part = (degInRasi / 3).floor();
        bool isOdd = (rasiIdx + 1) % 2 != 0;
        int startRasi = isOdd ? rasiIdx : (rasiIdx + 8) % 12;
        return (startRasi + part) % 12;
      case 12: // Dwadashamsha (D12) - 12 divisions of 2.5 deg each, starting from sign itself
        int part = (degInRasi / 2.5).floor();
        return (rasiIdx + part) % 12;
      case 16: // Shodashamsha
        int part = (degInRasi / (30/16)).floor();
        int type = (rasiIdx % 3); // 0=Movable, 1=Fixed, 2=Dual
        int startRasi = (type == 0) ? 0 : (type == 1 ? 4 : 8); // Aries, Leo, Sag
        return (startRasi + part) % 12;
      case 20: // Vimshamsha
        int part = (degInRasi / 1.5).floor();
        int group = (rasiIdx % 3); // 0=Movable, 1=Fixed, 2=Dual
        int startRasi = (group == 0) ? 0 : (group == 1 ? 8 : 4); // Ar, Sg, Le
        return (startRasi + part) % 12;
      case 24: // Siddhamsha (Chaturvimshamsha)
        int part = (degInRasi / 1.25).floor();
        bool isOdd = (rasiIdx + 1) % 2 != 0;
        int startRasi = isOdd ? 4 : 3; // Le, Cn
        return (startRasi + part) % 12;
      case 27: // Bhamsa (Nakshatramsha)
        int part = (degInRasi / (30/27)).floor();
        int triplicity = (rasiIdx % 4); // 0=Fire, 1=Earth, 2=Air, 3=Water
        int startRasi = (triplicity * 3) % 12; // Ar, Cn, Li, Cp (0, 3, 6, 9)
        return (startRasi + part) % 12;
      case 30: // Trimshamsha
        bool isOdd = (rasiIdx + 1) % 2 != 0;
        if (isOdd) {
          if (degInRasi < 5) return 0; // Aries (Mars)
          if (degInRasi < 10) return 10; // Aquarius (Saturn)
          if (degInRasi < 18) return 8; // Sagittarius (Jupiter)
          if (degInRasi < 25) return 2; // Gemini (Mercury)
          return 6; // Libra (Venus)
        } else {
          if (degInRasi < 5) return 1; // Taurus (Venus)
          if (degInRasi < 12) return 5; // Virgo (Mercury)
          if (degInRasi < 20) return 11; // Pisces (Jupiter)
          if (degInRasi < 25) return 9; // Capricorn (Saturn)
          return 7; // Scorpio (Mars)
        }
      case 40: // Khavedamsha
        int part = (degInRasi / 0.75).floor();
        bool isOdd = (rasiIdx + 1) % 2 != 0;
        int startRasi = isOdd ? 0 : 6; // Ar, Li
        return (startRasi + part) % 12;
      case 45: // Akshavedamsha
        int part = (degInRasi / (30/45)).floor();
        int group = (rasiIdx % 3); // 0=Movable, 1=Fixed, 2=Dual
        int startRasi = (group == 0) ? 0 : (group == 1 ? 4 : 8); // Ar, Le, Sg
        return (startRasi + part) % 12;
      case 60: // Shashtiamsha (D60) - 60 divisions of 0.5 deg each, starting from sign itself
        int part = (degInRasi / 0.5).floor();
        return (rasiIdx + part) % 12;
      default:
        return ((rasiIdx * division) + (degInRasi / (30 / division)).floor()) % 12;
    }
  }

  static Future<Map<String, dynamic>> _calculatePanchangam(double jd, Map<String, double> lons, DateTime dt, double lat, double lon, double timezone, AstroEngine engine) async {
    double sun = lons['Sun'] ?? 0; double moon = lons['Moon'] ?? 0; double diff = (moon - sun + 360) % 360;
    List<String> tithis = ["Prathama","Dwitiya","Tritiya","Chaturthi","Panchami","Shasthi","Saptami","Ashtami","Navami","Dashami","Ekadashi","Dwadashi","Trayodashi","Chaturdashi","Pournami","Prathama","Dwitiya","Tritiya","Chaturthi","Panchami","Shasthi","Saptami","Ashtami","Navami","Dashami","Ekadashi","Dwadashi","Trayodashi","Chaturdashi","Amavasya"];
    List<String> yogas = ["Vishkumbha","Priti","Ayushman","Saubhagya","Sobhana","Atiganda","Sukarma","Dhriti","Shula","Ganda","Vriddhi","Dhruva","Vyaghata","Harshana","Vajra","Siddhi","Vyatipata","Variyan","Parigha","Shiva","Siddha","Sadhya","Shubha","Shukla","Brahma","Indra","Vaidhriti"];
    List<String> karanas = ["Bava","Balava","Kaulava","Taitila","Garaja","Vanija","Vishti","Shakuni","Chatushpada","Nagawa","Kimstughna"];
    String sunrise = "-"; String sunset = "-";
    // debugPrint("Panchangam Calc - Timezone: $timezone, Lat: $lat, Lon: $lon");
    try {
      double jdNoonUt = jd.floor() + 0.5;
      double jdLocalMidnightUt = jdNoonUt - 0.5 - (timezone / 24.0);

      var phenomena = await engine.calcPhenomena(jdLocalMidnightUt, lat, lon, 0); // 0 = Sun
      
      double riseJD = phenomena['rise'] ?? 0;
      if (riseJD > 0) {
        sunrise = formatJDToLocalTime(riseJD, timezone, includeSeconds: true);
        // debugPrint("Sunrise for TZ $timezone: $sunrise");
      }
      
      double setJD = phenomena['set'] ?? 0;
      if (setJD > 0) {
        sunset = formatJDToLocalTime(setJD, timezone, includeSeconds: true);
      }
    } catch (e) { debugPrint("SunRise/Set Error: $e"); }

    // Day Lord Calculation
    List<String> weekLords = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    List<String> planetLords = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"];
    int weekday = dt.weekday % 7; // 0=Sun, 1=Mon... (Dart: 1=Mon, 7=Sun)
    
    // Check if time is before sunrise
    if (sunrise != "-") {
      try {
        List<String> parts = sunrise.split(" ")[0].split(":");
        int sH = int.parse(parts[0]); int sM = int.parse(parts[1]);
        if (sunrise.contains("PM") && sH < 12) sH += 12;
        if (sunrise.contains("AM") && sH == 12) sH = 0;
        
        if (dt.hour < sH || (dt.hour == sH && dt.minute < sM)) {
          weekday = (weekday - 1 + 7) % 7; // Previous day
        }
      } catch (e) { /* ignore */ }
    }
    String dayLord = planetLords[weekday];
    String vara = weekLords[weekday];
    int tMonthIdx = (sun / 30).floor(); int tDate = (sun % 30).floor() + 1;
    int yearOff = dt.year - 1987; if (dt.month < 4 || (dt.month == 4 && dt.day < 14)) yearOff -= 1;
    
    // Correct Karana Calculation
    int kIndex = (diff / 6).floor(); // 0 to 59
    String karanaName;
    if (kIndex == 0) {
      karanaName = "Kimstughna";
    } else if (kIndex >= 57) {
      if (kIndex == 57) karanaName = "Shakuni";
      else if (kIndex == 58) karanaName = "Chatushpada";
      else karanaName = "Nagawa";
    } else {
      // Movable Karanas (1 to 7) repeat
      List<String> movable = ["Bava", "Balava", "Kaulava", "Taitila", "Garaja", "Vanija", "Vishti"];
      karanaName = movable[(kIndex - 1) % 7];
    }

    int tithiIdx = (diff / 12).floor() % 30;
    final tithiName = tithis[tithiIdx];
    bool isShukla = (diff < 180);
    String tithiTamilBase = TAMIL_TITHIS[tithiIdx];
    String fullTithiDisplay;
    if (tithiIdx == 14) {
      fullTithiDisplay = "பௌர்ணமி (சுக்ல பக்ஷம்)";
    } else if (tithiIdx == 29) {
      fullTithiDisplay = "அமாவாசை (கிருஷ்ண பக்ஷம்)";
    } else {
      fullTithiDisplay = "${isShukla ? 'வளர்பிறை' : 'தேய்பிறை'} $tithiTamilBase (${isShukla ? 'சுக்ல' : 'கிருஷ்ண'} பக்ஷம்)";
    }

    String karanaTamil = TAMIL_KARANAS[karanaName] ?? karanaName;
    return <String, dynamic>{
      'tithi': fullTithiDisplay,
      'tithi_raw': tithiName,
      'yoga': yogas[(((sun + moon) % 360) / (360/27)).floor() % 27],
      'nakshatra': NAKSHATRAS[(moon / (360/27)).floor() % 27],
      'karana': karanaTamil,
      'karana_raw': karanaName,
      'paksham': isShukla ? "வளர்பிறை (சுக்ல பக்ஷம்)" : "தேய்பிறை (கிருஷ்ண பக்ஷம்)",
      'sunrise': sunrise,
      'sunset': sunset,
      'vara': vara,
      'day_lord': dayLord,
      'tamil_month': TAMIL_MONTHS[tMonthIdx % 12],
      'tamil_year': TAMIL_YEARS_60[yearOff % 60],
      'tamil_date': tDate,
      'diff': diff,
      'suniya_rasi': _calculateThithiSuniya(tithiName)
    };

  }
  
  static String _calculateThithiSuniya(String tithi) {
    const suniyaMap = {
      'Prathama': 'துலாம், மகரம்',
      'Dwitiya': 'தனுசு, மீனம்',
      'Tritiya': 'சிம்மம், மகரம்',
      'Chaturthi': 'ரிஷபம், கும்பம்',
      'Panchami': 'மிதுனம், கன்னி',
      'Shasthi': 'மேஷம், சிம்மம்',
      'Saptami': 'கடகம், தனுசு',
      'Ashtami': 'மிதுனம், கன்னி',
      'Navami': 'சிம்மம், விருச்சிககம்',
      'Dashami': 'சிம்மம், விருச்சிககம்',
      'Ekadashi': 'தனுசு, மீனம்',
      'Dwadashi': 'துலாம், மகரம்',
      'Trayodashi': 'ரிஷபம், சிம்மம்',
      'Chaturdashi': 'மிதுனம், கன்னி, தனுசு, மீனம்',
      'Pournami': '-',
      'Amavasya': '-'
    };
    return suniyaMap[tithi] ?? "-";
  }


  static String formatJDToLocalTime(double jd, double timezone, {DateTime? dtOverride, bool includeSeconds = false}) {
    try {
      DateTime dtLocal;
      if (dtOverride != null) {
        dtLocal = dtOverride;
      } else {
        // 1. Julian Day to Unix Millis
        int millis = ((jd - 2440587.5) * 86400 * 1000).round();
        // 2. Create UTC DateTime
        DateTime dtUtc = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
        // 3. Apply Local Timezone
        dtLocal = dtUtc.add(Duration(minutes: (timezone * 60).round()));
      }
      
      // 4. Format
      int hours = dtLocal.hour;
      int mins = dtLocal.minute;
      int secs = dtLocal.second;
      String p = hours >= 12 ? "PM" : "AM";
      int dH = hours % 12;
      if (dH == 0) dH = 12;
      
      if (includeSeconds) {
        return "${dH.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} $p";
      }
      return "${dH.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')} $p";
    } catch (e) {
      debugPrint("Time Format Error: $e");
      return "-";
    }
  }
  static Map<String, List<String>> _getFunctionalPlanets(String lagna) {
    const map = {
      'Mesham': {'S': ['Sun', 'Moon', 'Jupiter'], 'P': ['Mercury', 'Venus', 'Saturn'], 'M': ['Venus', 'Mars']},
      'Rishabam': {'S': ['Saturn', 'Mercury', 'Sun'], 'P': ['Moon', 'Jupiter', 'Mars'], 'M': ['Moon', 'Jupiter']},
      'Mithunam': {'S': ['Venus', 'Mercury'], 'P': ['Sun', 'Mars', 'Jupiter'], 'M': ['Moon', 'Jupiter']},
      'Kadagam': {'S': ['Moon', 'Mars', 'Jupiter'], 'P': ['Mercury', 'Venus'], 'M': ['Saturn', 'Mercury']},
      'Simmam': {'S': ['Sun', 'Mars', 'Jupiter'], 'P': ['Mercury', 'Venus'], 'M': ['Saturn', 'Mercury']},
      'Kanni': {'S': ['Mercury', 'Venus'], 'P': ['Moon', 'Mars', 'Jupiter'], 'M': ['Mars', 'Jupiter']},
      'Thulam': {'S': ['Venus', 'Saturn', 'Mercury'], 'P': ['Sun', 'Moon', 'Jupiter'], 'M': ['Sun', 'Mars']},
      'Viruchigam': {'S': ['Moon', 'Jupiter', 'Sun'], 'P': ['Mercury', 'Venus'], 'M': ['Venus', 'Mercury']},
      'Dhanusu': {'S': ['Jupiter', 'Sun', 'Mars'], 'P': ['Venus', 'Mercury'], 'M': ['Venus', 'Saturn']},
      'Magaram': {'S': ['Venus', 'Saturn', 'Mercury'], 'P': ['Moon', 'Mars', 'Jupiter'], 'M': ['Moon', 'Mars']},
      'Kumbam': {'S': ['Venus', 'Saturn'], 'P': ['Sun', 'Moon', 'Jupiter'], 'M': ['Sun', 'Jupiter']},
      'Meenam': {'S': ['Moon', 'Mars', 'Jupiter'], 'P': ['Sun', 'Venus', 'Saturn'], 'M': ['Venus', 'Saturn', 'Sun']}
    };
    final data = map[lagna] ?? map['Mesham']!;
    return {
      'benefics': data['S']!.map((p) => TAMIL_PLANETS[p] ?? p).toList().cast<String>(),
      'malefics': data['P']!.map((p) => TAMIL_PLANETS[p] ?? p).toList().cast<String>(),
      'marakas': data['M']!.map((p) => TAMIL_PLANETS[p] ?? p).toList().cast<String>(),
    };

  }

  static String _getRajju(String nakshatra) {
    const rajjus = {
      'Siro': ['Mrigashirsha', 'Chitra', 'Dhanishta'],
      'Kanta': ['Rohini', 'Arudra', 'Hastha', 'Swati', 'Shravana', 'Shatabhisha'],
      'Udara': ['Krittika', 'Punarvasu', 'Uttaraphalguni', 'Vishakha', 'Uttarashada', 'Purvabhadrapada'],
      'Kati': ['Bharani', 'Pushya', 'Purvaphalguni', 'Anuradha', 'Purvashada', 'Uttarabhadrapada'],
      'Pada': ['Ashwini', 'Ashlesha', 'Magha', 'Jyeshta', 'Mula', 'Revati']
    };
    final engNak = _nakshatraTamilToEng(nakshatra);
    for (var entry in rajjus.entries) {
      if (entry.value.contains(engNak)) {

        switch (entry.key) {
          case 'Siro': return "சிரசு ரஜ்ஜு";
          case 'Kanta': return "கண்ட ரஜ்ஜு";
          case 'Udara': return "உதர ரஜ்ஜு";
          case 'Kati': return "கடி ரஜ்ஜு";
          case 'Pada': return "பாத ரஜ்ஜு";
        }
      }
    }
    return "-";
  }

  static String _getAmirthaYoga(int weekday, String nakshatra) {
    const table = {
        0: {"Amirtha": ["Hastha", "Mula", "Uttarashada", "Uttaraphalguni", "Uttarabhadrapada"], "Marana": ["Bharani", "Magha", "Jyeshta", "Purvashada", "Purvabhadrapada"]},
        1: {"Amirtha": ["Sravana", "Rohini", "Pushya", "Mrigashirsha", "Chitra"], "Marana": ["Krittika", "Aslesha", "Chitra", "Vishakha", "Dhanishta"]},
        2: {"Amirtha": ["Ashwini", "Magha", "Anuradha", "Revati", "Uttara"], "Marana": ["Rohini", "Pushya", "Anuradha", "Shatabhisha", "Uttara"]},
        3: {"Amirtha": ["Arudra", "Swati", "Shatabhisha", "Punarvasu", "Vishakha"], "Marana": ["Mrigashirsha", "Swati", "Arudra", "Purvaphalguni", "Punarpusam"]},
        4: {"Amirtha": ["Bharani", "Purvaphalguni", "Purvashada", "Krittika", "Pushya"], "Marana": ["Punarvasu", "Arudra", "Aslesha", "Magha", "Swati"]},
        5: {"Amirtha": ["Rohini", "Hastha", "Pushya", "Ashwini", "Anuradha"], "Marana": ["Magha", "Purva", "Hastha", "Chitra", "Swati"]},
        6: {"Amirtha": ["Krithika", "Aslesha", "Magha", "Uttara", "Chitra"], "Marana": ["Rohini", "Mriga", "Punar", "Swati", "Shatabhisha"]}
    };
    final dayData = table[weekday % 7]!;
    String engNak = _nakshatraTamilToEng(nakshatra);
    if (dayData["Amirtha"]!.contains(engNak)) return "அமிர்த யோகம்";
    if (dayData["Marana"]!.contains(engNak)) return "மரண யோகம்";
    return "சித்த யோகம்";
  }

  static String _nakshatraTamilToEng(String tam) {
    final idx = NAKSHATRAS.indexOf(tam);
    if (idx == -1) return tam;
    const engList = ["Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashirsha", "Arudra", "Punarvasu", "Pushya", "Aslesha", "Magha", "Purvaphalguni", "Uttaraphalguni", "Hastha", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshta", "Mula", "Purvashada", "Uttarashada", "Shravana", "Dhanishta", "Shatabhisha", "Purvabhadrapada", "Uttarabhadrapada", "Revati"];
    return engList[idx];
  }

  static String _calculateHora(String sunrise, DateTime birthDt, int weekday) {
    try {
      final parts = sunrise.split(':');
      if (parts.length < 2) return "-";
      final riseH = int.parse(parts[0]);
      final riseM = int.parse(parts[1].split(' ')[0]);
      final riseTime = DateTime(birthDt.year, birthDt.month, birthDt.day, riseH, riseM);
      double diffHours = birthDt.difference(riseTime).inMinutes / 60.0;
      if (diffHours < 0) diffHours += 24;
      int horaIdx = diffHours.floor() % 24;
      const dayStartLords = [0, 3, 6, 2, 5, 1, 4];
      int startLordIdx = dayStartLords[weekday % 7];
      const horaPlanets = ['Sun', 'Venus', 'Mercury', 'Moon', 'Saturn', 'Jupiter', 'Mars'];
      final startPlanet = _engPlanetFromIdx(startLordIdx);
      int currentIdxInCycle = horaPlanets.indexOf(startPlanet);
      int targetPlanetIdx = (currentIdxInCycle + horaIdx) % 7;
      final targetPlanet = horaPlanets[targetPlanetIdx];
      return TAMIL_PLANETS[targetPlanet] ?? targetPlanet;
    } catch (e) { return "-"; }
  }

  static String _engPlanetFromIdx(int idx) {
    const list = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    return list[idx % 7];
  }

  static String _calculateAtmakaraka(Map<String, double> lons) {
    String bestP = "Sun";
    double maxDeg = -1;
    const physicalPlanets = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"];
    for (var p in physicalPlanets) {
      double deg = (lons[p] ?? 0) % 30;
      if (deg > maxDeg) { maxDeg = deg; bestP = p; }
    }
    return TAMIL_PLANETS[bestP] ?? bestP;

  }

  static String _calculateNazhigai(String sunrise, DateTime birthDt) {
    try {
      final parts = sunrise.split(':');
      if (parts.length < 2) return "-";
      final riseH = int.parse(parts[0]);
      final riseM = int.parse(parts[1].split(' ')[0]);
      final riseTime = DateTime(birthDt.year, birthDt.month, birthDt.day, riseH, riseM);
      int diffMins = birthDt.difference(riseTime).inMinutes;
      if (diffMins < 0) diffMins += 1440;
      double nazh = (diffMins / 24.0);
      int nInt = nazh.floor();
      int vInt = ((nazh - nInt) * 60).round();
      return "$nInt நாழிகை, $vInt விநாழிகை";
    } catch (e) { return "-"; }
  }

  static double _getHoraryLongitude(int number) {
    if (number < 1 || number > 249) return 0;
    
    final periods = [7.0, 20.0, 6.0, 10.0, 7.0, 18.0, 16.0, 19.0, 17.0]; // Ketu to Mercury
    final total = 120.0;
    final nakSize = 360.0 / 27.0;
    
    int count = 0;
    for (int n = 0; n < 27; n++) {
      // Correct start lord for each nakshatra:
      // Aswini (Ketu), Bharani (Ven), Krittika (Sun), ...
      final nakLords = [0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8];
      int startIdx = nakLords[n];
      
      double currentNakLon = n * nakSize;
      
      for (int s = 0; s < 9; s++) {
        int subLordIdx = (startIdx + s) % 9;
        double subSize = (periods[subLordIdx] / total) * nakSize;
        
        double subStart = currentNakLon;
        double subEnd = currentNakLon + subSize;
        
        // Check if this sub crosses a sign boundary (30 deg)
        double nextSignBoundary = ((subStart / 30).floor() + 1) * 30.0;
        
        if (subEnd > nextSignBoundary && (subEnd - nextSignBoundary) > 0.000001) {
          // Split into two
          count++;
          if (count == number) return subStart;
          
          count++;
          if (count == number) return nextSignBoundary;
        } else {
          count++;
          if (count == number) return subStart;
        }
        
        currentNakLon += subSize;
      }
    }
    return 0;
  }

  // Calculate Yogi, Avayogi, and Duplicate Yogi planets
  static Map<String, String> calculateYogiAvayogi(double sunLon, double moonLon) {
    double yogiPoint = (sunLon + moonLon + 93.333333) % 360;
    if (yogiPoint < 0) yogiPoint += 360;

    int nakIdx = (yogiPoint / (360.0 / 27.0)).floor() % 27;
    String yogiPlanet = VIMSHOTTARI_LORDS[nakIdx % 9];

    int yogiLordIdx = VIMSHOTTARI_LORDS.indexOf(yogiPlanet);
    String avayogiPlanet = VIMSHOTTARI_LORDS[(yogiLordIdx + 6) % 9];

    int signIdx = (yogiPoint / 30.0).floor() % 12;
    String duplicateYogi = SIGN_LORDS[signIdx];

    return {
      'yogi': yogiPlanet,
      'avayogi': avayogiPlanet,
      'duplicate': duplicateYogi,
    };
  }

  // Convert Julian Day to UTC DateTime
  static DateTime jdToDateTimeUtc(double jd) {
    int millis = ((jd - 2440587.5) * 86400 * 1000).round();
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  // Format a DateTime to HH:mm:ss for transit report display
  static String formatTransitTime(DateTime dt, double timezone) {
    DateTime local = dt.add(Duration(minutes: (timezone * 60).round()));
    return "${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}:${local.second.toString().padLeft(2, '0')}";
  }

  // Returns vibrant traditional colors for each planet (English/Tamil/Shortcodes)
  static Color getPlanetColor(String name) {
    name = name.trim().toLowerCase();
    
    if (name.contains('sun') || name.startsWith('சூரி') || name.startsWith('சூ')) {
      return const Color(0xFFE65100); // Dark Orange (சூரியன்)
    }
    if (name.contains('moon') || name.startsWith('சந்') || name.startsWith('தி')) {
      return const Color(0xFF1E88E5); // Blue (சந்திரன்)
    }
    if (name.contains('mars') || name.startsWith('செவ்') || name.startsWith('செ')) {
      return const Color(0xFFD32F2F); // Crimson Red (செவ்வாய்)
    }
    if (name.contains('mercury') || name.startsWith('புத') || name.startsWith('பு')) {
      return const Color(0xFF2E7D32); // Forest Green (புதன்)
    }
    if (name.contains('jupiter') || name.startsWith('குரு') || name.startsWith('வியா')) {
      return const Color(0xFFE65100); // Amber (குரு) - Wait, let's use 0xFFD84315 or 0xFFF57F17
    }
    if (name.contains('jupiter_val') || name.startsWith('வியாழன்') || name.contains('guru')) {
      return const Color(0xFFE65100);
    }
    if (name.startsWith('கு')) {
      // Avoid conflict with Ketu (கே) / Moon / Sun, 'கு' is Guru
      return const Color(0xFFF57F17); // Golden Yellow (குரு)
    }
    if (name.contains('venus') || name.startsWith('சுக்') || name.startsWith('சு')) {
      return const Color(0xFFD81B60); // Pink/Rose (சுக்கிரன்)
    }
    if (name.contains('saturn') || name.startsWith('சனி') || name.startsWith('ச')) {
      return const Color(0xFF3F51B5); // Indigo/Blue (சனி)
    }
    if (name.contains('rahu') || name.startsWith('ராகு') || name.startsWith('ரா')) {
      return const Color(0xFF795548); // Brown (ராகு)
    }
    if (name.contains('ketu') || name.startsWith('கேது') || name.startsWith('கே')) {
      return const Color(0xFF673AB7); // Purple (கேது)
    }
    if (name.contains('lagna') || name.startsWith('லக்') || name.startsWith('ல')) {
      return const Color(0xFF00796B); // Deep Teal (லக்னம்)
    }
    
    return Colors.black87; // default color
  }

  // Helper to find current sub lord boundary bounds
  static Map<String, double> getSubLordBounds(double longitude) {
    longitude = longitude % 360;
    if (longitude < 0) longitude += 360;
    
    int nakIdx = (longitude / (360.0 / 27.0)).floor();
    double nakStartDegree = nakIdx * (360.0 / 27.0);
    double degInNak = longitude - nakStartDegree;
    
    double arcMinutes = degInNak * 60.0;
    String startLord = VIMSHOTTARI_LORDS[nakIdx % 9];
    int startIndex = VIMSHOTTARI_LORDS.indexOf(startLord);
    
    double currentMinute = 0;
    for (int i = 0; i < 9; i++) {
      int lordIdx = (startIndex + i) % 9;
      String lordName = VIMSHOTTARI_LORDS[lordIdx];
      int years = VIMSHOTTARI_YEARS[lordName]!;
      double span = (years / 120.0) * 800.0; // 800 minutes is total Nakshatra span
      
      if (arcMinutes >= currentMinute && arcMinutes < currentMinute + span) {
        double subStart = nakStartDegree + currentMinute / 60.0;
        double subEnd = subStart + span / 60.0;
        return {
          'start': subStart % 360.0,
          'end': subEnd % 360.0,
        };
      }
      currentMinute += span;
    }
    
    return {
      'start': nakStartDegree,
      'end': (nakStartDegree + 13.333333) % 360.0,
    };
  }

  // Planet transit calculations using speed-based projection
  static List<PlanetTransitPeriod> calculatePlanetTransits(
    AstroEngine engine,
    double riseJD,
    double nextRiseJD,
    double lat,
    double lon,
    int planetId,
    String planetName,
  ) {
    List<PlanetTransitPeriod> periods = [];
    
    double currentJd = riseJD;
    double prevPeriodStartJd = riseJD;

    // Get initial state
    double lonVal = engine.calculatePlanetLongitude(jdToDateTimeUtc(currentJd), planetId);
    double lon1 = engine.calculatePlanetLongitude(jdToDateTimeUtc(currentJd - 0.005), planetId);
    double lon2 = engine.calculatePlanetLongitude(jdToDateTimeUtc(currentJd + 0.005), planetId);
    double speedVal = lon2 - lon1;
    if (speedVal > 180.0) speedVal -= 360.0;
    if (speedVal < -180.0) speedVal += 360.0;
    speedVal = speedVal / 0.01;
    
    Map<String, String> lords = getKPLords(lonVal);
    String prevStar = lords['nakshatra']!;
    String prevSub = lords['subLord']!;

    // Safety limit to prevent infinite loops (max 100 boundaries in 24 hours for a planet)
    int safetyCount = 0;

    while (currentJd < nextRiseJD && safetyCount < 100) {
      safetyCount++;
      
      var bounds = getSubLordBounds(lonVal);
      double targetLon = speedVal >= 0 ? bounds['end']! : bounds['start']!;
      
      // Calculate distance to boundary
      double dist;
      if (speedVal >= 0) {
        dist = (targetLon - lonVal + 360) % 360;
        if (dist < 0.0001) dist = 0.0001; // Avoid divide by zero/stagnation
      } else {
        dist = (lonVal - targetLon + 360) % 360;
        if (dist < 0.0001) dist = 0.0001;
      }
      
      // Projected time step (in Julian Days)
      double dt = dist / speedVal.abs();
      
      // If projection is extremely long (slow planet), cap it or check nextSunrise
      if (dt > (nextRiseJD - currentJd) || dt.isNaN || dt.isInfinite || dt == 0) {
        break;
      }

      double nextJd = currentJd + dt;
      if (nextJd > nextRiseJD) {
        break;
      }

      // Check state at nextJd
      double nextLon = engine.calculatePlanetLongitude(jdToDateTimeUtc(nextJd), planetId);
      var nextLords = getKPLords(nextLon);

      // Perform a binary search to find the exact boundary crossing time (bisection)
      double low = currentJd;
      double high = nextJd;
      for (int i = 0; i < 6; i++) {
        double mid = (low + high) / 2.0;
        double midLon = engine.calculatePlanetLongitude(jdToDateTimeUtc(mid), planetId);
        var midLords = getKPLords(midLon);
        if (midLords['nakshatra'] == prevStar && midLords['subLord'] == prevSub) {
          low = mid;
        } else {
          high = mid;
        }
      }
      double crossingJd = (low + high) / 2.0;

      periods.add(PlanetTransitPeriod(
        planetName: planetName,
        starName: prevStar,
        subLordName: prevSub,
        startTime: jdToDateTimeUtc(prevPeriodStartJd),
        endTime: jdToDateTimeUtc(crossingJd),
      ));

      prevPeriodStartJd = crossingJd;
      
      // Jump slightly past crossingJd to prevent repeating the boundary
      currentJd = crossingJd + 0.0001; // ~8.6 seconds
      if (currentJd > nextRiseJD) {
        currentJd = nextRiseJD;
        break;
      }

      // Update current values
      lonVal = engine.calculatePlanetLongitude(jdToDateTimeUtc(currentJd), planetId);
      double lon1Update = engine.calculatePlanetLongitude(jdToDateTimeUtc(currentJd - 0.005), planetId);
      double lon2Update = engine.calculatePlanetLongitude(jdToDateTimeUtc(currentJd + 0.005), planetId);
      speedVal = lon2Update - lon1Update;
      if (speedVal > 180.0) speedVal -= 360.0;
      if (speedVal < -180.0) speedVal += 360.0;
      speedVal = speedVal / 0.01;
      
      var postLords = getKPLords(lonVal);
      prevStar = postLords['nakshatra']!;
      prevSub = postLords['subLord']!;
    }

    // Add final period
    periods.add(PlanetTransitPeriod(
      planetName: planetName,
      starName: prevStar,
      subLordName: prevSub,
      startTime: jdToDateTimeUtc(prevPeriodStartJd),
      endTime: jdToDateTimeUtc(nextRiseJD),
    ));

    return periods;
  }

  // Lagna transit calculations using speed-based projection
  static List<PlanetTransitPeriod> calculateLagnaTransits(
    AstroEngine engine,
    double riseJD,
    double nextRiseJD,
    double lat,
    double lon,
  ) {
    List<PlanetTransitPeriod> periods = [];
    
    double currentJd = riseJD;
    double prevPeriodStartJd = riseJD;

    // Get initial state
    double lonVal = engine.calculateLagna(jdToDateTimeUtc(currentJd), lat, lon);
    
    // Estimate Lagna speed
    double nextLonVal = engine.calculateLagna(jdToDateTimeUtc(currentJd + 0.0001), lat, lon);
    double diff = nextLonVal - lonVal;
    if (diff < -180) diff += 360;
    if (diff > 180) diff -= 360;
    double speedVal = diff / 0.0001; // degrees per day (Julian Day)
    if (speedVal <= 0) speedVal = 361.0; // fallback speed (about 361 deg/day)

    Map<String, String> lords = getKPLords(lonVal);
    String prevStar = lords['nakshatra']!;
    String prevSub = lords['subLord']!;

    // Safety limit to prevent infinite loops (max 300 boundaries in 24 hours for Lagna)
    int safetyCount = 0;

    while (currentJd < nextRiseJD && safetyCount < 300) {
      safetyCount++;
      
      var bounds = getSubLordBounds(lonVal);
      double targetLon = bounds['end']!; // Lagna is always direct (speed > 0)
      
      double dist = (targetLon - lonVal + 360) % 360;
      if (dist < 0.0001) dist = 0.0001;
      
      double dt = dist / speedVal;
      
      if (dt > (nextRiseJD - currentJd) || dt.isNaN || dt.isInfinite || dt == 0) {
        break;
      }

      double nextJd = currentJd + dt;
      if (nextJd > nextRiseJD) {
        break;
      }

      // Check state at nextJd
      double nextLon = engine.calculateLagna(jdToDateTimeUtc(nextJd), lat, lon);
      
      // Perform a binary search to find the exact boundary crossing time
      double low = currentJd;
      double high = nextJd;
      for (int i = 0; i < 6; i++) {
        double mid = (low + high) / 2.0;
        double midLon = engine.calculateLagna(jdToDateTimeUtc(mid), lat, lon);
        var midLords = getKPLords(midLon);
        if (midLords['nakshatra'] == prevStar && midLords['subLord'] == prevSub) {
          low = mid;
        } else {
          high = mid;
        }
      }
      double crossingJd = (low + high) / 2.0;

      periods.add(PlanetTransitPeriod(
        planetName: "Lagna",
        starName: prevStar,
        subLordName: prevSub,
        startTime: jdToDateTimeUtc(prevPeriodStartJd),
        endTime: jdToDateTimeUtc(crossingJd),
      ));

      prevPeriodStartJd = crossingJd;
      
      currentJd = crossingJd + 0.00001; // ~0.86 seconds to skip past boundary
      if (currentJd > nextRiseJD) {
        currentJd = nextRiseJD;
        break;
      }

      // Update current values
      lonVal = engine.calculateLagna(jdToDateTimeUtc(currentJd), lat, lon);
      
      double postNextLonVal = engine.calculateLagna(jdToDateTimeUtc(currentJd + 0.0001), lat, lon);
      double postDiff = postNextLonVal - lonVal;
      if (postDiff < -180) postDiff += 360;
      if (postDiff > 180) postDiff -= 360;
      speedVal = postDiff / 0.0001;
      if (speedVal <= 0) speedVal = 361.0;

      var postLords = getKPLords(lonVal);
      prevStar = postLords['nakshatra']!;
      prevSub = postLords['subLord']!;
    }

    // Add final period
    periods.add(PlanetTransitPeriod(
      planetName: "Lagna",
      starName: prevStar,
      subLordName: prevSub,
      startTime: jdToDateTimeUtc(prevPeriodStartJd),
      endTime: jdToDateTimeUtc(nextRiseJD),
    ));

    return periods;
  }

  // Calculate Rahu Kalam, Yamakandam, and Gulika Kalam based on exact sunrise/sunset
  static Map<String, String> calculateKalamTimes(double riseJD, double setJD, double timezone, int weekday) {
    double partDuration = (setJD - riseJD) / 8.0;
    
    // Rahu parts: Sun=7, Mon=1, Tue=6, Wed=4, Thu=5, Fri=3, Sat=2
    const rahuParts = [7, 1, 6, 4, 5, 3, 2];
    // Yamakanda parts: Sun=5, Mon=4, Tue=3, Wed=2, Thu=1, Fri=7, Sat=6
    const yamaParts = [5, 4, 3, 2, 1, 7, 6];
    // Gulika parts: Sun=6, Mon=5, Tue=4, Wed=3, Thu=2, Fri=1, Sat=7
    const gulikaParts = [6, 5, 4, 3, 2, 1, 7];

    int rPart = rahuParts[weekday % 7];
    int yPart = yamaParts[weekday % 7];
    int gPart = gulikaParts[weekday % 7];

    String formatRange(double startJd, double endJd) {
      DateTime start = jdToDateTimeUtc(startJd).add(Duration(minutes: (timezone * 60).round()));
      DateTime end = jdToDateTimeUtc(endJd).add(Duration(minutes: (timezone * 60).round()));
      
      String formatTime(DateTime dt) {
        int hr = dt.hour % 12;
        if (hr == 0) hr = 12;
        return "${hr.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
      
      return "${formatTime(start)} - ${formatTime(end)}";
    }

    return {
      'rahu': formatRange(riseJD + rPart * partDuration, riseJD + (rPart + 1) * partDuration),
      'yama': formatRange(riseJD + yPart * partDuration, riseJD + (yPart + 1) * partDuration),
      'gulika': formatRange(riseJD + gPart * partDuration, riseJD + (gPart + 1) * partDuration),
    };
  }

  // Core orchestration method for dynamic Daily Panchangam and transits
  static Future<Map<String, dynamic>> calculateDailyPanchangam({
    required DateTime date,
    required double lat,
    required double lon,
    required double timezone,
  }) async {
    await init();
    final engine = AstroEngine();
    final int ayanamsaMode = await SettingsService.getAyanamsa();

    final localMidnight = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final utcMidnight = localMidnight.subtract(Duration(minutes: (timezone * 60).round()));
    double jdMidnight = engine.calculate(utcMidnight, lat, lon, ayanamsaMode: ayanamsaMode).jd;

    var phen1 = await engine.calcPhenomena(jdMidnight, lat, lon, 0); // 0 = Sun
    double riseJD = phen1['rise'] ?? (jdMidnight + 0.25);
    double setJD = phen1['set'] ?? (jdMidnight + 0.75);

    double jdNextMidnight = jdMidnight + 1.0;
    var phen2 = await engine.calcPhenomena(jdNextMidnight, lat, lon, 0);
    double nextRiseJD = phen2['rise'] ?? (jdNextMidnight + 0.25);

    DateTime sunriseUtc = jdToDateTimeUtc(riseJD);
    var sunResult = engine.calculate(sunriseUtc, lat, lon, ayanamsaMode: ayanamsaMode);

    Map<String, String> nithyaToTarget = {
      'Su': 'Sun', 'Mo': 'Moon', 'Ma': 'Mars', 'Me': 'Mercury', 'Ju': 'Jupiter', 'Ve': 'Venus', 'Sa': 'Saturn', 'Ra': 'Rahu', 'Ke': 'Ketu'
    };
    Map<String, double> lons = {};
    for (var p in sunResult.planets) {
      String targetName = nithyaToTarget[p.name] ?? p.name;
      lons[targetName] = p.siderealDegree;
    }
    
    var pancha = await _calculatePanchangam(sunResult.jd, lons, date, lat, lon, timezone, engine);

    // Day Lord Calculation
    int weekday = date.weekday % 7; // 0=Sun, 1=Mon...
    var kalam = calculateKalamTimes(riseJD, setJD, timezone, weekday);
    pancha['rahu_time'] = kalam['rahu']!;
    pancha['yama_time'] = kalam['yama']!;
    pancha['gulika_time'] = kalam['gulika']!;

    List<PlanetTransitPeriod> moonTransits = calculatePlanetTransits(engine, riseJD, nextRiseJD, lat, lon, 1, "Moon");
    
    List<PlanetTransitPeriod> otherPlanetsTransits = [];
    final List<Map<String, dynamic>> otherDefs = [
      {'id': 0, 'name': 'Sun'},
      {'id': 2, 'name': 'Mars'},
      {'id': 3, 'name': 'Mercury'},
      {'id': 4, 'name': 'Jupiter'},
      {'id': 5, 'name': 'Venus'},
      {'id': 6, 'name': 'Saturn'},
      {'id': 7, 'name': 'Rahu'},
      {'id': 8, 'name': 'Ketu'},
    ];
    for (var p in otherDefs) {
      otherPlanetsTransits.addAll(
        calculatePlanetTransits(engine, riseJD, nextRiseJD, lat, lon, p['id'] as int, p['name'] as String)
      );
    }

    List<PlanetTransitPeriod> lagnaTransits = calculateLagnaTransits(engine, riseJD, nextRiseJD, lat, lon);

    return {
      'panchangam': pancha,
      'sunrise_jd': riseJD,
      'sunset_jd': setJD,
      'next_sunrise_jd': nextRiseJD,
      'moon_transits': moonTransits,
      'other_transits': otherPlanetsTransits,
      'lagna_transits': lagnaTransits,
    };
  }

  static Future<Map<String, String>> calculateEndTimes(DateTime dt, double lat, double lon, double timezone) async {
    await init();
    final engine = AstroEngine();
    final int ayanamsaMode = await SettingsService.getAyanamsa();

    Map<String, int> getTNY(DateTime time) {
      final utDate = time.subtract(Duration(minutes: (timezone * 60).round()));
      final res = engine.calculate(utDate, lat, lon, ayanamsaMode: ayanamsaMode);

      double sun = 0.0;
      double moon = 0.0;
      for (var p in res.planets) {
        if (p.name == 'Su' || p.name == 'Sun') sun = p.siderealDegree;
        if (p.name == 'Mo' || p.name == 'Moon') moon = p.siderealDegree;
      }
      double diff = (moon - sun + 360) % 360;

      int tithiIdx = (diff / 12).floor() % 30;
      int nakIdx = (moon / (360 / 27)).floor() % 27;
      int yogaIdx = (((sun + moon) % 360) / (360 / 27)).floor() % 27;

      return {'t': tithiIdx, 'n': nakIdx, 'y': yogaIdx};
    }

    final current = getTNY(dt);
    final curT = current['t'];
    final curN = current['n'];
    final curY = current['y'];

    DateTime? findEndTime(String key, int currentVal) {
      DateTime start = dt;
      DateTime end = dt.add(const Duration(hours: 48));

      final endTNY = getTNY(end);
      if (endTNY[key] == currentVal) return null;

      for (int i = 0; i < 20; i++) {
        DateTime mid = start.add(Duration(seconds: end.difference(start).inSeconds ~/ 2));
        final midTNY = getTNY(mid);
        if (midTNY[key] == currentVal) {
          start = mid;
        } else {
          end = mid;
        }
      }
      return end;
    }

    DateTime? tEnd = findEndTime('t', curT!);
    DateTime? nEnd = findEndTime('n', curN!);
    DateTime? yEnd = findEndTime('y', curY!);

    String formatTime(DateTime? t) {
      if (t == null) return "நாளை வரை";
      String prefix = "";
      if (t.day != dt.day) {
        prefix = "நாளை ";
      }
      int h = t.hour % 12;
      if (h == 0) h = 12;
      String m = t.minute.toString().padLeft(2, '0');
      String ampm = t.hour >= 12 ? "PM" : "AM";
      return "$prefix$h:$m $ampm";
    }

    return {
      'tithi_end': formatTime(tEnd),
      'nakshatra_end': formatTime(nEnd),
      'yoga_end': formatTime(yEnd),
    };
  }
}

class PlanetTransitPeriod {
  final String planetName;
  final String starName;
  final String subLordName;
  final DateTime startTime;
  final DateTime endTime;

  PlanetTransitPeriod({
    required this.planetName,
    required this.starName,
    required this.subLordName,
    required this.startTime,
    required this.endTime,
  });
}
