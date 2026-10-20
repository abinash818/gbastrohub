import 'package:flutter/material.dart';
import '../services/astro_translation_service.dart';
import '../services/settings_service.dart';
import 'north_indian_chart.dart';

// RASI BOX ORDER (0-15 grid indices)
// 0  1  2  3  (Top row: Meenam to Rishabham)
// 4  5  6  7  (Row 2: Kumbham, center, center, Mithunam)
// 8  9  10 11 (Row 3: Makaram, center, center, Katakam)
// 12 13 14 15 (Bottom row: Dhanusu to Simmam)

const Map<int, String?> RASI_ORDER = {
  0: "Pisces", 1: "Aries", 2: "Taurus", 3: "Gemini",
  4: "Aquarius", 7: "Cancer",
  8: "Capricorn", 11: "Leo",
  12: "Sagittarius", 13: "Scorpio", 14: "Libra", 15: "Virgo",
};

const Map<String, int> RASI_NUMBERS = {
  "Aries": 1, "Taurus": 2, "Gemini": 3, "Cancer": 4, 
  "Leo": 5, "Virgo": 6, "Libra": 7, "Scorpio": 8, 
  "Sagittarius": 9, "Capricorn": 10, "Aquarius": 11, "Pisces": 12 
};

class SouthIndianChart extends StatelessWidget {
  final Map<String, List<String>> rasiMap;
  final String? centerLabel;
  final Widget? centerWidget;
  final Map<String, String>? borderLabels;
  final String? highlightSign;
  final String? highlightSignLabel;
  final Color? highlightColor;
  final bool allowScroll;
  final Map<String, String>? rasiKathir;
  final double heightRatio;
  final String? udayaLordLabel;
  final String? chartStyle;

  const SouthIndianChart({
    super.key, 
    required this.rasiMap, 
    this.centerLabel,
    this.centerWidget,
    this.borderLabels,
    this.highlightSign,
    this.highlightSignLabel,
    this.highlightColor,
    this.allowScroll = true,
    this.rasiKathir,
    this.heightRatio = 1.0,
    this.udayaLordLabel,
    this.chartStyle,
  });

  static double? _extractDegree(String str) {
    // Matches e.g. "06:28", "2:24", "14:32:10"
    final m1 = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(str);
    if (m1 != null) {
      return int.parse(m1.group(1)!) + int.parse(m1.group(2)!) / 60.0;
    }
    // Matches e.g. "14° 32'", "14°32"
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.chartStyleNotifier,
      builder: (context, globalStyle, _) {
        final activeStyle = chartStyle ?? globalStyle;
        if (activeStyle == 'north_indian' && (borderLabels == null || borderLabels!.isEmpty)) {
          return NorthIndianChart(
            rasiMap: rasiMap,
            centerLabel: centerLabel,
            centerWidget: centerWidget,
            highlightSign: highlightSign,
            highlightSignLabel: highlightSignLabel,
            highlightColor: highlightColor,
            allowScroll: allowScroll,
            heightRatio: heightRatio,
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: LayoutBuilder(
              builder: (context, constraints) {
            final double size = constraints.maxWidth;
            final double height = size * heightRatio;

            final bool hasBorderLabels = borderLabels != null && borderLabels!.isNotEmpty;
            final double pad = hasBorderLabels ? 24.0 : 0.0;
            final double innerW = size - (pad * 2);
            final double innerH = height - (pad * 2);

            return Container(
              width: size,
              height: height,
              child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Grid
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.all(pad), // Space for border labels if present
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade800, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: innerW / innerH,
                      ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        final rasi = RASI_ORDER[index];
                        final rawItems = rasiMap[rasi] ?? [];
                        final items = sortItemsByDegree(rawItems);
                        final bool isLagnaCell = items.any((e) => e.startsWith("லக்") || e.startsWith("உத") || e.startsWith("Asc") || e.startsWith("Lagna") || e.startsWith("Uda") || e.startsWith("लग्न") || e.startsWith("उदय"));
                        final bool isArudamCell = items.any((e) => e.startsWith("ஆரூ") || e.startsWith("Aru") || e.startsWith("आरू"));
                        final bool isKaviCell = items.any((e) => e.startsWith("கவி") || e.startsWith("Kav") || e.startsWith("कवि"));
                        final bool isSpecialCell = isLagnaCell || isArudamCell || isKaviCell;
                        final bool isHighlighted = rasi != null && highlightSign != null && rasi.toLowerCase() == highlightSign!.toLowerCase();
                        return _ChartCell(
                          rasi: rasi,
                          items: items,
                          allowScroll: allowScroll,
                          kathir: (rasi != null && rasiKathir != null) ? rasiKathir![rasi] : null,
                          isHighlighted: isHighlighted,
                          highlightLabel: isHighlighted ? highlightSignLabel : null,
                          highlightColor: isHighlighted ? highlightColor : null,
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // 2. Border Labels
              if (hasBorderLabels) ..._buildBorderLabels(context, size, height),

              // 3. Center Label
              Center(
                child: SizedBox(
                  width: innerW / 2 - 8,
                  height: innerH / 2 - 8,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: centerWidget ?? Text(
                      centerLabel != null ? AstroTranslationService.translate(context, centerLabel!) : "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.indigo.shade900, 
                        fontWeight: FontWeight.w900, 
                        fontSize: 18, 
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
          },
        ),
      ),
    );
      },
    );
  }

  List<Widget> _buildBorderLabels(BuildContext context, double width, double height) {
    if (borderLabels == null) return [];
    List<Widget> labels = [];
    final double boxW = (width - 48) / 4; // Subtracting the inner padding
    final double boxH = (height - 48) / 4;

    borderLabels!.forEach((sign, label) {
      if (label.trim().isEmpty) return; // Skip empty labels

      int? idx;
      // Get the grid index for this sign
      RASI_ORDER.forEach((key, value) { if (value == sign) idx = key; });
      if (idx == null) return;

      double anchorX = 0;
      double anchorY = 0;
      bool isVerticalEdge = false;

      int row = idx! ~/ 4;
      int col = idx! % 4;

      if (row == 0) { // Top
        anchorY = 12; // Center of the top 24px padding
        anchorX = 24 + (col * boxW) + (boxW / 2);
      } else if (row == 3) { // Bottom
        anchorY = height - 12; // Center of the bottom 24px padding
        anchorX = 24 + (col * boxW) + (boxW / 2);
      } else if (col == 0) { // Left
        isVerticalEdge = true;
        anchorX = 12; // Center of the left 24px padding
        anchorY = 24 + (row * boxH) + (boxH / 2);
      } else if (col == 3) { // Right
        isVerticalEdge = true;
        anchorX = width - 12; // Center of the right 24px padding
        anchorY = 24 + (row * boxH) + (boxH / 2);
      }

      String displayText = AstroTranslationService.translate(context, label.trim(), isPlanet: true);
      if (isVerticalEdge) {
        displayText = displayText.replaceAll('\u00A0', '\n').replaceAll(' ', '\n');
      } else {
        displayText = displayText.replaceAll(' ', '  ');
      }

      bool isUdayaLord = udayaLordLabel != null && 
          udayaLordLabel!.isNotEmpty && 
          label.trim().startsWith(udayaLordLabel!.trim());

      labels.add(Positioned(
        left: anchorX,
        top: anchorY,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6, 
              vertical: isVerticalEdge ? 6 : 4
            ),
            decoration: BoxDecoration(
              gradient: isUdayaLord
                ? const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)], // Distinct Emerald Green for Udayathipathi
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFE65100), Color(0xFFB58D3D)], // Default golden orange for other Jamakkol grahas
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUdayaLord ? Colors.greenAccent.shade100 : Colors.white, 
                width: isUdayaLord ? 1.8 : 1.2
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUdayaLord ? Colors.green.shade900 : const Color(0xFF5D1204)).withOpacity(0.35),
                  blurRadius: isUdayaLord ? 6 : 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              displayText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9.5, 
                fontWeight: FontWeight.w900, 
                color: Colors.white, 
                height: 1.1,
              ),
            ),
          ),
        ),
      ));
    });

    return labels;
  }
}

class _ChartCell extends StatefulWidget {
  final String? rasi;
  final List<String> items;
  final bool allowScroll;
  final String? kathir;
  final bool isHighlighted;
  final String? highlightLabel;
  final Color? highlightColor;

  const _ChartCell({
    required this.rasi, 
    required this.items, 
    this.allowScroll = true,
    this.kathir,
    this.isHighlighted = false,
    this.highlightLabel,
    this.highlightColor,
  });

  @override
  State<_ChartCell> createState() => _ChartCellState();
}

class _ChartCellState extends State<_ChartCell> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rasi == null) return const SizedBox();

    final bool isLagnaCell = widget.items.any((e) => e.startsWith("லக்") || e.startsWith("உத") || e.startsWith("Asc") || e.startsWith("Lagna") || e.startsWith("Uda") || e.startsWith("लग्न") || e.startsWith("उदय"));
    final bool isArudamCell = widget.items.any((e) => e.startsWith("ஆரூ") || e.startsWith("Aru") || e.startsWith("आरू"));
    final bool isKaviCell = widget.items.any((e) => e.startsWith("கவி") || e.startsWith("Kav") || e.startsWith("कवि"));
    final bool isSpecialCell = isLagnaCell || isArudamCell || isKaviCell;

    // Check if cell is a single number (e.g. Ashtakavarga points)
    final bool isSingleNumber = widget.items.length == 1 && int.tryParse(widget.items.first.trim()) != null;
    if (isSingleNumber) {
      final bool isHighlighted = widget.isHighlighted;
      return Container(
        decoration: BoxDecoration(
          color: isHighlighted 
              ? (widget.highlightColor ?? const Color(0xFFFFECC2)) 
              : Colors.white,
          border: Border.all(
            color: isHighlighted ? const Color(0xFFD84315) : Colors.orange.shade800,
            width: isHighlighted ? 2.5 : 1.5,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: widget.highlightLabel != null && isHighlighted
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D1204),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.highlightLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.items.first.trim(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF5D1204),
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.items.first.trim(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w900,
                      color: isHighlighted ? const Color(0xFF5D1204) : Colors.indigo.shade900,
                    ),
                  ),
          ),
        ),
      );
    }

    // Non-scrollable static poster mode: auto-scale all items inside FittedBox
    if (!widget.allowScroll) {
      final staticCell = Container(
        decoration: BoxDecoration(
          color: isSpecialCell ? (isLagnaCell ? Colors.green.withOpacity(0.05) : (isArudamCell ? Colors.blue.withOpacity(0.05) : Colors.red.withOpacity(0.05))) : Colors.white,
          border: Border.all(
            color: isSpecialCell ? (isLagnaCell ? Colors.green.shade700 : (isArudamCell ? Colors.blue.shade800 : Colors.red.shade800)) : Colors.orange.shade800,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.items.map((it) {
                bool isLagna = it.startsWith("லக்") || it.startsWith("உத") || it.startsWith("Asc") || it.startsWith("Lagna") || it.startsWith("Uda") || it.startsWith("लग्न") || it.startsWith("उदय");
                bool isArudam = it.startsWith("ஆரூ") || it.startsWith("Aru") || it.startsWith("आरू");
                bool isKavi = it.startsWith("கவி") || it.startsWith("Kav") || it.startsWith("कवि");
                bool isYama = it.startsWith("எம") || it.startsWith("Yama") || it.startsWith("यम");
                bool isMrityu = it.startsWith("மிரு") || it.startsWith("Mri") || it.startsWith("मृ");
                bool isRahuClockwise = (it.startsWith("ரா") && !it.startsWith("ராகு")) ||
                                       (it.startsWith("रा") && !it.startsWith("राहु")) ||
                                       (it.startsWith("Rah") && !it.startsWith("Rahu"));
                bool isSubPlanet = isYama || isMrityu || isRahuClockwise;
                bool isMaanthi = it.startsWith("மாந்") || it.startsWith("மாந்தி") || it.startsWith("Maanthi") || it.startsWith("Mn") || it.startsWith("मां");
                bool isSpecial = isLagna || isArudam || isKavi || isSubPlanet || isMaanthi;

                Color highlightColor = Colors.transparent;
                if (isLagna) highlightColor = Colors.green.shade700;
                else if (isArudam) highlightColor = Colors.blue.shade800;
                else if (isKavi) highlightColor = Colors.red.shade800;
                else if (isRahuClockwise) highlightColor = Colors.purple.shade700;
                else if (isYama) highlightColor = const Color(0xFFFFB300); // Vibrant Yellow / Amber (மஞ்சள்)
                else if (isMrityu) highlightColor = Colors.brown.shade700;

                String translatedIt = AstroTranslationService.translate(context, it.trim(), isPlanet: true);
                translatedIt = translatedIt.replaceAll(RegExp(r'''\s*\d+\s*(?:"|”|'')+$'''), '');

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
                  margin: const EdgeInsets.symmetric(vertical: 0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.8),
                  decoration: itemDecoration,
                  child: Text(
                    translatedIt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: (isSpecial || isMaanthi) ? FontWeight.w900 : FontWeight.bold,
                      color: (isMaanthi || isYama) ? Colors.black : (isSpecial ? Colors.white : Colors.indigo.shade900),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );

      if (widget.kathir != null && widget.kathir!.isNotEmpty) {
        return Stack(
          children: [
            staticCell,
            _buildKathirBadge(widget.kathir!),
          ],
        );
      }
      return staticCell;
    }

    // Dynamically adjust font size to reduce the need for scrolling
    double fontSize = 11.0;
    if (widget.items.length > 5) {
      fontSize = 9.0;
    } else if (widget.items.length > 4) {
      fontSize = 9.5;
    } else if (widget.items.length > 3) {
      fontSize = 10.0;
    }

    final scrollCell = Container(
      decoration: BoxDecoration(
        color: isSpecialCell ? (isLagnaCell ? Colors.green.withOpacity(0.05) : (isArudamCell ? Colors.blue.withOpacity(0.05) : Colors.red.withOpacity(0.05))) : Colors.white,
        border: Border.all(
          color: isSpecialCell ? (isLagnaCell ? Colors.green.shade700 : (isArudamCell ? Colors.blue.shade800 : Colors.red.shade800)) : Colors.orange.shade800,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(1),
      child: Center(
        child: RawScrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 3.0,
          radius: const Radius.circular(3),
          thumbColor: Colors.orange.shade300,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(1),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 1,
              runSpacing: 1,
              children: widget.items.map((it) {
                bool isLagna = it.startsWith("லக்") || it.startsWith("உத") || it.startsWith("Asc") || it.startsWith("Lagna") || it.startsWith("Uda") || it.startsWith("लग्न") || it.startsWith("उदय");
                bool isArudam = it.startsWith("ஆரூ") || it.startsWith("Aru") || it.startsWith("आरू");
                bool isKavi = it.startsWith("கவி") || it.startsWith("Kav") || it.startsWith("कवि");
                
                bool isMarana = it.startsWith("மார") || it.startsWith("Mar") || it.startsWith("मार");
                bool isYama = it.startsWith("எம") || it.startsWith("யம") || it.startsWith("Yama") || it.startsWith("यम");
                bool isMrityu = it.startsWith("மிரு") || it.startsWith("Mri") || it.startsWith("मृ");
                bool isRahuClockwise = (it.startsWith("ரா") && !it.startsWith("ராகு")) ||
                                       (it.startsWith("रा") && !it.startsWith("राहु")) ||
                                       (it.startsWith("Rah") && !it.startsWith("Rahu"));
                bool isSubPlanet = isMarana || isYama || isMrityu || isRahuClockwise;
                bool isMaanthi = it.startsWith("மாந்") || it.startsWith("மாந்தி") || it.startsWith("Maanthi") || it.startsWith("Mn") || it.startsWith("मां");
                
                bool isSpecial = isLagna || isArudam || isKavi || isSubPlanet || isMaanthi;
                
                Color highlightColor = Colors.transparent;
                if (isLagna) highlightColor = Colors.green.shade700;
                else if (isArudam) highlightColor = Colors.blue.shade800;
                else if (isKavi) highlightColor = Colors.red.shade800;
                else if (isMarana) highlightColor = Colors.teal.shade800;
                else if (isRahuClockwise) highlightColor = Colors.purple.shade700;
                else if (isMrityu) highlightColor = Colors.brown.shade700;
                else if (isYama) highlightColor = const Color(0xFFFFB300); // Vibrant Yellow / Amber (மஞ்சள்)

                // Replace space with newline to save horizontal space, e.g., "சனி 17:39" -> "சனி\n17:39"
                String translatedIt = AstroTranslationService.translate(context, it.trim(), isPlanet: true);
                translatedIt = translatedIt.replaceAll('\u00A0', ' ').replaceAll('&nbsp;', ' ');
                translatedIt = translatedIt.replaceAll(RegExp(r'''\s*\d+\s*(?:"|”|'')+$'''), '');
                
                // Separate planet name + flags from degree
                final match = RegExp(r'^(.*?)\s+(\d{1,2}:\d{2}(?::\d{2})?|\d{1,2}°\s*\d{1,2}.*)$').firstMatch(translatedIt);
                String displayText;
                if (match != null) {
                  displayText = "${match.group(1)}\n${match.group(2)}";
                } else {
                  final flagOnlyMatch = RegExp(r'^(.*?)\s+(\([வஅRC]\))$').firstMatch(translatedIt);
                  if (flagOnlyMatch != null) {
                    displayText = translatedIt;
                  } else {
                    int firstSpaceIndex = translatedIt.indexOf(' ');
                    if (firstSpaceIndex != -1) {
                      displayText = translatedIt.substring(0, firstSpaceIndex) + '\n' + translatedIt.substring(firstSpaceIndex + 1);
                    } else {
                      displayText = translatedIt;
                    }
                  }
                }

                BoxDecoration? itemDecoration;
                if (isMaanthi) {
                  itemDecoration = BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    border: Border.all(color: Colors.black, width: 1.2),
                    borderRadius: BorderRadius.circular(4),
                  );
                } else if (isSpecial) {
                  itemDecoration = BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(4),
                  );
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  decoration: itemDecoration,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: (isSpecial || isMaanthi) ? FontWeight.w900 : FontWeight.bold,
                        height: 1.1, // Tighter line height for multiline
                        color: (isMaanthi || isYama) ? Colors.black : (isSpecial ? Colors.white : Colors.indigo.shade900),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    if (widget.kathir != null && widget.kathir!.isNotEmpty) {
      return Stack(
        children: [
          scrollCell,
          _buildKathirBadge(widget.kathir!),
        ],
      );
    }
    return scrollCell;
  }

  Widget _buildKathirBadge(String text) {
    return Positioned(
      bottom: 2,
      left: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFF97316).withOpacity(0.8), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFFC2410C),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

