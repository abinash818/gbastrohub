import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gp_vaasthu_service.dart';

class _PoruthamTableRowItem {
  final int sNo;
  final String name;
  final String value;
  final String status; // 'உ', 'ம', 'அ'
  final String statusText; // 'உத்தமம்', 'மத்திமம்', 'அதமம்'
  final bool isGood;
  final String symbol; // '✓', '✗'

  const _PoruthamTableRowItem({
    required this.sNo,
    required this.name,
    required this.value,
    required this.status,
    required this.statusText,
    required this.isGood,
    required this.symbol,
  });
}

class GpVaasthuScreen extends StatefulWidget {
  final bool isPopup;
  const GpVaasthuScreen({super.key, this.isPopup = false});

  @override
  State<GpVaasthuScreen> createState() => _GpVaasthuScreenState();
}

class _GpVaasthuScreenState extends State<GpVaasthuScreen> {
  GpVaasthuRegion _selectedRegion = GpVaasthuRegion.madurai;
  bool _isIrregularSides = false;

  // Length 1 & 2 Controllers
  final TextEditingController _l1FtCtrl = TextEditingController(text: '30');
  final TextEditingController _l1InCtrl = TextEditingController(text: '0');
  final TextEditingController _l2FtCtrl = TextEditingController(text: '30');
  final TextEditingController _l2InCtrl = TextEditingController(text: '0');

  // Width 1 & 2 Controllers
  final TextEditingController _w1FtCtrl = TextEditingController(text: '20');
  final TextEditingController _w1InCtrl = TextEditingController(text: '0');
  final TextEditingController _w2FtCtrl = TextEditingController(text: '20');
  final TextEditingController _w2InCtrl = TextEditingController(text: '0');

  int _selectedOwnerNakshatra = 1; // Default to Ashwini
  int _selectedOwnerRasi = 1; // Default to Mesham
  int _selectedResultTab = 0; // 0: பொருத்தப் பட்டியல் (26 பலன்கள்), 1: விரிவான பலன்கள்
  static const bool _showCalculationDetails = false; // Hide formula breakdowns in detailed view for clean live UI

  GpKuzhiResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void reassemble() {
    super.reassemble();
    _calculate();
  }

  @override
  void dispose() {
    _l1FtCtrl.dispose();
    _l1InCtrl.dispose();
    _l2FtCtrl.dispose();
    _l2InCtrl.dispose();
    _w1FtCtrl.dispose();
    _w1InCtrl.dispose();
    _w2FtCtrl.dispose();
    _w2InCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final double l1Ft = double.tryParse(_l1FtCtrl.text.trim()) ?? 0.0;
    final double l1In = double.tryParse(_l1InCtrl.text.trim()) ?? 0.0;
    final double w1Ft = double.tryParse(_w1FtCtrl.text.trim()) ?? 0.0;
    final double w1In = double.tryParse(_w1InCtrl.text.trim()) ?? 0.0;

    final double l2Ft = _isIrregularSides ? (double.tryParse(_l2FtCtrl.text.trim()) ?? l1Ft) : l1Ft;
    final double l2In = _isIrregularSides ? (double.tryParse(_l2InCtrl.text.trim()) ?? l1In) : l1In;
    final double w2Ft = _isIrregularSides ? (double.tryParse(_w2FtCtrl.text.trim()) ?? w1Ft) : w1Ft;
    final double w2In = _isIrregularSides ? (double.tryParse(_w2InCtrl.text.trim()) ?? w1In) : w1In;

    setState(() {
      _result = GpVaasthuService.calculateKuzhi(
        region: _selectedRegion,
        l1Ft: l1Ft,
        l1In: l1In,
        l2Ft: l2Ft,
        l2In: l2In,
        w1Ft: w1Ft,
        w1In: w1In,
        w2Ft: w2Ft,
        w2In: w2In,
        ownerNakshatra: _selectedOwnerNakshatra,
        ownerRasi: _selectedOwnerRasi,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D1204),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFFFE082), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'GB 26 பொருத்தங்கள்',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFFE082),
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const Text(
              'ஆயாதி எண், 26 வாஸ்து பொருத்தங்கள் & குழிக்கணக்கு',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Regional Method Selector
              _buildRegionSelector(),
              const SizedBox(height: 16),

              // 2. Dimensions Input Card
              _buildDimensionsInputCard(),
              const SizedBox(height: 16),

              // 2.1. Owner Details Input Card (உரிமையாளர் நட்சத்திரம் & ராசி)
              _buildOwnerDetailsInputCard(),
              const SizedBox(height: 16),

              // 3. Calculation Action Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D1204),
                  foregroundColor: const Color(0xFFFFE082),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _calculate();
                },
                icon: const Icon(Icons.calculate_rounded, size: 22),
                label: const Text(
                  'கணக்கிடுக (Calculate)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 18),

              // 4. Calculation Result Cards
              if (_result != null) ...[
                // Ayadi Number Card
                _buildAyadiResultCard(_result!),
                const SizedBox(height: 16),

                // View Mode Tab Switcher: 📋 பொருத்தப் பட்டியல் (26) vs 📑 விரிவான பலன்கள்
                _buildResultViewTabSwitcher(),
                const SizedBox(height: 16),

                if (_selectedResultTab == 0) ...[
                  // 1. 26 Porutham Table Card (as in notebook)
                  _buildPorutham26TableCard(_result!),
                  const SizedBox(height: 18),

                  // Kuzhi Result Card
                  _buildResultCard(_result!),
                  const SizedBox(height: 18),

                  // 4 Regional Methods Comparison Table
                  _buildComparisonCard(),
                ] else ...[
                  // 1. Garbham Result Card (கெர்ப்ப பலன்)
                  _buildGarbhamResultCard(_result!),
                  const SizedBox(height: 16),

                  // 2. Yoni Result Card (யோனிப் பலன்)
                  _buildYoniResultCard(_result!),
                  const SizedBox(height: 16),

                  // 3. Aadhayam Result Card (ஆதாயப் பலன்)
                  _buildAadhayamResultCard(_result!),
                  const SizedBox(height: 16),

                  // 4. Virayam Result Card (விரையப் பலன்)
                  _buildVirayamResultCard(_result!),
                  const SizedBox(height: 16),

                  // Aadhayam vs Virayam Comparison Verdict Card
                  _buildAadhayamVirayamComparisonCard(_result!),
                  const SizedBox(height: 16),

                  // 5. Vaara Result Card (வாரப்பலன்)
                  _buildVaaraResultCard(_result!),
                  const SizedBox(height: 16),

                  // 6. Amsa Result Card (அம்ச பலன்)
                  _buildAmsaResultCard(_result!),
                  const SizedBox(height: 16),

                  // 7. Nakshatra & 11. Gana Result Card (நட்சத்திர பலன் & கணப் பலன்)
                  _buildNakshatraAndGanaResultCard(_result!),
                  const SizedBox(height: 16),

                  // 8. Vamsam Result Card (வம்சம் பலன்)
                  _buildVamsamResultCard(_result!),
                  const SizedBox(height: 16),

                  // 9. Thithi Result Card (திதிப் பலன் - மரபு 1 & 2)
                  _buildThithiResultCard(_result!),
                  const SizedBox(height: 16),

                  // 10. Rasi Result Card (இராசி பலன்)
                  _buildRasiResultCard(_result!),
                  const SizedBox(height: 16),

                  // 10 (கூடுதல்). Age Result Card (வயது பலன்)
                  _buildAgeResultCard(_result!),
                  const SizedBox(height: 16),

                  // 12. Purusha Rasi Result Card (புருஷ இராசி பலன்)
                  _buildPurushaRasiResultCard(_result!),
                  const SizedBox(height: 16),

                  // 13. Boothams Result Card (பூதம் பலன் - முறை 1 & 2)
                  _buildBoothamsResultCard(_result!),
                  const SizedBox(height: 16),

                  // 14. Soothiram Result Card (சூத்திரம் பலன்)
                  _buildSoothiramResultCard(_result!),
                  const SizedBox(height: 16),

                  // 15. Nethiram Result Card (நேத்திர பலன்)
                  _buildNethiramResultCard(_result!),
                  const SizedBox(height: 16),

                  // 16. Amirthathi Yoga Result Card (அமிர்தாதி யோக பலன்)
                  _buildAmirthathiYogaResultCard(_result!),
                  const SizedBox(height: 16),

                  // 17. Thara Phalan Result Card (தாரா பலன்)
                  _buildTharaPhalanResultCard(_result!),
                  const SizedBox(height: 16),

                  // 18. Karana Phalan Result Card (கரணப் பலன்)
                  _buildKaranaResultCard(_result!),
                  const SizedBox(height: 16),

                  // 19. Chandra Phalan Result Card (சந்திர பலன்)
                  _buildChandraPhalanResultCard(_result!),
                  const SizedBox(height: 16),

                  // 20. Ashta Lakshmi Phalan Result Card (அஷ்டலட்சுமி பலன்)
                  _buildAshtaLakshmiResultCard(_result!),
                  const SizedBox(height: 16),

                  // 21. Panchaka Phalan & Pariharam Result Card (பஞ்சகப் பலன் & பரிகாரம்)
                  _buildPanchakaResultCard(_result!),
                  const SizedBox(height: 16),

                  // 22. Guna Phalan Result Card (குணப் பலன்)
                  _buildGunaResultCard(_result!),
                  const SizedBox(height: 16),

                  // 23. Nama Yoga Phalan Result Card (நாம யோகப் பலன்)
                  _buildNamaYogaResultCard(_result!),
                  const SizedBox(height: 16),

                  // 24. Ashta Dikpalakar Phalan Result Card (அஷ்டதிக்கு பாலகர் பலன்)
                  _buildDikpalakarResultCard(_result!),
                  const SizedBox(height: 16),

                  // 25. Athidevathai Phalan Result Card (அதிதேவதை பலன்)
                  _buildAthidevathaiResultCard(_result!),
                  const SizedBox(height: 16),

                  // Kuzhi Result Card
                  _buildResultCard(_result!),
                  const SizedBox(height: 18),

                  // 4 Regional Methods Comparison Table
                  _buildComparisonCard(),
                  const SizedBox(height: 18),

                  // Reference Guides:
                  _buildAllGarbhamsReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllYonisReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllAadhayamsReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllVirayamsReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllVaarasReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllAmsasReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllNakshatrasAndGanasReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllVamsamsReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllThithisReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllRasisReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllAgesReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllPurushaRasisReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllBoothamsReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllSoothiramsReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllNethiramsReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllAmirthathiYogasReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllTharaPhalansReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllKaranasReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllChandraPhalansReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllAshtaLakshmisReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllPanchakasReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllGunasReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllNamaYogasReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllDikpalakarsReferenceCard(),
                  const SizedBox(height: 18),

                  _buildAllAthidevathaisReferenceCard(),
                  const SizedBox(height: 18),

                  // Step-by-Step Formula Explanation
                  if (_showCalculationDetails) ...[
                    const SizedBox(height: 18),
                    _buildFormulaExplanationCard(_result!),
                  ],
                ],
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Region Selector Segment
  Widget _buildRegionSelector() {
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
              const Icon(Icons.location_city_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'வாஸ்து முறை / ஊர் தேர்வு',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
            children: GpVaasthuRegion.values.map((region) {
              final isSelected = _selectedRegion == region;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedRegion = region);
                    _calculate();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5D1204) : const Color(0xFFFAF6EE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: isSelected ? const Color(0xFFFFE082) : const Color(0xFFB58D3D),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                region.nameTa,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: isSelected ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'ம.கோல்: ${region.kolInches}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white70 : const Color(0xFF7A6855),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Dimensions Input Card
  Widget _buildDimensionsInputCard() {
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
              const Icon(Icons.straighten_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'அளவீடுகள் (Dimensions)',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dimension Mode Segmented Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_isIrregularSides) {
                        setState(() => _isIrregularSides = false);
                        _calculate();
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isIrregularSides ? const Color(0xFF5D1204) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'வெளிப்புற சுற்றளவு',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: !_isIrregularSides ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (!_isIrregularSides) {
                        setState(() {
                          _isIrregularSides = true;
                          _l2FtCtrl.text = _l1FtCtrl.text;
                          _l2InCtrl.text = _l1InCtrl.text;
                          _w2FtCtrl.text = _w1FtCtrl.text;
                          _w2InCtrl.text = _w1InCtrl.text;
                        });
                        _calculate();
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isIrregularSides ? const Color(0xFF5D1204) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '4 பக்கங்கள் (மாறுபட்டவை)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isIrregularSides ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 22),

          // Length Section
          Text(
            _isIrregularSides ? 'நீளம் 1 & நீளம் 2 (Length 1 & 2):' : 'நீளம் (Length):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildUnitInputField(
                  label: _isIrregularSides ? 'நீளம் 1 (அடி)' : 'அடி (Ft)',
                  controller: _l1FtCtrl,
                  onChanged: (v) => _calculate(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUnitInputField(
                  label: _isIrregularSides ? 'நீளம் 1 (அங்குலம்)' : 'அங்குலம் (In)',
                  controller: _l1InCtrl,
                  onChanged: (v) => _calculate(),
                ),
              ),
            ],
          ),
          if (_isIrregularSides) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildUnitInputField(
                    label: 'நீளம் 2 (அடி)',
                    controller: _l2FtCtrl,
                    onChanged: (v) => _calculate(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildUnitInputField(
                    label: 'நீளம் 2 (அங்குலம்)',
                    controller: _l2InCtrl,
                    onChanged: (v) => _calculate(),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Width Section
          Text(
            _isIrregularSides ? 'அகலம் 1 & அகலம் 2 (Width 1 & 2):' : 'அகலம் (Width):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildUnitInputField(
                  label: _isIrregularSides ? 'அகலம் 1 (அடி)' : 'அடி (Ft)',
                  controller: _w1FtCtrl,
                  onChanged: (v) => _calculate(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUnitInputField(
                  label: _isIrregularSides ? 'அகலம் 1 (அங்குலம்)' : 'அங்குலம் (In)',
                  controller: _w1InCtrl,
                  onChanged: (v) => _calculate(),
                ),
              ),
            ],
          ),
          if (_isIrregularSides) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildUnitInputField(
                    label: 'அகலம் 2 (அடி)',
                    controller: _w2FtCtrl,
                    onChanged: (v) => _calculate(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildUnitInputField(
                    label: 'அகலம் 2 (அங்குலம்)',
                    controller: _w2InCtrl,
                    onChanged: (v) => _calculate(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Owner Details Input Card (உரிமையாளர் ஜென்ம நட்சத்திரம் & ராசி)
  Widget _buildOwnerDetailsInputCard() {
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
              const Icon(Icons.person_pin_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'உரிமையாளர் விவரங்கள் (Owner Profile)',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ஜென்ம நட்சத்திரம்:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedOwnerNakshatra,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5D1204)),
                          items: List.generate(27, (i) {
                            final n = GpVaasthuService.nakshatraList[i];
                            return DropdownMenuItem<int>(
                              value: n.number,
                              child: Text(
                                '${n.number}. ${n.name}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                              ),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedOwnerNakshatra = val);
                              _calculate();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ஜென்ம ராசி:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedOwnerRasi,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5D1204)),
                          items: List.generate(12, (i) {
                            final r = GpVaasthuService.rasiList[i];
                            return DropdownMenuItem<int>(
                              value: r.number,
                              child: Text(
                                '${r.number}. ${r.name}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                              ),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedOwnerRasi = val);
                              _calculate();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitInputField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
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
        onChanged: onChanged,
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

  // Helper Item for 26 Porutham Table
  List<_PoruthamTableRowItem> _get26PoruthamList(GpKuzhiResult res) {
    final String ownerGana = GpVaasthuService.nakshatraList[res.ownerNakshatra - 1].gana;
    final Map<String, dynamic> ganaMatch = GpVaasthuService.evaluateGanaMatch(res.nakshatra.gana, ownerGana);
    final bool isGanaGood = (ganaMatch['isGood'] as bool?) ?? false;
    final String ganaStatusStr = (ganaMatch['status'] as String?) ?? '';

    _PoruthamTableRowItem item({
      required int sNo,
      required String name,
      required String value,
      required String status,
      required String statusText,
      required bool isGood,
    }) {
      final String symbol = status == 'உ' ? '✓' : (status == 'ம' ? '=' : '✗');
      return _PoruthamTableRowItem(
        sNo: sNo,
        name: name,
        value: value,
        status: status,
        statusText: statusText,
        isGood: isGood,
        symbol: symbol,
      );
    }

    return [
      item(
        sNo: 1,
        name: 'கற்பம்',
        value: '${res.garbhamNumber} (${res.garbham.name.split(' ')[0]})',
        status: res.garbham.status.contains('மத்திமம்') ? 'ம' : (res.garbham.isGood ? 'உ' : 'அ'),
        statusText: res.garbham.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.garbham.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.garbham.isGood,
      ),
      item(
        sNo: 2,
        name: 'இலாபம்',
        value: '${res.aadhayamNumber}',
        status: res.aadhayam.isGood ? 'உ' : 'அ',
        statusText: res.aadhayam.isGood ? 'உத்தமம்' : 'அதமம்',
        isGood: res.aadhayam.isGood,
      ),
      item(
        sNo: 3,
        name: 'செலவு',
        value: '${res.virayamNumber}',
        status: res.virayam.status.contains('மத்திமம்') ? 'ம' : (res.virayam.isGood ? 'உ' : 'அ'),
        statusText: res.virayam.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.virayam.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.virayam.isGood,
      ),
      item(
        sNo: 4,
        name: 'யோனி',
        value: '${res.yoniNumber} (${res.yoni.name.split(' ')[0]})',
        status: res.yoni.status.contains('மத்திமம்') ? 'ம' : (res.yoni.isGood ? 'உ' : 'அ'),
        statusText: res.yoni.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.yoni.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.yoni.isGood,
      ),
      item(
        sNo: 5,
        name: 'நட்சத்திரம்',
        value: '${res.nakshatraNumber} (${res.nakshatra.name})',
        status: res.nakshatra.status.contains('மத்திமம்') ? 'ம' : (res.nakshatra.isGood ? 'உ' : 'அ'),
        statusText: res.nakshatra.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.nakshatra.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.nakshatra.isGood,
      ),
      item(
        sNo: 6,
        name: 'கிழமை',
        value: '${res.vaara.dayName.split(' ')[0]} (${res.vaaraNumber})',
        status: res.vaara.status.contains('மத்திமம்') ? 'ம' : (res.vaara.isGood ? 'உ' : 'அ'),
        statusText: res.vaara.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.vaara.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.vaara.isGood,
      ),
      item(
        sNo: 7,
        name: 'அம்சம்',
        value: '${res.amsaNumber} (${res.amsa.effect.replaceAll(' உண்டாகும்', '')})',
        status: res.amsa.status.contains('மத்திமம்') ? 'ம' : (res.amsa.isGood ? 'உ' : 'அ'),
        statusText: res.amsa.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.amsa.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.amsa.isGood,
      ),
      item(
        sNo: 8,
        name: 'வம்சம்',
        value: '${res.vamsamNumber} (${res.vamsam.name})',
        status: res.vamsam.status.contains('மத்திமம்') ? 'ம' : (res.vamsam.isGood ? 'உ' : 'அ'),
        statusText: res.vamsam.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.vamsam.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.vamsam.isGood,
      ),
      item(
        sNo: 9,
        name: 'திதி',
        value: '${res.thithi1.name.replaceAll('வ. ', 'வளர்.').replaceAll('தே. ', 'தேய்.')} / ${res.thithi2.name.replaceAll('வ. ', 'வளர்.').replaceAll('தே. ', 'தேய்.')}',
        status: res.thithi1.status.contains('மத்திமம்') ? 'ம' : (res.thithi1.isGood ? 'உ' : 'அ'),
        statusText: res.thithi1.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.thithi1.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.thithi1.isGood,
      ),
      item(
        sNo: 10,
        name: 'இராசி (மனைவி)',
        value: '${res.rasiNumber} (${res.rasi.name})',
        status: res.rasi.status.contains('மத்திமம்') ? 'ம' : (res.rasi.isGood ? 'உ' : 'அ'),
        statusText: res.rasi.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.rasi.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.rasi.isGood,
      ),
      item(
        sNo: 11,
        name: 'பூதம்',
        value: '${res.bootham1Number} (${res.bootham1.name.split(' ')[0]})',
        status: res.bootham1.status.contains('மத்திமம்') ? 'ம' : (res.bootham1.isGood ? 'உ' : 'அ'),
        statusText: res.bootham1.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.bootham1.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.bootham1.isGood,
      ),
      item(
        sNo: 12,
        name: 'கணம்',
        value: res.nakshatra.gana,
        status: ganaStatusStr.contains('மத்திமம்') ? 'ம' : (ganaStatusStr.contains('உத்தமம்') || isGanaGood ? 'உ' : 'அ'),
        statusText: ganaStatusStr.contains('மத்திமம்') ? 'மத்திமம்' : (ganaStatusStr.contains('உத்தமம்') || isGanaGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: isGanaGood,
      ),
      item(
        sNo: 13,
        name: 'நேத்திரம்',
        value: '${res.nethiram.eyes} கண் (${res.nethiram.title.split(' ')[0]})',
        status: res.nethiram.eyes == 2 ? 'உ' : (res.nethiram.eyes == 1 ? 'ம' : 'அ'),
        statusText: res.nethiram.eyes == 2 ? 'உத்தமம்' : (res.nethiram.eyes == 1 ? 'மத்திமம்' : 'அதமம்'),
        isGood: res.nethiram.eyes > 0,
      ),
      item(
        sNo: 14,
        name: 'வயது',
        value: '${res.age.age} (${res.age.status.split(' ')[0]})',
        status: res.age.age >= 51 ? 'உ' : (res.age.age >= 28 ? 'ம' : 'அ'),
        statusText: res.age.age >= 51 ? 'உத்தமம்' : (res.age.age >= 28 ? 'மத்திமம்' : 'அதமம்'),
        isGood: res.age.isGood,
      ),
      item(
        sNo: 15,
        name: 'தாராபலன்',
        value: '${res.tharaPhalan.remainder} (${res.tharaPhalan.tharaName})',
        status: res.tharaPhalan.status.contains('மத்திமம்') ? 'ம' : (res.tharaPhalan.isGood ? 'உ' : 'அ'),
        statusText: res.tharaPhalan.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.tharaPhalan.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.tharaPhalan.isGood,
      ),
      item(
        sNo: 16,
        name: 'சூத்திரம்',
        value: '${res.soothiramNumber} (${res.soothiram.name.split(' ')[0]})',
        status: res.soothiram.status.contains('மத்திமம்') || res.soothiram.number == 4 ? 'ம' : (res.soothiram.isGood ? 'உ' : 'அ'),
        statusText: res.soothiram.status.contains('மத்திமம்') || res.soothiram.number == 4 ? 'மத்திமம்' : (res.soothiram.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.soothiram.isGood,
      ),
      item(
        sNo: 17,
        name: 'நாமயோகம்',
        value: '${res.namaYogaNumber} (${res.namaYoga.name})',
        status: res.namaYoga.status.contains('மத்திமம்') ? 'ம' : (res.namaYoga.isGood ? 'உ' : 'அ'),
        statusText: res.namaYoga.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.namaYoga.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.namaYoga.isGood,
      ),
      item(
        sNo: 18,
        name: 'பஞ்சகம்',
        value: '${res.panchaka.number} (${res.panchaka.name})',
        status: res.panchaka.status.contains('மத்திமம்') ? 'ம' : (res.panchaka.isGood ? 'உ' : 'அ'),
        statusText: res.panchaka.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.panchaka.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.panchaka.isGood,
      ),
      item(
        sNo: 19,
        name: 'அமிர்தாதியோகம்',
        value: '(${res.amirthathiYoga.code}) ${res.amirthathiYoga.name.split(' ')[0]}',
        status: res.amirthathiYoga.status.contains('மத்திமம்') ? 'ம' : (res.amirthathiYoga.isGood ? 'உ' : 'அ'),
        statusText: res.amirthathiYoga.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.amirthathiYoga.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.amirthathiYoga.isGood,
      ),
      item(
        sNo: 20,
        name: 'கரணம்',
        value: '${res.karanaNumber} (${res.karana.name})',
        status: res.karana.status.contains('மத்திமம்') ? 'ம' : (res.karana.isGood ? 'உ' : 'அ'),
        statusText: res.karana.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.karana.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.karana.isGood,
      ),
      item(
        sNo: 21,
        name: 'சந்திரபலம்',
        value: '${res.chandraPhalan.number} (${res.chandraPhalan.name})',
        status: res.chandraPhalan.status.contains('மத்திமம்') ? 'ம' : (res.chandraPhalan.isGood ? 'உ' : 'அ'),
        statusText: res.chandraPhalan.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.chandraPhalan.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.chandraPhalan.isGood,
      ),
      item(
        sNo: 22,
        name: 'அ.இலட்சுமி',
        value: '${res.ashtaLakshmiNumber} (${res.ashtaLakshmi.name})',
        status: res.ashtaLakshmi.status.contains('மத்திமம்') ? 'ம' : (res.ashtaLakshmi.isGood ? 'உ' : 'அ'),
        statusText: res.ashtaLakshmi.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.ashtaLakshmi.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.ashtaLakshmi.isGood,
      ),
      item(
        sNo: 23,
        name: 'அ.திக்.பாலகர்',
        value: '${res.dikpalakarNumber} (${res.dikpalakar.name.split(' ')[0]})',
        status: res.dikpalakar.status.contains('மத்திமம்') ? 'ம' : (res.dikpalakar.isGood ? 'உ' : 'அ'),
        statusText: res.dikpalakar.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.dikpalakar.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.dikpalakar.isGood,
      ),
      item(
        sNo: 24,
        name: 'அ.திக்.தேவதை',
        value: '${res.athidevathaiNumber} (${res.athidevathai.name.split(' ')[0]})',
        status: res.athidevathai.status.contains('மத்திமம்') ? 'ம' : (res.athidevathai.isGood ? 'உ' : 'அ'),
        statusText: res.athidevathai.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.athidevathai.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.athidevathai.isGood,
      ),
      item(
        sNo: 25,
        name: 'புருஷ ராசி',
        value: '${res.purushaRasiNumber} (${res.purushaRasi.name} - ${res.purushaRasi.rasiType.split(' ')[0]})',
        status: res.purushaRasi.status.contains('மத்திமம்') ? 'ம' : (res.purushaRasi.isGood ? 'உ' : 'அ'),
        statusText: res.purushaRasi.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.purushaRasi.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.purushaRasi.isGood,
      ),
      item(
        sNo: 26,
        name: 'குண பலன்',
        value: '${res.gunaNumber} (${res.guna.name})',
        status: res.guna.status.contains('மத்திமம்') ? 'ம' : (res.guna.isGood ? 'உ' : 'அ'),
        statusText: res.guna.status.contains('மத்திமம்') ? 'மத்திமம்' : (res.guna.isGood ? 'உத்தமம்' : 'அதமம்'),
        isGood: res.guna.isGood,
      ),
    ];
  }

  // Result View Switcher (பொருத்தப் பட்டியல் vs விரிவான பலன்கள்)
  Widget _buildResultViewTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF5D1204).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedResultTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                decoration: BoxDecoration(
                  color: _selectedResultTab == 0 ? const Color(0xFF5D1204) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedResultTab == 0
                      ? [BoxShadow(color: const Color(0xFF5D1204).withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.checklist_rtl_rounded,
                      size: 16,
                      color: _selectedResultTab == 0 ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'பொருத்தப் பட்டியல் (26)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: _selectedResultTab == 0 ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedResultTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                decoration: BoxDecoration(
                  color: _selectedResultTab == 1 ? const Color(0xFF5D1204) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedResultTab == 1
                      ? [BoxShadow(color: const Color(0xFF5D1204).withValues(alpha: 0.25), blurRadius: 4, offset: const Offset(0, 2))]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize_rounded,
                      size: 16,
                      color: _selectedResultTab == 1 ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'விரிவான பலன்கள்',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: _selectedResultTab == 1 ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 26 Porutham Table Card (வரிசைப்படுத்தப்பட்ட 26 பொருத்தப் பலன்கள் பட்டியல்)
  Widget _buildPorutham26TableCard(GpKuzhiResult res) {
    final items = _get26PoruthamList(res);
    final int uCount = items.where((i) => i.status == 'உ').length;
    final int mCount = items.where((i) => i.status == 'ம').length;
    final int aCount = items.where((i) => i.status == 'அ').length;

    final int uPercent = uCount * 4;
    final int mPercent = mCount * 2;
    final int aPercent = aCount * 0;
    final int totalPercent = uPercent + mPercent + aPercent;

    final Color statusColor = totalPercent >= 60
        ? const Color(0xFF2E7D32)
        : (totalPercent >= 40 ? const Color(0xFFEF6C00) : const Color(0xFFC62828));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C1810), Color(0xFF5D1204)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: Color(0xFFFFE082), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'வரிசைப்படுத்தப்பட்ட 26 பொருத்தப் பலன்கள்',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFE082),
                        ),
                      ),
                      Text(
                        'ஆயாதி எண்: ${res.roundedAyadi} | மொத்த பலன்கள்: 26',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFF5D1204).withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text('#', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                ),
                SizedBox(width: 6),
                Expanded(
                  flex: 4,
                  child: Text('பொருத்தம்', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                ),
                SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Text('மதிப்பு / விவரம்', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                ),
                SizedBox(width: 4),
                SizedBox(
                  width: 34,
                  child: Text('நிலை', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                ),
                SizedBox(width: 4),
                SizedBox(
                  width: 32,
                  child: Text('முடிவு', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                ),
              ],
            ),
          ),

          // 26 Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final bool isEven = index.isEven;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isEven ? const Color(0xFFFAF6EE).withValues(alpha: 0.6) : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFB58D3D).withValues(alpha: 0.12), width: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    // S.No
                    SizedBox(
                      width: 28,
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5D1204).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            '${item.sNo}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D1204),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Name
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D1204),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Value & Result
                    Expanded(
                      flex: 5,
                      child: Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3E2723),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Status Badge (உ / ம / அ)
                    SizedBox(
                      width: 34,
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: item.status == 'உ'
                                ? const Color(0xFFE8F5E9)
                                : (item.status == 'ம' ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: item.status == 'உ'
                                  ? const Color(0xFF2E7D32)
                                  : (item.status == 'ம' ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              color: item.status == 'உ'
                                  ? const Color(0xFF2E7D32)
                                  : (item.status == 'ம' ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Symbol (✓ / = / ✗)
                    SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          item.symbol,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: item.status == 'உ' || item.symbol == '✓'
                                ? const Color(0xFF2E7D32)
                                : (item.status == 'ம' || item.symbol == '='
                                    ? const Color(0xFFEF6C00)
                                    : const Color(0xFFC62828)),
                            fontWeight: FontWeight.w900,
                            fontSize: item.symbol == '=' ? 17 : 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Summary Footer (Notebook style)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border(
                top: BorderSide(color: const Color(0xFFB58D3D).withValues(alpha: 0.35), width: 1.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.analytics_rounded, color: Color(0xFF5D1204), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'மொத்த பொருத்தம் சுருக்கம் (Summary)',
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D1204),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2E7D32), width: 1.2),
                        ),
                        child: Column(
                          children: [
                            const Text('உத்தமம் (உ) ✓', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                            const SizedBox(height: 2),
                            Text('$uCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32))),
                            const SizedBox(height: 1),
                            Text('$uCount × 4 = $uPercent%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEF6C00), width: 1.2),
                        ),
                        child: Column(
                          children: [
                            const Text('மத்திமம் (ம) =', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFEF6C00))),
                            const SizedBox(height: 2),
                            Text('$mCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFEF6C00))),
                            const SizedBox(height: 1),
                            Text('$mCount × 2 = $mPercent%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF6C00))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC62828), width: 1.2),
                        ),
                        child: Column(
                          children: [
                            const Text('அதமம் (அ) ✗', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                            const SizedBox(height: 2),
                            Text('$aCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFC62828))),
                            const SizedBox(height: 1),
                            Text('$aCount × 0 = 0%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Total Percentage Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: totalPercent >= 60
                          ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                          : (totalPercent >= 40 ? [const Color(0xFFE65100), const Color(0xFFEF6C00)] : [const Color(0xFFB71C1C), const Color(0xFFC62828)]),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'மொத்த பொருத்தம் சதவீதம்',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                totalPercent >= 60 ? '★ உத்தம சுப மனை' : (totalPercent >= 40 ? '★ மத்திம மனை' : '★ அதம மனை'),
                                style: const TextStyle(color: Color(0xFFFFE082), fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '$totalPercent%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'கணக்கீடு: ($uCount × 4%) + ($mCount × 2%) + ($aCount × 0%) = $totalPercent%',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Highlighted Ayadi Number Result Card (ஆயாதி எண்)
  Widget _buildAyadiResultCard(GpKuzhiResult res) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C1810), Color(0xFF5D1204)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE082).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${res.region.nameTa} முறை (ம.கோல்: ${res.region.kolInches})',
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFE082), size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'ஆயாதி எண் (Ayadi Number)',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Prominent Rounded Ayadi Number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${res.roundedAyadi}',
                style: GoogleFonts.outfit(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFE082),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'எண்',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Exact Decimal Subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'துருவ எண்: ${res.ayadiExact} (${res.ayadiExact >= res.ayadiNumber.floor() + 0.5 ? '≥ 0.5 அடுத்த முழு எண்' : '< 0.5 முந்தைய முழு எண்'})',
              style: const TextStyle(
                color: Color(0xFFFFE082),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildResultMiniStat('சுற்றளவு (அடி)', '${res.perimeterFt.toStringAsFixed(2)} அடி'),
              ),
              Container(height: 32, width: 1, color: Colors.white24),
              Expanded(
                child: _buildResultMiniStat('சுற்றளவு (அங்குலம்)', '${res.perimeterInches.toStringAsFixed(0)} அங்'),
              ),
              Container(height: 32, width: 1, color: Colors.white24),
              Expanded(
                child: _buildResultMiniStat('துருவ எண்', '${res.ayadiExact}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Highlighted Garbham Result Card (கெர்ப்ப பலன்)
  Widget _buildGarbhamResultCard(GpKuzhiResult res) {
    final garbham = res.garbham;
    final isAuspicious = garbham.isGood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAuspicious ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isAuspicious ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Properly constrained with Expanded)
          Row(
            children: [
              Text(garbham.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'கெர்ப்ப பலன் (Garbham)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAuspicious
                      ? const Color(0xFFE8F5E9)
                      : (garbham.status.contains('மத்திமம்') ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAuspicious
                        ? const Color(0xFF2E7D32)
                        : (garbham.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                  ),
                ),
                child: Text(
                  garbham.status,
                  style: TextStyle(
                    color: isAuspicious
                        ? const Color(0xFF2E7D32)
                        : (garbham.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Garbham Title Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAuspicious
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : (garbham.status.contains('மத்திமம்')
                        ? [const Color(0xFFE65100), const Color(0xFFF57C00)]
                        : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${garbham.number}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        garbham.name,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'திசை: ${garbham.direction}  |  அதிபதி: ${garbham.deity}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Effect description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFB58D3D), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'பலன் விவரம்:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A6855),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        garbham.effect,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D1204),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: ${res.roundedAyadi} % 8 = மீதம் ${res.garbhamNumber}',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF7A6855),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 5. Highlighted Yoni Result Card (யோனிப் பலன்)
  Widget _buildYoniResultCard(GpKuzhiResult res) {
    final yoni = res.yoni;
    final isGood = yoni.isGood;
    final int multiple8 = res.yoniNumber == 8
        ? (res.yoniTotal - 8)
        : ((res.yoniTotal ~/ 8) * 8);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Properly constrained with Expanded)
          Row(
            children: [
              Text(yoni.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'யோனிப் பலன் (Yoni)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  ),
                ),
                child: Text(
                  yoni.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Yoni Title Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.yoniNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${yoni.number}. ${yoni.name}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (yoni.enemyDirection.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '(${yoni.enemyDirection})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFFE082),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Effect description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isGood ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                  color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'பலன் விவரம்:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A6855),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        yoni.effect,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 10),

            // Formula & Step Details Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'யோனிக் கணக்கீடு முறை:',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A6855),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 3 = ${res.roundedAyadi} × 3 = ${res.yoniTotal}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D1204),
                    ),
                  ),
                  Text(
                    '• 8 இன் மடங்கு கழிவு = ${res.yoniTotal} - $multiple8 = ${res.yoniNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D1204),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.yoniNumber}) ${yoni.name} — ${yoni.effect}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 3 = ${res.yoniTotal}) % 8 = மீதம் ${res.yoniNumber}',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF7A6855),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 6. Highlighted Aadhayam Result Card (ஆதாயப் பலன்)
  Widget _buildAadhayamResultCard(GpKuzhiResult res) {
    final aadhayam = res.aadhayam;
    final int multiple12 = res.aadhayamNumber == 12
        ? (res.aadhayamTotal - 12)
        : ((res.aadhayamTotal ~/ 12) * 12);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFB58D3D),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58D3D).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Properly constrained with Expanded)
          Row(
            children: [
              Text(aadhayam.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ஆதாயம் (Aadhayam)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFA000),
                  ),
                ),
                child: const Text(
                  'சுப ஆதாயம்',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Aadhayam Title Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8D6E63), Color(0xFF5D1204)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE082).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.aadhayamNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFE082),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ஆதாயம் எண்: ${res.aadhayamNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        aadhayam.effect,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFE082),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 14),

            // Formula & Step Details Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'ஆதாயக் கணக்கீடு முறை:',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A6855),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 8 = ${res.roundedAyadi} × 8 = ${res.aadhayamTotal}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D1204),
                    ),
                  ),
                  Text(
                    '• 12 இன் மடங்கு கழிவு = ${res.aadhayamTotal} - $multiple12 = ${res.aadhayamNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D1204),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.aadhayamNumber}) ${aadhayam.effect}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 8 = ${res.aadhayamTotal}) % 12 = மீதம் ${res.aadhayamNumber}',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF7A6855),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 6. Highlighted Virayam Result Card (விரையப் பலன்)
  Widget _buildVirayamResultCard(GpKuzhiResult res) {
    final virayam = res.virayam;
    final int multiple10 = res.virayamNumber == 10
        ? (res.virayamTotal - 10)
        : ((res.virayamTotal ~/ 10) * 10);
    final isGood = virayam.isGood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(virayam.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'விரையம் (Virayam)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGood
                      ? const Color(0xFFE8F5E9)
                      : (virayam.status.contains('மத்திமம்') ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isGood
                        ? const Color(0xFF2E7D32)
                        : (virayam.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                  ),
                ),
                child: Text(
                  virayam.status,
                  style: TextStyle(
                    color: isGood
                        ? const Color(0xFF2E7D32)
                        : (virayam.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Virayam Title Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : (virayam.status.contains('மத்திமம்')
                        ? [const Color(0xFFE65100), const Color(0xFFF57C00)]
                        : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.virayamNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'விரையம் எண்: ${res.virayamNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        virayam.effect,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 14),

            // Formula & Step Details Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'விரையக் கணக்கீடு முறை:',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A6855),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 9 = ${res.roundedAyadi} × 9 = ${res.virayamTotal}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D1204),
                    ),
                  ),
                  Text(
                    '• 10 இன் மடங்கு கழிவு = ${res.virayamTotal} - $multiple10 = ${res.virayamNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D1204),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.virayamNumber}) ${virayam.effect}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 9 = ${res.virayamTotal}) % 10 = மீதம் ${res.virayamNumber}',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF7A6855),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 7. Aadhayam vs Virayam Comparison Rule Card
  Widget _buildAadhayamVirayamComparisonCard(GpKuzhiResult res) {
    final bool isAadhayamGreater = res.isAadhayamGreater;
    final bool isEqual = res.aadhayamNumber == res.virayamNumber;

    final Color statusColor = isAadhayamGreater
        ? const Color(0xFF2E7D32)
        : (isEqual ? const Color(0xFFEF6C00) : const Color(0xFFC62828));
    final Color bgColor = isAadhayamGreater
        ? const Color(0xFFE8F5E9)
        : (isEqual ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
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
              Icon(
                isAadhayamGreater ? Icons.verified_rounded : (isEqual ? Icons.info_rounded : Icons.warning_amber_rounded),
                color: statusColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ஆதாயம் vs விரையம் ஒப்பீடு',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAadhayamGreater ? 'சுப யோகம்' : (isEqual ? 'மத்திமம்' : 'கவனம்'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('ஆதாயம்', style: TextStyle(fontSize: 11, color: Color(0xFF7A6855), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${res.aadhayamNumber}',
                      style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF2E7D32)),
                    ),
                  ],
                ),
                Text(
                  isAadhayamGreater ? '>' : (isEqual ? '=' : '<'),
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: statusColor),
                ),
                Column(
                  children: [
                    const Text('விரையம்', style: TextStyle(fontSize: 11, color: Color(0xFF7A6855), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${res.virayamNumber}',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isAadhayamGreater ? const Color(0xFF7A6855) : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isAadhayamGreater
                ? '✓ சாஸ்திர விதிப்படி ஆதாயத்தை (${res.aadhayamNumber}) விட விரையம் (${res.virayamNumber}) குறைவாக உள்ளது. இது மிகுந்த சுப பலனையும் தன விருத்தியையும் தரும்.'
                : (isEqual
                    ? '※ ஆதாயமும் (${res.aadhayamNumber}) விரையமும் (${res.virayamNumber}) சமமாக உள்ளது. வரவு செலவு சமநிலையில் இருக்கும்.'
                    : '⚠ சாஸ்திர விதிப்படி ஆதாயத்தை (${res.aadhayamNumber}) விட விரையம் (${res.virayamNumber}) அதிகமாக உள்ளது. [ஆதாயத்தை விட விரையம் குறைவாக இருக்க வேண்டும்]'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // 8. Highlighted Vaaram Result Card (5. வாரப்பலன்)
  Widget _buildVaaraResultCard(GpKuzhiResult res) {
    final vaara = res.vaara;
    final isGood = vaara.isGood;
    final int multiple7 = res.vaaraNumber == 7
        ? (res.vaaraTotal - 7)
        : ((res.vaaraTotal ~/ 7) * 7);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : (vaara.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(vaara.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'வாரப்பலன் (Vaaram)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGood
                      ? const Color(0xFFE8F5E9)
                      : (vaara.status.contains('மத்திமம்') ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isGood
                        ? const Color(0xFF2E7D32)
                        : (vaara.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                  ),
                ),
                child: Text(
                  vaara.status,
                  style: TextStyle(
                    color: isGood
                        ? const Color(0xFF2E7D32)
                        : (vaara.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : (vaara.status.contains('மத்திமம்')
                        ? [const Color(0xFFE65100), const Color(0xFFF57C00)]
                        : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.vaaraNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'கிழமை: ${vaara.dayName}',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vaara.effect,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFFFE082),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'வாரப்பலன் கணக்கீடு முறை:',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7A6855),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 9 = ${res.roundedAyadi} × 9 = ${res.vaaraTotal}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 7 இன் மடங்கு கழிவு = ${res.vaaraTotal} - $multiple7 = ${res.vaaraNumber} (${vaara.dayName})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.vaaraNumber}) ${vaara.dayName} — ${vaara.effect}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF2E7D32) : (vaara.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 9 = ${res.vaaraTotal}) % 7 = மீதம் ${res.vaaraNumber}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 9. Highlighted Amsam Result Card (6. அம்ச பலன்)
  Widget _buildAmsaResultCard(GpKuzhiResult res) {
    final amsa = res.amsa;
    final isGood = amsa.isGood;
    final int multiple9 = res.amsaNumber == 9
        ? (res.amsaTotal - 9)
        : ((res.amsaTotal ~/ 9) * 9);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(amsa.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'அம்ச பலன் (Amsam)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  amsa.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.amsaNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'அம்ச எண்: ${res.amsaNumber}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        amsa.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'அம்சக் கணக்கீடு முறை:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 4 = ${res.roundedAyadi} × 4 = ${res.amsaTotal}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 9 இன் மடங்கு கழிவு = ${res.amsaTotal} - $multiple9 = ${res.amsaNumber}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.amsaNumber}) ${amsa.effect}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 4 = ${res.amsaTotal}) % 9 = மீதம் ${res.amsaNumber}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 10. Highlighted Nakshatra & Gana Result Card (7. நட்சத்திர பலன் & 11. கணப் பலன்)
  Widget _buildNakshatraAndGanaResultCard(GpKuzhiResult res) {
    final nak = res.nakshatra;
    final isGood = nak.isGood;
    final int multiple27 = res.nakshatraNumber == 27
        ? (res.nakshatraTotal - 27)
        : ((res.nakshatraTotal ~/ 27) * 27);

    final ownerStar = GpVaasthuService.nakshatraList[_selectedOwnerNakshatra - 1];
    final ganaVerdict = GpVaasthuService.evaluateGanaMatch(nak.gana, ownerStar.gana);
    final bool isGanaGood = ganaVerdict['isGood'] as bool;
    final String ganaStatus = ganaVerdict['status'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : (nak.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(nak.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'நட்சத்திர பலன் & கணம்',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGood
                      ? const Color(0xFFE8F5E9)
                      : (nak.status.contains('மத்திமம்') ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isGood
                        ? const Color(0xFF2E7D32)
                        : (nak.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                  ),
                ),
                child: Text(
                  nak.status,
                  style: TextStyle(
                    color: isGood
                        ? const Color(0xFF2E7D32)
                        : (nak.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : (nak.status.contains('மத்திமம்')
                        ? [const Color(0xFFE65100), const Color(0xFFF57C00)]
                        : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.nakshatraNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${nak.number}. ${nak.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'மனை கணம்: ${nak.gana}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFFFE082), fontWeight: FontWeight.bold),
                      ),
                      Text(
                        nak.effect,
                        style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'நட்சத்திரக் கணக்கீடு முறை:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 8 = ${res.roundedAyadi} × 8 = ${res.nakshatraTotal}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 27 இன் மடங்கு கழிவு = ${res.nakshatraTotal} - $multiple27 = ${res.nakshatraNumber} (${nak.name})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.nakshatraNumber}) ${nak.name} [${nak.gana}] — ${nak.effect}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF2E7D32) : (nak.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // 11. Gana Compatibility Interactive Match Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isGanaGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isGanaGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isGanaGood ? Icons.verified_rounded : Icons.info_outline_rounded,
                      color: isGanaGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '11. கணப் பலன் பொருத்தம் (Gana Match)',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isGanaGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ganaStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'உரிமையாளர் நட்சத்திரம்: ',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedOwnerNakshatra,
                            isDense: true,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                            items: GpVaasthuService.nakshatraList.map((n) {
                              return DropdownMenuItem<int>(
                                value: n.number,
                                child: Text('${n.number}. ${n.name} (${n.gana.split(' ')[0]})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedOwnerNakshatra = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• மனை: ${nak.name} (${nak.gana})  ↔  உரிமையாளர்: ${ownerStar.name} (${ownerStar.gana})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                ),
                const SizedBox(height: 2),
                Text(
                  ganaVerdict['effect'] as String,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isGanaGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 8 = ${res.nakshatraTotal}) % 27 = மீதம் ${res.nakshatraNumber}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 11. Highlighted Vamsam Result Card (8. வம்சம் பலன்)
  Widget _buildVamsamResultCard(GpKuzhiResult res) {
    final vamsam = res.vamsam;
    final int multiple4 = res.vamsamNumber == 4
        ? (res.vamsamTotal - 4)
        : ((res.vamsamTotal ~/ 4) * 4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58D3D).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(vamsam.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'வம்சம் பலன் (Vamsam)',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFA000)),
                ),
                child: Text(
                  vamsam.status,
                  style: const TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8D6E63), Color(0xFF5D1204)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE082).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.vamsamNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFE082),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vamsam.name,
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFFFE082)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vamsam.effect,
                        style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'வம்சக் கணக்கீடு முறை:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 9 = ${res.roundedAyadi} × 9 = ${res.vamsamTotal}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 4 இன் மடங்கு கழிவு = ${res.vamsamTotal} - $multiple4 = ${res.vamsamNumber} (${vamsam.name})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.vamsamNumber}) ${vamsam.name} — ${vamsam.effect}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 9 = ${res.vamsamTotal}) % 4 = மீதம் ${res.vamsamNumber}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 12. Highlighted Thithi Result Card (9. திதிப் பலன் - மரபு 1 & 2)
  Widget _buildThithiResultCard(GpKuzhiResult res) {
    final t1 = res.thithi1;
    final t2 = res.thithi2;
    final int multiple30_1 = res.thithi1Number == 30 ? (res.thithi1Total - 30) : ((res.thithi1Total ~/ 30) * 30);
    final int multiple30_2 = res.thithi2Number == 30 ? (res.thithi2Total - 30) : ((res.thithi2Total ~/ 30) * 30);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58D3D).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌓', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'திதிப் பலன் (Thithi)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFA000)),
                ),
                child: const Text(
                  'வளர்பிறை / தேய்பிறை',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Method 1 (× 4) Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: t1.isGood ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)] : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t1.iconEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'முதல் மரபு (× 4): ${t1.name}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '[${t1.paksha}]',
                            style: const TextStyle(color: Color(0xFFFFE082), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('பலன்: ${t1.effect} (${t1.status})', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      if (_showCalculationDetails)
                        Text(
                          'கணக்கீடு: ${res.roundedAyadi} × 4 = ${res.thithi1Total} | கழிவு $multiple30_1 = ${res.thithi1Number}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Method 2 (× 9) Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: t2.isGood ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)] : [const Color(0xFFC62828), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t2.iconEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'இரண்டாவது மரபு (× 9): ${t2.name}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '[${t2.paksha}]',
                            style: const TextStyle(color: Color(0xFFFFE082), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('பலன்: ${t2.effect} (${t2.status})', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      if (_showCalculationDetails)
                        Text(
                          'கணக்கீடு: ${res.roundedAyadi} × 9 = ${res.thithi2Total} | கழிவு $multiple30_2 = ${res.thithi2Number}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '※ வளர்பிறை (1-15) உத்தமம் / தேய்பிறை (16-30) மத்திமம்',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  // 13. Highlighted Rasi Result Card (10. இராசி பலன்)
  Widget _buildRasiResultCard(GpKuzhiResult res) {
    final rasi = res.rasi;
    final int multiple12 = res.rasiNumber == 12
        ? (res.rasiTotal - 12)
        : ((res.rasiTotal ~/ 12) * 12);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58D3D).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rasi.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'இராசி பலன் (Rasi)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFA000)),
                ),
                child: Text(
                  rasi.status,
                  style: const TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8D6E63), Color(0xFF5D1204)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE082).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.rasiNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFE082),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rasi.shortName} (${rasi.name})',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFFFE082)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rasi.effect,
                        style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'இராசிக் கணக்கீடு முறை:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 4 = ${res.roundedAyadi} × 4 = ${res.rasiTotal}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 12 இன் மடங்கு கழிவு = ${res.rasiTotal} - $multiple12 = ${res.rasiNumber} (${rasi.name})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.rasiNumber}) ${rasi.name} — ${rasi.effect}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 4 = ${res.rasiTotal}) % 12 = மீதம் ${res.rasiNumber}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 14. Highlighted Age Result Card (10 கூடுதல். வயது பலன்)
  Widget _buildAgeResultCard(GpKuzhiResult res) {
    final age = res.age;
    final isGood = age.isGood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(age.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'வயது பலன் (Age Phalam)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00)),
                ),
                child: Text(
                  age.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)] : [const Color(0xFFE65100), const Color(0xFFF57C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.ageNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${res.ageNumber} வயது (பிரிவு: ${age.category})',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        age.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'வயதுக் கணக்கீடு முறை & சாஸ்திர விதிகள்:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 27 = ${res.roundedAyadi} × 27 = ${res.ageTotal}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 100 இன் மடங்கு கழிவு = ${res.ageTotal} % 100 = ${res.ageNumber} வயது',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const Divider(height: 12),
                  const Text('• 1 – 27: சகல பொருத்தங்கள் இருந்தால் நன்மை, இல்லை என்றால் அதர்மம்', style: TextStyle(fontSize: 11, color: Color(0xFF5D1204))),
                  const Text('• 28 – 50: மத்திமம்', style: TextStyle(fontSize: 11, color: Color(0xFF5D1204))),
                  const Text('• 51 – 100: உத்தமம்', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 27 = ${res.ageTotal}) % 100 = மீதம் ${res.ageNumber}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 15. Highlighted Purusha Rasi Result Card (12. புருஷ இராசி பலன்)
  Widget _buildPurushaRasiResultCard(GpKuzhiResult res) {
    final purusha = res.purushaRasi;
    final isGood = purusha.isGood;
    final int multiple12 = res.purushaRasiNumber == 12
        ? (res.purushaRasiTotal - 12)
        : ((res.purushaRasiTotal ~/ 12) * 12);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(purusha.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'புருஷ இராசி பலன் (Purusha Rasi)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  purusha.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.purushaRasiNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${purusha.shortName} (${purusha.name}) — ${purusha.rasiType}',
                        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        purusha.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'புருஷ இராசிக் கணக்கீடு முறை:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 7 = ${res.roundedAyadi} × 7 = ${res.purushaRasiTotal}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 12 இன் மடங்கு கழிவு = ${res.purushaRasiTotal} - $multiple12 = ${res.purushaRasiNumber} (${purusha.name})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.purushaRasiNumber}) ${purusha.rasiType} ${purusha.name} — ${purusha.effect}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                  const Divider(height: 12),
                  const Text('• சர இராசி (1 மே, 4 கட, 7 து, 10 ம): நன்மை', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                  const Text('• ஸ்திர இராசி (2 ரி, 5 சி, 8 வி, 11 கு): தீமை', style: TextStyle(fontSize: 11, color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                  const Text('• உபய இராசி (3 மி, 6 கன், 9 த, 12 மீ): நன்மை', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 7 = ${res.purushaRasiTotal}) % 12 = மீதம் ${res.purushaRasiNumber}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 16. Highlighted Boothams Result Card (13. பூதம் பலன் - முறை 1 & முறை 2)
  Widget _buildBoothamsResultCard(GpKuzhiResult res) {
    final b1 = res.bootham1;
    final b2 = res.bootham2;
    final int multiple5_1 = res.bootham1Number == 5 ? (res.bootham1Total - 5) : ((res.bootham1Total ~/ 5) * 5);
    final int multiple5_2 = res.bootham2Number == 5 ? (res.bootham2Total - 5) : ((res.bootham2Total ~/ 5) * 5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58D3D).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌍', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'பூதம் பலன் (Boothams / Elements)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFA000)),
                ),
                child: const Text(
                  'முறை 1 & 2',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Method 1 (× 3) Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: b1.isGood ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)] : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b1.iconEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. முறை 1 (× 3): ${b1.number} – ${b1.name}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text('பலன்: ${b1.effect} (${b1.status})', style: const TextStyle(color: Color(0xFFFFE082), fontSize: 12, fontWeight: FontWeight.w600)),
                      if (_showCalculationDetails)
                        Text(
                          'கணக்கீடு: ${res.roundedAyadi} × 3 = ${res.bootham1Total} | கழிவு $multiple5_1 = ${res.bootham1Number}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Method 2 (× 9) Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: b2.isGood ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)] : [const Color(0xFFC62828), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b2.iconEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2. முறை 2 (× 9): ${b2.number} – ${b2.name}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text('பலன்: ${b2.effect} (${b2.status})', style: const TextStyle(color: Color(0xFFFFE082), fontSize: 12, fontWeight: FontWeight.w600)),
                      if (_showCalculationDetails)
                        Text(
                          'கணக்கீடு: ${res.roundedAyadi} × 9 = ${res.bootham2Total} | கழிவு $multiple5_2 = ${res.bootham2Number}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF6EE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('பூதங்களின் சாஸ்திர பலன் விதிகள்:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855))),
                SizedBox(height: 4),
                Text('• 1. நிலம் (பூமி) — செல்வம் உண்டாகும் (சுபம்)', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                Text('• 2. நீர் (அப்பு) — காரிய வெற்றி உண்டாகும் (சுபம்)', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                Text('• 3. நெருப்பு (தேயு) — பயம் உண்டாகும் (தீமை)', style: TextStyle(fontSize: 11, color: Color(0xFFC62828))),
                Text('• 4. காற்று (வாயு) — நன்மை உண்டாகும் (சுபம்)', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                Text('• 5. ஆகாயம் (விண்) — விரையம் உண்டாகும் (தீமை)', style: TextStyle(fontSize: 11, color: Color(0xFFC62828))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 17. Highlighted Soothiram Result Card (14. சூத்திரம் பலன்)
  Widget _buildSoothiramResultCard(GpKuzhiResult res) {
    final soothiram = res.soothiram;
    final isGood = soothiram.isGood;
    final int multiple5 = res.soothiramNumber == 5
        ? (res.soothiramTotal - 5)
        : ((res.soothiramTotal ~/ 5) * 5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : (soothiram.number == 4 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(soothiram.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'சூத்திரம் பலன் (Sutra Phalam)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood
                      ? const Color(0xFFE8F5E9)
                      : (soothiram.number == 4 ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isGood
                        ? const Color(0xFF2E7D32)
                        : (soothiram.number == 4 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                  ),
                ),
                child: Text(
                  soothiram.status,
                  style: TextStyle(
                    color: isGood
                        ? const Color(0xFF2E7D32)
                        : (soothiram.number == 4 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : (soothiram.number == 4
                        ? [const Color(0xFFE65100), const Color(0xFFF57C00)]
                        : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.soothiramNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${res.soothiramNumber} – ${soothiram.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        soothiram.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'சூத்திரக் கணக்கீடு முறை & சாஸ்திர விதிகள்:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• ஆயாதி எண் × 7 = ${res.roundedAyadi} × 7 = ${res.soothiramTotal}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 5 இன் மடங்கு கழிவு = ${res.soothiramTotal} - $multiple5 = ${res.soothiramNumber} (${soothiram.name})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ (${res.soothiramNumber}) ${soothiram.name} — ${soothiram.effect}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF2E7D32) : (soothiram.number == 4 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    ),
                  ),
                  const Divider(height: 12),
                  const Text('• 1. பால சூத்திரம் = உத்தமம்', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  const Text('• 2. யௌவன சூத்திரம் = சுபம்', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  const Text('• 3. கௌமார சூத்திரம் = நன்மை', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  const Text('• 4. விருத்த சூத்திரம் = துன்பம்', style: TextStyle(fontSize: 11, color: Color(0xFFEF6C00))),
                  const Text('• 5. மரண சூத்திரம் = பயம்', style: TextStyle(fontSize: 11, color: Color(0xFFC62828))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'கணக்கீடு: (${res.roundedAyadi} × 7 = ${res.soothiramTotal}) % 5 = மீதம் ${res.soothiramNumber}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 18. Highlighted Nethiram Result Card (15. நேத்திர பலன்)
  Widget _buildNethiramResultCard(GpKuzhiResult res) {
    final nethiram = res.nethiram;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: nethiram.eyes == 2
              ? const Color(0xFF2E7D32)
              : (nethiram.eyes == 1 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (nethiram.eyes == 2
                    ? const Color(0xFF2E7D32)
                    : (nethiram.eyes == 1 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)))
                .withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(nethiram.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'நேத்திர பலன் (Nethiram / Eyes)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: nethiram.eyes == 2
                      ? const Color(0xFFE8F5E9)
                      : (nethiram.eyes == 1 ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: nethiram.eyes == 2
                        ? const Color(0xFF2E7D32)
                        : (nethiram.eyes == 1 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                  ),
                ),
                child: Text(
                  nethiram.status,
                  style: TextStyle(
                    color: nethiram.eyes == 2
                        ? const Color(0xFF2E7D32)
                        : (nethiram.eyes == 1 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: nethiram.eyes == 2
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : (nethiram.eyes == 1
                        ? [const Color(0xFFE65100), const Color(0xFFF57C00)]
                        : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${nethiram.eyes}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nethiram.title,
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nethiram.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'நேத்திரக் கணக்கீடு முறை & சாஸ்திர விதிகள்:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• 1. வாரப்பலன் கிழமை எண் = ${res.vaaraNumber} (${res.vaara.dayName})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 2. வார நட்சத்திரம் (வார எண் × 3) = ${res.vaaraNumber} × 3 = ${nethiram.startStarNumber} (${nethiram.startStarName})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 3. ஆயாதி மனை நட்சத்திரம் = ${res.nakshatraNumber} (${res.nakshatra.name})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const Divider(height: 12),
                  Text('• 1 கண் பிரிவு (அடுத்த 9 நட்சத்): ${nethiram.range1Description}', style: const TextStyle(fontSize: 11, color: Color(0xFF7A6855))),
                  Text('• 2 கண் பிரிவு (அடுத்த 12 நட்சத்): ${nethiram.range2Description}', style: const TextStyle(fontSize: 11, color: Color(0xFF7A6855))),
                  Text('• 0 கண் பிரிவு (கடைசி 6 நட்சத்): ${nethiram.range3Description}', style: const TextStyle(fontSize: 11, color: Color(0xFF7A6855))),
                  const SizedBox(height: 4),
                  Text(
                    '➔ பொருந்திய பிரிவு: ${nethiram.matchedRange}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: nethiram.eyes == 2
                          ? const Color(0xFF2E7D32)
                          : (nethiram.eyes == 1 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                '※ 2 கண் = உத்தமம் / 1 கண் = மத்திமம் / 0 கண் = அதமம் (தீமை)',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 19. Highlighted Amirthathi Yoga Result Card (16. அமிர்தாதி யோக பலன்)
  Widget _buildAmirthathiYogaResultCard(GpKuzhiResult res) {
    final yoga = res.amirthathiYoga;
    final isGood = yoga.isGood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(yoga.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'அமிர்தாதி யோக பலன் (Amirthathi Yogam)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  yoga.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    yoga.code,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${yoga.name} (${yoga.code})',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        yoga.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'யோகக் கணக்கீடு முறை & சாஸ்திர விதிகள்:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• 1. வாரப்பலன் கிழமை = ${res.vaaraNumber} (${yoga.vaaraDayName})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  Text(
                    '• 2. நட்சத்திர பலன் = ${res.nakshatraNumber} (${yoga.nakshatraName})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '➔ யோக முடிவு: (${yoga.code}) ${yoga.name} — ${yoga.effect}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                  const Divider(height: 12),
                  const Text('• அ – அமிர்த யோகம் ➔ நன்மை / உத்தமம் (சகல காரிய சித்தி)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  const Text('• சி – சித்த யோகம் ➔ நன்மை / உத்தமம் (எண்ணிய காரியம் ஜெயம்)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  const Text('• ம – மரண யோகம் ➔ தீமை / அதமம் (அசுபம் / தன நஷ்டம்)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                  const Text('• பி – பிரபலாரிஷ்ட யோகம் ➔ தீமை / அதமம் (கிழமை பிறந்த நட்சத்திர தோஷம்)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                '※ ஆயாதி வாரமும் நட்சத்திரமும் இணைத்து அமிர்தாதி யோகம் கணிக்கப்படுகிறது.',
                style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 17. Highlighted Thara Phalan Result Card (17. தாரா பலன்)
  Widget _buildTharaPhalanResultCard(GpKuzhiResult res) {
    final thara = res.tharaPhalan;
    final isGood = thara.isGood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(thara.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'தாரா பலன் (Thara Phalan)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  thara.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${thara.remainder}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thara.tharaName,
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        thara.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'தாரா பலன் கணிதம் & சாஸ்திர விதிகள்:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• 1. உரிமையாளர் நட்சத்திரம் = ${thara.ownerNakshatraNumber} (${thara.ownerNakshatraName})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 2. ஆயாதி மனை நட்சத்திரம் = ${thara.houseNakshatraNumber} (${thara.houseNakshatraName})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 3. இடைப்பட்ட தூரம் = ${thara.count} நட்சத்திரங்கள்', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 4. 9 ஆல் வகுத்த மீதம் = ${thara.count} % 9 = ${thara.remainder} ➔ ${thara.tharaName}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                  const Divider(height: 12),
                  const Text('• 1, 3, 5, 7 ➔ தீமை தரும் (ஜென்மம், விபத்து, பிரத்யக், வதை)', style: TextStyle(fontSize: 11, color: Color(0xFFC62828))),
                  const Text('• 2, 4, 6, 8, 9(0) ➔ நன்மை தரும் (சம்பத்து, க்ஷேமம், சாதகம், மைத்ரம், பரம மைத்ரம்)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 18. Highlighted Karana Result Card (18. கரணப் பலன்)
  Widget _buildKaranaResultCard(GpKuzhiResult res) {
    final karana = res.karana;
    final isGood = karana.isGood;
    final int multiple11 = res.karanaNumber == 11 ? (res.karanaTotal - 11) : ((res.karanaTotal ~/ 11) * 11);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(karana.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'கரணப் பலன் (Karana Phalan)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  karana.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.karanaNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${res.karanaNumber} – ${karana.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        karana.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'கரணக் கணிதம்: (${res.roundedAyadi} × 5) % 11',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• ${res.roundedAyadi} × 5 = ${res.karanaTotal}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 11 இன் மடங்கு கழிவு = ${res.karanaTotal} - $multiple11 = ${res.karanaNumber} (${karana.name})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  const SizedBox(height: 4),
                  Text('➔ (${res.karanaNumber}) ${karana.name} — ${karana.effect}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 19. Highlighted Chandra Phalan Result Card (19. சந்திர பலன்)
  Widget _buildChandraPhalanResultCard(GpKuzhiResult res) {
    final chandra = res.chandraPhalan;
    final isGood = chandra.isGood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : (chandra.number == 9 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(chandra.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'சந்திர பலன் (Chandra Phalan)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : (chandra.number == 9 ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : (chandra.number == 9 ? const Color(0xFFEF6C00) : const Color(0xFFC62828))),
                ),
                child: Text(
                  chandra.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : (chandra.number == 9 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : (chandra.number == 9
                        ? [const Color(0xFFE65100), const Color(0xFFF57C00)]
                        : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${chandra.number}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${chandra.number} – ${chandra.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chandra.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• 1. உரிமையாளர் ராசி = ${chandra.ownerRasiNumber} (${chandra.ownerRasiName})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 2. ஆயாதி மனை ராசி = ${chandra.houseRasiNumber} (${chandra.houseRasiName})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 3. சந்திர பலன் எண் = (${chandra.houseRasiNumber} - ${chandra.ownerRasiNumber} + 12) % 12 + 1 = ${chandra.number}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  const SizedBox(height: 4),
                  Text('➔ (${chandra.number}) ${chandra.name} — ${chandra.effect}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 20. Highlighted Ashta Lakshmi Result Card (20. அஷ்டலட்சுமி பலன்)
  Widget _buildAshtaLakshmiResultCard(GpKuzhiResult res) {
    final lakshmi = res.ashtaLakshmi;
    final int multiple8 = res.ashtaLakshmiNumber == 8 ? (res.ashtaLakshmiTotal - 8) : ((res.ashtaLakshmiTotal ~/ 8) * 8);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(lakshmi.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'அஷ்டலட்சுமி பலன் (Ashta Lakshmi)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2E7D32)),
                ),
                child: Text(
                  lakshmi.status,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.ashtaLakshmiNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${res.ashtaLakshmiNumber} – ${lakshmi.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lakshmi.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'அஷ்டலட்சுமி கணிதம்: (${res.roundedAyadi} × 3) % 8',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• ${res.roundedAyadi} × 3 = ${res.ashtaLakshmiTotal}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 8 இன் மடங்கு கழிவு = ${res.ashtaLakshmiTotal} - $multiple8 = ${res.ashtaLakshmiNumber} (${lakshmi.name})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  const SizedBox(height: 4),
                  Text('➔ (${res.ashtaLakshmiNumber}) ${lakshmi.name} — ${lakshmi.effect}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 21. Highlighted Panchaka Result & Pariharam Card (21. பஞ்சகப் பலன் & பரிகாரம்)
  Widget _buildPanchakaResultCard(GpKuzhiResult res) {
    final pan = res.panchaka;
    final isGood = pan.isGood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(pan.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'பஞ்சகப் பலன் & பரிகாரம் (Panchaka)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  pan.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${pan.number}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pan.number} – ${pan.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pan.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'பஞ்சகக் கணிதம்: வாரம் + திதி + நட்சத்திரம் + ராசி',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• வாரம்(${pan.vaaraNumber}) + திதி(${pan.thithiNumber}) + நட்சத்திரம்(${pan.nakshatraNumber}) + ராசி(${pan.rasiNumber}) = ${pan.totalSum}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 9 ஆல் வகுத்த மீதம் = ${pan.totalSum} % 9 = ${pan.number} (${pan.name})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  const Divider(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.volunteer_activism_rounded, color: Color(0xFFB45309), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'பூமி பூஜை பரிகார தானம்: ${pan.pariharam}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 22. Highlighted Guna Result Card (22. குணப் பலன்)
  Widget _buildGunaResultCard(GpKuzhiResult res) {
    final guna = res.guna;
    final isGood = guna.isGood;
    final int multiple3 = res.gunaNumber == 3 ? (res.roundedAyadi - 3) : ((res.roundedAyadi ~/ 3) * 3);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(guna.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'குணப் பலன் (Guna Phalan)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  guna.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.gunaNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${res.gunaNumber} – ${guna.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        guna.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'குணப் பலன் கணிதம்: ஆயாதி எண் % 3 (மீதி 0 = 3)',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• ஆயாதி எண் = ${res.roundedAyadi}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 3 இன் மடங்கு கழிவு = ${res.roundedAyadi} - $multiple3 = ${res.gunaNumber} (${guna.name})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  const SizedBox(height: 4),
                  Text('➔ (${res.gunaNumber}) ${guna.name} — ${guna.effect}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 23. Highlighted Nama Yoga Result Card (23. நாம யோகப் பலன்)
  Widget _buildNamaYogaResultCard(GpKuzhiResult res) {
    final namaYoga = res.namaYoga;
    final isGood = namaYoga.isGood;
    final int multiple27 = res.namaYogaNumber == 27 ? (res.namaYogaTotal - 27) : ((res.namaYogaTotal ~/ 27) * 27);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(namaYoga.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'நாம யோகப் பலன் (Nama Yoga Phalan)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  namaYoga.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.namaYogaNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${res.namaYogaNumber} – ${namaYoga.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        namaYoga.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'நாம யோகப் பலன் கணிதம்: (ஆயாதி எண் × 4) % 27',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• ஆயாதி எண் × 4 = ${res.roundedAyadi} × 4 = ${res.namaYogaTotal}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 27 இன் மடங்கு கழிவு = ${res.namaYogaTotal} - $multiple27 = ${res.namaYogaNumber} (${namaYoga.name})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  const SizedBox(height: 4),
                  Text('➔ (${res.namaYogaNumber}) ${namaYoga.name} — ${namaYoga.effect}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 24. Highlighted Ashta Dikpalakar Result Card (24. அஷ்டதிக்கு பாலகர் பலன்)
  Widget _buildDikpalakarResultCard(GpKuzhiResult res) {
    final dikpalakar = res.dikpalakar;
    final isGood = dikpalakar.isGood;
    final int multiple8 = res.dikpalakarNumber == 8 ? (res.dikpalakarTotal - 8) : ((res.dikpalakarTotal ~/ 8) * 8);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dikpalakar.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'அஷ்டதிக்கு பாலகர் பலன் (Ashta Dikpalakar)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  dikpalakar.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.dikpalakarNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${res.dikpalakarNumber} – ${dikpalakar.name} (${dikpalakar.direction})',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dikpalakar.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'அஷ்டதிக்கு பாலகர் பலன் கணிதம்: (ஆயாதி எண் × 9) % 8',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• ஆயாதி எண் × 9 = ${res.roundedAyadi} × 9 = ${res.dikpalakarTotal}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 8 இன் மடங்கு கழிவு = ${res.dikpalakarTotal} - $multiple8 = ${res.dikpalakarNumber} (${dikpalakar.name} - ${dikpalakar.direction})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  const SizedBox(height: 4),
                  Text('➔ (${res.dikpalakarNumber}) ${dikpalakar.name} — ${dikpalakar.effect}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 25. Highlighted Athidevathai Result Card (25. அதிதேவதை பலன்)
  Widget _buildAthidevathaiResultCard(GpKuzhiResult res) {
    final athidevathai = res.athidevathai;
    final isGood = athidevathai.isGood;
    final int multiple8 = res.athidevathaiNumber == 8 ? (res.athidevathaiTotal - 8) : ((res.athidevathaiTotal ~/ 8) * 8);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(athidevathai.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'அதிதேவதை பலன் (Athidevathai Phalan)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D1204),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                ),
                child: Text(
                  athidevathai.status,
                  style: TextStyle(
                    color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGood
                    ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${res.athidevathaiNumber}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${res.athidevathaiNumber} – ${athidevathai.name}',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        athidevathai.effect,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFFFE082), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showCalculationDetails) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calculate_rounded, color: Color(0xFFB58D3D), size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'அதிதேவதை பலன் கணிதம்: (மனையின் வயது × 5) % 8',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF7A6855)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('• மனையின் வயது எண் = ${res.ageNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• வயது × 5 = ${res.ageNumber} × 5 = ${res.athidevathaiTotal}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  Text('• 8 இன் மடங்கு கழிவு = ${res.athidevathaiTotal} - $multiple8 = ${res.athidevathaiNumber} (${athidevathai.name})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D1204))),
                  const SizedBox(height: 4),
                  Text('➔ (${res.athidevathaiNumber}) ${athidevathai.name} — ${athidevathai.effect}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 26. Highlighted Result Card with Rounded Kuzhi
  Widget _buildResultCard(GpKuzhiResult res) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D1204), Color(0xFF801504)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${res.region.nameTa} முறை (ம.கோல்: ${res.region.kolInches})',
                  style: const TextStyle(
                    color: Color(0xFFFFE082),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.stars_rounded, color: Color(0xFFFFE082), size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'குழி அளவு (Rounded Kuzhi)',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Prominent Rounded Kuzhi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${res.roundedKuzhi}',
                style: GoogleFonts.outfit(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFE082),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'குழிகள்',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Exact Decimal Subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'துல்லிய அளவு: ${res.kuzhiExact} குழி  (${res.kuzhiExact >= res.wholeKuzhi + 0.5 ? '≥ 0.5 அடுத்த முழு எண்' : '< 0.5 முந்தைய முழு எண்'})',
              style: const TextStyle(
                color: Color(0xFFFFE082),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildResultMiniStat('மொத்த சுற்றளவு\n(வெளிப்புறம்)', '${res.sqft.toStringAsFixed(2)} அடி²'),
              ),
              Container(height: 32, width: 1, color: Colors.white24),
              Expanded(
                child: _buildResultMiniStat('சதுர அங்குலம்\n(Sq.Inches)', '${res.sqInches.toStringAsFixed(0)} அங்²'),
              ),
              Container(height: 32, width: 1, color: Colors.white24),
              Expanded(
                child: _buildResultMiniStat('துல்லிய குழி\n(Exact Kuzhi)', '${res.kuzhiExact}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.2),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
        ),
      ],
    );
  }

  // 9. Comparison with other 3 regional methods
  Widget _buildComparisonCard() {
    if (_result == null) return const SizedBox.shrink();

    final l1Ft = double.tryParse(_l1FtCtrl.text.trim()) ?? 0.0;
    final l1In = double.tryParse(_l1InCtrl.text.trim()) ?? 0.0;
    final l2Ft = _isIrregularSides ? (double.tryParse(_l2FtCtrl.text.trim()) ?? l1Ft) : l1Ft;
    final l2In = _isIrregularSides ? (double.tryParse(_l2InCtrl.text.trim()) ?? l1In) : l1In;

    final w1Ft = double.tryParse(_w1FtCtrl.text.trim()) ?? 0.0;
    final w1In = double.tryParse(_w1InCtrl.text.trim()) ?? 0.0;
    final w2Ft = _isIrregularSides ? (double.tryParse(_w2FtCtrl.text.trim()) ?? w1Ft) : w1Ft;
    final w2In = _isIrregularSides ? (double.tryParse(_w2InCtrl.text.trim()) ?? w1In) : w1In;

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
              const Icon(Icons.compare_arrows_rounded, color: Color(0xFF5D1204), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '4 ஊர் முறைகளின் ஒப்பீடு (All 4 Regional Methods)',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: const Color(0xFFB58D3D).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            columnWidths: const {
              0: FlexColumnWidth(0.85),
              1: FlexColumnWidth(0.45),
              2: FlexColumnWidth(0.55),
              3: FlexColumnWidth(0.85),
              4: FlexColumnWidth(0.80),
              5: FlexColumnWidth(0.80),
              6: FlexColumnWidth(0.80),
              7: FlexColumnWidth(0.70),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFF5D1204),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
                    child: Text('ஊர்', style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                    child: Text('கோல்', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                    child: Text('ஆயாதி', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                    child: Text('கெர்ப்பம்', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                    child: Text('யோனி', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                    child: Text('ஆதாயம்', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                    child: Text('விரையம்', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
                    child: Text('குழி', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
              ...GpVaasthuRegion.values.map((reg) {
                final isSelected = reg == _selectedRegion;
                final r = GpVaasthuService.calculateKuzhi(
                  region: reg,
                  l1Ft: l1Ft,
                  l1In: l1In,
                  l2Ft: l2Ft,
                  l2In: l2In,
                  w1Ft: w1Ft,
                  w1In: w1In,
                  w2Ft: w2Ft,
                  w2In: w2In,
                );
                final garbham = r.garbham;
                final yoni = r.yoni;
                final aadhayam = r.aadhayam;
                final virayam = r.virayam;
                return TableRow(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFE082).withValues(alpha: 0.25) : Colors.transparent,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
                      child: Row(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF5D1204), size: 10)
                          else
                            const SizedBox(width: 10),
                          const SizedBox(width: 1),
                          Expanded(
                            child: Text(
                              reg.nameTa,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 10,
                                color: const Color(0xFF5D1204),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                      child: Text(
                        '${reg.kolInches}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 10,
                          color: const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                      child: Text(
                        '${r.roundedAyadi}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 10,
                          color: isSelected ? const Color(0xFF5D1204) : const Color(0xFFB58D3D),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                      child: Text(
                        '${garbham.number}.${garbham.name.split(' ')[0]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                          color: garbham.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                      child: Text(
                        '${yoni.number}.${yoni.name.split(' ')[0]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                          color: yoni.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                      child: Text(
                        '${aadhayam.number}.${aadhayam.effect.split(' ')[0]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                          color: isSelected ? const Color(0xFF5D1204) : const Color(0xFF2E7D32),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
                      child: Text(
                        '${virayam.number}.${virayam.effect.split(' ')[0]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                          color: virayam.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
                      child: Text(
                        '${r.roundedKuzhi}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: isSelected ? const Color(0xFF5D1204) : const Color(0xFFB58D3D),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // 10. 8 Yoni Reference Guide Card
  Widget _buildAllYonisReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.pets_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '8 யோனிப் பலன்கள் சாஸ்திர அட்டவணை (8 Yoni Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.yoniList.map((y) {
              final isCurrent = _result != null && _result!.yoniNumber == y.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (y.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
                      : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? (y.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                        : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(y.iconEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${y.number}. ${y.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF5D1204),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: y.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    y.status,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            y.effect,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: y.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 3 ஆல் பெருக்கி விடையில் எத்தனை 8 உள்ளதோ அதை கழித்து மீதி யோனி எண் ஆகும் (மீதம் 0 வந்தால் 8).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 11. 12 Aadhayam Reference Guide Card
  Widget _buildAllAadhayamsReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.savings_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '12 ஆதாயப் பலன்கள் சாஸ்திர அட்டவணை (12 Aadhaya Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.aadhayamList.map((a) {
              final isCurrent = _result != null && _result!.aadhayamNumber == a.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFFFF8E1) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFFFFA000) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${a.number}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(a.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.effect,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                          color: isCurrent ? const Color(0xFF5D1204) : const Color(0xFF424242),
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'தற்போதைய பலன்',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 8 ஆல் பெருக்கி வந்த விடையில் எத்தனை 12 உள்ளதோ அதை கழித்து மீதம் ஆதாயம் ஆகும் (மீதம் 0 வந்தால் 12).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 11. 10 Virayam Reference Guide Card
  Widget _buildAllVirayamsReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '10 விரையப் பலன்கள் சாஸ்திர அட்டவணை (10 Viraya Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.virayamList.map((v) {
              final isCurrent = _result != null && _result!.virayamNumber == v.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (v.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
                      : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? (v.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                        : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? (v.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                            : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${v.number}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.white : const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(v.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        v.effect,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                          color: isCurrent ? const Color(0xFF5D1204) : const Color(0xFF424242),
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: v.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          v.status,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 9 ஆல் பெருக்கி வந்த விடையில் எத்தனை 10 உள்ளதோ அதை கழித்து மீதம் விரையம் ஆகும் (மீதம் 0 வந்தால் 10). [ஆதாயத்தை விட விரையம் குறைவாக இருக்க வேண்டும்].',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 12. 8 Garbhams Reference Guide Card
  Widget _buildAllGarbhamsReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.menu_book_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '8 கெர்ப்பங்கள் சாஸ்திர அட்டவணை (8 Garbha Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.garbhamList.map((g) {
              final isCurrent = _result != null && _result!.garbhamNumber == g.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (g.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
                      : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? (g.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                        : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.iconEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${g.number}. ${g.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF5D1204),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${g.direction} (${g.deity})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A6855),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            g.effect,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: g.isGood ? const Color(0xFF2E7D32) : (g.status.contains('மத்திமம்') ? const Color(0xFFE65100) : const Color(0xFFC62828)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 8 ஆல் வகுத்து மீதம் 0 வந்தால் 8 (கழுதை - ஈசான்யன்) எனக் கொள்ள வேண்டும்.',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 13. 7 Vaaram Reference Guide Card (வாரப்பலன் அட்டவணை)
  Widget _buildAllVaarasReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '5. வாரப்பலன் சாஸ்திர அட்டவணை (7 Vaara Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.vaaraList.map((v) {
              final isCurrent = _result != null && _result!.vaaraNumber == v.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (v.isGood ? const Color(0xFFE8F5E9) : (v.status.contains('மத்திமம்') ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)))
                      : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? (v.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                        : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${v.number}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(v.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.dayName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204)),
                          ),
                          Text(
                            v.effect,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: v.isGood ? const Color(0xFF2E7D32) : (v.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: v.isGood ? const Color(0xFF2E7D32) : (v.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          v.status,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 9 ஆல் பெருக்கி வந்த விடையில் எத்தனை 7 உள்ளதோ அதை கழித்து வருவது வாரப்பலன் எண் ஆகும் (மீதம் 0 வந்தால் 7 சனி).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 14. 9 Amsam Reference Guide Card (அம்ச பலன் அட்டவணை)
  Widget _buildAllAmsasReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.stars_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '6. அம்ச பலன் சாஸ்திர அட்டவணை (9 Amsa Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.amsaList.map((a) {
              final isCurrent = _result != null && _result!.amsaNumber == a.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (a.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
                      : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? (a.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                        : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${a.number}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(a.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${a.number}. ${a.effect}',
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                          color: a.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: a.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.status,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 4 ஆல் பெருக்கி விடையில் எத்தனை 9 உள்ளதோ அதை கழித்து மீதம் அம்ச எண் ஆகும் (மீதம் 0 வந்தால் 9).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 15. 27 Nakshatra & Gana Reference Guide Card (நட்சத்திர பலன் & கணப் பலன் அட்டவணை)
  Widget _buildAllNakshatrasAndGanasReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.wb_twilight_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '7 & 11. 27 நட்சத்திர பலன் & கணப் பலன் சாஸ்திர அட்டவணை',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            // Gana Rules Summary Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFA000).withValues(alpha: 0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📜 கணப் பலன் விதிகள் (Gana Matching Rules):',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                  ),
                  SizedBox(height: 4),
                  Text('• தலைவன் (எஜமானன்) கணமும் மனையின் கணமும் ஒன்றாகில் ➔ நலம் உண்டாகும் (உத்தமம்)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  Text('• தேவகணமும் மனிதகணமும் வந்தால் ➔ உத்தம பலன் (உத்தமம்)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  Text('• ராக்ஷஸகணமும் மனிதகணமும் வந்தால் ➔ மகிமையுண்டாகும் (உத்தமம்)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  Text('• ராட்சஸகணமும் தேவகணமும் வந்தால் ➔ பகையும் சத்துருக்களால் எக்காலத்திலும் கஷ்டமும் ஏற்படும் (அதமம்)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC62828))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...GpVaasthuService.nakshatraList.map((n) {
              final isCurrent = _result != null && _result!.nakshatraNumber == n.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? (n.isGood ? const Color(0xFFE8F5E9) : (n.status.contains('மத்திமம்') ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)))
                      : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? (n.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
                        : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${n.number}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${n.number}. ${n.name}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF5D1204)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5D1204).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  n.gana,
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            n.effect,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: n.isGood ? const Color(0xFF2E7D32) : (n.status.contains('மத்திமம்') ? const Color(0xFFEF6C00) : const Color(0xFFC62828)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: n.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            n.status,
                            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 8 ஆல் பெருக்கி வரும் விடையில் எத்தனை 27 உள்ளதோ கழித்து வரும் மீதம் வரும் எண் நட்சத்திர பலன் ஆகும் (மீதம் 0 வந்தால் 27 ரேவதி).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 16. 4 Vamsam Reference Guide Card (வம்சம் பலன் அட்டவணை)
  Widget _buildAllVamsamsReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.diversity_3_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '8. வம்சம் பலன் சாஸ்திர அட்டவணை (4 Vamsam Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.vamsamList.map((v) {
              final isCurrent = _result != null && _result!.vamsamNumber == v.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFFFF8E1) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFFFFA000) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${v.number}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(v.iconEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204)),
                          ),
                          Text(
                            v.effect,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'தற்போதைய பலன்',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 9 ஆல் பெருக்கி வந்த விடையில் எத்தனை 4 உள்ளதோ அதை கழித்து விடும் எண் வம்ச பலன் ஆகும் (மீதம் 0 வந்தால் 4 சூத்திர வம்சம்).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 17. 30 Thithi Reference Guide Card (திதிப் பலன் அட்டவணை)
  Widget _buildAllThithisReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.brightness_medium_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '9. திதிப் பலன் சாஸ்திர அட்டவணை (30 Thithi Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            const Text(
              'வளர்பிறை (1–15 உத்தமம்) | தேய்பிறை (16–30 மத்திமம்)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
            ),
            const SizedBox(height: 8),
            ...GpVaasthuService.thithiList.map((t) {
              final isCurrent1 = _result != null && _result!.thithi1Number == t.number;
              final isCurrent2 = _result != null && _result!.thithi2Number == t.number;
              final isAnyCurrent = isCurrent1 || isCurrent2;

              return Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isAnyCurrent
                      ? const Color(0xFFFFF8E1)
                      : (t.number <= 15 ? const Color(0xFFFAF6EE) : const Color(0xFFF5F0E6)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAnyCurrent ? const Color(0xFFFFA000) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isAnyCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isAnyCurrent ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${t.number}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isAnyCurrent ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(t.iconEmoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${t.name} [${t.paksha}]',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204)),
                      ),
                    ),
                    Text(
                      t.effect,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: t.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                    if (isCurrent1 || isCurrent2) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isCurrent1 && isCurrent2 ? 'மரபு 1 & 2' : (isCurrent1 ? 'மரபு 1 (×4)' : 'மரபு 2 (×9)'),
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 4 and 9 ஆல் பெருக்கி வந்த விடையில் எத்தனை 30 உள்ளதோ அதை கழித்து வருவது திதி எண் ஆகும் (மீதம் 0 வந்தால் 30 அமாவாசை).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 18. 12 Rasi Reference Guide Card (இராசி பலன் அட்டவணை)
  Widget _buildAllRasisReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.pie_chart_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '10. இராசி பலன் சாஸ்திர அட்டவணை (12 Rasi Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.rasiList.map((r) {
              final isCurrent = _result != null && _result!.rasiNumber == r.number;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFFFF8E1) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFFFFA000) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF5D1204) : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${r.number}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? const Color(0xFFFFE082) : const Color(0xFF5D1204),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(r.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${r.number}. ${r.shortName} (${r.name})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF5D1204)),
                          ),
                          Text(
                            r.effect,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF5D1204)),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'தற்போதைய பலன்',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 4 ஆல் பெருக்கி வந்த விடையில் எத்தனை 12 உள்ளதோ அதை கழித்து வருவது இராசி எண் ஆகும் (மீதம் 0 வந்தால் 12 மீனம்).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 19. Age Reference Guide Card (வயது பலன் அட்டவணை)
  Widget _buildAllAgesReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.timer_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '10 (கூடுதல்). வயது பலன் சாஸ்திர விதிகள் (Age Phalam Guide)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            _buildAgeRow('1 – 27 வயது', 'சகல பொருத்தங்கள் இருந்தால் நன்மை, இல்லை என்றால் அதர்மம்', 'பொருத்தம் தேவை', const Color(0xFFEF6C00)),
            const SizedBox(height: 6),
            _buildAgeRow('28 – 50 வயது', 'மத்திம பலன் உண்டாகும்', 'மத்திமம்', const Color(0xFFEF6C00)),
            const SizedBox(height: 6),
            _buildAgeRow('51 – 100 வயது', 'உத்தம பலன் / தீர்க்காயுள் உண்டாகும்', 'உத்தமம்', const Color(0xFF2E7D32)),
            const SizedBox(height: 8),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 27 ஆல் பெருக்கி வந்த விடையில் எத்தனை 100 உள்ளதோ அதை கழித்து வரும் எண் வயது ஆகும் (மீதம் 0 வந்தால் 100).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeRow(String range, String desc, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(range, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF5D1204))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(desc, style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 20. Purusha Rasi Reference Guide Card (புருஷ இராசி பலன் அட்டவணை)
  Widget _buildAllPurushaRasisReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.male_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '12. புருஷ இராசி பலன் அட்டவணை (12 Purusha Rasis)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.purushaRasiList.map((p) {
              final isCurrent = _result != null && _result!.purushaRasiNumber == p.number;
              final Color itemColor = p.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? itemColor.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? itemColor : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: itemColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${p.number}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: itemColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(p.iconEmoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.shortName} (${p.name}) — ${p.rasiType}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204)),
                          ),
                          Text(
                            p.effect,
                            style: TextStyle(fontSize: 11, color: itemColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: p.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: itemColor),
                      ),
                      child: Text(
                        p.status,
                        style: TextStyle(color: itemColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 7 ஆல் பெருக்கி வந்த விடையில் எத்தனை 12 உள்ளதோ அதை கழித்து வருவது புருஷ இராசி எண் ஆகும் (மீதம் 0 வந்தால் 12 மீனம்).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 21. Boothams Reference Guide Card (பூதம் பலன் அட்டவணை)
  Widget _buildAllBoothamsReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.public_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '13. பூதம் பலன் அட்டவணை (5 Elements Guide)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.boothamsList.map((b) {
              final isCurrent1 = _result != null && _result!.bootham1Number == b.number;
              final isCurrent2 = _result != null && _result!.bootham2Number == b.number;
              final Color itemColor = b.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: (isCurrent1 || isCurrent2) ? itemColor.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (isCurrent1 || isCurrent2) ? itemColor : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: (isCurrent1 || isCurrent2) ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: itemColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${b.number}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: itemColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(b.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${b.name} (${b.tamilElementName})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204)),
                          ),
                          Text(
                            b.effect,
                            style: TextStyle(fontSize: 11, color: itemColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: b.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: itemColor),
                      ),
                      child: Text(
                        b.status,
                        style: TextStyle(color: itemColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 3 (முறை 1) அல்லது 9 (முறை 2) ஆல் பெருக்கி வந்த விடையில் எத்தனை 5 உள்ளதோ அதை கழித்து வருவது பூத எண் ஆகும் (மீதம் 0 வந்தால் 5 ஆகாயம்).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 22. Soothiram Reference Guide Card (சூத்திரம் பலன் அட்டவணை)
  Widget _buildAllSoothiramsReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.auto_stories_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '14. சூத்திரம் பலன் அட்டவணை (5 Sutras Guide)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.soothiramList.map((s) {
              final isCurrent = _result != null && _result!.soothiramNumber == s.number;
              final Color itemColor = s.isGood
                  ? const Color(0xFF2E7D32)
                  : (s.number == 4 ? const Color(0xFFEF6C00) : const Color(0xFFC62828));

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? itemColor.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? itemColor : const Color(0xFFB58D3D).withValues(alpha: 0.2),
                    width: isCurrent ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: itemColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${s.number}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: itemColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(s.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204)),
                          ),
                          Text(
                            s.effect,
                            style: TextStyle(fontSize: 11, color: itemColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: s.isGood
                            ? const Color(0xFFE8F5E9)
                            : (s.number == 4 ? const Color(0xFFFFF3E0) : const Color(0xFFFFEBEE)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: itemColor),
                      ),
                      child: Text(
                        s.status,
                        style: TextStyle(color: itemColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text(
              '※ குறிப்பு: ஆயாதி எண்ணை 7 ஆல் பெருக்கி வந்த விடையில் எத்தனை 5 உள்ளதோ அதை கழித்து வருவது சூத்திர எண் ஆகும் (மீதம் 0 வந்தால் 5 மரண சூத்திரம்).',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 23. Nethiram Reference Guide Card (நேத்திர பலன் சாஸ்திர விதிகள்)
  Widget _buildAllNethiramsReferenceCard() {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.remove_red_eye_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '15. நேத்திர பலன் சாஸ்திர விதிகள் (Nethira Phalam Guide)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('2 கண்', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32))),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('இரட்டைக் கண் — முழுமையான உத்தம சுப பலன் மற்றும் சகல நன்மைகள் உண்டாகும்', style: TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(6)),
                    child: const Text('உத்தமம்', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF6C00).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('1 கண்', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF6C00))),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('ஒற்றைக் கண் — மத்திம பலன் (சுபமும் அசுபமும் கலந்த பலன்) உண்டாகும்', style: TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFEF6C00), borderRadius: BorderRadius.circular(6)),
                    child: const Text('மத்திமம்', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('0 கண்', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFC62828))),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('கண் இல்லை (குருடு) — அதம தீய பலன் / பயம் மற்றும் தன நஷ்டம் உண்டாகும்', style: TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(6)),
                    child: const Text('அதமம்', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ கணக்கீட்டு விதி: வாரப்பலன் கிழமை எண்ணை (ஞாயிறு=1 .. சனி=7) 3 ஆல் பெருக்கி வரும் நட்சத்திரத்திற்கு அடுத்த நட்சத்திரத்திலிருந்து, முதல் 9 நட்சத்திரங்கள் 1-கண் (மத்திமம்), அடுத்த 12 நட்சத்திரங்கள் 2-கண் (உத்தமம்), அடுத்த 6 நட்சத்திரங்கள் 0-கண் (அதமம்) ஆகும்.',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  // 24. Amirthathi Yoga Reference Guide & 27 Nakshatra x 7 Days Table Card
  Widget _buildAllAmirthathiYogasReferenceCard() {
    final days = ['ஞாயிறு', 'திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி'];

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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.table_chart_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '16. அமிர்தாதி யோகங்கள் அறியும் அட்டவணை (Yoga Table)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: const Color(0xFF5D1204),
            ),
          ),
          children: [
            const Divider(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildYogaBadge('அ', 'அமிர்த யோகம் (உத்தமம்)', const Color(0xFF2E7D32)),
                _buildYogaBadge('சி', 'சித்த யோகம் (உத்தமம்)', const Color(0xFF1B5E20)),
                _buildYogaBadge('ம', 'மரண யோகம் (தீமை)', const Color(0xFFC62828)),
                _buildYogaBadge('பி', 'பிரபலாரிஷ்ட யோகம் (தீமை)', const Color(0xFF880E4F)),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 34,
                dataRowMinHeight: 30,
                dataRowMaxHeight: 32,
                horizontalMargin: 8,
                columnSpacing: 10,
                headingRowColor: WidgetStateProperty.all(const Color(0xFF5D1204)),
                columns: [
                  const DataColumn(
                    label: Text(
                      'நட்சத்திரம்',
                      style: TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  ...days.map(
                    (d) => DataColumn(
                      label: Text(
                        d,
                        style: const TextStyle(color: Color(0xFFFFE082), fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                ],
                rows: List.generate(27, (starIdx) {
                  final starNum = starIdx + 1;
                  final starName = GpVaasthuService.nakshatraList[starIdx].name;
                  final isCurrentStar = _result != null && _result!.nakshatraNumber == starNum;

                  return DataRow(
                    color: WidgetStateProperty.all(
                      isCurrentStar ? const Color(0xFFFFF8E1) : (starIdx.isEven ? const Color(0xFFFAF6EE) : Colors.white),
                    ),
                    cells: [
                      DataCell(
                        Text(
                          '$starNum. $starName',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isCurrentStar ? FontWeight.bold : FontWeight.w600,
                            color: isCurrentStar ? const Color(0xFFB45309) : const Color(0xFF5D1204),
                          ),
                        ),
                      ),
                      ...List.generate(7, (dayIdx) {
                        final vaaraNum = dayIdx + 1;
                        final code = GpVaasthuService.amirthathiYogaMatrix[starIdx][dayIdx];
                        final isCurrentCell = _result != null &&
                            _result!.nakshatraNumber == starNum &&
                            _result!.vaaraNumber == vaaraNum;

                        final Color codeColor = (code == 'அ' || code == 'சி')
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828);

                        return DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: isCurrentCell
                                ? BoxDecoration(
                                    color: codeColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: codeColor, width: 1.2),
                                  )
                                : null,
                            child: Text(
                              code,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: codeColor,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '※ குறிப்பு: அமிர்த, சித்த யோகங்களே எந்த ஒரு சுபகாரியங்களுக்கும் ஏற்றதாகும். மரண யோகம், பிரபலாரிஷ்ட யோகம் சுப காரியங்களுக்கு அனுகூலம் இல்லை.',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF7A6855), fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYogaBadge(String code, String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            child: Text(code, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          Text(name, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // 25. Thara Phalan Reference Guide Card
  Widget _buildAllTharaPhalansReferenceCard() {
    final tharas = [
      {'num': 1, 'name': 'ஜென்ம தாரை', 'effect': 'சரீர பீடை / அச்சம்', 'status': 'தீமை', 'isGood': false},
      {'num': 2, 'name': 'சம்பத்து தாரை', 'effect': 'தன லாபம் & செல்வம்', 'status': 'உத்தமம்', 'isGood': true},
      {'num': 3, 'name': 'விபத்து தாரை', 'effect': 'காரிய நஷ்டம் / விபத்து', 'status': 'தீமை', 'isGood': false},
      {'num': 4, 'name': 'க்ஷேம தாரை', 'effect': 'சுகம் & நன்மைகள்', 'status': 'உத்தமம்', 'isGood': true},
      {'num': 5, 'name': 'பிரத்யக் தாரை', 'effect': 'காரியத் தடை / எதிர்ப்பு', 'status': 'தீமை', 'isGood': false},
      {'num': 6, 'name': 'சாதக தாரை', 'effect': 'காரிய ஜெயம் & சித்தி', 'status': 'உத்தமம்', 'isGood': true},
      {'num': 7, 'name': 'வதை தாரை', 'effect': 'மரண பயம் / துன்பம்', 'status': 'தீமை', 'isGood': false},
      {'num': 8, 'name': 'மைத்ர தாரை', 'effect': 'நட்பு & மகிழ்ச்சி', 'status': 'உத்தமம்', 'isGood': true},
      {'num': 9, 'name': 'பரம மைத்ர தாரை', 'effect': 'பேரானந்தம் & சகல வெற்றி', 'status': 'உத்தமம்', 'isGood': true},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.star_half_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '17. தாரா பலன் சாஸ்திர அட்டவணை (9 Tharas)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...tharas.map((t) {
              final isCurrent = _result != null && (_result!.tharaPhalan.remainder == t['num'] || (_result!.tharaPhalan.remainder == 0 && t['num'] == 9));
              final isGood = t['isGood'] as bool;
              final Color color = isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: Text('${t['num']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(t['effect'] as String, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(t['status'] as String, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 26. Karana Reference Guide Card
  Widget _buildAllKaranasReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.flash_on_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '18. கரணப் பலன் சாஸ்திர அட்டவணை (11 Karanas)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.karanaList.map((k) {
              final isCurrent = _result != null && _result!.karanaNumber == k.number;
              final Color color = k.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Text('${k.number}.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    const SizedBox(width: 6),
                    Text(k.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(k.effect, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: k.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(k.status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 27. Chandra Phalan Reference Guide Card
  Widget _buildAllChandraPhalansReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.nightlight_round, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '19. சந்திர பலன் சாஸ்திர அட்டவணை (12 Chandra Phalans)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...List.generate(12, (i) {
              final num = i + 1;
              final def = GpVaasthuService.chandraPhalanDefinitions[i];
              final isCurrent = _result != null && _result!.chandraPhalan.number == num;
              final isGood = def['isGood'] as bool;
              final Color color = isGood ? const Color(0xFF2E7D32) : (num == 9 ? const Color(0xFFEF6C00) : const Color(0xFFC62828));

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Text('$num.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    const SizedBox(width: 6),
                    Text(def['icon'] as String, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(def['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(def['effect'] as String, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(def['status'] as String, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 28. Ashta Lakshmi Reference Guide Card
  Widget _buildAllAshtaLakshmisReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '20. அஷ்டலட்சுமி பலன் அட்டவணை (8 Lakshmis)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.ashtaLakshmiList.map((l) {
              final isCurrent = _result != null && _result!.ashtaLakshmiNumber == l.number;
              const Color color = Color(0xFF2E7D32);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Text('${l.number}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    const SizedBox(width: 6),
                    Text(l.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(l.effect, style: const TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(l.status, style: const TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 29. Panchaka Phalan & Pariharam Reference Guide Card
  Widget _buildAllPanchakasReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '21. பஞ்சகப் பலன் & பரிகாரங்கள் (Panchaka Guide)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...List.generate(9, (i) {
              final num = i + 1;
              final def = GpVaasthuService.panchakaDefinitions[i];
              final isCurrent = _result != null && _result!.panchaka.number == num;
              final isGood = def['isGood'] as bool;
              final Color color = isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Text('$num.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    const SizedBox(width: 6),
                    Text(def['icon'] as String, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(def['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(def['effect'] as String, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                          Text('பரிகாரம்: ${def['pariharam']}', style: const TextStyle(fontSize: 10.5, color: Color(0xFFB45309), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(def['status'] as String, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 30. Guna Reference Guide Card
  Widget _buildAllGunasReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.psychology_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '22. குணப் பலன் சாஸ்திர அட்டவணை (3 Gunas)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.gunaList.map((g) {
              final isCurrent = _result != null && _result!.gunaNumber == g.number;
              final Color color = g.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Text('${g.number}.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    const SizedBox(width: 6),
                    Text(g.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(g.effect, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: g.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(g.status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 31. Nama Yoga Reference Guide Card
  Widget _buildAllNamaYogasReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '23. நாம யோகப் பலன் சாஸ்திர அட்டவணை (27 Nama Yogas)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.namaYogaList.map((y) {
              final isCurrent = _result != null && _result!.namaYogaNumber == y.number;
              final Color color = y.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Text('${y.number}.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    const SizedBox(width: 6),
                    Text(y.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(y.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(y.effect, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: y.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(y.status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 32. Ashta Dikpalakar Reference Guide Card
  Widget _buildAllDikpalakarsReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.explore_rounded, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '24. அஷ்டதிக்கு பாலகர் சாஸ்திர அட்டவணை (8 Dikpalakas)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.dikpalakarList.map((d) {
              final isCurrent = _result != null && _result!.dikpalakarNumber == d.number;
              final Color color = d.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Text('${d.number}.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    const SizedBox(width: 6),
                    Text(d.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${d.name} (${d.direction})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(d.effect, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: d.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(d.status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 33. Athidevathai Reference Guide Card
  Widget _buildAllAthidevathaisReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: const Icon(Icons.shield_outlined, color: Color(0xFF5D1204), size: 20),
          title: Text(
            '25. அதிதேவதை பலன் சாஸ்திர அட்டவணை (8 Athidevathas)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: const Color(0xFF5D1204)),
          ),
          children: [
            const Divider(height: 16),
            ...GpVaasthuService.athidevathaiList.map((a) {
              final isCurrent = _result != null && _result!.athidevathaiNumber == a.number;
              final Color color = a.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? color.withValues(alpha: 0.08) : const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isCurrent ? color : const Color(0xFFB58D3D).withValues(alpha: 0.2), width: isCurrent ? 1.5 : 1.0),
                ),
                child: Row(
                  children: [
                    Text('${a.number}.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: color)),
                    const SizedBox(width: 6),
                    Text(a.iconEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204))),
                          Text(a.effect, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: a.isGood ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6), border: Border.all(color: color)),
                      child: Text(a.status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 34. Comprehensive Step-by-Step Formula Explanation Card
  Widget _buildFormulaExplanationCard(GpKuzhiResult res) {
    final int multiple8 = res.yoniNumber == 8 ? (res.yoniTotal - 8) : ((res.yoniTotal ~/ 8) * 8);
    final int multiple12 = res.aadhayamNumber == 12 ? (res.aadhayamTotal - 12) : ((res.aadhayamTotal ~/ 12) * 12);
    final int multiple10 = res.virayamNumber == 10 ? (res.virayamTotal - 10) : ((res.virayamTotal ~/ 10) * 10);
    final int multiple7 = res.vaaraNumber == 7 ? (res.vaaraTotal - 7) : ((res.vaaraTotal ~/ 7) * 7);
    final int multiple9 = res.amsaNumber == 9 ? (res.amsaTotal - 9) : ((res.amsaTotal ~/ 9) * 9);
    final int multiple27 = res.nakshatraNumber == 27 ? (res.nakshatraTotal - 27) : ((res.nakshatraTotal ~/ 27) * 27);
    final int multiple4 = res.vamsamNumber == 4 ? (res.vamsamTotal - 4) : ((res.vamsamTotal ~/ 4) * 4);
    final int multiple30_1 = res.thithi1Number == 30 ? (res.thithi1Total - 30) : ((res.thithi1Total ~/ 30) * 30);
    final int multiple30_2 = res.thithi2Number == 30 ? (res.thithi2Total - 30) : ((res.thithi2Total ~/ 30) * 30);
    final int multiple12Rasi = res.rasiNumber == 12 ? (res.rasiTotal - 12) : ((res.rasiTotal ~/ 12) * 12);
    final int multiple12Purusha = res.purushaRasiNumber == 12 ? (res.purushaRasiTotal - 12) : ((res.purushaRasiTotal ~/ 12) * 12);
    final int multiple5_1 = res.bootham1Number == 5 ? (res.bootham1Total - 5) : ((res.bootham1Total ~/ 5) * 5);
    final int multiple5_2 = res.bootham2Number == 5 ? (res.bootham2Total - 5) : ((res.bootham2Total ~/ 5) * 5);
    final int multiple5Soothiram = res.soothiramNumber == 5 ? (res.soothiramTotal - 5) : ((res.soothiramTotal ~/ 5) * 5);
    final int multiple11Karana = res.karanaNumber == 11 ? (res.karanaTotal - 11) : ((res.karanaTotal ~/ 11) * 11);
    final int multiple8AshtaLakshmi = res.ashtaLakshmiNumber == 8 ? (res.ashtaLakshmiTotal - 8) : ((res.ashtaLakshmiTotal ~/ 8) * 8);
    final int multiple3Guna = res.gunaNumber == 3 ? (res.roundedAyadi - 3) : ((res.roundedAyadi ~/ 3) * 3);
    final int multiple27NamaYoga = res.namaYogaNumber == 27 ? (res.namaYogaTotal - 27) : ((res.namaYogaTotal ~/ 27) * 27);
    final int multiple8Dikpalakar = res.dikpalakarNumber == 8 ? (res.dikpalakarTotal - 8) : ((res.dikpalakarTotal ~/ 8) * 8);
    final int multiple8Athidevathai = res.athidevathaiNumber == 8 ? (res.athidevathaiTotal - 8) : ((res.athidevathaiTotal ~/ 8) * 8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: Color(0xFF5D1204), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'முழு கணித முறை விளக்கம் (All 22 Formulas Breakdown):',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: const Color(0xFF5D1204),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('【 1. ஆயாதி எண் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• நீளங்களின் கூடுதல் = ${(res.length1Ft + res.length1In/12 + res.length2Ft + res.length2In/12).toStringAsFixed(2)} அடி', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• அகலங்களின் கூடுதல் = ${(res.width1Ft + res.width1In/12 + res.width2Ft + res.width2In/12).toStringAsFixed(2)} அடி', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• மொத்த சுற்றளவு = ${res.perimeterFt.toStringAsFixed(2)} அடி | அங்குலத்தில் = ${res.perimeterInches.toStringAsFixed(2)} அங்குலம்', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• ஆயாதி எண் = ${res.perimeterInches.toStringAsFixed(2)} ÷ ${res.ayadiDivisor} = ${res.ayadiExact} ➔ ${res.roundedAyadi}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),

                const Divider(height: 16),
                const Text('【 2. கெர்ப்ப பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} % 8 = ${res.garbhamNumber} ➔ ${res.garbham.name} (${res.garbham.direction} - ${res.garbham.deity})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.garbham.effect} [${res.garbham.status}]', style: TextStyle(fontSize: 11.5, color: res.garbham.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 3. யோனி பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 3 = ${res.yoniTotal} | கழிவு $multiple8 = ${res.yoniNumber} (${res.yoni.name})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.yoni.effect}', style: TextStyle(fontSize: 11.5, color: res.yoni.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 4. ஆதாயம் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 8 = ${res.aadhayamTotal} | கழிவு $multiple12 = ${res.aadhayamNumber}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: (${res.aadhayamNumber}) ${res.aadhayam.effect}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),

                const Divider(height: 16),
                const Text('【 5. விரையம் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 9 = ${res.virayamTotal} | கழிவு $multiple10 = ${res.virayamNumber}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: (${res.virayamNumber}) ${res.virayam.effect} [ஆதாயம் ${res.aadhayamNumber} ${res.isAadhayamGreater ? '>' : '<='} விரையம் ${res.virayamNumber}]', style: TextStyle(fontSize: 11.5, color: res.isAadhayamGreater ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 6. வாரப்பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 9 = ${res.vaaraTotal} | கழிவு $multiple7 = ${res.vaaraNumber} (${res.vaara.dayName})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.vaara.effect} [${res.vaara.status}]', style: TextStyle(fontSize: 11.5, color: res.vaara.isGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00))),

                const Divider(height: 16),
                const Text('【 7. அம்ச பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 4 = ${res.amsaTotal} | கழிவு $multiple9 = ${res.amsaNumber}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: (${res.amsaNumber}) ${res.amsa.effect} [${res.amsa.status}]', style: TextStyle(fontSize: 11.5, color: res.amsa.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 8. நட்சத்திர பலன் & கணம் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 8 = ${res.nakshatraTotal} | கழிவு $multiple27 = ${res.nakshatraNumber} (${res.nakshatra.name})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• மனை கணம்: ${res.nakshatra.gana} | பலன்: ${res.nakshatra.effect} [${res.nakshatra.status}]', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),

                const Divider(height: 16),
                const Text('【 9. வம்சம் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 9 = ${res.vamsamTotal} | கழிவு $multiple4 = ${res.vamsamNumber} (${res.vamsam.name})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.vamsam.effect}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),

                const Divider(height: 16),
                const Text('【 10. திதிப் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• முதல் மரபு (× 4): ${res.roundedAyadi} × 4 = ${res.thithi1Total} | கழிவு $multiple30_1 = ${res.thithi1Number} (${res.thithi1.name} [${res.thithi1.paksha}]) ➔ ${res.thithi1.effect}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• இரண்டாவது மரபு (× 9): ${res.roundedAyadi} × 9 = ${res.thithi2Total} | கழிவு $multiple30_2 = ${res.thithi2Number} (${res.thithi2.name} [${res.thithi2.paksha}]) ➔ ${res.thithi2.effect}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),

                const Divider(height: 16),
                const Text('【 11. இராசி பலன் / ஸ்திரீ இராசி கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 4 = ${res.rasiTotal} | கழிவு $multiple12Rasi = ${res.rasiNumber} (${res.rasi.name})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.rasi.effect}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),

                const Divider(height: 16),
                const Text('【 12. வயது பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 27 = ${res.ageTotal} | % 100 = ${res.ageNumber} வயது (${res.age.category})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.age.effect} [${res.age.status}]', style: TextStyle(fontSize: 11.5, color: res.age.isGood ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00))),

                const Divider(height: 16),
                const Text('【 13. புருஷ இராசி பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 7 = ${res.purushaRasiTotal} | கழிவு $multiple12Purusha = ${res.purushaRasiNumber} (${res.purushaRasi.name} [${res.purushaRasi.rasiType}])', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.purushaRasi.effect} [${res.purushaRasi.status}]', style: TextStyle(fontSize: 11.5, color: res.purushaRasi.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 14. பூதம் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• முறை 1 (× 3): ${res.roundedAyadi} × 3 = ${res.bootham1Total} | கழிவு $multiple5_1 = ${res.bootham1Number} (${res.bootham1.name}) ➔ ${res.bootham1.effect}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• முறை 2 (× 9): ${res.roundedAyadi} × 9 = ${res.bootham2Total} | கழிவு $multiple5_2 = ${res.bootham2Number} (${res.bootham2.name}) ➔ ${res.bootham2.effect}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),

                const Divider(height: 16),
                const Text('【 15. சூத்திரம் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 7 = ${res.soothiramTotal} | கழிவு $multiple5Soothiram = ${res.soothiramNumber} (${res.soothiram.name})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.soothiram.effect} [${res.soothiram.status}]', style: TextStyle(fontSize: 11.5, color: res.soothiram.isGood ? const Color(0xFF2E7D32) : (res.soothiram.number == 4 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)))),

                const Divider(height: 16),
                const Text('【 16. நேத்திர பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• வார எண்: ${res.vaaraNumber} (${res.vaara.dayName}) ➔ வார நட்சத் (${res.vaaraNumber} × 3): ${res.nethiram.startStarNumber} (${res.nethiram.startStarName})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• ஆயாதி மனை நட்சத்திரம்: ${res.nakshatraNumber} (${res.nakshatra.name})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.nethiram.title} [${res.nethiram.status}] — ${res.nethiram.matchedRange}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.nethiram.eyes == 2 ? const Color(0xFF2E7D32) : (res.nethiram.eyes == 1 ? const Color(0xFFEF6C00) : const Color(0xFFC62828)))),

                const Divider(height: 16),
                const Text('【 17. அமிர்தாதி யோக பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• வாரப்பலன் கிழமை: ${res.vaaraNumber} (${res.amirthathiYoga.vaaraDayName}) | மனை நட்சத்திரம்: ${res.nakshatraNumber} (${res.amirthathiYoga.nakshatraName})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• யோக முடிவு: (${res.amirthathiYoga.code}) ${res.amirthathiYoga.name} [${res.amirthathiYoga.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.amirthathiYoga.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                Text('• பலன்: ${res.amirthathiYoga.effect}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),

                const Divider(height: 16),
                const Text('【 18. தாரா பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• உரிமையாளர் நட்சத்: ${res.tharaPhalan.ownerNakshatraNumber} (${res.tharaPhalan.ownerNakshatraName}) ➔ மனை நட்சத்: ${res.tharaPhalan.houseNakshatraNumber} (${res.tharaPhalan.houseNakshatraName})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• தூரம் = ${res.tharaPhalan.count} | % 9 = ${res.tharaPhalan.remainder} ➔ ${res.tharaPhalan.tharaName} [${res.tharaPhalan.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.tharaPhalan.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 19. கரணப் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 5 = ${res.karanaTotal} | கழிவு $multiple11Karana = ${res.karanaNumber} (${res.karana.name})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.karana.effect} [${res.karana.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.karana.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 20. சந்திர பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• உரிமையாளர் ராசி: ${res.chandraPhalan.ownerRasiNumber} (${res.chandraPhalan.ownerRasiName}) ➔ மனை ராசி: ${res.chandraPhalan.houseRasiNumber} (${res.chandraPhalan.houseRasiName})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• சந்திர பலன் எண்: ${res.chandraPhalan.number} (${res.chandraPhalan.name}) [${res.chandraPhalan.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.chandraPhalan.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 21. அஷ்டலட்சுமி பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 3 = ${res.ashtaLakshmiTotal} | கழிவு $multiple8AshtaLakshmi = ${res.ashtaLakshmiNumber} (${res.ashtaLakshmi.name})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• பலன்: ${res.ashtaLakshmi.effect} [${res.ashtaLakshmi.status}]', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),

                const Divider(height: 16),
                const Text('【 22. பஞ்சகப் பலன் & பரிகாரம் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• வாரம்(${res.panchaka.vaaraNumber}) + திதி(${res.panchaka.thithiNumber}) + நட்சத்(${res.panchaka.nakshatraNumber}) + ராசி(${res.panchaka.rasiNumber}) = ${res.panchaka.totalSum}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• ${res.panchaka.totalSum} % 9 = ${res.panchaka.number} (${res.panchaka.name}) [${res.panchaka.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.panchaka.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                Text('• பரிகாரம்: ${res.panchaka.pariharam}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),

                const Divider(height: 16),
                const Text('【 23. குணப் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} % 3 = ${res.gunaNumber} (${res.guna.name}) | கழிவு $multiple3Guna = ${res.gunaNumber}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• பலன்: (${res.gunaNumber}) ${res.guna.name} — ${res.guna.effect} [${res.guna.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.guna.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 24. நாம யோகப் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 4 = ${res.namaYogaTotal} | கழிவு $multiple27NamaYoga = ${res.namaYogaNumber} (${res.namaYoga.name})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• பலன்: (${res.namaYogaNumber}) ${res.namaYoga.name} — ${res.namaYoga.effect} [${res.namaYoga.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.namaYoga.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 25. அஷ்டதிக்கு பாலகர் பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• ${res.roundedAyadi} × 9 = ${res.dikpalakarTotal} | கழிவு $multiple8Dikpalakar = ${res.dikpalakarNumber} (${res.dikpalakar.name}) | திசை: ${res.dikpalakar.direction}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• பலன்: (${res.dikpalakarNumber}) ${res.dikpalakar.name} — ${res.dikpalakar.effect} [${res.dikpalakar.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.dikpalakar.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 26. அதிதேவதை பலன் கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• மனையின் வயது: ${res.ageNumber} ➔ ${res.ageNumber} × 5 = ${res.athidevathaiTotal} | கழிவு $multiple8Athidevathai = ${res.athidevathaiNumber} (${res.athidevathai.name})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• பலன்: (${res.athidevathaiNumber}) ${res.athidevathai.name} — ${res.athidevathai.effect} [${res.athidevathai.status}]', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: res.athidevathai.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),

                const Divider(height: 16),
                const Text('【 27. குழிக்கணக்கு கணிதம் 】', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                const SizedBox(height: 4),
                Text('• மொத்த சுற்றளவு (வெளிப்புறம்) = ${res.sqft.toStringAsFixed(2)} ச.அடி | ச.அங்குலம் = ${res.sqInches.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D1204))),
                Text('• துல்லிய குழி = ${res.sqInches.toStringAsFixed(2)} ÷ ${res.divisor} = ${res.kuzhiExact} குழி ➔ முடிவு: ${res.roundedKuzhi} குழிகள்', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

