import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../screens/input_screen.dart';
import '../screens/jamakkol_input_screen.dart';
import '../services/access_service.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: const Color(0xFFFCF9F2),
      child: Column(
        children: [
          // ── Premium Gradient Header ──────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5D1204), Color(0xFF8B1E0F), Color(0xFFB58D3D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 52,
                          width: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.auto_awesome, color: Color(0xFFB58D3D), size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'GB ASTRO',
                            style: GoogleFonts.cinzel(
                              color: const Color(0xFFFFE082),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ஜோதிட மென்பொருள்',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Modern Navigation List ──────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: 'முகப்பு',
                  subtitle: 'Dashboard',
                  routeName: '/dashboard',
                  isSelected: currentRoute == '/dashboard',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFFE11D48),
                  title: 'ஜாதகம்',
                  subtitle: 'Horoscope Chart',
                  routeName: '/horoscope_input',
                  isSelected: currentRoute == '/horoscope_input',
                  featureKey: 'ஜாதகம்',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFEC4899),
                  title: 'திருமணப் பொருத்தம்',
                  subtitle: 'Marriage Matching',
                  routeName: '/marriage_matching',
                  isSelected: currentRoute == '/marriage_matching',
                  featureKey: 'பொருத்தம்',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.wb_sunny_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: 'பஞ்சாங்கம்',
                  subtitle: 'Daily Panchangam',
                  routeName: '/panchangam',
                  isSelected: currentRoute == '/panchangam',
                  featureKey: 'பஞ்சாங்கம்',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.pin_rounded,
                  iconColor: const Color(0xFF0284C7),
                  title: 'எண் கணிதம்',
                  subtitle: 'Numerology',
                  routeName: '/numerology_input',
                  isSelected: currentRoute == '/numerology_input',
                  featureKey: 'எண் கணிதம்',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.explore_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'ஜாமக்கோள் பிரசன்னம்',
                  subtitle: 'Jamakkol Prasannam',
                  routeName: '/jamakkol_input',
                  isSelected: currentRoute == '/jamakkol_input',
                  featureKey: 'ஜாமக்கோள்',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.foundation_rounded,
                  iconColor: const Color(0xFFB45309),
                  title: 'வாஸ்து',
                  subtitle: 'மனை அடி சாஸ்திரம் (Kuzhikanakku)',
                  routeName: '/vaasthu',
                  isSelected: currentRoute == '/vaasthu',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.auto_fix_high_rounded,
                  iconColor: const Color(0xFF059669),
                  title: 'ஜோதிடக் கருவிகள்',
                  subtitle: 'Astro Tools (நாழிகை, பஞ்ச பட்சி)',
                  routeName: '/astro_tools',
                  isSelected: currentRoute == '/astro_tools',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.bookmark_added_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  title: 'சேமித்த ஜாதகங்கள்',
                  subtitle: 'Saved Horoscopes',
                  routeName: '/saved_horoscopes',
                  isSelected: currentRoute == '/saved_horoscopes',
                ),
                const SizedBox(height: 5),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_suggest_rounded,
                  iconColor: const Color(0xFF6B7280),
                  title: 'அமைப்புகள்',
                  subtitle: 'Settings & Ayanamsa',
                  routeName: '/settings',
                  isSelected: currentRoute == '/settings',
                ),
              ],
            ),
          ),

          // ── Bottom Logout & Version Bar with SafeArea ───────────────────────
          SafeArea(
            top: false,
            bottom: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final nav = Navigator.of(context);
                        Navigator.pop(context); // Close drawer
                        await AuthService().signOut();
                        nav.pushNamedAndRemoveUntil('/login', (route) => false);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              l10n.logout,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String routeName,
    required bool isSelected,
    bool isKp = false,
    bool isNadi = false,
    String? featureKey,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (featureKey != null && !AccessService().hasAccess(featureKey)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.accessDenied)),
            );
            return;
          }

          final double screenWidth = MediaQuery.of(context).size.width;
          final bool isWide = screenWidth > 900;

          if (!isWide && Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context); // Close drawer
          }

          if (isWide && (routeName == '/horoscope_input' || routeName == '/nadi')) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => InputScreen(
                isPopup: true,
                isKp: isKp,
                isNadi: isNadi,
                onCompleted: (results) {
                  Navigator.pop(context);
                  if (isNadi) {
                    Navigator.pushNamed(context, '/nadi_results', arguments: results);
                  } else {
                    Navigator.pushNamed(context, '/workspace', arguments: results);
                  }
                },
              ),
            );
          } else if (isWide && routeName == '/jamakkol_input') {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const JamakkolInputScreen(isPopup: true),
            );
          } else if (!isSelected) {
            if (routeName == '/dashboard') {
              Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
            } else {
              Map<String, dynamic>? args;
              if (isKp) args = {'isKp': true};
              if (isNadi) args = {'isNadi': true};

              Navigator.pushNamedAndRemoveUntil(
                context,
                routeName,
                (route) => route.settings.name == '/dashboard' || route.isFirst,
                arguments: args,
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5D1204).withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFB58D3D)
                  : Colors.grey.shade200,
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFB58D3D).withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5D1204)
                      : iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? const Color(0xFFFFE082) : iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        fontSize: 14,
                        color: isSelected ? const Color(0xFF5D1204) : const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: isSelected
                            ? const Color(0xFFB58D3D)
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isSelected ? const Color(0xFF5D1204) : Colors.grey.shade300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
