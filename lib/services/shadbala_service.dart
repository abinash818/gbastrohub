import 'dart:math' as math;
import 'kp_service.dart';

class ShadbalaService {
  static const List<String> PLANETS = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'
  ];

  static const Map<String, String> TAMIL_PLANETS = {
    'Sun': 'சூரியன்',
    'Moon': 'சந்திரன்',
    'Mars': 'செவ்வாய்',
    'Mercury': 'புதன்',
    'Jupiter': 'குரு',
    'Venus': 'சுக்கிரன்',
    'Saturn': 'சனி',
  };

  // Deep exaltation points (Paramochha Longitudes in degrees)
  static const Map<String, double> DEEP_EXALTATION = {
    'Sun': 10.0,       // Aries 10°
    'Moon': 33.0,      // Taurus 3°
    'Mars': 298.0,     // Capricorn 28°
    'Mercury': 165.0,  // Virgo 15°
    'Jupiter': 95.0,   // Cancer 5°
    'Venus': 357.0,    // Pisces 27°
    'Saturn': 200.0,   // Libra 20°
  };

  // Naisargika Bala (Natural Strength in Virupas, Max = 60)
  static const Map<String, double> NAISARGIKA_BALA = {
    'Sun': 60.0,
    'Moon': 51.43,
    'Venus': 42.86,
    'Jupiter': 34.29,
    'Mercury': 25.71,
    'Mars': 17.14,
    'Saturn': 8.57,
  };

  // Minimum Required Shadbala in Rupas
  static const Map<String, double> REQUIRED_SHADBALA_RUPAS = {
    'Sun': 6.5,
    'Moon': 6.0,
    'Mars': 5.0,
    'Mercury': 7.0,
    'Jupiter': 6.5,
    'Venus': 5.5,
    'Saturn': 5.0,
  };

  /// Main calculation method for Complete 6-Fold Shadbala System
  static Map<String, dynamic> calculateShadbala({
    required Map<String, double> planetLons,
    required double lagnaLon,
    required DateTime birthDt,
    required String sunriseStr,
    required String sunsetStr,
    Map<String, dynamic>? planetSpeeds,
    Map<String, dynamic>? planetRetrograde,
  }) {
    Map<String, dynamic> sthanaBala = _calculateSthanaBala(planetLons, lagnaLon);
    Map<String, dynamic> digBala = _calculateDigBala(planetLons, lagnaLon);
    Map<String, dynamic> kaalaBala = _calculateKaalaBala(planetLons, birthDt, sunriseStr, sunsetStr);
    Map<String, dynamic> cheshtaBala = _calculateCheshtaBala(planetLons, planetRetrograde, kaalaBala);
    Map<String, dynamic> naisargikaBala = _calculateNaisargikaBala();
    Map<String, dynamic> drikBala = _calculateDrikBala(planetLons);

    Map<String, Map<String, dynamic>> planetShadbala = {};
    List<Map<String, dynamic>> summaryList = [];

    for (var p in PLANETS) {
      double sBala = (sthanaBala[p]?['total'] as num?)?.toDouble() ?? 0.0;
      double dBala = (digBala[p]?['total'] as num?)?.toDouble() ?? 0.0;
      double kBala = (kaalaBala[p]?['total'] as num?)?.toDouble() ?? 0.0;
      double cBala = (cheshtaBala[p]?['total'] as num?)?.toDouble() ?? 0.0;
      double nBala = (naisargikaBala[p]?['total'] as num?)?.toDouble() ?? 0.0;
      double drBala = (drikBala[p]?['total'] as num?)?.toDouble() ?? 0.0;

      double totalVirupas = sBala + dBala + kBala + cBala + nBala + drBala;
      if (totalVirupas < 0) totalVirupas = 0;

      double totalRupas = totalVirupas / 60.0;
      double requiredRupas = REQUIRED_SHADBALA_RUPAS[p] ?? 5.5;
      double requiredVirupas = requiredRupas * 60.0;
      double ratio = totalRupas / requiredRupas;

      String strengthStatus = ratio >= 1.2
          ? 'மிக பலம் (Very Strong)'
          : (ratio >= 1.0 ? 'போதுமான பலம் (Strong)' : 'பலவீனமானது (Weak)');

      var pData = {
        'planet': p,
        'planet_tamil': TAMIL_PLANETS[p] ?? p,
        'sthana_bala': sBala,
        'dig_bala': dBala,
        'kaala_bala': kBala,
        'cheshta_bala': cBala,
        'naisargika_bala': nBala,
        'drik_bala': drBala,
        'total_virupas': totalVirupas,
        'total_rupas': totalRupas,
        'required_rupas': requiredRupas,
        'required_virupas': requiredVirupas,
        'ratio': ratio,
        'percentage': (ratio * 100).clamp(0, 300),
        'status': strengthStatus,
      };

      planetShadbala[p] = pData;
      summaryList.add(pData);
    }

    // Rank planets by ratio descending
    summaryList.sort((a, b) => (b['ratio'] as double).compareTo(a['ratio'] as double));
    for (int i = 0; i < summaryList.length; i++) {
      summaryList[i]['rank'] = i + 1;
      planetShadbala[summaryList[i]['planet']]!['rank'] = i + 1;
    }

    return {
      'planets': planetShadbala,
      'summary_list': summaryList,
      'top_planet': summaryList.first,
      'lowest_planet': summaryList.last,
      'sthana_bala_details': sthanaBala,
      'dig_bala_details': digBala,
      'kaala_bala_details': kaalaBala,
      'cheshta_bala_details': cheshtaBala,
      'naisargika_bala_details': naisargikaBala,
      'drik_bala_details': drikBala,
    };
  }

  // ── 1. ஸ்தான பலம் (Sthana Bala) ──────────────────────────────────────────
  static Map<String, dynamic> _calculateSthanaBala(Map<String, double> planetLons, double lagnaLon) {
    Map<String, dynamic> result = {};
    int lagnaRasi = (lagnaLon / 30).floor() % 12;

    for (var p in PLANETS) {
      double lon = planetLons[p] ?? 0.0;
      int rasiIdx = (lon / 30).floor() % 12;
      double degInRasi = lon % 30.0;

      // 1. உச்சா பலம் (Uchha Bala: 0 - 60 Virupas)
      double deepExalt = DEEP_EXALTATION[p] ?? 0.0;
      double deepDebil = (deepExalt + 180.0) % 360.0;
      double distDebil = (lon - deepDebil).abs();
      if (distDebil > 180) distDebil = 360 - distDebil;
      double uchhaBala = (distDebil / 180.0) * 60.0;

      // 2. சப்தவர்க்கஜ பலம் (Saptavargaja Bala: D1, D2, D3, D7, D9, D12, D30)
      double saptavargajaBala = _calculateSaptavargajaBala(p, lon);

      // 3. ஓஜ-யுக்ம பலம் (Ojhayugma Bala: Odd / Even Sign & Navamsha)
      bool isRasiOdd = (rasiIdx % 2 == 0); // 0=Aries (Odd), 1=Taurus (Even)
      int navamshaIdx = KPService.calculateVargaSignForTest(lon, 9);
      bool isNavOdd = (navamshaIdx % 2 == 0);

      double ojhaBala = 0.0;
      if (p == 'Sun' || p == 'Mars' || p == 'Jupiter' || p == 'Mercury') {
        // Male planets prefer Odd signs
        if (isRasiOdd) ojhaBala += 15.0;
        if (isNavOdd) ojhaBala += 15.0;
      } else {
        // Female planets prefer Even signs (Moon, Venus, Saturn)
        if (!isRasiOdd) ojhaBala += 15.0;
        if (!isNavOdd) ojhaBala += 15.0;
      }

      // 4. கேந்திராதி பலம் (Kendradi Bala: Kendra=60, Panaphara=30, Apoklima=15)
      int houseFromLagna = ((rasiIdx - lagnaRasi + 12) % 12) + 1;
      double kendraBala = 15.0;
      if (houseFromLagna == 1 || houseFromLagna == 4 || houseFromLagna == 7 || houseFromLagna == 10) {
        kendraBala = 60.0; // Kendra
      } else if (houseFromLagna == 2 || houseFromLagna == 5 || houseFromLagna == 8 || houseFromLagna == 11) {
        kendraBala = 30.0; // Panaphara
      } else {
        kendraBala = 15.0; // Apoklima
      }

      // 5. த்ரேக்காண பலம் (Drekkana Bala)
      int drekkanaPart = (degInRasi / 10).floor(); // 0, 1, 2
      double drekkanaBala = 0.0;
      if ((p == 'Sun' || p == 'Mars' || p == 'Jupiter') && drekkanaPart == 0) {
        drekkanaBala = 15.0; // Male planets in 1st decan
      } else if ((p == 'Saturn' || p == 'Mercury') && drekkanaPart == 1) {
        drekkanaBala = 15.0; // Hermaphrodite planets in 2nd decan
      } else if ((p == 'Moon' || p == 'Venus') && drekkanaPart == 2) {
        drekkanaBala = 15.0; // Female planets in 3rd decan
      }

      double totalSthana = uchhaBala + saptavargajaBala + ojhaBala + kendraBala + drekkanaBala;

      result[p] = {
        'total': totalSthana,
        'uchha_bala': uchhaBala,
        'saptavargaja_bala': saptavargajaBala,
        'ojhayugma_bala': ojhaBala,
        'kendradi_bala': kendraBala,
        'drekkana_bala': drekkanaBala,
      };
    }

    return result;
  }

  static double _calculateSaptavargajaBala(String planet, double lon) {
    const List<int> vargas = [1, 2, 3, 7, 9, 12, 30];
    double totalBala = 0.0;

    for (var v in vargas) {
      int sign = KPService.calculateVargaSignForTest(lon, v);
      String signLord = KPService.SIGN_LORDS[sign];

      if (signLord == planet) {
        totalBala += 30.0; // Own sign (Swakshetra)
      } else {
        // Natural relationship strength
        totalBala += 15.0; // Mitra/Sama average
      }
    }

    return (totalBala / 7.0) * 4.0; // Normalized Saptavargaja
  }

  // ── 2. திக்பலம் (Dig Bala: 0 - 60 Virupas) ──────────────────────────────────
  static Map<String, dynamic> _calculateDigBala(Map<String, double> planetLons, double lagnaLon) {
    Map<String, dynamic> result = {};

    // Maximum Power Points (Digbala Points)
    // 1st House (Lagna): Mercury, Jupiter
    // 4th House (IC = Lagna + 90°): Moon, Venus
    // 7th House (Desc = Lagna + 180°): Saturn
    // 10th House (MC = Lagna + 270°): Sun, Mars
    Map<String, double> maxDigPoints = {
      'Mercury': lagnaLon,
      'Jupiter': lagnaLon,
      'Moon': (lagnaLon + 90.0) % 360.0,
      'Venus': (lagnaLon + 90.0) % 360.0,
      'Saturn': (lagnaLon + 180.0) % 360.0,
      'Sun': (lagnaLon + 270.0) % 360.0,
      'Mars': (lagnaLon + 270.0) % 360.0,
    };

    for (var p in PLANETS) {
      double pLon = planetLons[p] ?? 0.0;
      double maxPoint = maxDigPoints[p] ?? lagnaLon;
      double zeroPoint = (maxPoint + 180.0) % 360.0;

      double distFromZero = (pLon - zeroPoint).abs();
      if (distFromZero > 180) distFromZero = 360 - distFromZero;

      double digBala = (distFromZero / 180.0) * 60.0;
      result[p] = {
        'total': digBala,
      };
    }

    return result;
  }

  // ── 3. கால பலம் (Kaala Bala) ──────────────────────────────────────────────
  static Map<String, dynamic> _calculateKaalaBala(
    Map<String, double> planetLons,
    DateTime birthDt,
    String sunriseStr,
    String sunsetStr,
  ) {
    Map<String, dynamic> result = {};
    bool isDay = _isDayBirth(birthDt, sunriseStr, sunsetStr);

    double sunLon = planetLons['Sun'] ?? 0.0;
    double moonLon = planetLons['Moon'] ?? 0.0;

    // 1. பக்ஷ பலம் (Paksha Bala: Angle between Sun and Moon)
    double moonSunAngle = (moonLon - sunLon + 360.0) % 360.0;
    double pakshaStrength = (moonSunAngle <= 180.0)
        ? (moonSunAngle / 180.0) * 60.0 // Shukla Paksha
        : ((360.0 - moonSunAngle) / 180.0) * 60.0; // Krishna Paksha

    for (var p in PLANETS) {
      // 1. நதோன்னத பலம் (Nathonnatha Bala: Day/Night)
      double nathoBala = 0.0;
      if (p == 'Mercury') {
        nathoBala = 60.0; // Always gets 60
      } else if (p == 'Sun' || p == 'Jupiter' || p == 'Venus') {
        nathoBala = isDay ? 60.0 : 0.0;
      } else {
        // Moon, Mars, Saturn
        nathoBala = isDay ? 0.0 : 60.0;
      }

      // 2. பக்ஷ பலம்
      double pBala = 0.0;
      if (p == 'Jupiter' || p == 'Venus' || (p == 'Moon' && moonSunAngle < 180)) {
        pBala = pakshaStrength;
      } else {
        pBala = 60.0 - pakshaStrength;
      }

      // 3. த்ரிபாக பலம் (Tribhaga Bala)
      double tribhagaBala = 30.0;

      // 4. அயன பலம் (Ayana Bala: Declination based)
      double ayanaBala = _calculateAyanaBala(planetLons[p] ?? 0.0, p);

      // 5. வர்ஷ-மாஸ-தின-ஹோரா பலம்
      double abdaMasaVaraBala = 45.0; // Standard nominal

      double totalKaala = nathoBala + pBala + tribhagaBala + ayanaBala + abdaMasaVaraBala;

      result[p] = {
        'total': totalKaala,
        'nathonnatha_bala': nathoBala,
        'paksha_bala': pBala,
        'tribhaga_bala': tribhagaBala,
        'ayana_bala': ayanaBala,
      };
    }

    return result;
  }

  static double _calculateAyanaBala(double lon, String planet) {
    // Declination based on Sayana/Nirayana angle
    double krantiAngle = math.sin((lon) * math.pi / 180.0) * 23.45;
    double norm = (krantiAngle + 23.45) / 46.90 * 60.0;
    if (planet == 'Sun' || planet == 'Mars' || planet == 'Jupiter' || planet == 'Venus') {
      return norm.clamp(0.0, 60.0);
    } else {
      return (60.0 - norm).clamp(0.0, 60.0);
    }
  }

  // ── 4. சேஷ்டா பலம் (Cheshta Bala) ──────────────────────────────────────────
  static Map<String, dynamic> _calculateCheshtaBala(
    Map<String, double> planetLons,
    Map<String, dynamic>? planetRetrograde,
    Map<String, dynamic> kaalaBala,
  ) {
    Map<String, dynamic> result = {};

    for (var p in PLANETS) {
      if (p == 'Sun' || p == 'Moon') {
        // For Sun and Moon, Cheshta Bala is their Ayana Bala
        double ayana = (kaalaBala[p]?['ayana_bala'] as num?)?.toDouble() ?? 30.0;
        result[p] = {'total': ayana};
      } else {
        bool isVakri = (planetRetrograde?[p] == true);
        double cBala = isVakri ? 60.0 : 30.0; // 60 when Retrograde, 30 normal
        result[p] = {'total': cBala};
      }
    }

    return result;
  }

  // ── 5. நைசர்கிக பலம் (Naisargika Bala) ────────────────────────────────────
  static Map<String, dynamic> _calculateNaisargikaBala() {
    Map<String, dynamic> result = {};
    for (var p in PLANETS) {
      result[p] = {
        'total': NAISARGIKA_BALA[p] ?? 10.0,
      };
    }
    return result;
  }

  // ── 6. த்ரிக் பலம் (Drik Bala - Aspect Strength) ──────────────────────────
  static Map<String, dynamic> _calculateDrikBala(Map<String, double> planetLons) {
    Map<String, dynamic> result = {};

    for (var p in PLANETS) {
      double pLon = planetLons[p] ?? 0.0;
      double netDrik = 0.0;

      for (var aspPlanet in PLANETS) {
        if (aspPlanet == p) continue;
        double aLon = planetLons[aspPlanet] ?? 0.0;
        double angle = (pLon - aLon + 360.0) % 360.0;

        // Aspect value based on angle
        double aspectVal = 0.0;
        if (angle >= 30 && angle <= 60) {
          aspectVal = ((angle - 30) / 30) * 15;
        } else if (angle > 60 && angle <= 90) {
          aspectVal = 15 + ((angle - 60) / 30) * 30;
        } else if (angle > 90 && angle <= 120) {
          aspectVal = 45 - ((angle - 90) / 30) * 15;
        } else if (angle > 120 && angle <= 150) {
          aspectVal = 30 - ((angle - 120) / 30) * 30;
        } else if (angle > 150 && angle <= 180) {
          aspectVal = ((angle - 150) / 30) * 60; // 7th aspect full
        }

        // Special Aspects for Mars (4, 8), Jupiter (5, 9), Saturn (3, 10)
        if (aspPlanet == 'Mars' && ((angle >= 90 && angle <= 120) || (angle >= 210 && angle <= 240))) {
          aspectVal = 45.0;
        }
        if (aspPlanet == 'Jupiter' && ((angle >= 120 && angle <= 150) || (angle >= 240 && angle <= 270))) {
          aspectVal = 30.0;
        }
        if (aspPlanet == 'Saturn' && ((angle >= 60 && angle <= 90) || (angle >= 270 && angle <= 300))) {
          aspectVal = 45.0;
        }

        bool isBenefic = (aspPlanet == 'Jupiter' || aspPlanet == 'Venus' || aspPlanet == 'Mercury');
        if (isBenefic) {
          netDrik += (aspectVal * 0.25);
        } else {
          netDrik -= (aspectVal * 0.25);
        }
      }

      result[p] = {
        'total': netDrik.clamp(-30.0, 30.0),
      };
    }

    return result;
  }

  static bool _isDayBirth(DateTime birthDt, String sunriseStr, String sunsetStr) {
    try {
      final sParts = sunriseStr.split(':');
      final eParts = sunsetStr.split(':');
      final sMinutes = int.parse(sParts[0]) * 60 + int.parse(sParts[1]);
      final eMinutes = int.parse(eParts[0]) * 60 + int.parse(eParts[1]);
      final bMinutes = birthDt.hour * 60 + birthDt.minute;
      return bMinutes >= sMinutes && bMinutes <= eMinutes;
    } catch (_) {
      return birthDt.hour >= 6 && birthDt.hour < 18;
    }
  }
}
