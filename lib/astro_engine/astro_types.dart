enum HouseSystem {
  placidus,
  equal,
  wholeSign,
}

class PlanetPosition {
  final int id;
  final String name;
  final double tropicalDegree;
  final double siderealDegree;
  final int rasiIndex;
  final int navamsaIndex;
  final double speed;
  final bool isRetrograde;

  PlanetPosition({
    required this.id,
    required this.name,
    required this.tropicalDegree,
    required this.siderealDegree,
    required this.rasiIndex,
    required this.navamsaIndex,
    required this.speed,
    required this.isRetrograde,
  });
}

class AstroResult {
  final double jd;
  final double ayanamsa;
  final double lagnaSidereal;
  final int lagnaRasiIndex;
  final int lagnaNavamsaIndex;
  final List<PlanetPosition> planets;
  final List<double> houseCuspsSidereal;

  AstroResult({
    required this.jd,
    required this.ayanamsa,
    required this.lagnaSidereal,
    required this.lagnaRasiIndex,
    required this.lagnaNavamsaIndex,
    required this.planets,
    required this.houseCuspsSidereal,
  });
}
