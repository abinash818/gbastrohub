import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'approval_pending_screen.dart';
import '../services/location_service.dart';
import '../services/device_service.dart';
import '../services/access_service.dart';
import '../services/subscription_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';
import 'subscription_plans_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _controller.forward();

    _initializeAppData();
  }

  Future<void> _initializeAppData() async {
    final stopwatch = Stopwatch()..start();

    // Start pre-loading the location database
    await LocationService().init();

    Widget targetScreen = const LoginScreen();
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
      // If null, the SDK might still be reading from local storage.
      if (user == null) {
        try {
          // Wait for the first emission which gives the initialized state
          user = await FirebaseAuth.instance.authStateChanges().first.timeout(const Duration(milliseconds: 3000));
        } catch (_) {
          // Timeout reached or error.
        }
      }
    } catch (e) {
      debugPrint("Firebase Auth skipped: $e");
    }

    // Auto-login fallback for Windows Email/Password
    if (user == null) {
      try {
        final authService = AuthService();
        user = await authService.autoLoginWindows();
      } catch (e) {
        debugPrint("Auto Login fallback failed: $e");
      }
    }

    if (user != null) {
      // Check device status if user is already logged in with Firebase
      
      // --- PLAY STORE REVIEWER BACKDOOR ---
      if (user.email?.toLowerCase() == 'playstore@aadhiguru.com') {
        await AccessService().init();
        await AccessService().updateAccess({});
        targetScreen = const DashboardScreen();
      } else {
        final statusData = await DeviceService().checkUserStatus(user.email!);
        final String status = statusData['status'] ?? "NOT_REGISTERED";
        
        if (status == 'NOT_REGISTERED' || status == 'NEW_DEVICE' || status == 'LIMIT_REACHED') {
          // 1-Device Limit Enforcement: If this device is no longer approved 
          // (because they logged into another device), log them out locally
          try {
             await FirebaseAuth.instance.signOut();
             await AuthService().signOut();
          } catch (_) {}
          targetScreen = const LoginScreen();
        } else {
          // Global App Paywall: Check Subscription instead of Manual Admin Approval
          final subStatus = await SubscriptionService().checkUserSubscription(user.uid, user.email);
          
          Map<String, dynamic> finalAccessMap = {};
  
          // 1. Add Admin Panel Features (if any)
        if (statusData.containsKey('access') && statusData['access'] != null) {
          try {
            var accessData = statusData['access'];
            if (accessData is Map) {
              finalAccessMap.addAll(accessData.cast<String, dynamic>());
            }
          } catch(e){
            debugPrint("Error parsing admin access data: $e");
          }
        }

        // 2. Add Subscription Info (is_premium, dates)
        if (subStatus['success'] == true && subStatus['is_premium'] == true && subStatus['subscription'] != null) {
          final subscription = subStatus['subscription'];
          finalAccessMap['is_premium'] = true;
          finalAccessMap['start_date'] = subscription['start_date'];
          finalAccessMap['end_date'] = subscription['end_date'];
          finalAccessMap['last_online_check'] = DateTime.now().toIso8601String();
        }

        await AccessService().init();

        // 3. Decide navigation based on final access map
        bool hasAnyFeature = finalAccessMap.keys.any((key) => 
          (finalAccessMap[key] == true || finalAccessMap[key] == 1 || finalAccessMap[key] == "1") &&
          key != 'is_premium' && key != 'start_date' && key != 'end_date' && key != 'last_online_check'
        );

        if (hasAnyFeature || finalAccessMap['is_premium'] == true) {
          await AccessService().updateAccess(finalAccessMap);
          targetScreen = const DashboardScreen();
        } else if (subStatus['error'] == true) {
          // Offline or API error: rely on cached access
          if (AccessService().hasAccess('is_premium') || AccessService().getActiveFeatures().isNotEmpty) {
            if (AccessService().isOfflineExpired(15)) {
              // 15 days passed without internet check
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.noInternetSub),
                  duration: const Duration(seconds: 5),
                ));
              });
              targetScreen = const SubscriptionPlansScreen();
            } else {
              targetScreen = const DashboardScreen();
            }
          } else {
            targetScreen = const SubscriptionPlansScreen();
          }
        } else {
          // Clear access only if both are empty
          await AccessService().updateAccess({'is_premium': false});
          targetScreen = const SubscriptionPlansScreen();
        }
       }
      }
    }

    // Ensure at least 2.8s total splash time
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 2800) {
      await Future.delayed(Duration(milliseconds: 2800 - elapsed));
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double logoSize = (screenWidth * 0.7).clamp(180.0, 300.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'assets/images/home_mandala_bg.png',
                width: screenWidth * 1.5,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, size: 80, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)!.astrologicalMath,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      "GB ASTRO",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
