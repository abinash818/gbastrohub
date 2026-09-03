import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../services/settings_service.dart';
import '../services/astro_utils.dart';
import '../components/south_indian_chart.dart';
import '../theme/app_colors.dart';

class PanchangamImageScreen extends StatefulWidget {
  final Map<String, dynamic> panchangamData;
  final DateTime selectedDate;
  final Map<String, dynamic>? chartResults;

  const PanchangamImageScreen({
    super.key,
    required this.panchangamData,
    required this.selectedDate,
    this.chartResults,
  });

  @override
  State<PanchangamImageScreen> createState() => _PanchangamImageScreenState();
}

class _PanchangamImageScreenState extends State<PanchangamImageScreen> {
  final GlobalKey _globalKey = GlobalKey();
  Map<String, String> _astro = {};
  bool _isCapturing = false;
  bool _isLoading = true;

  static const double targetWidth = 780.0;
  static const double targetHeight = 840.0;

  @override
  void initState() {
    super.initState();
    _loadAstro();
  }

  Future<void> _loadAstro() async {
    try {
      _astro = await SettingsService.getAstrologerDetails();
    } catch (e) {
      _astro = {
        'name': "GB ASTRO",
        'address': "",
        'phone': ""
      };
    }
    if (_astro['name'] == null || _astro['name']!.isEmpty) {
      _astro['name'] = "GB ASTRO";
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, List<String>> _castChartMap(dynamic data) {
    if (data == null) return {};
    final result = <String, List<String>>{};
    if (data is Map) {
      data.forEach((key, val) {
        if (val is List) {
          result[key.toString()] = val
              .map((e) => e.toString())
              .where((item) {
                final trimmed = item.trim();
                return !trimmed.startsWith("லக்") &&
                       !trimmed.startsWith("உத") &&
                       !trimmed.startsWith("Asc") &&
                       !trimmed.startsWith("Lagna") &&
                       !trimmed.startsWith("Uda") &&
                       !trimmed.startsWith("लग्न") &&
                       !trimmed.startsWith("उदय");
              })
              .toList();
        }
      });
    }
    return result;
  }

  Future<void> _captureAndShare() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      String dateStr = DateFormat('dd-MM-yyyy').format(widget.selectedDate);
      await Share.shareXFiles(
        [XFile.fromData(pngBytes, mimeType: 'image/png', name: 'panchangam_$dateStr.png')],
        text: 'சுப தினப் பஞ்சாங்கம் - $dateStr | ${_astro['name'] ?? "GB ASTRO"}',
      );
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('பகிர்வதில் பிழை: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181824),
      appBar: AppBar(
        title: Text(
          'சுப தினப் பஞ்சாங்கம்',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF12121E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isLoading)
            _isCapturing
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
                  )
                : ElevatedButton.icon(
                    onPressed: _captureAndShare,
                    icon: const Icon(Icons.share_rounded, size: 18, color: Colors.black),
                    label: Text("பகிர் (Share)", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F),
                      foregroundColor: Colors.black,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          // 1. Off-screen full resolution capture container
          OverflowBox(
            minWidth: targetWidth,
            maxWidth: targetWidth,
            minHeight: targetHeight,
            maxHeight: targetHeight,
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: _globalKey,
              child: SizedBox(
                width: targetWidth,
                height: targetHeight,
                child: _buildPosterDesign(),
              ),
            ),
          ),

          // 2. Solid Background over capture container
          Positioned.fill(
            child: Container(color: const Color(0xFF181824)),
          ),

          // 3. Responsive on-screen preview
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.accent))
          else
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 520,
                      maxHeight: MediaQuery.of(context).size.height * 0.82,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: targetWidth,
                          height: targetHeight,
                          child: _buildPosterDesign(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SWARNA MANGALAM POSTER DESIGN
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildPosterDesign() {
    final p = widget.panchangamData;
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    String shopName = _astro['name'] ?? "GB ASTRO";
    String address = _astro['address'] ?? "";
    String phone = _astro['phone'] ?? "";
    final nowStr = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    // Tamil dates
    String tamilYear = p['tamil_year'] != null ? "${p['tamil_year']}" : "ஸ்ரீ குரோதி";
    String tamilMonth = p['tamil_month'] != null ? "${p['tamil_month']}" : "";
    String tamilDate = p['tamil_date'] != null ? "${p['tamil_date']}" : "";
    String tamilDateFull = "$tamilYear வருடம், $tamilMonth $tamilDate";
    String engDateFull = dateFormat.format(widget.selectedDate);

    // Vara (Day)
    String varaTamil = AstroUtils.getTamilNakshatra(p['vara'] ?? '');
    if (varaTamil.isEmpty || varaTamil == '-') {
      const days = ["ஞாயிறு", "திங்கள்", "செவ்வாய்", "புதன்", "வியாழன்", "வெள்ளி", "சனி"];
      varaTamil = days[widget.selectedDate.weekday % 7];
    } else {
      const dayMap = {
        'Sunday': 'ஞாயிறு', 'Monday': 'திங்கள்', 'Tuesday': 'செவ்வாய்',
        'Wednesday': 'புதன்', 'Thursday': 'வியாழன்', 'Friday': 'வெள்ளி', 'Saturday': 'சனி'
      };
      varaTamil = dayMap[p['vara']] ?? varaTamil;
    }

    // Ayanam & Rutu
    String ayanam = p['ayanam'] ?? '';
    if (ayanam.isEmpty || ayanam == '-') {
      final sunLon = (widget.chartResults?['planet_details']?['sun']?['longitude'] as num?)?.toDouble() ?? 0.0;
      ayanam = AstroUtils.getAyanam(sunLon);
    }

    String season = p['season'] ?? '';
    if (season.isEmpty || season == '-') {
      final sunLon = (widget.chartResults?['planet_details']?['sun']?['longitude'] as num?)?.toDouble() ?? 0.0;
      season = AstroUtils.getSeason(sunLon);
    }

    // Paksham
    String paksham = p['paksham'] ?? 'வளர்பிறை (சுக்ல பக்ஷம்)';

    // Tithi & End Time
    String tithi = AstroUtils.getTamilTithi(p['tithi'] ?? '-');
    String tithiEnd = p['tithi_end'] != null && p['tithi_end'] != '-' ? " (${p['tithi_end']} வரை)" : "";
    String tithiFull = "$tithi$tithiEnd";

    // Nakshatra & End Time
    String nakshatra = AstroUtils.getTamilNakshatra(p['nakshatra'] ?? '-');
    String nakEnd = p['nakshatra_end'] != null && p['nakshatra_end'] != '-' ? " (${p['nakshatra_end']} வரை)" : "";
    String nakFull = "$nakshatra$nakEnd";

    // Yoga & Karana
    String yoga = AstroUtils.getTamilYoga(p['yoga'] ?? '-');
    String yogaEnd = p['yoga_end'] != null && p['yoga_end'] != '-' ? " (${p['yoga_end']} வரை)" : "";
    String yogaFull = "$yoga$yogaEnd";
    String karana = AstroUtils.getTamilKarana(p['karana'] ?? '-');

    // Amirthathi, Nethram, Jeevan, Vivaga, Pancha Patchi
    String amirthathi = AstroUtils.getAmirthathiYogamTamil(p['amirthathi_yogam'] ?? 'sitham');
    String nethraJeeva = "${p['nethra'] ?? '2'} / ${p['jeeva'] ?? '1'}";
    String vivaga = p['vivaga'] ?? 'வடமேற்கு';
    String panjaPatchi = p['panja_patchi'] ?? 'வல்லூறு';

    // Chandrashtamam
    String chandrashtama = AstroUtils.getTamilNakshatra(p['chandrashtama'] ?? '-');

    // Soolam & Pariharam
    String soolam = AstroUtils.getSoolamTamil(p['soolam'] ?? 'north');
    String pariharam = AstroUtils.getPariharamTamil(p['pariharam'] ?? 'milk');

    // Timings
    String sunrise = p['sunrise'] ?? "06:00:00 AM";
    String sunset = p['sunset'] ?? "06:00:00 PM";
    String nallaNeram = (p['nalla_neram'] ?? "-").replaceAll(',\n', ', ');
    String rahuKalam = p['rahukalam'] ?? "-";
    String yemaGandam = p['yemagandam'] ?? "-";
    String kuliGai = p['kuligai'] ?? "-";

    return Container(
      width: targetWidth,
      height: targetHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFFBF6ED),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBF2), Color(0xFFF9F1E2)],
        ),
      ),
      child: Stack(
        children: [
          // Outer Decorative Double Border
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8B0000), width: 3.0),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Corner Flourishes
          const Positioned(top: 14, left: 14, child: Text("❖", style: TextStyle(color: Color(0xFFB58D3D), fontSize: 14))),
          const Positioned(top: 14, right: 14, child: Text("❖", style: TextStyle(color: Color(0xFFB58D3D), fontSize: 14))),
          const Positioned(bottom: 14, left: 14, child: Text("❖", style: TextStyle(color: Color(0xFFB58D3D), fontSize: 14))),
          const Positioned(bottom: 14, right: 14, child: Text("❖", style: TextStyle(color: Color(0xFFB58D3D), fontSize: 14))),

          // Content Column
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Astrologer Header Bar
                _buildModernHeader(shopName, address, phone, nowStr),

                const SizedBox(height: 6),

                // 2. Divine Title & Date Banner
                _buildDateBanner(engDateFull, varaTamil, tamilDateFull),

                const SizedBox(height: 6),

                // 3. Two-Column Main Content
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LEFT COLUMN: Core Panchangam & Auspicious Timings
                      Expanded(
                        flex: 11,
                        child: Column(
                          children: [
                            // 3.1 Core Panchangam Card
                            Expanded(
                              flex: 14,
                              child: _buildPanchangamCard(
                                tamilDateFull: tamilDateFull,
                                ayanam: ayanam,
                                season: season,
                                paksham: paksham,
                                tithiFull: tithiFull,
                                nakFull: nakFull,
                                yogaFull: yogaFull,
                                karana: karana,
                                amirthathi: amirthathi,
                                nethraJeeva: nethraJeeva,
                                vivaga: vivaga,
                                panjaPatchi: panjaPatchi,
                                chandrashtama: chandrashtama,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // 3.2 Timings Card
                            Expanded(
                              flex: 9,
                              child: _buildTimingsCard(
                                sunrise: sunrise,
                                sunset: sunset,
                                nallaNeram: nallaNeram,
                                rahuKalam: rahuKalam,
                                yemaGandam: yemaGandam,
                                kuliGai: kuliGai,
                                soolam: soolam,
                                pariharam: pariharam,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // RIGHT COLUMN: Rasi Chart & Horai / Gowri
                      Expanded(
                        flex: 12,
                        child: Column(
                          children: [
                            // 3.3 South Indian Chart Card
                            if (widget.chartResults != null) ...[
                              _buildChartCard(),
                              const SizedBox(height: 6),
                            ],

                            // 3.4 Horai & Gowri Slots Card
                            Expanded(
                              child: _buildHoraiGowriCard(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // 4. Regal Vedic Blessing Footer
                _buildRegalFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // SUB-COMPONENTS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildModernHeader(String shopName, String address, String phone, String nowStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Name & Address
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("🕉️ ", style: TextStyle(fontSize: 15, color: Color(0xFFB58D3D))),
                    Expanded(
                      child: Text(
                        shopName,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF5D1204),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    address,
                    style: const TextStyle(color: Color(0xFF795548), fontSize: 10.5, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Center Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Image.asset(
              'assets/images/logo.png',
              height: 42,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFB58D3D).withValues(alpha: 0.2)),
                child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFB58D3D), size: 26),
              ),
            ),
          ),

          // Right: Phone & Timestamp
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (phone.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB58D3D).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_rounded, size: 11, color: Color(0xFFB58D3D)),
                        const SizedBox(width: 3),
                        Text(
                          phone,
                          style: const TextStyle(color: Color(0xFF5D1204), fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  nowStr,
                  style: const TextStyle(color: Color(0xFF795548), fontSize: 9.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBanner(String engDate, String varaTamil, String tamilDateFull) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5D1204),
            Color(0xFF8B0000),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: English Date Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.5)),
            ),
            child: Text(
              engDate,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Center: Main Title
          Text(
            "✨ சுப தினப் பஞ்சாங்கம் ✨",
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD54F),
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),

          // Right: Tamil Day Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.5)),
            ),
            child: Text(
              varaTamil,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangamCard({
    required String tamilDateFull,
    required String ayanam,
    required String season,
    required String paksham,
    required String tithiFull,
    required String nakFull,
    required String yogaFull,
    required String karana,
    required String amirthathi,
    required String nethraJeeva,
    required String vivaga,
    required String panjaPatchi,
    required String chandrashtama,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF5D1204).withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader("🌟 பஞ்சாங்க அங்கங்கள்", icon: Icons.auto_awesome),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildPosterRow("தமிழ் தேதி", tamilDateFull, isBold: true),
                  _buildPosterRow("அயனம் / ருது", "$ayanam | $season"),
                  _buildPosterRow("பட்சம்", paksham, highlight: true),
                  _buildPosterRow("திதி", tithiFull, valueColor: const Color(0xFF0D47A1), isBold: true),
                  _buildPosterRow("நட்சத்திரம்", nakFull, valueColor: const Color(0xFF4A148C), isBold: true),
                  _buildPosterRow("யோகம்", yogaFull),
                  _buildPosterRow("கரணம்", karana),
                  _buildPosterRow("அமிர்தாதி யோகம்", amirthathi, valueColor: const Color(0xFF1B5E20), isBold: true),
                  _buildPosterRow("நேத்திரம் / ஜீவன்", nethraJeeva),
                  _buildPosterRow("விவாகச் சக்கரம்", vivaga),
                  _buildPosterRow("பஞ்சபட்சி", panjaPatchi),
                  _buildPosterRow("சந்திராஷ்டமம்", chandrashtama, valueColor: const Color(0xFFB71C1C), isBold: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingsCard({
    required String sunrise,
    required String sunset,
    required String nallaNeram,
    required String rahuKalam,
    required String yemaGandam,
    required String kuliGai,
    required String soolam,
    required String pariharam,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF5D1204).withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader("⏰ சுப & முக்கிய நேரங்கள்", icon: Icons.access_time_filled_rounded),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildPosterRow("சூரிய உதயம் / அஸ்தமனம்", "$sunrise | $sunset"),
                  _buildPosterRow("நல்ல நேரம்", nallaNeram, valueColor: const Color(0xFF1B5E20), isBold: true, isPill: true),
                  _buildPosterRow("ராகு காலம்", rahuKalam, valueColor: const Color(0xFFB71C1C), isBold: true),
                  _buildPosterRow("எமகண்டம்", yemaGandam, valueColor: const Color(0xFFB71C1C)),
                  _buildPosterRow("குளிகை", kuliGai, valueColor: const Color(0xFFE65100)),
                  _buildPosterRow("சூலம் & பரிகாரம்", "$soolam (பரிகாரம்: $pariharam)"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF5D1204).withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("🪐 கோச்சார ராசி கட்டம்", style: GoogleFonts.outfit(color: const Color(0xFF5D1204), fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 320,
            height: 320,
            child: SouthIndianChart(
              rasiMap: _castChartMap(widget.chartResults!['rasi']),
              centerLabel: "கோச்சார\nராசி",
              allowScroll: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoraiGowriCard() {
    final p = widget.panchangamData;
    String sunriseStr = p['sunrise'] ?? "06:00 AM";
    String sunsetStr = p['sunset'] ?? "06:00 PM";
    DateTime sunrise = _parseTimeString(sunriseStr, widget.selectedDate);
    DateTime sunset = _parseTimeString(sunsetStr, widget.selectedDate);

    int weekday = widget.selectedDate.weekday % 7;
    int dayLordIdx = [0, 3, 6, 2, 5, 1, 4][weekday];
    
    double dayTotalMins = sunset.difference(sunrise).inMinutes.toDouble();
    if (dayTotalMins <= 0) dayTotalMins = 720.0;
    double gowriSlot = dayTotalMins / 8.0;
    double horaiSlot = dayTotalMins / 12.0;

    List<Map<String, String>> horaiList = [];
    for (int i = 0; i < 12; i++) {
      int hIdx = (dayLordIdx + i) % 7;
      if (hIdx == 1 || hIdx == 2 || hIdx == 3 || hIdx == 5) {
        DateTime start = sunrise.add(Duration(minutes: (i * horaiSlot).toInt()));
        DateTime end = sunrise.add(Duration(minutes: ((i + 1) * horaiSlot).toInt()));
        horaiList.add({
          'time': "${_formatTime(start)} - ${_formatTime(end)}",
          'name': HORA_NAMES[hIdx],
        });
      }
    }

    int rahuSegment = [7, 1, 6, 4, 5, 3, 2][weekday];
    List<Map<String, String>> gowriList = [];
    for (int i = 0; i < 8; i++) {
      int gIdx = GOWRI_DAY_SEQ[weekday]![i];
      if (i == rahuSegment) {
        gIdx = 7;
      }
      if (gIdx <= 4) {
        DateTime start = sunrise.add(Duration(minutes: (i * gowriSlot).toInt()));
        DateTime end = sunrise.add(Duration(minutes: ((i + 1) * gowriSlot).toInt()));
        gowriList.add({
          'time': "${_formatTime(start)} - ${_formatTime(end)}",
          'name': GOWRI_TYPES[gIdx],
        });
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF5D1204).withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader("✨ சுப ஹோரை & நல்ல கௌரி", icon: Icons.schedule_rounded),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Suba Horai Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6EE),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("சுப ஹோரை (பகல்)", style: TextStyle(color: Color(0xFF5D1204), fontSize: 10.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Expanded(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: horaiList.length,
                            itemBuilder: (context, i) {
                              final item = horaiList[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 1.5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 13,
                                      child: Text(
                                        item['time']!,
                                        style: const TextStyle(color: Color(0xFF795548), fontSize: 9.2, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        item['name']!,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 9.2, fontWeight: FontWeight.w900),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Nalla Gowri Column
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF6EE),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("நல்ல கௌரி (பகல்)", style: TextStyle(color: Color(0xFF5D1204), fontSize: 10.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Expanded(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: gowriList.length,
                            itemBuilder: (context, i) {
                              final item = gowriList[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 1.5),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 13,
                                      child: Text(
                                        item['time']!,
                                        style: const TextStyle(color: Color(0xFF795548), fontSize: 9.2, fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        item['name']!,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 9.2, fontWeight: FontWeight.w900),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  Widget _buildCardHeader(String title, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFB58D3D).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: const Color(0xFFB58D3D)),
            const SizedBox(width: 5),
          ],
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              color: const Color(0xFF5D1204),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterRow(
    String label, String value, {
    Color? valueColor,
    bool isBold = false,
    bool highlight = false,
    bool isPill = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 9,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6D240E),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(" : ", style: TextStyle(color: Color(0xFF6D240E), fontSize: 10.5, fontWeight: FontWeight.bold)),
          Expanded(
            flex: 13,
            child: isPill
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: (valueColor ?? const Color(0xFF1B5E20)).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: (valueColor ?? const Color(0xFF1B5E20)).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: valueColor ?? const Color(0xFF1F2937),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? const Color(0xFF1F2937),
                      fontSize: 11,
                      fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegalFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("卐 ", style: TextStyle(color: Color(0xFFB58D3D), fontSize: 12, fontWeight: FontWeight.bold)),
          Text(
            "ஸர்வமங்களம் உண்டாகட்டும் | சுபமஸ்து",
            style: GoogleFonts.outfit(
              color: const Color(0xFF5D1204),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const Text(" 卐", style: TextStyle(color: Color(0xFFB58D3D), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  DateTime _parseTimeString(String timeStr, DateTime baseDate) {
    try {
      final cleanStr = timeStr.trim();
      final parts = cleanStr.split(" ");
      final hm = parts[0].split(":");
      int h = int.parse(hm[0]);
      int m = int.parse(hm[1]);
      String ampm = parts[1].toUpperCase();
      if (ampm == "PM" && h < 12) h += 12;
      if (ampm == "AM" && h == 12) h = 0;
      return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m);
    } catch (e) {
      if (timeStr.toLowerCase().contains("pm")) {
        return DateTime(baseDate.year, baseDate.month, baseDate.day, 18, 0);
      }
      return DateTime(baseDate.year, baseDate.month, baseDate.day, 6, 0);
    }
  }

  String _formatTime(DateTime dt) {
    int h = dt.hour % 12;
    if (h == 0) h = 12;
    String m = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? "PM" : "AM";
    return "$h:$m $period";
  }

  static const List<String> HORA_NAMES = ["சூரியன்", "சுக்கிரன்", "புதன்", "சந்திரன்", "சனி", "குரு", "செவ்வாய்"];
  static const List<String> GOWRI_TYPES = ["அமிர்தம்", "சுகம்", "லாபம்", "தனம்", "உத்தியோகம்", "ரோகம்", "சோரம்", "விஷம்"];
  static const Map<int, List<int>> GOWRI_DAY_SEQ = {
    0: [4, 0, 5, 2, 3, 1, 7, 6],
    1: [0, 5, 2, 3, 1, 7, 6, 4],
    2: [5, 2, 3, 1, 7, 6, 4, 0],
    3: [2, 3, 1, 7, 6, 4, 0, 5],
    4: [3, 1, 7, 6, 4, 0, 5, 2],
    5: [1, 7, 6, 4, 0, 5, 2, 3],
    6: [7, 6, 4, 0, 5, 2, 3, 1],
  };
}
