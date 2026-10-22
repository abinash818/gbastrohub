import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/kp_service.dart';
import '../services/astro_special_calculations_service.dart';
import '../services/temple_worship_service.dart';
import '../services/astro_translation_service.dart';
import '../components/custom_drawer.dart';

class AstroToolsScreen extends StatefulWidget {
  const AstroToolsScreen({super.key});

  @override
  State<AstroToolsScreen> createState() => _AstroToolsScreenState();
}

class _AstroToolsScreenState extends State<AstroToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Nazhigai Converter State
  final TextEditingController _hoursController = TextEditingController(text: "10");
  final TextEditingController _minutesController = TextEditingController(text: "30");
  final TextEditingController _secondsController = TextEditingController(text: "00");
  String _calculatedNazhigai = "26 நாழிகை, 15 விநாழிகை";

  final TextEditingController _nazhigaiInputController = TextEditingController(text: "26");
  final TextEditingController _vinazhigaiInputController = TextEditingController(text: "15");
  String _calculatedHours = "10 மணி 30 நிமிடம் 0 வினாடி";

  // 2. Pancha Pakshi State
  int _selectedNakshatraIdx = 0;
  bool _isShuklaPaksha = true;
  int _selectedWeekday = DateTime.now().weekday; // 1=Mon... 7=Sun

  // 3. Sub-Hora State
  int _horaWeekday = DateTime.now().weekday;
  TimeOfDay _sunriseTime = const TimeOfDay(hour: 6, minute: 0);

  // 5. Karma / Marabu Nakshatras State
  String _selectedKarmaLookupNakshatra = "அசுவனி";

  // 6. Temple Worship Directories State
  final TextEditingController _templeSearchController = TextEditingController();
  String _templeSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _recalcHoursToNazhigai();
    _recalcNazhigaiToHours();
  }

  void _recalcHoursToNazhigai() {
    double h = double.tryParse(_hoursController.text) ?? 0.0;
    double m = double.tryParse(_minutesController.text) ?? 0.0;
    double s = double.tryParse(_secondsController.text) ?? 0.0;
    double totalHours = h + (m / 60.0) + (s / 3600.0);

    final res = AstroSpecialCalculationsService.convertHoursToNazhigai(totalHours);
    setState(() {
      _calculatedNazhigai = res['formatted'];
    });
  }

  void _recalcNazhigaiToHours() {
    int n = int.tryParse(_nazhigaiInputController.text) ?? 0;
    int v = int.tryParse(_vinazhigaiInputController.text) ?? 0;
    double totalHours = AstroSpecialCalculationsService.convertNazhigaiToHours(n, v);

    int h = totalHours.floor();
    double remM = (totalHours - h) * 60.0;
    int m = remM.floor();
    int s = ((remM - m) * 60.0).round();

    setState(() {
      _calculatedHours = "$h மணி $m நிமிடம் $s வினாடி";
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _nazhigaiInputController.dispose();
    _vinazhigaiInputController.dispose();
    _templeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "ஜோதிடக் கருவிகள் (Astro Tools)",
          style: GoogleFonts.cinzel(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: const Color(0xFF5D1204).withOpacity(0.5),
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13.5),
          tabs: const [
            Tab(text: "நாழிகை மாற்றி", icon: Icon(Icons.access_time_rounded)),
            Tab(text: "பஞ்ச பட்சி", icon: Icon(Icons.flutter_dash_rounded)),
            Tab(text: "ஹோரை / உப-ஹோரை", icon: Icon(Icons.grid_view_rounded)),
            Tab(text: "தசா நாதனின் நால்வர்", icon: Icon(Icons.people_alt_rounded)),
            Tab(text: "மரபு நட்சத்திரங்கள்", icon: Icon(Icons.hub_rounded)),
            Tab(text: "வழிபாட்டுத் தலங்கள்", icon: Icon(Icons.temple_hindu_rounded)),
          ],
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
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNazhigaiConverterTab(),
                _buildPanchaPakshiTab(),
                _buildSubHoraTab(),
                _buildDasaNalvarToolTab(),
                _buildKarmaNakshatrasTab(),
                _buildTempleWorshipDirectoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 1: நாழிகை ⟷ மணி மாற்றி
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildNazhigaiConverterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            children: [
              // Card 1: Hours to Nazhigai
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.hourglass_bottom_rounded, color: AppColors.primary, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "மணி நேரம் ➔ நாழிகை மாற்றி",
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _hoursController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "மணி (Hrs)", border: OutlineInputBorder()),
                              onChanged: (_) => _recalcHoursToNazhigai(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _minutesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "நிமிடம் (Min)", border: OutlineInputBorder()),
                              onChanged: (_) => _recalcHoursToNazhigai(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _secondsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "வினாடி (Sec)", border: OutlineInputBorder()),
                              onChanged: (_) => _recalcHoursToNazhigai(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFB58D3D)),
                        ),
                        child: Column(
                          children: [
                            const Text("கணக்கிடப்பட்ட நாழிகை அளவு:", style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              _calculatedNazhigai,
                              style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Card 2: Nazhigai to Hours
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_rounded, color: AppColors.primary, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "நாழிகை ➔ மணி நேரம் மாற்றி",
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nazhigaiInputController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "நாழிகை (Nazhigai)", border: OutlineInputBorder()),
                              onChanged: (_) => _recalcNazhigaiToHours(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _vinazhigaiInputController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "விநாழிகை (Vinazhigai)", border: OutlineInputBorder()),
                              onChanged: (_) => _recalcNazhigaiToHours(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFB58D3D)),
                        ),
                        child: Column(
                          children: [
                            const Text("கணக்கிடப்பட்ட மணி நேரம்:", style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              _calculatedHours,
                              style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "விதிமுறை குறிப்பு: 1 நாள் = 60 நாழிகை = 24 மணி நேரம். 1 மணி = 2.5 நாழிகை. 1 நாழிகை = 24 நிமிடங்கள் = 60 விநாழிகை.",
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 2: பஞ்ச பட்சி காலம்
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildPanchaPakshiTab() {
    double sampleMoonLon = (_selectedNakshatraIdx * (360.0 / 27.0)) + 5.0;
    final now = DateTime.now();
    DateTime sunriseDt = DateTime(now.year, now.month, now.day, 6, 0);

    final pakshiData = AstroSpecialCalculationsService.calculatePanchaPakshi(
      nakshatraIdx: _selectedNakshatraIdx,
      moonLon: sampleMoonLon,
      currentDt: now,
      sunrise: sunriseDt,
      isShuklaPaksha: _isShuklaPaksha,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("நட்சத்திரம் & பக்ஷம் தேர்வு", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedNakshatraIdx,
                        decoration: const InputDecoration(labelText: "பிறந்த / தற்போதைய நட்சத்திரம்", border: OutlineInputBorder()),
                        items: List.generate(27, (idx) {
                          return DropdownMenuItem(
                            value: idx,
                            child: Text("${idx + 1}. ${AstroSpecialCalculationsService.TAMIL_NAKSHATRAS[idx]}"),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedNakshatraIdx = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          const Text("பக்ஷம்: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          ChoiceChip(
                            label: const Text("வளர்பிறை (சுக்ல)"),
                            selected: _isShuklaPaksha,
                            onSelected: (val) => setState(() => _isShuklaPaksha = true),
                          ),
                          ChoiceChip(
                            label: const Text("தேய்பிறை (கிருஷ்ண)"),
                            selected: !_isShuklaPaksha,
                            onSelected: (val) => setState(() => _isShuklaPaksha = false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Current Status
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: pakshiData['is_favorable'] == true 
                          ? [Colors.green.shade800, Colors.green.shade600]
                          : [Colors.orange.shade900, Colors.orange.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "உங்கள் பட்சி: ${pakshiData['pakshi']}",
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const Divider(color: Colors.white30, height: 24),
                      Text(
                        "தற்போதைய தொழில்: ${pakshiData['current_activity']}",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pakshiData['activity_description'] ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 3: ஹோரை & உள்-ஹோரை அட்டவணை
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSubHoraTab() {
    final now = DateTime.now();
    DateTime sunriseDt = DateTime(now.year, now.month, now.day, _sunriseTime.hour, _sunriseTime.minute);
    final horaTable = AstroSpecialCalculationsService.getHoraAndSubHoraTable(_horaWeekday, sunriseDt);

    const List<String> weekdays = ["திங்கள்", "செவ்வாய்", "புதன்", "வியாழன்", "வெள்ளி", "சனி", "ஞாயிறு"];

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Weekday
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("கிழமை: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204))),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _horaWeekday,
                      isDense: true,
                      items: List.generate(7, (idx) {
                        return DropdownMenuItem(
                          value: idx + 1,
                          child: Text(weekdays[idx], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204))),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => _horaWeekday = val);
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Sunrise Picker
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _sunriseTime,
                    helpText: "சூரிய உதயம் நேரம் தேர்ந்தெடுக்கவும்",
                  );
                  if (picked != null) {
                    setState(() => _sunriseTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    border: Border.all(color: const Color(0xFFB58D3D)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wb_sunny_rounded, size: 15, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "உதயம்: ${_sunriseTime.hour.toString().padLeft(2, '0')}:${_sunriseTime.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF5D1204)),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.edit, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: horaTable.length,
            itemBuilder: (context, index) {
              final item = horaTable[index];
              final subHoras = item['sub_horas'] as List;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text("${item['hora_number']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                    "${item['start_time']} - ${item['end_time']}  |  ${item['lord_tamil']} ஹோரை",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text("5 உள்-ஹோரைகளைப் பார்க்க கிளிக் செய்க", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFFAF6EE),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "உள்-ஹோரைகள் (தலா 12 நிமிடங்கள்):",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204)),
                              ),
                              Text(
                                "${item['lord_tamil']} ஓரை",
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...subHoras.map((subItem) {
                            final sNum = subItem is Map ? subItem['sub_number'] : 0;
                            final sName = subItem is Map ? subItem['lord_tamil'] : subItem.toString();
                            final sTime = subItem is Map ? subItem['time_range'] : '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.35)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF5D1204),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "$sNum",
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "$sName உப ஓரை",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204)),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF6EE),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      sTime,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. தசா நாதனின் நால்வர் (Dasa Nalvar Tool)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildDasaNalvarToolTab() {
    final list = AstroSpecialCalculationsService.getAllDasaNalvarMasterList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D1204), Color(0xFF8B2500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D1204).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.people_alt_rounded, color: Colors.amber, size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "தசா நாதனின் நால்வர் அட்டவணை",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "ஒரு தசை நடக்கும் போது அந்த தசா நாதனுடன் இணைந்து செயல்படும் நான்கு முக்கிய கிரகங்கள்:\n"
                  "• போதகன்: நன்மைகளை போதிப்பவர் / வழிகாட்டுபவர் (பச்சை)\n"
                  "• வேதகன்: தடைகள் / சோதனைகளை உருவாக்குபவர் (சிகப்பு)\n"
                  "• பாசகன்: ஈர்ப்பு / பற்றுதலை ஏற்படுத்துபவர் (ஆரஞ்சு)\n"
                  "• காரகன்: காரகத்துவங்களை நிறைவேற்றுபவர் (நீலம்)",
                  style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Master Table
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  color: const Color(0xFF5D1204),
                  child: const Text(
                    "9 கிரகங்களின் நால்வர் அட்டவணை (Dasa Nalvar Matrix)",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ),
                Table(
                  border: TableBorder.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 0.8),
                  columnWidths: const {
                    0: FlexColumnWidth(1.3),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(1.2),
                    4: FlexColumnWidth(1.2),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFFAF0DC)),
                      children: const [
                        TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2), child: Text("தசை", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.w900, fontSize: 12)))),
                        TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2), child: Text("போதகன்", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w900, fontSize: 12)))),
                        TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2), child: Text("வேதகன்", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w900, fontSize: 12)))),
                        TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2), child: Text("பாசகன்", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w900, fontSize: 12)))),
                        TableCell(child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2), child: Text("காரகன்", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w900, fontSize: 12)))),
                      ],
                    ),
                    ...list.map((row) {
                      final b = row['bodhaka'] as Map<String, dynamic>;
                      final v = row['vedhaka'] as Map<String, dynamic>;
                      final p = row['pachaka'] as Map<String, dynamic>;
                      final k = row['karaka'] as Map<String, dynamic>;

                      return TableRow(
                        decoration: const BoxDecoration(color: Colors.white),
                        children: [
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              child: Text(
                                "• ${row['dasa_tamil']}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF5D1204)),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                              child: Text(
                                "${b['full_tamil']}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF2E7D32)),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                              child: Text(
                                "${v['full_tamil']}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFC62828)),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                              child: Text(
                                "${p['full_tamil']}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFE65100)),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                              child: Text(
                                "${k['full_tamil']}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1565C0)),
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
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 5: மரபு நட்சத்திரங்கள் (Karma / DNA Nakshatras Master Guide)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildKarmaNakshatrasTab() {
    const List<String> nakshatras27 = [
      'அசுவனி', 'பரணி', 'கார்த்திகை', 'ரோகிணி', 'மிருகசீரிஷம்', 'திருவாதிரை',
      'புனர்பூசம்', 'பூசம்', 'ஆயில்யம்', 'மகம்', 'பூரம்', 'உத்திரம்',
      'அஸ்தம்', 'சித்திரை', 'சுவாதி', 'விசாகம்', 'அனுஷம்', 'கேட்டை',
      'மூலம்', 'பூராடம்', 'உத்திராடம்', 'திருவோணம்', 'அவிட்டம்', 'சதயம்',
      'பூரட்டாதி', 'உத்திரட்டாதி', 'ரேவதி'
    ];

    const List<String> nakLords = [
      'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்',
      'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்',
      'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்'
    ];

    final Map<String, Color> planetColors = {
      'Sun': const Color(0xFFE65100),
      'Moon': const Color(0xFF1565C0),
      'Mars': const Color(0xFFC62828),
      'Mercury': const Color(0xFF2E7D32),
      'Jupiter': const Color(0xFFD48806),
      'Venus': const Color(0xFF8E24AA),
      'Saturn': const Color(0xFF37474F),
      'Rahu': const Color(0xFF00695C),
    };

    final Map<String, IconData> planetIcons = {
      'Sun': Icons.wb_sunny_rounded,
      'Moon': Icons.nightlight_round,
      'Mars': Icons.local_fire_department_rounded,
      'Mercury': Icons.eco_rounded,
      'Jupiter': Icons.school_rounded,
      'Venus': Icons.favorite_rounded,
      'Saturn': Icons.shield_rounded,
      'Rahu': Icons.all_inclusive_rounded,
    };

    final String selectedKarmaKey = AstroSpecialCalculationsService.getDnaPlanetFromNakshatra(_selectedKarmaLookupNakshatra);
    final String selectedKarmaTamil = AstroSpecialCalculationsService.DNA_PLANET_TAMIL[selectedKarmaKey] ?? selectedKarmaKey;
    final Color selectedColor = planetColors[selectedKarmaKey] ?? AppColors.primary;
    final int selectedNakIdx = nakshatras27.indexOf(_selectedKarmaLookupNakshatra);
    final String selectedLord = selectedNakIdx != -1 ? nakLords[selectedNakIdx] : "-";
    final List<String> siblingStars = AstroSpecialCalculationsService.KARMA_MASTER_TABLE[selectedKarmaKey] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5D1204), Color(0xFF8A1C08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hub_rounded, color: Color(0xFFFFD54F), size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "மரபு நட்சத்திர வழிகாட்டி (Karma / DNA Nakshatras)",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "8 கிரகங்களின் மரபு ஆதிக்கச் சுழற்சி மற்றும் 27 நட்சத்திரங்களின் மரபுப் பதிவுகள் வழிகாட்டி.",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Nakshatra Lookup Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "நட்சத்திர மரபு விரைவுத் தேர்வு (Quick Lookup)",
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6EE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedKarmaLookupNakshatra,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                            items: nakshatras27.map((nak) {
                              return DropdownMenuItem<String>(
                                value: nak,
                                child: Text(
                                  nak,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedKarmaLookupNakshatra = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Highlight Result Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selectedColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selectedColor.withOpacity(0.3), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(planetIcons[selectedKarmaKey] ?? Icons.circle, color: selectedColor, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$_selectedKarmaLookupNakshatra ➔ $selectedKarmaTamil மரபு",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: selectedColor,
                                        ),
                                      ),
                                      Text(
                                        "விம்சோத்தரி நட்சத்திர அதிபதி: $selectedLord",
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              "$selectedKarmaTamil மரபில் வரும் மற்ற நட்சத்திரங்கள்:",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D1204)),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: siblingStars.map((s) {
                                final bool isCurrent = s == _selectedKarmaLookupNakshatra;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCurrent ? selectedColor : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isCurrent ? selectedColor : const Color(0xFFB58D3D).withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                      color: isCurrent ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 8 Planet Master Reference Cards
              Text(
                "8 கிரகங்களின் மரபு நட்சத்திர அட்டவணை (Master Registry)",
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),

              ...AstroSpecialCalculationsService.KARMA_MASTER_TABLE.entries.map((entry) {
                final pKey = entry.key;
                final pTamil = AstroSpecialCalculationsService.DNA_PLANET_TAMIL[pKey] ?? pKey;
                final color = planetColors[pKey] ?? AppColors.primary;
                final icon = planetIcons[pKey] ?? Icons.circle;
                final stars = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "$pTamil ($pKey)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "${stars.length} நட்சத்திரங்கள்",
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: stars.map((star) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF6EE),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      "• $star",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF5D1204),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // 27 Stars Complete Table Expansion
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.3)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    collapsedBackgroundColor: const Color(0xFFFAF6EE),
                    backgroundColor: Colors.white,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D1204).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.table_chart_rounded, color: Color(0xFF5D1204), size: 22),
                    ),
                    title: const Text(
                      "27 நட்சத்திரங்களின் முழு மரபு அட்டவணை (Complete Table)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF5D1204),
                      ),
                    ),
                    subtitle: const Text(
                      "எண், நட்சத்திரம், நட்சத்திர அதிபதி மற்றும் மரபு கிரகம்",
                      style: TextStyle(fontSize: 11.5, color: Colors.black54),
                    ),
                    children: [
                      Container(
                        color: const Color(0xFF5D1204),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: const Row(
                          children: [
                            Expanded(flex: 1, child: Text("எண்", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                            Expanded(flex: 3, child: Text("நட்சத்திரம்", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                            Expanded(flex: 3, child: Text("நட்சத்திர அதிபதி", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                            Expanded(flex: 3, child: Text("மரபு கிரகம்", style: TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                        ),
                      ),
                      ...nakshatras27.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final star = entry.value;
                        final lord = nakLords[idx];
                        final kKey = AstroSpecialCalculationsService.getDnaPlanetFromNakshatra(star);
                        final kTamil = AstroSpecialCalculationsService.DNA_PLANET_TAMIL[kKey] ?? kKey;
                        final kColor = planetColors[kKey] ?? AppColors.primary;
                        final isAlt = idx % 2 == 1;

                        return Container(
                          color: isAlt ? const Color(0xFFFAF6EE) : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Text("${idx + 1}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF5D1204)))),
                              Expanded(flex: 3, child: Text(star, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87))),
                              Expanded(flex: 3, child: Text(lord, style: const TextStyle(fontSize: 12, color: Colors.black54))),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "$kTamil மரபு",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Tab 6: வழிபாட்டுத் தலங்கள் (Temple Worship Directories Tab)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTempleWorshipDirectoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5D1204), Color(0xFF8A1C08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.temple_hindu_rounded, color: Color(0xFFFFD54F), size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "முழு வழிபாட்டுத் தலங்கள் அட்டவணைகள் (REFERENCE DIRECTORIES)",
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "நட்சத்திரங்கள், யோகங்கள், திதிகள், கரணங்கள் மற்றும் முடக்கு ராசிகளுக்கான 7 முழுமையான திருத்தல அட்டவணைகள்.",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _templeSearchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _templeSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _templeSearchController.clear();
                              _templeSearchQuery = "";
                            });
                          },
                        )
                      : null,
                  hintText: "கோவில், ஊர், நட்சத்திரம், திதி அல்லது யோகம் தேடுக...",
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _templeSearchQuery = val.trim();
                  });
                },
              ),

              const SizedBox(height: 16),

              // Directory 1: 88-வது பாத வைநாசிக பரிகாரத் தலங்கள் (27)
              _buildExpandableTableCard(
                title: "88-வது பாத வைநாசிக பரிகாரத் தலங்கள் (27 நட்சத்திரங்கள்)",
                subtitle: "ஜன்ம நட்சத்திரத்திற்குரிய 88-வது பாத வைநாசிக பரிகாரத் தலங்கள்",
                icon: Icons.flare_rounded,
                headerColor: const Color(0xFF00695C),
                headers: const ["எண்", "நட்சத்திரம்", "கோவில் & ஊர் விவரம்"],
                flexes: const [1, 3, 6],
                rows: TempleWorshipService.VAINASIKA_TEMPLES.entries
                    .toList()
                    .where((e) => e.key != 'அசுவனி' && e.key != 'மிருகசீர்ஷம்')
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) => [
                          "${entry.key + 1}",
                          entry.value.key,
                          entry.value.value,
                        ])
                    .toList(),
              ),

              const SizedBox(height: 12),

              // Directory 2: நாம யோகங்கள் - யோகி & அவயோகி கோயில்கள் (27)
              _buildExpandableTableCard(
                title: "நாம யோகங்கள் - யோகி & அவயோகி கோயில்கள் (27 யோகங்கள்)",
                subtitle: "27 நித்திய யோகங்களுக்குரிய சுப யோகி மற்றும் தோஷ நிவர்த்தி அவயோகி தலங்கள்",
                icon: Icons.wb_sunny_rounded,
                headerColor: const Color(0xFF5D1204),
                headers: const ["எண்", "நாம யோகம்", "யோகி கோவில்", "அவயோகி கோவில்"],
                flexes: const [1, 2, 4, 4],
                rows: TempleWorshipService.YOGA_TEMPLES.entries.toList().asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final yogaName = entry.value.key;
                  final yogi = entry.value.value['yogi'] ?? '-';
                  final avayogi = entry.value.value['avayogi'] ?? '-';
                  return ["$idx", yogaName, yogi, avayogi];
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Directory 3: சுக்கில பட்சம் (வளர்பிறை) திதி அதிதேவதை & கோவில்கள் (15)
              _buildExpandableTableCard(
                title: "சுக்கில பட்சம் / வளர்பிறை திதிகள் & கோவில்கள்",
                subtitle: "வளர்பிறை 15 திதிகளுக்குரிய அதிதேவதை மற்றும் வழிபட வேண்டிய திருக்கோவில்கள்",
                icon: Icons.brightness_7_rounded,
                headerColor: const Color(0xFF1565C0),
                headers: const ["எண்", "திதி", "அதிதேவதை", "திருக்கோவில்"],
                flexes: const [1, 2, 3, 4],
                rows: TempleWorshipService.SHUKLA_THITHI_TEMPLES.entries.toList().asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final thithi = entry.value.key;
                  final deity = entry.value.value['deity'] ?? '-';
                  final temple = entry.value.value['temple'] ?? '-';
                  return ["$idx", thithi, deity, temple];
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Directory 4: கிருஷ்ண பட்சம் (தேய்பிறை) திதி அதிதேவதை & கோவில்கள் (15)
              _buildExpandableTableCard(
                title: "கிருஷ்ண பட்சம் / தேய்பிறை திதிகள் & கோவில்கள்",
                subtitle: "தேய்பிறை 15 திதிகளுக்குரிய அதிதேவதை மற்றும் வழிபட வேண்டிய திருக்கோவில்கள்",
                icon: Icons.brightness_3_rounded,
                headerColor: const Color(0xFF37474F),
                headers: const ["எண்", "திதி", "அதிதேவதை", "திருக்கோவில்"],
                flexes: const [1, 2, 3, 4],
                rows: TempleWorshipService.KRISHNA_THITHI_TEMPLES.entries.toList().asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final thithi = entry.value.key;
                  final deity = entry.value.value['deity'] ?? '-';
                  final temple = entry.value.value['temple'] ?? '-';
                  return ["$idx", thithi, deity, temple];
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Directory 5: கரண நாதன் & அதிதேவதைக் கோவில்கள் (11)
              _buildExpandableTableCard(
                title: "கரண நாதன் கோவில்கள் (11 கரணங்கள்)",
                subtitle: "11 கரணங்களுக்குரிய கிரகம், வாகனம், அதிதேவதை மற்றும் சிறப்புத் திருத்தலங்கள்",
                icon: Icons.pets_rounded,
                headerColor: const Color(0xFF6A1B9A),
                headers: const ["எண்", "கரணம்", "கிரகம்", "மிருகம்", "அதிதேவதை", "கோவில்"],
                flexes: const [1, 2, 2, 2, 2, 4],
                rows: TempleWorshipService.PRIMARY_KARANAS.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final karana = entry.value;
                  final info = TempleWorshipService.KARANA_TEMPLES[karana] ?? {};
                  final lord = info['lord'] ?? '-';
                  final animal = info['animal'] ?? '-';
                  final deity = info['deity'] ?? '-';
                  final temple = info['temple'] ?? '-';
                  return ["$idx", karana, lord, animal, deity, temple];
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Directory 6: முடக்கு ராசி / பாவகம் வாரியான கோவில்கள்
              _buildExpandableMudakkuCard(),

              const SizedBox(height: 12),

              // Directory 7: ஜன்ம நட்சத்திரக் கோவில்கள் (27)
              _buildExpandableTableCard(
                title: "ஜன்ம நட்சத்திரக் கோவில்கள் (27 நட்சத்திரங்கள்)",
                subtitle: "27 நட்சத்திரங்களுக்கும் அருள் பாலிக்கும் பாரம்பரியத் திருத்தலங்கள்",
                icon: Icons.star_rounded,
                headerColor: const Color(0xFFD48806),
                headers: const ["எண்", "நட்சத்திரம்", "ஜன்ம நட்சத்திரத் திருக்கோவில்"],
                flexes: const [1, 3, 6],
                rows: TempleWorshipService.NAKSHATRA_TEMPLES.entries
                    .toList()
                    .where((e) => e.key != 'அசுவனி' && e.key != 'மிருகசீர்ஷம்')
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) => [
                          "${entry.key + 1}",
                          entry.value.key,
                          entry.value.value,
                        ])
                    .toList(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to build expandable reference tables with live search filtering
  Widget _buildExpandableTableCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color headerColor,
    required List<String> headers,
    required List<int> flexes,
    required List<List<String>> rows,
  }) {
    List<List<String>> displayRows = rows;
    if (_templeSearchQuery.isNotEmpty) {
      displayRows = rows.where((row) {
        return row.any((cell) => cell.toLowerCase().contains(_templeSearchQuery.toLowerCase()));
      }).toList();
    }

    if (_templeSearchQuery.isNotEmpty && displayRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      key: ValueKey("$title-$_templeSearchQuery"),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _templeSearchQuery.isNotEmpty,
          collapsedBackgroundColor: const Color(0xFFFAF6EE),
          backgroundColor: Colors.white,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: headerColor, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: headerColor,
            ),
          ),
          subtitle: Text(
            _templeSearchQuery.isNotEmpty
                ? "${displayRows.length} முடிவுகள் கண்டறியப்பட்டன"
                : subtitle,
            style: TextStyle(
              fontSize: 11.5,
              color: _templeSearchQuery.isNotEmpty ? const Color(0xFF2E7D32) : Colors.black54,
              fontWeight: _templeSearchQuery.isNotEmpty ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          children: [
            Container(
              decoration: const BoxDecoration(color: Color(0xFF5D1204)),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: List.generate(headers.length, (i) {
                  return Expanded(
                    flex: flexes[i],
                    child: Text(
                      headers[i],
                      textAlign: i == 0 ? TextAlign.center : TextAlign.start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
              ),
            ),
            ...displayRows.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;
              final isAlt = idx % 2 == 1;

              return Container(
                color: isAlt ? const Color(0xFFFAF6EE) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(
                  children: List.generate(row.length, (i) {
                    return Expanded(
                      flex: flexes[i],
                      child: Text(
                        row[i],
                        textAlign: i == 0 ? TextAlign.center : TextAlign.start,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: i == 1 ? FontWeight.bold : FontWeight.normal,
                          color: i == 0
                              ? const Color(0xFF5D1204)
                              : (i == 1 ? headerColor : Colors.black87),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Expandable Card for Mudakku Rasi / Bhava Temples with live search filtering
  Widget _buildExpandableMudakkuCard() {
    final filteredBhavas = <String, Map<String, String>>{};
    for (var entry in TempleWorshipService.MUDAKKU_BHAVA_TEMPLES.entries) {
      final matchingSub = <String, String>{};
      for (var sub in entry.value.entries) {
        if (_templeSearchQuery.isEmpty ||
            entry.key.toLowerCase().contains(_templeSearchQuery.toLowerCase()) ||
            sub.key.toLowerCase().contains(_templeSearchQuery.toLowerCase()) ||
            sub.value.toLowerCase().contains(_templeSearchQuery.toLowerCase())) {
          matchingSub[sub.key] = sub.value;
        }
      }
      if (matchingSub.isNotEmpty) {
        filteredBhavas[entry.key] = matchingSub;
      }
    }

    if (_templeSearchQuery.isNotEmpty && filteredBhavas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      key: ValueKey("mudakku-$_templeSearchQuery"),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _templeSearchQuery.isNotEmpty,
          collapsedBackgroundColor: const Color(0xFFFAF6EE),
          backgroundColor: Colors.white,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE65100).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_open_rounded, color: Color(0xFFE65100), size: 22),
          ),
          title: const Text(
            "முடக்கு ராசி / பாவகம் வாரியான வழிபாட்டுத் தலங்கள்",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFFE65100),
            ),
          ),
          subtitle: Text(
            _templeSearchQuery.isNotEmpty
                ? "${filteredBhavas.length} பாவக முடிவுகள் கண்டறியப்பட்டன"
                : "12 லக்னங்கள் & 1 முதல் 12-ஆம் பாவகங்கள் முடக்காக அமைந்தால் வழிபட வேண்டிய திருத்தலங்கள்",
            style: TextStyle(
              fontSize: 11.5,
              color: _templeSearchQuery.isNotEmpty ? const Color(0xFF2E7D32) : Colors.black54,
              fontWeight: _templeSearchQuery.isNotEmpty ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          children: [
            ...filteredBhavas.entries.map((bhavaEntry) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      color: const Color(0xFF5D1204),
                      child: Text(
                        "முடக்கு ராசி அமைப்பு: ${bhavaEntry.key}",
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    ...bhavaEntry.value.entries.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF6EE),
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.withOpacity(0.15)),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                "• ${item.key}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF5D1204),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 6,
                              child: Text(
                                item.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
