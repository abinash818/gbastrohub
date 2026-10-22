import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

  static const String _adminWhatsAppNumber = '919787067910';
  static const String _gpayNumberDisplay = '+91 97870 67910';
  static const String _gpayNumberRaw = '9787067910';
  static const String _upiId = 'ganeshmuthukumarts@okicici';

  Future<void> _downloadOrShareQrCode() async {
    try {
      final byteData = await rootBundle.load('assets/images/gpay_qr.png');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/gb_astro_gpay_qr.png');
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'GB ASTRO - Google Pay / PhonePe QR Code\nGPay / PhonePe No: +91 97870 67910\nUPI ID: ganeshmuthukumarts@okicici',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR Code-ஐ பதிவிறக்க/பகிர முடியவில்லை: $e')),
        );
      }
    }
  }

  void _showQrCodeDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFFF9EE),
          title: Row(
            children: const [
              Icon(Icons.qr_code_2_rounded, color: Color(0xFF5D1204), size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "GPay / PhonePe QR Code",
                  style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/gpay_qr.png',
                      height: 240,
                      width: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 240,
                        width: 240,
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: const Text("QR Code Image\n(assets/images/gpay_qr.png)", textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "GPay / PhonePe எண்:",
                  style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                const SelectableText(
                  _gpayNumberDisplay,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D1204), letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "UPI ID: $_upiId",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(const ClipboardData(text: _upiId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('UPI ID நகலெடுக்கப்பட்டது!'), duration: Duration(seconds: 2)),
                          );
                        },
                        child: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF5D1204)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "இந்த QR Code-ஐ சேமித்து (Save / Download) அல்லது ஸ்கேன் செய்து Google Pay / PhonePe-ல் பணம் செலுத்தலாம்.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black87.withOpacity(0.8), height: 1.3),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D1204),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text("Download / Share", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: _downloadOrShareQrCode,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text("Close", style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPlanViaWhatsApp(SubscriptionPlan plan) async {
    final userEmail = _authService.currentUser?.email ?? _authService.currentUser?.phoneNumber ?? 'Unknown';
    final userPhone = _authService.currentUser?.phoneNumber ?? '';

    final StringBuffer msg = StringBuffer();
    msg.writeln("வணக்கம் குருஜி,");
    msg.writeln("நான் GB ASTRO செயலியில் *${plan.name}* (₹${plan.price.toStringAsFixed(0)} / ${plan.durationDays} நாட்கள்) சந்தா பெற விரும்புகிறேன்.");
    msg.writeln();
    msg.writeln("📌 எனது விவரங்கள் (My Details):");
    msg.writeln("• மின்னஞ்சல் (Email): $userEmail");
    if (userPhone.isNotEmpty) {
      msg.writeln("• தொலைபேசி (Phone): $userPhone");
    }
    msg.writeln("• திட்டம் (Plan): ${plan.name} (₹${plan.price.toStringAsFixed(0)})");
    msg.writeln();
    msg.writeln("Google Pay / PhonePe எண் ($_gpayNumberDisplay) மூலமாக பணம் செலுத்திவிட்டேன் / ரசீது இணைத்துள்ளேன். தயவுசெய்து எனது சந்தாவை செயல்படுத்தி தருமாறு கேட்டுக்கொள்கிறேன். நன்றி!");

    final Uri url = Uri.parse('https://wa.me/$_adminWhatsAppNumber?text=${Uri.encodeComponent(msg.toString())}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WhatsApp திறக்க முடியவில்லை: $e')),
        );
      }
    }
  }

  void _showPlanPaymentBottomSheet(SubscriptionPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF9EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              const SizedBox(height: 6),
              Text(
                "கால அளவு: ${plan.durationDays} நாட்கள்",
                style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFB58D3D)),
              const SizedBox(height: 12),
              
              // GPay / PhonePe Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5D1204), Color(0xFF8B2B15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF5D1204).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.payment_rounded, color: Color(0xFFF3D99F), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Google Pay / PhonePe கட்டணம் செலுத்துக:",
                            style: TextStyle(color: Color(0xFFF3D99F), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF3D99F).withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: SelectableText(
                              _gpayNumberDisplay,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(const ClipboardData(text: _gpayNumberRaw));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('GPay / PhonePe எண் நகலெடுக்கப்பட்டது! (Number copied)'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3D99F),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.copy_rounded, size: 14, color: Color(0xFF5D1204)),
                                      SizedBox(width: 4),
                                      Text("Copy", style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _showQrCodeDialog();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3D99F),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.qr_code_rounded, size: 14, color: Color(0xFF5D1204)),
                                      SizedBox(width: 4),
                                      Text("QR", style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "இந்த எண்ணிற்கு ₹${plan.price.toStringAsFixed(0)} செலுத்திவிட்டு, ஸ்கிரீன்ஷாட் (Screenshot) எடுத்து WhatsApp-ல் அனுப்பவும்.",
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // WhatsApp Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
                label: const Text(
                  "WhatsApp-ல் கோரிக்கை அனுப்ப (Request via WhatsApp)",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _requestPlanViaWhatsApp(plan);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("ரத்து செய் (Cancel)", style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
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
      } else if (subStatus['error'] == true || statusData['status'] == 'ERROR') {
        if (AccessService().getActiveFeatures().isNotEmpty || AccessService().hasAccess('is_premium')) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('இணைப்பில் தாமதம். நீங்கள் முதன்மைப் பக்கத்திற்குச் செல்லலாம்.'),
            backgroundColor: Colors.orange,
          ));
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error. Please try again.')));
        }
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
                
                final userCard = // User Details & Refresh Card (Compact)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5D1204), Color(0xFF8B2B15)], // Premium dark red gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF5D1204).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                    border: Border.all(color: const Color(0xFFB58D3D), width: 1.5), // Gold border
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info & Active Status Row (Compact)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB58D3D).withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Color(0xFFF3D99F), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Logged in as", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                                Text(
                                  _authService.currentUser?.email ?? _authService.currentUser?.phoneNumber ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF3D99F).withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars_rounded, color: Color(0xFFF3D99F), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  activeFeatures.isEmpty ? 'Free Plan' : 'Premium (${activeFeatures.length})',
                                  style: const TextStyle(color: Color(0xFFF3D99F), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      if (activeFeatures.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Active: ${activeFeatures.join(', ')}",
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                        ),
                      ],

                      if (AccessService().startDate != null && AccessService().endDate != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Purchased: ${_formatDate(AccessService().startDate!)}",
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                            Text(
                              "Expires: ${_formatDate(AccessService().endDate!)}",
                              style: const TextStyle(color: Color(0xFFF3D99F), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),

                      // GPay / PhonePe Payment Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB58D3D).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF3D99F), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFF3D99F), size: 18),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Google Pay / PhonePe கட்டணம்:",
                                    style: TextStyle(color: Color(0xFFF3D99F), fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  child: SelectableText(
                                    _gpayNumberDisplay,
                                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(const ClipboardData(text: _gpayNumberRaw));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('GPay எண் நகலெடுக்கப்பட்டது! (Number copied)'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3D99F),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.copy_rounded, size: 12, color: Color(0xFF5D1204)),
                                            SizedBox(width: 3),
                                            Text("Copy", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: _showQrCodeDialog,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3D99F),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.qr_code_rounded, size: 13, color: Color(0xFF5D1204)),
                                            SizedBox(width: 3),
                                            Text("QR Code", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "இந்த எண்ணிற்கு பணம் செலுத்திவிட்டு, கீழே உள்ள திட்டத்தில் WhatsApp வழியாக ரசீது அனுப்பவும்.",
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      
                      // Refresh Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _isChecking ? null : _verifyCurrentSubscription,
                          icon: _isChecking 
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5D1204))) 
                              : const Icon(Icons.sync_rounded, color: Color(0xFF5D1204), size: 20),
                          label: Text(
                            _isChecking ? "Checking..." : "சந்தாவை சரிபார்க்க (Check Subscription)",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3D99F),
                            foregroundColor: const Color(0xFF5D1204),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Center(
                        child: Text(
                          "பணம் செலுத்திய பின், சந்தாவை அப்டேட் செய்ய இந்த பட்டனை அழுத்தவும்.",
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      if (AccessService().hasAccess('is_premium') || AccessService().getActiveFeatures().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                            icon: const Icon(Icons.dashboard_rounded, color: Color(0xFFF3D99F), size: 18),
                            label: const Text(
                              "முதன்மைப் பக்கம் (Open Dashboard)",
                              style: TextStyle(color: Color(0xFFF3D99F), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFF3D99F), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ],
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
                            Expanded(
                              flex: 3,
                              child: _plans.isEmpty
                                  ? const Center(child: Text("No active plans available."))
                                  : ListView.builder(
                                      itemCount: _plans.length,
                                      itemBuilder: (context, index) => _buildPlanCard(_plans[index]),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          userCard,
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Row(
                              children: const [
                                Icon(Icons.workspace_premium_rounded, color: Color(0xFF5D1204), size: 22),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "சந்தா திட்டங்கள் (Subscription Plans)",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5D1204),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_plans.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(child: Text("No active plans available.")),
                            )
                          else
                            ..._plans.map((plan) => _buildPlanCard(plan)),
                          const SizedBox(height: 32),
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
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                onPressed: () => _showPlanPaymentBottomSheet(plan),
                label: const Text(
                  "WhatsApp மூலம் பெற (Request via WhatsApp)",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
