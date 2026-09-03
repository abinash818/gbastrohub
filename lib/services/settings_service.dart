import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyLocationName = 'default_location_name';
  static const String _keyLat = 'default_latitude';
  static const String _keyLon = 'default_longitude';
  static const String _keyTz = 'default_timezone';
  static const String _keyAstroName = 'astrologer_name';
  static const String _keyAstroPhone = 'astrologer_phone';
  static const String _keyAstroAddress = 'astrologer_address';
  static const String _keyStateName = 'default_state_name';
  static const String _keyCountryIso = 'default_country_iso';
  static const String _keyDasaYearLength = 'dasa_year_length';
  static const String _keyAyanamsa = 'ayanamsa_mode';
  static const String _keyCustomAyanamsaDeg = 'custom_ayanamsa_deg';
  static const String _keyCustomAyanamsaMin = 'custom_ayanamsa_min';
  static const String _keyCustomAyanamsaSec = 'custom_ayanamsa_sec';
  static const String _keyBhavaMethod = 'bhava_method'; // 0 = Placidus / KP, 1 = Sripati
  static const String _keyFontSize = 'app_font_size';
  static const String _keyTrueNode = 'use_true_node';
  static const String _keyLanguage = 'app_language';
  static const String _keyUdayamMethod = 'udayam_method';
  static const String _keyMaandiMethod = 'maandi_method';
  static const String _keyIncludeLagnaAshtakavarga = 'include_lagna_ashtakavarga';

  static Future<void> saveIncludeLagnaAshtakavarga(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIncludeLagnaAshtakavarga, value);
  }

  static Future<bool> getIncludeLagnaAshtakavarga() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIncludeLagnaAshtakavarga) ?? false;
  }

  static Future<void> saveMaandiMethod(int method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaandiMethod, method);
  }

  static Future<int> getMaandiMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMaandiMethod) ?? 1; // Default to 1 (Start of Saturn's part)
  }

  static Future<void> saveUdayamMethod(int method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUdayamMethod, method);
  }

  static Future<int> getUdayamMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUdayamMethod) ?? 0;
  }

  static Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, langCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'ta';
  }

  static Future<void> saveTrueNodeMode(bool isTrueNode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTrueNode, isTrueNode);
  }

  static Future<bool> getTrueNodeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTrueNode) ?? false; // false = Mean Node (default), true = True Node
  }

  static Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, size);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyFontSize) ?? 1.0;
  }

  static Future<void> saveDasaYearLength(double length) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDasaYearLength, length);
  }

  static Future<double> getDasaYearLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyDasaYearLength) ?? 365.25;
  }

  static Future<void> saveAyanamsa(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAyanamsa, mode);
  }

  static Future<int> getAyanamsa() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAyanamsa) ?? 0; // 0 = Lahiri
  }

  static Future<void> saveBhavaMethod(int method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBhavaMethod, method);
  }

  static Future<int> getBhavaMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBhavaMethod) ?? 0; // 0 = Placidus/KP, 1 = Sripati
  }

  static Future<void> saveCustomAyanamsa({required int deg, required int min, required int sec}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCustomAyanamsaDeg, deg);
    await prefs.setInt(_keyCustomAyanamsaMin, min);
    await prefs.setInt(_keyCustomAyanamsaSec, sec);
  }

  static Future<Map<String, int>> getCustomAyanamsa() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'deg': prefs.getInt(_keyCustomAyanamsaDeg) ?? 24,
      'min': prefs.getInt(_keyCustomAyanamsaMin) ?? 15,
      'sec': prefs.getInt(_keyCustomAyanamsaSec) ?? 0,
    };
  }

  static Future<void> saveDefaultLocation({
    required String name,
    required double lat,
    required double lon,
    required double tz,
    String? state,
    String? countryIso,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocationName, name);
    await prefs.setDouble(_keyLat, lat);
    await prefs.setDouble(_keyLon, lon);
    await prefs.setDouble(_keyTz, tz);
    if (state != null) await prefs.setString(_keyStateName, state);
    if (countryIso != null) await prefs.setString(_keyCountryIso, countryIso);
  }

  static Future<Map<String, dynamic>> getDefaultLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyLocationName) ?? 'Chennai (சென்னை)',
      'lat': prefs.getDouble(_keyLat) ?? 13.0827,
      'lon': prefs.getDouble(_keyLon) ?? 80.2707,
      'tz': prefs.getDouble(_keyTz) ?? 5.5,
      'state': prefs.getString(_keyStateName) ?? 'Tamil Nadu',
      'countryIso': prefs.getString(_keyCountryIso) ?? 'IN',
    };
  }

  static Future<void> saveAstrologerDetails({
    required String name,
    required String phone,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAstroName, name);
    await prefs.setString(_keyAstroPhone, phone);
    await prefs.setString(_keyAstroAddress, address);
  }

  static Future<Map<String, String>> getAstrologerDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyAstroName) ?? '',
      'phone': prefs.getString(_keyAstroPhone) ?? '',
      'address': prefs.getString(_keyAstroAddress) ?? '',
    };
  }
}
