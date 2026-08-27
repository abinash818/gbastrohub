import 'astro_types.dart';
import 'astro_engine.dart';

class AstroEngineImpl implements AstroEngine {
  static Future<void> init() async {}

  @override
  AstroResult calculate(DateTime dateTime, double lat, double lon, {bool trueNode = true, HouseSystem houseSystem = HouseSystem.placidus}) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<Map<String, double>> calcPhenomena(double jd, double lat, double lon, int planetId) async {
    throw UnsupportedError('Platform not supported');
  }

  @override
  double calculatePlanetLongitude(DateTime dateTime, int planetId, {bool trueNode = true}) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  double calculateLagna(DateTime dateTime, double lat, double lon) {
    throw UnsupportedError('Platform not supported');
  }
}
