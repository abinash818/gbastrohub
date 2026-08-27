import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';
import '../services/auth_service.dart';
import '../services/access_service.dart';
import '../services/device_service.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionPlansScreenState createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final AuthService _authService = AuthService();
  
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _fetchUserId();
  }

  void _fetchUserId() {
    // For testing, we use a temp user id if no user is logged in
    _userId = _authService.currentUser?.uid ?? 'test_user_id';
  }

  Future<void> _fetchPlans() async {
    final plans = await _subscriptionService.getActivePlans();
    setState(() {
      _plans = plans;
      _isLoading = false;
    });
  }

  bool _isBrowserOpen = false;

  Future<void> _initiatePayment(SubscriptionPlan plan) async {
    final amountInPaisa = (plan.price * 100).toInt();
    
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String orderId = "APP${timestamp}";

    // Construct the Guruji Checkout Wrapper URL
    final String checkoutUrl = "https://abinaasananthaguruji.com/api/aadhiguru_checkout.php?amount=$amountInPaisa&user_id=$_userId&plan_id=${plan.id}&order_id=$orderId";
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening secure payment gateway...')));

    try {
      final Uri url = Uri.parse(checkoutUrl);
      
      _isBrowserOpen = true;
      
      // Open in Custom Tab.
      launchUrl(url, mode: LaunchMode.inAppBrowserView).then((_) {
        _isBrowserOpen = false;
      });
      
      // Start polling in the background to detect success
      _pollPaymentStatus(orderId, plan.id.toString());
      
      // Show the manual verification dialog so user can verify if polling fails
      _showPaymentStatusDialog(orderId, plan.id.toString());
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open payment page: $e')));
    }
  }

  void _showPaymentStatusDialog(String orderId, String planId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Payment in Progress", style: TextStyle(color: Color(0xFFB58D3D))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Please complete the payment in the browser overlay.\n\nNote: After payment, PhonePe will redirect to a blank error page (due to a whitelist issue). Please DO NOT WORRY. Just close the browser by clicking 'X' at the top, and click 'Verify Payment' below!"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _isBrowserOpen = false;
                Navigator.pop(dialogContext);
              },
              child: const Text("Close"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB58D3D)),
              onPressed: () {
                Navigator.pop(dialogContext);
                _verifyPaymentStatus(context, orderId, planId);
              },
              child: const Text("Verify Payment"),
            ),
          ],
        );
      }
    );
  }

  Future<void> _pollPaymentStatus(String orderId, String planId) async {
    final String verifyUrl = "https://abinaasananthaguruji.com/api/aadhiguru_payment.php?action=check_status&orderId=$orderId&user_id=$_userId&plan_id=$planId";
    
    while (_isBrowserOpen) {
      await Future.delayed(const Duration(seconds: 3));
      if (!_isBrowserOpen) break;
      
      try {
        final response = await http.get(Uri.parse(verifyUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['success'] == true && data['is_premium'] == true) {
            // Payment was successful! Automatically close the browser!
            closeInAppWebView();
            _isBrowserOpen = false;
            
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Subscription Activated Successfully!'),
              backgroundColor: Colors.green,
            ));
            
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
            break;
          }
        }
      } catch (e) {
        // Ignore network errors during polling
      }
    }
  }
  Future<void> _verifyPaymentStatus(BuildContext context, String orderId, String planId) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verifying payment with PhonePe...')));

    try {
      final String verifyUrl = "https://abinaasananthaguruji.com/api/aadhiguru_payment.php?action=check_status&orderId=$orderId&user_id=$_userId&plan_id=$planId";
      
      final response = await http.get(Uri.parse(verifyUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['is_premium'] == true) {
          
           // Fetch new subscription features to update AccessService
           try {
             final userEmail = _authService.currentUser?.email ?? _authService.currentUser?.phoneNumber;
             
             // Fetch both Admin features and Subscription features
             final statusData = await DeviceService().checkUserStatus(userEmail ?? '');
             final subStatus = await SubscriptionService().checkUserSubscription(_userId ?? '', userEmail);
             
             Map<String, dynamic> finalAccessMap = {};
             
             // Add Admin features
             if (statusData.containsKey('access') && statusData['access'] != null) {
                var accessData = statusData['access'];
                if (accessData is Map) {
                  finalAccessMap.addAll(accessData.cast<String, dynamic>());
                }
             }

             // Add Subscription features
             if (subStatus['success'] == true && subStatus['is_premium'] == true) {
               final subscription = subStatus['subscription'];
               finalAccessMap['is_premium'] = true;
               finalAccessMap['start_date'] = subscription['start_date'];
               finalAccessMap['end_date'] = subscription['end_date'];
               finalAccessMap['last_online_check'] = DateTime.now().toIso8601String();
             }
             
             if (finalAccessMap.isNotEmpty) {
                await AccessService().updateAccess(finalAccessMap);
             }
          } catch (e) {
             print("Could not update access map immediately: $e");
          }

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Subscription Activated Successfully!'),
            backgroundColor: Colors.green,
          ));
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Payment not successful yet')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Server error while verifying payment')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not connect to payment server: $e')));
    }
  }


  bool _isChecking = false;
  Future<void> _verifyCurrentSubscription() async {
    setState(() => _isChecking = true);
    try {
      final userEmail = _authService.currentUser?.email ?? _authService.currentUser?.phoneNumber;
      
      // Fetch both Admin features and Subscription features
      final statusData = await DeviceService().checkUserStatus(userEmail ?? '');
      final subStatus = await SubscriptionService().checkUserSubscription(_userId ?? '', userEmail);
      
      Map<String, dynamic> finalAccessMap = {};
      
      // 1. Add Admin features
      if (statusData.containsKey('access') && statusData['access'] != null) {
        var accessData = statusData['access'];
        if (accessData is Map) {
          finalAccessMap.addAll(accessData.cast<String, dynamic>());
        }
      }

      // 2. Add Subscription features
      if (subStatus['success'] == true && subStatus['is_premium'] == true) {
        final subscription = subStatus['subscription'];
        finalAccessMap['is_premium'] = true;
        finalAccessMap['start_date'] = subscription['start_date'];
        finalAccessMap['end_date'] = subscription['end_date'];
        finalAccessMap['last_online_check'] = DateTime.now().toIso8601String();
      }

      bool hasAnyFeature = finalAccessMap.keys.any((key) => 
        (finalAccessMap[key] == true || finalAccessMap[key] == 1 || finalAccessMap[key] == "1") &&
        key != 'is_premium' && key != 'start_date' && key != 'end_date' && key != 'last_online_check'
      );

      if (hasAnyFeature || finalAccessMap['is_premium'] == true) {
        await AccessService().updateAccess(finalAccessMap);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('சந்தா புதுப்பிக்கப்பட்டது! (Subscription updated!)')));
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (subStatus['error'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error. Please try again.')));
      } else {
        await AccessService().updateAccess({'is_premium': false});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('உங்களுக்கு Active Premium சந்தா எதுவும் இல்லை.')));
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isChecking = false);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr.split(' ')[0]; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeFeatures = AccessService().getActiveFeatures();
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EE),
      appBar: AppBar(
        title: const Text('Premium Plans'),
        backgroundColor: const Color(0xFFB58D3D),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth > 900;
                
                final userCard = // User Details & Refresh Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5D1204), Color(0xFF8B2B15)], // Premium dark red gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF5D1204).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                    border: Border.all(color: const Color(0xFFB58D3D), width: 1.5), // Gold border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB58D3D).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Color(0xFFF3D99F), size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Logged in as", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                Text(
                                  _authService.currentUser?.email ?? _authService.currentUser?.phoneNumber ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Active Features Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.stars_rounded, color: Color(0xFFF3D99F), size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Active Features", style: TextStyle(color: Color(0xFFF3D99F), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                                  const SizedBox(height: 6),
                                  Text(
                                    activeFeatures.isEmpty ? 'None' : activeFeatures.join(',  '),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (AccessService().startDate != null && AccessService().endDate != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Purchased Date", style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(AccessService().startDate!),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              Container(height: 30, width: 1, color: Colors.white24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Expiry Date", style: TextStyle(color: Colors.white60, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(AccessService().endDate!),
                                    style: const TextStyle(color: Color(0xFFF3D99F), fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      
                      // Refresh Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isChecking ? null : _verifyCurrentSubscription,
                          icon: _isChecking 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5D1204))) 
                              : const Icon(Icons.sync_rounded, color: Color(0xFF5D1204), size: 24),
                          label: Text(
                            _isChecking ? "Checking..." : "சந்தாவை சரிபார்க்க (Check Subscription)",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3D99F), // Gold background
                            foregroundColor: const Color(0xFF5D1204), // Dark red text
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      
                      // Helper Text
                      Center(
                        child: Text(
                          "நீங்கள் அட்மினிடம் பேசி சந்தா வாங்கியிருந்தால்,\nஇந்த பட்டனை கிளிக் செய்து அப்டேட் செய்யவும்.",
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7), height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
                
                final plansList = // Plans List
                Expanded(
                  child: _plans.isEmpty
                      ? const Center(child: Text("No active plans available."))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _plans.length,
                          itemBuilder: (context, index) {
                            final plan = _plans[index];
                            return _buildPlanCard(plan);
                          },
                        ),
                );
                
                if (isWide) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: SingleChildScrollView(child: userCard)),
                            const SizedBox(width: 24),
                            plansList,
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          userCard,
                          plansList,
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFB58D3D), width: 1.5),
      ),
      elevation: 4,
      shadowColor: const Color(0xFFB58D3D).withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFFFF9EE)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D1204),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D1204),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "₹${plan.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Duration: ${plan.durationDays} Days",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFB58D3D)),
            const SizedBox(height: 8),
            if (plan.features.isNotEmpty)
              ...plan.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature.trim(), style: const TextStyle(fontSize: 15))),
                      ],
                    ),
                  )).toList()
            else
              const Text("Unlock all premium features."),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB58D3D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: () => _initiatePayment(plan),
                child: const Text("Subscribe Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
