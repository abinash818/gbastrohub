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
    if (dasaList == null) return;
    
    final now = DateTime.now();
    for (var d in dasaList) {
      if (now.isAfter(d['start']) && now.isBefore(d['end'])) {
        _selectedDasa = d;
        for (var b in (d['subPeriods'] as List? ?? [])) {
          if (now.isAfter(b['start']) && now.isBefore(b['end'])) {
            _selectedBukthi = b;
            for (var a in (b['subPeriods'] as List? ?? [])) {
              if (now.isAfter(a['start']) && now.isBefore(a['end'])) {
                _selectedAntharam = a;
                for (var s in (a['subPeriods'] as List? ?? [])) {
                  if (now.isAfter(s['start']) && now.isBefore(s['end'])) {
                    _selectedSookshmam = s;
                    for (var p in (s['subPeriods'] as List? ?? [])) {
                      if (now.isAfter(p['start']) && now.isBefore(p['end'])) {
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
      tabLength = 7;
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
    
    final planets = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"];
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
      "Jupiter": "குரு", "Venus": "சுக்கிரன்", "Saturn": "சனி"
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
      'Jupiter': 'குரு', 'Venus': 'சுக்', 'Saturn': 'சனி'
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
      'Jupiter': 'குரு', 'Venus': 'சுக்', 'Saturn': 'சனி'
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
                      _buildDetailRow(l10n.rasiLabel, "${KPService.TAMIL_SIGNS[basics['moon']?['rasi']] ?? basics['moon']?['rasi'] ?? '-'}"),
                      _buildDetailRow(l10n.lagnaLabel, "${KPService.TAMIL_SIGNS[basics['lagna']?['rasi']] ?? basics['lagna']?['rasi'] ?? '-'}"),
                      _buildDetailRow(l10n.atmakarakaLabel, widget.results['atmakaraka'] ?? "-", isPlanet: true),
                      const Divider(color: Color(0xFFB58D3D), height: 32),
                      _buildDetailRow(l10n.ganam, matching['ganam'] ?? "-"),
                      _buildDetailRow(l10n.mirugam, matching['mirugam'] ?? "-"),
                      _buildDetailRow(l10n.pakshi, matching['pakshi'] ?? "-"),
                      _buildDetailRow(l10n.maram, matching['maram'] ?? "-"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildVivaramView() {final l10n = AppLocalizations.of(context)!;
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

    final cards = [
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
        if (namaEzhuthu.isNotEmpty) _buildDetailRow("நட்சத்திர நாம எழுத்து", namaEzhuthu),
        _buildDetailRow(l10n.rasiLabel, "${KPService.TAMIL_SIGNS[basics['moon']?['rasi']] ?? basics['moon']?['rasi'] ?? '-'} (${basics['moon']?['lords']?['signLord'] ?? '-'})"),
        _buildDetailRow(l10n.lagnaLabel, "${KPService.TAMIL_SIGNS[basics['lagna']?['rasi']] ?? basics['lagna']?['rasi'] ?? '-'} (${basics['lagna']?['lords']?['signLord'] ?? '-'})"),
        _buildDetailRow(l10n.atmakarakaLabel, widget.results['atmakaraka'] ?? "-", isPlanet: true),
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
        _buildDetailRow("லக்ன சுபர்கள்", lBenefics.join(", "), isPlanet: true),
        _buildDetailRow("லக்ன பாபர்கள்", lMalefics.join(", "), isPlanet: true),
        _buildDetailRow("லக்ன மாரகர்", lMarakas.join(", "), isPlanet: true),
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
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cards[0],
          const SizedBox(height: 20),
          cards[1],
          const SizedBox(height: 20),
          cards[2],
          const SizedBox(height: 20),
          cards[3],
          const SizedBox(height: 20),
          cards[4],
          const SizedBox(height: 20),
          cards[5],
          const SizedBox(height: 50),
        ],
      ),
    );
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
    if (dasaList == null) return const SizedBox();

    Map<String, dynamic>? activeDasa;
    Map<String, dynamic>? activeBukthi;
    final now = DateTime.now();

    for (var dasa in dasaList) {
      if (now.isAfter(dasa['start']) && now.isBefore(dasa['end'])) {
        activeDasa = dasa;
        final List<dynamic> subPeriods = dasa['subPeriods'] ?? [];
        for (var bukthi in subPeriods) {
          if (now.isAfter(bukthi['start']) && now.isBefore(bukthi['end'])) {
            activeBukthi = bukthi;
            break;
          }
        }
        break;
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
