import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/astro_translation_service.dart';

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

  const SouthIndianChart({
    super.key, 
    required this.rasiMap, 
    this.centerLabel,
    this.centerWidget,
    this.borderLabels,
    this.highlightSign,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: LayoutBuilder(
          builder: (context, constraints) {
        final double size = constraints.maxWidth;
        final double boxSize = size / 4;

        return Container(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Grid
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.all(24), // Space for border labels
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        final rasi = RASI_ORDER[index];
                        final items = rasiMap[rasi] ?? [];
                        final bool isLagnaCell = items.any((e) => e.startsWith("லக்") || e.startsWith("உத") || e.startsWith("Asc") || e.startsWith("Lagna") || e.startsWith("Uda") || e.startsWith("लग्न") || e.startsWith("उदय"));
                        final bool isArudamCell = items.any((e) => e.startsWith("ஆரூ") || e.startsWith("Aru") || e.startsWith("आरू"));
                        final bool isKaviCell = items.any((e) => e.startsWith("கவி") || e.startsWith("Kav") || e.startsWith("कवि"));
                        final bool isSpecialCell = isLagnaCell || isArudamCell || isKaviCell;
                        return _ChartCell(
                          rasi: rasi,
                          items: items,
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // 2. Border Labels
              if (borderLabels != null) ..._buildBorderLabels(context, size),

              // 3. Center Label
              Center(
                child: SizedBox(
                  width: (size - 48) / 2 - 8,
                  height: (size - 48) / 2 - 8,
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
  }

  List<Widget> _buildBorderLabels(BuildContext context, double size) {
    if (borderLabels == null) return [];
    List<Widget> labels = [];
    final double boxSize = (size - 48) / 4; // Subtracting the inner padding

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
        anchorX = 24 + (col * boxSize) + (boxSize / 2);
      } else if (row == 3) { // Bottom
        anchorY = size - 12; // Center of the bottom 24px padding
        anchorX = 24 + (col * boxSize) + (boxSize / 2);
      } else if (col == 0) { // Left
        isVerticalEdge = true;
        anchorX = 12; // Center of the left 24px padding
        anchorY = 24 + (row * boxSize) + (boxSize / 2);
      } else if (col == 3) { // Right
        isVerticalEdge = true;
        anchorX = size - 12; // Center of the right 24px padding
        anchorY = 24 + (row * boxSize) + (boxSize / 2);
      }

      String displayText = AstroTranslationService.translate(context, label.trim(), isPlanet: true);
      if (isVerticalEdge) {
        displayText = displayText.replaceAll('\u00A0', '\n').replaceAll(' ', '\n');
      } else {
        displayText = displayText.replaceAll(' ', '  ');
      }

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
              gradient: const LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFB58D3D)], // Beautiful golden orange
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D1204).withOpacity(0.25),
                  blurRadius: 4,
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

  const _ChartCell({required this.rasi, required this.items});

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

    // Dynamically adjust font size to reduce the need for scrolling
    double fontSize = 11.0;
    if (widget.items.length > 5) {
      fontSize = 9.0;
    } else if (widget.items.length > 4) {
      fontSize = 9.5;
    } else if (widget.items.length > 3) {
      fontSize = 10.0;
    }

    return Container(
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
                bool isSpecial = isLagna || isArudam || isKavi;
                
                Color highlightColor = Colors.transparent;
                if (isLagna) highlightColor = Colors.green.shade700;
                else if (isArudam) highlightColor = Colors.blue.shade800;
                else if (isKavi) highlightColor = Colors.red.shade800;

                // Replace space with newline to save horizontal space, e.g., "சனி 17:39" -> "சனி\n17:39"
                
                String translatedIt = AstroTranslationService.translate(context, it.trim(), isPlanet: true);
                // Remove seconds (e.g. 03") to keep only DD° MM'
                translatedIt = translatedIt.replaceAll(RegExp("\\s*\\d+\\s*(?:\"|”|'')+\$"), '');
                
                // Replace only the first space with a newline to keep name on top and DD° MM' on the bottom line
                int firstSpaceIndex = translatedIt.indexOf(' ');
                String displayText;
                if (firstSpaceIndex != -1) {
                  displayText = translatedIt.substring(0, firstSpaceIndex) + '\n' + translatedIt.substring(firstSpaceIndex + 1);
                } else {
                  displayText = translatedIt;
                }


                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  decoration: isSpecial ? BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(4),
                  ) : null,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      displayText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        height: 1.1, // Tighter line height for multiline
                        color: isSpecial ? Colors.white : Colors.indigo.shade900,
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
  }
}

