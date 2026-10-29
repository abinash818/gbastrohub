import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudSyncService {
  static const String apiUrl = "https://gbastrocentre.com/api/muruga_api.php";

  /// Gets the currently authenticated user's email
  static String? get currentUserEmail {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null && user.email!.trim().isNotEmpty) {
        return user.email!.trim();
      }
    } catch (e) {
      debugPrint("Error getting current user email: $e");
    }
    return null;
  }

  /// Saves or updates a single horoscope in the cloud (Fire-and-forget / background safe)
  static Future<bool> saveToCloud({
    String? email,
    required Map<String, dynamic> item,
    String chartType = 'horoscope',
  }) async {
    final userEmail = email ?? currentUserEmail;
    if (userEmail == null || userEmail.isEmpty) {
      debugPrint("[CloudSync] No user email logged in. Skipping cloud save.");
      return false;
    }

    try {
      final String itemId = (item['id'] ?? item['item_id'] ?? DateTime.now().millisecondsSinceEpoch).toString();
      final String name = (item['name'] ?? '').toString();
      final String dateStr = (item['date'] ?? item['date_time'] ?? '').toString();
      final String place = (item['place'] ?? '').toString();
      final String gender = (item['gender'] ?? 'male').toString();
      final double lat = double.tryParse((item['latitude'] ?? item['lat'] ?? 0.0).toString()) ?? 0.0;
      final double lon = double.tryParse((item['longitude'] ?? item['lon'] ?? 0.0).toString()) ?? 0.0;
      final double tz = double.tryParse((item['timezone'] ?? item['tz'] ?? 5.5).toString()) ?? 5.5;
      final int ayanamsa = int.tryParse((item['ayanamsa'] ?? 1).toString()) ?? 1;

      final body = jsonEncode({
        "action": "save_horoscope",
        "email": userEmail,
        "item_id": itemId,
        "chart_type": chartType,
        "name": name,
        "gender": gender,
        "date_time": dateStr,
        "place": place,
        "latitude": lat,
        "longitude": lon,
        "timezone": tz,
        "ayanamsa": ayanamsa,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res['success'] == true;
      }
    } catch (e) {
      debugPrint("[CloudSync] Error saving to cloud: $e");
    }
    return false;
  }

  /// Deletes a horoscope from cloud by email and item_id
  static Future<bool> deleteFromCloud({
    String? email,
    required String itemId,
  }) async {
    final userEmail = email ?? currentUserEmail;
    if (userEmail == null || userEmail.isEmpty) return false;

    try {
      final body = jsonEncode({
        "action": "delete_horoscope",
        "email": userEmail,
        "item_id": itemId,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res['success'] == true;
      }
    } catch (e) {
      debugPrint("[CloudSync] Error deleting from cloud: $e");
    }
    return false;
  }

  /// Performs full 2-way merge:
  /// 1. Uploads local horoscopes and prasannams to cloud (if not yet present on cloud)
  /// 2. Downloads all cloud records and merges them into local SharedPreferences (without duplicating)
  static Future<Map<String, dynamic>> syncAll({String? email}) async {
    final userEmail = email ?? currentUserEmail;
    if (userEmail == null || userEmail.isEmpty) {
      return {"success": false, "message": "பயனர் லாகின் செய்யப்படவில்லை (No logged-in user)"};
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Read local general horoscopes
      final List<String> rawHoroscopes = prefs.getStringList('saved_horoscopes') ?? [];
      final List<Map<String, dynamic>> localHoroscopes = [];
      bool localHoroscopesUpdated = false;

      for (int i = 0; i < rawHoroscopes.length; i++) {
        try {
          final map = jsonDecode(rawHoroscopes[i]) as Map<String, dynamic>;
          // Ensure each item has a unique id
          if (map['id'] == null && map['item_id'] == null) {
            map['id'] = 'h_${DateTime.now().millisecondsSinceEpoch}_$i';
            rawHoroscopes[i] = jsonEncode(map);
            localHoroscopesUpdated = true;
          }
          localHoroscopes.add(map);
        } catch (_) {}
      }
      if (localHoroscopesUpdated) {
        await prefs.setStringList('saved_horoscopes', rawHoroscopes);
      }

      // Read local jamakkol prasannams
      final List<String> rawPrasannams = prefs.getStringList('saved_jamakkol_prasannams') ?? [];
      final List<Map<String, dynamic>> localPrasannams = [];
      bool localPrasannamsUpdated = false;

      for (int i = 0; i < rawPrasannams.length; i++) {
        try {
          final map = jsonDecode(rawPrasannams[i]) as Map<String, dynamic>;
          if (map['id'] == null && map['item_id'] == null) {
            map['id'] = 'j_${DateTime.now().millisecondsSinceEpoch}_$i';
            rawPrasannams[i] = jsonEncode(map);
            localPrasannamsUpdated = true;
          }
          localPrasannams.add(map);
        } catch (_) {}
      }
      if (localPrasannamsUpdated) {
        await prefs.setStringList('saved_jamakkol_prasannams', rawPrasannams);
      }

      // Prepare batch payload
      final List<Map<String, dynamic>> itemsToUpload = [];

      for (var h in localHoroscopes) {
        itemsToUpload.add({
          "item_id": (h['id'] ?? h['item_id']).toString(),
          "chart_type": "horoscope",
          "name": h['name'] ?? '',
          "gender": h['gender'] ?? 'male',
          "date_time": (h['date'] ?? h['date_time'] ?? '').toString(),
          "place": h['place'] ?? '',
          "latitude": double.tryParse((h['latitude'] ?? h['lat'] ?? 0.0).toString()) ?? 0.0,
          "longitude": double.tryParse((h['longitude'] ?? h['lon'] ?? 0.0).toString()) ?? 0.0,
          "timezone": double.tryParse((h['timezone'] ?? h['tz'] ?? 5.5).toString()) ?? 5.5,
          "ayanamsa": int.tryParse((h['ayanamsa'] ?? 1).toString()) ?? 1,
        });
      }

      for (var p in localPrasannams) {
        itemsToUpload.add({
          "item_id": (p['id'] ?? p['item_id']).toString(),
          "chart_type": "jamakkol",
          "name": p['name'] ?? '',
          "gender": 'male',
          "date_time": (p['date'] ?? p['date_time'] ?? '').toString(),
          "place": p['place'] ?? '',
          "latitude": double.tryParse((p['latitude'] ?? p['lat'] ?? 0.0).toString()) ?? 0.0,
          "longitude": double.tryParse((p['longitude'] ?? p['lon'] ?? 0.0).toString()) ?? 0.0,
          "timezone": double.tryParse((p['timezone'] ?? p['tz'] ?? 5.5).toString()) ?? 5.5,
          "ayanamsa": 1,
        });
      }

      final body = jsonEncode({
        "action": "batch_sync_horoscopes",
        "email": userEmail,
        "items": itemsToUpload,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res['success'] == true && res['items'] is List) {
          final List cloudItems = res['items'];
          int restoredCount = 0;

          // Existing local IDs map for quick lookup
          final Set<String> localHoroscopeIds = localHoroscopes
              .map((e) => (e['id'] ?? e['item_id'] ?? '').toString())
              .toSet();
          final Set<String> localPrasannamIds = localPrasannams
              .map((e) => (e['id'] ?? e['item_id'] ?? '').toString())
              .toSet();

          for (var c in cloudItems) {
            final String cId = (c['item_id'] ?? '').toString();
            final String cType = (c['chart_type'] ?? 'horoscope').toString();
            if (cId.isEmpty) continue;

            if (cType == 'jamakkol') {
              if (!localPrasannamIds.contains(cId)) {
                final newItem = {
                  'id': cId,
                  'name': c['name'] ?? '',
                  'date': c['date_time'] ?? '',
                  'place': c['place'] ?? '',
                  'lat': double.tryParse((c['latitude'] ?? 0.0).toString()) ?? 0.0,
                  'lon': double.tryParse((c['longitude'] ?? 0.0).toString()) ?? 0.0,
                  'tz': double.tryParse((c['timezone'] ?? 5.5).toString()) ?? 5.5,
                  'ayanamsa': (c['ayanamsa'] == 1 || c['ayanamsa'] == '1') ? 'KP New' : 'Lahiri',
                  'created_at': c['created_at'] ?? c['date_time'],
                };
                rawPrasannams.add(jsonEncode(newItem));
                localPrasannamIds.add(cId);
                restoredCount++;
              }
            } else {
              // Horoscope
              if (!localHoroscopeIds.contains(cId)) {
                final newItem = {
                  'id': cId,
                  'name': c['name'] ?? '',
                  'gender': c['gender'] ?? 'male',
                  'date': c['date_time'] ?? '',
                  'latitude': double.tryParse((c['latitude'] ?? 0.0).toString()) ?? 0.0,
                  'longitude': double.tryParse((c['longitude'] ?? 0.0).toString()) ?? 0.0,
                  'timezone': double.tryParse((c['timezone'] ?? 5.5).toString()) ?? 5.5,
                  'place': c['place'] ?? '',
                };
                rawHoroscopes.add(jsonEncode(newItem));
                localHoroscopeIds.add(cId);
                restoredCount++;
              }
            }
          }

          // Persist merged lists locally
          await prefs.setStringList('saved_horoscopes', rawHoroscopes);
          await prefs.setStringList('saved_jamakkol_prasannams', rawPrasannams);

          return {
            "success": true,
            "message": "சிங்க் வெற்றிகரமாக முடிந்தது",
            "restoredCount": restoredCount,
            "totalCloudCount": cloudItems.length,
          };
        }
      }
    } catch (e) {
      debugPrint("[CloudSync] Error syncing all: $e");
      return {"success": false, "message": e.toString()};
    }
    return {"success": false, "message": "Sync request failed"};
  }
}
