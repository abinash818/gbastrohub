import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/kp_service.dart';
import '../components/south_indian_chart.dart';
import '../services/astro_data.dart';
import '../services/pdf_service.dart';
import '../components/custom_drawer.dart';
import '../data/nakshatra_data.dart';
import '../theme/app_colors.dart';
import 'pdf_viewer_screen.dart';
import '../services/one_page_pdf_service.dart';
import '../services/kp_one_page_pdf_service.dart';
import '../services/full_report_pdf_service.dart';
import '../services/settings_service.dart';
import '../services/astro_translation_service.dart';
import '../services/palangal_service.dart';
import 'dart:io' show Platform;
import 'package:astrology_flutter/l10n/app_localizations.dart';

class HoroscopeResultsScreen extends StatefulWidget {
  final Map<String, dynamic> results;
  final String name;

  const HoroscopeResultsScreen({super.key, required this.results, required this.name});

  @override
  State<HoroscopeResultsScreen> createState() => _HoroscopeResultsScreenState();
}

class _HoroscopeResultsScreenState extends State<HoroscopeResultsScreen> {
  Map<String, dynamic>? _selectedDasa;
  Map<String, dynamic>? _selectedBukthi;
  Map<String, dynamic>? _selectedAntharam;
  Map<String, dynamic>? _selectedSookshmam;
  Map<String, dynamic>? _selectedPranam;
  String _selectedBavPlanet = "Sun";
  String _selectedVargam = 'அனைத்தும்';
  bool _isGenerating = false;
  
  @override
  void initState() {
    super.initState();
    _autoSelectCurrentDasa();
  }

  void _autoSelectCurrentDasa() {
    final List<dynamic>? dasaList = widget.results['dasa'];
    if (dasaList == null || dasaList.isEmpty) return;
    
    DateTime now = DateTime.now();
    final birthDt = widget.results['birth_dt'] as DateTime?;
    if (birthDt != null && now.isBefore(birthDt)) {
      now = birthDt;
    }

    for (var d in dasaList) {
      final dStart = d['start'] as DateTime?;
      final dEnd = d['end'] as DateTime?;
      if (dStart != null && dEnd != null && !now.isBefore(dStart) && now.isBefore(dEnd)) {
        _selectedDasa = d;
        for (var b in (d['subPeriods'] as List? ?? [])) {
          final bStart = b['start'] as DateTime?;
          final bEnd = b['end'] as DateTime?;
          if (bStart != null && bEnd != null && !now.isBefore(bStart) && now.isBefore(bEnd)) {
            _selectedBukthi = b;
            for (var a in (b['subPeriods'] as List? ?? [])) {
              final aStart = a['start'] as DateTime?;
              final aEnd = a['end'] as DateTime?;
              if (aStart != null && aEnd != null && !now.isBefore(aStart) && now.isBefore(aEnd)) {
                _selectedAntharam = a;
                for (var s in (a['subPeriods'] as List? ?? [])) {
                  final sStart = s['start'] as DateTime?;
                  final sEnd = s['end'] as DateTime?;
                  if (sStart != null && sEnd != null && !now.isBefore(sStart) && now.isBefore(sEnd)) {
                    _selectedSookshmam = s;
                    for (var p in (s['subPeriods'] as List? ?? [])) {
                      final pStart = p['start'] as DateTime?;
                      final pEnd = p['end'] as DateTime?;
                      if (pStart != null && pEnd != null && !now.isBefore(pStart) && now.isBefore(pEnd)) {
                        _selectedPranam = p;
                        break;
                      }
                    }
                    break;
                  }
                }
                break;
              }
            }
            break;
          }
        }
        break;
      }
    }

    if (_selectedDasa == null && dasaList.isNotEmpty) {
      _selectedDasa = dasaList.first;
      final subPeriods = _selectedDasa!['subPeriods'] as List? ?? [];
      if (subPeriods.isNotEmpty) {
        _selectedBukthi = subPeriods.firstWhere(
          (b) => !(b['end'] as DateTime).isBefore(birthDt ?? dasaList.first['start']),
          orElse: () => subPeriods.first,
        );
      }
    }
  }

  String _calculateAge(DateTime? targetDate) {
    if (targetDate == null) return "வயது : 0 வ, 0 மா, 0 நா";
    final dob = widget.results['birth_dt'] as DateTime?;
    if (dob == null) return "வயது : 0 வ, 0 மா, 0 நா";
    
    int years = targetDate.year - dob.year;
    int months = targetDate.month - dob.month;
    int days = targetDate.day - dob.day;
    
    if (days < 0) {
      months -= 1;
      days += DateTime(targetDate.year, targetDate.month, 0).day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (years < 0) years = 0;
    if (months < 0) months = 0;
    if (days < 0) days = 0;
    
    return AppLocalizations.of(context)!.ageFormat(years, months, days);
  }

  bool _showGocharam = false;
  bool _isLoadingGocharam = false;
  Map<String, String>? _gocharamLabels;

  Future<void> _handleOnePageReport() async {
    if (kIsWeb) {
      if (widget.results['isKp'] == true) {
        KpOnePagePdfService.showHtmlReport(
          name: widget.results['name'] ?? widget.name,
          gender: widget.results['gender'] ?? "-",
          results: widget.results,
          l10n: AppLocalizations.of(context)!,
        );
      } else {
        OnePagePdfService.showHtmlReport(
          name: widget.results['name'] ?? widget.name,
          gender: widget.results['gender'] ?? "-",
          results: widget.results,
          l10n: AppLocalizations.of(context)!,
        );
      }
    } else {
      if (_isGenerating) return;
      setState(() => _isGenerating = true);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
      
      try {
        final bytes = widget.results['isKp'] == true
            ? await KpOnePagePdfService.generate(
                name: widget.results['name'] ?? widget.name,
                gender: widget.results['gender'] ?? "-",
                results: widget.results,
                l10n: AppLocalizations.of(context)!,
              )
            : await OnePagePdfService.generate(
                name: widget.results['name'] ?? widget.name,
                gender: widget.results['gender'] ?? "-",
                results: widget.results,
                l10n: AppLocalizations.of(context)!,
              );
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        
        final fileNamePrefix = widget.results['isKp'] == true ? "KP_OnePageHoroscope" : "OnePageHoroscope";
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfBytes: bytes,
              fileName: "${fileNamePrefix}_${widget.name.replaceAll(' ', '_')}.pdf",
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _handleKpOnePageReport() async {
    if (kIsWeb) {
      KpOnePagePdfService.showHtmlReport(
        name: widget.results['name'] ?? widget.name,
        gender: widget.results['gender'] ?? "-",
        results: widget.results,
        l10n: AppLocalizations.of(context)!,
      );
    } else {
      if (_isGenerating) return;
      setState(() => _isGenerating = true);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
      
      try {
        final bytes = await KpOnePagePdfService.generate(
          name: widget.results['name'] ?? widget.name,
          gender: widget.results['gender'] ?? "-",
          results: widget.results,
          l10n: AppLocalizations.of(context)!,
        );
        if (!mounted) return;
        Navigator.pop(context);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfBytes: bytes,
              fileName: "KP_OnePageHoroscope_${widget.name.replaceAll(' ', '_')}.pdf",
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _toggleGocharam() async {
    if (_showGocharam) {
      setState(() { _showGocharam = false; });
      return;
    }

    if (_gocharamLabels != null) {
      setState(() { _showGocharam = true; });
      return;
    }

    setState(() { _isLoadingGocharam = true; });
    try {
      final now = DateTime.now();
      final lat = widget.results['place_lat'] ?? 13.0827;
      final lon = widget.results['place_lon'] ?? 80.2707;
      final tz = widget.results['place_tz'] ?? 5.5;

      final transitResults = await KPService.calculateChart("Transit", now, lat, lon, tz);
      final Map<String, List<String>> transitRasiMap = _castChartMap(transitResults['rasi']);
      
      Map<String, String> labels = {};
      transitRasiMap.forEach((sign, items) {
        List<String> shortItems = items.map((it) {
          return it.contains(" ") ? it.split(" ").first : it;
        }).toList();
        labels[sign] = shortItems.join("\n");
      });

      if (mounted) {
        setState(() {
          _gocharamLabels = labels;
          _showGocharam = true;
          _isLoadingGocharam = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoadingGocharam = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;

    final bool isKp = widget.results['isKp'] ?? false;
    final bool isNadi = widget.results['isNadi'] ?? false;
    final bool isPrasannam = widget.results['isPrasannam'] ?? false;
    
    int tabLength = 0;
    if (isPrasannam) {
      tabLength = 2;
    } else {
      tabLength = 8;
      if (isKp) tabLength += 4;
    }

    final tabsList = [
      if (isPrasannam) Tab(text: AppLocalizations.of(context)!.tabPrasannam),
      Tab(text: AppLocalizations.of(context)!.tabDetails),
      if (!isPrasannam) Tab(text: AppLocalizations.of(context)!.tabChart),
      if (!isPrasannam) Tab(text: AppLocalizations.of(context)!.tabPadasaram),
      if (isKp && !isPrasannam) Tab(text: AppLocalizations.of(context)!.tabKpCusps),
      if (isKp && !isPrasannam) Tab(text: AppLocalizations.of(context)!.tabKpPlanets),
      if (isKp && !isPrasannam) Tab(text: AppLocalizations.of(context)!.tabSignificators),
      if (isKp && !isPrasannam) Tab(text: AppLocalizations.of(context)!.tabStarSignificators),
      if (!isPrasannam) Tab(text: AppLocalizations.of(context)!.tabDasaBukthi),
      if (!isPrasannam) Tab(text: AppLocalizations.of(context)!.tabAshtakavarga),
      if (!isPrasannam) Tab(text: AppLocalizations.of(context)!.tabDasavarga),
      if (!isPrasannam) const Tab(text: "ஷட்பலம்"),
      if (!isPrasannam) Tab(text: AppLocalizations.of(context)!.tabPalangal),
    ];

    final tabViewsList = [
      if (isPrasannam) _buildPrasannamView(),
      _buildVivaramView(),
      if (!isPrasannam) _buildKattamView(),
      if (!isPrasannam) _buildPlanetsView(),
      if (isKp && !isPrasannam) _buildKpCuspsView(),
      if (isKp && !isPrasannam) _buildKpPlanetsView(),
      if (isKp && !isPrasannam) _buildSignificatorsView(),
      if (isKp && !isPrasannam) _buildStarSignificatorsView(),
      if (!isPrasannam) (isWide ? _buildWideDasaView() : _buildDasaView()),
      if (!isPrasannam) _buildAshtakavargaView(),
      if (!isPrasannam) _buildDasavarkkamView(),
      if (!isPrasannam) _buildShadbalaView(),
      if (!isPrasannam) _buildPalangalView(),
    ];

    return DefaultTabController(
      length: tabLength,
      initialIndex: (isPrasannam || isNadi) ? 0 : 0, // Keep at 0 for Prasannam or details
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: isWide ? null : AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5D1204).withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, size: 20, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  isPrasannam ? AppLocalizations.of(context)!.tabPrasannam : "GB ASTRO",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cinzel(
                    color: AppColors.primary, 
                    fontWeight: FontWeight.w900, 
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                tooltip: AppLocalizations.of(context)!.pdfDownload,
                onPressed: _handleOnePageReport,
              )
            else
              PopupMenuButton<String>(
                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                tooltip: AppLocalizations.of(context)!.pdfDownload,
                onSelected: (value) {
                  if (value == 'one_page') {
                    _handleOnePageReport();
                  } else if (value == 'kp_one_page') {
                    _handleKpOnePageReport();
                  } else if (value == 'full_report') {
                    _handleFullReport();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'one_page',
                    child: Text(AppLocalizations.of(context)!.onePageA5),
                  ),
                  PopupMenuItem(
                    value: 'kp_one_page',
                    child: Text(AppLocalizations.of(context)!.kpOnePageA5),
                  ),
                  if (!kIsWeb && Platform.isWindows)
                    PopupMenuItem(
                      value: 'full_report',
                      child: Text(AppLocalizations.of(context)!.fullReport),
                    ),
                ],
              ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: const Color(0xFF5D1204).withOpacity(0.5),
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13.5),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: tabsList,
          ),
        ),
        drawer: isWide ? null : const CustomDrawer(),
        body: Row(
          children: [
            if (isWide)
              const SizedBox(
                width: 280,
                child: CustomDrawer(),
              ),
            Expanded(
              child: isWide 
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: AppColors.background,
                        child: Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                isScrollable: true,
                                indicatorColor: AppColors.primary,
                                labelColor: AppColors.primary,
                                unselectedLabelColor: const Color(0xFF5D1204).withOpacity(0.5),
                                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13.5),
                                unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
                                tabs: tabsList,
                              ),
                            ),
                            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                                tooltip: AppLocalizations.of(context)!.pdfDownload,
                                onPressed: _handleOnePageReport,
                              )
                            else
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                                tooltip: AppLocalizations.of(context)!.pdfDownload,
                                onSelected: (value) {
                                  if (value == 'one_page') {
                                    _handleOnePageReport();
                                  } else if (value == 'kp_one_page') {
                                    _handleKpOnePageReport();
                                  } else if (value == 'full_report') {
                                    _handleFullReport();
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'one_page',
                                    child: Text(AppLocalizations.of(context)!.onePageA5),
                                  ),
                                  PopupMenuItem(
                                    value: 'kp_one_page',
                                    child: Text(AppLocalizations.of(context)!.kpOnePageA5),
                                  ),
                                  if (!kIsWeb && Platform.isWindows)
                                    PopupMenuItem(
                                      value: 'full_report',
                                      child: Text(AppLocalizations.of(context)!.fullReport),
                                    ),
                                ],
                              ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: tabViewsList,
                        ),
                      ),
                    ],
                  )
                : TabBarView(
                    children: tabViewsList,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpCuspsView() {
    final Map<dynamic, dynamic>? cusps = widget.results['houses_data'];
    if (cusps == null) return Center(child: Text(AppLocalizations.of(context)!.noDetails));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.kpCuspsTitle, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.05)),
              columns: [
                DataColumn(label: Text(AppLocalizations.of(context)!.bhavam, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.sign, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.degree, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.signLord, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.starLord, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.subLord, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(12, (index) {
                final houseNum = index + 1;
                final data = cusps[houseNum];
                if (data == null) return const DataRow(cells: []);
                final lords = data['lords'] ?? {};
                final double lon = data['longitude'] ?? 0;
                
                return DataRow(cells: [
                  DataCell(Text(houseNum.toString())),
                  DataCell(Text(AstroTranslationService.translate(context, KPService.TAMIL_SIGNS[lords['sign']] ?? lords['sign'] ?? "-"))),
                  DataCell(Text(KPService.formatDegrees(lon))),
                  DataCell(Text(AstroTranslationService.translate(context, KPService.TAMIL_PLANETS[KPService.SIGN_LORDS[KPService.SIGNS.indexOf(lords['sign'])]] ?? "-", isPlanet: true))),
                  DataCell(Text(AstroTranslationService.translate(context, KPService.TAMIL_PLANET_SHORT[lords['nakLord']] ?? lords['nakLord'] ?? "-", isPlanet: true))),
                  DataCell(Text(AstroTranslationService.translate(context, KPService.TAMIL_PLANETS[lords['subLord']] ?? lords['subLord'] ?? "-", isPlanet: true))),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpPlanetsView() {
    final Map<String, dynamic>? data = widget.results['planet_details'];
    if (data == null) return Center(child: Text(AppLocalizations.of(context)!.noDetails));

    const List<String> sortedKeys = ["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu", "ketu", "maanthi"];
    final Map<String, String> planetTamilNames = {
        "sun": "சூரியன்", "moon": "சந்திரன்", "mars": "செவ்வாய்", "mercury": "புதன்", 
        "jupiter": "குரு", "venus": "சுக்கிரன்", "saturn": "சனி", "rahu": "ராகு", "ketu": "கேது", "maanthi": "மாந்தி"
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.kpPlanetsTitle, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.05)),
              columns: [
                DataColumn(label: Text(AppLocalizations.of(context)!.planet, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.sign, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.degree, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.signLord, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.starLord, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(AppLocalizations.of(context)!.subLord, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: sortedKeys.map((key) {
                final p = data[key];
                if (p == null) return const DataRow(cells: []);
                final lords = p['lords'] ?? {};
                final double lon = p['longitude'] ?? 0;

                return DataRow(cells: [
                  DataCell(Text(AstroTranslationService.translate(context, planetTamilNames[key] ?? key, isPlanet: true))),
                  DataCell(Text(AstroTranslationService.translate(context, KPService.TAMIL_SIGNS[lords['sign']] ?? lords['sign'] ?? "-"))),
                  DataCell(Text(KPService.formatDegrees(lon))),
                  DataCell(Text(AstroTranslationService.translate(context, KPService.TAMIL_PLANETS[KPService.SIGN_LORDS[KPService.SIGNS.indexOf(lords['sign'])]] ?? "-", isPlanet: true))),
                  DataCell(Text(AstroTranslationService.translate(context, KPService.TAMIL_PLANET_SHORT[lords['nakLord']] ?? lords['nakLord'] ?? "-", isPlanet: true))),
                  DataCell(Text(AstroTranslationService.translate(context, KPService.TAMIL_PLANETS[lords['subLord']] ?? lords['subLord'] ?? "-", isPlanet: true))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignificatorsView() {
    final Map<String, dynamic>? sigs = widget.results['significators'];
    if (sigs == null) return Center(child: Text(AppLocalizations.of(context)!.noDetails));

    final planetView = sigs['planet_view'] as Map<String, dynamic>;
    final houseView = sigs['house_view'] as Map<dynamic, dynamic>;

    const List<String> planetKeys = ["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu", "ketu"];
    final Map<String, String> planetTamilNames = {
        "sun": "சூரியன்", "moon": "சந்திரன்", "mars": "செவ்வாய்", "mercury": "புதன்", 
        "jupiter": "குரு", "venus": "சுக்கிரன்", "saturn": "சனி", "rahu": "ராகு", "ketu": "கேது"
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.planetSignificators, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.05)),
              columnSpacing: 25,
              columns: [
                DataColumn(label: Text(AppLocalizations.of(context)!.planet, style: const TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('(A)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('(B)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('(C)', style: TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('(D)', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: planetKeys.map((key) {
                final pSig = planetView[key] ?? {'A': '-', 'B': '-', 'C': '-', 'D': '-'};
                return DataRow(cells: [
                  DataCell(Text(planetTamilNames[key] ?? key, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(pSig['A'].toString())),
                  DataCell(Text(pSig['B'].toString())),
                  DataCell(Text(pSig['C'].toString())),
                  DataCell(Text(pSig['D'].toString())),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),
          Text(AppLocalizations.of(context)!.houseSignificators, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.05)),
              columnSpacing: 25,
              columns: [
                DataColumn(label: Text(AppLocalizations.of(context)!.bhavam, style: const TextStyle(fontWeight: FontWeight.bold))),
                const DataColumn(label: Text('(A)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('(B)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('(C)', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('(D)', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(12, (index) {
                final houseNum = index + 1;
                final hSig = houseView[houseNum] ?? {'A': [], 'B': [], 'C': [], 'D': []};
                
                return DataRow(cells: [
                  DataCell(Text(houseNum.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text((hSig['A'] as List).join(', '))),
                  DataCell(Text((hSig['B'] as List).join(', '))),
                  DataCell(Text((hSig['C'] as List).join(', '))),
                  DataCell(Text((hSig['D'] as List).join(', '))),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarSignificatorsView() {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, dynamic>? data = widget.results['planet_details'];
    if (data == null) return Center(child: Text(AppLocalizations.of(context)!.noDetails));

    const List<String> sortedKeys = ["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu", "ketu", "maanthi"];
    final Map<String, String> planetTamilNames = {
        "sun": "சூரியன்", "moon": "சந்திரன்", "mars": "செவ்வாய்", "mercury": "புதன்", 
        "jupiter": "குரு", "venus": "சுக்கிரன்", "saturn": "சனி", "rahu": "ராகு", "ketu": "கேது", "maanthi": "மாந்தி"
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Jathaga (Rasi) & Bhavaga (Bhava) Charts
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.rasiChart,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          SouthIndianChart(
                            rasiMap: _castChartMap(widget.results['rasi']),
                            centerLabel: l10n.rasiLabel,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.bhavaChart,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          SouthIndianChart(
                            rasiMap: _castChartMap(widget.results['pavagam']),
                            centerLabel: "பாவகம்",
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.rasiChart,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    SouthIndianChart(
                      rasiMap: _castChartMap(widget.results['rasi']),
                      centerLabel: l10n.rasiLabel,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)!.bhavaChart,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    SouthIndianChart(
                      rasiMap: _castChartMap(widget.results['pavagam']),
                      centerLabel: "பாவகம்",
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 30),
          const Divider(thickness: 1.2, color: Color(0xFFB58D3D)),
          const SizedBox(height: 20),
          
          Text(AppLocalizations.of(context)!.tabSignificators, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: AppColors.primaryLight.withOpacity(0.5), width: 1),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.2),
            },
            children: [
              _buildKbTableHeader([AstroTranslationService.translate(context, 'கிரகம்'), AstroTranslationService.translate(context, 'நட்சத்திரம் பாதம்'), AstroTranslationService.translate(context, 'நட்சத்திர அதிபதி'), AstroTranslationService.translate(context, 'பாவ தொடர்பு')]),
              ...sortedKeys.map((key) {
                final p = data[key];
                if (p == null) return _buildTableRow(['', '', '', '']);
                
                final lords = p['lords'] ?? {};
                int x = p['house'] ?? 0;
                
                String starLordNameEn = (lords['nakLord'] ?? '').toString().toLowerCase();
                final slData = data[starLordNameEn];
                int y = slData?['house'] ?? 0;

                String planetName = "${AstroTranslationService.translate(context, planetTamilNames[key] ?? key, isPlanet: true)} $x";
                String nakshatraPada = "${AstroTranslationService.translate(context, lords['nakshatra'] ?? '-')} ${p['pada'] ?? ''}";
                String slName = "${AstroTranslationService.translate(context, KPService.TAMIL_PLANETS[lords['nakLord']] ?? lords['nakLord'], isPlanet: true)} ${y > 0 ? '$y${AstroTranslationService.translate(context, ' ல்')}' : ''}";
                
                String connection = _calculateKbConnection(x, y);

                return _buildTableRow([planetName, nakshatraPada, slName, connection]);
              }).toList(),
            ],
          ),
          
          const SizedBox(height: 30),
          Text(AppLocalizations.of(context)!.tabStarSignificators, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: AppColors.primaryLight.withOpacity(0.5), width: 1),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.2),
            },
            children: [
              _buildKbTableHeader([AstroTranslationService.translate(context, 'பாவ ஆரம்ப முனை'), AstroTranslationService.translate(context, 'நட்சத்திர பாதம்'), AstroTranslationService.translate(context, 'நட்சத்திர அதிபதி'), AstroTranslationService.translate(context, 'நின்ற நட்சத்திர அதிபதி'), AstroTranslationService.translate(context, 'பாவ தொடர்பு')]),
              ...List.generate(12, (index) {
                int cuspNum = index + 1;
                final Map<dynamic, dynamic>? cusps = widget.results['houses_data'];
                if (cusps == null || cusps[cuspNum] == null) return _buildTableRow(['', '', '', '', '']);
                
                final cuspData = cusps[cuspNum];
                final cLords = cuspData['lords'] ?? {};
                
                // Cusp's Star Lord
                String aNameEn = (cLords['nakLord'] ?? '').toString().toLowerCase();
                final aData = data[aNameEn];
                int aHouse = aData?['house'] ?? 0;
                
                // Star Lord's Star Lord
                final aLords = aData?['lords'] ?? {};
                String bNameEn = (aLords['nakLord'] ?? '').toString().toLowerCase();
                final bData = data[bNameEn];
                int bHouse = bData?['house'] ?? 0;

                // For Pada of Cusp
                double hLon = (cuspData['longitude'] ?? 0).toDouble();
                String nakshatra = KPService.NAKSHATRAS[(hLon / (360/27)).floor() % 27];
                int pada = ((hLon % (360/27)) / (360/108)).floor() + 1;

                String cuspName = "$cuspNum";
                String nakPada = "${AstroTranslationService.translate(context, nakshatra)} $pada";
                String aStr = "${AstroTranslationService.translate(context, KPService.TAMIL_PLANETS[cLords['nakLord']] ?? cLords['nakLord'], isPlanet: true)} ${aHouse > 0 ? '$aHouse' : ''}";
                String bStr = "${AstroTranslationService.translate(context, KPService.TAMIL_PLANET_SHORT[aLords['nakLord']] ?? aLords['nakLord'], isPlanet: true)} ${bHouse > 0 ? '$bHouse' : ''}";
                
                String connection = _calculateKbConnection(aHouse, bHouse);

                return _buildTableRow([cuspName, nakPada, aStr, bStr, connection]);
              }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _calculateKbConnection(int x, int y) {
    if (x <= 0 || y <= 0) return "-";
    int prevY = y - 1;
    if (prevY == 0) prevY = 12;
    int prevX = x - 1;
    if (prevX == 0) prevX = 12;
    
    if (x == prevY) {
      return "$x";
    } else if (y == prevX) {
      return "$y";
    } else if (x == y) {
      return "$x";
    } else {
      return "$y, $x";
    }
  }

  TableRow _buildKbTableHeader(List<String> headers) {
    return TableRow(
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
      children: headers.map((h) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary), textAlign: TextAlign.center),
      )).toList(),
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells.map((c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        child: Text(c, style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
      )).toList(),
    );
  }

  Widget _buildDasaView() {
    final List<dynamic>? dasaList = widget.results['dasa'];
    if (dasaList == null) return const Center(child: Text('தசாபுத்தி விவரங்கள் இல்லை'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 1. Dasa Section
          _buildDasaSection(AppLocalizations.of(context)!.dasa, dasaList, _selectedDasa, (selected) {
            setState(() {
              if (_selectedDasa == selected) {
                _selectedDasa = null;
                _selectedBukthi = null;
                _selectedAntharam = null;
                _selectedSookshmam = null;
                _selectedPranam = null;
              } else {
                _selectedDasa = selected;
                _selectedBukthi = null;
                _selectedAntharam = null;
                _selectedSookshmam = null;
                _selectedPranam = null;
              }
            });
          }),
          
          // 2. Bhukti Section
          if (_selectedDasa != null) ...[
            const SizedBox(height: 20),
            _buildDasaSection(AppLocalizations.of(context)!.bukthi, _selectedDasa!['subPeriods'] ?? [], _selectedBukthi, (selected) {
              setState(() {
                if (_selectedBukthi == selected) {
                  _selectedBukthi = null;
                  _selectedAntharam = null;
                  _selectedSookshmam = null;
                  _selectedPranam = null;
                } else {
                  _selectedBukthi = selected;
                  _selectedAntharam = null;
                  _selectedSookshmam = null;
                  _selectedPranam = null;
                }
              });
            }),
          ],

          // 3. Antharam Section
          if (_selectedBukthi != null) ...[
            const SizedBox(height: 20),
            _buildDasaSection(AppLocalizations.of(context)!.antharam, _selectedBukthi!['subPeriods'] ?? [], _selectedAntharam, (selected) {
              setState(() {
                if (_selectedAntharam == selected) {
                  _selectedAntharam = null;
                  _selectedSookshmam = null;
                  _selectedPranam = null;
                } else {
                  _selectedAntharam = selected;
                  _selectedSookshmam = null;
                  _selectedPranam = null;
                }
              });
            }),
          ],

          // 4. Sookshmam Section
          if (_selectedAntharam != null) ...[
            const SizedBox(height: 20),
            _buildDasaSection(AppLocalizations.of(context)!.sookshmam, _selectedAntharam!['subPeriods'] ?? [], _selectedSookshmam, (selected) {
              setState(() {
                if (_selectedSookshmam == selected) {
                  _selectedSookshmam = null;
                  _selectedPranam = null;
                } else {
                  _selectedSookshmam = selected;
                  _selectedPranam = null;
                }
              });
            }),
          ],

          // 5. Pranam Section
          if (_selectedSookshmam != null) ...[
            const SizedBox(height: 20),
            _buildDasaSection(
              AppLocalizations.of(context)!.localeName == 'en' ? 'Prana' : (AppLocalizations.of(context)!.localeName == 'hi' ? 'प्राण' : 'பிராணம்'),
              _selectedSookshmam!['subPeriods'] ?? [],
              _selectedPranam,
              (selected) {
                setState(() {
                  if (_selectedPranam == selected) {
                    _selectedPranam = null;
                  } else {
                    _selectedPranam = selected;
                  }
                });
              },
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDasaSection(String title, List<dynamic> periods, Map<String, dynamic>? selectedItem, Function(Map<String, dynamic>) onSelect) {
    final l10n = AppLocalizations.of(context)!;
    // If an item is selected, we only show that one row (as a header).
    // Otherwise, we show the full table.
    final List<dynamic> displayList = selectedItem != null ? [selectedItem] : periods;
    final bool isHeaderStyle = selectedItem != null;

    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF5D1204))),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            border: TableBorder.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 0.8),
            columnWidths: const {
              0: FixedColumnWidth(35),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Color(0xFF5D1204)),
                children: [
                  TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text("No", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                  TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(l10n.lord, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                  TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(l10n.start, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                  TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(l10n.end, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                ],
              ),
              ...List.generate(displayList.length, (index) {
                final p = displayList[index];
                // Find original index if it's a filtered list
                int originalIdx = periods.indexOf(p) + 1;
                
                final bool isToday = DateTime.now().isAfter(p['start']) && DateTime.now().isBefore(p['end']);
                
                return TableRow(
                  children: [
                    _buildInteractiveCell(
                      originalIdx.toString(), 
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isHeaderStyle,
                    ),
                    _buildInteractiveCell(
                      AstroTranslationService.translate(context, p['lord']?.toString().trim() ?? "-", isPlanet: true), 
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isHeaderStyle,
                    ),
                    _buildInteractiveCell(
                      _formatDateOnly(p['start']), 
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isHeaderStyle,
                    ),
                    _buildInteractiveCell(
                      _formatDateOnly(p['end']), 
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isHeaderStyle,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveCell(String text, {required VoidCallback onTap, bool isToday = false, bool isSelected = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isToday 
              ? const Color(0xFFFFD54F).withOpacity(0.3) 
              : (isSelected ? const Color(0xFFFAF6EE) : Colors.white),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF5D1204),
            fontWeight: (isToday || isSelected) ? FontWeight.w900 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDasaHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  String _formatDateOnly(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return "$d-$m-$y";
  }

  Widget _buildWideDasaView() {
    final List<dynamic>? dasaList = widget.results['dasa'];
    if (dasaList == null) return const Center(child: Text('தசாபுத்தி விவரங்கள் இல்லை'));

    final selectedBukthiList = _selectedDasa != null ? (_selectedDasa!['subPeriods'] as List? ?? []) : [];
    final selectedAntharamList = _selectedBukthi != null ? (_selectedBukthi!['subPeriods'] as List? ?? []) : [];
    final selectedSookshmamList = _selectedAntharam != null ? (_selectedAntharam!['subPeriods'] as List? ?? []) : [];
    final selectedPranamList = _selectedSookshmam != null ? (_selectedSookshmam!['subPeriods'] as List? ?? []) : [];

    DateTime? activeDate = _selectedPranam?['start'] ?? _selectedSookshmam?['start'] ?? _selectedAntharam?['start'] ?? _selectedBukthi?['start'] ?? _selectedDasa?['start'];
    
    String currentSelectionStr = "";
    if (_selectedDasa != null) currentSelectionStr += "${AppLocalizations.of(context)!.dasa}: ${AstroTranslationService.translate(context, _selectedDasa!['lord'], isPlanet: true)}\n";
    if (_selectedBukthi != null) currentSelectionStr += "${AppLocalizations.of(context)!.bukthi}: ${AstroTranslationService.translate(context, _selectedBukthi!['lord'], isPlanet: true)}\n";
    if (_selectedAntharam != null) currentSelectionStr += "${AppLocalizations.of(context)!.antharam}: ${AstroTranslationService.translate(context, _selectedAntharam!['lord'], isPlanet: true)}\n";
    if (_selectedSookshmam != null) currentSelectionStr += "${AppLocalizations.of(context)!.sookshmam}: ${AstroTranslationService.translate(context, _selectedSookshmam!['lord'], isPlanet: true)}\n";
    if (_selectedPranam != null) currentSelectionStr += "${AppLocalizations.of(context)!.localeName == 'en' ? 'Prana' : (AppLocalizations.of(context)!.localeName == 'hi' ? 'प्राण' : 'பிராணம்')}: ${AstroTranslationService.translate(context, _selectedPranam!['lord'], isPlanet: true)}";

    String dateRangeStr = "";
    if (_selectedPranam != null) {
      dateRangeStr = "${_formatDateOnly(_selectedPranam!['start'])}  -  ${_formatDateOnly(_selectedPranam!['end'])}";
    } else if (_selectedSookshmam != null) {
      dateRangeStr = "${_formatDateOnly(_selectedSookshmam!['start'])}  -  ${_formatDateOnly(_selectedSookshmam!['end'])}";
    } else if (_selectedAntharam != null) {
      dateRangeStr = "${_formatDateOnly(_selectedAntharam!['start'])}  -  ${_formatDateOnly(_selectedAntharam!['end'])}";
    } else if (_selectedBukthi != null) {
      dateRangeStr = "${_formatDateOnly(_selectedBukthi!['start'])}  -  ${_formatDateOnly(_selectedBukthi!['end'])}";
    } else if (_selectedDasa != null) {
      dateRangeStr = "${_formatDateOnly(_selectedDasa!['start'])}  -  ${_formatDateOnly(_selectedDasa!['end'])}";
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDasaTableWide(AppLocalizations.of(context)!.dasa, dasaList, _selectedDasa, (selected) {
                          setState(() {
                            _selectedDasa = selected;
                            _selectedBukthi = null;
                            _selectedAntharam = null;
                            _selectedSookshmam = null;
                            _selectedPranam = null;
                          });
                        }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDasaTableWide(AppLocalizations.of(context)!.bukthi, selectedBukthiList, _selectedBukthi, (selected) {
                          setState(() {
                            _selectedBukthi = selected;
                            _selectedAntharam = null;
                            _selectedSookshmam = null;
                            _selectedPranam = null;
                          });
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDasaTableWide(AppLocalizations.of(context)!.antharam, selectedAntharamList, _selectedAntharam, (selected) {
                          setState(() {
                            _selectedAntharam = selected;
                            _selectedSookshmam = null;
                            _selectedPranam = null;
                          });
                        }),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDasaTableWide(AppLocalizations.of(context)!.sookshmam, selectedSookshmamList, _selectedSookshmam, (selected) {
                          setState(() {
                            _selectedSookshmam = selected;
                            _selectedPranam = null;
                          });
                        }),
                      ),
                    ],
                  ),
                  if (selectedPranamList.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDasaTableWide(
                            AppLocalizations.of(context)!.localeName == 'en' ? 'Prana' : (AppLocalizations.of(context)!.localeName == 'hi' ? 'प्राण' : 'பிராணம்'),
                            selectedPranamList,
                            _selectedPranam,
                            (selected) {
                              setState(() {
                                _selectedPranam = selected;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.currentDasaBukthi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF5D1204))),
                  const Divider(color: Color(0xFFB58D3D)),
                  const SizedBox(height: 10),
                  Text(
                    currentSelectionStr.isEmpty ? AppLocalizations.of(context)!.noneSelected : currentSelectionStr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _calculateAge(activeDate),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFE65100)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dateRangeStr,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDasaTableWide(String title, List<dynamic> periods, Map<String, dynamic>? selectedItem, Function(Map<String, dynamic>) onSelect) {
    final l10n = AppLocalizations.of(context)!;
    if (periods.isEmpty) return const SizedBox();
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF5D1204),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          ),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            border: TableBorder.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 0.8),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Color(0xFFFAF6EE)),
                children: [
                  TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text(l10n.lord, textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 12)))),
                  TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text(l10n.start, textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 12)))),
                  TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text(l10n.end, textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 12)))),
                ],
              ),
              ...periods.map((p) {
                final bool isSelected = selectedItem == p;
                final bool isToday = DateTime.now().isAfter(p['start']) && DateTime.now().isBefore(p['end']);
                
                return TableRow(
                  children: [
                    _buildInteractiveCellWide(p['lord'] ?? "-", isPlanet: true, onTap: () => onSelect(p), isToday: isToday, isSelected: isSelected),
                    _buildInteractiveCellWide(_formatDateOnly(p['start']), onTap: () => onSelect(p), isToday: isToday, isSelected: isSelected),
                    _buildInteractiveCellWide(_formatDateOnly(p['end']), onTap: () => onSelect(p), isToday: isToday, isSelected: isSelected),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveCellWide(String text, {required VoidCallback onTap, bool isToday = false, bool isSelected = false, bool isPlanet = false}) {
    String translatedText = AstroTranslationService.translate(context, text, isPlanet: isPlanet);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: isToday 
              ? const Color(0xFFFFD54F).withOpacity(0.3) 
              : (isSelected ? const Color(0xFFE8F5E9) : Colors.white),
        ),
        child: Text(
          translatedText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isToday ? Colors.red.shade900 : const Color(0xFF5D1204),
            fontWeight: (isToday || isSelected) ? FontWeight.w900 : FontWeight.w500,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }



  Widget _buildAshtakavargaView() {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, dynamic>? av = widget.results['ashtakavarga'];
    if (av == null) return Center(child: Text(AppLocalizations.of(context)!.noDetails));

    final individual = (av['individual'] as Map? ?? {}).cast<String, dynamic>();
    final total = av['total'] as List? ?? List.filled(12, 0);
    final trikona = (av['trikona'] as Map? ?? {}).cast<String, dynamic>();
    final ekadipathya = (av['ekadipathya'] as Map? ?? {}).cast<String, dynamic>();
    final pindas = (av['pindas'] as Map? ?? {}).cast<String, dynamic>();
    
    final bool includeLagna = av['includeLagna'] == true && individual.containsKey('Lagna');
    final planets = includeLagna
        ? ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn", "Lagna"]
        : ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"];
    if (!planets.contains(_selectedBavPlanet)) {
      _selectedBavPlanet = "Sun";
    }
    final List<String> signShortNames = ["மேஷ", "ரிஷ", "மிது", "கட", "சிம்", "கன்", "துலா", "விரு", "தனு", "மக", "கும்", "மீன"];

    Map<String, List<String>> sarvaMap = {};
    for (int i = 0; i < 12; i++) {
        sarvaMap[KPService.SIGNS[i]] = [total[i].toString()];
    }

    final Map<String, List<String>> planetBavMap = {};
    final List<dynamic> selectedBavPoints = individual[_selectedBavPlanet] ?? List.filled(12, 0);
    for (int i = 0; i < 12; i++) {
        planetBavMap[KPService.SIGNS[i]] = [selectedBavPoints[i].toString()];
    }

    final Map<String, String> planetTamilNames = {
      "Sun": "சூரியன்", "Moon": "சந்திரன்", "Mars": "செவ்வாய்", "Mercury": "புதன்",
      "Jupiter": "குரு", "Venus": "சுக்கிரன்", "Saturn": "சனி", "Lagna": "லக்னம்"
    };

    final bool isWide = MediaQuery.of(context).size.width > 900;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildHeading(AppLocalizations.of(context)!.sarvaAshtakavarga),
                      SouthIndianChart(
                        rasiMap: sarvaMap,
                        centerLabel: AppLocalizations.of(context)!.sarvaAshtakavarga.replaceAll(' ', '\n'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    children: [
                      _buildHeading(AppLocalizations.of(context)!.suyaVargaChakra),
                      SouthIndianChart(
                        rasiMap: planetBavMap,
                        centerLabel: "${AstroTranslationService.translate(context, planetTamilNames[_selectedBavPlanet] ?? "", isPlanet: true)}\n${AppLocalizations.of(context)!.suyaAshtakavarga}",
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: planets.map((p) {
                          final bool isSelected = _selectedBavPlanet == p;
                          return ChoiceChip(
                            label: Text(AstroTranslationService.translate(context, planetTamilNames[p] ?? p, isPlanet: true)),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedBavPlanet = p);
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : const Color(0xFFB58D3D).withOpacity(0.4),
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF5D1204),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                SouthIndianChart(
                  rasiMap: sarvaMap,
                  centerLabel: AppLocalizations.of(context)!.sarvaAshtakavarga.replaceAll(' ', '\n'),
                ),
                const SizedBox(height: 32),
                _buildHeading(AppLocalizations.of(context)!.suyaVargaChakra),
                SouthIndianChart(
                  rasiMap: planetBavMap,
                  centerLabel: "${AstroTranslationService.translate(context, planetTamilNames[_selectedBavPlanet] ?? "", isPlanet: true)}\n${AppLocalizations.of(context)!.suyaAshtakavarga}",
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: planets.map((p) {
                    final bool isSelected = _selectedBavPlanet == p;
                    return ChoiceChip(
                      label: Text(AstroTranslationService.translate(context, planetTamilNames[p] ?? p, isPlanet: true)),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedBavPlanet = p);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected 
                              ? AppColors.primary 
                              : const Color(0xFFB58D3D).withOpacity(0.4),
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF5D1204),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

          
          const SizedBox(height: 32),
          _buildHeading(l10n.tabAshtakavarga),
          _buildPointsTable(planets, individual, signShortNames, footer: total),
          const SizedBox(height: 32),
          _buildHeading(l10n.thirigonaSothanai),
          _buildPointsTable(planets, trikona, signShortNames, showMoththam: true),
          const SizedBox(height: 32),
          _buildHeading(l10n.egathipathyaSothanai),
          _buildPointsTable(planets, ekadipathya, signShortNames, showMoththam: true),
          const SizedBox(height: 32),
          _buildHeading(l10n.pindangal),
          _buildPindasTable(planets, pindas),
          const SizedBox(height: 20),
        ],
      ),
    );

  }

  Widget _buildHeading(String title) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF5D1204), fontSize: 18),
      ),
    );
  }

  Widget _buildPointsTable(List<String> planets, Map<String, dynamic> data, List<String> signNames, {List? footer, bool showMoththam = false}) {
    final l10n = AppLocalizations.of(context)!;
    if (data.isEmpty) return const SizedBox();
    
    final Map<String, String> shortPlanetNames = {
      'Sun': 'சூரி', 'Moon': 'சந்', 'Mars': 'செவ்', 'Mercury': 'புத',
      'Jupiter': 'குரு', 'Venus': 'சுக்', 'Saturn': 'சனி', 'Lagna': 'லக்'
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(40),
          columnWidths: const {0: FixedColumnWidth(45), 13: FixedColumnWidth(60)},
          border: TableBorder.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 0.8),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF5D1204)),
              children: [
                _buildSmallTableHeader(l10n.planet),
                ...signNames.map((s) => _buildSmallTableHeader(s)).toList(),
                if (showMoththam) _buildSmallTableHeader(l10n.totalLabel),
              ],
            ),
            ...planets.map((p) {
              final List<dynamic> pPoints = data[p] ?? List.filled(12, 0);
              int rowSum = 0; for (var v in pPoints) rowSum += (v as int? ?? 0);
              return TableRow(
                children: [
                  _buildSmallTableCell(shortPlanetNames[p] ?? p, isPlanet: true),
                  ...pPoints.map((pt) => _buildSmallTableCell(pt.toString())).toList(),
                  if (showMoththam) _buildSmallTableCell(rowSum.toString(), isBold: true, customColor: const Color(0xFFE65100)),
                ],
              );
            }).toList(),
            if (footer != null)
              TableRow(
                children: [
                   _buildSmallTableCell("", isPlanet: true),
                   ...footer.map((val) => _buildSmallTableCell(val.toString(), isBold: true, customColor: const Color(0xFFE65100))).toList(),
                   if (showMoththam) _buildSmallTableCell("", isBold: true),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPindasTable(List<String> planets, Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    if (data.isEmpty) return const SizedBox();
    final Map<String, String> shortPlanetNames = {
      'Sun': 'சூரி', 'Moon': 'சந்', 'Mars': 'செவ்', 'Mercury': 'புத',
      'Jupiter': 'குரு', 'Venus': 'சுக்', 'Saturn': 'சனி', 'Lagna': 'லக்'
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        border: TableBorder.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 0.8),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Color(0xFF5D1204)),
            children: [
              TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Text(l10n.planet, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))),
              TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Text(l10n.rasiPindam, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))),
              TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Text(l10n.grahaPindam, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))),
              TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Text(l10n.shodyaPindam, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))),
            ],
          ),
          ...planets.map((p) {
            final Map<String, dynamic> pPinda = (data[p] as Map? ?? {}).cast<String, dynamic>();
            return TableRow(
              children: [
                _buildSmallTableCell(shortPlanetNames[p] ?? p, isPlanet: true),
                _buildSmallTableCell(pPinda['rasi']?.toString() ?? "0"),
                _buildSmallTableCell(pPinda['graha']?.toString() ?? "0"),
                _buildSmallTableCell(pPinda['total']?.toString() ?? "0", isBold: true, customColor: const Color(0xFF5D1204)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSmallTableHeader(String text) {
    String translatedText = AstroTranslationService.translate(context, text, isPlanet: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Text(
        translatedText,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildSmallTableCell(String text, {bool isPlanet = false, bool isBold = false, Color? customColor}) {
    String translatedText = AstroTranslationService.translate(context, text, isPlanet: isPlanet);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Text(
        translatedText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: customColor ?? (isPlanet ? Colors.red.shade700 : (isBold ? Colors.black : Colors.black87)),
          fontWeight: (isPlanet || isBold) ? FontWeight.bold : FontWeight.w500,
          fontSize: 11.5,
        ),
      ),
    );
  }



  Widget _buildDasavarkkamView() {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, dynamic>? vargas = widget.results['divisional_charts'];
    if (vargas == null) return const Center(child: Text('தசவர்க்கம் விவரங்கள் இல்லை'));

    final bool isWide = MediaQuery.of(context).size.width > 900;
    final List<String> vargaNames = vargas.keys.toList();

    return Column(
      children: [
        if (isWide)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                ChoiceChip(
                  label: Text(AstroTranslationService.translate(context, 'அனைத்தும் (Show All)')),
                  selected: _selectedVargam == 'அனைத்தும்',
                  onSelected: (val) {
                    if (val) setState(() => _selectedVargam = 'அனைத்தும்');
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedVargam == 'அனைத்தும்'
                          ? AppColors.primary 
                          : const Color(0xFFB58D3D).withOpacity(0.4),
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: _selectedVargam == 'அனைத்தும்' ? Colors.white : const Color(0xFF5D1204),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...vargaNames.map((name) {
                  final shortMatch = RegExp(r'\((D\d+)\)').firstMatch(name);
                  final shortName = shortMatch != null ? shortMatch.group(1)! : name;
                  final bool isSelected = _selectedVargam == name;
                  return ChoiceChip(
                    label: Text(shortName),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedVargam = name);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected 
                            ? AppColors.primary 
                            : const Color(0xFFB58D3D).withOpacity(0.4),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF5D1204),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vargaNames.length,
            itemBuilder: (context, index) {
              final name = vargaNames[index];
              if (isWide && _selectedVargam != 'அனைத்தும்' && _selectedVargam != name) {
                return const SizedBox.shrink();
              }
              final chartData = vargas[name];
              return Column(
                children: [
                  SouthIndianChart(
                    rasiMap: _castChartMap(chartData),
                    centerLabel: name,
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Map<String, List<String>> _castChartMap(dynamic data) {
    if (data == null || data is! Map) return {};
    return data.map((key, value) {
      if (value is List) {
        return MapEntry(key.toString(), List<String>.from(value.map((e) => e.toString())));
      }
      return MapEntry(key.toString(), <String>[]);
    });
  }

  Widget _buildShadbalaView() {
    final shadbala = widget.results['shadbala'] as Map<String, dynamic>?;
    if (shadbala == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('ஷட்பலம் விவரங்கள் கணக்கிடப்படவில்லை', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    final summaryList = (shadbala['summary_list'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final topPlanet = shadbala['top_planet'] as Map<String, dynamic>?;
    final sthanaMap = shadbala['sthana_bala_details'] as Map<String, dynamic>? ?? {};
    final kaalaMap = shadbala['kaala_bala_details'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top Strongest Planet Banner ──────────────────────────────────
          if (topPlanet != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5D1204), Color(0xFF8B1E0F), Color(0xFFB58D3D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5D1204).withOpacity(0.25),
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
                      color: const Color(0xFFFFD54F),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF5D1204), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "அதிக ஷட்பலம் பெற்ற கிரகம் (Rank #1)",
                          style: TextStyle(color: Colors.amber.shade200, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${topPlanet['planet_tamil']} (${(topPlanet['total_rupas'] as double).toStringAsFixed(2)} ரூபங்கள் - ${((topPlanet['ratio'] as double) * 100).toStringAsFixed(0)}%)",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          "தேவை: ${(topPlanet['required_rupas'] as double).toStringAsFixed(1)} ரூபம் | நிலை: ${topPlanet['status']}",
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Planetary Strength Summary & Ranking ──────────────────────────
          _buildDetailCard("கிரகங்களின் ஷட்பல தரவரிசை & விகிதம்", [
            ...summaryList.map((p) {
              final rank = p['rank'] ?? 0;
              final rupa = (p['total_rupas'] as double?) ?? 0.0;
              final reqRupa = (p['required_rupas'] as double?) ?? 5.5;
              final ratio = (p['ratio'] as double?) ?? 1.0;
              final percent = (ratio * 100).clamp(0.0, 200.0);
              final isStrong = ratio >= 1.0;

              Color badgeColor;
              if (rank == 1) badgeColor = const Color(0xFFFFD700); // Gold
              else if (rank == 2) badgeColor = const Color(0xFFC0C0C0); // Silver
              else if (rank == 3) badgeColor = const Color(0xFFCD7F32); // Bronze
              else badgeColor = const Color(0xFFB58D3D).withOpacity(0.3);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isStrong ? const Color(0xFFB58D3D).withOpacity(0.3) : Colors.red.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: badgeColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "$rank",
                            style: TextStyle(
                              color: rank <= 3 ? const Color(0xFF5D1204) : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['planet_tamil'] ?? p['planet'],
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF5D1204)),
                              ),
                              Text(
                                "தேவை: ${reqRupa.toStringAsFixed(1)} ரூபம் | பெற்றது: ${rupa.toStringAsFixed(2)} ரூபம் (${(p['total_virupas'] as double).toStringAsFixed(1)} விரூபங்கள்)",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isStrong ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isStrong ? Colors.green.shade300 : Colors.red.shade300),
                          ),
                          child: Text(
                            "${(ratio).toStringAsFixed(2)}x",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: isStrong ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (percent / 150.0).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isStrong ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ]),
          const SizedBox(height: 20),

          // ── 6-Fold Detailed Balas Table (In Virupas) ───────────────────────
          _buildDetailCard("6 வகை பலங்கள் விரிவான அட்டவணை (விரூபங்களில்)", [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF5D1204).withOpacity(0.08)),
                columnSpacing: 14,
                horizontalMargin: 8,
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204)),
                dataTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
                columns: const [
                  DataColumn(label: Text("கிரகம்")),
                  DataColumn(label: Text("ஸ்தான")),
                  DataColumn(label: Text("திக்பலம்")),
                  DataColumn(label: Text("கால")),
                  DataColumn(label: Text("சேஷ்டா")),
                  DataColumn(label: Text("நைசர்கிக")),
                  DataColumn(label: Text("த்ரிக்")),
                  DataColumn(label: Text("மொத்தம் (Virupas)")),
                  DataColumn(label: Text("ரூபங்கள் (Rupas)")),
                ],
                rows: summaryList.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(Text(p['planet_tamil'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204)))),
                      DataCell(Text((p['sthana_bala'] as double).toStringAsFixed(1))),
                      DataCell(Text((p['dig_bala'] as double).toStringAsFixed(1))),
                      DataCell(Text((p['kaala_bala'] as double).toStringAsFixed(1))),
                      DataCell(Text((p['cheshta_bala'] as double).toStringAsFixed(1))),
                      DataCell(Text((p['naisargika_bala'] as double).toStringAsFixed(1))),
                      DataCell(Text((p['drik_bala'] as double).toStringAsFixed(1))),
                      DataCell(Text((p['total_virupas'] as double).toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text((p['total_rupas'] as double).toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204)))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Sthana Bala Sub-Breakdown ───────────────────────────────────────
          _buildDetailCard("1. ஸ்தான பல உட்பிரிவுகள் (Sthana Bala Sub-Components)", [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFB58D3D).withOpacity(0.12)),
                columnSpacing: 14,
                horizontalMargin: 8,
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204)),
                dataTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
                columns: const [
                  DataColumn(label: Text("கிரகம்")),
                  DataColumn(label: Text("உச்சா பலம்")),
                  DataColumn(label: Text("சப்தவர்க்கஜ")),
                  DataColumn(label: Text("ஓஜ-யுக்ம")),
                  DataColumn(label: Text("கேந்திராதி")),
                  DataColumn(label: Text("த்ரேக்காண")),
                  DataColumn(label: Text("மொத்த ஸ்தான பலம்")),
                ],
                rows: summaryList.map((p) {
                  final s = sthanaMap[p['planet']] ?? {};
                  return DataRow(
                    cells: [
                      DataCell(Text(p['planet_tamil'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204)))),
                      DataCell(Text(((s['uchha_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((s['saptavargaja_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((s['ojhayugma_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((s['kendradi_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((s['drekkana_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((s['total'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204)))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Kaala Bala Sub-Breakdown ─────────────────────────────────────────
          _buildDetailCard("2. கால பல உட்பிரிவுகள் (Kaala Bala Sub-Components)", [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFB58D3D).withOpacity(0.12)),
                columnSpacing: 14,
                horizontalMargin: 8,
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204)),
                dataTextStyle: const TextStyle(fontSize: 12, color: Colors.black87),
                columns: const [
                  DataColumn(label: Text("கிரகம்")),
                  DataColumn(label: Text("நதோன்னத (பகல்/இரவு)")),
                  DataColumn(label: Text("பக்ஷ பலம்")),
                  DataColumn(label: Text("த்ரிபாக")),
                  DataColumn(label: Text("அயன பலம்")),
                  DataColumn(label: Text("மொத்த கால பலம்")),
                ],
                rows: summaryList.map((p) {
                  final k = kaalaMap[p['planet']] ?? {};
                  return DataRow(
                    cells: [
                      DataCell(Text(p['planet_tamil'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204)))),
                      DataCell(Text(((k['nathonnatha_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((k['paksha_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((k['tribhaga_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((k['ayana_bala'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1))),
                      DataCell(Text(((k['total'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204)))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Information & Rules Card ───────────────────────────────────────
          _buildDetailCard("ஷட்பலம் பற்றிய ஜோதிடக் குறிப்புகள்", [
            _buildDetailRow("கணித அளவு", "1 ரூபம் (Rupa) = 60 விரூபங்கள் (Virupas)"),
            _buildDetailRow("குறைந்தபட்ச தேவை", "புதன்: 7.0 | சூரியன், குரு: 6.5 | சந்திரன்: 6.0 | சுக்கிரன்: 5.5 | செவ்வாய், சனி: 5.0 ரூபங்கள்"),
            _buildDetailRow("பலன் நிர்ணயம்", "1.0-க்கு மேல் விகிதம் பெற்ற கிரகங்களின் தசா-புக்திகள் நற்பலன்களையும் காரகத்துவ உயர்வுகளையும் தரும்."),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWideVivaramView() {final l10n = AppLocalizations.of(context)!;
    final pancha = widget.results['panchangam'] ?? {};
    final matching = widget.results['matching_attrs'] ?? {};
    final basics = widget.results['planet_details'] ?? {};
    final era = widget.results['era'] ?? {};

    String nakshatraName = basics['moon']?['nakshatra'] ?? '-';
    String namaEzhuthu = "";
    try {
      final nakData = NakshatraData.nakshatraDetails.firstWhere(
        (element) => element['nakshatram'] == nakshatraName,
        orElse: () => {"nama_ezhuthu": ""},
      );
      if (nakData['nama_ezhuthu']!.isNotEmpty) {
         namaEzhuthu = nakData['nama_ezhuthu']!.replaceAll('-', ', ');
      }
    } catch (_) {}

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDetailRow(l10n.nameLabel, widget.results['name'] ?? widget.name, isPrimary: true),
                      _buildDetailRow(l10n.genderLabel, widget.results['gender'] ?? "-"),
                      if (widget.results['birth_dt'] != null) ...[
                        _buildDetailRow(l10n.dateLabel, "${widget.results['birth_dt'].day}/${widget.results['birth_dt'].month}/${widget.results['birth_dt'].year}"),
                        _buildDetailRow(l10n.timeLabel, widget.results['tob'] ?? "-"),
                        _buildDetailRow(l10n.ageLabel, _calculateFullAge(widget.results['birth_dt'])),
                      ],
                      _buildDetailRow(l10n.placeOfBirthLabel, AstroTranslationService.cleanLocation(context, widget.results['place'] ?? "-")),
                      const Divider(color: Color(0xFFB58D3D), height: 32),
                      _buildDetailRow(l10n.nakshatraLabel, "$nakshatraName (${basics['moon']?['pada'] ?? '-'} பாதம்)", isPrimary: true),
                      if (namaEzhuthu.isNotEmpty) _buildDetailRow("நட்சத்திர நாம எழுத்து", namaEzhuthu),
                      _buildDetailRow(l10n.rasiLabel, "${KPService.TAMIL_SIGNS[basics['moon']?['rasi']] ?? basics['moon']?['rasi'] ?? '-'} (${KPService.TAMIL_PLANETS[basics['moon']?['lords']?['signLord']] ?? basics['moon']?['lords']?['signLord'] ?? '-'})"),
                      _buildDetailRow(l10n.atmakarakaLabel, KPService.TAMIL_PLANETS[widget.results['atmakaraka']] ?? widget.results['atmakaraka'] ?? "-", isPlanet: true),
                      if (widget.results['chandrashtama'] != null) ...[
                        _buildDetailRow("சந்திராஷ்டம ராசி", widget.results['chandrashtama']['rasi_tamil'] ?? "-"),
                        _buildDetailRow("சந்திராஷ்டம நட்சத்திரம்", widget.results['chandrashtama']['direct_text'] ?? "-"),
                      ],
                      const Divider(color: Color(0xFFB58D3D), height: 32),
                      _buildDetailRow(l10n.ganam, matching['ganam'] ?? "-"),
                      _buildDetailRow(l10n.mirugam, matching['mirugam'] ?? "-"),
                      _buildDetailRow(l10n.pakshi, matching['pakshi'] ?? "-"),
                      _buildDetailRow(l10n.maram, matching['maram'] ?? "-"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSpecialLagnasCard(),
                const SizedBox(height: 20),
                _buildYogiAvayogiCard(),
                const SizedBox(height: 20),
                _buildAvasthasAndParivarthanaCard(),
                const SizedBox(height: 20),
                _buildUpagrahasCard(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDetailRow(l10n.tamilYearLabel, pancha['tamil_year'] ?? "-"),
                      _buildDetailRow(l10n.tamilDateLabel, "${pancha['tamil_month'] ?? "-"} ${pancha['tamil_date'] ?? "-"}"),
                      _buildDetailRow(l10n.varaLabel, pancha['vara'] ?? "-"),
                      _buildDetailRow(l10n.tithiLabel, pancha['tithi'] ?? "-"),
                      _buildDetailRow(l10n.yogaLabel, pancha['yoga'] ?? "-"),
                      _buildDetailRow(l10n.karanaLabel, pancha['karana']?.toString() ?? "-"),
                      _buildDetailRow(l10n.kaliYearLabel, era['kali']?.toString() ?? "-"),
                      const Divider(color: Color(0xFFB58D3D), height: 32),
                      _buildDetailRow(l10n.sunriseLabel, pancha['sunrise'] ?? "-"),
                      _buildDetailRow(l10n.sunsetLabel, pancha['sunset'] ?? "-"),
                      _buildDetailRow(l10n.paramaNazhigaiLabel, widget.results['nazhigai'] ?? "-"),
                      _buildDetailRow(l10n.horaLabel, widget.results['hora'] ?? "-"),
                      _buildDetailRow(l10n.amirthaYogaLabel, widget.results['special_yoga'] ?? "-"),
                      _buildDetailRow(l10n.dasaBalanceLabel, _calculateBirthDasaBalance()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildJaiminiKarakasCard(),
                if (widget.results['kala_pagai']?['warnings'] != null && (widget.results['kala_pagai']['warnings'] as List).isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildKalaPagaiCard(),
                ],
                const SizedBox(height: 20),
                _buildKalaNatpuPagaiAgeCard(),
                const SizedBox(height: 20),
                _buildSpecialStarsAndTharaisCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVivaramView() {
    final l10n = AppLocalizations.of(context)!;
    final bool isWide = MediaQuery.of(context).size.width > 900;
    if (isWide) return _buildWideVivaramView();

    final pancha = widget.results['panchangam'] ?? {};
    final matching = widget.results['matching_attrs'] ?? {};
    final basics = widget.results['planet_details'] ?? {};
    final lBenefics = widget.results['functional_planets']?['benefics'] as List? ?? [];
    final lMalefics = widget.results['functional_planets']?['malefics'] as List? ?? [];
    final lMarakas = widget.results['functional_planets']?['marakas'] as List? ?? [];
    final era = widget.results['era'] ?? {};

    String nakshatraName = basics['moon']?['nakshatra'] ?? '-';
    String namaEzhuthu = "";
    try {
      final nakData = NakshatraData.nakshatraDetails.firstWhere(
        (element) => element['nakshatram'] == nakshatraName,
        orElse: () => {"nama_ezhuthu": ""},
      );
      if (nakData['nama_ezhuthu']!.isNotEmpty) {
         namaEzhuthu = nakData['nama_ezhuthu']!.replaceAll('-', ', ');
      }
    } catch (_) {}

    final List<Widget> cards = [
      _buildDetailCard(l10n.birthDetailsTitle, [
        _buildDetailRow(l10n.nameLabel, widget.results['name'] ?? widget.name, isPrimary: true),
        _buildDetailRow(l10n.genderLabel, widget.results['gender'] ?? "-"),
        if (widget.results['birth_dt'] != null) ...[
          _buildDetailRow(l10n.dateLabel, "${widget.results['birth_dt'].day}/${widget.results['birth_dt'].month}/${widget.results['birth_dt'].year}"),
          _buildDetailRow(l10n.timeLabel, widget.results['tob'] ?? "-"),
          _buildDetailRow(l10n.ageLabel, _calculateFullAge(widget.results['birth_dt'])),
        ],
        _buildDetailRow(l10n.placeOfBirthLabel, AstroTranslationService.cleanLocation(context, widget.results['place'] ?? "-")),
      ]),
      _buildDetailCard(l10n.panchangamTitle, [
        _buildDetailRow(l10n.tamilYearLabel, pancha['tamil_year'] ?? "-"),
        _buildDetailRow(l10n.tamilDateLabel, "${pancha['tamil_month'] ?? "-"} ${pancha['tamil_date'] ?? "-"}"),
        _buildDetailRow(l10n.varaLabel, pancha['vara'] ?? "-"),
        _buildDetailRow(l10n.tithiLabel, pancha['tithi'] ?? "-"),
        _buildDetailRow(l10n.kaliYearLabel, era['kali']?.toString() ?? "-"),
        _buildDetailRow(l10n.kollamYearLabel, era['kollam']?.toString() ?? "-"),
      ]),
      _buildDetailCard(l10n.astroBasicsTitle, [
        _buildDetailRow(l10n.nakshatraLabel, "$nakshatraName (${basics['moon']?['pada'] ?? '-'} பாதம்)", isPrimary: true),
        _buildDetailRow(l10n.rasiLabel, "${KPService.TAMIL_SIGNS[basics['moon']?['rasi']] ?? basics['moon']?['rasi'] ?? '-'} (${KPService.TAMIL_PLANETS[basics['moon']?['lords']?['signLord']] ?? basics['moon']?['lords']?['signLord'] ?? '-'})"),
        _buildDetailRow(l10n.lagnaLabel, "${KPService.TAMIL_SIGNS[basics['lagna']?['rasi']] ?? basics['lagna']?['rasi'] ?? '-'} (${KPService.TAMIL_PLANETS[basics['lagna']?['lords']?['signLord']] ?? basics['lagna']?['lords']?['signLord'] ?? '-'})"),
        _buildDetailRow(l10n.atmakarakaLabel, KPService.TAMIL_PLANETS[widget.results['atmakaraka']] ?? widget.results['atmakaraka'] ?? "-", isPlanet: true),
        if (widget.results['chandrashtama'] != null) ...[
          _buildDetailRow("சந்திராஷ்டம ராசி", widget.results['chandrashtama']['rasi_tamil'] ?? "-"),
          _buildDetailRow("சந்திராஷ்டம நட்சத்திரம்", widget.results['chandrashtama']['direct_text'] ?? "-"),
        ],
      ]),
      _buildDetailCard(l10n.matchingAttrsTitle, [
        _buildDetailRow(l10n.mirugam, matching['mirugam'] ?? "-"),
        _buildDetailRow(l10n.pakshi, matching['pakshi'] ?? "-"),
        _buildDetailRow(l10n.ganam, matching['ganam'] ?? "-"),
        _buildDetailRow("யோனி", matching['yoni'] ?? "-"),
        _buildDetailRow(l10n.maram, matching['maram'] ?? "-"),
        _buildDetailRow("ரஜ்ஜு", matching['rajju'] ?? "-"),
        _buildDetailRow("நாடி", matching['naadi'] ?? "-"),
      ]),
      _buildDetailCard("சுப/அசுப கிரகங்கள்", [
        _buildDetailRow("லக்ன சுபர்கள்", lBenefics.map((p) => KPService.TAMIL_PLANETS[p] ?? p).join(", "), isPlanet: true),
        _buildDetailRow("லக்ன பாபர்கள்", lMalefics.map((p) => KPService.TAMIL_PLANETS[p] ?? p).join(", "), isPlanet: true),
        _buildDetailRow("லக்ன மாரகர்", lMarakas.map((p) => KPService.TAMIL_PLANETS[p] ?? p).join(", "), isPlanet: true),
      ]),
      _buildDetailCard("நேரம் & யோகங்கள்", [
        _buildDetailRow(l10n.sunriseLabel, pancha['sunrise'] ?? "-"),
        _buildDetailRow(l10n.sunsetLabel, pancha['sunset'] ?? "-"),
        _buildDetailRow("ஆதியந்த பரம நாழிகை", widget.results['nazhigai'] ?? "-"),
        _buildDetailRow(l10n.horaLabel, widget.results['hora'] ?? "-"),
        _buildDetailRow(l10n.yogaLabel, pancha['yoga'] ?? "-"),
        _buildDetailRow(l10n.amirthaYogaLabel, widget.results['special_yoga'] ?? "-"),
        _buildDetailRow(l10n.karanaLabel, pancha['karana']?.toString() ?? "-"),
        _buildDetailRow("பிறக்கும் போது தசா இருப்பு", _calculateBirthDasaBalance()),
      ]),
      _buildSpecialLagnasCard(),
      _buildJaiminiKarakasCard(),
      _buildYogiAvayogiCard(),
      if (widget.results['kala_pagai']?['warnings'] != null && (widget.results['kala_pagai']['warnings'] as List).isNotEmpty)
        _buildKalaPagaiCard(),
      _buildKalaNatpuPagaiAgeCard(),
      _buildAvasthasAndParivarthanaCard(),
      _buildSpecialStarsAndTharaisCard(),
      _buildUpagrahasCard(),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...cards.expand((c) => [c, const SizedBox(height: 20)]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLagnaChangeBanner() {
    final lc = widget.results['lagna_change'] as Map<String, dynamic>?;
    if (lc == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFA000), width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_filled_rounded, color: Color(0xFFE65100), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              lc['formatted_text'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF5D1204)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialLagnasCard() {
    final indu = widget.results['indu_lagna'] as Map<String, dynamic>?;
    final fortuna = widget.results['fortuna_detailed'] as Map<String, dynamic>?;
    final jLagnas = widget.results['jaimini_lagnas'] as Map<String, dynamic>?;

    return _buildDetailCard("சிறப்பு லக்னங்கள் & புள்ளிகள்", [
      if (indu != null)
        _buildDetailRow("இந்து லக்னம் (Indu Lagna)", "${indu['rasi_tamil']} (${indu['formatted']}) - ${indu['total_rays']} கதிர்கள்", isPrimary: true),
      if (fortuna != null)
        _buildDetailRow("பார்ச்சூனா புள்ளி (Fortuna)", "${fortuna['rasi_tamil']} (${fortuna['formatted']})"),
      if (jLagnas != null) ...[
        if (jLagnas['arudha_lagna'] != null)
          _buildDetailRow("பதா / ஆருட லக்னம் (AL)", "${jLagnas['arudha_lagna']['rasi_tamil']} (${jLagnas['arudha_lagna']['formatted']})"),
        if (jLagnas['upapada_lagna'] != null)
          _buildDetailRow("உபபதா லக்னம் (UL)", "${jLagnas['upapada_lagna']['rasi_tamil']} (${jLagnas['upapada_lagna']['formatted']})"),
        if (jLagnas['hora_lagna'] != null)
          _buildDetailRow("ஹோரா லக்னம் (HL)", "${jLagnas['hora_lagna']['rasi_tamil']} (${jLagnas['hora_lagna']['formatted']})"),
        if (jLagnas['ghatika_lagna'] != null)
          _buildDetailRow("கடிகா லக்னம் (GL)", "${jLagnas['ghatika_lagna']['rasi_tamil']} (${jLagnas['ghatika_lagna']['formatted']})"),
      ],
    ]);
  }

  Widget _buildJaiminiKarakasCard() {
    final karakasData = widget.results['jaimini_karakas']?['karakas'] as Map<String, dynamic>?;
    if (karakasData == null) return const SizedBox();

    return _buildDetailCard("ஜெமினி 7 காரகங்கள் (Jaimini Karakas)", karakasData.entries.map((e) {
      final info = e.value as Map<String, dynamic>;
      return _buildDetailRow("${e.key} - ${info['description']}", "${info['planet_tamil']} (${info['degree']})", isPlanet: true);
    }).toList());
  }

  Widget _buildYogiAvayogiCard() {
    final yogiData = widget.results['yogi_avayogi'] as Map<String, dynamic>?;
    final roles = widget.results['planetary_roles'] as Map<String, dynamic>?;

    return _buildDetailCard("யோகி / அவயோகி & பாதக அமைப்புகள்", [
      if (yogiData != null) ...[
        _buildDetailRow("யோகி கிரகம் / நட்சத்திரம்", "${yogiData['yogi']['planet_tamil']} - ${yogiData['yogi']['nakshatra_tamil']} (${yogiData['yogi']['rasi_tamil']})", isPrimary: true),
        _buildDetailRow("அவயோகி கிரகம் / நட்சத்திரம்", "${yogiData['avayogi']['planet_tamil']} - ${yogiData['avayogi']['nakshatra_tamil']} (${yogiData['avayogi']['rasi_tamil']})"),
        _buildDetailRow("துணை யோகி (பகர்ப்பு யோகி)", yogiData['upayogi']['planet_tamil'] ?? '-', isPlanet: true),
        _buildDetailRow("முடக்கு ராசி & நாதன்", "${yogiData['mudakku']['rasi_tamil']} (${yogiData['mudakku']['lord_tamil']})"),
      ],
      if (roles != null) ...[
        if (roles['badhaka'] != null)
          _buildDetailRow("பாதகாதிபதி (${roles['badhaka']['house']}-ஆம் வீடு)", "${roles['badhaka']['rasi_tamil']} (${roles['badhaka']['lord_tamil']})"),
        if (roles['tharaka'] != null && roles['tharaka']['lords_tamil'] != null)
          _buildDetailRow("தாரக கிரகங்கள் (5, 9 திரிகோண அதிபதிகள்)", (roles['tharaka']['lords_tamil'] as List).join(', '), isPlanet: true),
      ],
    ]);
  }

  Widget _buildKalaPagaiCard() {
    final warnings = widget.results['kala_pagai']?['warnings'] as List? ?? [];
    if (warnings.isEmpty) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Colors.red.shade900,
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "காலப்பகை தசா - புத்தி எச்சரிக்கைகள்",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFFFF3E0),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: warnings.map((w) {
                String dTamil = w['dasa_tamil'] ?? (KPService.TAMIL_PLANETS[w['dasa']] ?? w['dasa'] ?? '');
                String bTamil = w['bhukthi_tamil'] ?? (KPService.TAMIL_PLANETS[w['bhukthi']] ?? w['bhukthi'] ?? '');
                bool isCur = w['is_current'] == true;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right_rounded, color: isCur ? Colors.red.shade900 : Colors.deepOrange, size: 20),
                      Expanded(
                        child: Text(
                          "$dTamil தசை - $bTamil புத்தி (${w['age_range']}): $dTamil தசையில் $bTamil புத்தி காலப்பகை அமைப்பாகும்.${isCur ? ' (தற்போது நடக்கிறது)' : ''}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCur ? FontWeight.w900 : FontWeight.w600,
                            color: isCur ? Colors.red.shade900 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKalaNatpuPagaiAgeCard() {
    final ageData = widget.results['kala_natpu_pagai_age'] as Map<String, dynamic>?;
    if (ageData == null) return const SizedBox();

    final currentStatus = ageData['current_status'] as Map<String, dynamic>?;
    final List natpuRules = ageData['natpu_rules'] as List? ?? [];
    final List pagaiRules = ageData['pagai_rules'] as List? ?? [];

    Color bannerColor = const Color(0xFFF5F5F5);
    Color bannerBorder = Colors.grey.shade400;
    Color bannerTextColor = Colors.black87;
    IconData bannerIcon = Icons.info_outline_rounded;
    String statusTitle = "தற்போது சம நிலை தசை நடைபெறுகிறது";

    if (currentStatus != null) {
      if (currentStatus['status_type'] == 'natpu') {
        bannerColor = const Color(0xFFE8F5E9);
        bannerBorder = const Color(0xFF4CAF50);
        bannerTextColor = const Color(0xFF1B5E20);
        bannerIcon = Icons.check_circle_outline_rounded;
        statusTitle = "தற்போது காலநட்பு (நன்மை தரும்) பருவம்: ${currentStatus['dasa_tamil']} தசை (${currentStatus['age_range']})";
      } else if (currentStatus['status_type'] == 'pagai') {
        bannerColor = const Color(0xFFFFEBEE);
        bannerBorder = const Color(0xFFE53935);
        bannerTextColor = const Color(0xFFB71C1C);
        bannerIcon = Icons.warning_amber_rounded;
        statusTitle = "தற்போது காலப்பகை (சவால் தரும்) பருவம்: ${currentStatus['dasa_tamil']} தசை (${currentStatus['age_range']})";
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(color: Color(0xFF5D1204)),
            child: const Text(
              "காலநட்பு & காலப்பகை பருவங்கள் (Age & Dasa Matrix)",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (currentStatus != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: bannerColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: bannerBorder, width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(bannerIcon, color: bannerTextColor, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statusTitle,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: bannerTextColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                // காலநட்பு Section
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF81C784).withOpacity(0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.star_rounded, color: Color(0xFF2E7D32), size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "காலநட்பு வயது & திசை (நன்மை பயக்கும் காலம்)",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14, color: Color(0xFF81C784)),
                      ...natpuRules.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Text.rich(
                          TextSpan(
                            text: "• ${r['label']}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF2E7D32)),
                            children: [
                              TextSpan(
                                text: "${r['lord_tamil']} திசை",
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // காலப்பகை Section
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_rounded, color: Color(0xFFE65100), size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "காலப்பகை வயது & திசை (சவால்கள் தரும் காலம்)",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFBF360C)),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 14, color: Color(0xFFFFB74D)),
                      ...pagaiRules.map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Text.rich(
                          TextSpan(
                            text: "• ${r['label']}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFFD84315)),
                            children: [
                              TextSpan(
                                text: "${r['lord_tamil']} திசை",
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      )),
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

  Widget _buildAvasthasAndParivarthanaCard() {
    final avasthas = widget.results['planetary_avasthas'] as Map<String, dynamic>? ?? {};
    final parivarthana = widget.results['parivarthana'] as Map<String, dynamic>?;

    List<Widget> rows = [];
    avasthas.forEach((planet, info) {
      if (info['status'] != "சமம்" || info['has_digbala'] == true) {
        String pTamil = KPService.TAMIL_PLANETS[planet] ?? planet;
        String statusDisplay = info['status'];
        if (info['has_digbala'] == true) {
          statusDisplay = statusDisplay == "சமம்" ? "திக்பலம்" : "$statusDisplay (திக்பலம்)";
        }
        rows.add(_buildDetailRow("$pTamil நிலை", statusDisplay, isPlanet: true));
      }
    });

    if (parivarthana != null && parivarthana['has_parivarthana'] == true) {
      final rasiP = parivarthana['rasi_parivarthana'] as List? ?? [];
      for (var rp in rasiP) {
        rows.add(_buildDetailRow("ராசி பரிவர்த்தனை", "${rp['planet1_tamil']} ⟷ ${rp['planet2_tamil']} (${rp['rasi1_tamil']} - ${rp['rasi2_tamil']})", isPrimary: true));
      }
      final nakP = parivarthana['nak_parivarthana'] as List? ?? [];
      for (var np in nakP) {
        rows.add(_buildDetailRow("நட்சத்திர பரிவர்த்தனை", "${np['planet1_tamil']} ⟷ ${np['planet2_tamil']} (${np['nak1_tamil']} - ${np['nak2_tamil']})"));
      }
    } else {
      rows.add(_buildDetailRow("பரிவர்த்தனை", "இல்லை"));
    }

    if (rows.isEmpty) {
      rows.add(const Text("குறிப்பிடத்தக்க பரிவர்த்தனை அல்லது உச்ச/நீச அமைப்புகள் இல்லை"));
    }

    return _buildDetailCard("கிரக நிலைகள் & பரிவர்த்தனை யோகங்கள்", rows);
  }

  Widget _buildSpecialStarsAndTharaisCard() {
    final karma = widget.results['karma_nakshatras'] as Map<String, dynamic>?;
    final pushkara = widget.results['pushkara_navamsa'] as Map<String, dynamic>?;
    final navatara = widget.results['navatara'] as Map<String, dynamic>?;
    final vainasika = widget.results['vainasika_pada'] as Map<String, dynamic>?;

    List<Widget> rows = [];

    // Vainasika 88th Pada
    if (vainasika != null) {
      rows.add(_buildDetailRow(
        "வைநாசிக தோஷ பாதம் (88-வது பாதம்)",
        "${vainasika['description']} (${vainasika['vainasika_nak_lord_tamil']})",
        isPrimary: true,
      ));
      if (vainasika['has_affliction'] == true) {
        final affList = (vainasika['afflicted_planets'] as List).map((p) => p['planet_tamil']).join(', ');
        rows.add(_buildDetailRow("வைநாசிக பாதத்தில் உள்ள கிரகம்", affList));
      } else {
        rows.add(_buildDetailRow("வைநாசிக பாதத்தில் உள்ள கிரகம்", "கிரகங்கள் இல்லை (சுபம்)"));
      }
    }

    // Pushkara
    bool hasPushkara = false;
    if (pushkara != null) {
      pushkara.forEach((name, info) {
        if (info['is_pushkara'] == true) {
          hasPushkara = true;
          String nTamil = name == 'Lagna' ? 'லக்னம்' : (KPService.TAMIL_PLANETS[name] ?? name);
          rows.add(_buildDetailRow("$nTamil புஷ்கர நிலை", info['status_text'] ?? '', isPrimary: true));
        }
      });
    }
    if (!hasPushkara) {
      rows.add(_buildDetailRow("புஷ்கர நவாம்சம்", "இல்லை"));
    }

    // 3, 5, 7 Tharais warnings
    if (navatara != null) {
      final pTharais = navatara['planet_tharais'] as Map<String, dynamic>? ?? {};
      pTharais.forEach((p, info) {
        if (info['is_warning'] == true) {
          String pTamil = KPService.TAMIL_PLANETS[p] ?? p;
          rows.add(_buildDetailRow("$pTamil (${info['nakshatra']})", "${info['tharai_name']} - ${info['warning_type']}"));
        }
      });
    }

    // Karma nakshatras
    if (karma != null) {
      final pKarma = karma['planets_in_karma'] as List? ?? [];
      for (var pk in pKarma) {
        rows.add(_buildDetailRow("${pk['planet_tamil']} (${pk['nakshatra']})", pk['role'] ?? 'கரும நட்சத்திரம்'));
      }
    }

    if (rows.isEmpty) {
      rows.add(const Text("அனைத்து கிரகங்களும் சுப தாரைகளில் அமைந்துள்ளன"));
    }

    return _buildDetailCard("வைநாசிகம், புஷ்கரம், தாரைகள் & கரும நட்சத்திரங்கள்", rows);
  }

  Widget _buildUpagrahasCard() {
    final upagrahas = widget.results['upagrahas'] as Map<String, dynamic>? ?? {};

    return _buildDetailCard("உபகிரகங்கள் (Aprakash Upagrahas)", upagrahas.entries.map((e) {
      final info = e.value as Map<String, dynamic>;
      return _buildDetailRow(e.key, "${info['rasi_tamil']} (${info['formatted']}) - ${info['nakshatra']}");
    }).toList());
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    final l10n = AppLocalizations.of(context)!;
    String tTitle = AstroTranslationService.translate(context, title);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(color: Color(0xFF5D1204)),
            child: Text(tTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrimary = false, bool isPlanet = false}) {
    final l10n = AppLocalizations.of(context)!;
    String tLabel = AstroTranslationService.translate(context, label);
    String tValue = AstroTranslationService.translate(context, value, isPlanet: isPlanet);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text(tLabel, style: const TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 13))),
          const Text(" :  ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB58D3D))),
          Expanded(flex: 6, child: Text(tValue, style: TextStyle(color: isPrimary ? const Color(0xFFE65100) : const Color(0xFF5D1204), fontWeight: FontWeight.w900, fontSize: 13.5))),
        ],
      ),
    );
  }


  Widget _buildKattamView() {
    final l10n = AppLocalizations.of(context)!;
    final bool isNadi = widget.results['isNadi'] ?? false;
    final bool isWide = MediaQuery.of(context).size.width > 900;
    
    if (isWide) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildChartSection("ராசி கட்டம்", widget.results['rasi'], isWide: true)),
                const SizedBox(width: 32),
                Expanded(child: _buildChartSection(l10n.amsam, widget.results['navamsa'], isWide: true)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.gocharam, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                Switch(
                  value: _showGocharam,
                  activeColor: AppColors.primary,
                  onChanged: (val) => _toggleGocharam(),
                ),
                if (_isLoadingGocharam) const Padding(padding: EdgeInsets.only(left: 8), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
              ],
            ),
            const SizedBox(height: 32),
            _buildChartSection("பாவகம்", widget.results['pavagam'], isWide: true),
            const SizedBox(height: 20),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartSection("ராசி கட்டம்", widget.results['rasi']),
          const SizedBox(height: 32),
          _buildChartSection(l10n.amsam, widget.results['navamsa']),
          const SizedBox(height: 32),
          _buildChartSection("பாவகம்", widget.results['pavagam']),
          const SizedBox(height: 20),
        ],
      ),
    );
  }



  Widget _buildChartSection(String title, dynamic chartData, {bool isWide = false}) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        if (title == "ராசி கட்டம்" && !isWide) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.gocharam, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Switch(
                value: _showGocharam,
                activeColor: AppColors.primary,
                onChanged: (val) => _toggleGocharam(),
              ),
              if (_isLoadingGocharam) const Padding(padding: EdgeInsets.only(left: 8), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SouthIndianChart(
              rasiMap: _castChartMap(chartData),
              centerLabel: title.split(' ')[0],
              borderLabels: (title == "ராசி கட்டம்" && _showGocharam) ? _gocharamLabels : null,
            ),
          ),
        ),
        if (title == "ராசி கட்டம்" && !isWide) ...[
          const SizedBox(height: 20),
          _buildCurrentStatusTable(),
        ],
      ],
    );
  }

  Widget _buildCurrentStatusTable() {
    final List<dynamic>? dasaList = widget.results['dasa'];
    if (dasaList == null || dasaList.isEmpty) return const SizedBox();

    Map<String, dynamic>? activeDasa;
    Map<String, dynamic>? activeBukthi;
    DateTime now = DateTime.now();
    final birthDt = widget.results['birth_dt'] as DateTime?;
    if (birthDt != null && now.isBefore(birthDt)) {
      now = birthDt;
    }

    for (var dasa in dasaList) {
      final dStart = dasa['start'] as DateTime?;
      final dEnd = dasa['end'] as DateTime?;
      if (dStart != null && dEnd != null && !now.isBefore(dStart) && now.isBefore(dEnd)) {
        activeDasa = dasa;
        final List<dynamic> subPeriods = dasa['subPeriods'] ?? [];
        for (var bukthi in subPeriods) {
          final bStart = bukthi['start'] as DateTime?;
          final bEnd = bukthi['end'] as DateTime?;
          if (bStart != null && bEnd != null && !now.isBefore(bStart) && now.isBefore(bEnd)) {
            activeBukthi = bukthi;
            break;
          }
        }
        break;
      }
    }

    if (activeDasa == null && dasaList.isNotEmpty) {
      activeDasa = dasaList.first;
      final subPeriods = activeDasa!['subPeriods'] as List? ?? [];
      if (subPeriods.isNotEmpty) {
        activeBukthi = subPeriods.firstWhere(
          (b) => !(b['end'] as DateTime).isBefore(birthDt ?? dasaList.first['start']),
          orElse: () => subPeriods.first,
        );
      }
    }

    if (activeDasa == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
      ),
      child: Column(
        children: [
          _buildStatusRow("ஜனன கால தசை இருப்பு", _calculateBirthDasaBalance()),
          const Divider(height: 1, color: Color(0xFFB58D3D)),
          _buildStatusRow("நடப்பு தசா இருப்பு", "${activeDasa['lord']} - ${activeDasa['end'].day}-${activeDasa['end'].month}-${activeDasa['end'].year}"),
          const Divider(height: 1, color: Color(0xFFB58D3D)),
          _buildStatusRow("நடப்பு புத்தி இருப்பு", "${activeBukthi?['lord'] ?? '-'} - ${activeBukthi != null ? "${activeBukthi['end'].day}-${activeBukthi['end'].month}-${activeBukthi['end'].year}" : '-'}"),
          const Divider(height: 1, color: Color(0xFFB58D3D)),
          _buildStatusRow("திதி சூன்ய ராசிகள்", widget.results['panchangam']?['suniya_rasi'] ?? "-"),

        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    String tLabel = AstroTranslationService.translate(context, label);
    String tValue = AstroTranslationService.translate(context, value, isPlanet: true);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(tLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(tValue, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF5D1204), fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsView() {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, dynamic>? data = widget.results['planet_details'];
    if (data == null) return const Center(child: Text('தரவுகள் கிடைக்கவில்லை'));
    
    const List<String> sortedKeys = ["lagna", "sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu", "ketu", "maanthi"];
    Map<String, String> planetTamilNames = {
        "lagna": l10n.lagnaLabel, "sun": "சூரியன்", "moon": "சந்திரன்", "mars": "செவ்வாய்", "mercury": "புதன்", 
        "jupiter": "குரு", "venus": "சுக்கிரன்", "saturn": "சனி", "rahu": "ராகு", "ketu": "கேது", "maanthi": "மாந்தி"
    };

    final Map<String, String> rawPlanetNames = {
        "lagna": "Lagna", "sun": "Sun", "moon": "Moon", "mars": "Mars", "mercury": "Mercury", 
        "jupiter": "Jupiter", "venus": "Venus", "saturn": "Saturn", "rahu": "Rahu", "ketu": "Ketu", "maanthi": "Maanthi"
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Table(
          border: TableBorder.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 0.8),
          columnWidths: const {
            0: FlexColumnWidth(1.8),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(2.5),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.5),
          },
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: Color(0xFF5D1204)),
              children: [
                TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(l10n.planet, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(AstroTranslationService.translate(context, "பாகை"), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(AstroTranslationService.translate(context, "நட்சத்திரம்-பாதம்"), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(AstroTranslationService.translate(context, "ந.நா"), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(AstroTranslationService.translate(context, "நிலை"), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
              ],
            ),
            // Rows
            ...sortedKeys.map((key) {
              final p = data[key];
              if (p == null) return TableRow(children: [SizedBox(), SizedBox(), SizedBox(), SizedBox(), SizedBox()]);
              
              final lords = p['lords'] ?? {};
              final String rasi = p['rasi'] ?? "";
              final String dignity = KPService.getPlanetDignity(rawPlanetNames[key]!, rasi);
              
              return TableRow(
                children: [
                  _buildTableCell(planetTamilNames[key] ?? key, isPlanet: true),
                  _buildTableCell(KPService.formatAbsoluteDegrees(p['longitude'])),
                  _buildTableCell("${p['nakshatra']}-${p['pada']}"),
                  _buildTableCell(KPService.TAMIL_PLANET_SHORT[lords['nakLord']] ?? lords['nakLord'] ?? "-", isPlanet: true),
                  _buildTableCell(dignity),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    final l10n = AppLocalizations.of(context)!;
    String translatedText = AstroTranslationService.translate(context, text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        translatedText,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isPlanet = false}) {
    String translatedText = AstroTranslationService.translate(context, text, isPlanet: isPlanet);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        translatedText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isPlanet ? const Color(0xFFE65100) : const Color(0xFF5D1204),
          fontWeight: isPlanet ? FontWeight.bold : FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.indigo.shade900, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              color: isPrimary ? AppColors.primary : Colors.black87,
              fontSize: 15,
              fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalangalView() {
    final l10n = AppLocalizations.of(context)!;
    final pancha = widget.results['panchangam'] ?? {};
    final basics = widget.results['planet_details'] ?? {};
    final moon = basics['moon'] ?? {};
    final lagna = basics['lagna'] ?? {};
    final dasaList = widget.results['dasa'] as List? ?? [];
    
    // Find active Dasa & Bukthi
    Map<String, dynamic>? activeDasa;
    Map<String, dynamic>? activeBukthi;
    final now = DateTime.now();
    for (var d in dasaList) {
      if (now.isAfter(d['start']) && now.isBefore(d['end'])) {
        activeDasa = d;
        for (var b in (d['subPeriods'] as List? ?? [])) {
          if (now.isAfter(b['start']) && now.isBefore(b['end'])) {
            activeBukthi = b;
            break;
          }
        }
        break;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPalangalCard(
          "லக்ன பலன்", 
          PalangalService.getDetailedLagnaPalan(lagna['rasi']),
          Icons.brightness_5_rounded,
          color: Colors.orange.shade800,
          isTall: true,
        ),
        _buildPalangalCard(
          "ராசி பலன்", 
          PalangalService.getDetailedRasiPalan(moon['rasi']),
          Icons.brightness_2_rounded,
          color: Colors.indigo.shade800,
          isTall: true,
        ),
        _buildPalangalCard(
          "நட்சத்திர பலன்", 
          PalangalService.getDetailedNakshatraPalan(moon['nakshatra'], moon['pada']),
          Icons.star_rounded,
          color: Colors.amber.shade900,
          isTall: true,
        ),
        _buildPalangalCard(
          l10n.yogaLabel, 
          PalangalService.getDetailedYogaPalan(pancha['yoga']),
          Icons.auto_awesome_rounded,
          color: Colors.purple.shade700,
          isTall: true,
        ),
        _buildPalangalCard(
          "கர்ணம்", 
          PalangalService.getDetailedKaranaPalan(pancha['karana']?.toString()),
          Icons.category_rounded,
          color: Colors.teal.shade700,
          isTall: true,
        ),
        _buildPalangalCard(
          "கிழமை", 
          PalangalService.getDetailedWeekdayPalan(pancha['vara']),
          Icons.calendar_today_rounded,
          color: Colors.blue.shade800,
          isTall: true,
        ),
        _buildPalangalCard(
          l10n.tithiLabel, 
          PalangalService.getDetailedThithiPalan(pancha['tithi']),
          Icons.brightness_4_rounded,
          color: Colors.deepOrange.shade700,
          isTall: true,
        ),
        _buildPalangalCard(
          "தசா புத்தி பலன்", 
          activeDasa != null 
            ? "நடப்பு தசை: ${activeDasa['lord']} (${_formatDateOnly(activeDasa['end'])} வரை)\n${PalangalService.getDetailedDasaPalan(activeDasa['lord'])}\n\nநடப்பு புத்தி: ${activeBukthi?['lord'] ?? '-'} (${activeBukthi != null ? _formatDateOnly(activeBukthi['end']) : '-'} வரை)\n${PalangalService.getDetailedBhuktiPalan(activeBukthi?['lord'])}" 
            : "தசா புத்தி விபரங்கள் இல்லை",
          Icons.history_rounded,
          color: Colors.red.shade900,
          isTall: true,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPalangalCard(String title, String value, IconData icon, {required Color color, bool isTall = false}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          crossAxisAlignment: isTall ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                      fontSize: isTall ? 14.5 : 16, // Slightly smaller for long text cards
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateFullAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }
    
    if (years > 0) {
      return "$years வயது $months மாதம் $days நாள்";
    } else if (months > 0) {
      return "$months மாதம் $days நாள்";
    } else {
      return "$days நாள்";
    }
  }

  String _calculateBirthDasaBalance() {
    final List<dynamic>? dasaList = widget.results['dasa'];
    final birthDt = widget.results['birth_dt'] as DateTime?;
    if (dasaList == null || dasaList.isEmpty || birthDt == null) return "-";

    final firstDasa = dasaList[0];
    return "${firstDasa['lord']} - ${firstDasa['balanceStr'] ?? '-'}";
  }
  Widget _buildPrasannamView() {
    final prasannamData = widget.results['prasannam_data'] as Map<String, dynamic>?;
    if (prasannamData == null) return const Center(child: Text("தகவல் இல்லை"));

    final type = prasannamData['type'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPrasannamCard(prasannamData),
          const SizedBox(height: 20),
          if (type == 'horai') _buildHoraiPredictions(prasannamData),
          if (type == 'number' || type == 'soli') _buildPaathagaSection(prasannamData),
        ],
      ),
    );
  }

  Widget _buildPrasannamCard(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              _getPrasannamTitle(data['type']),
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white30, height: 25),
            _buildPrasannamRow("உள்ளீடு (Input)", data['input']?.toString() ?? "-"),
            if (data['rasi'] != null) _buildPrasannamRow("ஆரூட ராசி", data['rasi']),
            if (data['nakshatra'] != null) _buildPrasannamRow("ஆரூட நட்சத்திரம்", "${data['nakshatra']} - ${data['padam']}"),
            if (data['aarooda_number'] != null) _buildPrasannamRow("ஆரூட எண்", data['aarooda_number'].toString()),
            if (data['planet'] != null) _buildPrasannamRow("ஆரூட கிரகம்", KPService.TAMIL_PLANETS[data['planet']] ?? data['planet']),
            if (data['day_lord'] != null) _buildPrasannamRow("கிழமை நாதன்", KPService.TAMIL_PLANETS[data['day_lord']] ?? data['day_lord']),
            if (data['hora_lord'] != null) _buildPrasannamRow("ஓரை நாதன்", KPService.TAMIL_PLANETS[data['hora_lord']] ?? data['hora_lord']),
            if (data['ubha_hora_lord'] != null) _buildPrasannamRow("உப ஓரை நாதன்", KPService.TAMIL_PLANETS[data['ubha_hora_lord']] ?? data['ubha_hora_lord']),
          ],
        ),
      ),
    );
  }

  Widget _buildPrasannamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getPrasannamTitle(String? type) {
    switch (type) {
      case 'number': return 'எண் பிரசன்னம்';
      case 'soli': return 'சோழி பிரசன்னம்';
      case 'vetrilai': return 'வெற்றிலை பிரசன்னம்';
      case 'kp': return 'KP பிரசன்னம்';
      case 'horai': return 'ஓரை பிரசன்னம்';
      default: return 'பிரசன்னம்';
    }
  }

  Widget _buildHoraiPredictions(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("ஓரை பலன்", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Text(
                "மிகச் சிறப்பு. நினைத்த காரியம் நிச்சயம் விரைவில் நடக்கும்.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaathagaSection(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("பாதக விவரங்கள்", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPaathagaItem("பாதக ராசி", data['paathaga_rasi'] ?? "-"),
                _buildPaathagaItem("பாதக அதிபதி", KPService.TAMIL_PLANETS[data['paathaga_lord']] ?? data['paathaga_lord'] ?? "-"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaathagaItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }


  Future<void> _handleFullReport() async {
    setState(() => _isGenerating = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
    
    try {
      final astroDetails = await SettingsService.getAstrologerDetails();
      final bytes = await FullReportPdfService.generateFullHoroscopePdf(
        name: widget.results['name'] ?? widget.name,
        gender: widget.results['gender'] ?? '-',
        results: widget.results,
        astroDetails: astroDetails,
      );
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            pdfBytes: bytes,
            fileName: "FullHoroscope_${widget.name.replaceAll(' ', '_')}.pdf",
          ),
        ),
      );
    } catch (e, st) {
      print("PDF Generation Error: $e");
      print("Stack trace: $st");
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
