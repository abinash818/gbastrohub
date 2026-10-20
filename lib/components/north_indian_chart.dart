import 'package:flutter/material.dart';
import '../services/astro_translation_service.dart';

const List<String> NORTH_INDIAN_SIGNS = [
  "Aries", "Taurus", "Gemini", "Cancer",
  "Leo", "Virgo", "Libra", "Scorpio",
  "Sagittarius", "Capricorn", "Aquarius", "Pisces"
];

class NorthIndianChart extends StatelessWidget {
  final Map<String, List<String>> rasiMap;
  final String? centerLabel;
  final Widget? centerWidget;
  final String? highlightSign;
  final String? highlightSignLabel;
  final Color? highlightColor;
  final bool allowScroll;
  final double heightRatio;

  const NorthIndianChart({
    super.key,
    required this.rasiMap,
    this.centerLabel,
    this.centerWidget,
    this.highlightSign,
    this.highlightSignLabel,
    this.highlightColor,
    this.allowScroll = true,
    this.heightRatio = 1.0,
  });

  static double? _extractDegree(String str) {
    final m1 = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(str);
    if (m1 != null) {
      return int.parse(m1.group(1)!) + int.parse(m1.group(2)!) / 60.0;
    }
    final m2 = RegExp(r'(\d{1,2})°\s*(\d{1,2})').firstMatch(str);
    if (m2 != null) {
      return int.parse(m2.group(1)!) + int.parse(m2.group(2)!) / 60.0;
    }
    return null;
  }

  static List<String> sortItemsByDegree(List<String> items) {
    if (items.length <= 1) return items;
    if (items.any((e) => _extractDegree(e) != null)) {
      final sorted = List<String>.from(items);
      sorted.sort((a, b) {
        final degA = _extractDegree(a) ?? 999.0;
        final degB = _extractDegree(b) ?? 999.0;
        return degA.compareTo(degB);
      });
      return sorted;
    }
    return items;
  }

  int _findLagnaSignIndex() {
    for (final entry in rasiMap.entries) {
      if (entry.value.any((it) =>
          it.startsWith("லக்") ||
          it.startsWith("உத") ||
          it.startsWith("Asc") ||
          it.startsWith("Lagna") ||
          it.startsWith("Uda") ||
          it.startsWith("लग्न") ||
          it.startsWith("उदय"))) {
        final idx = NORTH_INDIAN_SIGNS.indexWhere(
            (s) => s.toLowerCase() == entry.key.trim().toLowerCase());
        if (idx != -1) return idx;
      }
    }
    return 0; // Default to Aries if no Lagna found
  }

  @override
  Widget build(BuildContext context) {
    final lagnaIdx = _findLagnaSignIndex();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double size = constraints.maxWidth;
            final double height = size * heightRatio;

            // Map house 1..12 to its sign name and 1-based Rasi number
            final Map<int, String> houseSigns = {};
            final Map<int, int> houseRasiNumbers = {};
            final Map<int, Color> houseHighlights = {};

            for (int h = 1; h <= 12; h++) {
              final signIdx = (lagnaIdx + (h - 1)) % 12;
              final signName = NORTH_INDIAN_SIGNS[signIdx];
              houseSigns[h] = signName;
              houseRasiNumbers[h] = signIdx + 1; // 1 to 12

              if (highlightSign != null &&
                  signName.toLowerCase() == highlightSign!.toLowerCase()) {
                houseHighlights[h] =
                    highlightColor ?? const Color(0xFFFFECC2);
              }
            }

            return Container(
              width: size,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // 1. Custom painter for North Indian diamond chart grid lines & highlights
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _NorthIndianChartPainter(
                          borderColor: Colors.orange.shade800,
                          borderWidth: 2.0,
                          houseHighlights: houseHighlights,
                        ),
                      ),
                    ),

                    // 2. Content for each of the 12 houses
                    for (int h = 1; h <= 12; h++)
                      _buildHouseContent(
                        context: context,
                        house: h,
                        signName: houseSigns[h]!,
                        rasiNumber: houseRasiNumbers[h]!,
                        w: size,
                        h: height,
                        isHighlighted: houseHighlights.containsKey(h),
                      ),

                    // 3. Center Label (e.g. "ராசி", "நவாம்சம்")
                    if (centerWidget != null)
                      Positioned(
                        left: size * 0.5,
                        top: height * 0.5,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -0.5),
                          child: centerWidget!,
                        ),
                      )
                    else if (centerLabel != null && centerLabel!.isNotEmpty)
                      Positioned(
                        left: size * 0.5,
                        top: height * 0.5,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, -0.5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF6EE),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFB58D3D), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              AstroTranslationService.translate(
                                  context, centerLabel!),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D1204),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHouseContent({
    required BuildContext context,
    required int house,
    required String signName,
    required int rasiNumber,
    required double w,
    required double h,
    required bool isHighlighted,
  }) {
    final rawItems = rasiMap[signName] ?? [];
    final items = sortItemsByDegree(rawItems);
    final bounds = _getHouseContentBounds(house, w, h);
    final rasiNumPos = _getRasiNumberPosition(house, w, h);

    final bool isSingleNumber =
        items.length == 1 && int.tryParse(items.first.trim()) != null;

    return Stack(
      children: [
        // Rasi Number Badge in the corner
        Positioned(
          left: rasiNumPos.dx,
          top: rasiNumPos.dy,
          child: FractionalTranslation(
            translation: const Offset(-0.5, -0.5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.orange.shade50.withOpacity(0.85),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: Colors.orange.shade300.withOpacity(0.5), width: 0.8),
              ),
              child: Text(
                "$rasiNumber",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.brown.shade800,
                ),
              ),
            ),
          ),
        ),

        // Planet Items inside the House
        Positioned(
          left: bounds.left,
          top: bounds.top,
          width: bounds.width,
          height: bounds.height,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: isSingleNumber
                  ? _buildSingleNumberContent(items.first.trim(), isHighlighted)
                  : _buildPlanetListContent(context, items),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleNumberContent(String numStr, bool isHighlighted) {
    if (highlightSignLabel != null && isHighlighted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFF5D1204),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              highlightSignLabel!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            numStr,
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5D1204),
            ),
          ),
        ],
      );
    }
    return Text(
      numStr,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w900,
        color: isHighlighted ? const Color(0xFF5D1204) : Colors.indigo.shade900,
      ),
    );
  }

  Widget _buildPlanetListContent(BuildContext context, List<String> items) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: items.map((it) {
        bool isLagna = it.startsWith("லக்") ||
            it.startsWith("உத") ||
            it.startsWith("Asc") ||
            it.startsWith("Lagna") ||
            it.startsWith("Uda") ||
            it.startsWith("लग्न") ||
            it.startsWith("उदय");
        bool isArudam =
            it.startsWith("ஆரூ") || it.startsWith("Aru") || it.startsWith("आरू");
        bool isKavi =
            it.startsWith("கவி") || it.startsWith("Kav") || it.startsWith("कवि");
        bool isYama =
            it.startsWith("எம") || it.startsWith("Yama") || it.startsWith("यम");
        bool isMrityu =
            it.startsWith("மிரு") || it.startsWith("Mri") || it.startsWith("मृ");
        bool isRahuClockwise = (it.startsWith("ரா") && !it.startsWith("ராகு")) ||
            (it.startsWith("रा") && !it.startsWith("राहु")) ||
            (it.startsWith("Rah") && !it.startsWith("Rahu"));
        bool isSubPlanet = isYama || isMrityu || isRahuClockwise;
        bool isMaanthi = it.startsWith("மாந்") ||
            it.startsWith("மாந்தி") ||
            it.startsWith("Maanthi") ||
            it.startsWith("Mn") ||
            it.startsWith("मां");
        bool isSpecial = isLagna || isArudam || isKavi || isSubPlanet || isMaanthi;

        Color highlightColor = Colors.transparent;
        if (isLagna) {
          highlightColor = Colors.green.shade700;
        } else if (isArudam) {
          highlightColor = Colors.blue.shade800;
        } else if (isKavi) {
          highlightColor = Colors.red.shade800;
        } else if (isRahuClockwise) {
          highlightColor = Colors.purple.shade700;
        } else if (isYama) {
          highlightColor = const Color(0xFFFFB300);
        } else if (isMrityu) {
          highlightColor = Colors.brown.shade700;
        }

        String translatedIt = AstroTranslationService.translate(
            context, it.trim(),
            isPlanet: true);
        translatedIt = translatedIt.replaceAll(
            RegExp(r'''\s*\d+\s*(?:"|”|'')+$'''), '');

        BoxDecoration? itemDecoration;
        if (isMaanthi) {
          itemDecoration = BoxDecoration(
            color: const Color(0xFFF5F5F5),
            border: Border.all(color: Colors.black, width: 1.2),
            borderRadius: BorderRadius.circular(3),
          );
        } else if (isSpecial) {
          itemDecoration = BoxDecoration(
            color: highlightColor,
            borderRadius: BorderRadius.circular(3),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 0.6),
          decoration: itemDecoration,
          child: Text(
            translatedIt,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSpecial ? FontWeight.w900 : FontWeight.w700,
              color: isMaanthi
                  ? Colors.black87
                  : (isSpecial ? Colors.white : const Color(0xFF1A237E)),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Safe inner bounding boxes for items inside each house
  Rect _getHouseContentBounds(int house, double w, double h) {
    switch (house) {
      case 1: // Top Center Diamond
        return Rect.fromLTWH(w * 0.35, h * 0.08, w * 0.3, h * 0.3);
      case 2: // Top-Left Triangle
        return Rect.fromLTWH(w * 0.12, h * 0.04, w * 0.24, h * 0.16);
      case 3: // Upper-Left Corner Triangle
        return Rect.fromLTWH(w * 0.04, h * 0.12, w * 0.16, h * 0.24);
      case 4: // Left Center Diamond
        return Rect.fromLTWH(w * 0.08, h * 0.35, w * 0.3, h * 0.3);
      case 5: // Lower-Left Corner Triangle
        return Rect.fromLTWH(w * 0.04, h * 0.64, w * 0.16, h * 0.24);
      case 6: // Bottom-Left Triangle
        return Rect.fromLTWH(w * 0.12, h * 0.80, w * 0.24, h * 0.16);
      case 7: // Bottom Center Diamond
        return Rect.fromLTWH(w * 0.35, h * 0.62, w * 0.3, h * 0.3);
      case 8: // Bottom-Right Triangle
        return Rect.fromLTWH(w * 0.64, h * 0.80, w * 0.24, h * 0.16);
      case 9: // Lower-Right Corner Triangle
        return Rect.fromLTWH(w * 0.80, h * 0.64, w * 0.16, h * 0.24);
      case 10: // Right Center Diamond
        return Rect.fromLTWH(w * 0.62, h * 0.35, w * 0.3, h * 0.3);
      case 11: // Upper-Right Corner Triangle
        return Rect.fromLTWH(w * 0.80, h * 0.12, w * 0.16, h * 0.24);
      case 12: // Top-Right Triangle
        return Rect.fromLTWH(w * 0.64, h * 0.04, w * 0.24, h * 0.16);
      default:
        return Rect.zero;
    }
  }

  // Anchor points for Rasi numbers in each house
  Offset _getRasiNumberPosition(int house, double w, double h) {
    switch (house) {
      case 1:
        return Offset(w * 0.5, h * 0.43);
      case 2:
        return Offset(w * 0.42, h * 0.04);
      case 3:
        return Offset(w * 0.04, h * 0.42);
      case 4:
        return Offset(w * 0.43, h * 0.5);
      case 5:
        return Offset(w * 0.04, h * 0.58);
      case 6:
        return Offset(w * 0.42, h * 0.96);
      case 7:
        return Offset(w * 0.5, h * 0.57);
      case 8:
        return Offset(w * 0.58, h * 0.96);
      case 9:
        return Offset(w * 0.96, h * 0.58);
      case 10:
        return Offset(w * 0.57, h * 0.5);
      case 11:
        return Offset(w * 0.96, h * 0.42);
      case 12:
        return Offset(w * 0.58, h * 0.04);
      default:
        return Offset.zero;
    }
  }
}

class _NorthIndianChartPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Map<int, Color> houseHighlights;

  _NorthIndianChartPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.houseHighlights,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Highlights under the lines
    houseHighlights.forEach((house, color) {
      final path = _getHousePolygon(house, w, h);
      if (path != null) {
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }
    });

    final linePaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    // 2. Outer Rectangle
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), linePaint);

    // 3. Diagonals (X)
    canvas.drawLine(const Offset(0, 0), Offset(w, h), linePaint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), linePaint);

    // 4. Inner Diamond
    final diamond = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.5)
      ..close();
    canvas.drawPath(diamond, linePaint);
  }

  Path? _getHousePolygon(int house, double w, double h) {
    final path = Path();
    switch (house) {
      case 1:
        path.moveTo(w * 0.5, 0);
        path.lineTo(w * 0.25, h * 0.25);
        path.lineTo(w * 0.5, h * 0.5);
        path.lineTo(w * 0.75, h * 0.25);
        break;
      case 2:
        path.moveTo(0, 0);
        path.lineTo(w * 0.5, 0);
        path.lineTo(w * 0.25, h * 0.25);
        break;
      case 3:
        path.moveTo(0, 0);
        path.lineTo(w * 0.25, h * 0.25);
        path.lineTo(0, h * 0.5);
        break;
      case 4:
        path.moveTo(0, h * 0.5);
        path.lineTo(w * 0.25, h * 0.25);
        path.lineTo(w * 0.5, h * 0.5);
        path.lineTo(w * 0.25, h * 0.75);
        break;
      case 5:
        path.moveTo(0, h * 0.5);
        path.lineTo(w * 0.25, h * 0.75);
        path.lineTo(0, h);
        break;
      case 6:
        path.moveTo(0, h);
        path.lineTo(w * 0.25, h * 0.75);
        path.lineTo(w * 0.5, h);
        break;
      case 7:
        path.moveTo(w * 0.5, h * 0.5);
        path.lineTo(w * 0.25, h * 0.75);
        path.lineTo(w * 0.5, h);
        path.lineTo(w * 0.75, h * 0.75);
        break;
      case 8:
        path.moveTo(w * 0.5, h);
        path.lineTo(w * 0.75, h * 0.75);
        path.lineTo(w, h);
        break;
      case 9:
        path.moveTo(w * 0.75, h * 0.75);
        path.lineTo(w, h * 0.5);
        path.lineTo(w, h);
        break;
      case 10:
        path.moveTo(w * 0.5, h * 0.5);
        path.lineTo(w * 0.75, h * 0.25);
        path.lineTo(w, h * 0.5);
        path.lineTo(w * 0.75, h * 0.75);
        break;
      case 11:
        path.moveTo(w, 0);
        path.lineTo(w, h * 0.5);
        path.lineTo(w * 0.75, h * 0.25);
        break;
      case 12:
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, 0);
        path.lineTo(w * 0.75, h * 0.25);
        break;
      default:
        return null;
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _NorthIndianChartPainter oldDelegate) => true;
}
