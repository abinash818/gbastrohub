import 'package:country_state_city/country_state_city.dart' as csc;

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  List<csc.Country> _countries = [];
  final Map<String, List<csc.State>> _statesCache = {};
  final Map<String, List<csc.City>> _citiesCache = {};
  
  bool _isInitialized = false;

  List<csc.Country> get countries => _countries;
  bool get isInitialized => _isInitialized;

  /// Starts loading countries and pre-loads Indian states for speed.
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // 1. Try Load All Countries
      final allCountries = await csc.getAllCountries();
      
      // Sort: India first, then alphabetically
      int indiaIdx = allCountries.indexWhere((c) => c.isoCode == 'IN');
      if (indiaIdx != -1) {
        final india = allCountries.removeAt(indiaIdx);
        allCountries.insert(0, india);
      }
      
      _countries = allCountries;
      
      // 2. Background Pre-load: India States
      final indiaStates = await csc.getStatesOfCountry('IN');
      _statesCache['IN'] = indiaStates;
      
      _isInitialized = true;
    } catch (e) {
      print('LocationService initialization failing, providing default India: $e');
      // FALLBACK: If assets fail (common on web), provide India manually
      _countries = [
        csc.Country(
          name: 'India',
          isoCode: 'IN',
          phoneCode: '91',
          currency: 'INR',
          flag: '🇮🇳',
          latitude: '20.5937',
          longitude: '78.9629',
          timezones: <csc.Timezone>[],
        )
      ];
      _isInitialized = true; // Mark as true so screens don't hang
    }
  }

  /// Get states with memory caching
  Future<List<csc.State>> getStates(String countryCode) async {
    if (_statesCache.containsKey(countryCode)) {
      return _statesCache[countryCode]!;
    }
    
    try {
      final states = await csc.getStatesOfCountry(countryCode);
      _statesCache[countryCode] = states;
      return states;
    } catch (e) {
      print('Error loading states for $countryCode: $e');
      return [];
    }
  }

  /// Get cities with memory caching
  Future<List<csc.City>> getCities(String countryCode, String stateCode) async {
    final cacheKey = '${countryCode}_$stateCode';
    if (_citiesCache.containsKey(cacheKey)) {
      return _citiesCache[cacheKey]!;
    }
    
    try {
      final cities = await csc.getStateCities(countryCode, stateCode);
      _citiesCache[cacheKey] = cities;
      return cities;
    } catch (e) {
      print('Error loading cities for $cacheKey: $e');
      return [];
    }
  }

  /// Get all cities in a country with memory caching
  Future<List<csc.City>> getCountryCities(String countryCode) async {
    final cacheKey = 'country_$countryCode';
    if (_citiesCache.containsKey(cacheKey)) {
      return _citiesCache[cacheKey]!;
    }
    
    try {
      final cities = await csc.getCountryCities(countryCode);
      _citiesCache[cacheKey] = cities;
      return cities;
    } catch (e) {
      print('Error loading country cities for $cacheKey: $e');
      return [];
    }
  }

  /// Get all cities in the world with memory caching
  Future<List<csc.City>> getAllCities() async {
    final cacheKey = 'all_world_cities';
    if (_citiesCache.containsKey(cacheKey)) {
      return _citiesCache[cacheKey]!;
    }
    
    try {
      final cities = await csc.getAllCities();
      _citiesCache[cacheKey] = cities;
      return cities;
    } catch (e) {
      print('Error loading all cities: $e');
      return [];
    }
  }
}
