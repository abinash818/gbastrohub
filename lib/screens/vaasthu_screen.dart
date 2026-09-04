import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/vaasthu_service.dart';

class VaasthuScreen extends StatefulWidget {
  final bool isPopup;
  const VaasthuScreen({super.key, this.isPopup = false});

  @override
  State<VaasthuScreen> createState() => _VaasthuScreenState();
}

class _VaasthuScreenState extends State<VaasthuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Inputs for Dimension Calculator
  final TextEditingController _widthFtCtrl = TextEditingController(text: '20');
  final TextEditingController _widthInCtrl = TextEditingController(text: '0');
  final TextEditingController _lengthFtCtrl = TextEditingController(text: '30');
  final TextEditingController _lengthInCtrl = TextEditingController(text: '0');
  final TextEditingController _directSqftCtrl = TextEditingController();

  bool _isDirectSqftMode = false;
  ManaiyadiResult? _calcResult;

  // Length Suggestions State
  final TextEditingController _suggWidthFtCtrl = TextEditingController(text: '20');
  final TextEditingController _suggWidthInCtrl = TextEditingController(text: '0');
  List<LengthSuggestion>? _suggestions;

  // Best Areas State
  String _manaiFilter = 'All';
  String _sortOrder = 'percent_desc';
  List<ManaiyadiResult>? _bestAreas;
  bool _isLoadingBestAreas = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Directly calculate initial result without calling FocusScope in initState
    final wFt = double.tryParse(_widthFtCtrl.text.trim()) ?? 20.0;
    final wIn = double.tryParse(_widthInCtrl.text.trim()) ?? 0.0;
    final lFt = double.tryParse(_lengthFtCtrl.text.trim()) ?? 30.0;
    final lIn = double.tryParse(_lengthInCtrl.text.trim()) ?? 0.0;
    _calcResult = VaasthuService.evaluateManaiyadi(wFt, wIn, lFt, lIn);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _widthFtCtrl.dispose();
    _widthInCtrl.dispose();
    _lengthFtCtrl.dispose();
    _lengthInCtrl.dispose();
    _directSqftCtrl.dispose();
    _suggWidthFtCtrl.dispose();
    _suggWidthInCtrl.dispose();
    super.dispose();
  }

  void _performCalculation({bool unfocus = true}) {
    if (unfocus && mounted) {
      FocusScope.of(context).unfocus();
    }
    if (_isDirectSqftMode) {
      final sqft = double.tryParse(_directSqftCtrl.text.trim()) ?? 0.0;
      if (sqft <= 0) {
        _showSnackBar('சரியான சதுரடியை உள்ளிடவும் (Please enter valid Sq.Ft)');
        return;
      }
      setState(() {
        _calcResult = VaasthuService.evaluateManaiyadiBySqft(sqft);
      });
    } else {
      final wFt = double.tryParse(_widthFtCtrl.text.trim()) ?? 0.0;
      final wIn = double.tryParse(_widthInCtrl.text.trim()) ?? 0.0;
      final lFt = double.tryParse(_lengthFtCtrl.text.trim()) ?? 0.0;
      final lIn = double.tryParse(_lengthInCtrl.text.trim()) ?? 0.0;

      if (wFt <= 0 && lFt <= 0) {
        _showSnackBar('அகலம் மற்றும் நீள அளவுகளை உள்ளிடவும்');
        return;
      }

      setState(() {
        _calcResult = VaasthuService.evaluateManaiyadi(wFt, wIn, lFt, lIn);
      });
    }
  }

  void _generateSuggestions() {
    if (mounted) FocusScope.of(context).unfocus();
    final wFt = double.tryParse(_suggWidthFtCtrl.text.trim()) ?? 0.0;
    final wIn = double.tryParse(_suggWidthInCtrl.text.trim()) ?? 0.0;

    if (wFt <= 0 && wIn <= 0) {
      _showSnackBar('பரிந்துரைகளைப் பெற சரியான அகலத்தை உள்ளிடவும்');
      return;
    }

    setState(() {
      _suggestions = VaasthuService.findGoodLengths(wFt, wIn);
    });
  }

  void _loadBestAreas() {
    if (mounted) FocusScope.of(context).unfocus();
    setState(() => _isLoadingBestAreas = true);

    Future.microtask(() {
      final results = VaasthuService.findBestAreas(
        manaiFilter: _manaiFilter,
        sortOrder: _sortOrder,
      );
      if (mounted) {
        setState(() {
          _bestAreas = results;
          _isLoadingBestAreas = false;
        });
      }
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF5D1204),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

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
              'மனை அடி சாஸ்திரம்',
              style: GoogleFonts.cinzel(
                color: const Color(0xFFFFE082),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const Text(
              'வாஸ்து & குழிக்கணக்கு (Vaasthu Kuzhikanakku)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFFFFE082)),
            tooltip: 'சாஸ்திர குறிப்பு',
            onPressed: _showInfoDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF470C01),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: const Color(0xFFFFE082),
              indicatorWeight: 3,
              labelColor: const Color(0xFFFFE082),
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.calculate_rounded, size: 18), text: 'கணக்கீடு'),
                Tab(icon: Icon(Icons.lightbulb_outline_rounded, size: 18), text: 'நீளப் பரிந்துரை'),
                Tab(icon: Icon(Icons.stars_rounded, size: 18), text: 'சிறந்த பரப்பளவு'),
                Tab(icon: Icon(Icons.straighten_rounded, size: 18), text: 'உள்பக்க அடி'),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCalculatorTab(),
              _buildSuggestionsTab(),
              _buildBestAreasTab(),
              _buildGoodFeetTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 1: DIMENSION CALCULATOR
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildCalculatorTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputCard(),
          const SizedBox(height: 16),
          if (_calcResult != null) _buildResultSection(_calcResult!),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.architecture_rounded, color: Color(0xFF5D1204), size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'அளவுகளை உள்ளிடவும்',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF5D1204),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isDirectSqftMode = !_isDirectSqftMode;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isDirectSqftMode ? Icons.grid_view_rounded : Icons.square_foot_rounded,
                        size: 13,
                        color: const Color(0xFF5D1204),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isDirectSqftMode ? 'நீளம் x அகலம்' : 'நேரடி சதுரடி',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D1204),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_isDirectSqftMode) ...[
            _buildNumberField(
              controller: _directSqftCtrl,
              label: 'மொத்த சதுரடி (Total Sq.Ft)',
              hint: 'எ.கா. 1200',
              icon: Icons.aspect_ratio_rounded,
            ),
          ] else ...[
            // Width
            Text(
              'Width (உள்பக்க அகலம் / தலைவாசக்கால்):',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D1204),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _widthFtCtrl,
                    label: 'Feet (அடி)',
                    hint: '20',
                    icon: Icons.straighten_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildNumberField(
                    controller: _widthInCtrl,
                    label: 'Inches (அங்குலம்)',
                    hint: '0',
                    icon: Icons.more_horiz_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Length
            Text(
              'Length (உள்பக்க நீளம்):',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D1204),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _lengthFtCtrl,
                    label: 'Feet (அடி)',
                    hint: '30',
                    icon: Icons.straighten_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildNumberField(
                    controller: _lengthInCtrl,
                    label: 'Inches (அங்குலம்)',
                    hint: '0',
                    icon: Icons.more_horiz_rounded,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _performCalculation,
              icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFE082), size: 20),
              label: Text(
                'பொருத்தங்களை கணக்கிடு (Calculate)',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D1204),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(ManaiyadiResult res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Highlight Score & Metrics Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5D1204), Color(0xFF8B1E0F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D1204).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('சதுரடி (Sq.Ft)', res.sqft.toStringAsFixed(1)),
                  Container(height: 36, width: 1, color: Colors.white24),
                  _buildMetricItem('குழி (Kuzhi)', res.kuzhi.toStringAsFixed(1)),
                  Container(height: 36, width: 1, color: Colors.white24),
                  _buildMetricItem('பொருத்தம்', '${res.percentage}% (${res.goodCount}/11)'),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: res.manaiGood
                          ? const Color(0xFF16A34A).withOpacity(0.2)
                          : const Color(0xFFDC2626).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: res.manaiGood ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          res.manaiGood ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                          color: res.manaiGood ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${res.manaiNameTa} (${res.manaiName})',
                          style: TextStyle(
                            color: res.manaiGood ? const Color(0xFFFFE082) : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 11 Poruthams Detailed Card List
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D1204).withOpacity(0.04),
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
                  const Icon(Icons.fact_check_rounded, color: Color(0xFF5D1204), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '11 ஆயாதி பொருத்தங்கள் (Detailed Breakdown)',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF5D1204),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: res.details.length,
                separatorBuilder: (c, i) => const Divider(height: 1, color: Color(0xFFF0EBE0)),
                itemBuilder: (context, idx) {
                  final item = res.details[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nameTa,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Color(0xFF2D1B00),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.nameEn,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.value,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: const Color(0xFF5D1204),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildStatusBadge(item),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cinzel(
            color: const Color(0xFFFFE082),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(PoruthamItem item) {
    Color bg;
    Color fg;
    IconData icon;

    switch (item.statusType) {
      case PoruthamStatusType.good:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        icon = Icons.check_circle_rounded;
        break;
      case PoruthamStatusType.bad:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        break;
      case PoruthamStatusType.none:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
        icon = Icons.remove_circle_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 11),
          const SizedBox(width: 3),
          Text(
            item.statusText,
            style: TextStyle(
              color: fg,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 2: LENGTH SUGGESTIONS
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildSuggestionsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D1204).withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF5D1204), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'அகலத்திற்கு ஏற்ற நன்மையான நீளங்கள்',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF5D1204),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'நீங்கள் நிர்ணயித்த அகலத்திற்கு (Width), அதிக பொருத்தமுள்ள (7/11+) நீளங்களை உடனடியாகக் கண்டறியலாம்.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        controller: _suggWidthFtCtrl,
                        label: 'Width (Feet / அடி)',
                        hint: '20',
                        icon: Icons.straighten_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildNumberField(
                        controller: _suggWidthInCtrl,
                        label: 'Inches (அங்குலம்)',
                        hint: '0',
                        icon: Icons.more_horiz_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _generateSuggestions,
                    icon: const Icon(Icons.search_rounded, color: Color(0xFFFFE082), size: 20),
                    label: Text(
                      'நீளப் பரிந்துரைகளைக் கண்டறி (Suggest Lengths)',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D1204),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_suggestions != null) ...[
            if (_suggestions!.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'இந்த அகலத்திற்கு 10-100 அடி வரம்பில் உகந்த பொருத்தங்கள் அமையவில்லை. வேறு அகலத்தை முயற்சிக்கவும்.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestions!.length,
                separatorBuilder: (c, i) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final item = _suggestions![idx];
                  final res = item.result;
                  final isSuperGood = res.percentage >= 80;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSuperGood ? const Color(0xFFF0FDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSuperGood
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFB58D3D).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5D1204).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${item.lengthFt}\'',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D1204),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.lengthFt} அடி ${item.lengthIn > 0 ? "${item.lengthIn.toStringAsFixed(1)} அங்" : ""} (${res.sqft.toStringAsFixed(1)} ச.அடி)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: Color(0xFF2D1B00),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${res.manaiNameTa} • ${res.kuzhi.toStringAsFixed(1)} குழி',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${res.percentage}% (${res.goodCount}/11)',
                                style: const TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                _widthFtCtrl.text = _suggWidthFtCtrl.text;
                                _widthInCtrl.text = _suggWidthInCtrl.text;
                                _lengthFtCtrl.text = item.lengthFt.toString();
                                _lengthInCtrl.text = item.lengthIn.toString();
                                _isDirectSqftMode = false;
                                _tabController.animateTo(0);
                                _performCalculation();
                              },
                              child: const Text(
                                'விவரங்கள் »',
                                style: TextStyle(
                                  color: Color(0xFF5D1204),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 3: BEST AREA EXPLORER
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildBestAreasTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFF5D1204), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'சிறந்த பரப்பளவுகள் (100 - 10,000 ச.அடி)',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF5D1204),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '8/11 (72%+) க்கும் அதிகமான பொருத்தம் கொண்ட சுபமான மனை பரப்பளவுகளை வடிகட்டிப் பார்க்கலாம்.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 14),
                // Vertically stacked dropdowns to fit any mobile screen width
                DropdownButtonFormField<String>(
                  value: _manaiFilter,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'மனை வகை (Filter by Manai)',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF5D1204)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('அனைத்து சுப மனை (All Good)')),
                    DropdownMenuItem(value: 'Karuda', child: Text('கருட மனை (Karuda)')),
                    DropdownMenuItem(value: 'Simma', child: Text('சிம்ம மனை (Simma)')),
                    DropdownMenuItem(value: 'Pasu', child: Text('பசு மனை (Pasu)')),
                    DropdownMenuItem(value: 'Yanai', child: Text('யானை மனை (Yanai)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _manaiFilter = val);
                      _loadBestAreas();
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _sortOrder,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'வரிசைப்படுத்து (Sort Order)',
                    labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF5D1204)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'percent_desc', child: Text('அதிக பொருத்தம் % (Highest Match)')),
                    DropdownMenuItem(value: 'size_asc', child: Text('சிறிய பரப்பளவு முதல் (Smallest First)')),
                    DropdownMenuItem(value: 'size_desc', child: Text('பெரிய பரப்பளவு முதல் (Largest First)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _sortOrder = val);
                      _loadBestAreas();
                    }
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _loadBestAreas,
                    icon: const Icon(Icons.explore_rounded, color: Color(0xFFFFE082), size: 18),
                    label: Text(
                      'பரப்பளவுகளைக் காட்டு (Explore Areas)',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D1204),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoadingBestAreas)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: Color(0xFF5D1204)),
              ),
            )
          else if (_bestAreas != null) ...[
            Text(
              'கண்டறியப்பட்ட பரப்பளவுகள்: ${_bestAreas!.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204), fontSize: 13),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _bestAreas!.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final a = _bestAreas![idx];
                final isTop = a.percentage >= 90;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isTop ? const Color(0xFFF0FDF4) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isTop ? const Color(0xFF86EFAC) : const Color(0xFFB58D3D).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${a.sqft.toStringAsFixed(0)} சதுரடி (${a.kuzhi.toStringAsFixed(1)} குழி)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D1B00)),
                          ),
                          Text(
                            a.manaiNameTa,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${a.percentage}% (${a.goodCount}/11)',
                              style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF5D1204)),
                            onPressed: () {
                              _directSqftCtrl.text = a.sqft.toStringAsFixed(0);
                              _isDirectSqftMode = true;
                              _tabController.animateTo(0);
                              _performCalculation();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 4: GOOD FEET (உள்பக்க அடி) REFERENCE
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildGoodFeetTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1.2),
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
                        'நன்மையான உள்ப்பக்க அளவுகள் (Good Feet Table)',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF5D1204),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'அறை (Room), கூடம் (Hall), ரேழி ஆகியவற்றிற்கு இந்த அளவுகள் அமைவது இல்லத்திற்கு சுபிட்சத்தையும் செல்வ விருத்தியையும் தரும் என மனை சாஸ்திரம் கூறுகிறது.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Grid of Good Feet
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: VaasthuService.goodFeet.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, idx) {
              final ft = VaasthuService.goodFeet[idx];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    '$ft அடி',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF5D1204),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF5D1204)),
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFB58D3D), size: 18),
        filled: true,
        fillColor: const Color(0xFFFAF6EE),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5D1204), width: 1.8),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF6EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFF5D1204)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'மனை அடி சாஸ்திர விளக்கம்',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF5D1204),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• குழி கணக்கீடு: மொத்த சதுரடி ÷ 9 = குழி.\n'
                '• 11 ஆயாதி பொருத்தங்கள்:\n'
                '  1. மனை வகை (கருட, சிம்ம, பசு, யானை)\n'
                '  2. ஆயுள்/வயது (60 க்கு மேல் நன்று, 50க்கு கீழ் ஆகாது)\n'
                '  3. வரவு/ஆதாயம் (வரவு செலவை விட அதிகம் இருக்க வேண்டும்)\n'
                '  4. செலவு/விரயம்\n'
                '  5. யோனி (ஒற்றைப்படை யோனிகள் நன்று)\n'
                '  6. நட்சத்திரம் (சுப நட்சத்திரங்கள்)\n'
                '  7. வாரம் (திங்கள், புதன், வியாழன், வெள்ளி)\n'
                '  8. அம்சம்\n'
                '  9. வம்சம்\n'
                '  10. திதி\n'
                '  11. ராசி',
                style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF2D1B00)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('சரி (OK)', style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
