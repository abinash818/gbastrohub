import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/astro_data.dart';
import '../services/kp_service.dart';
import '../theme/app_colors.dart';
import '../services/astro_translation_service.dart';
import '../components/south_indian_chart.dart';
import '../components/custom_drawer.dart';
import 'panchangam_image_screen.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';
import '../services/astro_utils.dart';

class PanchangamScreen extends StatefulWidget {
  const PanchangamScreen({super.key});

  @override
  State<PanchangamScreen> createState() => _PanchangamScreenState();
}

class _PanchangamScreenState extends State<PanchangamScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _panchangamData;
  Map<String, dynamic>? _chartResults;
  bool _isLoading = true;

  static const List<List<String>> AMIRTHATHI_YOGAM_TABLE = [
    // Sun (0)
    ["S", "P", "S", "S", "S", "S", "S", "S", "S", "M", "S", "A", "S", "S", "S", "M", "M", "M", "A", "S", "A", "A", "M", "S", "S", "A", "A"],
    // Mon (1)
    ["S", "S", "M", "A", "S", "S", "A", "S", "S", "M", "S", "S", "S", "P", "A", "M", "S", "S", "S", "M", "M", "A", "S", "S", "S", "S", "S"],
    // Tue (2)
    ["S", "S", "S", "A", "S", "M", "S", "S", "S", "S", "S", "A", "S", "S", "S", "M", "S", "M", "A", "S", "P", "S", "S", "M", "M", "A", "S"],
    // Wed (3)
    ["M", "S", "A", "S", "S", "S", "S", "S", "S", "S", "A", "A", "M", "S", "S", "S", "S", "S", "M", "A", "A", "S", "P", "S", "A", "S", "M"],
    // Thu (4)
    ["A", "S", "M", "M", "M", "M", "A", "S", "S", "A", "S", "M", "S", "S", "A", "S", "S", "P", "S", "S", "S", "S", "S", "S", "M", "S", "S"],
    // Fri (5)
    ["A", "S", "S", "M", "S", "S", "S", "M", "M", "M", "S", "S", "A", "S", "S", "S", "S", "M", "A", "P", "S", "M", "S", "S", "S", "S", "S"],
    // Sat (6)
    ["S", "S", "S", "A", "S", "S", "S", "S", "M", "A", "S", "M", "M", "M", "S", "S", "S", "S", "S", "S", "S", "S", "S", "A", "M", "S", "P"]
  ];

  static const Map<String, String> YOGAM_NAMES = {
    "A": "amirtham",
    "S": "sitham",
    "M": "maranam",
    "P": "prabalarishtam",
  };

  static const Map<int, List<String>> _NETHRA_JEEVA_TABLE = {
    1: ["0", "0", "நடு"],
    2: ["0", "0", "நடு"],
    3: ["0", "1/2", "கிழக்கு"],
    4: ["0", "1/2", "கிழக்கு"],
    5: ["1", "1/2", "கிழக்கு"],
    6: ["1", "1/2", "தென்கிழக்கு"],
    7: ["1", "1/2", "தென்கிழக்கு"],
    8: ["1", "1/2", "தென்கிழக்கு"],
    9: ["2", "1/2", "தெற்கு"],
    10: ["2", "0", "தெற்கு"],
    11: ["2", "1", "தெற்கு"],
    12: ["2", "1", "தென்மேற்கு"],
    13: ["2", "1", "தென்மேற்கு"],
    14: ["2", "1", "தென்மேற்கு"],
    15: ["2", "1", "மேற்கு"],
    16: ["2", "1", "மேற்கு"],
    17: ["2", "1", "மேற்கு"],
    18: ["2", "1", "வடமேற்கு"],
    19: ["2", "0", "வடமேற்கு"],
    20: ["2", "1/2", "வடமேற்கு"],
    21: ["1", "1/2", "வடக்கு"],
    22: ["1", "1/2", "வடக்கு"],
    23: ["1", "1/2", "வடக்கு"],
    24: ["1", "1/2", "வடகிழக்கு"],
    25: ["0", "1/2", "வடகிழக்கு"],
    26: ["0", "1/2", "வடகிழக்கு"],
    27: ["0", "0", "நடு"],
  };

  @override
  void initState() {
    super.initState();
    _loadPanchangam();
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

  String _calculateBlockTime(int blockNum, DateTime sunrise, DateTime sunset) {
    try {
      double durationSeconds = sunset.difference(sunrise).inSeconds.toDouble();
      double blockSeconds = durationSeconds / 8.0;
      DateTime start = sunrise.add(Duration(seconds: ((blockNum - 1) * blockSeconds).toInt()));
      DateTime end = sunrise.add(Duration(seconds: (blockNum * blockSeconds).toInt()));
      return "${_formatTime(start)} - ${_formatTime(end)}";
    } catch (e) {
      return "-";
    }
  }

  String _formatTime(DateTime dt) {
    int h = dt.hour % 12;
    if (h == 0) h = 12;
    String m = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? "PM" : "AM";
    return "$h:$m $period";
  }

  Future<void> _loadPanchangam() async {
    setState(() => _isLoading = true);
    try {
      final results = await KPService.calculateChart("Panchangam", _selectedDate, 13.0827, 80.2707, 5.5);
      
      final sunLon = results['planet_details']['sun']['longitude'] as double;
      final moonLon = results['planet_details']['moon']['longitude'] as double;
      
      final sunNakIdx = (sunLon / (360.0 / 27.0)).floor() % 27;
      final moonNakIdx = (moonLon / (360.0 / 27.0)).floor() % 27;
      final moonRasiIdx = (moonLon / 30).floor() % 12;
      
      final count = (moonNakIdx - sunNakIdx + 27) % 27 + 1;
      final nethra = _NETHRA_JEEVA_TABLE[count]?[0] ?? "0";
      final jeeva = _NETHRA_JEEVA_TABLE[count]?[1] ?? "0";
      final vivaga = _NETHRA_JEEVA_TABLE[count]?[2] ?? "நடு";
      
      final weekdayIdx = _selectedDate.weekday == 7 ? 0 : _selectedDate.weekday;
      
      String amirthathiYogam = "sitham";
      if (weekdayIdx >= 0 && weekdayIdx <= 6 && moonNakIdx >= 0 && moonNakIdx < 27) {
        final code = AMIRTHATHI_YOGAM_TABLE[weekdayIdx][moonNakIdx];
        amirthathiYogam = YOGAM_NAMES[code] ?? "sitham";
      }
      
      const sulams = ["west", "east", "north", "north", "south", "west", "east"];
      const pariharams = ["jaggery", "curd", "milk", "milk", "oil", "jaggery", "curd"];
      final soolam = sulams[weekdayIdx];
      final pariharam = pariharams[weekdayIdx];
      
      final chandrashtamaRasiIdx = (moonRasiIdx - 7 + 12) % 12;
      final chandrashtama = AstroData.raasiList[chandrashtamaRasiIdx];
      
      List<String> chandrashtamaNats = [];
      for (String n in AstroData.natchathiraList) {
        if (AstroData.getRaasi(n, 1) == chandrashtama || AstroData.getRaasi(n, 2) == chandrashtama || AstroData.getRaasi(n, 3) == chandrashtama || AstroData.getRaasi(n, 4) == chandrashtama) {
          chandrashtamaNats.add(n);
        }
      }
      String chanNatsStr = chandrashtamaNats.join(", ");
      
      final year = _selectedDate.year;
      final month = _selectedDate.month;
      final day = _selectedDate.day;
      
      final pancha = results['panchangam'] as Map<String, dynamic>;

      final double diff = (moonLon - sunLon + 360) % 360;
      final bool isShukla = diff < 180.0;

      final ayanam = AstroUtils.getAyanam(sunLon);
      final season = AstroUtils.getSeason(sunLon);
      final panjaPatchi = AstroUtils.getPanchaPatchi(moonNakIdx, isShukla);

      final kaliYear = AstroUtils.calculateKaliYear(year, month, day);
      final salivahanaYear = AstroUtils.calculateSalivahanaYear(year, month, day);
      final pasaliYear = AstroUtils.calculatePasaliYear(year, month, day);
      final kollamYear = AstroUtils.calculateKollamYear(year, month, day, sunLongitude: sunLon);
      final hijriYear = AstroUtils.calculateHijriYear(year, month, day, tamilMonth: month, diff: diff);
      
      final sunriseStr = pancha['sunrise'] as String? ?? "06:00 AM";
      final sunsetStr = pancha['sunset'] as String? ?? "06:00 PM";
      final sunriseDt = _parseTimeString(sunriseStr, _selectedDate);
      final sunsetDt = _parseTimeString(sunsetStr, _selectedDate);
      
      final rahuDayMap = [8, 2, 7, 5, 6, 4, 3];
      final yemaDayMap = [5, 4, 3, 2, 1, 7, 6];
      final kuliDayMap = [7, 6, 5, 4, 3, 2, 1];
      
      final rahuBlock = rahuDayMap[weekdayIdx];
      final yemaBlock = yemaDayMap[weekdayIdx];
      final kuliBlock = kuliDayMap[weekdayIdx];
      
      final rahuTime = _calculateBlockTime(rahuBlock, sunriseDt, sunsetDt);
      final yemaTime = _calculateBlockTime(yemaBlock, sunriseDt, sunsetDt);
      final kuliTime = _calculateBlockTime(kuliBlock, sunriseDt, sunsetDt);

      final double durationSeconds = sunsetDt.difference(sunriseDt).inSeconds.toDouble();
      final double blockSeconds = durationSeconds / 8.0;

      final rahuStart = sunriseDt.add(Duration(seconds: ((rahuBlock - 1) * blockSeconds).toInt()));
      final rahuEnd = sunriseDt.add(Duration(seconds: (rahuBlock * blockSeconds).toInt()));
      final yemaStart = sunriseDt.add(Duration(seconds: ((yemaBlock - 1) * blockSeconds).toInt()));
      final yemaEnd = sunriseDt.add(Duration(seconds: (yemaBlock * blockSeconds).toInt()));

      final nallaNeram = _calculateDynamicNallaNeram(weekdayIdx, sunriseDt, sunsetDt, rahuStart, rahuEnd, yemaStart, yemaEnd);
      
      final endTimes = await KPService.calculateEndTimes(_selectedDate, 13.0827, 80.2707, 5.5);

      setState(() {
        _chartResults = results;
        _panchangamData = {
          ...pancha,
          'moon_rasi_idx': moonRasiIdx,
          'rasi': AstroData.raasiList[moonRasiIdx],
          'nethra': nethra,
          'jeeva': jeeva,
          'vivaga': vivaga,
          'amirthathi_yogam': amirthathiYogam,
          'soolam': soolam,
          'pariharam': pariharam,
          'ayanam': ayanam,
          'season': season,
          'panja_patchi': panjaPatchi,
          'chandrashtama': chandrashtama,
          'chandrashtama_nats': chanNatsStr,
          'hijri_year': hijriYear,
          'pasali_year': pasaliYear,
          'salivahana_year': salivahanaYear,
          'kollam_year': kollamYear,
          'kali_year': kaliYear,
          'rahukalam': rahuTime,
          'yemagandam': yemaTime,
          'kuligai': kuliTime,
          'nalla_neram': nallaNeram,
          'tithi_end': endTimes['tithi_end'],
          'nakshatra_end': endTimes['nakshatra_end'],
          'yoga_end': endTimes['yoga_end'],
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Panchangam Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Map<String, List<String>> _castChartMap(dynamic data) {
    if (data == null) return {};
    final result = <String, List<String>>{};
    if (data is Map) {
      data.forEach((key, val) {
        if (val is List) {
          result[key.toString()] = val.map((e) => e.toString()).toList();
        }
      });
    }
    return result;
  }

  static const Map<int, List<_NallaNeramSlot>> NALLA_NERAM_DEFAULTS = {
    7: [_NallaNeramSlot(1.5, 3.0), _NallaNeramSlot(10.5, 12.0)],
    1: [_NallaNeramSlot(0.25, 1.25), _NallaNeramSlot(9.25, 10.25)],
    2: [_NallaNeramSlot(1.5, 2.5), _NallaNeramSlot(10.5, 11.5)],
    3: [_NallaNeramSlot(3.25, 4.25), _NallaNeramSlot(10.75, 11.75)],
    4: [_NallaNeramSlot(4.75, 5.75), _NallaNeramSlot(6.25, 7.25)],
    5: [_NallaNeramSlot(3.25, 4.25), _NallaNeramSlot(10.75, 11.75)],
    6: [_NallaNeramSlot(1.5, 2.5), _NallaNeramSlot(4.75, 5.75)],
  };

  String _calculateDynamicNallaNeram(int weekday, DateTime sunriseDt, DateTime sunsetDt, DateTime rahuStart, DateTime rahuEnd, DateTime yemaStart, DateTime yemaEnd) {
    final slots = NALLA_NERAM_DEFAULTS[weekday] ?? [];
    List<_TimeRange> currentRanges = [];
    for (final slot in slots) {
      final start = sunriseDt.add(Duration(minutes: (slot.startOffset * 60).toInt()));
      final end = sunriseDt.add(Duration(minutes: (slot.endOffset * 60).toInt()));
      currentRanges.add(_TimeRange(start, end));
    }
    
    currentRanges = _subtractExclusion(currentRanges, _TimeRange(rahuStart, rahuEnd));
    currentRanges = _subtractExclusion(currentRanges, _TimeRange(yemaStart, yemaEnd));
    currentRanges = currentRanges.where((r) => r.end.difference(r.start).inMinutes >= 5).toList();
    
    if (currentRanges.isEmpty) return "notToday";
    return currentRanges.map((r) => "${_formatTime(r.start)} - ${_formatTime(r.end)}").join(",\n");
  }
  
  List<_TimeRange> _subtractExclusion(List<_TimeRange> currentRanges, _TimeRange ex) {
    List<_TimeRange> result = [];
    for (final r in currentRanges) {
      if (ex.end.isBefore(r.start) || ex.start.isAfter(r.end) || ex.end == r.start || ex.start == r.end) {
        result.add(r);
      } else if ((ex.start.isBefore(r.start) || ex.start == r.start) && (ex.end.isAfter(r.end) || ex.end == r.end)) {
        // completely covered
      } else if (ex.start.isBefore(r.start) && ex.end.isBefore(r.end)) {
        result.add(_TimeRange(ex.end, r.end));
      } else if (ex.start.isAfter(r.start) && ex.end.isAfter(r.end)) {
        result.add(_TimeRange(r.start, ex.start));
      } else {
        if (r.start.isBefore(ex.start)) {
          result.add(_TimeRange(r.start, ex.start));
        }
        if (ex.end.isBefore(r.end)) {
          result.add(_TimeRange(ex.end, r.end));
        }
      }
    }
    return result;
  }

  String _getEnglishPlanetName(String pKey) {
    switch (pKey) {
      case "lagna": return "Lagna";
      case "sun": return "Sun";
      case "moon": return "Moon";
      case "mars": return "Mars";
      case "mercury": return "Mercury";
      case "jupiter": return "Jupiter";
      case "venus": return "Venus";
      case "saturn": return "Saturn";
      case "rahu": return "Rahu";
      case "ketu": return "Ketu";
      case "maanthi": return "Maanthi";
      default: return "";
    }
  }

  Future<void> _sharePanchangam() async {
    if (_panchangamData == null || _chartResults == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PanchangamImageScreen(
          panchangamData: _panchangamData!,
          selectedDate: _selectedDate,
          chartResults: _chartResults,
        ),
      ),
    );
  }

  void _changeDateBy(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadPanchangam();
  }

  void _setToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadPanchangam();
  }

  @override
  Widget build(BuildContext context) {
    String dayInTamil = AstroData.daysInTamil[DateFormat('EEEE').format(_selectedDate)] ?? '';
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final bool isWide = MediaQuery.of(context).size.width > 900;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF6EE),
        appBar: isWide ? null : AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: AppColors.primary.withOpacity(0.08),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                }
              },
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.panchangamTitle,
            style: GoogleFonts.outfit(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded, color: AppColors.primary),
              onPressed: _sharePanchangam,
              tooltip: 'பஞ்சாங்கம் பகிர் (Share Poster)',
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryLight,
            indicatorWeight: 3.5,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
            tabs: [
              Tab(text: "விவரம் (Details)"),
              Tab(text: "கோச்சாரம் (Chart)"),
            ],
          ),
        ),
        drawer: isWide ? null : const CustomDrawer(),
        body: SafeArea(
          child: Row(
            children: [
              if (isWide)
                const SizedBox(
                  width: 280,
                  child: CustomDrawer(),
                ),
              Expanded(
                child: isWide 
                  ? Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: TabBar(
                                  labelColor: AppColors.primary,
                                  unselectedLabelColor: AppColors.textSecondary,
                                  indicatorColor: AppColors.primaryLight,
                                  indicatorWeight: 3.5,
                                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
                                  tabs: [
                                    Tab(text: "விவரம் (Details)"),
                                    Tab(text: "கோச்சாரம் (Chart)"),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_rounded, color: AppColors.primary),
                                onPressed: _sharePanchangam,
                                tooltip: 'பஞ்சாங்கம் பகிர் (Share Poster)',
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildPanchangamBody(formattedDate, dayInTamil),
                        ),
                      ],
                    )
                  : _buildPanchangamBody(formattedDate, dayInTamil),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _sharePanchangam,
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFFFFD54F),
          icon: const Icon(Icons.image_rounded),
          label: Text("போஸ்டர் பகிர்", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildPanchangamBody(String formattedDate, String dayInTamil) {
    return Column(
      children: [
        // Modern Date Navigator Hero Card
        _buildHeroDateNavigator(formattedDate, dayInTamil),

        // Tabs Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: TabBarView(
                      children: [
                        _buildVivaramTab(),
                        _buildKattamTab(),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HERO DATE NAVIGATOR
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildHeroDateNavigator(String formattedDate, String dayInTamil) {
    final p = _panchangamData;
    String tamilYear = p?['tamil_year'] != null ? "${p!['tamil_year']}" : "ஸ்ரீ குரோதி";
    String tamilMonth = p?['tamil_month'] != null ? "${p!['tamil_month']}" : "";
    String tamilDate = p?['tamil_date'] != null ? "${p!['tamil_date']}" : "";
    String ayanam = p?['ayanam'] ?? '';
    String season = p?['season'] ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Navigator Row
                Row(
                  children: [
                    // Previous Day Button
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 16, color: AppColors.primary),
                      onPressed: () => _changeDateBy(-1),
                      tooltip: 'முந்தைய நாள்',
                    ),
                    
                    // Date & Day Display (Clickable for DatePicker)
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  onSurface: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                            _loadPanchangam();
                          }
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.calendar_month_rounded, size: 17, color: AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedDate,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 17,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "| ${AstroTranslationService.translate(context, dayInTamil)}",
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (tamilMonth.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "$tamilYear வருடம் • $tamilMonth $tamilDate",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Next Day Button
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                      onPressed: () => _changeDateBy(1),
                      tooltip: 'அடுத்த நாள்',
                    ),

                    const SizedBox(width: 4),

                    // Today Quick Button
                    InkWell(
                      onTap: _setToday,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          "இன்று",
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Ayana & Rutu Badges if available
                if (ayanam.isNotEmpty || season.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (ayanam.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFFB74D)),
                            ),
                            child: Text(
                              ayanam,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                            ),
                          ),
                        if (ayanam.isNotEmpty && season.isNotEmpty)
                          const SizedBox(width: 6),
                        if (season.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF81C784)),
                            ),
                            child: Text(
                              season,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 1: VIVARAM (DETAILS)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildVivaramTab() {
    if (_panchangamData == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noDataAvailable,
          style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 16),
        ),
      );
    }

    final p = _panchangamData!;
    final bool isWide = MediaQuery.of(context).size.width > 900;

    // 1. Five Limbs of Panchangam (பஞ்ச அங்கங்கள்)
    final fiveLimbsCard = _buildFiveLimbsCard(p);

    // 2. Auspicious & Inauspicious Timings Card (முக்கிய நேரங்கள்)
    final timingsCard = _buildAuspiciousTimingsCard(p);

    // 3. Moon & Chandrashtama Card (சந்திரன் விபரம்)
    final moonCard = _buildMoonAndChandrashtamaCard(p);

    // 4. Special Vedic Details Card (விசேஷ விபரங்கள்)
    final specialCard = _buildSpecialVedicCard(p);

    // 5. Horai & Gowri Live Timeline (ஹோரை & கௌரி)
    final horaiGowriCard = _buildLiveHoraiGowriSection(p);

    // 6. Vedic Epoch Years Card (ஆண்டுகள்)
    final epochYearsCard = _buildEpochYearsCard(p);

    if (isWide) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  fiveLimbsCard,
                  timingsCard,
                  epochYearsCard,
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  moonCard,
                  specialCard,
                  horaiGowriCard,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Column(
        children: [
          fiveLimbsCard,
          timingsCard,
          moonCard,
          specialCard,
          horaiGowriCard,
          epochYearsCard,
        ],
      ),
    );
  }

  // 1. FIVE LIMBS OF PANCHANGAM GRID
  Widget _buildFiveLimbsCard(Map<String, dynamic> p) {
    String varaTamil = AstroUtils.getTamilNakshatra(p['vara'] ?? '');
    String paksham = p['paksham'] ?? 'வளர்பிறை';
    String tithi = AstroUtils.getTamilTithi(p['tithi'] ?? '-');
    String tEnd = p['tithi_end'] != null ? "${p['tithi_end']} வரை" : "-";
    String nakshatra = AstroUtils.getTamilNakshatra(p['nakshatra'] ?? '-');
    String nEnd = p['nakshatra_end'] != null ? "${p['nakshatra_end']} வரை" : "-";
    String yoga = AstroUtils.getTamilYoga(p['yoga'] ?? '-');
    String yEnd = p['yoga_end'] != null ? "${p['yoga_end']} வரை" : "-";
    String karana = AstroUtils.getTamilKarana(p['karana'] ?? '-');

    return _buildStyledCard(
      title: "🌟 பஞ்சாங்க அங்கங்கள் (5 Pillars)",
      icon: Icons.auto_awesome,
      children: [
        // Grid of 5 Elements
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            _buildLimbTile("📅 கிழமை (Vara)", varaTamil, p['day_lord'] != null ? "அதிபதி: ${p['day_lord']}" : "சுப வாரம்"),
            _buildLimbTile("🌙 திதி (Tithi)", tithi, "$paksham • $tEnd"),
            _buildLimbTile("⭐ நட்சத்திரம் (Star)", nakshatra, nEnd),
            _buildLimbTile("🔮 யோகம் (Yoga)", yoga, yEnd),
          ],
        ),
        const SizedBox(height: 8),
        _buildLimbTile("⚡ கரணம் (Karana)", karana, "இன்றைய கரணம்", fullWidth: true),
      ],
    );
  }

  Widget _buildLimbTile(String label, String value, String subtext, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.primaryDark, fontSize: 10.5, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 13.5, fontWeight: FontWeight.w900),
              maxLines: 1,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              subtext,
              style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 9.5, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 2. AUSPICIOUS & INAUSPICIOUS TIMINGS
  Widget _buildAuspiciousTimingsCard(Map<String, dynamic> p) {
    String nallaNeram = (p['nalla_neram'] ?? "-").replaceAll(',\n', ', ');
    String rahuKalam = p['rahukalam'] ?? "-";
    String yemaGandam = p['yemagandam'] ?? "-";
    String kuliGai = p['kuligai'] ?? "-";
    String sunrise = p['sunrise'] ?? "06:00 AM";
    String sunset = p['sunset'] ?? "06:00 PM";

    return _buildStyledCard(
      title: "⏰ முக்கிய நேரங்கள் (Daily Timings)",
      icon: Icons.schedule_rounded,
      children: [
        // Sunrise & Sunset Pill Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFD54F)),
          ),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wb_sunny_rounded, size: 15, color: Color(0xFFE65100)),
                      const SizedBox(width: 4),
                      Text("உதயம்: $sunrise", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 16, color: Colors.orange.shade300, margin: const EdgeInsets.symmetric(horizontal: 4)),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.nightlight_round, size: 15, color: Color(0xFF1565C0)),
                      const SizedBox(width: 4),
                      Text("அஸ்தமனம்: $sunset", style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Nalla Neram (Auspicious)
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF81C784)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("நல்ல நேரம் (Auspicious Time)", style: TextStyle(color: Color(0xFF1B5E20), fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(nallaNeram, style: GoogleFonts.outfit(color: const Color(0xFF2E7D32), fontSize: 13.5, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Inauspicious Grid (Rahu, Yemagandam, Kuligai)
        Row(
          children: [
            Expanded(
              child: _buildInauspiciousPill("ராகு காலம்", rahuKalam, const Color(0xFFFFEBEE), const Color(0xFFC62828)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildInauspiciousPill("எமகண்டம்", yemaGandam, const Color(0xFFFFEBEE), const Color(0xFFC62828)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildInauspiciousPill("குளிகை", kuliGai, const Color(0xFFFFF3E0), const Color(0xFFE65100)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInauspiciousPill(String title, String time, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textCol.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title, style: TextStyle(color: textCol, fontSize: 10.5, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              style: GoogleFonts.outfit(color: textCol, fontSize: 11, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // 3. MOON & CHANDRASHTAMA
  Widget _buildMoonAndChandrashtamaCard(Map<String, dynamic> p) {
    String moonRasi = AstroTranslationService.translate(context, p['rasi'] ?? "-");
    String chandrashtama = AstroTranslationService.translate(context, p['chandrashtama'] ?? "-");
    String chandrashtamaNats = p['chandrashtama_nats'] ?? "";

    return _buildStyledCard(
      title: "🌕 சந்திரன் & சந்திராஷ்டமம்",
      icon: Icons.brightness_3_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("இன்றைய சந்திர ராசி", style: TextStyle(color: Color(0xFF1565C0), fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(moonRasi, style: GoogleFonts.outfit(color: const Color(0xFF0D47A1), fontSize: 15, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEF9A9A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("சந்திராஷ்டம ராசி", style: TextStyle(color: Color(0xFFC62828), fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(chandrashtama, style: GoogleFonts.outfit(color: const Color(0xFFB71C1C), fontSize: 15, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (chandrashtamaNats.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: Colors.orange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "சந்திராஷ்டம நட்சத்திரங்கள்: $chandrashtamaNats",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 4. SPECIAL VEDIC DETAILS
  Widget _buildSpecialVedicCard(Map<String, dynamic> p) {
    String amirthathi = AstroUtils.getAmirthathiYogamTamil(p['amirthathi_yogam'] ?? 'sitham');
    String nethra = p['nethra'] ?? "2";
    String jeeva = p['jeeva'] ?? "1";
    String vivaga = p['vivaga'] ?? "வடமேற்கு";
    String panjaPatchi = p['panja_patchi'] ?? "வல்லூறு";
    String soolam = AstroUtils.getSoolamTamil(p['soolam'] ?? 'north');
    String pariharam = AstroUtils.getPariharamTamil(p['pariharam'] ?? 'milk');

    return _buildStyledCard(
      title: "🔮 விசேஷ கணிதங்கள் (Vedic Special)",
      icon: Icons.psychology_rounded,
      children: [
        _buildRowItem("அமிர்தாதி யோகம்", amirthathi, isGreen: true),
        _buildDivider(),
        _buildRowItem("நேத்திரம் / ஜீவன்", "$nethra / $jeeva"),
        _buildDivider(),
        _buildRowItem("விவாகச் சக்கரம்", vivaga),
        _buildDivider(),
        _buildRowItem("பஞ்சபட்சி", panjaPatchi),
        _buildDivider(),
        _buildRowItem("சூலம் & பரிகாரம்", "$soolam (பரிகாரம்: $pariharam)"),
      ],
    );
  }

  // 5. LIVE HORAI & GOWRI TIMELINE
  Widget _buildLiveHoraiGowriSection(Map<String, dynamic> p) {
    String sunriseStr = p['sunrise'] ?? "06:00 AM";
    String sunsetStr = p['sunset'] ?? "06:00 PM";
    DateTime sunrise = _parseTimeString(sunriseStr, _selectedDate);
    DateTime sunset = _parseTimeString(sunsetStr, _selectedDate);

    int weekday = _selectedDate.weekday % 7;
    int dayLordIdx = [0, 3, 6, 2, 5, 1, 4][weekday];
    
    double dayTotalMins = sunset.difference(sunrise).inMinutes.toDouble();
    if (dayTotalMins <= 0) dayTotalMins = 720.0;
    double gowriSlot = dayTotalMins / 8.0;
    double horaiSlot = dayTotalMins / 12.0;

    DateTime now = DateTime.now();
    bool isSameDay = now.year == _selectedDate.year && now.month == _selectedDate.month && now.day == _selectedDate.day;

    List<Widget> horaiWidgets = [];
    for (int i = 0; i < 12; i++) {
      int hIdx = (dayLordIdx + i) % 7;
      DateTime start = sunrise.add(Duration(minutes: (i * horaiSlot).toInt()));
      DateTime end = sunrise.add(Duration(minutes: ((i + 1) * horaiSlot).toInt()));
      bool isSuba = (hIdx == 1 || hIdx == 2 || hIdx == 3 || hIdx == 5);
      bool isCurrent = isSameDay && now.isAfter(start) && now.isBefore(end);

      horaiWidgets.add(
        _buildTimeSlotTile(
          "${_formatTime(start)} - ${_formatTime(end)}",
          HORA_NAMES[hIdx],
          isSuba: isSuba,
          isCurrent: isCurrent,
        ),
      );
    }

    int rahuSegment = [7, 1, 6, 4, 5, 3, 2][weekday];
    List<Widget> gowriWidgets = [];
    for (int i = 0; i < 8; i++) {
      int gIdx = GOWRI_DAY_SEQ[weekday]![i];
      if (i == rahuSegment) {
        gIdx = 7;
      }
      DateTime start = sunrise.add(Duration(minutes: (i * gowriSlot).toInt()));
      DateTime end = sunrise.add(Duration(minutes: ((i + 1) * gowriSlot).toInt()));
      bool isGood = gIdx <= 4;
      bool isCurrent = isSameDay && now.isAfter(start) && now.isBefore(end);

      gowriWidgets.add(
        _buildTimeSlotTile(
          "${_formatTime(start)} - ${_formatTime(end)}",
          GOWRI_TYPES[gIdx],
          isSuba: isGood,
          isCurrent: isCurrent,
        ),
      );
    }

    return _buildStyledCard(
      title: "🕒 சுப ஹோரை & நல்ல கௌரி நேரங்கள்",
      icon: Icons.timelapse_rounded,
      children: [
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.primary,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: "பகல் ஹோரை"),
                    Tab(text: "நல்ல கௌரி"),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 280,
                child: TabBarView(
                  children: [
                    ListView(physics: const BouncingScrollPhysics(), children: horaiWidgets),
                    ListView(physics: const BouncingScrollPhysics(), children: gowriWidgets),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotTile(String time, String name, {required bool isSuba, required bool isCurrent}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFFE8F5E9)
            : isSuba
                ? Colors.white
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF2E7D32)
              : isSuba
                  ? AppColors.primaryLight.withOpacity(0.3)
                  : Colors.grey.shade200,
          width: isCurrent ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isCurrent) ...[
                const Icon(Icons.radio_button_checked_rounded, color: Color(0xFF2E7D32), size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                time,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? const Color(0xFF1B5E20) : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (isCurrent)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text("இப்போது", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isSuba ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. EPOCH YEARS CARD
  Widget _buildEpochYearsCard(Map<String, dynamic> p) {
    return _buildStyledCard(
      title: "📜 பஞ்சாங்க பிற ஆண்டுகள் (Epoch Years)",
      icon: Icons.history_edu_rounded,
      children: [
        _buildRowItem("கலியுக ஆண்டு", "${p['kali_year'] ?? '-'}"),
        _buildDivider(),
        _buildRowItem("சாலிவாகன சகாப்தம்", "${p['salivahana_year'] ?? '-'}"),
        _buildDivider(),
        _buildRowItem("பசலி ஆண்டு", "${p['pasali_year'] ?? '-'}"),
        _buildDivider(),
        _buildRowItem("கொல்லம் ஆண்டு", "${p['kollam_year'] ?? '-'}"),
        _buildDivider(),
        _buildRowItem("ஹிஜ்ரி ஆண்டு", "${p['hijri_year'] ?? '-'}"),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // TAB 2: KATTAM (CHART)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildKattamTab() {
    if (_chartResults == null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.rasiChartDataNotAvailable,
          style: GoogleFonts.outfit(color: AppColors.primary, fontSize: 16),
        ),
      );
    }

    const List<String> planetsOrder = [
      "lagna", "sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu", "ketu", "maanthi"
    ];
    final planetDetails = _chartResults!['planet_details'] as Map<String, dynamic>;
    
    final bool isWide = MediaQuery.of(context).size.width > 900;

    final chartWidget = Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: SouthIndianChart(
          rasiMap: _castChartMap(_chartResults!['rasi']),
          centerLabel: "கோச்சார\nராசி",
        ),
      ),
    );

    final positionsWidget = _buildStyledCard(
      title: AppLocalizations.of(context)!.planetaryPositionsTitle,
      icon: Icons.blur_on_rounded,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: planetsOrder.length,
          separatorBuilder: (context, index) => _buildDivider(),
          itemBuilder: (context, index) {
            final pKey = planetsOrder[index];
            final details = planetDetails[pKey];
            if (details == null) return const SizedBox();

            final engName = _getEnglishPlanetName(pKey);
            final isRetro = engName.isNotEmpty && engName != "Lagna" && (_chartResults?['planet_info']?[engName]?['isRetro'] ?? false);
            
            final tamilName = AstroTranslationService.translate(context, KPService.TAMIL_PLANETS[engName] ?? (pKey == "lagna" ? AppLocalizations.of(context)!.lagna : pKey), isPlanet: true);
            final rasiNameEnglish = details['rasi'] as String? ?? "Aries";
            final rasiNameTamil = AstroTranslationService.translate(context, KPService.TAMIL_SIGNS[rasiNameEnglish] ?? rasiNameEnglish);
            
            final nakName = AstroTranslationService.translate(context, details['nakshatra'] as String? ?? "-");
            final padaStr = (details['pada'] ?? "-").toString();
            final padaWord = AstroTranslationService.translate(context, "Pada");
            final pada = "$padaStr $padaWord";
            final totalDeg = (details['longitude'] ?? 0.0) as double;
            final formattedDeg = KPService.formatDegrees(totalDeg);

            return _buildPlanetRow(tamilName, rasiNameTamil, nakName, pada, formattedDeg, isRetro);
          },
        ),
      ],
    );

    if (isWide) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: chartWidget),
            const SizedBox(width: 16),
            Expanded(flex: 6, child: positionsWidget),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Column(
        children: [
          chartWidget,
          const SizedBox(height: 12),
          positionsWidget,
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REUSABLE UI HELPERS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildStyledCard({required String title, required List<Widget> children, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primaryLight),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value, {bool isGreen = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isGreen ? const Color(0xFF2E7D32) : (valueColor ?? AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetRow(String name, String rasi, String nakshatra, String pada, String deg, bool isRetro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (isRetro) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.retrograde,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "$rasi • $nakshatra • $pada",
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            deg,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 12, color: AppColors.primaryLight.withOpacity(0.12));
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

class _NallaNeramSlot {
  final double startOffset;
  final double endOffset;
  const _NallaNeramSlot(this.startOffset, this.endOffset);
}

class _TimeRange {
  final DateTime start;
  final DateTime end;
  _TimeRange(this.start, this.end);
}
