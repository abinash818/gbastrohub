import 'dart:math' as math;
import '../data/nakshatra_data.dart';
import 'kp_service.dart';

class AstroSpecialCalculationsService {
  static const List<String> SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
  ];

  static const Map<String, String> TAMIL_SIGNS = {
    'Aries': 'மேஷம்', 'Taurus': 'ரிஷபம்', 'Gemini': 'மிதுனம்', 'Cancer': 'கடகம்',
    'Leo': 'சிம்மம்', 'Virgo': 'கன்னி', 'Libra': 'துலாம்', 'Scorpio': 'விருச்சிகம்',
    'Sagittarius': 'தனுசு', 'Capricorn': 'மகரம்', 'Aquarius': 'கும்பம்', 'Pisces': 'மீனம்'
  };

  static const List<String> NAKSHATRAS = [
    "Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashirsha", "Arudra",
    "Punarvasu", "Pushya", "Aslesha", "Magha", "Purvaphalguni", "Uttaraphalguni",
    "Hastha", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshta",
    "Mula", "Purvashada", "Uttarashada", "Shravana", "Dhanishta", "Shatabhisha",
    "Purvabhadrapada", "Uttarabhadrapada", "Revati"
  ];

  static const List<String> TAMIL_NAKSHATRAS = [
    "அஸ்வினி", "பரணி", "கார்த்திகை", "ரோகிணி", "மிருகசீரிஷம்", "திருவாதிரை",
    "புனர்பூசம்", "பூசம்", "ஆயில்யம்", "மகம்", "பூரம்", "உத்திரம்",
    "அஸ்தம்", "சித்திரை", "சுவாதி", "விசாகம்", "அனுஷம்", "கேட்டை",
    "மூலம்", "பூராடம்", "உத்திராடம்", "திருவோணம்", "அவிட்டம்", "சதயம்",
    "பூரட்டாதி", "உத்திரட்டாதி", "ரேவதி"
  ];

  static const List<String> NAK_LORDS = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];

  static const List<String> SIGN_LORDS = [
    'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
    'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter'
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 1. லக்னங்கள் & சிறப்புப் புள்ளிகள் (Lagnas & Special Points)
  // ──────────────────────────────────────────────────────────────────────────

  /// 1.1 இந்து லக்னம் (Indu Lagna)
  /// லக்னம் மற்றும் சந்திரனின் 9-ஆம் அதிபதிகளின் ஒளிக்கலை மதிப்புகள்:
  /// Sun:30, Moon:16, Mars:6, Merc:8, Jup:10, Ven:12, Sat:1
  static Map<String, dynamic> calculateInduLagna(double lagnaLon, double moonLon) {
    int lagnaRasi = (lagnaLon / 30).floor() % 12;
    int moonRasi = (moonLon / 30).floor() % 12;

    int lagna9thRasi = (lagnaRasi + 8) % 12;
    int moon9thRasi = (moonRasi + 8) % 12;

    String lagna9thLord = SIGN_LORDS[lagna9thRasi];
    String moon9thLord = SIGN_LORDS[moon9thRasi];

    const Map<String, int> rays = {
      'Sun': 30, 'Moon': 16, 'Mars': 6, 'Mercury': 8,
      'Jupiter': 10, 'Venus': 12, 'Saturn': 1, 'Rahu': 0, 'Ketu': 0
    };

    int totalRays = (rays[lagna9thLord] ?? 0) + (rays[moon9thLord] ?? 0);
    int rem = totalRays % 12;
    if (rem == 0) rem = 12;

    int induRasiIdx = (moonRasi + rem - 1) % 12;
    double induLon = (induRasiIdx * 30.0) + (moonLon % 30.0);

    return {
      'rasi_index': induRasiIdx,
      'rasi_name': SIGNS[induRasiIdx],
      'rasi_tamil': TAMIL_SIGNS[SIGNS[induRasiIdx]],
      'longitude': induLon,
      'formatted': KPService.formatDegrees(induLon),
      'lagna_9th_lord': lagna9thLord,
      'moon_9th_lord': moon9thLord,
      'total_rays': totalRays,
      'remainder': rem,
    };
  }

  /// 1.2 பார்ச்சூனா புள்ளி (Fortuna Point)
  /// பகல் பிறப்பு: Lagna + Moon - Sun
  /// இரவு பிறப்பு: Lagna + Sun - Moon
  static Map<String, dynamic> calculateFortuna(double lagnaLon, double sunLon, double moonLon, bool isDayBirth) {
    double fortunaLon;
    if (isDayBirth) {
      fortunaLon = (lagnaLon + moonLon - sunLon + 720.0) % 360.0;
    } else {
      fortunaLon = (lagnaLon + sunLon - moonLon + 720.0) % 360.0;
    }

    int rasiIdx = (fortunaLon / 30).floor() % 12;
    return {
      'longitude': fortunaLon,
      'rasi_index': rasiIdx,
      'rasi_name': SIGNS[rasiIdx],
      'rasi_tamil': TAMIL_SIGNS[SIGNS[rasiIdx]],
      'formatted': KPService.formatDegrees(fortunaLon),
      'is_day_birth': isDayBirth,
    };
  }

  /// 1.3 ஜெமினி லக்னங்கள் (Jaimini Special Lagnas: AL, UL, HL, GL)
  static Map<String, dynamic> calculateJaiminiLagnas({
    required double lagnaLon,
    required double sunLon,
    required DateTime birthDt,
    required String sunriseStr,
    required Map<String, double> planetLons,
  }) {
    int lagnaRasi = (lagnaLon / 30).floor() % 12;
    String lagnaLord = SIGN_LORDS[lagnaRasi];
    double lagnaLordLon = planetLons[lagnaLord] ?? lagnaLon;
    int lagnaLordRasi = (lagnaLordLon / 30).floor() % 12;

    // 1. பதா / ஆருட லக்னம் (Pada / Arudha Lagna - AL)
    int distLagna = (lagnaLordRasi - lagnaRasi + 12) % 12;
    int alRasi = (lagnaLordRasi + distLagna) % 12;
    // Jaimini Exception: If AL falls in same rasi or 7th, take 10th from it
    if (alRasi == lagnaRasi || alRasi == (lagnaRasi + 6) % 12) {
      alRasi = (alRasi + 9) % 12;
    }
    double alLon = (alRasi * 30.0) + (lagnaLon % 30.0);

    // 2. உபபதா லக்னம் (Upapada Lagna - UL) - Arudha of 12th house
    int house12Rasi = (lagnaRasi + 11) % 12;
    String lord12 = SIGN_LORDS[house12Rasi];
    double lord12Lon = planetLons[lord12] ?? lagnaLon;
    int lord12Rasi = (lord12Lon / 30).floor() % 12;
    int dist12 = (lord12Rasi - house12Rasi + 12) % 12;
    int ulRasi = (lord12Rasi + dist12) % 12;
    if (ulRasi == house12Rasi || ulRasi == (house12Rasi + 6) % 12) {
      ulRasi = (ulRasi + 9) % 12;
    }
    double ulLon = (ulRasi * 30.0) + (lagnaLon % 30.0);

    // 3. ஹோரா லக்னம் (Hora Lagna - HL) & 4. கடிகா லக்னம் (Ghatika Lagna - GL)
    double hoursFromSunrise = _getHoursFromSunrise(birthDt, sunriseStr);
    double nazhigaiFromSunrise = hoursFromSunrise * 2.5;

    // Hora Lagna: 1 Hour = 1 Rasi (30°)
    double hlLon = (sunLon + (hoursFromSunrise * 30.0)) % 360.0;
    int hlRasi = (hlLon / 30).floor() % 12;

    // Ghatika Lagna: 1 Ghatika (Nazhigai) = 1 Rasi (30°)
    double glLon = (lagnaLon + (nazhigaiFromSunrise * 30.0)) % 360.0;
    int glRasi = (glLon / 30).floor() % 12;

    return {
      'arudha_lagna': {
        'name': 'பதா / ஆருட லக்னம் (AL)',
        'rasi': SIGNS[alRasi],
        'rasi_tamil': TAMIL_SIGNS[SIGNS[alRasi]],
        'longitude': alLon,
        'formatted': KPService.formatDegrees(alLon),
      },
      'upapada_lagna': {
        'name': 'உபபதா லக்னம் (UL)',
        'rasi': SIGNS[ulRasi],
        'rasi_tamil': TAMIL_SIGNS[SIGNS[ulRasi]],
        'longitude': ulLon,
        'formatted': KPService.formatDegrees(ulLon),
      },
      'hora_lagna': {
        'name': 'ஹோரா லக்னம் (HL)',
        'rasi': SIGNS[hlRasi],
        'rasi_tamil': TAMIL_SIGNS[SIGNS[hlRasi]],
        'longitude': hlLon,
        'formatted': KPService.formatDegrees(hlLon),
      },
      'ghatika_lagna': {
        'name': 'கடிகா லக்னம் (GL)',
        'rasi': SIGNS[glRasi],
        'rasi_tamil': TAMIL_SIGNS[SIGNS[glRasi]],
        'longitude': glLon,
        'formatted': KPService.formatDegrees(glLon),
      },
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. யோகங்கள் & தோஷ அமைப்புகள் (Yogas & Planetary Roles)
  // ──────────────────────────────────────────────────────────────────────────

  /// 2.1 யோகி, அவயோகி, உபயோகி (பகர்ப்பு யோகி), முடக்கு
  static Map<String, dynamic> calculateYogiAvayogi(double sunLon, double moonLon) {
    // Yogi Point = Sun + Moon + 93° 20' (93.333333°)
    double yogiLon = (sunLon + moonLon + 93.3333333333) % 360.0;
    int yogiNakIdx = (yogiLon / (360.0 / 27.0)).floor() % 27;
    int yogiRasiIdx = (yogiLon / 30.0).floor() % 12;
    String yogiPlanet = NAK_LORDS[yogiNakIdx];
    String yogiRasiLord = SIGN_LORDS[yogiRasiIdx];

    // Avayogi Point = Yogi Point + 186° 40' (186.6666667°) -> 6th Nakshatra from Yogi
    double avayogiLon = (yogiLon + 186.6666666667) % 360.0;
    int avayogiNakIdx = (avayogiLon / (360.0 / 27.0)).floor() % 27;
    int avayogiRasiIdx = (avayogiLon / 30.0).floor() % 12;
    String avayogiPlanet = NAK_LORDS[avayogiNakIdx];

    // உபயோகி / பகர்ப்பு யோகி (Sahayogi): Yogi Rasi Lord
    String upaYogi = yogiRasiLord;

    // முடக்கு ராசி (Mudakku): Obstructed house opposite of Avayogi
    int mudakkuRasiIdx = (avayogiRasiIdx + 6) % 12;
    String mudakkuLord = SIGN_LORDS[mudakkuRasiIdx];

    return {
      'yogi': {
        'planet': yogiPlanet,
        'planet_tamil': KPService.TAMIL_PLANETS[yogiPlanet] ?? yogiPlanet,
        'nakshatra': NAKSHATRAS[yogiNakIdx],
        'nakshatra_tamil': TAMIL_NAKSHATRAS[yogiNakIdx],
        'rasi': SIGNS[yogiRasiIdx],
        'rasi_tamil': TAMIL_SIGNS[SIGNS[yogiRasiIdx]],
        'longitude': yogiLon,
        'formatted': KPService.formatDegrees(yogiLon),
      },
      'avayogi': {
        'planet': avayogiPlanet,
        'planet_tamil': KPService.TAMIL_PLANETS[avayogiPlanet] ?? avayogiPlanet,
        'nakshatra': NAKSHATRAS[avayogiNakIdx],
        'nakshatra_tamil': TAMIL_NAKSHATRAS[avayogiNakIdx],
        'rasi': SIGNS[avayogiRasiIdx],
        'rasi_tamil': TAMIL_SIGNS[SIGNS[avayogiRasiIdx]],
        'longitude': avayogiLon,
        'formatted': KPService.formatDegrees(avayogiLon),
      },
      'upayogi': {
        'planet': upaYogi,
        'planet_tamil': KPService.TAMIL_PLANETS[upaYogi] ?? upaYogi,
      },
      'mudakku': {
        'rasi': SIGNS[mudakkuRasiIdx],
        'rasi_tamil': TAMIL_SIGNS[SIGNS[mudakkuRasiIdx]],
        'lord': mudakkuLord,
        'lord_tamil': KPService.TAMIL_PLANETS[mudakkuLord] ?? mudakkuLord,
      },
    };
  }

  /// 2.2 பாதகன், வேதகன், போதகன், தாரகன்
  static Map<String, dynamic> calculatePlanetaryRoles(double lagnaLon, Map<String, double> planetLons) {
    int lagnaRasi = (lagnaLon / 30).floor() % 12;
    int mobilityType = lagnaRasi % 3; // 0=Movable (சரம்), 1=Fixed (ஸ்திரம்), 2=Dual (உபயம்)

    // பாதகாதிபதி: சரம்=11, ஸ்திரம்=9, உபயம்=7
    int badhakaHouse = (mobilityType == 0) ? 11 : (mobilityType == 1 ? 9 : 7);
    int badhakaRasi = (lagnaRasi + badhakaHouse - 1) % 12;
    String badhakaLord = SIGN_LORDS[badhakaRasi];

    int trikona5Rasi = (lagnaRasi + 4) % 12;
    int trikona9Rasi = (lagnaRasi + 8) % 12;
    String tharaka1 = SIGN_LORDS[trikona5Rasi];
    String tharaka2 = SIGN_LORDS[trikona9Rasi];

    return {
      'badhaka': {
        'house': badhakaHouse,
        'rasi': SIGNS[badhakaRasi],
        'rasi_tamil': TAMIL_SIGNS[SIGNS[badhakaRasi]],
        'lord': badhakaLord,
        'lord_tamil': KPService.TAMIL_PLANETS[badhakaLord] ?? badhakaLord,
      },
      'tharaka': {
        'lords': [tharaka1, tharaka2],
        'lords_tamil': [KPService.TAMIL_PLANETS[tharaka1] ?? tharaka1, KPService.TAMIL_PLANETS[tharaka2] ?? tharaka2],
      },
      'mobility': mobilityType == 0 ? 'சரம்' : (mobilityType == 1 ? 'ஸ்திரம்' : 'உபயம்'),
    };
  }

  /// 2.3 காலப்பகை அமைப்புகள் (Kala Pagai Dasa-Bhukthi Rules - 9 Specific Pairs)
  static Map<String, dynamic> checkKalaPagai({
    required List<dynamic> dasaList,
    required DateTime birthDt,
  }) {
    List<Map<String, dynamic>> warnings = [];
    final now = DateTime.now();

    // 9 Specific Kala Pagai Pairs requested:
    // சனி தசை: செவ்வாய் புத்தி
    // ராகு தசை: புதன் புத்தி
    // சூரிய தசை: சுக்கிர புத்தி
    // சந்திர தசை: குரு புத்தி
    // சுக்கிர தசை: சூரிய புத்தி
    // கேது தசை: சனி புத்தி
    // புதன் தசை: ராகு புத்தி
    // செவ்வாய் தசை: சனி புத்தி
    // குரு தசை: புதன் புத்தி
    const Map<String, String> kalaPagaiPairs = {
      'Saturn': 'Mars',      // சனி திசை -> செவ்வாய் புத்தி
      'Rahu': 'Mercury',     // ராகு திசை -> புதன் புத்தி
      'Sun': 'Venus',        // சூரிய திசை -> சுக்கிர புத்தி
      'Moon': 'Jupiter',     // சந்திர திசை -> குரு புத்தி
      'Venus': 'Sun',        // சுக்கிர திசை -> சூரிய புத்தி
      'Ketu': 'Saturn',      // கேது திசை -> சனி புத்தி
      'Mercury': 'Rahu',     // புதன் திசை -> ராகு புத்தி
      'Mars': 'Saturn',      // செவ்வாய் திசை -> சனி புத்தி
      'Jupiter': 'Mercury',  // குரு திசை -> புதன் புத்தி
    };

    for (var d in dasaList) {
      String dasaLord = d['lord']?.toString() ?? '';
      List subPeriods = d['subPeriods'] as List? ?? [];
      for (var b in subPeriods) {
        String bhukthiLord = b['lord']?.toString() ?? '';
        dynamic rawStart = b['start'];
        dynamic rawEnd = b['end'];
        DateTime? start = rawStart is DateTime ? rawStart : (rawStart is String ? DateTime.tryParse(rawStart) : null);
        DateTime? end = rawEnd is DateTime ? rawEnd : (rawEnd is String ? DateTime.tryParse(rawEnd) : null);

        if (start != null && end != null && kalaPagaiPairs[dasaLord] == bhukthiLord) {
          int startAge = start.year - birthDt.year;
          int endAge = end.year - birthDt.year;
          if (startAge < 0) startAge = 0;
          if (endAge < 0) endAge = 0;
          bool isCurrent = now.isAfter(start) && now.isBefore(end);

          warnings.add({
            'type': 'Dasa-Bhukthi',
            'pair': '$dasaLord-$bhukthiLord',
            'dasa': dasaLord,
            'bhukthi': bhukthiLord,
            'dasa_tamil': KPService.TAMIL_PLANETS[dasaLord] ?? dasaLord,
            'bhukthi_tamil': KPService.TAMIL_PLANETS[bhukthiLord] ?? bhukthiLord,
            'start': start,
            'end': end,
            'age_range': '$startAge - $endAge வயது',
            'is_current': isCurrent,
            'message': '${KPService.TAMIL_PLANETS[dasaLord] ?? dasaLord} தசையில் ${KPService.TAMIL_PLANETS[bhukthiLord] ?? bhukthiLord} புத்தி காலப்பகை அமைப்பாகும்.',
          });
        }
      }
    }

    return {
      'warnings': warnings,
      'has_current_warning': warnings.any((w) => w['is_current'] == true),
    };
  }

  /// 2.4 வைநாசிக தோஷ நட்சத்திர பாதம் (88th Pada from Janma Nakshatra Pada)
  static Map<String, dynamic> calculateVainasikaPada(double moonLon, Map<String, double> planetLons) {
    // 108 Padas total across 27 Nakshatras (4 Padas each, 3°20' = 3.3333333333° each)
    int janmaPadaGlobalIdx = (moonLon / (360.0 / 108.0)).floor() % 108;
    int janmaNakIdx = (moonLon / (360.0 / 27.0)).floor() % 27;
    int janmaPada = (janmaPadaGlobalIdx % 4) + 1;

    // 88th pada from Janma pada: (janmaPadaGlobalIdx + 88 - 1) % 108
    int vainasikaPadaGlobalIdx = (janmaPadaGlobalIdx + 87) % 108;
    int vainasikaNakIdx = (vainasikaPadaGlobalIdx / 4).floor() % 27;
    int vainasikaPada = (vainasikaPadaGlobalIdx % 4) + 1;
    int vainasikaRasiIdx = (vainasikaPadaGlobalIdx / 9).floor() % 12; // 9 padas per Rasi (30°)
    
    String vainasikaNakLord = NAK_LORDS[vainasikaNakIdx];
    String vainasikaRasiLord = SIGN_LORDS[vainasikaRasiIdx];

    // Check which planets fall in this 88th pada
    List<Map<String, dynamic>> afflictedPlanets = [];
    planetLons.forEach((p, lon) {
      int pGlobalPada = (lon / (360.0 / 108.0)).floor() % 108;
      if (pGlobalPada == vainasikaPadaGlobalIdx) {
        afflictedPlanets.add({
          'planet': p,
          'planet_tamil': KPService.TAMIL_PLANETS[p] ?? p,
          'longitude': lon,
          'formatted': KPService.formatDegrees(lon),
        });
      }
    });

    return {
      'janma_nakshatra': TAMIL_NAKSHATRAS[janmaNakIdx],
      'janma_pada': janmaPada,
      'vainasika_nakshatra': TAMIL_NAKSHATRAS[vainasikaNakIdx],
      'vainasika_nakshatra_en': NAKSHATRAS[vainasikaNakIdx],
      'vainasika_pada': vainasikaPada,
      'vainasika_rasi': SIGNS[vainasikaRasiIdx],
      'vainasika_rasi_tamil': TAMIL_SIGNS[SIGNS[vainasikaRasiIdx]],
      'vainasika_nak_lord': vainasikaNakLord,
      'vainasika_nak_lord_tamil': KPService.TAMIL_PLANETS[vainasikaNakLord] ?? vainasikaNakLord,
      'vainasika_rasi_lord': vainasikaRasiLord,
      'vainasika_rasi_lord_tamil': KPService.TAMIL_PLANETS[vainasikaRasiLord] ?? vainasikaRasiLord,
      'afflicted_planets': afflictedPlanets,
      'has_affliction': afflictedPlanets.isNotEmpty,
      'description': '${TAMIL_NAKSHATRAS[vainasikaNakIdx]} ($vainasikaPada-ம் பாதம்) - ${TAMIL_SIGNS[SIGNS[vainasikaRasiIdx]]}',
    };
  }

  /// 2.5 காலநட்பு & காலப்பகை வயது/திசை ஆய்வு (Kala Natpu & Kala Pagai Age/Dasa Rules)
  static Map<String, dynamic> checkKalaNatpuAndPagaiAges({
    required List<dynamic> dasaList,
    required DateTime birthDt,
  }) {
    final now = DateTime.now();
    double currentAge = (now.difference(birthDt).inDays / 365.25);
    if (currentAge < 0) currentAge = 0;

    // Rules Definitions
    // காலநட்பு (Benefic/Favorable Age Range per Dasa)
    final List<Map<String, dynamic>> natpuRules = [
      {'dasa': 'Moon', 'min_age': 0.0, 'max_age': 1.0, 'label': '1 வயதுக்குள்', 'lord_tamil': 'சந்திரன்', 'effect': 'நன்மை / வளர்ச்சி'},
      {'dasa': 'Mars', 'min_age': 2.0, 'max_age': 3.0, 'label': '2 முதல் 3 வயது வரை', 'lord_tamil': 'செவ்வாய்', 'effect': 'சுறுசுறுப்பு / ஆரோக்கியம்'},
      {'dasa': 'Mercury', 'min_age': 4.0, 'max_age': 12.0, 'label': '4 முதல் 12 வயது வரை', 'lord_tamil': 'புதன்', 'effect': 'கல்வி / புத்தி கூர்மை'},
      {'dasa': 'Venus', 'min_age': 12.0, 'max_age': 32.0, 'label': '12 முதல் 32 வயது வரை', 'lord_tamil': 'சுக்கிரன்', 'effect': 'திருமணம் / செல்வம் / கலை'},
      {'dasa': 'Jupiter', 'min_age': 33.0, 'max_age': 50.0, 'label': '33 முதல் 50 வயது வரை', 'lord_tamil': 'குரு', 'effect': 'பதவி / குழந்தை / மேன்மை'},
      {'dasa': 'Sun', 'min_age': 51.0, 'max_age': 70.0, 'label': '51 முதல் 70 வயது வரை', 'lord_tamil': 'சூரியன்', 'effect': 'கௌரவம் / ஆளுமை / ஆன்மீகம்'},
      {'dasa': 'Saturn', 'min_age': 71.0, 'max_age': 120.0, 'label': '71 முதல் 120 வயது வரை', 'lord_tamil': 'சனி', 'effect': 'ஆயுள் / அமைதி / பக்தி'},
    ];

    // காலப்பகை (Challenging/Incompatible Age Range per Dasa)
    final List<Map<String, dynamic>> pagaiRules = [
      {'dasa': 'Saturn', 'min_age': 0.0, 'max_age': 2.0, 'label': '2 வயது வரை', 'lord_tamil': 'சனி', 'risk': 'ஆரோக்கியக் குறைவு / மந்தம்'},
      {'dasa': 'Rahu', 'min_age': 3.0, 'max_age': 18.0, 'label': '3 முதல் 18 வயதுக்குள்', 'lord_tamil': 'ராகு', 'risk': 'பயம் / கவனச்சிதறல் / தடுமாற்றம்'},
      {'dasa': 'Sun', 'min_age': 11.0, 'max_age': 12.0, 'label': '11 முதல் 12 வயதுக்குள்', 'lord_tamil': 'சூரியன்', 'risk': 'உஷ்ணம் / பிடிவாதம்'},
      {'dasa': 'Moon', 'min_age': 18.0, 'max_age': 34.0, 'label': '18 முதல் 34 வயதுக்குள்', 'lord_tamil': 'சந்திரன்', 'risk': 'மன அலைச்சல் / சஞ்சலம்'},
      {'dasa': 'Venus', 'min_age': 34.0, 'max_age': 52.0, 'label': '34 முதல் 52 வயதுக்குள்', 'lord_tamil': 'சுக்கிரன்', 'risk': 'குடும்ப/பொருளாதார சவால்கள்'},
      {'dasa': 'Ketu', 'min_age': 52.0, 'max_age': 68.0, 'label': '52 முதல் 68 வயதுக்குள்', 'lord_tamil': 'கேது', 'risk': 'விரக்தி / உடல் உபாதைகள்'},
      {'dasa': 'Mercury', 'min_age': 68.0, 'max_age': 100.0, 'label': '68 முதல் 100 வயதுக்குள்', 'lord_tamil': 'புதன்', 'risk': 'நரம்பு / பலவீனம்'},
    ];

    // Map native's life dasa periods to check compatibility
    List<Map<String, dynamic>> timelineResults = [];
    Map<String, dynamic>? currentDasaStatus;

    for (var d in dasaList) {
      String dasaLord = d['lord']?.toString() ?? '';
      dynamic rawStart = d['start'];
      dynamic rawEnd = d['end'];
      DateTime? start = rawStart is DateTime ? rawStart : (rawStart is String ? DateTime.tryParse(rawStart) : null);
      DateTime? end = rawEnd is DateTime ? rawEnd : (rawEnd is String ? DateTime.tryParse(rawEnd) : null);

      if (start != null && end != null) {
        double startAge = (start.difference(birthDt).inDays / 365.25);
        double endAge = (end.difference(birthDt).inDays / 365.25);
        if (startAge < 0) startAge = 0;
        bool isCurrent = now.isAfter(start) && now.isBefore(end);

        // Check if overlaps with natpu or pagai rules for this dasaLord
        var matchingNatpu = natpuRules.where((r) => r['dasa'] == dasaLord && (startAge <= r['max_age'] && endAge >= r['min_age'])).toList();
        var matchingPagai = pagaiRules.where((r) => r['dasa'] == dasaLord && (startAge <= r['max_age'] && endAge >= r['min_age'])).toList();

        String status = "சம நிலை";
        String statusType = "neutral";
        String detail = "";

        if (matchingNatpu.isNotEmpty) {
          status = "காலநட்பு (நன்மை)";
          statusType = "natpu";
          detail = matchingNatpu.map((m) => "${m['label']}: ${m['effect']}").join(", ");
        } else if (matchingPagai.isNotEmpty) {
          status = "காலப்பகை (சவால்)";
          statusType = "pagai";
          detail = matchingPagai.map((m) => "${m['label']}: ${m['risk']}").join(", ");
        }

        var entry = {
          'dasa': dasaLord,
          'dasa_tamil': KPService.TAMIL_PLANETS[dasaLord] ?? dasaLord,
          'start_year': start.year,
          'end_year': end.year,
          'age_range': '${startAge.toStringAsFixed(0)} - ${endAge.toStringAsFixed(0)} வயது',
          'status': status,
          'status_type': statusType,
          'detail': detail,
          'is_current': isCurrent,
        };

        timelineResults.add(entry);
        if (isCurrent) {
          currentDasaStatus = entry;
        }
      }
    }

    return {
      'current_age': currentAge,
      'current_status': currentDasaStatus,
      'timeline': timelineResults,
      'natpu_rules': natpuRules,
      'pagai_rules': pagaiRules,
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. கிரக நிலைகள் & கணிதங்கள் (Planetary Positions & States)
  // ──────────────────────────────────────────────────────────────────────────

  /// 3.1 ஜெமினி 7 காரகங்கள் (Jaimini Karakas based on Degree in Sign)
  static Map<String, dynamic> calculateJaiminiKarakas(Map<String, double> planetLons) {
    const List<String> eligiblePlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    List<Map<String, dynamic>> planetDegrees = [];

    for (var p in eligiblePlanets) {
      double lon = planetLons[p] ?? 0.0;
      double degInRasi = lon % 30.0;
      planetDegrees.add({
        'planet': p,
        'deg': degInRasi,
        'lon': lon,
      });
    }

    // Sort descending by degree in sign
    planetDegrees.sort((a, b) => (b['deg'] as double).compareTo(a['deg'] as double));

    const List<String> karakaNames = [
      'ஆத்மகாரகன் (AK)',
      'அமாத்யகாரகன் (AmK)',
      'பிராத்ருகாரகன் (BK)',
      'மாத்ருகாரகன் (MK)',
      'புத்ரகாரகன் (PK)',
      'ஞானதிகாரகன் (GK)',
      'தாரகாரகன் (DK)'
    ];

    const List<String> karakaDescriptions = [
      'ஆன்மா, தலைமை, சுய வளர்ச்சி (Highest Degree)',
      'தொழில், அந்தஸ்து, அமைச்சர் நிலை',
      'சகோதரம், தைரியம், வழிகாட்டுதல்',
      'தாய், கல்வி, சுகபோகங்கள்',
      'புத்திர பாக்கியம், புத்தி கூர்மை',
      'எதிரிகள், கடன், நோய், உறவுகள்',
      'வாழ்க்கைத் துணை, கூட்டுத் தொழில் (Lowest Degree)'
    ];

    Map<String, dynamic> karakaMap = {};
    for (int i = 0; i < planetDegrees.length; i++) {
      String p = planetDegrees[i]['planet'];
      karakaMap[karakaNames[i]] = {
        'planet': p,
        'planet_tamil': KPService.TAMIL_PLANETS[p] ?? p,
        'degree': KPService.formatDegrees(planetDegrees[i]['deg']),
        'description': karakaDescriptions[i],
      };
    }

    return {
      'karakas': karakaMap,
      'atmakaraka': karakaMap['ஆத்மகாரகன் (AK)'],
      'darakaraka': karakaMap['தாரகாரகன் (DK)'],
    };
  }

  /// 3.2 உச்சம், நீசம், ஆட்சி, திக்பலம், நிஷ்பலம்
  static Map<String, dynamic> calculatePlanetaryAvasthas(Map<String, double> planetLons, double lagnaLon) {
    int lagnaRasi = (lagnaLon / 30).floor() % 12;
    Map<String, dynamic> avasthas = {};

    const Map<String, int> uchamRasis = {
      'Sun': 0, 'Moon': 1, 'Mars': 9, 'Mercury': 5, 'Jupiter': 3, 'Venus': 11, 'Saturn': 6, 'Rahu': 1, 'Ketu': 7
    };
    const Map<String, int> neesamRasis = {
      'Sun': 6, 'Moon': 7, 'Mars': 3, 'Mercury': 11, 'Jupiter': 9, 'Venus': 5, 'Saturn': 0, 'Rahu': 7, 'Ketu': 1
    };
    const Map<String, List<int>> aatchiRasis = {
      'Sun': [4], 'Moon': [3], 'Mars': [0, 7], 'Mercury': [2, 5],
      'Jupiter': [8, 11], 'Venus': [1, 6], 'Saturn': [9, 10], 'Rahu': [10], 'Ketu': [7]
    };

    // திக்பலம்: 1st house (Lagna) - Merc, Jup; 4th house - Moon, Ven; 7th house - Sat; 10th house - Sun, Mars
    const Map<String, int> digbalaHouses = {
      'Mercury': 1, 'Jupiter': 1,
      'Moon': 4, 'Venus': 4,
      'Saturn': 7,
      'Sun': 10, 'Mars': 10
    };

    planetLons.forEach((planet, lon) {
      int rasi = (lon / 30).floor() % 12;
      int houseFromLagna = ((rasi - lagnaRasi + 12) % 12) + 1;

      String status = "சமம்";
      if (uchamRasis[planet] == rasi) {
        status = "உச்சம்";
      } else if (neesamRasis[planet] == rasi) {
        status = "நீசம்";
      } else if (aatchiRasis[planet]?.contains(rasi) ?? false) {
        status = "ஆட்சி";
      }

      bool hasDigbala = digbalaHouses[planet] == houseFromLagna;

      avasthas[planet] = {
        'status': status,
        'has_digbala': hasDigbala,
        'digbala_text': hasDigbala ? "திக்பலம் உள்ளது" : "நிஷ்பலம்",
        'house': houseFromLagna,
        'rasi_tamil': TAMIL_SIGNS[SIGNS[rasi]],
      };
    });

    return avasthas;
  }

  /// 3.3 பரிவர்த்தனை (ராசி & நட்சத்திர பரிவர்த்தனை)
  static Map<String, dynamic> checkParivarthana(Map<String, double> planetLons) {
    List<Map<String, dynamic>> rasiParivarthana = [];
    List<Map<String, dynamic>> nakParivarthana = [];

    const planets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];

    // 1. ராசி பரிவர்த்தனை
    for (int i = 0; i < planets.length; i++) {
      for (int j = i + 1; j < planets.length; j++) {
        String p1 = planets[i];
        String p2 = planets[j];
        int rasi1 = (planetLons[p1]! / 30).floor() % 12;
        int rasi2 = (planetLons[p2]! / 30).floor() % 12;
        String lord1 = SIGN_LORDS[rasi1];
        String lord2 = SIGN_LORDS[rasi2];

        if (lord1 == p2 && lord2 == p1) {
          rasiParivarthana.add({
            'planet1': p1,
            'planet2': p2,
            'planet1_tamil': KPService.TAMIL_PLANETS[p1] ?? p1,
            'planet2_tamil': KPService.TAMIL_PLANETS[p2] ?? p2,
            'rasi1': SIGNS[rasi1],
            'rasi2': SIGNS[rasi2],
            'rasi1_tamil': TAMIL_SIGNS[SIGNS[rasi1]],
            'rasi2_tamil': TAMIL_SIGNS[SIGNS[rasi2]],
          });
        }
      }
    }

    // 2. நட்சத்திர பரிவர்த்தனை
    for (int i = 0; i < planets.length; i++) {
      for (int j = i + 1; j < planets.length; j++) {
        String p1 = planets[i];
        String p2 = planets[j];
        int nak1 = (planetLons[p1]! / (360.0 / 27.0)).floor() % 27;
        int nak2 = (planetLons[p2]! / (360.0 / 27.0)).floor() % 27;
        String lord1 = NAK_LORDS[nak1];
        String lord2 = NAK_LORDS[nak2];

        if (lord1 == p2 && lord2 == p1) {
          nakParivarthana.add({
            'planet1': p1,
            'planet2': p2,
            'planet1_tamil': KPService.TAMIL_PLANETS[p1] ?? p1,
            'planet2_tamil': KPService.TAMIL_PLANETS[p2] ?? p2,
            'nak1': NAKSHATRAS[nak1],
            'nak2': NAKSHATRAS[nak2],
            'nak1_tamil': TAMIL_NAKSHATRAS[nak1],
            'nak2_tamil': TAMIL_NAKSHATRAS[nak2],
          });
        }
      }
    }

    return {
      'rasi_parivarthana': rasiParivarthana,
      'nak_parivarthana': nakParivarthana,
      'has_parivarthana': rasiParivarthana.isNotEmpty || nakParivarthana.isNotEmpty,
    };
  }

  /// 3.4 விஷக்கடிகை & அமிர்தக்கடிகை
  static const List<int> VISHA_GHATIKA_START = [
    50, 24, 30, 40, 14, 11, 30, 20, 32, 30, 20, 18, 21, 20, 14, 14, 10, 14, 56, 24, 20, 10, 10, 18, 16, 24, 30
  ];
  static const List<int> AMRITA_GHATIKA_START = [
    42, 36, 48, 52, 38, 35, 54, 44, 56, 54, 44, 42, 45, 44, 38, 38, 34, 38, 20, 48, 44, 34, 34, 42, 40, 48, 54
  ];

  static Map<String, dynamic> checkVishaAmritaGhatika(Map<String, double> planetLons) {
    Map<String, dynamic> result = {};

    planetLons.forEach((planet, lon) {
      double nakSpan = 360.0 / 27.0;
      int nakIdx = (lon / nakSpan).floor() % 27;
      double degInNak = lon % nakSpan;
      double nazhigaiInNak = (degInNak / nakSpan) * 60.0;

      int vishaStart = VISHA_GHATIKA_START[nakIdx];
      int amritaStart = AMRITA_GHATIKA_START[nakIdx];

      bool inVisha = nazhigaiInNak >= vishaStart && nazhigaiInNak <= (vishaStart + 4);
      bool inAmrita = nazhigaiInNak >= amritaStart && nazhigaiInNak <= (amritaStart + 4);

      result[planet] = {
        'nakshatra': TAMIL_NAKSHATRAS[nakIdx],
        'nazhigai_in_nak': nazhigaiInNak.toStringAsFixed(1),
        'in_visha': inVisha,
        'in_amrita': inAmrita,
        'status': inVisha ? "விஷக்கடிகை" : (inAmrita ? "அமிர்தக்கடிகை" : "சாதாரண பகுதி"),
      };
    });

    return result;
  }

  /// 3.5 கரும நட்சத்திரங்கள் (Karma Nakshatras)
  static Map<String, dynamic> checkKarmaNakshatras(double moonLon, Map<String, double> planetLons) {
    int janmaNakIdx = (moonLon / (360.0 / 27.0)).floor() % 27;
    Set<int> karmaIndices = {
      janmaNakIdx,
      (janmaNakIdx + 9) % 27,
      (janmaNakIdx + 18) % 27,
      (janmaNakIdx + 6) % 27,
      (janmaNakIdx + 15) % 27,
      (janmaNakIdx + 24) % 27,
      (janmaNakIdx + 17) % 27,
      (janmaNakIdx + 26) % 27,
    };

    List<Map<String, dynamic>> planetsInKarma = [];
    planetLons.forEach((planet, lon) {
      int pNak = (lon / (360.0 / 27.0)).floor() % 27;
      if (karmaIndices.contains(pNak)) {
        int diff = (pNak - janmaNakIdx + 27) % 27 + 1;
        String role = "கரும நட்சத்திரம்";
        if (diff == 1) role = "ஜென்ம நட்சத்திரம்";
        else if (diff == 10) role = "அனுஜென்ம நட்சத்திரம்";
        else if (diff == 19) role = "திரிஜென்ம / கர்ம நட்சத்திரம்";
        else if (diff == 7) role = "நைதன / வதை நட்சத்திரம்";
        else if (diff == 16) role = "சங்காதக நட்சத்திரம்";
        else if (diff == 25) role = "மானச நட்சத்திரம்";

        planetsInKarma.add({
          'planet': planet,
          'planet_tamil': KPService.TAMIL_PLANETS[planet] ?? planet,
          'nakshatra': TAMIL_NAKSHATRAS[pNak],
          'role': role,
        });
      }
    });

    return {
      'janma_nakshatra': TAMIL_NAKSHATRAS[janmaNakIdx],
      'planets_in_karma': planetsInKarma,
    };
  }

  /// 3.6 புஷ்கர நவாம்ச பாதம் (Pushkara Navamsa - 24 Auspicious Padas)
  static Map<String, dynamic> checkPushkaraNavamsa(Map<String, double> planetLons, double lagnaLon) {
    Map<String, dynamic> pushkaraMap = {};

    void check(String name, double lon) {
      int rasiIdx = (lon / 30.0).floor() % 12;
      double degInRasi = lon % 30.0;
      int pada = (degInRasi / (30.0 / 9.0)).floor() + 1;

      int element = rasiIdx % 4; // 0=Fire, 1=Earth, 2=Air, 3=Water
      bool isPushkara = false;
      String navamsaSign = "";

      if (element == 0 && (pada == 7 || pada == 9)) {
        isPushkara = true;
        navamsaSign = pada == 7 ? "துலாம்" : "தனுசு";
      } else if (element == 1 && (pada == 3 || pada == 5)) {
        isPushkara = true;
        navamsaSign = pada == 3 ? "மீனம்" : "ரிஷபம்";
      } else if (element == 2 && (pada == 6 || pada == 8)) {
        isPushkara = true;
        navamsaSign = pada == 6 ? "மீனம்" : "ரிஷபம்";
      } else if (element == 3 && (pada == 1 || pada == 3)) {
        isPushkara = true;
        navamsaSign = pada == 1 ? "கடகம்" : "கன்னி";
      }

      pushkaraMap[name] = {
        'is_pushkara': isPushkara,
        'navamsa_sign': navamsaSign,
        'pada': pada,
        'status_text': isPushkara ? "புஷ்கர நவாம்சம் ($navamsaSign நவாம்சம்)" : "-",
      };
    }

    check('Lagna', lagnaLon);
    planetLons.forEach((p, l) => check(p, l));

    return pushkaraMap;
  }

  /// 3.6.1 சந்திராஷ்டம ராசி & நட்சத்திரம் (Chandrashtama Rasi & 17th Star)
  static Map<String, dynamic> calculateChandrashtama(double moonLon) {
    int moonRasiIdx = (moonLon / 30).floor() % 12;
    int moonNakIdx = (moonLon / (360.0 / 27.0)).floor() % 27;

    // 8th Rasi from Moon (சந்திராஷ்டம ராசி)
    int chRasiIdx = (moonRasiIdx + 7) % 12;
    String chRasiTamil = TAMIL_SIGNS[SIGNS[chRasiIdx]] ?? '';

    // 17th Nakshatra from Moon (சந்திராஷ்டம நட்சத்திரம்)
    int directStarIdx = (moonNakIdx + 16) % 27;
    String directStarTamil = TAMIL_NAKSHATRAS[directStarIdx];

    return {
      'rasi_index': chRasiIdx,
      'rasi_tamil': chRasiTamil,
      'direct_star_index': directStarIdx,
      'direct_star_tamil': directStarTamil,
      'direct_text': "$directStarTamil (17-வது நட்சத்திரம்)",
    };
  }

  /// 3.7 3, 5, 7 தாரைகள் (Vipat, Pratyak, Naidhana / Vadha Tharais)
  static Map<String, dynamic> checkNavataraPositions(double moonLon, Map<String, double> planetLons) {
    int janmaNakIdx = (moonLon / (360.0 / 27.0)).floor() % 27;

    const List<String> tharaiNames = [
      "1. ஜென்ம தாரை", "2. சம்பத் தாரை", "3. விபத்து தாரை",
      "4. க்ஷேம தாரை", "5. பிரத்யக் தாரை", "6. சாதக தாரை",
      "7. வதை / நைதன தாரை", "8. மித்ர தாரை", "9. பரம மித்ர தாரை"
    ];

    Map<String, dynamic> planetTharais = {};
    planetLons.forEach((planet, lon) {
      int pNak = (lon / (360.0 / 27.0)).floor() % 27;
      int dist = (pNak - janmaNakIdx + 27) % 27;
      int tharaiIndex = dist % 9;

      bool isVipat = tharaiIndex == 2;
      bool isPratyak = tharaiIndex == 4;
      bool isVadha = tharaiIndex == 6;

      planetTharais[planet] = {
        'tharai_number': tharaiIndex + 1,
        'tharai_name': tharaiNames[tharaiIndex],
        'nakshatra': TAMIL_NAKSHATRAS[pNak],
        'is_warning': isVipat || isPratyak || isVadha,
        'warning_type': isVadha ? "வதை தாரை (அதி எச்சரிக்கை)" : (isPratyak ? "பிரத்யக் தாரை" : (isVipat ? "விபத்து தாரை" : "சுப தாரை")),
      };
    });

    return {
      'janma_nakshatra': TAMIL_NAKSHATRAS[janmaNakIdx],
      'planet_tharais': planetTharais,
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. கணித முறைகள் & அட்டவணைகள் (Calculations & Divisions)
  // ──────────────────────────────────────────────────────────────────────────

  /// 4.1 உபகிரகங்கள் (Upagrahas - 5 Aprakash based on Sun & Time-based)
  static Map<String, dynamic> calculateUpagrahas(double sunLon, DateTime birthDt, String sunriseStr) {
    // 1. தூமன் (Dhuma) = Sun + 133° 20' (133.333333°)
    double dhuma = (sunLon + 133.3333333333) % 360.0;

    // 2. வ்யதீபாதன் (Vyatipata) = 360° - Dhuma
    double vyatipata = (360.0 - dhuma + 360.0) % 360.0;

    // 3. பரிவேடன் (Parivesha) = Vyatipata + 180°
    double parivesha = (vyatipata + 180.0) % 360.0;

    // 4. இந்திரசாபம் / கோதண்டம் (Indrachapa) = 360° - Parivesha
    double indrachapa = (360.0 - parivesha + 360.0) % 360.0;

    // 5. உபகேது / தூமகோது (Upaketu) = Indrachapa + 16° 40' (16.666667°)
    double upaketu = (indrachapa + 16.6666666667) % 360.0;

    Map<String, Map<String, dynamic>> upagrahaMap = {
      'தூமன் (Dhuma)': _formatPoint(dhuma),
      'வ்யதீபாதன் (Vyatipata)': _formatPoint(vyatipata),
      'பரிவேடன் (Parivesha)': _formatPoint(parivesha),
      'இந்திரசாபம் (Indrachapa)': _formatPoint(indrachapa),
      'உபகேது (Upaketu)': _formatPoint(upaketu),
    };

    return upagrahaMap;
  }

  static Map<String, dynamic> _formatPoint(double lon) {
    int rasi = (lon / 30.0).floor() % 12;
    int nak = (lon / (360.0 / 27.0)).floor() % 27;
    return {
      'longitude': lon,
      'rasi': SIGNS[rasi],
      'rasi_tamil': TAMIL_SIGNS[SIGNS[rasi]],
      'nakshatra': TAMIL_NAKSHATRAS[nak],
      'formatted': KPService.formatDegrees(lon),
    };
  }

  /// 4.2 ஹோரை & உள்-ஹோரை (Sub-Hora / Upa-Hora) அட்டவணை
  static List<Map<String, dynamic>> getHoraAndSubHoraTable(int weekday, DateTime sunrise) {
    const List<String> horaLordsByDay = [
      'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'
    ];
    const List<String> horaCycle = [
      'Sun', 'Venus', 'Mercury', 'Moon', 'Saturn', 'Jupiter', 'Mars'
    ];

    int dayIdx = (weekday == 7) ? 0 : weekday;
    String firstHora = horaLordsByDay[dayIdx];
    int startCycleIdx = horaCycle.indexOf(firstHora);

    List<Map<String, dynamic>> table = [];
    DateTime currentTime = sunrise;

    for (int h = 0; h < 24; h++) {
      String lord = horaCycle[(startCycleIdx + h) % 7];
      DateTime horaEnd = currentTime.add(const Duration(hours: 1));

      int subStartIdx = horaCycle.indexOf(lord);
      List<String> subHoras = [];
      for (int s = 0; s < 5; s++) {
        subHoras.add(KPService.TAMIL_PLANETS[horaCycle[(subStartIdx + s) % 7]] ?? horaCycle[(subStartIdx + s) % 7]);
      }

      table.add({
        'hora_number': h + 1,
        'start_time': "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}",
        'end_time': "${horaEnd.hour.toString().padLeft(2, '0')}:${horaEnd.minute.toString().padLeft(2, '0')}",
        'lord': lord,
        'lord_tamil': KPService.TAMIL_PLANETS[lord] ?? lord,
        'sub_horas': subHoras,
      });

      currentTime = horaEnd;
    }

    return table;
  }

  /// 4.3 பஞ்ச பட்சி காலம் (Pancha Pakshi Kalam)
  static Map<String, dynamic> calculatePanchaPakshi({
    required double moonLon,
    required DateTime currentDt,
    required DateTime sunrise,
    required bool isShuklaPaksha,
  }) {
    int nakIdx = (moonLon / (360.0 / 27.0)).floor() % 27;

    const List<String> pakshis = ["வல்லூறு", "ஆந்தை", "காகம்", "கோழி", "மயில்"];
    int pakshiIdx;
    if (nakIdx < 5) pakshiIdx = 0;
    else if (nakIdx < 11) pakshiIdx = 1;
    else if (nakIdx < 17) pakshiIdx = 2;
    else if (nakIdx < 22) pakshiIdx = 3;
    else pakshiIdx = 4;

    String myPakshi = pakshis[pakshiIdx];
    const List<String> activities = ["ஊண் (உணவு)", "நடை (பயணம்)", "அரசு (ஆட்சி)", "துயில் (தூக்கம்)", "மரணம் (செயலிழப்பு)"];

    double hoursFromSunrise = currentDt.difference(sunrise).inMinutes / 60.0;
    if (hoursFromSunrise < 0) hoursFromSunrise += 24.0;
    int yamaIdx = (hoursFromSunrise / 2.4).floor() % 5;

    int actIdx = (pakshiIdx + yamaIdx) % 5;
    String currentActivity = activities[actIdx];

    return {
      'pakshi': myPakshi,
      'paksha': isShuklaPaksha ? "வளர்பிறை" : "தேய்பிறை",
      'current_activity': currentActivity,
      'is_favorable': actIdx == 0 || actIdx == 2,
      'activity_description': actIdx == 2 ? "மிகவும் உன்னதமான நேரம் (அரசு)" : (actIdx == 0 ? "சுப காரியங்களுக்கு உகந்தது (ஊண்)" : "முக்கிய முடிவுகளைத் தவிர்க்கவும்"),
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. பொதுவான அமைப்புகள் & கருவிகள் (Settings & Tools)
  // ──────────────────────────────────────────────────────────────────────────

  /// 5.1 நாழிகை ⟷ மணி மாற்றி (Nazhigai to Hours / Hours to Nazhigai Converter)
  static Map<String, dynamic> convertHoursToNazhigai(double hours) {
    double totalNazhigai = hours * 2.5;
    int n = totalNazhigai.floor();
    double remV = (totalNazhigai - n) * 60.0;
    int v = remV.round();
    return {
      'nazhigai': n,
      'vinazhigai': v,
      'formatted': "$n நாழிகை, $v விநாழிகை",
    };
  }

  static double convertNazhigaiToHours(int nazhigai, int vinazhigai) {
    double totalNazhigai = nazhigai + (vinazhigai / 60.0);
    return totalNazhigai / 2.5;
  }

  /// 5.2 லக்னம் மாறும் நேரக் காட்டி (Lagna Time Change Indicator)
  static Map<String, dynamic> calculateLagnaTimeChange(double lagnaLon, DateTime birthDt) {
    double degInRasi = lagnaLon % 30.0;
    double remainingDeg = 30.0 - degInRasi;

    // தோராயமாக 1 பாகை = 4 நிமிடங்கள்
    double remainingMinutes = remainingDeg * 4.0;
    DateTime nextLagnaTime = birthDt.add(Duration(minutes: remainingMinutes.round()));

    int nextRasiIdx = ((lagnaLon / 30.0).floor() + 1) % 12;

    return {
      'current_deg_in_rasi': degInRasi.toStringAsFixed(2),
      'remaining_deg': remainingDeg.toStringAsFixed(2),
      'remaining_minutes': remainingMinutes.round(),
      'next_lagna_time': nextLagnaTime,
      'next_lagna_rasi': SIGNS[nextRasiIdx],
      'next_lagna_tamil': TAMIL_SIGNS[SIGNS[nextRasiIdx]],
      'formatted_text': "அடுத்த ${TAMIL_SIGNS[SIGNS[nextRasiIdx]]} லக்னம் இன்னும் ${remainingMinutes.round()} நிமிடங்களில் தொடங்கும்.",
    };
  }

  static double _getHoursFromSunrise(DateTime dt, String sunriseStr) {
    try {
      final parts = sunriseStr.split(':');
      if (parts.length >= 2) {
        int sHour = int.tryParse(parts[0].trim()) ?? 6;
        int sMin = int.tryParse(parts[1].trim()) ?? 0;
        DateTime sr = DateTime(dt.year, dt.month, dt.day, sHour, sMin);
        double diffHours = dt.difference(sr).inMinutes / 60.0;
        if (diffHours < 0) diffHours += 24.0;
        return diffHours;
      }
    } catch (_) {}
    return 6.0;
  }
}
