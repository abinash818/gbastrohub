import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/widgets/vaasthu_pooja_view.dart';

void main() {
  testWidgets('VaasthuPoojaView renders with Coimbatore on 360 width without overflow', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(320, 800);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VaasthuPoojaView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Select Coimbatore from dropdown
    await tester.tap(find.text('நாமக்கல்'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('கோயம்புத்தூர்').last);
    await tester.pumpAndSettle();

    // Verify Coimbatore is selected and displayed
    expect(find.text('கோயம்புத்தூர்'), findsWidgets);
    expect(find.textContaining('8:08:26 AM'), findsWidgets);
    expect(find.textContaining('8:26:26 AM'), findsWidgets);
  });
}
