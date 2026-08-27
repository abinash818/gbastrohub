// lib/services/nithya_engine_web.dart
// Web fallback: Pure Dart astronomical calculations
// Uses Jean Meeus "Astronomical Algorithms" and VSOP87 formulas
// This mirrors the output of nithya.dll for browser environments.

import 'dart:math' as math;
import 'package:flutter/foundation.dart' show debugPrint;
import 'vsop87_data.dart' as data;

class NithyaPlanet {
  static const int sun = 0;
  static const int moon = 1;
  static const int mars = 2;
  static const int mercury = 3;
  static const int jupiter = 4;
  static const int venus = 5;
  static const int saturn = 6;
  static const int rahu = 7;
  static const int ketu = 8;
}

class NithyaEngine {
  static NithyaEngine? _instance;
  bool _isLoaded = false;

  int currentAyanamsaMode = 0;

  NithyaEngine._internal();

  static NithyaEngine get instance {
    _instance ??= NithyaEngine._internal();
    return _instance!;
  }

  void load() {
    if (_isLoaded) return;
    _isLoaded = true;
    debugPrint('✅ Nithya Engine loaded (Web Pure Dart)');
  }

  // ─── Julian Day ─────────────────────────────────────────────────────────

  double julianDay(int year, int month, int day, int hour, int minute,
      {double second = 0.0}) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    int a = (year / 100).floor();
    int b = 2 - a + (a / 4).floor();
    double dayFraction = day + (hour + minute / 60.0 + second / 3600.0) / 24.0;
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        dayFraction +
        b -
        1524.5;
  }

  // ─── Lahiri Ayanamsa ────────────────────────────────────────────────────

  double lahiriAyanamsa(double jd) {
    // Chitra Paksha (Lahiri) Ayanamsa formula matching C code exactly
    double t = (jd - 2451545.0) / 36525.0; // Centuries from J2000
    double ayanamsa = 23.856472222222 + (1.396041666666 * t) + (0.000308333333 * t * t);
    return ayanamsa;
  }

  /// Calculate Ayanamsa based on the selected mode
  /// 0: Lahiri, 1: Raman, 2: KP Old, 3: KP New, 4: KP Straight Line
  double getAyanamsa(double jd) {
    double lahiri = lahiriAyanamsa(jd);
    switch (currentAyanamsaMode) {
      case 1: 
        return lahiri - 1.44666666; // Raman
      case 2: {
        double t = (jd - 2415020.5) / 365.242199;
        return 22.366666666667 + (t * 50.2388475 + t * t * 0.000111) / 3600.0; // KP Old
      }
      case 3: {
        double t = (jd - 2415124.5) / 365.242199;
        return 22.375 + (t * 50.2388475 + t * t * 0.000111) / 3600.0; // KP New
      }
      case 4: {
        double t = (jd - 1827449.5) / 365.25;
        return (t * 50.2388475) / 3600.0; // KP Straight Line
      }
      case 0:
      default: 
        return lahiri;
    }
  }

  // ─── Planet Longitudes ──────────────────────────────────────────────────

  double planetLongitude(double jd, int planetId, {bool sidereal = true}) {
    double tropical = _calcTropicalLongitude(jd, planetId);
    if (sidereal) {
      double ayanamsa = getAyanamsa(jd);
      double sid = tropical - ayanamsa;
      while (sid < 0) sid += 360.0;
      while (sid >= 360) sid -= 360.0;
      return sid;
    }
    return tropical;
  }

  double _calcTropicalLongitude(double jd, int planetId) {
    double tau = (jd - 2451545.0) / 365250.0;

    // Calculate Earth's heliocentric position (used for geocentric conversion)
    double earthL = _sumVsopSeries(data.earth_var1_t0, tau) +
        _sumVsopSeries(data.earth_var1_t1, tau) * tau +
        _sumVsopSeries(data.earth_var1_t2, tau) * math.pow(tau, 2) +
        _sumVsopSeries(data.earth_var1_t3, tau) * math.pow(tau, 3) +
        _sumVsopSeries(data.earth_var1_t4, tau) * math.pow(tau, 4) +
        _sumVsopSeries(data.earth_var1_t5, tau) * math.pow(tau, 5);

    double earthB = _sumVsopSeries(data.earth_var2_t0, tau) +
        _sumVsopSeries(data.earth_var2_t1, tau) * tau +
        _sumVsopSeries(data.earth_var2_t2, tau) * math.pow(tau, 2) +
        _sumVsopSeries(data.earth_var2_t3, tau) * math.pow(tau, 3) +
        _sumVsopSeries(data.earth_var2_t4, tau) * math.pow(tau, 4);

    double earthR = _sumVsopSeries(data.earth_var3_t0, tau) +
        _sumVsopSeries(data.earth_var3_t1, tau) * tau +
        _sumVsopSeries(data.earth_var3_t2, tau) * math.pow(tau, 2) +
        _sumVsopSeries(data.earth_var3_t3, tau) * math.pow(tau, 3) +
        _sumVsopSeries(data.earth_var3_t4, tau) * math.pow(tau, 4) +
        _sumVsopSeries(data.earth_var3_t5, tau) * math.pow(tau, 5);

    if (planetId == NithyaPlanet.sun) {
      return _normalize(_rad2deg(earthL) + 180.0);
    }

    if (planetId == NithyaPlanet.moon) {
      return _moonLongitude(jd);
    }

    if (planetId == NithyaPlanet.rahu) {
      return _rahuLongitude(jd);
    }

    if (planetId == NithyaPlanet.ketu) {
      return (_rahuLongitude(jd) + 180.0) % 360.0;
    }

    List<double> pVar1T0, pVar1T1, pVar1T2, pVar1T3, pVar1T4, pVar1T5;
    List<double> pVar2T0, pVar2T1, pVar2T2, pVar2T3, pVar2T4, pVar2T5;
    List<double> pVar3T0, pVar3T1, pVar3T2, pVar3T3, pVar3T4, pVar3T5;

    switch (planetId) {
      case NithyaPlanet.mercury:
        pVar1T0 = data.mercury_var1_t0; pVar1T1 = data.mercury_var1_t1; pVar1T2 = data.mercury_var1_t2; pVar1T3 = data.mercury_var1_t3; pVar1T4 = data.mercury_var1_t4; pVar1T5 = data.mercury_var1_t5;
        pVar2T0 = data.mercury_var2_t0; pVar2T1 = data.mercury_var2_t1; pVar2T2 = data.mercury_var2_t2; pVar2T3 = data.mercury_var2_t3; pVar2T4 = data.mercury_var2_t4; pVar2T5 = data.mercury_var2_t5;
        pVar3T0 = data.mercury_var3_t0; pVar3T1 = data.mercury_var3_t1; pVar3T2 = data.mercury_var3_t2; pVar3T3 = data.mercury_var3_t3; pVar3T4 = data.mercury_var3_t4; pVar3T5 = data.mercury_var3_t5;
        break;
      case NithyaPlanet.venus:
        pVar1T0 = data.venus_var1_t0; pVar1T1 = data.venus_var1_t1; pVar1T2 = data.venus_var1_t2; pVar1T3 = data.venus_var1_t3; pVar1T4 = data.venus_var1_t4; pVar1T5 = data.venus_var1_t5;
        pVar2T0 = data.venus_var2_t0; pVar2T1 = data.venus_var2_t1; pVar2T2 = data.venus_var2_t2; pVar2T3 = data.venus_var2_t3; pVar2T4 = data.venus_var2_t4; pVar2T5 = data.venus_var2_t5;
        pVar3T0 = data.venus_var3_t0; pVar3T1 = data.venus_var3_t1; pVar3T2 = data.venus_var3_t2; pVar3T3 = data.venus_var3_t3; pVar3T4 = data.venus_var3_t4; pVar3T5 = data.venus_var3_t5;
        break;
      case NithyaPlanet.mars:
        pVar1T0 = data.mars_var1_t0; pVar1T1 = data.mars_var1_t1; pVar1T2 = data.mars_var1_t2; pVar1T3 = data.mars_var1_t3; pVar1T4 = data.mars_var1_t4; pVar1T5 = data.mars_var1_t5;
        pVar2T0 = data.mars_var2_t0; pVar2T1 = data.mars_var2_t1; pVar2T2 = data.mars_var2_t2; pVar2T3 = data.mars_var2_t3; pVar2T4 = data.mars_var2_t4; pVar2T5 = data.mars_var2_t5;
        pVar3T0 = data.mars_var3_t0; pVar3T1 = data.mars_var3_t1; pVar3T2 = data.mars_var3_t2; pVar3T3 = data.mars_var3_t3; pVar3T4 = data.mars_var3_t4; pVar3T5 = data.mars_var3_t5;
        break;
      case NithyaPlanet.jupiter:
        pVar1T0 = data.jupiter_var1_t0; pVar1T1 = data.jupiter_var1_t1; pVar1T2 = data.jupiter_var1_t2; pVar1T3 = data.jupiter_var1_t3; pVar1T4 = data.jupiter_var1_t4; pVar1T5 = data.jupiter_var1_t5;
        pVar2T0 = data.jupiter_var2_t0; pVar2T1 = data.jupiter_var2_t1; pVar2T2 = data.jupiter_var2_t2; pVar2T3 = data.jupiter_var2_t3; pVar2T4 = data.jupiter_var2_t4; pVar2T5 = data.jupiter_var2_t5;
        pVar3T0 = data.jupiter_var3_t0; pVar3T1 = data.jupiter_var3_t1; pVar3T2 = data.jupiter_var3_t2; pVar3T3 = data.jupiter_var3_t3; pVar3T4 = data.jupiter_var3_t4; pVar3T5 = data.jupiter_var3_t5;
        break;
      case NithyaPlanet.saturn:
        pVar1T0 = data.saturn_var1_t0; pVar1T1 = data.saturn_var1_t1; pVar1T2 = data.saturn_var1_t2; pVar1T3 = data.saturn_var1_t3; pVar1T4 = data.saturn_var1_t4; pVar1T5 = data.saturn_var1_t5;
        pVar2T0 = data.saturn_var2_t0; pVar2T1 = data.saturn_var2_t1; pVar2T2 = data.saturn_var2_t2; pVar2T3 = data.saturn_var2_t3; pVar2T4 = data.saturn_var2_t4; pVar2T5 = data.saturn_var2_t5;
        pVar3T0 = data.saturn_var3_t0; pVar3T1 = data.saturn_var3_t1; pVar3T2 = data.saturn_var3_t2; pVar3T3 = data.saturn_var3_t3; pVar3T4 = data.saturn_var3_t4; pVar3T5 = data.saturn_var3_t5;
        break;
      default:
        return 0.0;
    }

    double pL = _sumVsopSeries(pVar1T0, tau) +
        _sumVsopSeries(pVar1T1, tau) * tau +
        _sumVsopSeries(pVar1T2, tau) * math.pow(tau, 2) +
        _sumVsopSeries(pVar1T3, tau) * math.pow(tau, 3) +
        _sumVsopSeries(pVar1T4, tau) * math.pow(tau, 4) +
        _sumVsopSeries(pVar1T5, tau) * math.pow(tau, 5);

    double pB = _sumVsopSeries(pVar2T0, tau) +
        _sumVsopSeries(pVar2T1, tau) * tau +
        _sumVsopSeries(pVar2T2, tau) * math.pow(tau, 2) +
        _sumVsopSeries(pVar2T3, tau) * math.pow(tau, 3) +
        _sumVsopSeries(pVar2T4, tau) * math.pow(tau, 4) +
        _sumVsopSeries(pVar2T5, tau) * math.pow(tau, 5);

    double pR = _sumVsopSeries(pVar3T0, tau) +
        _sumVsopSeries(pVar3T1, tau) * tau +
        _sumVsopSeries(pVar3T2, tau) * math.pow(tau, 2) +
        _sumVsopSeries(pVar3T3, tau) * math.pow(tau, 3) +
        _sumVsopSeries(pVar3T4, tau) * math.pow(tau, 4) +
        _sumVsopSeries(pVar3T5, tau) * math.pow(tau, 5);

    return _helioToGeo3D(earthL, earthB, earthR, pL, pB, pR);
  }

  double _sumVsopSeries(List<double> terms, double tau) {
    double sum = 0.0;
    for (int i = 0; i < terms.length; i += 3) {
      double a = terms[i];
      double b = terms[i+1];
      double c = terms[i+2];
      sum += a * math.cos(b + c * tau);
    }
    return sum;
  }

  // 3D Heliocentric to Geocentric conversion
  double _helioToGeo3D(double l0, double b0, double r0, double lp, double bp, double rp) {
    double x0 = r0 * math.cos(b0) * math.cos(l0);
    double y0 = r0 * math.cos(b0) * math.sin(l0);
    double z0 = r0 * math.sin(b0);

    double xp = rp * math.cos(bp) * math.cos(lp);
    double yp = rp * math.cos(bp) * math.sin(lp);
    double zp = rp * math.sin(bp);

    double x = xp - x0;
    double y = yp - y0;

    return _normalize(_rad2deg(math.atan2(y, x)));
  }

  double _deg2rad(double deg) => deg * math.pi / 180.0;
  double _rad2deg(double rad) => rad * 180.0 / math.pi;
  double _normalize(double deg) {
    deg = deg % 360.0;
    if (deg < 0) deg += 360.0;
    return deg;
  }

  double _moonLongitude(double jd) {
    double T = (jd - 2451545.0) / 36525.0;

    double L_prime = 218.3164477 + 481267.88123421 * T;
    double D = 297.8501921 + 445267.1114034 * T;
    double M = 357.5291092 + 35999.0502909 * T;
    double M_prime = 134.9633964 + 477198.8675055 * T;
    double F = 93.2720950 + 483202.0175233 * T;

    double sum_L = 0.0;
    sum_L += 6288774.0 * math.sin(_deg2rad(M_prime));
    sum_L += 1274027.0 * math.sin(_deg2rad(2 * D - M_prime));
    sum_L += 658314.0 * math.sin(_deg2rad(2 * D));
    sum_L += 213618.0 * math.sin(_deg2rad(2 * M_prime));
    sum_L += -185116.0 * math.sin(_deg2rad(M));
    sum_L += -114332.0 * math.sin(_deg2rad(2 * F));
    sum_L += 58793.0 * math.sin(_deg2rad(2 * D - 2 * M_prime));
    sum_L += 57066.0 * math.sin(_deg2rad(2 * D - M - M_prime));
    sum_L += 53322.0 * math.sin(_deg2rad(2 * D + M_prime));
    sum_L += 45758.0 * math.sin(_deg2rad(2 * D - M));
    sum_L += -40923.0 * math.sin(_deg2rad(M - M_prime));
    sum_L += -34720.0 * math.sin(_deg2rad(D));
    sum_L += -30383.0 * math.sin(_deg2rad(M + M_prime));
    sum_L += 15327.0 * math.sin(_deg2rad(2 * D - 2 * F));
    sum_L += -12528.0 * math.sin(_deg2rad(M_prime + 2 * F));
    sum_L += 10980.0 * math.sin(_deg2rad(M_prime - 2 * F));
    sum_L += 10675.0 * math.sin(_deg2rad(4 * D - M_prime));
    sum_L += 10034.0 * math.sin(_deg2rad(3 * M_prime));
    sum_L += 8548.0 * math.sin(_deg2rad(4 * D - 2 * M_prime));
    sum_L += -7888.0 * math.sin(_deg2rad(2 * D + M - M_prime));
    sum_L += -6766.0 * math.sin(_deg2rad(2 * D + M));
    sum_L += -5163.0 * math.sin(_deg2rad(D - M_prime));
    sum_L += 4987.0 * math.sin(_deg2rad(D + M));
    sum_L += 4036.0 * math.sin(_deg2rad(2 * D - M + M_prime));
    sum_L += 3994.0 * math.sin(_deg2rad(2 * D + 2 * M_prime));
    sum_L += 3861.0 * math.sin(_deg2rad(4 * D));
    sum_L += 3665.0 * math.sin(_deg2rad(2 * D - 3 * M_prime));
    sum_L += -2689.0 * math.sin(_deg2rad(M - 2 * M_prime));
    sum_L += -2602.0 * math.sin(_deg2rad(2 * D - M_prime + 2 * F));
    sum_L += 2390.0 * math.sin(_deg2rad(2 * D - M - 2 * M_prime));
    sum_L += -2348.0 * math.sin(_deg2rad(D + M_prime));
    sum_L += 2236.0 * math.sin(_deg2rad(2 * D - 2 * M));
    sum_L += -2120.0 * math.sin(_deg2rad(M + 2 * M_prime));
    sum_L += -2069.0 * math.sin(_deg2rad(2 * M));
    sum_L += 2048.0 * math.sin(_deg2rad(2 * D - 2 * M - M_prime));
    sum_L += -1773.0 * math.sin(_deg2rad(2 * D + M_prime - 2 * F));
    sum_L += -1595.0 * math.sin(_deg2rad(2 * D + 2 * F));
    sum_L += 1215.0 * math.sin(_deg2rad(4 * D - M - M_prime));
    sum_L += -1110.0 * math.sin(_deg2rad(2 * M_prime + 2 * F));
    sum_L += -892.0 * math.sin(_deg2rad(3 * D - M_prime));
    sum_L += -810.0 * math.sin(_deg2rad(2 * D + M + M_prime));
    sum_L += 759.0 * math.sin(_deg2rad(4 * D - M - 2 * M_prime));
    sum_L += -713.0 * math.sin(_deg2rad(2 * M - M_prime));
    sum_L += -700.0 * math.sin(_deg2rad(2 * D + 2 * M - M_prime));
    sum_L += 691.0 * math.sin(_deg2rad(2 * D + M - 2 * M_prime));
    sum_L += 596.0 * math.sin(_deg2rad(2 * D - M - 2 * F));
    sum_L += 549.0 * math.sin(_deg2rad(4 * D + M_prime));
    sum_L += 537.0 * math.sin(_deg2rad(4 * M_prime));
    sum_L += 520.0 * math.sin(_deg2rad(4 * D - M));
    sum_L += -487.0 * math.sin(_deg2rad(D - 2 * M_prime));
    sum_L += -399.0 * math.sin(_deg2rad(2 * D + M - 2 * F));
    sum_L += -381.0 * math.sin(_deg2rad(2 * M_prime - 2 * F));
    sum_L += 351.0 * math.sin(_deg2rad(D + M + M_prime));
    sum_L += -340.0 * math.sin(_deg2rad(3 * D - 2 * M_prime));
    sum_L += 330.0 * math.sin(_deg2rad(4 * D - 3 * M_prime));
    sum_L += 327.0 * math.sin(_deg2rad(2 * D - M + 2 * M_prime));
    sum_L += -323.0 * math.sin(_deg2rad(2 * M + M_prime));
    sum_L += 299.0 * math.sin(_deg2rad(D + M - M_prime));
    sum_L += 294.0 * math.sin(_deg2rad(2 * D + 3 * M_prime));

    double moonLon = L_prime + (sum_L / 1000000.0);
    return _normalize(moonLon);
  }

  double _rahuLongitude(double jd) {
    double T = (jd - 2451545.0) / 36525.0;
    // Mean node calculation matching C source code
    double omega = 125.04452 - 1934.136261 * T + 0.0020708 * T * T + (T * T * T / 450000.0);
    return _normalize(omega);
  }

  // ─── Ascendant (Lagna) ──────────────────────────────────────────────────

  double ascendant(double jd, double lat, double lon, {bool sidereal = true}) {
    double t = (jd - 2451545.0) / 36525.0;
    // Greenwich Mean Sidereal Time
    double gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t - t * t * t / 38710000.0;
    gmst = _normalize(gmst);
    // Local Sidereal Time
    double lst = _normalize(gmst + lon);
    // Obliquity of ecliptic
    double eps = 23.439291111 - 0.013004167 * t;
    eps = _deg2rad(eps);
    double lstRad = _deg2rad(lst);
    double latRad = _deg2rad(lat);

    double x = -math.cos(lstRad);
    double y = math.sin(lstRad) * math.cos(eps) +
        math.tan(latRad) * math.sin(eps);
    double asc = _rad2deg(math.atan2(x, y));
    // Adjust to correct quadrant
    if (math.cos(lstRad) < 0) {
      asc += 180.0;
    } else {
      asc += 360.0;
    }
    asc = _normalize(asc);

    if (sidereal) {
      double ayanamsa = getAyanamsa(jd);
      asc = _normalize(asc - ayanamsa);
    }
    return asc;
  }

  // ─── House Cusps (Placidus complex) ───────────────────────────────────────

  List<double> houseCusps(double jd, double lat, double lon) {
    // Placidus House Cusps matching native nithya_math.c nithya_calc_houses_placidus
    double t = (jd - 2451545.0) / 36525.0;
    double gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t;
    double lst = _normalize(gmst + lon);
    double eps = 23.43929111 - 0.013004167 * t;

    double lstRad = _deg2rad(lst);
    double epsRad = _deg2rad(eps);
    double latRad = _deg2rad(lat);

    List<double> cusps = List.filled(13, 0.0);

    // House 1 (Ascendant)
    double y1 = math.cos(lstRad);
    double x1 = -math.sin(lstRad) * math.cos(epsRad) - math.tan(latRad) * math.sin(epsRad);
    cusps[1] = _normalize(_rad2deg(math.atan2(y1, x1)));

    // House 10 (Midheaven)
    double y10 = math.sin(lstRad);
    double x10 = math.cos(lstRad) * math.cos(epsRad);
    cusps[10] = _normalize(_rad2deg(math.atan2(y10, x10)));

    // Placidus Iterative Cusps
    cusps[11] = _placidusIterate(_normalize(lst + 30.0), latRad, epsRad, 1.0 / 3.0);
    cusps[12] = _placidusIterate(_normalize(lst + 60.0), latRad, epsRad, 2.0 / 3.0);
    cusps[2] = _placidusIterate(_normalize(lst + 120.0), latRad, epsRad, 2.0 / 3.0);
    cusps[3] = _placidusIterate(_normalize(lst + 150.0), latRad, epsRad, 1.0 / 3.0);

    // Opposites
    cusps[4] = _normalize(cusps[10] + 180.0);
    cusps[5] = _normalize(cusps[11] + 180.0);
    cusps[6] = _normalize(cusps[12] + 180.0);
    cusps[7] = _normalize(cusps[1] + 180.0);
    cusps[8] = _normalize(cusps[2] + 180.0);
    cusps[9] = _normalize(cusps[3] + 180.0);

    // Apply sidereal ayanamsa to all house cusps
    double ayanamsa = getAyanamsa(jd);
    for (int i = 1; i <= 12; i++) {
      cusps[i] = _normalize(cusps[i] - ayanamsa);
    }

    return cusps;
  }

  double _placidusIterate(double ramc, double latRad, double epsRad, double factor) {
    double ra = ramc;
    double d, a, raNew, lNew;
    double l = ra;
    for (int i = 0; i < 10; i++) {
      double lRad = _deg2rad(l);
      d = math.asin(math.sin(epsRad) * math.sin(lRad));
      a = math.asin(math.tan(latRad) * math.tan(d));
      raNew = ramc + factor * _rad2deg(a);
      double y = math.sin(_deg2rad(raNew));
      double x = math.cos(_deg2rad(raNew)) * math.cos(epsRad);
      lNew = _rad2deg(math.atan2(y, x));
      if ((lNew - l).abs() < 0.0001) break;
      l = lNew;
    }
    return _normalize(l);
  }

  // ─── Phenomena (Sunrise / Sunset) ───────────────────────────────────────

  Map<String, double> phenomena(double jd, double lat, double lon, int planetId) {
    double h0 = -0.8333; // Default for Sun
    if (planetId == NithyaPlanet.moon) {
      h0 = 0.125; // Default for Moon
    }

    double jdMid = (jd - 0.5).floorToDouble() + 0.5; // JD at noon UTC
    double pLon = _calcTropicalLongitude(jdMid, planetId);
    double pLat = 0.0;
    
    if (planetId == NithyaPlanet.sun) {
      double tau = (jdMid - 2451545.0) / 365250.0;
      double earthB = _sumVsopSeries(data.earth_var2_t0, tau) +
          _sumVsopSeries(data.earth_var2_t1, tau) * tau +
          _sumVsopSeries(data.earth_var2_t2, tau) * math.pow(tau, 2) +
          _sumVsopSeries(data.earth_var2_t3, tau) * math.pow(tau, 3) +
          _sumVsopSeries(data.earth_var2_t4, tau) * math.pow(tau, 4);
      pLat = -_rad2deg(earthB);
    }

    double T = (jdMid - 2451545.0) / 36525.0;
    double epsilon = 23.43929111 - 0.013004167 * T;

    double epsRad = _deg2rad(epsilon);
    double lonRad = _deg2rad(pLon);
    double latRad = _deg2rad(pLat);

    // Ecliptic to Equatorial
    double y = math.sin(lonRad) * math.cos(epsRad) - math.tan(latRad) * math.sin(epsRad);
    double x = math.cos(lonRad);
    double ra = _normalize(_rad2deg(math.atan2(y, x)));

    double sinDec = math.sin(latRad) * math.cos(epsRad) + math.cos(latRad) * math.sin(epsRad) * math.sin(lonRad);
    double dec = _rad2deg(math.asin(sinDec));

    // Hour Angle H
    double decRad = _deg2rad(dec);
    double geoLatRad = _deg2rad(lat);
    double h0Rad = _deg2rad(h0);

    double cosH = (math.sin(h0Rad) - math.sin(geoLatRad) * math.sin(decRad)) / (math.cos(geoLatRad) * math.cos(decRad));

    if (cosH < -1.0 || cosH > 1.0) {
      return {'rise': 0.0, 'set': 0.0, 'transit': 0.0};
    }

    double H = _rad2deg(math.acos(cosH));

    // GMST at 0 UT
    double jd0 = (jd - 0.5).floorToDouble() + 0.5;
    double T0 = (jd0 - 2451545.0) / 36525.0;
    double gmst0 = 280.46061837 + 360.98564736629 * (jd0 - 2451545.0) + 0.000387933 * T0 * T0;
    gmst0 = _normalize(gmst0);

    double mTransit = (ra - lon - gmst0) / 360.0;
    mTransit = mTransit - mTransit.floorToDouble();

    double mRise = mTransit - (H / 360.0);
    if (mRise < 0) mRise += 1.0;

    double mSet = mTransit + (H / 360.0);
    if (mSet > 1.0) mSet -= 1.0;

    return {
      'transit': jd0 + mTransit,
      'rise': jd0 + mRise,
      'set': jd0 + mSet,
    };
  }
}
