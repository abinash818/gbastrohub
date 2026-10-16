import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/widgets/thalaivaasal_vaasthu_view.dart';

void main() {
  testWidgets('ThalaivaasalVaasthuView renders and calculates correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ThalaivaasalVaasthuView(
            initialFeet: 17.0,
            initialInches: 0.0,
          ),
        ),
      ),
    );

    // Initial render pump
    await tester.pumpAndSettle();

    // Verify key titles and texts from prompt
    expect(find.text('கட்டிடத்தின் தலைவாசல் (நிலை) வைக்கும் பகுதி'), findsOneWidget);
    expect(find.text('1. கட்டிடத்தின் திசை தேர்ந்தெடுக்கவும்:'), findsOneWidget);
    expect(find.text('2. தலைவாசல் சுவரின் மொத்த அளவு:'), findsOneWidget);
    expect(find.text('உத்தம பலன் (தலைவாசல் நிலை வைக்கும் இடம்)'), findsOneWidget);

    // Verify the math result for 17 feet
    // Start: 5 அடி 8 அங், End: 7 அடி 7 அங்
    expect(find.textContaining('5 அடி 8 அங்'), findsWidgets);
    expect(find.textContaining('7 அடி 7 அங்'), findsWidgets);
  });
}
