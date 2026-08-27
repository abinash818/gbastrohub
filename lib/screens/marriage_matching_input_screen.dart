import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/astro_data.dart';
import '../services/kp_service.dart';
import '../widgets/custom_wheel_picker.dart';
import '../widgets/custom_time_wheel_picker.dart';
import '../widgets/location_search_dialog.dart';
import '../widgets/saved_horoscope_dialog.dart';
import '../services/location_data.dart';
import 'marriage_matching_results_screen.dart';
import '../components/custom_drawer.dart';
import '../theme/app_colors.dart';

enum MatchingMode { star, horoscope }

class MarriageMatchingInputScreen extends StatefulWidget {
  const MarriageMatchingInputScreen({super.key});

  @override
  State<MarriageMatchingInputScreen> createState() => _MarriageMatchingInputScreenState();
}

class _MarriageMatchingInputScreenState extends State<MarriageMatchingInputScreen> {
  MatchingMode _mode = MatchingMode.star;

  // Star Mode State
  String _girlStar = AstroData.natchathiraList[0];
  String _girlPada = "1";
  String _boyStar = AstroData.natchathiraList[0];
  String _boyPada = "1";

  // Horoscope Mode State - Groom
  final TextEditingController _boyName = TextEditingController();
  final TextEditingController _boyDate = TextEditingController();
  final TextEditingController _boyTime = TextEditingController();
  final TextEditingController _boyPlace = TextEditingController(text: 'Chennai (சென்னை)');
  double _boyLat = 13.0827, _boyLong = 80.2707, _boyTz = 5.5;
  DateTime _boySelDate = DateTime.now();
  TimeOfDay _boySelTime = TimeOfDay.now();

  // Horoscope Mode State - Bride
  final TextEditingController _girlName = TextEditingController();
  final TextEditingController _girlDate = TextEditingController();
  final TextEditingController _girlTime = TextEditingController();
  final TextEditingController _girlPlace = TextEditingController(text: 'Chennai (சென்னை)');
  double _girlLat = 13.0827, _girlLong = 80.2707, _girlTz = 5.5;
  DateTime _girlSelDate = DateTime.now();
  TimeOfDay _girlSelTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    String d = DateFormat('dd/MM/yyyy').format(DateTime.now());
    String t = "${TimeOfDay.now().hourOfPeriod}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}";
    _boyDate.text = _girlDate.text = d;
    _boyTime.text = _girlTime.text = t;
  }

  String _getTranslatedText(String key) {
    String lang = Localizations.localeOf(context).languageCode;
    
    Map<String, Map<String, String>> translations = {
      "திருமணப் பொருத்தம்": {"en": "Marriage Matching", "hi": "विवाह मिलान"},
      "நட்சத்திரப் பொருத்தம்": {"en": "Star Matching", "hi": "नक्षत्र मिलान"},
      "ஜாதகப் பொருத்தம்": {"en": "Horoscope Matching", "hi": "कुंडली मिलान"},
      "பெண் (Girl)": {"en": "Bride", "hi": "दुल्हन (Girl)"},
      "ஆண் (Boy)": {"en": "Groom", "hi": "दूल्हा (Boy)"},
      "பெண் விவரம் (Bride)": {"en": "Bride Details", "hi": "दुल्हन का विवरण"},
      "ஆண் விவரம் (Groom)": {"en": "Groom Details", "hi": "दूल्हे का विवरण"},
      "நட்சத்திரம் (Star)": {"en": "Star (Nakshatra)", "hi": "नक्षत्र"},
      "பாதம் (Pada)": {"en": "Pada", "hi": "पद"},
      "பெயர்": {"en": "Name", "hi": "नाम"},
      "பிறந்த இடம்": {"en": "Place of Birth", "hi": "जन्म स्थान"},
      "தேதி": {"en": "Date", "hi": "दिनांक"},
      "நேரம்": {"en": "Time", "hi": "समय"},
      "பொருத்தம் பார்க்க (Search)": {"en": "Check Matching", "hi": "मिलान जांचें"},
      "கணிப்பில் பிழை": {"en": "Calculation Error", "hi": "गणना त्रुटि"},
      
      // Nakshatras
      "அசுவனி": {"en": "Ashwini", "hi": "अश्विनी"}, "பரணி": {"en": "Bharani", "hi": "भरणी"}, "கிருத்திகை": {"en": "Krittika", "hi": "कृत्तिका"}, "ரோகிணி": {"en": "Rohini", "hi": "रोहिणी"}, "மிருகசீர்ஷம்": {"en": "Mrigashirsha", "hi": "मृगशीर्ष"}, "திருவாதிரை": {"en": "Arudra", "hi": "आर्द्रा"}, "புனர்பூசம்": {"en": "Punarvasu", "hi": "पुनर्वसु"}, "பூசம்": {"en": "Pushya", "hi": "पुष्य"}, "ஆயில்யம்": {"en": "Aslesha", "hi": "आश्लेषा"}, "மகம்": {"en": "Magha", "hi": "मघा"}, "பூரம்": {"en": "Purvaphalguni", "hi": "पूर्वाफाल्गुनी"}, "உத்திரம்": {"en": "Uttaraphalguni", "hi": "उत्तराफाल्गुनी"}, "அஸ்தம்": {"en": "Hastha", "hi": "हस्त"}, "சித்திரை": {"en": "Chitra", "hi": "चित्रा"}, "சுவாதி": {"en": "Swati", "hi": "स्वाती"}, "விசாகம்": {"en": "Vishakha", "hi": "विशाखा"}, "அனுஷம்": {"en": "Anuradha", "hi": "अनुराधा"}, "கேட்டை": {"en": "Jyeshta", "hi": "ज्येष्ठा"}, "மூலம்": {"en": "Mula", "hi": "मूल"}, "பூராடம்": {"en": "Purvashada", "hi": "पूर्वाषाढ़ा"}, "உத்திராடம்": {"en": "Uttarashada", "hi": "उत्तराषाढ़ा"}, "திருவோணம்": {"en": "Shravana", "hi": "श्रवण"}, "அவிட்டம்": {"en": "Dhanishta", "hi": "धनिष्ठा"}, "சதயம்": {"en": "Shatabhisha", "hi": "शतभिषा"}, "பூரட்டாதி": {"en": "Purvabhadrapada", "hi": "पूर्वाभाद्रपद"}, "உத்திரட்டாதி": {"en": "Uttarabhadrapada", "hi": "उत्तराभाद्रपद"}, "ரேவதி": {"en": "Revati", "hi": "रेवती"},
    };

    return translations[key]?[lang] ?? key;
  }

  Future<void> _submitMatching() async {
    if (_mode == MatchingMode.star) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MarriageMatchingResultsScreen(
            girlStar: _girlStar,
            girlPada: int.parse(_girlPada),
            boyStar: _boyStar,
            boyPada: int.parse(_boyPada),
          ),
        ),
      );
    } else {
      // Show loading
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (context) => Center(child: CircularProgressIndicator(color: AppColors.primary))
      );

      try {
        // 1. Calculate both charts
        DateTime bDt = DateTime(_boySelDate.year, _boySelDate.month, _boySelDate.day, _boySelTime.hour, _boySelTime.minute);
        DateTime gDt = DateTime(_girlSelDate.year, _girlSelDate.month, _girlSelDate.day, _girlSelTime.hour, _girlSelTime.minute);

        var boyRes = await KPService.calculateChart(_boyName.text, bDt, _boyLat, _boyLong, _boyTz);
        var girlRes = await KPService.calculateChart(_girlName.text, gDt, _girlLat, _girlLong, _girlTz);

        boyRes['name'] = _boyName.text.isNotEmpty ? _boyName.text : "-";
        boyRes['place'] = _boyPlace.text.isNotEmpty ? _boyPlace.text : "-";
        boyRes['birth_dt'] = bDt;

        girlRes['name'] = _girlName.text.isNotEmpty ? _girlName.text : "-";
        girlRes['place'] = _girlPlace.text.isNotEmpty ? _girlPlace.text : "-";
        girlRes['birth_dt'] = gDt;

        if (!mounted) return;
        Navigator.pop(context); // Hide loading

        // 2. Extract Star/Pada from planet_details['moon']
        var boyMoon = boyRes['planet_details']['moon'];
        var girlMoon = girlRes['planet_details']['moon'];

        // 3. Navigate with full data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MarriageMatchingResultsScreen(
              girlStar: girlMoon['nakshatra'],
              girlPada: girlMoon['pada'],
              boyStar: boyMoon['nakshatra'],
              boyPada: boyMoon['pada'],
              girlFullData: girlRes,
              boyFullData: boyRes,
            ),
          ),
        );
      } catch (e) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_getTranslatedText("கணிப்பில் பிழை")}: $e')));
      }
    }
  }

  Future<void> _showSavedHoroscopeDialog({required bool isGirl}) async {
    final Map<String, dynamic>? selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const SavedHoroscopeDialog(),
    );

    if (selected != null) {
      setState(() {
        DateTime dt = DateTime.parse(selected['date']);
        if (isGirl) {
          _girlName.text = selected['name'] ?? '';
          _girlPlace.text = selected['place'] ?? 'Chennai (சென்னை)';
          _girlLat = selected['latitude'] ?? 13.0827;
          _girlLong = selected['longitude'] ?? 80.2707;
          _girlTz = selected['timezone'] ?? 5.5;
          _girlSelDate = dt;
          _girlDate.text = DateFormat('dd/MM/yyyy').format(dt);
          _girlSelTime = TimeOfDay.fromDateTime(dt);
          _girlTime.text = "${_girlSelTime.hourOfPeriod}:${_girlSelTime.minute.toString().padLeft(2, '0')} ${_girlSelTime.period == DayPeriod.am ? 'AM' : 'PM'}";
        } else {
          _boyName.text = selected['name'] ?? '';
          _boyPlace.text = selected['place'] ?? 'Chennai (சென்னை)';
          _boyLat = selected['latitude'] ?? 13.0827;
          _boyLong = selected['longitude'] ?? 80.2707;
          _boyTz = selected['timezone'] ?? 5.5;
          _boySelDate = dt;
          _boyDate.text = DateFormat('dd/MM/yyyy').format(dt);
          _boySelTime = TimeOfDay.fromDateTime(dt);
          _boyTime.text = "${_boySelTime.hourOfPeriod}:${_boySelTime.minute.toString().padLeft(2, '0')} ${_boySelTime.period == DayPeriod.am ? 'AM' : 'PM'}";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getTranslatedText('திருமணப் பொருத்தம்'), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: isWide ? null : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
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
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
        child: Column(
          children: [
            _buildModeToggle(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _mode == MatchingMode.star 
                    ? _buildStarModeInputs(isWide) 
                    : _buildHoroscopeModeInputs(isWide),
                  const SizedBox(height: 15),
                  _buildSubmitButton(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Row(
        children: [
          _toggleItem(_getTranslatedText("நட்சத்திரப் பொருத்தம்"), MatchingMode.star),
          _toggleItem(_getTranslatedText("ஜாதகப் பொருத்தம்"), MatchingMode.horoscope),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, MatchingMode mode) {
    bool isSel = _mode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(color: isSel ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(
              label, 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSel ? Colors.white : const Color(0xFF5D1204).withOpacity(0.7), 
                fontWeight: FontWeight.bold, 
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarModeInputs(bool isWide) {
    final girlCard = _buildSectionCard(_getTranslatedText("பெண் (Girl)"), Icons.female, Colors.pink, children: [
      _buildDropdown(_getTranslatedText("நட்சத்திரம் (Star)"), _girlStar, AstroData.natchathiraList, (val) => setState(() => _girlStar = val!)),
      const SizedBox(height: 15),
      _buildDropdown(_getTranslatedText("பாதம் (Pada)"), _girlPada, AstroData.paathamList, (val) => setState(() => _girlPada = val!)),
    ]);
    final boyCard = _buildSectionCard(_getTranslatedText("ஆண் (Boy)"), Icons.male, Colors.blue, children: [
      _buildDropdown(_getTranslatedText("நட்சத்திரம் (Star)"), _boyStar, AstroData.natchathiraList, (val) => setState(() => _boyStar = val!)),
      const SizedBox(height: 15),
      _buildDropdown(_getTranslatedText("பாதம் (Pada)"), _boyPada, AstroData.paathamList, (val) => setState(() => _boyPada = val!)),
    ]);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: girlCard),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Icon(Icons.favorite, color: AppColors.primary, size: 30),
          ),
          Expanded(child: boyCard),
        ],
      );
    }
    
    return Column(
      children: [
        girlCard,
        const SizedBox(height: 5),
        const Icon(Icons.favorite, color: AppColors.primary, size: 30),
        const SizedBox(height: 5),
        boyCard,
      ],
    );
  }

  Widget _buildHoroscopeModeInputs(bool isWide) {
    final girlCard = _buildSectionCard(_getTranslatedText("பெண் விவரம் (Bride)"), Icons.female, Colors.pink, children: [
      _buildTextField(_getTranslatedText("பெயர்"), _girlName, Icons.person_outline, 
        suffix: IconButton(icon: const Icon(Icons.search, color: AppColors.primary), onPressed: () => _showSavedHoroscopeDialog(isGirl: true))),
      const SizedBox(height: 12),
      _buildPlaceField(_girlPlace, () => _showLocationSearch(isGirl: true)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _buildClickField(_getTranslatedText("தேதி"), _girlDate, Icons.calendar_month, () => _selectDate(isGirl: true))),
        const SizedBox(width: 8),
        Expanded(child: _buildClickField(_getTranslatedText("நேரம்"), _girlTime, Icons.access_time, () => _selectTime(isGirl: true))),
      ]),
    ]);
    final boyCard = _buildSectionCard(_getTranslatedText("ஆண் விவரம் (Groom)"), Icons.male, Colors.blue, children: [
      _buildTextField(_getTranslatedText("பெயர்"), _boyName, Icons.person_outline, 
        suffix: IconButton(icon: const Icon(Icons.search, color: AppColors.primary), onPressed: () => _showSavedHoroscopeDialog(isGirl: false))),
      const SizedBox(height: 12),
      _buildPlaceField(_boyPlace, () => _showLocationSearch(isGirl: false)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _buildClickField(_getTranslatedText("தேதி"), _boyDate, Icons.calendar_month, () => _selectDate(isGirl: false))),
        const SizedBox(width: 8),
        Expanded(child: _buildClickField(_getTranslatedText("நேரம்"), _boyTime, Icons.access_time, () => _selectTime(isGirl: false))),
      ]),
    ]);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: girlCard),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 80),
            child: Icon(Icons.favorite, color: AppColors.primary, size: 30),
          ),
          Expanded(child: boyCard),
        ],
      );
    }

    return Column(
      children: [
        girlCard,
        const SizedBox(height: 5),
        const Icon(Icons.favorite, color: AppColors.primary, size: 30),
        const SizedBox(height: 5),
        boyCard,
      ],
    );
  }

  // --- REUSABLE WIDGETS ---
  Widget _buildSectionCard(String title, IconData icon, Color accentColor, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), 
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 10),
          Text(
            title, 
            style: GoogleFonts.outfit(
              fontSize: 16, 
              fontWeight: FontWeight.w900, 
              color: AppColors.primary,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 11)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(15), 
          border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true, 
            value: value, 
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary), 
            items: items.map((s) => DropdownMenuItem(value: s, child: Text(_getTranslatedText(s), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5D1204))))).toList(), 
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {Widget? suffix}) {
    return TextField(
      controller: controller, 
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204), fontSize: 14),
      decoration: _inputDeco(label, icon, suffix: suffix),
    );
  }

  Widget _buildClickField(String label, TextEditingController controller, IconData icon, VoidCallback onTap) {
    return TextField(
      controller: controller, 
      readOnly: true, 
      onTap: onTap, 
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204), fontSize: 14),
      decoration: _inputDeco(label, icon),
    );
  }

  Widget _buildPlaceField(TextEditingController controller, VoidCallback onTap) {
    return TextField(
      controller: controller, 
      readOnly: true, 
      onTap: onTap, 
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204), fontSize: 14),
      decoration: _inputDeco(_getTranslatedText("பிறந்த இடம்"), Icons.location_on_outlined, suffix: const Icon(Icons.search, size: 18, color: AppColors.primary)),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label, 
      labelStyle: TextStyle(fontSize: 12, color: const Color(0xFF5D1204).withOpacity(0.5)),
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary), 
      suffixIcon: suffix,
      filled: true, 
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), 
        borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), 
        borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15), 
        borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity, 
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: const Color(0xFFE65100), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _submitMatching,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, 
          foregroundColor: const Color(0xFF5D1204), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), 
          elevation: 0,
        ),
        child: Text(_getTranslatedText("பொருத்தம் பார்க்க (Search)"), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF5D1204))),
      ),
    );
  }

  // --- PICKERS ---
  Future<void> _selectDate({required bool isGirl}) async {
    showDialog(context: context, builder: (context) => CustomWheelPicker(initialDate: isGirl ? _girlSelDate : _boySelDate, onSelect: (date) {
      setState(() {
        if (isGirl) { _girlSelDate = date; _girlDate.text = DateFormat('dd/MM/yyyy').format(date); }
        else { _boySelDate = date; _boyDate.text = DateFormat('dd/MM/yyyy').format(date); }
      });
    }));
  }

  Future<void> _selectTime({required bool isGirl}) async {
    showDialog(context: context, builder: (context) => CustomTimeWheelPicker(initialTime: isGirl ? _girlSelTime : _boySelTime, onSelect: (time) {
      setState(() {
        String t = "${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
        if (isGirl) { _girlSelTime = time; _girlTime.text = t; }
        else { _boySelTime = time; _boyTime.text = t; }
      });
    }));
  }

  Future<void> _showLocationSearch({required bool isGirl}) async {
    final CityLocation? sel = await showDialog<CityLocation>(context: context, builder: (context) => const LocationSearchDialog());
    if (sel != null) {
      setState(() {
        if (isGirl) { _girlPlace.text = sel.name; _girlLat = sel.lat; _girlLong = sel.lon; _girlTz = sel.tz; }
        else { _boyPlace.text = sel.name; _boyLat = sel.lat; _boyLong = sel.lon; _boyTz = sel.tz; }
      });
    }
  }
}
