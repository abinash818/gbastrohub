import 'package:flutter_test/flutter_test.dart';
import '../lib/services/numerology_service.dart';

void main() {
  group('Vehicle and Mobile Numerology Tests', () {
    test('TN76K5406 Chaldean calculations', () {
      // T=4, N=5, 7=7, 6=6, K=2, 5=5, 4=4, 0=0, 6=6
      // Sum = 4+5+7+6+2+5+4+0+6 = 39
      final compound = NumerologyService.calculateAlphanumericCompoundNumber('TN76K5406');
      expect(compound, 39);

      // Root of 39: 3+9 = 12 -> 1+2 = 3
      final root = NumerologyService.calculateAlphanumericRootNumber('TN76K5406');
      expect(root, 3);

      final breakdown = NumerologyService.getCharacterBreakdown('TN 76 K 5406');
      expect(breakdown.map((e) => e['char']).join(''), 'TN76K5406');
      expect(breakdown.map((e) => e['value']).toList(), [4, 5, 7, 6, 2, 5, 4, 0, 6]);

      final pyramid = NumerologyService.calculateAlphanumericPyramidData('TN 76 K 5406');
      expect(pyramid.first, [4, 5, 7, 6, 2, 5, 4, 0, 6]);
      // Length of pyramid rows: 9 -> 8 -> 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 (9 rows total)
      expect(pyramid.length, 9);
      expect(pyramid.last.length, 1);
      print('TN76K5406 Pyramid:');
      for (var row in pyramid) {
        print(row);
      }
      print('Peak number: ${pyramid.last.first}');
      expect(NumerologyService.formatPyramidResult(pyramid), '52 = 7');
    });

    test('Mobile 9876543210 calculations', () {
      // 9+8+7+6+5+4+3+2+1+0 = 45
      final compound = NumerologyService.calculateAlphanumericCompoundNumber('9876543210');
      expect(compound, 45);

      // Root of 45: 4+5 = 9
      final root = NumerologyService.calculateAlphanumericRootNumber('9876543210');
      expect(root, 9);

      final pyramid = NumerologyService.calculateAlphanumericPyramidData('9876543210');
      expect(pyramid.first, [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]);
      expect(pyramid.length, 10);
      expect(pyramid.last.length, 1);
      print('9876543210 Pyramid peak: ${pyramid.last.first}');
    });

    test('GBASTRO Screenshot Pyramid and format test', () {
      final pyramid = NumerologyService.calculateAlphanumericPyramidData('GBASTRO');
      expect(pyramid.first, [3, 2, 1, 3, 4, 2, 7]);
      expect(pyramid[pyramid.length - 2], [3, 4]);
      expect(pyramid.last, [7]);
      expect(NumerologyService.formatPyramidResult(pyramid), '34 = 7');
    });

    test('DOB Pyramid test', () {
      final dob = DateTime(2026, 10, 21);
      final pyramid = NumerologyService.calculateDobPyramidData(dob);
      expect(pyramid.first, [2, 1, 1, 0, 2, 0, 2, 6]);
      expect(pyramid.last.first, 3);
      expect(NumerologyService.formatPyramidResult(pyramid), '12 = 3');
    });
  });
}
