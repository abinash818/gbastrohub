import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/kp_service.dart';
import '../services/astro_special_calculations_service.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
}
