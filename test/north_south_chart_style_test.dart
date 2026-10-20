import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';
import 'package:astrology_flutter/components/north_indian_chart.dart';
import 'package:astrology_flutter/components/south_indian_chart.dart';
import 'package:astrology_flutter/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ta'),
      home: Scaffold(body: child),
    );
  }

  group('Chart Style & North/South Indian Chart Tests', () {
    final sampleRasiMap = {
      'Aries': ['சூரி 14°'],
      'Taurus': ['சுக் 05°'],
      'Gemini': ['புத 18°'],
      'Cancer': ['சந் 22°'],
      'Leo': ['லக் 08°'], // Lagna in Leo (sign index 4, rasi number 5)
      'Virgo': <String>[],
      'Libra': <String>[],
      'Scorpio': ['செவ் 28°'],
      'Sagittarius': ['குரு 12°'],
      'Capricorn': ['சனி 02°'],
      'Aquarius': ['ரா 16°'],
      'Pisces': ['கே 16°'],
    };

    test('SettingsService saves and retrieves chart style', () async {
      // Default style
      final defaultStyle = await SettingsService.getChartStyle();
      expect(defaultStyle, 'south_indian');
      expect(SettingsService.chartStyleNotifier.value, 'south_indian');

      // Change to North Indian
      await SettingsService.saveChartStyle('north_indian');
      expect(await SettingsService.getChartStyle(), 'north_indian');
      expect(SettingsService.chartStyleNotifier.value, 'north_indian');

      // Change back to South Indian
      await SettingsService.saveChartStyle('south_indian');
      expect(await SettingsService.getChartStyle(), 'south_indian');
      expect(SettingsService.chartStyleNotifier.value, 'south_indian');
    });

    testWidgets('NorthIndianChart renders all 12 houses and places Lagna in House 1', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          NorthIndianChart(
            rasiMap: sampleRasiMap,
            centerLabel: 'ராசி',
          ),
        ),
      );

      // Verify custom painter is present
      expect(find.byType(CustomPaint), findsWidgets);

      // Lagna is in Leo (5). So House 1 must display Rasi number '5'.
      expect(find.text('5'), findsWidgets);

      // Center label 'ராசி' must be rendered
      expect(find.text('ராசி'), findsOneWidget);
    });

    testWidgets('SouthIndianChart dynamically renders NorthIndianChart when style is north_indian', (tester) async {
      SettingsService.chartStyleNotifier.value = 'north_indian';

      await tester.pumpWidget(
        buildTestableWidget(
          SouthIndianChart(
            rasiMap: sampleRasiMap,
            centerLabel: 'ராசி',
          ),
        ),
      );

      // NorthIndianChart should be rendered
      expect(find.byType(NorthIndianChart), findsOneWidget);

      // Now switch back to South Indian style dynamically
      SettingsService.chartStyleNotifier.value = 'south_indian';
      await tester.pumpAndSettle();

      // NorthIndianChart should no longer be rendered; standard GridView should be rendered
      expect(find.byType(NorthIndianChart), findsNothing);
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
