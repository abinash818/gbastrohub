import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/screens/gp_vaasthu_screen.dart';
import 'package:astrology_flutter/services/gp_vaasthu_service.dart';

void main() {
  test('Direct Ayadi parameter calculation test', () {
    final result = GpVaasthuService.calculateKuzhi(
      region: GpVaasthuRegion.madurai,
      l1Ft: 0,
      l1In: 0,
      w1Ft: 0,
      w1In: 0,
      directAyadi: 1763,
      ownerNakshatra: 1,
      ownerRasi: 1,
    );

    expect(result.roundedAyadi, 1763);
    expect(result.garbhamNumber, 3); // 1763 % 8 = 3 (சிம்மம்)
    expect(result.garbham.name, contains('சிம்மம்'));
    expect(result.aadhayamNumber, 4); // (1763 * 8) % 12 = 4
    expect(result.virayamNumber, 7); // (1763 * 3) % 8 = 7
  });

  testWidgets('GpVaasthuScreen direct ayadi mode toggle test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GpVaasthuScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify exactly 2 segmented mode buttons: 'வெளிப்புற சுற்றளவு' and 'நேரடி ஆயாதி எண்'
    expect(find.text('வெளிப்புற சுற்றளவு'), findsOneWidget);
    expect(find.text('நேரடி ஆயாதி எண்'), findsOneWidget);
    expect(find.text('4 பக்கங்கள்'), findsNothing);

    final modeButton = find.text('நேரடி ஆயாதி எண்');
    await tester.ensureVisible(modeButton);
    await tester.pumpAndSettle();

    // Tap 'நேரடி ஆயாதி எண்'
    await tester.tap(modeButton);
    await tester.pumpAndSettle();

    // Verify Direct Ayadi input card is now visible
    expect(find.text('நேரடி ஆயாதி எண் உள்ளீடு:'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.text('-1'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
    expect(find.text('-10'), findsOneWidget);

    // Tap +1 button
    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();

    // Check that Ayadi Number updated to 1764
    expect(find.text('1764'), findsWidgets);
  });
}
