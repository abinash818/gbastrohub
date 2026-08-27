import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/custom_drawer.dart';
import '../theme/app_colors.dart';
import '../services/access_service.dart';
import 'live_dashboard_screen.dart';
import 'input_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'jamakkol_input_screen.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;
    
    if (isWide) {
      return const LiveDashboardScreen();
    }
    
    int getCrossAxisCount(double width) {
      if (width > 1200) return 4;
      if (width > 800) return 3;
      return 3;
    }
    
    double getMaxWidth(double width) {
      if (width > 1200) return 1000;
      if (width > 800) return 800;
      return 600;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE), // Premium light warm cream background
      drawer: isWide ? null : const CustomDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide)
              const SizedBox(
                width: 280,
                child: CustomDrawer(),
              ),
            Expanded(
              child: Stack(
                children: [
            if (!isWide)
              // Floating Hamburger Menu Button
              Positioned(
                top: 8,
                left: 8,
                child: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded, 
                      color: Color(0xFF5D1204), 
                      size: 30
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
            
            // Main Dashboard Body
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: getMaxWidth(screenWidth)),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      

                      
                      // 2. Middle Row: Title (Left & Right Logos Removed)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Text(
                                '⪥⪥⪥⪥⪥⪥⪥⪥',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFB58D3D), 
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'GB ASTRO',
                                style: GoogleFonts.cinzel(
                                  color: const Color(0xFF5D1204),
                                  fontSize: screenWidth < 360 ? 20 : 23,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '⪥⪥⪥⪥⪥⪥⪥⪥',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFFB58D3D), 
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // 3. Grid of 10 Buttons
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: getCrossAxisCount(screenWidth),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: screenWidth > 800 ? 1.25 : 1.15,
                        children: [
                          _buildPremiumButton(
                            context, 
                            AppLocalizations.of(context)!.horoscope.split('\n')[0], 
                            "பிறப்பு ஜாதகத்தை கணித்து பார்க்கவும்",
                            "assets/images/jathagam_planet.png",
                            '/horoscope_input', 
                            featureKey: 'can_view_jathagam'
                          ),
                          _buildPremiumButton(
                            context, 
                            AppLocalizations.of(context)!.marriageMatching.split('\n')[0], 
                            "திருமண பொருத்தத்தை பார்க்கவும்",
                            "assets/images/marriage_planet.png",
                            '/marriage_matching', 
                            featureKey: 'can_view_matching'
                          ),
                          _buildPremiumButton(
                            context, 
                            AppLocalizations.of(context)!.jamakkol.split('\n')[0], 
                            "ஜாமக்கோள் கணிதம் மற்றும் பலன்கள்",
                            "assets/images/jamakkol_planet.png",
                            '/jamakkol_input', 
                            featureKey: 'can_view_jamakkol'
                          ),
                          _buildPremiumButton(
                            context, 
                            AppLocalizations.of(context)!.numerology.split('\n')[0], 
                            "பெயர் மற்றும் எண் கணித பலன்களை அறியவும்",
                            "assets/images/numerology_planet.png",
                            '/numerology_input', 
                            featureKey: 'can_view_numerology'
                          ),
                          _buildPremiumButton(
                            context, 
                            AppLocalizations.of(context)!.aboutUs, 
                            "GB ASTRO பற்றி மற்றும் எங்கள் சேவைகள்",
                            "assets/images/about_planet.png",
                            null, 
                            isAboutTrigger: true
                          ),
                          _buildPremiumButton(
                            context, 
                            AppLocalizations.of(context)!.settingsTitle, 
                            "கணக்கு, மொழி மற்றும் பயன்பாட்டு அமைப்புகள்",
                            "assets/images/settings_planet.png",
                            '/settings'
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premium Grid Button Builder using Planet Images
  Widget _buildPremiumButton(
    BuildContext context, 
    String title, 
    String subtitle,
    String imagePath, 
    String? route, 
    {bool isKp = false, bool isNadi = false, bool isAboutTrigger = false, String? featureKey}
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFB58D3D).withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isAboutTrigger) {
                _showAboutUsDialog(context);
                return;
              }
              if (featureKey != null && !AccessService().hasAccess(featureKey)) {
                _showAccessDeniedDialog(context, title);
                return;
              }
              if (route != null) {
                final double screenWidth = MediaQuery.of(context).size.width;
                final bool isDesktop = Theme.of(context).platform == TargetPlatform.windows || 
                                       Theme.of(context).platform == TargetPlatform.macOS || 
                                       Theme.of(context).platform == TargetPlatform.linux || 
                                       screenWidth > 900;
                
                if (isDesktop && (route == '/horoscope_input' || route == '/nadi')) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => InputScreen(
                      isPopup: true,
                      isKp: isKp,
                      isNadi: isNadi,
                      onCompleted: (results) {
                        Navigator.pop(context); // Close the popup dialog
                        if (isNadi) {
                          Navigator.pushNamed(context, '/nadi_results', arguments: results);
                        } else {
                          Navigator.pushNamed(context, '/workspace', arguments: results);
                        }
                      },
                    ),
                  );
                } else if (isDesktop && route == '/jamakkol_input') {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const JamakkolInputScreen(isPopup: true),
                  );
                } else {
                  Map<String, dynamic> args = {};
                  if (isKp) args['isKp'] = true;
                  if (isNadi) args['isNadi'] = true;
                  Navigator.pushNamed(context, route, arguments: args);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title - ${AppLocalizations.of(context)!.comingSoon}')),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Planet Image
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      color: const Color(0xFFFAF6EE),
                      colorBlendMode: BlendMode.multiply,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF5D1204), // Dark maroon text
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Premium About Us Dialog
  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6EE),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', height: 80),
              const SizedBox(height: 16),
              Text(
                'GB ASTRO',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF5D1204),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.aadhiguruSchool,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB58D3D),
                ),
              ),
              const Divider(color: Color(0xFFB58D3D), height: 30, thickness: 1),
              Text(
                AppLocalizations.of(context)!.aadhiguruDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5D1204),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D1204),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.close, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Access Denied Dialog
  void _showAccessDeniedDialog(BuildContext context, String serviceName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF6EE),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 60, color: Color(0xFF5D1204)),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D1204),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.accessDeniedSub(serviceName),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF5D1204),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  final String adminWhatsAppNumber = '919600666225';
                  final encodedText = Uri.encodeComponent(AppLocalizations.of(context)!.whatsappMsg(serviceName));
                  final url = Uri.parse('https://wa.me/$adminWhatsAppNumber?text=$encodedText');
                  
                  Navigator.pop(context);
                  
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint('Could not launch WhatsApp: $e');
                  }
                },
                icon: const Icon(Icons.message_rounded, color: Colors.white, size: 20),
                label: Text(
                  AppLocalizations.of(context)!.whatsappAdmin, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.close, style: const TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
