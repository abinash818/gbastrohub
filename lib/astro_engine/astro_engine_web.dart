import 'package:flutter/foundation.dart';
import 'astro_types.dart';
import 'astro_engine.dart' as engine;
import 'nithya_engine_web_pure.dart';

class AstroEngineImpl implements engine.AstroEngine {
  static bool _isInitialized = false;
  static late NithyaEngine _engine;

  AstroEngineImpl() {
    _engine = NithyaEngine.instance;
  }

  static Future<void> init() async {
    _isInitialized = true;
  }

  @override
  AstroResult calculate(DateTime dateTime, double lat, double lon, {bool trueNode = true, HouseSystem houseSystem = HouseSystem.placidus, int ayanamsaMode = 0}) {
    // Convert local time to UTC
    DateTime utc = dateTime.toUtc();
    double jd = _engine.julianDay(utc.year, utc.month, utc.day, utc.hour, utc.minute, second: utc.second + utc.millisecond / 1000.0);
    _engine.currentAyanamsaMode = ayanamsaMode;
    double ayanamsa = _engine.getAyanamsa(jd);

    final planetDefs = [
      {'id': 0, 'name': 'Su'},
      {'id': 1, 'name': 'Mo'},
      {'id': 2, 'name': 'Ma'},
      {'id': 3, 'name': 'Me'},
      {'id': 4, 'name': 'Ju'},
      {'id': 5, 'name': 'Ve'},
      {'id': 6, 'name': 'Sa'},
      {'id': 7, 'name': 'Ra'},
      {'id': 8, 'name': 'Ke'}
    ];

    List<PlanetPosition> positions = [];
    
    double normalize(double deg) {
      double res = deg % 360.0;
      if (res < 0) res += 360.0;
      return res;
    }

    for (var p in planetDefs) {
      int planetId = p['id'] as int;
      double sid = _engine.planetLongitude(jd, planetId, sidereal: true);
      double trop = _engine.planetLongitude(jd, planetId, sidereal: false);
      
      // Calculate speed
      double lon1 = _engine.planetLongitude(jd - 0.005, planetId, sidereal: false);
      double lon2 = _engine.planetLongitude(jd + 0.005, planetId, sidereal: false);
      double diff = lon2 - lon1;
      if (diff > 180.0) diff -= 360.0;
      if (diff < -180.0) diff += 360.0;
      double speed = diff / 0.01;
      bool isRetrograde = speed < 0;

      int rasi = (sid / 30.0).floor();
      int navamsa = (((sid % 30.0) / 3.333333333).floor() + rasi * 9) % 12;

      positions.add(PlanetPosition(
        id: p['id'] as int,
        name: p['name'] as String,
        tropicalDegree: trop,
        siderealDegree: sid,
        rasiIndex: rasi,
        navamsaIndex: navamsa,
        speed: speed,
        isRetrograde: isRetrograde,
      ));
    }

    double tropLagna = _engine.ascendant(jd, lat, lon, sidereal: false);
    double sidLagna = _engine.ascendant(jd, lat, lon, sidereal: true);
    int lagnaRasi = (sidLagna / 30.0).floor();
    int lagnaNavamsa = (((sidLagna % 30.0) / 3.333333333).floor() + lagnaRasi * 9) % 12;

    List<double> houseCusps = [];
    if (houseSystem == HouseSystem.placidus) {
      List<double> rawCusps = _engine.houseCusps(jd, lat, lon);
      for (int i = 1; i <= 12; i++) {
        houseCusps.add(rawCusps[i]);
      }
    } else if (houseSystem == HouseSystem.equal) {
      for (int i = 0; i < 12; i++) {
        houseCusps.add(normalize(sidLagna + i * 30.0));
      }
    } else if (houseSystem == HouseSystem.wholeSign) {
      double firstHouse = (sidLagna / 30.0).floor() * 30.0;
      for (int i = 0; i < 12; i++) {
        houseCusps.add(normalize(firstHouse + i * 30.0));
      }
    }

    return AstroResult(
      jd: jd,
      ayanamsa: ayanamsa,
      lagnaSidereal: sidLagna,
      lagnaRasiIndex: lagnaRasi,
      lagnaNavamsaIndex: lagnaNavamsa,
      planets: positions,
      houseCuspsSidereal: houseCusps,
    );
  }

  @override
  Future<Map<String, double>> calcPhenomena(double jd, double lat, double lon, int planetId) async {
    Map<String, double> res = _engine.phenomena(jd, lat, lon, planetId);
    return res;
  }

  @override
  double calculatePlanetLongitude(DateTime dateTime, int planetId, {bool trueNode = true, int ayanamsaMode = 0}) {
    DateTime utc = dateTime.toUtc();
    double jd = _engine.julianDay(utc.year, utc.month, utc.day, utc.hour, utc.minute, second: utc.second + utc.millisecond / 1000.0);
    _engine.currentAyanamsaMode = ayanamsaMode;
    
    int actualPlanetId = planetId;
    if (trueNode) {
      if (actualPlanetId == 7) actualPlanetId = NithyaPlanet.rahu;
      if (actualPlanetId == 8) actualPlanetId = NithyaPlanet.ketu;
    }
    
    return _engine.planetLongitude(jd, actualPlanetId, sidereal: true);
  }

  @override
  double calculateLagna(DateTime dateTime, double lat, double lon, {int ayanamsaMode = 0}) {
    DateTime utc = dateTime.toUtc();
    double jd = _engine.julianDay(utc.year, utc.month, utc.day, utc.hour, utc.minute, second: utc.second + utc.millisecond / 1000.0);
    _engine.currentAyanamsaMode = ayanamsaMode;
    return _engine.ascendant(jd, lat, lon, sidereal: true);
  }
}
