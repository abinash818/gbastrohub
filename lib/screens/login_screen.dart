import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/device_service.dart';
import '../services/access_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';
import 'approval_pending_screen.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final DeviceService _deviceService = DeviceService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _showEmailLogin = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        if (!mounted) return;
        
        // Check Device Status in PHP Server
        final statusData = await _deviceService.checkUserStatus(user.email!);
        final String status = statusData['status'] ?? "NOT_REGISTERED";

        if (status == 'NOT_REGISTERED' || status == 'NEW_DEVICE') {
          _showPhoneRegistrationDialog(
            user.email!, 
            status == 'NEW_DEVICE' ? AppLocalizations.of(context)!.newDeviceReg : null
          );
          return;
        }

        // Always initialize AccessService
        await AccessService().init();

        // Global App Paywall: Check Subscription
        final subStatus = await SubscriptionService().checkUserSubscription(user.uid, user.email);
        
        Map<String, dynamic> finalAccessMap = {};

        // 1. Add Admin Panel Features
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
        
        // 2. Add Subscription Features
        if (subStatus['success'] == true && subStatus['is_premium'] == true && subStatus['subscription'] != null) {
          final subscription = subStatus['subscription'];
          finalAccessMap['is_premium'] = true;
          finalAccessMap['start_date'] = subscription['start_date'];
          finalAccessMap['end_date'] = subscription['end_date'];
          finalAccessMap['last_online_check'] = DateTime.now().toIso8601String();
        }

        // 3. Decide navigation based on final access map
        bool hasAnyFeature = finalAccessMap.keys.any((key) => 
          (finalAccessMap[key] == true || finalAccessMap[key] == 1 || finalAccessMap[key] == "1") &&
          key != 'is_premium' && key != 'start_date' && key != 'end_date' && key != 'last_online_check'
        );

        if (hasAnyFeature || finalAccessMap['is_premium'] == true) {
          await AccessService().updateAccess(finalAccessMap);
          if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (subStatus['error'] == true) {
          if (AccessService().hasAccess('is_premium') || AccessService().getActiveFeatures().isNotEmpty) {
            if (AccessService().isOfflineExpired(15)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.noInternetSub),
                  duration: const Duration(seconds: 5),
                ));
                Navigator.pushReplacementNamed(context, '/subscriptions');
              }
            } else {
              if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
            }
          } else {
            if (mounted) Navigator.pushReplacementNamed(context, '/subscriptions');
          }
        } else {
          await AccessService().updateAccess({'is_premium': false});
          if (mounted) Navigator.pushReplacementNamed(context, '/subscriptions');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed or cancelled')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(label: 'Close', onPressed: () {}),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterEmailPass)),
      );
      return;
    }

    if (!_isLogin && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passNotMatch)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user;
      if (_isLogin) {
        user = await _authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        user = await _authService.registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (user != null) {
        if (!mounted) return;
        
        final statusData = await _deviceService.checkUserStatus(user.email!);
        final String status = statusData['status'] ?? "NOT_REGISTERED";

        if (status == 'LIMIT_REACHED') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(statusData['message'] ?? 'Device limit reached. Contact Admin.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ));
          return;
        }

        if (status == 'NOT_REGISTERED' || status == 'NEW_DEVICE') {
          _showPhoneRegistrationDialog(
            user.email!, 
            status == 'NEW_DEVICE' ? AppLocalizations.of(context)!.newDeviceReg : null
          );
          return;
        }

        // Always initialize AccessService
        await AccessService().init();

        // Global App Paywall: Check Subscription
        final SubscriptionService subService = SubscriptionService();
        final subStatus = await subService.checkUserSubscription(user.uid, user.email);
        
        Map<String, dynamic> finalAccessMap = {};

        // 1. Add Admin Panel Features
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
        
        // 2. Add Subscription Features
        if (subStatus['success'] == true && subStatus['is_premium'] == true && subStatus['subscription'] != null) {
          final subscription = subStatus['subscription'];
          finalAccessMap['is_premium'] = true;
          finalAccessMap['start_date'] = subscription['start_date'];
          finalAccessMap['end_date'] = subscription['end_date'];
          finalAccessMap['last_online_check'] = DateTime.now().toIso8601String();
        }

        // 3. Decide navigation based on final access map
        bool hasAnyFeature = finalAccessMap.keys.any((key) => 
          (finalAccessMap[key] == true || finalAccessMap[key] == 1 || finalAccessMap[key] == "1") &&
          key != 'is_premium' && key != 'start_date' && key != 'end_date' && key != 'last_online_check'
        );

        if (hasAnyFeature || finalAccessMap['is_premium'] == true) {
          await AccessService().updateAccess(finalAccessMap);
          if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (subStatus['error'] == true) {
          if (AccessService().hasAccess('is_premium') || AccessService().getActiveFeatures().isNotEmpty) {
            if (AccessService().isOfflineExpired(15)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.noInternetSub),
                  duration: const Duration(seconds: 5),
                ));
                Navigator.pushReplacementNamed(context, '/subscriptions');
              }
            } else {
              if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
            }
          } else {
            if (mounted) Navigator.pushReplacementNamed(context, '/subscriptions');
          }
        } else {
          await AccessService().updateAccess({'is_premium': false}); // Clear access if no subscription
          if (mounted) Navigator.pushReplacementNamed(context, '/subscriptions');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Error: $e';
        if (e.toString().contains('user-not-found') || e.toString().contains('invalid-credential') || e.toString().contains('INVALID_LOGIN_CREDENTIALS')) {
          setState(() {
            _isLogin = false;
          });
          errorMsg = AppLocalizations.of(context)!.invalidCredentials;
        }
        else if (e.toString().contains('wrong-password')) errorMsg = AppLocalizations.of(context)!.wrongPassword;
        else if (e.toString().contains('email-already-in-use')) errorMsg = AppLocalizations.of(context)!.emailInUse;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPhoneRegistrationDialog(String email, String? customMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          customMessage ?? AppLocalizations.of(context)!.registration,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              customMessage ?? AppLocalizations.of(context)!.enterMobilePrompt,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_phoneController.text.length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.enterValidMobile)),
                );
                return;
              }
              
              // Removed hardcoded backdoor to enforce secure server-side check.
              
              Navigator.pop(context); // Close dialog
              setState(() => _isLoading = true);
              
              final success = await _deviceService.requestApproval(
                email: email,
                phone: _phoneController.text,
              );
              
              setState(() => _isLoading = false);
              
              if (success && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ApprovalPendingScreen(
                    message: AppLocalizations.of(context)!.requestSent
                  )),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(AppLocalizations.of(context)!.requestApproval),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFAF6EE),
                  Colors.white,
                  Color(0xFFFAF6EE),
                ],
              ),
            ),
          ),
          
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: AppColors.primaryLight.withOpacity(0.08),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.12),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/muruga_logo.jpg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.auto_awesome, size: 70, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Title Section
                    Text(
                      AppLocalizations.of(context)!.welcome,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GB ASTRO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryLight,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5D1204).withOpacity(0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            )
                          else ...[
                            // Google Sign In Button
                            _buildGoogleButton(),
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider(thickness: 1)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(AppLocalizations.of(context)!.or, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  const Expanded(child: Divider(thickness: 1)),
                                ],
                              ),
                            ),
                            
                            // Email Login Toggle
                            GestureDetector(
                              onTap: () => setState(() => _showEmailLogin = !_showEmailLogin),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _showEmailLogin ? AppLocalizations.of(context)!.hideEmailLogin : AppLocalizations.of(context)!.loginWithEmail,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Icon(
                                    _showEmailLogin ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),

                            if (_showEmailLogin) ...[
                              const SizedBox(height: 20),
                              // Email Field
                              _buildTextField(
                                controller: _emailController,
                                hint: AppLocalizations.of(context)!.emailAddress,
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              
                               // Password Field
                               _buildTextField(
                                 controller: _passwordController,
                                 hint: AppLocalizations.of(context)!.password,
                                 icon: Icons.lock_outline_rounded,
                                 isPassword: true,
                               ),
                               if (!_isLogin) ...[
                                 const SizedBox(height: 16),
                                 _buildTextField(
                                   controller: _confirmPasswordController,
                                   hint: AppLocalizations.of(context)!.confirmPassword,
                                   icon: Icons.lock_outline_rounded,
                                   isPassword: true,
                                 ),
                               ],
                               const SizedBox(height: 24),
                              
                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: AppColors.primaryGradient,
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    border: Border.all(color: const Color(0xFFE65100), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF5D1204).withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _handleEmailAuth,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: const Color(0xFF5D1204),
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      _isLogin ? AppLocalizations.of(context)!.loginBtn : AppLocalizations.of(context)!.createAccountBtn,
                                      style: const TextStyle(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.w900, 
                                        color: Color(0xFF5D1204),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Toggle Link
                              GestureDetector(
                                onTap: () => setState(() => _isLogin = !_isLogin),
                                child: Text(
                                  _isLogin ? AppLocalizations.of(context)!.noAccountReg : AppLocalizations.of(context)!.haveAccountLogin,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    Opacity(
                      opacity: 0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security_rounded, size: 14, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.secureLogin,
                            style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.4)),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.8),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: Colors.grey.shade300, width: 1.2),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.mail_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.continueGoogle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

