import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../screens/input_screen.dart';
import '../screens/jamakkol_input_screen.dart';
import '../services/access_service.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      backgroundColor: AppColors.background, // Match cream background
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 2),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png', 
                        height: 80, 
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.auto_awesome, color: AppColors.primary, size: 50)
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'GB ASTRO',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      color: AppColors.primary, // Dark maroon for gold background contrast
                      fontSize: 15, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 1
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildGridItem(context, Icons.dashboard_rounded, AppLocalizations.of(context)!.dashboard, '/dashboard', currentRoute == '/dashboard'),
                _buildGridItem(context, Icons.history_edu_rounded, AppLocalizations.of(context)!.horoscope, '/horoscope_input', currentRoute == '/horoscope_input', featureKey: 'ஜாதகம்'),
                _buildGridItem(context, Icons.favorite_rounded, AppLocalizations.of(context)!.marriageMatching, '/marriage_matching', currentRoute == '/marriage_matching', featureKey: 'பொருத்தம்'),
                _buildGridItem(context, Icons.grid_3x3_rounded, AppLocalizations.of(context)!.numerology, '/numerology_input', currentRoute == '/numerology_input', featureKey: 'எண் கணிதம்'),
                _buildGridItem(context, Icons.explore_rounded, AppLocalizations.of(context)!.jamakkol, '/jamakkol_input', currentRoute == '/jamakkol_input', featureKey: 'ஜாமக்கோள்'),
                _buildGridItem(context, Icons.save_rounded, AppLocalizations.of(context)!.savedHoroscopes, '/saved_horoscopes', currentRoute == '/saved_horoscopes'),
                _buildGridItem(context, Icons.settings_outlined, AppLocalizations.of(context)!.settingsTitle, '/settings', currentRoute == '/settings'),
                
                // Logout Button
                InkWell(
                  onTap: () async {
                    final nav = Navigator.of(context);
                    Navigator.pop(context); // Close drawer
                    await AuthService().signOut();
                    nav.pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.logout,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.redAccent, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String title, String routeName, bool isSelected, {bool isKp = false, bool isNadi = false, String? featureKey}) {
    return InkWell(
      onTap: () {
        if (featureKey != null && !AccessService().hasAccess(featureKey)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.accessDenied)));
          return;
        }

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isWide = screenWidth > 900;
        
        if (!isWide && Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context); // Close drawer only if it's actually a modal drawer
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
            // Keep dashboard in stack
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.5) : const Color(0xFFB58D3D).withOpacity(0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected ? [] : [
            BoxShadow(
              color: const Color(0xFF5D1204).withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey.shade700, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 12,
                color: isSelected ? AppColors.primary : Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
