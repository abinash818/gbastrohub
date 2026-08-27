import 'astro_types.dart';
export 'astro_types.dart';

import 'astro_engine_stub.dart'
  if (dart.library.ffi) 'astro_engine_native.dart'
  if (dart.library.js_interop) 'astro_engine_web.dart' as impl;

abstract class AstroEngine {
  factory AstroEngine() => impl.AstroEngineImpl();
  
  static Future<void> init() => impl.AstroEngineImpl.init();
  
  AstroResult calculate(DateTime dateTime, double lat, double lon, {bool trueNode = true, HouseSystem houseSystem = HouseSystem.placidus, int ayanamsaMode = 0});
  
  /// Calculate Rise, Set, and Transit for Sun or Moon
  /// Returns a map with keys: 'rise', 'set', 'transit' containing Julian Days.
  Future<Map<String, double>> calcPhenomena(double jd, double lat, double lon, int planetId);

  /// Calculate only the sidereal longitude of a specific planet
  double calculatePlanetLongitude(DateTime dateTime, int planetId, {bool trueNode = true, int ayanamsaMode = 0});

  /// Calculate only the sidereal lagna
  double calculateLagna(DateTime dateTime, double lat, double lon, {int ayanamsaMode = 0});
}
