import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/screens/gp_vaasthu_screen.dart';

void main() {
  testWidgets('Thithi and Bootham dual methods display and modal dialog test', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: GpVaasthuScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Check that '2 முறை' badges are visible for Thithi and Bootham
    expect(find.text('2 முறை'), findsNWidgets(2));

    // Tap on Thithi row / '2 முறை' badge
    await tester.tap(find.text('2 முறை').first);
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.textContaining('திதி - இரு முறைகள் ஒப்பீடு'), findsOneWidget);
    expect(find.textContaining('முதல் மரபு'), findsOneWidget);
    expect(find.textContaining('இரண்டாவது மரபு'), findsOneWidget);
    expect(find.text('சரி (சரிபார்க்கப்பட்டது)'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('சரி (சரிபார்க்கப்பட்டது)'));
    await tester.pumpAndSettle();

    // Now tap on Bootham '2 முறை' badge
    await tester.tap(find.text('2 முறை').last);
    await tester.pumpAndSettle();

    // Verify Bootham dialog opened
    expect(find.textContaining('பூதம் - இரு முறைகள் ஒப்பீடு'), findsOneWidget);
    expect(find.textContaining('முறை 1 (ஆயாதி × 3)'), findsOneWidget);
    expect(find.textContaining('முறை 2 (ஆயாதி × 9)'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('சரி (சரிபார்க்கப்பட்டது)'));
    await tester.pumpAndSettle();
  });
}
