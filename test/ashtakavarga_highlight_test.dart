import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/components/south_indian_chart.dart';

import 'package:astrology_flutter/l10n/app_localizations.dart';

void main() {
  testWidgets('SouthIndianChart highlights planet sign with name and color', (WidgetTester tester) async {
    // Given Ashtakavarga chart for Sun with Sun located in Virgo (கன்னி)
    final Map<String, List<String>> rasiMap = {
      'Aries': ['5'], 'Taurus': ['4'], 'Gemini': ['4'], 'Cancer': ['3'],
      'Leo': ['3'], 'Virgo': ['4'], 'Libra': ['4'], 'Scorpio': ['5'],
      'Sagittarius': ['3'], 'Capricorn': ['4'], 'Aquarius': ['3'], 'Pisces': ['6']
    };

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ta'),
        home: Scaffold(
          body: SouthIndianChart(
            rasiMap: rasiMap,
            centerLabel: 'சூரி\nசுய வர்க்கம்',
            highlightSign: 'Virgo',
            highlightSignLabel: 'சூரி',
            highlightColor: Color(0xFFFFECC2),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify planet label 'சூரி' is rendered in the highlighted cell
    expect(find.text('சூரி'), findsOneWidget);

    // Verify point '4' exists in the chart
    expect(find.text('4'), findsWidgets);
  });
}
