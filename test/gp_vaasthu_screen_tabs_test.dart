import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/screens/gp_vaasthu_screen.dart';

void main() {
  testWidgets('GpVaasthuScreen displays all 3 tabs and renders correctly', (WidgetTester tester) async {
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

    expect(find.text('26 பொருத்தங்கள்'), findsOneWidget);
    expect(find.text('தலைவாசல் கணிதம்'), findsOneWidget);
    expect(find.text('வாஸ்து பூஜை நாள்'), findsOneWidget);

    // Tap on the 3rd tab
    await tester.tap(find.text('வாஸ்து பூஜை நாள்'));
    await tester.pumpAndSettle();

    // Verify Vaasthu Pooja content is displayed
    expect(find.textContaining('வாஸ்து / பூமி பூஜை நாள் & நேரம்'), findsWidgets);
    expect(find.textContaining('உதாரணக் கணக்கீடு'), findsOneWidget);
    expect(find.textContaining('8:08:26 AM'), findsWidgets);
    expect(find.textContaining('8:26:26 AM'), findsWidgets);
  });
}
