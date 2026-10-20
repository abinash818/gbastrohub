import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscription_plan.dart';

class SubscriptionService {
  static const String apiUrl = "https://gbastrocentre.com/api/subscription_api.php";
  static const String userApiUrl = "https://gbastrocentre.com/api/user_subscription_api.php";

  Future<List<SubscriptionPlan>> getActivePlans() async {
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> plansList = data['plans'];
          final plans = plansList.map((planMap) => SubscriptionPlan.fromMap(planMap, planMap['id'].toString())).toList();
          if (plans.isNotEmpty) return plans;
        }
      }
    } catch (e) {
      print("Error fetching plans from PHP API: $e");
    }
    return _getDefaultPlans();
  }

  List<SubscriptionPlan> _getDefaultPlans() {
    return [
      SubscriptionPlan(
        id: "1",
        name: "1 Month Plan",
        price: 499.0,
        durationDays: 30,
        features: ["ஜாதகம்", "பொருத்தம்", "எண் கணிதம்", "ஜாமக்கோள்", "வாஸ்து"],
        isActive: true,
        order: 1,
      ),
      SubscriptionPlan(
        id: "2",
        name: "6 Months Plan",
        price: 1999.0,
        durationDays: 180,
        features: ["ஜாதகம்", "பொருத்தம்", "எண் கணிதம்", "ஜாமக்கோள்", "வாஸ்து", "பஞ்சாங்கம்"],
        isActive: true,
        order: 2,
      ),
      SubscriptionPlan(
        id: "3",
        name: "1 Year Plan",
        price: 3499.0,
        durationDays: 365,
        features: ["அனைத்து வசதிகளும் (All Features)"],
        isActive: true,
        order: 3,
      ),
    ];
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
