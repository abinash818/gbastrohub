import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccessService {
  static final AccessService _instance = AccessService._internal();
  factory AccessService() => _instance;
  AccessService._internal();

  final _secureStorage = const FlutterSecureStorage();
  Map<String, dynamic> _accessMap = {};

  Future<void> init() async {
    try {
      final accessStr = await _secureStorage.read(key: 'user_access_map');
      if (accessStr != null) {
        _accessMap = jsonDecode(accessStr);
      } else {
        _accessMap = {};
      }
    } catch (e) {
      _accessMap = {};
    }
  }

  Future<void> updateAccess(Map<String, dynamic>? accessData) async {
    if (accessData != null) {
      _accessMap = accessData;
      try {
        await _secureStorage.write(key: 'user_access_map', value: jsonEncode(_accessMap));
      } catch (e) {
        print("Error writing access to secure storage: $e");
      }
    }
  }

  bool hasAccess(String feature) {
    if (_accessMap.isEmpty) return false; // Fixed: Default to false, empty means no access
    
    // Check exact key first
    if (_accessMap[feature] == true || _accessMap[feature] == 1 || _accessMap[feature] == "1") {
      return true;
    }
    
    // Mapping from internal keys to Tamil strings from DB
    Map<String, String> tamilMapping = {
      'can_view_jathagam': 'ஜாதகம்',
      'can_view_matching': 'பொருத்தம்',
      'can_view_kp': 'KP',
      'can_view_numerology': 'எண் கணிதம்',
      'can_view_jamakkol': 'ஜாமக்கோள்',
      'can_view_nadi': 'நாடி',
      'can_view_muhurtham': 'சுபநேரம்',
      'can_view_panchangam': 'பஞ்சாங்கம்'
    };
    
    // Mapping from internal keys to English strings from DB Admin Panel
    Map<String, String> englishMapping = {
      'can_view_jathagam': 'Jathagam',
      'can_view_matching': 'Porutham',
      'can_view_kp': 'KP Astrology',
      'can_view_numerology': 'Numerology',
      'can_view_jamakkol': 'Jamakkol',
      'can_view_nadi': 'Nadi Astrology',
      'can_view_muhurtham': 'Muhurtham',
      'can_view_panchangam': 'Panchangam'
    };
    
    if (tamilMapping.containsKey(feature)) {
      String tamilKey = tamilMapping[feature]!;
      if (_accessMap[tamilKey] == true || _accessMap[tamilKey] == 1 || _accessMap[tamilKey] == "1") {
        return true;
      }
    }

    if (englishMapping.containsKey(feature)) {
      String englishKey = englishMapping[feature]!;
      if (_accessMap[englishKey] == true || _accessMap[englishKey] == 1 || _accessMap[englishKey] == "1") {
        return true;
      }
    }
    
    // Fallback if the user has full premium subscription
    if (_accessMap['is_premium'] == true) {
      return true;
    }
    
    return false;
  }

  List<String> getActiveFeatures() {
    List<String> activeFeatures = [];
    _accessMap.forEach((key, value) {
      if ((value == true || value == 1 || value == "1") && key != 'is_premium' && key != 'last_online_check' && key != 'start_date' && key != 'end_date') {
        activeFeatures.add(key);
      }
    });
    return activeFeatures;
  }

  String? get startDate => _accessMap['start_date'];
  String? get endDate => _accessMap['end_date'];

  bool isOfflineExpired(int daysLimit) {
    if (!_accessMap.containsKey('last_online_check')) return true;
    
    try {
      DateTime lastCheck = DateTime.parse(_accessMap['last_online_check']);
      DateTime now = DateTime.now();
      return now.difference(lastCheck).inDays >= daysLimit;
    } catch (e) {
      return true; // If parsing fails, force online check
    }
  }
}
