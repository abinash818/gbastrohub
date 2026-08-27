import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/input_screen.dart';
import 'screens/horoscope_results_screen.dart';
import 'screens/marriage_matching_input_screen.dart';
import 'screens/numerology_input_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/subscription_plans_screen.dart';
import 'screens/saved_horoscopes_screen.dart';
import 'screens/jamakkol_screen.dart';
import 'screens/jamakkol_input_screen.dart';
import 'screens/horoscope_workspace_screen.dart';
import 'screens/login_screen.dart';
import 'services/kp_service.dart';
import 'services/settings_service.dart';
import 'theme/app_colors.dart';

final ValueNotifier<double> appFontScaleNotifier = ValueNotifier<double>(1.0);
final ValueNotifier<Locale> appLocaleNotifier = ValueNotifier<Locale>(const Locale('ta'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init skipped/failed: $e");
  }
  final double initialFontScale = await SettingsService.getFontSize();
  appFontScaleNotifier.value = initialFontScale;
  final String initialLang = await SettingsService.getLanguage();
  appLocaleNotifier.value = Locale(initialLang);
  runApp(const AstrologyApp());
}

class AstrologyApp extends StatelessWidget {
  const AstrologyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: appFontScaleNotifier,
      builder: (context, fontScale, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: appLocaleNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              builder: (context, child) {
                if (child == null) return const SizedBox.shrink();
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(fontScale)),
                  child: child,
                );
              },
              title: 'GB Astro',
              locale: locale,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('ta', ''),
                Locale('hi', ''),
              ],
              debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: AppColors.primary),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/horoscope_input': (context) => const InputScreen(),
        '/marriage_matching': (context) => const MarriageMatchingInputScreen(),
        '/numerology_input': (context) => const NumerologyInputScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/subscriptions': (context) => const SubscriptionPlansScreen(),
        '/saved_horoscopes': (context) => const SavedHoroscopesScreen(),
        '/jamakkol': (context) => const JamakkolScreen(),
        '/jamakkol_input': (context) => const JamakkolInputScreen(),
        '/login': (context) => const LoginScreen(),
        '/workspace': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return HoroscopeWorkspaceScreen(initialJathagamData: args ?? {});
        },
      },
      // Using a wrapper logic for calculation
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null) {
            return MaterialPageRoute(builder: (context) => const DashboardScreen());
          }
          return MaterialPageRoute(
            builder: (context) => HoroscopeResultsScreen(results: args, name: args['name'] ?? 'User'),
          );
        }
          return null;
        },
      );
      },
    );
  });
}
}

/// This is a helper to wrap the calculation logic so it can be called from InputScreen
class AppNavigator {
  static Future<void> calculateAndNavigate(
    BuildContext context, 
    Map<String, dynamic> inputs, {
    bool isKp = false, 
    void Function(Map<String, dynamic>)? onCompleted,
  }) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      // Ensure date is a DateTime (if it comes from saved history, it might be a String)
      dynamic birthDate = inputs['date'];
      if (birthDate is String) {
        birthDate = DateTime.parse(birthDate);
      }

      final double yearLength = await SettingsService.getDasaYearLength();
      final int siderealMode = await SettingsService.getAyanamsa();

      final results = await KPService.calculateChart(
        inputs['name'],
        birthDate as DateTime,
        inputs['latitude'] ?? 13.0827,
        inputs['longitude'] ?? 80.2707,
        (inputs['timezone'] == null || inputs['timezone'] == 0) ? 5.5 : inputs['timezone'],
        yearLength: yearLength,
        siderealModeIndex: siderealMode,
      );

       // Add extra metadata for UI
      results['name'] = inputs['name'];
      results['gender'] = inputs['gender'];
      results['place'] = inputs['place'];
      results['birth_dt'] = birthDate;
      results['lat'] = inputs['latitude'].toString();
      results['lon'] = inputs['longitude'].toString();
      results['isKp'] = isKp;

      if (!context.mounted) return;
      Navigator.pop(context); // Remove loading
      
      if (onCompleted != null) {
        onCompleted(results);
      } else {
        Navigator.pushNamed(context, '/home', arguments: results);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Remove loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('கணிப்பதில் பிழை: $e')),
      );
    }
  }
}
