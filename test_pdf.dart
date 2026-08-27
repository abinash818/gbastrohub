import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/one_page_pdf_service.dart';
import 'dart:convert';

void main() async {
  // Simulate results
  Map<String, dynamic> results = {
    'rasi': {
      'Aries': ['சூரி 18:58', 'சந் 12:00'],
      'Taurus': ['லக் 14:05']
    }
  };
  
  var rasiMap = OnePagePdfServiceTest._getSafeChartMap(results, 'rasi', 'ta');
  print(jsonEncode(rasiMap));
}

class OnePagePdfServiceTest {
  static Map<int, List<String>> _getSafeChartMap(Map results, String key, String langCode) {
    final Map<int, List<String>> rasiMap = {};
    final lookupKey = (key == 'transit_rasi') ? 'rasi' : key;
    if (results.containsKey(lookupKey) && results[lookupKey] is Map) {
      final Map raw = results[lookupKey];
      raw.forEach((s, pList) {
        int idx = _getSignIdx(s.toString());
        if (idx != -1) {
          final List<String> planets = pList is List ? pList.map((e) => e.toString()).toList() : [pList.toString()];
          final List<String> cleanPlanets = [];
          for (var p in planets) {
            final trimmed = p.trim();
            if (trimmed.isEmpty) continue;
            
            // Split by space to separate planet name from degrees/details
            final firstWord = trimmed.split(' ').first;
            
            // Filter out house cusps (which are Roman numerals: I, II, III...)
            const romanNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'];
            if (romanNumerals.contains(firstWord)) {
              cleanPlanets.add(trimmed);
              continue;
            }
            
            // Translate the planet
            final localizedName = _toLocal(firstWord, langCode);
            if (localizedName.isNotEmpty) {
              cleanPlanets.add(localizedName);
            }
          }
          if (cleanPlanets.isNotEmpty) {
            rasiMap.putIfAbsent(idx + 1, () => []).addAll(cleanPlanets);
          }
        }
      });
    }
    return rasiMap;
  }
  
  static int _getSignIdx(String s) {
    int idx = KPService.SIGNS.indexOf(s);
    if (idx == -1) idx = KPService.TAMIL_SIGNS.values.toList().indexOf(s);
    if (idx == -1) idx = (int.tryParse(s) ?? 1) - 1;
    return idx;
  }
  
  static String _toLocal(String p, String langCode) {
    final key = p.toLowerCase().trim();
    final Map<String, String> shortMap = langCode == 'en' ? KPService.ENGLISH_PLANET_SHORT : (langCode == 'hi' ? KPService.HINDI_PLANET_SHORT : KPService.TAMIL_PLANET_SHORT);
    final Map<String, String> fullMap = langCode == 'en' ? KPService.ENGLISH_PLANETS : (langCode == 'hi' ? KPService.HINDI_PLANETS : KPService.TAMIL_PLANETS);
    
    if (shortMap.containsKey(key)) return shortMap[key]!;
    if (shortMap.values.contains(p)) return p;
    for (var entry in fullMap.entries) {
      if (entry.value == p || entry.key == p) {
        return shortMap[entry.key] ?? shortMap[entry.key.toLowerCase()] ?? p;
      }
    }
    if (key.startsWith('t_')) {
      final subKey = key.substring(2);
      if (shortMap.containsKey(subKey)) return shortMap[subKey]!;
    }
    return "";
  }
}
