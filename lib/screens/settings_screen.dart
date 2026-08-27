import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';
import '../services/astro_translation_service.dart';
import '../widgets/location_search_dialog.dart';
import '../services/location_data.dart';
import '../components/custom_drawer.dart';
import '../theme/app_colors.dart';
import '../main.dart' as main_file;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _astroNameController = TextEditingController();
  final TextEditingController _astroPhoneController = TextEditingController();
  final TextEditingController _astroAddressController = TextEditingController();
  
  String _locationName = "Chennai (சென்னை)";
  String _stateName = "Tamil Nadu";
  String _countryIso = "IN";
  double _lat = 13.0827;
  double _lon = 80.2707;
  double _tz = 5.5;
  double _dasaYearLength = 365.25;
  int _ayanamsaMode = 0; // 0: Lahiri, 5: Krishnamurti
  double _fontSize = 1.0;
  bool _useTrueNode = false;
  String _selectedLang = 'ta';
  int _udayamMethod = 0;
  int _maandiMethod = 1;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final location = await SettingsService.getDefaultLocation();
    final info = await SettingsService.getAstrologerDetails();

    setState(() {
      if (location['name'] != null) {
        _locationName = location['name'];
        _lat = location['lat'];
        _lon = location['lon'];
        _tz = location['tz'];
        _stateName = location['state'] ?? '';
        _countryIso = location['countryIso'] ?? '';
      }
      _astroNameController.text = info['name'] ?? '';
      _astroPhoneController.text = info['phone'] ?? '';
      _astroAddressController.text = info['address'] ?? '';
    });
    
    final dyl = await SettingsService.getDasaYearLength();
    final am = await SettingsService.getAyanamsa();
    final fs = await SettingsService.getFontSize();
    final utn = await SettingsService.getTrueNodeMode();
    final lang = await SettingsService.getLanguage();
    final um = await SettingsService.getUdayamMethod();
    final mm = await SettingsService.getMaandiMethod();
    
    if (mounted) {
      setState(() {
        _dasaYearLength = dyl;
        _ayanamsaMode = am;
        _fontSize = fs;
        _useTrueNode = utn;
        _selectedLang = lang;
        _udayamMethod = um;
        _maandiMethod = mm;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    await SettingsService.saveDefaultLocation(
      name: _locationName,
      lat: _lat,
      lon: _lon,
      tz: _tz,
      state: _stateName,
      countryIso: _countryIso,
    );
    await SettingsService.saveAstrologerDetails(
      name: _astroNameController.text,
      phone: _astroPhoneController.text,
      address: _astroAddressController.text,
    );
    await SettingsService.saveDasaYearLength(_dasaYearLength);
    await SettingsService.saveAyanamsa(_ayanamsaMode);
    await SettingsService.saveFontSize(_fontSize);
    await SettingsService.saveTrueNodeMode(_useTrueNode);
    await SettingsService.saveLanguage(_selectedLang);
    await SettingsService.saveUdayamMethod(_udayamMethod);
    await SettingsService.saveMaandiMethod(_maandiMethod);

    // Update the global notifiers so changes take effect immediately
    main_file.appFontScaleNotifier.value = _fontSize;
    main_file.appLocaleNotifier.value = Locale(_selectedLang);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AstroTranslationService.translate(context, 'அமைப்புகள் சேமிக்கப்பட்டன! (Settings Saved)'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    final bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isWide ? null : AppBar(
        title: Text(AstroTranslationService.translate(context, 'அமைப்புகள்'), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Builder(
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isWide) ...[
                          Text(AstroTranslationService.translate(context, 'அமைப்புகள்'), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.primary)),
                          const SizedBox(height: 20),
                        ],
            _buildSectionTitle(AstroTranslationService.translate(context, "நிலையான இடம் (Default Location)")),
            const SizedBox(height: 12),
            _buildLocationCard(),
            
            const SizedBox(height: 32),
            _buildSectionTitle(AstroTranslationService.translate(context, "ஜோதிடர் விவரங்கள் (Astrologer Details)")),
            const SizedBox(height: 12),
            _buildInfoCard(),
            
            const SizedBox(height: 32),
            _buildSectionTitle(AstroTranslationService.translate(context, "அமைப்புகள் (App Settings)")),
            const SizedBox(height: 16),
            _buildLanguageSelector(),
            const SizedBox(height: 16),
            _buildFontSizeSelector(),
            const SizedBox(height: 32),
            _buildSectionTitle(AstroTranslationService.translate(context, "கணக்கீடு அமைப்புகள் (Calculation Settings)")),
            const SizedBox(height: 16),
            _buildNodeSelector(),
            const SizedBox(height: 24),
            _buildYearLengthSelector(),
            const SizedBox(height: 24),
            _buildAyanamsaSelector(),
            const SizedBox(height: 24),
            _buildUdayamMethodSelector(),
            const SizedBox(height: 24),
            _buildMaandiMethodSelector(),
            const SizedBox(height: 36),
            _buildSectionTitle(AstroTranslationService.translate(context, "சந்தா (Subscription)")),
            const SizedBox(height: 16),
            _buildSubscriptionCard(),
            const SizedBox(height: 36),
            _buildSaveButton(),
            const SizedBox(height: 40),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.location_on, color: Color(0xFFB58D3D)),
            title: Text(_locationName, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204))),
            subtitle: Text("Lat: $_lat, Lon: $_lon, TZ: $_tz", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            trailing: TextButton(
              onPressed: () async {
                final result = await showDialog<CityLocation>(
                  context: context,
                  builder: (context) => const LocationSearchDialog(),
                );
                if (result != null) {
                  setState(() {
                    _locationName = result.name;
                    _lat = result.lat;
                    _lon = result.lon;
                    _tz = result.tz;
                    _stateName = result.stateName;
                    _countryIso = result.countryIso;
                  });
                }
              },
              child: Text(AstroTranslationService.translate(context, "மாற்று"), style: TextStyle(color: Color(0xFFB58D3D), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          _buildTextField(_astroNameController, AstroTranslationService.translate(context, "உங்கள் பெயர் (Name)"), Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(_astroPhoneController, AstroTranslationService.translate(context, "மொபைல் எண் (Phone)"), Icons.phone_android_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField(_astroAddressController, AstroTranslationService.translate(context, "முகவரி (Address)"), Icons.location_city_outlined, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildNodeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.settings_suggest_outlined, color: Color(0xFFB58D3D), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(AstroTranslationService.translate(context, "ராகு/கேது (Node Calculation)"), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204)))),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(AstroTranslationService.translate(context, "சராசரி (Mean Node)"))),
              ButtonSegment(value: true, label: Text(AstroTranslationService.translate(context, "உண்மை (True Node)"))),
            ],
            selected: {_useTrueNode},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _useTrueNode = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AstroTranslationService.translate(context, "* பாரம்பரிய பஞ்சாங்கங்கள் 'சராசரி' (Mean Node) முறையை பயன்படுத்துகின்றன."),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildYearLengthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: Color(0xFFB58D3D), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(AstroTranslationService.translate(context, "திசை வருட அளவு (Dasa Year Length)"), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204)))),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<double>(
            segments: [
              ButtonSegment(value: 360.0, label: Text(AstroTranslationService.translate(context, "360 நாட்கள்"))),
              ButtonSegment(value: 365.25, label: Text(AstroTranslationService.translate(context, "365.25 நாட்கள்"))),
            ],
            selected: {_dasaYearLength},
            onSelectionChanged: (Set<double> newSelection) {
              setState(() {
                _dasaYearLength = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AstroTranslationService.translate(context, "* 365.25 என்பது நவீன முறை (Default). 360 என்பது பாரம்பரிய முறை."),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildAyanamsaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.blur_circular_outlined, color: Color(0xFFB58D3D), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(AstroTranslationService.translate(context, "அயனாம்சம் (Ayanamsa Mode)"), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204)))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
          ),
          child: DropdownButtonFormField<int>(
            value: _ayanamsaMode,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            dropdownColor: Colors.white,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF5D1204)),
            items: [
              DropdownMenuItem(value: 0, child: Text(AstroTranslationService.translate(context, "Lahiri (Chitra Paksha)"))),
              DropdownMenuItem(value: 1, child: Text(AstroTranslationService.translate(context, "Raman"))),
              DropdownMenuItem(value: 2, child: Text(AstroTranslationService.translate(context, "KP Old (Original)"))),
              DropdownMenuItem(value: 3, child: Text(AstroTranslationService.translate(context, "KP New (Modern)"))),
              DropdownMenuItem(value: 4, child: Text(AstroTranslationService.translate(context, "KP Straight Line (Khullar)"))),
              DropdownMenuItem(value: 5, child: Text(AstroTranslationService.translate(context, "KP-Newcomb (Auto)"))),
            ],
            onChanged: (int? newSelection) {
              if (newSelection != null) {
                setState(() {
                  _ayanamsaMode = newSelection;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUdayamMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time_outlined, color: Color(0xFFB58D3D), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AstroTranslationService.translate(context, "ஜாமக்கோள் உதயம் கணக்கிடும் முறை"),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 0,
                label: Text(AstroTranslationService.translate(context, "12 மணிநேர முறை")),
              ),
              ButtonSegment(
                value: 1,
                label: Text(AstroTranslationService.translate(context, "சூரிய உதய முறை")),
              ),
            ],
            selected: {_udayamMethod},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                _udayamMethod = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaandiMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.blur_circular_outlined, color: Color(0xFFB58D3D), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AstroTranslationService.translate(context, "மாந்தி உதயம் கணக்கிடும் முறை"),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: _maandiMethod,
          isExpanded: true,
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF5D1204)),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text(
                AstroTranslationService.translate(context, "நாள்/இரவு நாழிகை மற்றும் நிலையான நாழிகை விகிதாச்சாரம்"),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 1,
              child: Text(
                AstroTranslationService.translate(context, "8 சம பாகங்கள் மற்றும் சனியின் பாகத் தொடக்கம் (Start)"),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 2,
              child: Text(
                AstroTranslationService.translate(context, "8 சம பாகங்கள் மற்றும் சனியின் பாக நடுப்பகுதி (Middle)"),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 3,
              child: Text(
                AstroTranslationService.translate(context, "8 சம பாகங்கள் மற்றும் சனியின் பாக முடிவு (End)"),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 4,
              child: Text(
                AstroTranslationService.translate(context, "சூரியன் பாகை + நிலையான பாகை கூட்டும் முறை"),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          onChanged: (int? val) {
            if (val != null) {
              setState(() {
                _maandiMethod = val;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildFontSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.text_fields_outlined, color: Color(0xFFB58D3D), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(AstroTranslationService.translate(context, "எழுத்துரு அளவு (Font Size)"), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204)))),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<double>(
            segments: [
              ButtonSegment(value: 0.85, label: Text(AstroTranslationService.translate(context, "சிறிய (Small)"))),
              ButtonSegment(value: 1.0, label: Text(AstroTranslationService.translate(context, "நடுத்தர (Normal)"))),
              ButtonSegment(value: 1.15, label: Text(AstroTranslationService.translate(context, "பெரிய (Large)"))),
            ],
            selected: {_fontSize},
            onSelectionChanged: (Set<double> newSelection) {
              setState(() {
                _fontSize = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.language_outlined, color: Color(0xFFB58D3D), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(AstroTranslationService.translate(context, "மொழி (Language)"), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204)))),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: [
              const ButtonSegment(value: 'en', label: Text("English")),
              const ButtonSegment(value: 'ta', label: Text("தமிழ்")),
              const ButtonSegment(value: 'hi', label: Text("हिन्दी")),
            ],
            selected: {_selectedLang},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedLang = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF5D1204)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.7), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFFB58D3D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      width: double.infinity,
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const Icon(Icons.card_membership_rounded, color: Color(0xFFB58D3D), size: 30),
        title: Text(AstroTranslationService.translate(context, "சந்தா திட்டங்கள்"), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF5D1204))),
        subtitle: Text(AstroTranslationService.translate(context, "Subscription Plans"), style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFB58D3D), size: 18),
        onTap: () {
          Navigator.pushNamed(context, '/subscriptions');
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D1204), Color(0xFFB58D3D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.3), 
            blurRadius: 10, 
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(
          AstroTranslationService.translate(context, "சேமி (SAVE)"), 
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1, color: Colors.white),
        ),
      ),
    );
  }
}
