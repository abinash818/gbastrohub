import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  // --- CHANGE THIS TO YOUR ACTUAL SERVER URL ---
  static const String apiUrl = "https://deeppink-hedgehog-734715.hostingersite.com/muruga_api.php";

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Get Unique Device ID and Model
  Future<Map<String, String>> getDeviceInfo() async {
    String deviceId = "Unknown";
    String model = "Unknown";

    try {
      if (kIsWeb) {
        WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;
        deviceId = "WEB_${webInfo.userAgent.hashCode}";
        model = "Web Browser (${webInfo.browserName.name})";
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Unique ID
        model = "${androidInfo.manufacturer} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "Unknown";
        model = iosInfo.utsname.machine;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await _deviceInfo.windowsInfo;
        deviceId = windowsInfo.deviceId.replaceAll('{', '').replaceAll('}', '');
        model = "Windows PC (${windowsInfo.computerName})";
      }
    } catch (e) {
      print("Error getting device info: $e");
    }

    return {"deviceId": deviceId, "model": model};
  }

  // Check user status in PHP Server
  Future<Map<String, dynamic>> checkUserStatus(String email) async {
    final info = await getDeviceInfo();
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "check_status",
          "email": email,
          "device_id": info['deviceId'],
        }),
      );

      print("Server Response Status: ${response.statusCode}");
      print("Server Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error checking status: $e");
    }
    return {"status": "ERROR", "message": "Connection error"};
  }

  // Request Approval (Register Device)
  Future<bool> requestApproval({
    required String email,
    required String phone,
  }) async {
    final info = await getDeviceInfo();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "register_device",
          "email": email,
          "device_id": info['deviceId'],
          "device_model": info['model'],
          "phone_number": phone,
        }),
      );

      print("Server Response Status (Register): ${response.statusCode}");
      print("Server Response Body (Register): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
    } catch (e) {
      print("Error registering device: $e");
    }
    return false;
  }
}
