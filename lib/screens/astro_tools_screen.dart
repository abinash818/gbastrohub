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
    _tabController = TabController(length: 3, vsync: this);
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("கிழமை: ", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _horaWeekday,
                items: List.generate(7, (idx) {
                  return DropdownMenuItem(
                    value: idx + 1,
                    child: Text(weekdays[idx]),
                  );
                }),
                onChanged: (val) {
                  if (val != null) setState(() => _horaWeekday = val);
                },
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
                          const Text("உள்-ஹோரைகள் (தலா 12 நிமிடங்கள்):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5D1204))),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: (item['sub_horas'] as List).asMap().entries.map((e) {
                              return Chip(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFB58D3D)),
                                label: Text("${e.key + 1}. ${e.value}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                          ),
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
}
