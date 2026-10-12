import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astrology_flutter/screens/numerology_input_screen.dart';

void main() {
  testWidgets('NumerologyInputScreen tab switching and vehicle calculation test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ta'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [
          Locale('ta'),
          Locale('en'),
        ],
        home: NumerologyInputScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Tab headers exist
    expect(find.text('பெயர் & பிறந்த தேதி'), findsOneWidget);
    expect(find.text('வாகனம் & மொபைல்'), findsOneWidget);

    // Tap on Vehicle & Mobile tab
    await tester.tap(find.text('வாகனம் & மொபைல்'));
    await tester.pumpAndSettle();

    // Verify Vehicle & Mobile input field is present
    expect(find.text('வாகனம் அல்லது மொபைல் எண்ணை உள்ளிடவும்'), findsOneWidget);

    // Enter vehicle number "TN 76 K 5406"
    final inputField = find.byType(TextFormField).first;
    await tester.enterText(inputField, 'TN 76 K 5406');
    await tester.pumpAndSettle();

    // Compound number for TN 76 K 5406 is 39
    expect(find.text('39'), findsOneWidget);
    // Root number for 39 is 3
    expect(find.text('3'), findsWidgets);

    // Verify Pyramid header is present
    expect(find.text('வாகனம் / மொபைல் பிரமிடு'), findsOneWidget);
    // Verify peak is 7
    expect(find.textContaining('பிரமிடு உச்ச எண்: 7'), findsOneWidget);
  });
}
