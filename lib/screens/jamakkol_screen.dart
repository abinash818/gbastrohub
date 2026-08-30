import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/kp_service.dart';
import '../services/jamakkol_service.dart';
import '../components/south_indian_chart.dart';
import '../components/custom_drawer.dart';
import '../theme/app_colors.dart';
import '../services/settings_service.dart';
import '../services/jamakkol_one_page_pdf_service.dart';
import 'package:flutter/foundation.dart';
import 'pdf_viewer_screen.dart';
import '../widgets/location_search_dialog.dart';
import '../services/location_data.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';
import '../services/astro_translation_service.dart';

class JamakkolScreen extends StatefulWidget {
  const JamakkolScreen({super.key});

  @override
  State<JamakkolScreen> createState() => _JamakkolScreenState();
}

class _JamakkolScreenState extends State<JamakkolScreen> {
  int _selectedArudamIdx = 0;
  DateTime _currentTime = DateTime.now();
  Map<String, dynamic>? _results;
  bool _isLoading = true;
  bool _isAltNaming = false;
  bool _isInit = false;

  // Input variables
  DateTime? _inputTime;
  String? _inputLocationName;
  double? _inputLat;
  double? _inputLon;
  double? _inputTz;

  // 'Now' variables
  DateTime _nowTime = DateTime.now();
  String _nowLocationName = 'Chennai (சென்னை)';
  double _nowLat = 13.0827;
  double _nowLon = 80.2707;
  double _nowTz = 5.5;

  bool _showIppothu = false;

  Map<String, dynamic>? _selectedDasa;
  Map<String, dynamic>? _selectedBukthi;
  Map<String, dynamic>? _selectedAntharam;
  Map<String, dynamic>? _selectedSookshmam;
  Map<String, dynamic>? _selectedPranam;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final Map? args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        _inputTime = args['date'] ?? DateTime.now();
        _inputLat = args['lat'] ?? 13.0827;
        _inputLon = args['lon'] ?? 80.2707;
        _inputTz = args['tz'] ?? 5.5;
        _inputLocationName = args['place'] ?? 'Chennai (சென்னை)';
        _showIppothu = false;
      } else {
        _showIppothu = true;
      }
      _loadDefaultLocation();
      _isInit = true;
    }
  }

  Future<void> _loadDefaultLocation() async {
    try {
      final loc = await SettingsService.getDefaultLocation();
      setState(() {
        _nowLocationName = loc['name'] ?? 'Chennai (சென்னை)';
        _nowLat = loc['lat'] ?? 13.0827;
        _nowLon = loc['lon'] ?? 80.2707;
        _nowTz = loc['tz'] ?? 5.5;
      });
    } catch (e) {
      debugPrint("Error loading saved location: $e");
    }
    _calculateJamakkol();
  }

  Future<void> _calculateJamakkol() async {
    setState(() => _isLoading = true);
    
    try {
      DateTime timeToUse = _showIppothu ? _nowTime : (_inputTime ?? _nowTime);
      double latToUse = _showIppothu ? _nowLat : (_inputLat ?? _nowLat);
      double lonToUse = _showIppothu ? _nowLon : (_inputLon ?? _nowLon);
      double tzToUse = _showIppothu ? _nowTz : (_inputTz ?? _nowTz);

      // 1. Get Inner Planets
      final inner = await KPService.calculateChart("Prasanam", timeToUse, latToUse, lonToUse, tzToUse);

      // 2. Solar Month for Soorya Veethi
      double sunLon = (inner['planet_info']?['Sun']?['lon'] ?? 0.0).toDouble();
      int solarMonthIdx = (sunLon / 30).floor() % 12;

      // Parse sunrise and sunset
      final pancha = inner['panchangam'];
      DateTime sunrise = timeToUse;
      DateTime sunset = timeToUse;

      DateTime parseTime(String timeStr, DateTime baseDate) {
        try {
          final parts = timeStr.split(' ');
          final hms = parts[0].split(':');
          int h = int.parse(hms[0]);
          int m = int.parse(hms[1]);
          int s = hms.length > 2 ? int.parse(hms[2]) : 0;
          if (parts[1] == "PM" && h < 12) h += 12;
          if (parts[1] == "AM" && h == 12) h = 0;
          return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m, s);
        } catch (e) {
          return baseDate;
        }
      }

      try {
        sunrise = parseTime(pancha['sunrise'], timeToUse);
        sunset = parseTime(pancha['sunset'], timeToUse);
        if (timeToUse.isBefore(sunrise)) {
          sunrise = sunrise.subtract(const Duration(days: 1));
          sunset = sunset.subtract(const Duration(days: 1));
        }
      } catch (_) {}

      final udayamMethod = await SettingsService.getUdayamMethod();

      // 3. Outer Planets and Traditional Udayam/Arudam
      final langCode = AppLocalizations.of(context)!.localeName;
      final outer = JamakkolService.calculate(
        timeToUse,
        sunrise,
        latToUse,
        lonToUse,
        tzToUse,
        solarMonthIdx,
        sunLongitude: sunLon,
        useAltNaming: _isAltNaming,
        langCode: langCode,
        udayamMethod: udayamMethod,
        sunset: sunset,
      );

      // 4. Extract Udayam and Arudam from the precise calculation
      int udayamIdx = outer['udayam_idx'] ?? 0;
      int arudamIdx = outer['arudam_sign_idx'] ?? 0;
      int sooryaVeethiIdx = outer['soorya_veethi_idx'] ?? 0;
      int kaviIdx = JamakkolService.calculateKavippu(udayamIdx, arudamIdx, sooryaVeethiIdx);

      // Calculate Jamakkol SubPlanets
      final subPlanets = calculateAllJamakkolSubPlanets(
        currentTime: timeToUse,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      setState(() {
        _results = {
          'inner': inner,
          'outer': outer,
          'udayam_idx': udayamIdx,
          'arudam_idx': arudamIdx,
          'kavi_idx': kaviIdx,
          'sub_planets': subPlanets,
          'strength': JamakkolService.calculateStrengthAnalysis({
            'udayam_idx': udayamIdx,
            'arudam_idx': arudamIdx,
            'kavi_idx': kaviIdx,
            'outer': outer,
          }, langCode: langCode),
          'notes': JamakkolService.calculateNotes({
            'udayam_idx': udayamIdx,
            'arudam_idx': arudamIdx,
            'kavi_idx': kaviIdx,
            'inner': inner,
            'outer': outer,
            'udayam_abs_deg': outer['udayam_abs_deg'],
          }, langCode: langCode),
        };
        _selectedArudamIdx = arudamIdx; // Sync UI
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error calculating Jamakkol: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorCalculating} $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.jamakkolPrasannamTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary)),
          centerTitle: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: () {
                setState(() {
                  _nowTime = DateTime.now();
                  if (_showIppothu || _inputTime == null) {
                    _showIppothu = true;
                  }
                });
                _calculateJamakkol();
              },
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              onPressed: () async {
                if (_results == null) return;
                if (kIsWeb) {
                  JamakkolOnePagePdfService.showHtmlReport(name: AppLocalizations.of(context)!.tabPrasannam, gender: "-", results: _results!, inputTime: _inputTime ?? _nowTime, place: _inputLocationName ?? _nowLocationName, lat: _inputLat ?? _nowLat, lon: _inputLon ?? _nowLon, isAltNaming: _isAltNaming, l10n: AppLocalizations.of(context)!);
                  return;
                }
                final bytes = await JamakkolOnePagePdfService.generate(name: AppLocalizations.of(context)!.tabPrasannam, gender: "-", results: _results!, inputTime: _inputTime ?? _nowTime, place: _inputLocationName ?? _nowLocationName, lat: _inputLat ?? _nowLat, lon: _inputLon ?? _nowLon, isAltNaming: _isAltNaming, l10n: AppLocalizations.of(context)!);
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerScreen(pdfBytes: bytes, fileName: "ஜாமக்கோள்_பிரசன்னம்.pdf")));
              }
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: [
              Tab(text: AppLocalizations.of(context)!.tabPrasannam),
              Tab(text: AppLocalizations.of(context)!.tabPadasaram),
              Tab(text: AppLocalizations.of(context)!.tabDasaBukthi),
            ],
          ),
        ),
        drawer: const CustomDrawer(),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPrasannamView(),
                      _buildPathasaramView(),
                      _buildDasaView(),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildPrasannamView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (_inputTime != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_showIppothu) {
                            setState(() => _showIppothu = false);
                            _calculateJamakkol();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_showIppothu ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(AppLocalizations.of(context)!.jathagam, style: TextStyle(color: !_showIppothu ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_showIppothu) {
                            setState(() {
                              _showIppothu = true;
                              _nowTime = DateTime.now();
                            });
                            _calculateJamakkol();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _showIppothu ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(AppLocalizations.of(context)!.nowTooltip, style: TextStyle(color: _showIppothu ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _buildTimePlaceCard(),
          ),
          const SizedBox(height: 5),
          if (_results != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.jamakkolPlanet, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _isAltNaming ? AppColors.primary : Colors.grey.shade600)),
                Switch(
                  value: _isAltNaming,
                  onChanged: (val) {
                    setState(() => _isAltNaming = val);
                    _calculateJamakkol();
                  },
                  activeColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildCombinedChart(),
          ],
          const SizedBox(height: 25),
          if (_results != null) _buildJamakkolNotes(),
          const SizedBox(height: 20),
          if (_results != null) _buildKathirAnalysis(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Map<String, String> _getStarPada(BuildContext context, double deg) {
    String star = KPService.NAKSHATRAS[(deg / (360/27)).floor() % 27];
    int pada = ((deg % (360/27)) / (360/108)).floor() + 1;
    return {'star': AstroTranslationService.translate(context, star), 'pada': pada.toString()};
  }

  Widget _buildPathasaramView() {
    if (_results == null) return Center(child: Text(AppLocalizations.of(context)!.noDetails));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.jamakkolPlanetsMainPoints, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 15)),
          const SizedBox(height: 12),
          _buildOuterPathasaramTable(),
          const SizedBox(height: 30),
          Text(AppLocalizations.of(context)!.innerPlanets, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 15)),
          const SizedBox(height: 12),
          _buildInnerPathasaramTable(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOuterPathasaramTable() {
    List<TableRow> rows = [];
    rows.add(
      TableRow(
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
        children: [
          Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.nameLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.degree, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.nakshatra, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.pada, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
        ],
      )
    );

    void addRow(String name, double deg) {
      int d = deg.floor();
      int m = ((deg - d) * 60).floor();
      var sp = _getStarPada(context, deg);
      rows.add(
        TableRow(
          children: [
            Padding(padding: const EdgeInsets.all(8), child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: const EdgeInsets.all(8), child: Text("$d° $m'")),
            Padding(padding: const EdgeInsets.all(8), child: Text(sp['star']!)),
            Padding(padding: const EdgeInsets.all(8), child: Text(sp['pada']!)),
          ]
        )
      );
    }

    final outer = _results!['outer'];
    
    double uDeg = outer['udayam_abs_deg'] ?? 0.0;
    double aDeg = outer['arudam_abs_deg'] ?? 0.0;
    
    int kaviIdx = _results!['kavi_idx'] ?? 0;
    double kDeg = (30.0 - (aDeg % 30.0)) + (kaviIdx * 30.0);
    kDeg = (kDeg % 360.0 + 360.0) % 360.0;

    addRow(AppLocalizations.of(context)!.udayam, uDeg);
    addRow(AppLocalizations.of(context)!.arudam, aDeg);
    addRow(AppLocalizations.of(context)!.kavippu, kDeg);

    // Add Jamakkol Subplanets to Outer Pathasaram Table
    final subPlanets = _results?['sub_planets'] as JamakkolSubPlanets?;
    if (subPlanets != null) {
      String getSubPlanetFullName(String name, String lang) {
        if (lang == 'ta') {
          if (name == "Rahu") return "ரா(வ) / கோள் இராகு";
          if (name == "Yamagandan") return "எமகண்டன்";
          if (name == "Mrityu") return "மிருத்யு";
        } else if (lang == 'hi') {
          if (name == "Rahu") return "राहु (मार्गी)";
          if (name == "Yamagandan") return "यमगंडम";
          if (name == "Mrityu") return "मृत्यु";
        } else {
          if (name == "Rahu") return "Rahu (Clockwise)";
          if (name == "Yamagandan") return "Yamagandan";
          if (name == "Mrityu") return "Mrityu";
        }
        return name;
      }
      final lang = AppLocalizations.of(context)!.localeName;
      
      void addSubPlanetRow(SubPlanetResult sp) {
        double deg = (sp.rasi - 1) * 30.0 + sp.degree;
        addRow(getSubPlanetFullName(sp.name, lang), deg);
      }
      addSubPlanetRow(subPlanets.rahu);
      addSubPlanetRow(subPlanets.yamagandan);
      addSubPlanetRow(subPlanets.mrityu);
    }

    final pDegs = outer['planet_degrees'] as Map;
    final namingMap = _isAltNaming ? JamakkolService.JAMAKKOL_TAMIL_ALT : JamakkolService.JAMAKKOL_TAMIL_SHORT;
    
    for (var pName in JamakkolService.JAMAKKOL_PLANETS) {
      double deg = (pDegs[pName] ?? 0.0).toDouble();
      addRow(AstroTranslationService.translate(context, namingMap[pName] ?? pName), deg);
    }

    return Table(
      border: TableBorder.all(color: AppColors.primaryLight.withOpacity(0.5), width: 1),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(0.8),
      },
      children: rows,
    );
  }

  Widget _buildInnerPathasaramTable() {
    List<TableRow> rows = [];
    rows.add(
      TableRow(
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08)),
        children: [
          Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.planet, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.degree, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.nakshatra, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
          Padding(padding: const EdgeInsets.all(8), child: Text(AppLocalizations.of(context)!.pada, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
        ],
      )
    );

    void addRow(String name, double deg) {
      int d = deg.floor();
      int m = ((deg - d) * 60).floor();
      var sp = _getStarPada(context, deg);
      rows.add(
        TableRow(
          children: [
            Padding(padding: const EdgeInsets.all(8), child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: const EdgeInsets.all(8), child: Text("$d° $m'")),
            Padding(padding: const EdgeInsets.all(8), child: Text(sp['star']!)),
            Padding(padding: const EdgeInsets.all(8), child: Text(sp['pada']!)),
          ]
        )
      );
    }

    final pDetails = _results!['inner']['planet_details'] as Map;
    final keys = ['lagna', 'sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu'];
    
    for (var key in keys) {
      if (!pDetails.containsKey(key)) continue;
      double deg = (pDetails[key]['longitude'] ?? 0.0).toDouble();
      String nameKey = key[0].toUpperCase() + key.substring(1);
      String name = KPService.TAMIL_PLANETS[nameKey] ?? nameKey;
      if (key == 'lagna') name = AppLocalizations.of(context)!.lagna;
      else name = AstroTranslationService.translate(context, name, isPlanet: true);
      addRow(name, deg);
    }

    return Table(
      border: TableBorder.all(color: AppColors.primaryLight.withOpacity(0.5), width: 1),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(0.8),
      },
      children: rows,
    );
  }

  Widget _buildKathirAnalysis() {
    final strength = _results!['strength'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
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
              const Icon(Icons.flash_on_rounded, color: Color(0xFFB58D3D), size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.strengthAnalysis, 
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildKathirRow(AppLocalizations.of(context)!.feature, AppLocalizations.of(context)!.sign, AppLocalizations.of(context)!.lord, AppLocalizations.of(context)!.total, isHeader: true),
          const Divider(color: Color(0xFFB58D3D)),
          _buildKathirRow(AstroTranslationService.translate(context, strength['udayam']['label']), AstroTranslationService.translate(context, "${strength['udayam']['rasi']}"), AstroTranslationService.translate(context, "${strength['udayam']['lord']}", isPlanet: true), "${strength['udayam']['total']}"),
          _buildKathirRow(AstroTranslationService.translate(context, strength['arudam']['label']), AstroTranslationService.translate(context, "${strength['arudam']['rasi']}"), AstroTranslationService.translate(context, "${strength['arudam']['lord']}", isPlanet: true), "${strength['arudam']['total']}"),
          _buildKathirRow(AstroTranslationService.translate(context, strength['kavi']['label']), AstroTranslationService.translate(context, "${strength['kavi']['rasi']}"), AstroTranslationService.translate(context, "${strength['kavi']['lord']}", isPlanet: true), "${strength['kavi']['total']}"),
          const Divider(color: Color(0xFFB58D3D)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${AppLocalizations.of(context)!.jamakkolPlanet} (${AstroTranslationService.translate(context, strength['jamam']['planet'], isPlanet: true)})", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D1204))),
                Text("${strength['jamam']['total']}", style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFE65100), fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKathirRow(String col1, String col2, String col3, String col4, {bool isHeader = false}) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.w900 : FontWeight.bold,
      fontSize: isHeader ? 12 : 14,
      color: isHeader ? Colors.grey.shade600 : const Color(0xFF5D1204),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(col1, style: style)),
          Expanded(flex: 2, child: Text(col2, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(col3, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(col4, style: style.copyWith(color: isHeader ? null : const Color(0xFFE65100), fontSize: isHeader ? 12 : 16), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    DateTime timeToShow = _showIppothu ? _nowTime : (_inputTime ?? _nowTime);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(timeToShow),
    );
    if (picked != null) {
      if (!context.mounted) return;
      int seconds = timeToShow.second;
      final secondsController = TextEditingController(text: seconds.toString());
      final int? pickedSeconds = await showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.localeName == 'ta' ? 'விநாடிகள் (Seconds)' : 'Seconds'),
          content: TextField(
            controller: secondsController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '0-59',
              suffixText: 'sec',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 0),
              child: Text(AppLocalizations.of(context)!.localeName == 'ta' ? 'பூஜ்ஜியம் (Reset)' : 'Reset'),
            ),
            TextButton(
              onPressed: () {
                int s = int.tryParse(secondsController.text) ?? 0;
                if (s < 0) s = 0;
                if (s > 59) s = 59;
                Navigator.pop(context, s);
              },
              child: Text(AppLocalizations.of(context)!.localeName == 'ta' ? 'சரி (OK)' : 'OK'),
            ),
          ],
        ),
      );

      setState(() {
        DateTime newTime = DateTime(
          timeToShow.year, timeToShow.month, timeToShow.day,
          picked.hour, picked.minute, pickedSeconds ?? seconds
        );
        if (_showIppothu) {
          _nowTime = newTime;
        } else {
          _inputTime = newTime;
        }
      });
      _calculateJamakkol();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime timeToShow = _showIppothu ? _nowTime : (_inputTime ?? _nowTime);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: timeToShow,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        DateTime newTime = DateTime(
          picked.year, picked.month, picked.day,
          timeToShow.hour, timeToShow.minute, timeToShow.second
        );
        if (_showIppothu) {
          _nowTime = newTime;
        } else {
          _inputTime = newTime;
        }
      });
      _calculateJamakkol();
    }
  }

  Widget _buildTimePlaceCard() {
    DateTime timeToShow = _showIppothu ? _nowTime : (_inputTime ?? _nowTime);
    String placeToShow = _showIppothu ? _nowLocationName : (_inputLocationName ?? _nowLocationName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.04), 
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.timeLabel, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        "${timeToShow.hour.toString().padLeft(2, '0')}:${timeToShow.minute.toString().padLeft(2, '0')}:${timeToShow.second.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.dateLabel, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        "${timeToShow.day}/${timeToShow.month}/${timeToShow.year}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF5D1204)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () async {
                final result = await showDialog<CityLocation>(
                  context: context,
                  builder: (context) => const LocationSearchDialog(),
                );
                if (result != null) {
                  setState(() {
                    if (_showIppothu) {
                      _nowLocationName = result.name;
                      _nowLat = result.lat;
                      _nowLon = result.lon;
                      _nowTz = result.tz;
                    } else {
                      _inputLocationName = result.name;
                      _inputLat = result.lat;
                      _inputLon = result.lon;
                      _inputTz = result.tz;
                    }
                  });
                  _calculateJamakkol();
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_location_alt_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(AppLocalizations.of(context)!.placeLabel, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      placeToShow,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF5D1204)),
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

  Widget _buildArudamSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('${AppLocalizations.of(context)!.arudam}:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            itemBuilder: (context, index) {
              bool isSel = _selectedArudamIdx == index;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? AppColors.primary : Colors.black12),
                ),
                child: Center(
                  child: Text(
                    KPService.TAMIL_SIGNS[KPService.SIGNS[index]]!,
                    style: TextStyle(color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCenterWidget() {
    final pancha = _results!['inner']['panchangam'];
    DateTime timeToUse = _showIppothu ? _nowTime : (_inputTime ?? _nowTime);
    final DateTime dt = timeToUse;

    DateTime parseTime(String timeStr, DateTime baseDate) {
      try {
        final parts = timeStr.split(' ');
        final hms = parts[0].split(':');
        int h = int.parse(hms[0]);
        int m = int.parse(hms[1]);
        int s = hms.length > 2 ? int.parse(hms[2]) : 0;
        if (parts[1] == "PM" && h < 12) h += 12;
        if (parts[1] == "AM" && h == 12) h = 0;
        return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m, s);
      } catch (e) {
        return baseDate;
      }
    }

    final sunrise = parseTime(pancha['sunrise'], dt);
    final sunset = parseTime(pancha['sunset'], dt);
    
    final langCode = AppLocalizations.of(context)!.localeName;
    final segments = JamakkolService.calculateCurrentSegments(dt, sunrise, sunset, langCode: langCode);
    
    final tamilMonth = pancha['tamil_month'];
    final tamilDate = pancha['tamil_date'];
    final dayTamil = pancha['vara'];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${AstroTranslationService.translate(context, tamilMonth)} - $tamilDate", style: GoogleFonts.outfit(color: const Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 13)),
        Text("${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}", style: GoogleFonts.outfit(color: const Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 12)),
        Text(AstroTranslationService.translate(context, dayTamil), style: GoogleFonts.outfit(color: const Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Text(
          "${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}",
          style: GoogleFonts.outfit(color: const Color(0xFF5D1204), fontWeight: FontWeight.w900, fontSize: 14)
        ),
        if (segments['status'] != "-")
           Text(AstroTranslationService.translate(context, segments['status']), style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w900, fontSize: 14)),
        Text("${AstroTranslationService.translate(context, "கௌரி")} : ${segments['gowri']}", style: const TextStyle(color: Color(0xFFB58D3D), fontWeight: FontWeight.w900, fontSize: 13)),
      ],
    );
  }

  Widget _buildCombinedChart() {
    Map<String, List<String>> rasiMap = {};
    for (var sign in KPService.SIGNS) rasiMap[sign] = [];
    
    final outer = _results!['outer'];
    final udayamIdx = _results!['udayam_idx'] ?? 0;

    // Inner Planets
    final Map<String, dynamic> pDetails = _results!['inner']['planet_details'];
    pDetails.forEach((pKey, pVal) {
      String sign = pVal['rasi'];
      double lon = pVal['longitude'] % 30;
      int d = lon.floor();
      int m = ((lon - d) * 60).floor();
      
      if (pKey == 'lagna') {
        // Use Jamakkol Udayam instead of KP Lagna for consistency in Jamakkol Chart
        String jUdayamSign = KPService.SIGNS[udayamIdx % 12];
        double jUdayamDeg = (outer['udayam_abs_deg'] ?? 0.0) % 30;
        int jd = jUdayamDeg.floor();
        int jm = ((jUdayamDeg - jd) * 60).floor();
        rasiMap[jUdayamSign]?.add("${AppLocalizations.of(context)!.udaShort}\u00A0${jd.toString().padLeft(2, '0')}:${jm.toString().padLeft(2, '0')}");
      } else {
        if (pKey == 'fortuna') return; // Skip Fortuna in Jamakkol Chart
        
        final Map<String, dynamic> pInfo = _results!['inner']['planet_info'] ?? {};
        bool isRetro = pInfo[pKey[0].toUpperCase() + pKey.substring(1)]?['isRetro'] ?? false;
        double pLon = (pVal['longitude'] ?? 0.0).toDouble();
        double sunLon = (pDetails['sun']?['longitude'] ?? 0.0).toDouble();
        bool isCombust = JamakkolService.isPlanetCombust(pKey[0].toUpperCase() + pKey.substring(1), pLon, sunLon, isRetro);

        String name = KPService.TAMIL_PLANET_SHORT[pKey[0].toUpperCase() + pKey.substring(1)] ?? pKey;
        if (pKey == 'sun') name = 'சூ';
        if (pKey == 'moon') name = 'சந்';
        name = AstroTranslationService.translate(context, name);

        String suffix = "";
        final lang = AppLocalizations.of(context)!.localeName;
        if (isRetro && pKey != 'rahu' && pKey != 'ketu') {
          suffix += (lang == 'en') ? "R" : "வ";
        }
        if (isCombust) {
          if (suffix.isNotEmpty) suffix += ",";
          suffix += (lang == 'en') ? "C" : ((lang == 'hi') ? "अ" : "அ");
        }
        if (suffix.isNotEmpty) {
          name = "$name($suffix)";
        }

        rasiMap[sign]!.add("$name\u00A0${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}");
      }
    });

    // Arudam and Kavi
    int arudamIdx = _results?['arudam_idx'] ?? 0;
    double aDeg = (_results?['outer']?['arudam_abs_deg'] ?? 0.0).toDouble();
    double aDegInSign = aDeg % 30.0;
    int aD = aDegInSign.floor();
    int aM = ((aDegInSign - aD) * 60).floor();
    
    debugPrint("Arudam: Idx=$arudamIdx, Deg=$aDeg");
    rasiMap[KPService.SIGNS[arudamIdx % 12]]?.add("${AppLocalizations.of(context)!.aruShort}\u00A0${aD.toString().padLeft(2, '0')}:${aM.toString().padLeft(2, '0')}");
    
    int kaviIdx = _results?['kavi_idx'] ?? 0;
    double kDegInSign = 30.0 - aDegInSign;
    if (kDegInSign >= 30.0) kDegInSign = 29.9999;
    int kD = kDegInSign.floor();
    int kM = ((kDegInSign - kD) * 60).floor();
    rasiMap[KPService.SIGNS[kaviIdx % 12]]?.add("${AppLocalizations.of(context)!.kaviShort}\u00A0${kD.toString().padLeft(2, '0')}:${kM.toString().padLeft(2, '0')}");

    // Subplanets (Rahu, Yamagandan, Mrityu)
    final lang = AppLocalizations.of(context)!.localeName;
    final subPlanets = _results?['sub_planets'] as JamakkolSubPlanets?;
    if (subPlanets != null) {
      String getSubPlanetDisplayName(String name, String lang) {
        if (lang == 'ta') {
          if (name == "Rahu") return "ரா";
          if (name == "Yamagandan") return "எம";
          if (name == "Mrityu") return "மிரு";
        } else if (lang == 'hi') {
          if (name == "Rahu") return "रा";
          if (name == "Yamagandan") return "यम";
          if (name == "Mrityu") return "मृ";
        } else {
          if (name == "Rahu") return "Rah";
          if (name == "Yamagandan") return "Yama";
          if (name == "Mrityu") return "Mri";
        }
        return name;
      }

      void addSubPlanet(SubPlanetResult sp) {
        String sign = KPService.SIGNS[sp.rasi - 1];
        double degInSign = sp.degree;
        int d = degInSign.floor();
        int m = ((degInSign - d) * 60).floor();
        String name = getSubPlanetDisplayName(sp.name, lang);
        rasiMap[sign]?.add("$name\u00A0${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}");
      }
      addSubPlanet(subPlanets.rahu);
      addSubPlanet(subPlanets.yamagandan);
      addSubPlanet(subPlanets.mrityu);
    }

    // Border Labels
    final Map<String, String> borderLabels = Map<String, String>.from(_results!['outer']['border_planets']);
    
    // Find the sign for highlight
    String currentPlanet = _results?['outer']?['current_jamam_planet'] ?? "Sun";
    final namingMap = _isAltNaming ? JamakkolService.JAMAKKOL_TAMIL_ALT : JamakkolService.JAMAKKOL_TAMIL_SHORT;
    String tamilName = namingMap[currentPlanet] ?? currentPlanet;
    String? highlightSign;
    borderLabels.forEach((s, label) {
      if (label.contains(tamilName)) highlightSign = s;
    });

    return Column(
      children: [
        Text(AppLocalizations.of(context)!.jamakkolChartTitle, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
        const SizedBox(height: 12),
        SouthIndianChart(
          rasiMap: rasiMap,
          centerWidget: _buildCenterWidget(),
          borderLabels: borderLabels,
          highlightSign: highlightSign,
        ),
      ],
    );
  }

  Widget _buildKaviInfo() {
    int kaviIdx = _results?['kavi_idx'] ?? 0;
    String kaviSign = KPService.TAMIL_SIGNS[KPService.SIGNS[kaviIdx % 12]] ?? "மேஷம்";
    String udayamSign = "-";
    try {
      udayamSign = KPService.TAMIL_SIGNS[(_results?['inner']?['planet_details']?['lagna']?['rasi'])] ?? "-";
    } catch (e) {
      debugPrint("Udayam Sign Error: $e");
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
      child: Column(
        children: [
          _buildInfoRow(AppLocalizations.of(context)!.udayam, udayamSign),
          const Divider(),
          _buildInfoRow(AppLocalizations.of(context)!.arudam, KPService.TAMIL_SIGNS[KPService.SIGNS[_results!['arudam_idx']]]!),
          const Divider(),
          _buildInfoRow(AppLocalizations.of(context)!.kavippu, kaviSign, isPrimary: true),
        ],
      ),
    );
  }

  Widget _buildJamakkolNotes() {
    final notes = _results!['notes'] as Map<String, dynamic>;
    final isTa = AppLocalizations.of(context)!.localeName == 'ta';
    final isHi = AppLocalizations.of(context)!.localeName == 'hi';

    // Helper: Translate planet name
    String getPName(String name) {
      return AstroTranslationService.translate(context, name, isPlanet: true);
    }
    
    // Helper: Translate rasi name
    String getRName(String name) {
      return AstroTranslationService.translate(context, name);
    }

    // 1. Planet contacting Udayam
    final uContacts = notes['udayam_contact'] as List;
    String uContactStr = "-";
    if (uContacts.isNotEmpty) {
      uContactStr = uContacts.map((c) {
        String p = getPName(c['planet']);
        double deg = c['deg'] % 30;
        int d = deg.floor();
        int m = ((deg - d) * 60).floor();
        String degStr = "${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
        return isTa 
            ? "$p\_$degStr / பாவம் ${c['house']} / ${c['lordship']}"
            : (isHi ? "$p\_$degStr / भाव ${c['house']} / ${c['lordship']}" : "$p\_$degStr / House ${c['house']} / ${c['lordship']}");
      }).join(", ");
    }

    // 2. Udayam star pada
    final uStar = notes['udayam_star'] as Map;
    double uDeg = uStar['deg'] % 30;
    int ud = uDeg.floor();
    int um = ((uDeg - ud) * 60).floor();
    String uStarStr = "${ud.toString().padLeft(2, '0')}:${um.toString().padLeft(2, '0')} ${getRName(uStar['nakshatra'])} ${uStar['pada']} ${getPName(uStar['lord'])} ${uStar['lordship']}";

    // 3. Crossed planet
    final crossed = notes['crossed_planet'] as Map?;
    String crossedStr = "-";
    if (crossed != null) {
      double cDeg = crossed['deg'] % 30;
      int cd = cDeg.floor();
      int cm = ((cDeg - cd) * 60).floor();
      String cDegStr = "${cd.toString().padLeft(2, '0')}:${cm.toString().padLeft(2, '0')}";
      crossedStr = "${getPName(crossed['planet'])} ${crossed['lordship']} = $cDegStr";
    }

    // 4. Arudam House
    final aHouse = notes['arudam_house_details'] as Map;
    double aDeg = aHouse['deg'] % 30;
    int ad = aDeg.floor();
    int am = ((aDeg - ad) * 60).floor();
    String aDegStr = "${ad.toString().padLeft(2, '0')}:${am.toString().padLeft(2, '0')}";
    String aHouseStr = "${aHouse['house']} ${getPName(aHouse['lord'])} ${aHouse['lordship']} $aDegStr ${getRName(aHouse['nakshatra'])} ${aHouse['pada']}";

    // 5. Planet contacting Arudam
    final aContact = notes['arudam_contact'] as Map?;
    String aContactStr = "-";
    if (aContact != null) {
      double acDeg = aContact['deg'] % 30;
      int acd = acDeg.floor();
      int acm = ((acDeg - acd) * 60).floor();
      String acDegStr = "${acd.toString().padLeft(2, '0')}:${acm.toString().padLeft(2, '0')}";
      aContactStr = "${getPName(aContact['planet'])}\_$acDegStr ${getRName(aContact['nakshatra'])} ${aContact['pada']}";
    }

    // 6. Kavippu House
    final kHouse = notes['kavi_house_details'] as Map;
    double kDeg = kHouse['deg'] % 30;
    int kd = kDeg.floor();
    int km = ((kDeg - kd) * 60).floor();
    String kDegStr = "${kd.toString().padLeft(2, '0')}:${km.toString().padLeft(2, '0')}";
    String kHouseStr = "${kHouse['house']} $kDegStr ${getRName(kHouse['nakshatra'])} ${kHouse['pada']}";

    // 7. Planet covered by Kavippu
    final kPlanet = notes['kavi_planet_details'] as Map?;
    String kPlanetStr = "-";
    if (kPlanet != null) {
      double kpDeg = kPlanet['deg'] % 30;
      int kpd = kpDeg.floor();
      int kpm = ((kpDeg - kpd) * 60).floor();
      String kpDegStr = "${kpd.toString().padLeft(2, '0')}:${kpm.toString().padLeft(2, '0')}";
      kPlanetStr = "${getPName(kPlanet['planet'])} - ${kPlanet['lordship']} = $kpDegStr ${getRName(kPlanet['nakshatra'])} ${kPlanet['pada']}";
    }

    // 8. Arudam Lord House
    String aLordHouseStr = notes['arudam_lord_house'].toString();

    // 9. Arudam vs Udayam
    String aVsUStr = notes['arudam_vs_udayam'].toString();

    // 10. Arudam vs Kavippu
    String aVsKStr = notes['arudam_vs_kavi'].toString();

    // 11. 8th Lord
    final eLord = notes['eighth_lord_details'] as Map;
    String eLordStr = isTa 
        ? "${getPName(eLord['lord'])} \_ ${eLord['house']}-ல்"
        : (isHi ? "${getPName(eLord['lord'])} \_ ${eLord['house']} वें भाव में" : "${getPName(eLord['lord'])} in House ${eLord['house']}");

    // 12. Badhakadhipathi
    final bLord = notes['badhaka_lord_details'] as Map;
    String bTypeLabel = isTa
        ? (bLord['type_offset'] == 11 ? "சர ராசி 11" : (bLord['type_offset'] == 9 ? "ஸ்திர ராசி 9" : "உபய ராசி 7"))
        : (isHi ? (bLord['type_offset'] == 11 ? "चर राशि 11" : (bLord['type_offset'] == 9 ? "स्थिर राशि 9" : "द्विस्वभाव राशि 7")) : "Badhaka House ${bLord['type_offset']}");
    String bLordStr = isTa
        ? "${getPName(bLord['lord'])} ($bTypeLabel) ${bLord['house']} \_ல்"
        : (isHi ? "${getPName(bLord['lord'])} ($bTypeLabel) ${bLord['house']} वें भाव में" : "${getPName(bLord['lord'])} ($bTypeLabel) in House ${bLord['house']}");

    // 13. Parivarthanai
    final parivarthanas = notes['parivarthana'] as List;
    String parivarthanaiStr = parivarthanas.isEmpty 
        ? (isTa ? "இராசி பரிவர்த்தனை இல்லை" : (isHi ? "राशि परिवर्तन नहीं है" : "No Rasi exchange"))
        : parivarthanas.map((p) {
            final parts = p.toString().split('-');
            return "${getPName(parts[0])} - ${getPName(parts[1])}";
          }).join(", ");

    // 14. Sootchuma Rasi
    final sootchuma = notes['sootchuma_details'] as Map;
    String sootchumaStr = isTa
        ? "${getRName(sootchuma['rasi'])} (துல்லியமாக: ${getRName(sootchuma['pada_rasi'])} - ${getRName(sootchuma['pada_nakshatra'])} ${sootchuma['pada_num']})"
        : "${getRName(sootchuma['rasi'])} (Precise: ${getRName(sootchuma['pada_rasi'])} - ${getRName(sootchuma['pada_nakshatra'])} ${sootchuma['pada_num']})";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
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
              const Icon(Icons.description_rounded, color: Color(0xFFB58D3D), size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.jamakkolNotes, 
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNoteRow(isTa ? "1. உதயம் தொடர்பு கொள்ளும் கிரகம்" : "1. Planet Contacting Udayam", uContactStr),
          _buildNoteRow(isTa ? "2. உதயம் நின்ற நட்சத்திர பாதம்" : "2. Udayam Star Pada", uStarStr),
          _buildNoteRow(isTa ? "3. உதயத்தை கடந்த கிரகம்" : "3. Planet Passed Udayam", crossedStr),
          _buildNoteRow(isTa ? "4. ஆருடம் உள்ள பாவம்" : "4. Arudam House Details", aHouseStr),
          _buildNoteRow(isTa ? "5. ஆருடம் தொடர்பு கொள்ளும் கிரகம்" : "5. Planet Contacting Arudam", aContactStr),
          _buildNoteRow(isTa ? "6. கவிப்புள்ள பாவம்" : "6. Kavippu House Details", kHouseStr),
          _buildNoteRow(isTa ? "7. கவிக்கப்படும் கிரகம்" : "7. Planet Covered by Kavippu", kPlanetStr),
          _buildNoteRow(isTa ? "8. ஆருடாதிபதி நின்ற பாவம்" : "8. Arudam Lord's House", aLordHouseStr),
          _buildNoteRow(isTa ? "9. ஆருடம் vs உதயம்" : "9. Arudam vs Udayam", aVsUStr),
          _buildNoteRow(isTa ? "10. ஆருடம் vs கவிப்பு" : "10. Arudam vs Kavippu", aVsKStr),
          _buildNoteRow(isTa ? "11. அஷ்டமாதிபதி" : "11. 8th Lord", eLordStr),
          _buildNoteRow(isTa ? "12. பாதகாதிபதி" : "12. Badhakadhipathi", bLordStr),
          _buildNoteRow(isTa ? "13. இராசிப் பரிவர்த்தனை" : "13. Rasi Parivarthanai", parivarthanaiStr),
          _buildNoteRow(isTa ? "14. சூட்சும ராசி" : "14. Sootchuma Rasi", sootchumaStr),
        ],
      ),
    );
  }

  Widget _buildNoteRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF5D1204),
                fontSize: 14,
              ),
            ),
          ),
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
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: isPrimary ? AppColors.primary : const Color(0xFF5D1204), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDasaView() {
    if (_results == null || _results!['inner'] == null || _results!['inner']['dasa'] == null) {
      return Center(child: Text(AppLocalizations.of(context)!.noDasaDetails));
    }
    
    final List<dynamic>? dasaList = _results!['inner']['dasa'];
    if (dasaList == null) return Center(child: Text(AppLocalizations.of(context)!.noDasaDetails));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 1. Dasa Section
          _buildDasaSection(AppLocalizations.of(context)!.dasaTitle, dasaList, _selectedDasa, (selected) {
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
            _buildDasaSection(AppLocalizations.of(context)!.bukthiTitle, _selectedDasa!['subPeriods'] ?? [], _selectedBukthi, (selected) {
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
            _buildDasaSection(AppLocalizations.of(context)!.antharamTitle, _selectedBukthi!['subPeriods'] ?? [], _selectedAntharam, (selected) {
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
            _buildDasaSection(AppLocalizations.of(context)!.sookshmamTitle, _selectedAntharam!['subPeriods'] ?? [], _selectedSookshmam, (selected) {
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
                  const TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text("No", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                  TableCell(child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(AppLocalizations.of(context)!.lord, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                  TableCell(child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(AppLocalizations.of(context)!.start, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
                  TableCell(child: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), child: Text(AppLocalizations.of(context)!.end, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
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
                      AstroTranslationService.translate(context, p['lord'] ?? "-", isPlanet: true), 
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

  String _formatDateOnly(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return "$d-$m-$y";
  }
}
