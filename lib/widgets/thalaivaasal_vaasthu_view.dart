import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/thalaivaasal_vaasthu_service.dart';

class ThalaivaasalVaasthuView extends StatefulWidget {
  final double? initialFeet;
  final double? initialInches;

  const ThalaivaasalVaasthuView({
    super.key,
    this.initialFeet,
    this.initialInches,
  });

  @override
  State<ThalaivaasalVaasthuView> createState() => _ThalaivaasalVaasthuViewState();
}

class _ThalaivaasalVaasthuViewState extends State<ThalaivaasalVaasthuView> {
  VaasthuDirection _selectedDirection = VaasthuDirection.east;
  late final TextEditingController _ftCtrl;
  late final TextEditingController _inCtrl;

  @override
  void initState() {
    super.initState();
    _ftCtrl = TextEditingController(text: (widget.initialFeet ?? 17.0).toStringAsFixed(0));
    _inCtrl = TextEditingController(text: (widget.initialInches ?? 0.0).toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ftCtrl.dispose();
    _inCtrl.dispose();
    super.dispose();
  }

  ThalaivaasalResult _getResult() {
    final double ft = double.tryParse(_ftCtrl.text.trim()) ?? 17.0;
    final double inches = double.tryParse(_inCtrl.text.trim()) ?? 0.0;
    return ThalaivaasalVaasthuService.calculate(
      direction: _selectedDirection,
      feet: ft,
      inches: inches,
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = _getResult();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Banner Card
          _buildHeaderBanner(),
          const SizedBox(height: 16),

          // 2. Direction Selection Card
          _buildDirectionSelectorCard(),
          const SizedBox(height: 16),

          // 3. Wall Dimension Input Card
          _buildDimensionInputCard(),
          const SizedBox(height: 18),

          // 4. Hero Optimal Result Card
          _buildOptimalResultHeroCard(res),
          const SizedBox(height: 18),

          // 5. Interactive Visual Blueprint & Wall Strip
          _buildVisualDiagramCard(res),
          const SizedBox(height: 18),

          // 6. Detailed Measurements Table Card
          _buildMeasurementsTableCard(res),
          const SizedBox(height: 18),

          // 7. Step-by-Step Mathematical Explanation Card
          _buildStepByStepMathCard(res),
          const SizedBox(height: 18),

          // 8. Vaasthu Corner Guidelines Card
          _buildCornerGuidelinesCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D1204), Color(0xFF8A1538)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE082).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.door_front_door_rounded, color: Color(0xFFFFE082), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'கட்டிடத்தின் தலைவாசல் (நிலை) வைக்கும் பகுதி',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFE082),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'உச்ச, நீச, மத்திம & உத்தம பலன் கணித முறை',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionSelectorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '1. கட்டிடத்தின் திசை தேர்ந்தெடுக்கவும்:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.3,
            children: [
              _buildDirectionOption(
                direction: VaasthuDirection.east,
                title: 'கிழக்கு (East)',
                subtitle: 'ஈசானியம் ➔ அக்னி',
                icon: Icons.wb_twilight_rounded,
              ),
              _buildDirectionOption(
                direction: VaasthuDirection.south,
                title: 'தெற்கு (South)',
                subtitle: 'அக்னி ➔ கன்னி',
                icon: Icons.wb_sunny_rounded,
              ),
              _buildDirectionOption(
                direction: VaasthuDirection.west,
                title: 'மேற்கு (West)',
                subtitle: 'வாயு ➔ கன்னி',
                icon: Icons.nights_stay_rounded,
              ),
              _buildDirectionOption(
                direction: VaasthuDirection.north,
                title: 'வடக்கு (North)',
                subtitle: 'ஈசானியம் ➔ வாயு',
                icon: Icons.navigation_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionOption({
    required VaasthuDirection direction,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedDirection == direction;

    return GestureDetector(
      onTap: () => setState(() => _selectedDirection = direction),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D1204) : const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.35),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF5D1204).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : const Color(0xFF7A6855),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.square_foot_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '2. தலைவாசல் சுவரின் மொத்த அளவு:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildUnitField(
                  label: 'அடி (Feet)',
                  controller: _ftCtrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUnitField(
                  label: 'அங்குலம் (Inches)',
                  controller: _inCtrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildPresetChip('17 அடி (உதாரணம்)', 17.0, 0.0),
              _buildPresetChip('20 அடி', 20.0, 0.0),
              _buildPresetChip('25 அடி', 25.0, 0.0),
              _buildPresetChip('30 அடி', 30.0, 0.0),
              _buildPresetChip('35 அடி', 35.0, 0.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitField({
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.35)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) => setState(() {}),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF5D1204),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF7A6855), fontWeight: FontWeight.w600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, double ft, double inch) {
    final double curFt = double.tryParse(_ftCtrl.text.trim()) ?? 0.0;
    final double curIn = double.tryParse(_inCtrl.text.trim()) ?? 0.0;
    final bool isSelected = (curFt == ft && curIn == inch);

    return InkWell(
      onTap: () {
        setState(() {
          _ftCtrl.text = ft.toStringAsFixed(0);
          _inCtrl.text = inch.toStringAsFixed(0);
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5D1204) : const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
          ),
        ),
      ),
    );
  }

  Widget _buildOptimalResultHeroCard(ThalaivaasalResult res) {
    final String startStr = ThalaivaasalResult.toFeetAndInches(res.uttamaStartFeet);
    final String endStr = ThalaivaasalResult.toFeetAndInches(res.uttamaEndFeet);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1B5E20),
            const Color(0xFF2E7D32),
            const Color(0xFF388E3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFFFE082), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'உத்தம பலன் (தலைவாசல் நிலை வைக்கும் இடம்)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Main Dimension Range
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$startStr முதல் $endStr வரை',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFE082),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '(${res.uttamaStartFeet.toStringAsFixed(2)} அடி முதல் ${res.uttamaEndFeet.toStringAsFixed(2)} அடி வரை)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_circle_right_rounded, color: Color(0xFFFFE082), size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${res.startCornerName} மூலையிலிருந்து அளக்க வேண்டும்',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualDiagramCard(ThalaivaasalResult res) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.architecture_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '3. சுவரின் நேரலை வரைபடம் (Wall Blueprint):',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${ThalaivaasalVaasthuService.getDirectionOnlyTamil(res.direction)} பார்த்த சுவர்: ${res.startCornerShort} ➔ ${res.endCornerShort}',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A6855), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),

          // Wall Strip Diagram
          _buildWallStrip(res),
          const SizedBox(height: 16),

          // Compass Corners Box Diagram
          _buildBuildingCompassBox(res),
        ],
      ),
    );
  }

  Widget _buildWallStrip(ThalaivaasalResult res) {
    final double safeTotal = res.totalFeet > 0 ? res.totalFeet : 17.0;

    // Fractions of the wall length:
    // Zone 1: 0 to uttamaStart (மத்திமம்)
    // Zone 2: uttamaStart to uttamaEnd (உத்தமம்)
    // Zone 3: uttamaEnd to ucchaEnd (மத்திமம் முடிவு)
    // Zone 4: ucchaEnd to total (நீசம்)

    final double f1 = (res.uttamaStartFeet / safeTotal).clamp(0.0, 1.0);
    final double f2 = ((res.uttamaEndFeet - res.uttamaStartFeet) / safeTotal).clamp(0.0, 1.0);
    final double f3 = ((res.ucchaFeet - res.uttamaEndFeet) / safeTotal).clamp(0.0, 1.0);
    final double f4 = ((safeTotal - res.ucchaFeet) / safeTotal).clamp(0.0, 1.0);

    return Column(
      children: [
        // Corner indicators at top
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D1204),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    res.startCornerShort,
                    style: const TextStyle(color: Color(0xFFFFE082), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 2),
                const Text('0 அடி (தொடக்க மூலை)', style: TextStyle(fontSize: 9.5, color: Colors.grey)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    res.endCornerShort,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${res.totalFeet.toStringAsFixed(1)} அடி (முடிவு மூலை)',
                  style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Colored Wall Strip
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // 1. Mathimam Part 1 (0 to 3P)
                Expanded(
                  flex: (f1 * 1000).round(),
                  child: Container(
                    color: Colors.amber.shade200,
                    alignment: Alignment.center,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'மத்திமம்\n(0-3P)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                    ),
                  ),
                ),

                // 2. Uttamam Part (3P to 4P - Main Door)
                Expanded(
                  flex: (f2 * 1000).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      border: Border.symmetric(
                        vertical: BorderSide(color: Colors.amber.shade400, width: 2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.door_front_door, color: Colors.white, size: 16),
                          Text(
                            'உத்தமம்\n(தலைவாசல்)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Mathimam Part 2 (4P to 4.5P)
                Expanded(
                  flex: (f3 * 1000).round(),
                  child: Container(
                    color: Colors.amber.shade200,
                    alignment: Alignment.center,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'மத்திமம்',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                    ),
                  ),
                ),

                // 4. Neesam Part (Center to End)
                Expanded(
                  flex: (f4 * 1000).round(),
                  child: Container(
                    color: Colors.red.shade100,
                    alignment: Alignment.center,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close_rounded, color: Colors.red, size: 14),
                          Text(
                            'நீசம் (தவிர்க்கவும்)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Halfway Divider Label
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                color: Colors.green.withValues(alpha: 0.1),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'உச்சப்பகுதி: 0 முதல் ${res.ucchaFeet.toStringAsFixed(2)} அடி வரை (மத்திமம் பலன்)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                color: Colors.red.withValues(alpha: 0.08),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'நீசப்பகுதி: ${res.ucchaFeet.toStringAsFixed(2)} முதல் ${res.totalFeet.toStringAsFixed(2)} அடி வரை',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBuildingCompassBox(ThalaivaasalResult res) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.compass_calibration_rounded, size: 14, color: Color(0xFF5D1204)),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'கட்டிடத்தின் 4 மூலைகள் & உச்ச-நீச அமைவிடம்',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown.shade800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2x2 Corners Visual Box
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF5D1204), width: 1.5),
            ),
            child: Stack(
              children: [
                // North-West (வாயு)
                Positioned(
                  top: 6,
                  left: 8,
                  child: _buildCornerBadge('வாயு (NW)', res.direction == VaasthuDirection.west || res.direction == VaasthuDirection.north),
                ),
                // North-East (ஈசானியம்)
                Positioned(
                  top: 6,
                  right: 8,
                  child: _buildCornerBadge('ஈசானியம் (NE)', res.direction == VaasthuDirection.east || res.direction == VaasthuDirection.north),
                ),
                // South-West (கன்னி)
                Positioned(
                  bottom: 6,
                  left: 8,
                  child: _buildCornerBadge('கன்னி (SW)', res.direction == VaasthuDirection.south || res.direction == VaasthuDirection.west),
                ),
                // South-East (அக்னி)
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: _buildCornerBadge('அக்னி (SE)', res.direction == VaasthuDirection.east || res.direction == VaasthuDirection.south),
                ),

                // Center Label
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D1204).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${ThalaivaasalVaasthuService.getDirectionOnlyTamil(res.direction)} பார்த்த கட்டிடம்\nஉச்சப்பகுதி ➔ நீசம்',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBadge(String label, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF5D1204) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isHighlighted ? const Color(0xFFFFE082) : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: isHighlighted ? const Color(0xFFFFE082) : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMeasurementsTableCard(ThalaivaasalResult res) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_list_bulleted_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '4. அளவு விவரங்களின் சுருக்கம்:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildRowItem(
            title: 'சுவரின் மொத்த அளவு',
            value: ThalaivaasalResult.toFeetAndInchesDetailed(res.totalFeet),
            color: const Color(0xFF5D1204),
          ),
          const Divider(height: 16),

          _buildRowItem(
            title: 'உச்சப்பகுதி (மத்திமம் பலன்)',
            value: '0 முதல் ${ThalaivaasalResult.toFeetAndInchesDetailed(res.ucchaFeet)} வரை',
            subtitle: '${res.startCornerShort} மூலையிலிருந்து பாதி சுவர் வரை',
            color: Colors.brown.shade800,
          ),
          const Divider(height: 16),

          _buildRowItem(
            title: 'ஒரு பகுதி உண்டான அளவு (1/4.5)',
            value: ThalaivaasalResult.toFeetAndInchesDetailed(res.onePartFeet),
            subtitle: 'உச்சப்பகுதி ÷ 4.5',
            color: Colors.indigo.shade800,
          ),
          const Divider(height: 16),

          _buildRowItem(
            title: 'உத்தம ஆரம்ப அளவு (3 × ஒரு பகுதி)',
            value: ThalaivaasalResult.toFeetAndInchesDetailed(res.uttamaStartFeet),
            subtitle: '${res.startCornerShort}-லிருந்து இந்த தூரத்தில் தலைவாசல் ஆரம்பிக்க வேண்டும்',
            color: Colors.green.shade900,
            isBold: true,
          ),
          const Divider(height: 16),

          _buildRowItem(
            title: 'உத்தம முடிவு அளவு (ஆரம்பம் + ஒரு பகுதி)',
            value: ThalaivaasalResult.toFeetAndInchesDetailed(res.uttamaEndFeet),
            subtitle: '${res.startCornerShort}-லிருந்து இந்த தூரம் வரை தலைவாசல் பகுதி அமையும்',
            color: Colors.green.shade900,
            isBold: true,
          ),
          const Divider(height: 16),

          _buildRowItem(
            title: 'நீசப் பகுதி (தவிர்க்கவும்)',
            value: '${ThalaivaasalResult.toFeetAndInches(res.neesaStartFeet)} முதல் ${ThalaivaasalResult.toFeetAndInches(res.neesaEndFeet)} வரை',
            subtitle: 'மையத்திலிருந்து ${res.endCornerShort} மூலை வரை',
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem({
    required String title,
    required String value,
    String? subtitle,
    required Color color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepByStepMathCard(ThalaivaasalResult res) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '5. படிமுறை கணித விளக்கம் (Mathematical Steps):',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildMathStep(
            stepNum: '1',
            title: 'உச்சப்பகுதி கணிதம் (மத்திமம் பலன்):',
            formula: 'கொடுக்கப்பட்ட அளவு ÷ 2 = உச்சப்பகுதி',
            calculation: '${res.totalFeet.toStringAsFixed(2)} அடி ÷ 2 = ${res.ucchaFeet.toStringAsFixed(2)} அடி (${ThalaivaasalResult.toFeetAndInches(res.ucchaFeet)})',
            note: '${res.startCornerShort} மூலையிலிருந்து ${res.ucchaFeet.toStringAsFixed(2)} அடி வரை உச்சப்பகுதி ஆகும். (மத்திமம் பலன்)',
          ),
          const SizedBox(height: 10),

          _buildMathStep(
            stepNum: '2',
            title: 'ஒரு பகுதி உண்டான அளவு கணிதம்:',
            formula: 'உச்சப்பகுதி அளவு ÷ 4.5 = 1 பகுதி',
            calculation: '${res.ucchaFeet.toStringAsFixed(2)} அடி ÷ 4.5 = ${res.onePartFeet.toStringAsFixed(2)} அடி (${ThalaivaasalResult.toFeetAndInches(res.onePartFeet)})',
            note: 'இது உத்தம வாசல் கணக்கீட்டின் ஒரு அடிப்படை பகுதியாகும்.',
          ),
          const SizedBox(height: 10),

          _buildMathStep(
            stepNum: '3',
            title: 'உத்தம ஆரம்ப அளவு (வாசல் தொடக்கம்):',
            formula: '1 பகுதி அளவு × 3 = ஆரம்ப அளவு',
            calculation: '${res.onePartFeet.toStringAsFixed(2)} அடி × 3 = ${res.uttamaStartFeet.toStringAsFixed(2)} அடி (${ThalaivaasalResult.toFeetAndInches(res.uttamaStartFeet)})',
            note: '${res.startCornerShort} மூலையிலிருந்து ${ThalaivaasalResult.toFeetAndInches(res.uttamaStartFeet)} தள்ளி தலைவாசல் ஆரம்பிக்க வேண்டும்.',
          ),
          const SizedBox(height: 10),

          _buildMathStep(
            stepNum: '4',
            title: 'உத்தம முடிவு அளவு (வாசல் முடிவு):',
            formula: 'ஆரம்ப அளவு + 1 பகுதி = முடிவு அளவு',
            calculation: '${res.uttamaStartFeet.toStringAsFixed(2)} + ${res.onePartFeet.toStringAsFixed(2)} = ${res.uttamaEndFeet.toStringAsFixed(2)} அடி (${ThalaivaasalResult.toFeetAndInches(res.uttamaEndFeet)})',
            note: 'எனவே ${res.startCornerShort} மூலையிலிருந்து ${ThalaivaasalResult.toFeetAndInches(res.uttamaStartFeet)} முதல் ${ThalaivaasalResult.toFeetAndInches(res.uttamaEndFeet)} வரை உத்தம பலன் தரும் தலைவாசல் பகுதி ஆகும்!',
            isFinal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMathStep({
    required String stepNum,
    required String title,
    required String formula,
    required String calculation,
    required String note,
    bool isFinal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isFinal ? Colors.green.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFinal ? Colors.green.shade600 : const Color(0xFFB58D3D).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isFinal ? Colors.green.shade800 : const Color(0xFF5D1204),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNum,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isFinal ? Colors.green.shade900 : const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formula,
            style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            calculation,
            style: TextStyle(
              fontSize: 11.5,
              color: isFinal ? Colors.green.shade900 : const Color(0xFF5D1204),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            note,
            style: const TextStyle(fontSize: 10, color: Color(0xFF555555), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerGuidelinesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '6. வாஸ்து சாஸ்திர வரைபடக் குறிப்புகள்:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildCornerRuleItem('வடக்கு-கிழக்கு', 'ஈசானியம் (நீர் மூலை) - ஆன்மீகம், சுகாதாரம், சுப விருத்தி'),
          _buildCornerRuleItem('தெற்கு-கிழக்கு', 'அக்னி (நெருப்பு மூலை) - சமையல் அறை, சுப காரிய பலன்'),
          _buildCornerRuleItem('தெற்கு-மேற்கு', 'கன்னி / நிருதி (பூமி மூலை) - தலைவரின் படுக்கையறை, நிலைத்தன்மை'),
          _buildCornerRuleItem('வடக்கு-மேற்கு', 'வாயு (காற்று மூலை) - விருந்தினர் அறை, வாகன நிறுத்துமிடம்'),

          const Divider(height: 18),
          const Text(
            'முக்கிய வாஸ்து விதி:\n'
            '• உச்சப்பகுதி என்பது மத்திம பலன் தரக்கூடிய பகுதி ஆகும்.\n'
            '• உச்சப்பகுதியை 4.5 பங்குகளாகப் பிரித்து, 3 பங்குகள் கழித்து 4-வது பங்கு பகுதியில் தலைவாசல் நிலை வைப்பதே சாஸ்திரப்படி "உத்தம பலன்" ஆகும்.\n'
            '• நீசப்பகுதியில் ஒருபோதும் தலைவாசல் நிலை வைக்கக் கூடாது.',
            style: TextStyle(fontSize: 11, color: Color(0xFF5D1204), height: 1.4, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerRuleItem(String direction, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFFB58D3D), size: 14),
          const SizedBox(width: 6),
          Text(
            '$direction: ',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
          ),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(fontSize: 11, color: Color(0xFF444444)),
            ),
          ),
        ],
      ),
    );
  }
}
