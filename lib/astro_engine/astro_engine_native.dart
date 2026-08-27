import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'astro_types.dart';
import 'astro_engine.dart' as engine;

typedef CalcJulianDayC = ffi.Double Function(ffi.Int32 year, ffi.Int32 month, ffi.Int32 day, ffi.Int32 hour, ffi.Int32 minute, ffi.Double second);
typedef CalcJulianDayDart = double Function(int year, int month, int day, int hour, int minute, double second);

typedef CalcPlanetC = ffi.Void Function(ffi.Double jd, ffi.Int32 planet_id, ffi.Pointer<ffi.Double> longitude, ffi.Pointer<ffi.Double> latitude, ffi.Pointer<ffi.Double> distance);
typedef CalcPlanetDart = void Function(double jd, int planet_id, ffi.Pointer<ffi.Double> longitude, ffi.Pointer<ffi.Double> latitude, ffi.Pointer<ffi.Double> distance);

typedef CalcAyanamsaC = ffi.Double Function(ffi.Double jd);
typedef CalcAyanamsaDart = double Function(double jd);

typedef CalcAscendantC = ffi.Double Function(ffi.Double jd, ffi.Double lat, ffi.Double lon);
typedef CalcAscendantDart = double Function(double jd, double lat, double lon);

typedef CalcHousesC = ffi.Void Function(ffi.Double jd, ffi.Double lat, ffi.Double lon, ffi.Pointer<ffi.Double> cusps);
typedef CalcHousesDart = void Function(double jd, double lat, double lon, ffi.Pointer<ffi.Double> cusps);

typedef CalcPhenomenaC = ffi.Void Function(ffi.Double jd, ffi.Double lat, ffi.Double lon, ffi.Int32 planet_id, ffi.Pointer<ffi.Double> rise_jd, ffi.Pointer<ffi.Double> set_jd, ffi.Pointer<ffi.Double> transit_jd);
typedef CalcPhenomenaDart = void Function(double jd, double lat, double lon, int planet_id, ffi.Pointer<ffi.Double> rise_jd, ffi.Pointer<ffi.Double> set_jd, ffi.Pointer<ffi.Double> transit_jd);

class AstroEngineImpl implements engine.AstroEngine {
  static Future<void> init() async {}

  late ffi.DynamicLibrary dylib;
  late CalcJulianDayDart calcJulianDay;
  late CalcPlanetDart calcPlanet;
  late CalcAyanamsaDart calcLahiriAyanamsa;
  late CalcAyanamsaDart calcKpOldAyanamsa;
  late CalcAyanamsaDart calcKpNewAyanamsa;
  late CalcAyanamsaDart calcKpStraightLineAyanamsa;
  late CalcAscendantDart calcAscendantDart;
  late CalcHousesDart calcHouses;
  late CalcPhenomenaDart calcPhenomenaNative;

  AstroEngineImpl() {
    if (Platform.isWindows) {
      String dylibPath = 'nithya.dll';
      if (!File(dylibPath).existsSync()) {
        dylibPath = '${Directory.current.path}/nithya.dll';
      }
      dylib = ffi.DynamicLibrary.open(dylibPath);
    } else if (Platform.isLinux || Platform.isAndroid) {
      dylib = ffi.DynamicLibrary.open('libnithya.so');
    } else if (Platform.isMacOS || Platform.isIOS) {
      dylib = ffi.DynamicLibrary.process();
    } else {
      throw UnsupportedError('Platform not supported');
    }

    calcJulianDay = dylib.lookup<ffi.NativeFunction<CalcJulianDayC>>('nithya_calc_julian_day').asFunction();
    calcPlanet = dylib.lookup<ffi.NativeFunction<CalcPlanetC>>('nithya_calc_planet').asFunction();
    calcLahiriAyanamsa = dylib.lookup<ffi.NativeFunction<CalcAyanamsaC>>('nithya_calc_lahiri_ayanamsa').asFunction();
    try {
      calcKpOldAyanamsa = dylib.lookup<ffi.NativeFunction<CalcAyanamsaC>>('nithya_calc_kp_old_ayanamsa').asFunction();
      calcKpNewAyanamsa = dylib.lookup<ffi.NativeFunction<CalcAyanamsaC>>('nithya_calc_kp_new_ayanamsa').asFunction();
      calcKpStraightLineAyanamsa = dylib.lookup<ffi.NativeFunction<CalcAyanamsaC>>('nithya_calc_kp_straight_line_ayanamsa').asFunction();
    } catch (e) {
      print("Warning: KP Ayanamsa functions not found in DLL, using Lahiri fallback");
      calcKpOldAyanamsa = calcLahiriAyanamsa;
      calcKpNewAyanamsa = calcLahiriAyanamsa;
      calcKpStraightLineAyanamsa = calcLahiriAyanamsa;
    }
    calcAscendantDart = dylib.lookup<ffi.NativeFunction<CalcAscendantC>>('nithya_calc_ascendant').asFunction();
    calcHouses = dylib.lookup<ffi.NativeFunction<CalcHousesC>>('nithya_calc_houses_placidus').asFunction();
    try {
      calcPhenomenaNative = dylib.lookup<ffi.NativeFunction<CalcPhenomenaC>>('nithya_calc_phenomena').asFunction();
    } catch (e) {
      print("Warning: nithya_calc_phenomena not found in DLL");
    }
  }

  double getAyanamsaValue(double jd, int mode) {
    switch (mode) {
      case 1:
        return calcLahiriAyanamsa(jd) - 1.44666666; // Raman
      case 2:
        return calcKpOldAyanamsa(jd); // KP Old
      case 3:
        return calcKpNewAyanamsa(jd); // KP New
      case 4:
        return calcKpStraightLineAyanamsa(jd); // KP Straight Line
      case 0:
      default:
        return calcLahiriAyanamsa(jd); // Lahiri
    }
  }

  @override
  AstroResult calculate(DateTime dateTime, double lat, double lon, {bool trueNode = true, HouseSystem houseSystem = HouseSystem.placidus, int ayanamsaMode = 0}) {
    DateTime utc = dateTime.toUtc();
    final jd = calcJulianDay(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second + utc.millisecond / 1000.0);
    
    final ayanamsa = getAyanamsaValue(jd, ayanamsaMode);
    
    final longitudePtr = calloc<ffi.Double>();
    final latitudePtr = calloc<ffi.Double>();
    final distancePtr = calloc<ffi.Double>();

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
      if (trueNode) {
        if (planetId == 7) planetId = 10; // NITHYA_TRUE_RAHU
        if (planetId == 8) planetId = 11; // NITHYA_TRUE_KETU
      }
      calcPlanet(jd, planetId, longitudePtr, latitudePtr, distancePtr);
      double trop = longitudePtr.value;
      
      // Calculate speed
      calcPlanet(jd - 0.005, planetId, longitudePtr, latitudePtr, distancePtr);
      double lon1 = longitudePtr.value;
      calcPlanet(jd + 0.005, planetId, longitudePtr, latitudePtr, distancePtr);
      double lon2 = longitudePtr.value;
      double diff = lon2 - lon1;
      if (diff > 180.0) diff -= 360.0;
      if (diff < -180.0) diff += 360.0;
      double speed = diff / 0.01;
      bool isRetrograde = speed < 0;

      double sid = normalize(trop - ayanamsa);
      
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

    double tropLagna = calcAscendantDart(jd, lat, lon);
    double sidLagna = normalize(tropLagna - ayanamsa);
    int lagnaRasi = (sidLagna / 30.0).floor();
    int lagnaNavamsa = (((sidLagna % 30.0) / 3.333333333).floor() + lagnaRasi * 9) % 12;

    List<double> houseCusps = [];
    if (houseSystem == HouseSystem.placidus) {
      final cuspsPtr = calloc<ffi.Double>(13);
      calcHouses(jd, lat, lon, cuspsPtr);
      for (int i = 1; i <= 12; i++) {
        houseCusps.add(normalize(cuspsPtr[i] - ayanamsa));
      }
      customFree(cuspsPtr);
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

    customFree(longitudePtr);
    customFree(latitudePtr);
    customFree(distancePtr);

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

  void customFree(ffi.Pointer ptr) {
    try {
      calloc.free(ptr);
    } catch (e) {
      // Ignored
    }
  }

  @override
  Future<Map<String, double>> calcPhenomena(double jd, double lat, double lon, int planetId) async {
    final risePtr = calloc<ffi.Double>();
    final setPtr = calloc<ffi.Double>();
    final transitPtr = calloc<ffi.Double>();

    calcPhenomenaNative(jd, lat, lon, planetId, risePtr, setPtr, transitPtr);

    double rise = risePtr.value;
    double set = setPtr.value;
    double transit = transitPtr.value;

    customFree(risePtr);
    customFree(setPtr);
    customFree(transitPtr);

    return {'rose': 0, 'rise': rise, 'set': set, 'transit': transit};
  }

  @override
  double calculatePlanetLongitude(DateTime dateTime, int planetId, {bool trueNode = true, int ayanamsaMode = 0}) {
    DateTime utc = dateTime.toUtc();
    final jd = calcJulianDay(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second + utc.millisecond / 1000.0);
    final ayanamsa = getAyanamsaValue(jd, ayanamsaMode);
    final longitudePtr = calloc<ffi.Double>();
    final latitudePtr = calloc<ffi.Double>();
    final distancePtr = calloc<ffi.Double>();

    int actualPlanetId = planetId;
    if (trueNode) {
      if (actualPlanetId == 7) actualPlanetId = 10;
      if (actualPlanetId == 8) actualPlanetId = 11;
    }

    calcPlanet(jd, actualPlanetId, longitudePtr, latitudePtr, distancePtr);
    double trop = longitudePtr.value;

    customFree(longitudePtr);
    customFree(latitudePtr);
    customFree(distancePtr);

    double sid = (trop - ayanamsa) % 360.0;
    if (sid < 0) sid += 360.0;
    return sid;
  }

  @override
  double calculateLagna(DateTime dateTime, double lat, double lon, {int ayanamsaMode = 0}) {
    DateTime utc = dateTime.toUtc();
    final jd = calcJulianDay(utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second + utc.millisecond / 1000.0);
    final ayanamsa = getAyanamsaValue(jd, ayanamsaMode);
    double tropLagna = calcAscendantDart(jd, lat, lon);
    double sidLagna = (tropLagna - ayanamsa) % 360.0;
    if (sidLagna < 0) sidLagna += 360.0;
    return sidLagna;
  }
}
