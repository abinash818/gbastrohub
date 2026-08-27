import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscription_plan.dart';

class SubscriptionService {
  static const String apiUrl = "https://deeppink-hedgehog-734715.hostingersite.com/subscription_api.php";
  static const String userApiUrl = "https://deeppink-hedgehog-734715.hostingersite.com/user_subscription_api.php";

  Future<List<SubscriptionPlan>> getActivePlans() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> plansList = data['plans'];
          return plansList.map((planMap) => SubscriptionPlan.fromMap(planMap, planMap['id'].toString())).toList();
        }
      }
    } catch (e) {
      print("Error fetching plans from PHP API: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> checkUserSubscription(String userId, [String? email]) async {
    try {
      final response = await http.post(
        Uri.parse(userApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "check_status", 
          "user_id": userId,
          if (email != null) "email": email
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error checking subscription: $e");
      return {"success": false, "is_premium": false, "error": true};
    }
    return {"success": false, "is_premium": false, "error": true};
  }

  Future<Map<String, dynamic>> activateSubscription(String userId, int planId, String paymentId) async {
    try {
      final response = await http.post(
        Uri.parse(userApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "create_subscription",
          "user_id": userId,
          "plan_id": planId,
          "payment_id": paymentId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error activating subscription: $e");
    }
    return {"success": false, "message": "Failed to connect to server"};
  }
}
