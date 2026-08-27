import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../widgets/custom_wheel_picker.dart';
import '../widgets/custom_time_wheel_picker.dart';
import '../widgets/location_search_dialog.dart';
import '../widgets/saved_horoscope_dialog.dart';
import '../services/location_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/pdf_service.dart';
import '../services/one_page_pdf_service.dart';
import '../services/kp_one_page_pdf_service.dart';
import '../services/kp_service.dart';
import 'horoscope_results_screen.dart';
import 'pdf_viewer_screen.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../components/custom_drawer.dart';
import '../widgets/custom_date_input_field.dart';
import '../widgets/custom_time_input_field.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class InputScreen extends StatefulWidget {
  final bool isPopup;
  final bool isKp;
  final bool isNadi;
  final bool isPrasannam;
  final String? prasannamType;
  final void Function(Map<String, dynamic>)? onCompleted;

  const InputScreen({
    super.key,
    this.isPopup = false,
    this.isKp = false,
    this.isNadi = false,
    this.isPrasannam = false,
    this.prasannamType,
    this.onCompleted,
  });

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _tzController = TextEditingController();
  final TextEditingController _prasannamController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedGender = 'ஆண்';
  bool _saveHoroscope = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _timeController.text = "${_selectedTime.hourOfPeriod}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}";
    
    _loadDefaultLocation();
  }

  Future<void> _loadDefaultLocation() async {
    final location = await SettingsService.getDefaultLocation();
    setState(() {
      if (location['name'] != null) {
        _placeController.text = location['name'];
        _latController.text = location['lat'].toString();
        _longController.text = location['lon'].toString();
        _tzController.text = location['tz'].toString();
      } else {
        _placeController.text = 'Chennai (சென்னை)';
        _latController.text = '13.0827';
        _longController.text = '80.2707';
        _tzController.text = '5.5';
      }
    });
  }

  void _setCurrentDateTime() {
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      _timeController.text =
          "${_selectedTime.hourOfPeriod}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}";
    });
  }

  Future<void> _submitData() async {
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = "-";
    }
    if (_formKey.currentState!.validate()) {
      final dt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final Map<String, dynamic> inputs = <String, dynamic>{
        'name': _nameController.text,
        'gender': _selectedGender,
        'date': dt.toIso8601String(), // Convert to string for storage
        'latitude': double.parse(_latController.text),
        'longitude': double.parse(_longController.text),
        'timezone': double.parse(_tzController.text),
        'place': _placeController.text,
      };

      if (_saveHoroscope) {
        final prefs = await SharedPreferences.getInstance();
        List<String> saved = prefs.getStringList('saved_horoscopes') ?? [];
        saved.add(jsonEncode(inputs));
        await prefs.setStringList('saved_horoscopes', saved);
        // Show confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.horoscopeSaved)),
          );
        }
      }

      // Convert date back to DateTime for calculation
      inputs['date'] = dt;
      // Ensure timezone is correctly passed from controller or defaults to 5.5 for India
      double tz = double.tryParse(_tzController.text) ?? 5.5;
      inputs['timezone'] = tz == 0 ? 5.5 : tz; 
      inputs['prasannam_input'] = _prasannamController.text;
      
      // Fetch settings
      final ayanamsaMode = await SettingsService.getAyanamsa();
      final yearLength = await SettingsService.getDasaYearLength();
      inputs['ayanamsa_index'] = ayanamsaMode;
      inputs['year_length'] = yearLength;

       final isKp = widget.isPopup ? widget.isKp : (ModalRoute.of(context)?.settings.arguments as Map?)?['isKp'] == true;
      
      // Call the Navigator helper from main.dart
      if (mounted) {
        AppNavigator.calculateAndNavigate(
          context, 
          inputs, 
          isKp: isKp, 
          onCompleted: widget.onCompleted,
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => CustomWheelPicker(
        initialDate: _selectedDate,
        onSelect: (date) {
          setState(() {
            _selectedDate = date;
            _dateController.text = DateFormat('dd/MM/yyyy').format(date);
          });
        },
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => CustomTimeWheelPicker(
        initialTime: _selectedTime,
        onSelect: (time) {
          setState(() {
            _selectedTime = time;
            _timeController.text = "${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
          });
        },
      ),
    );
  }

  Future<void> _showLocationSearch() async {
    final CityLocation? selected = await showDialog<CityLocation>(
      context: context,
      builder: (context) => const LocationSearchDialog(),
    );

    if (selected != null) {
      setState(() {
        _placeController.text = selected.name;
        _latController.text = selected.lat.toString();
        _longController.text = selected.lon.toString();
        _tzController.text = selected.tz.toString();
      });
    }
  }

  Future<void> _showSavedHoroscopeDialog() async {
    final Map<String, dynamic>? selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const SavedHoroscopeDialog(),
    );

    if (selected != null) {
      setState(() {
        DateTime dt = DateTime.parse(selected['date']);
        _nameController.text = selected['name'] ?? '';
        _placeController.text = selected['place'] ?? 'Chennai (சென்னை)';
        _latController.text = (selected['latitude'] ?? 13.0827).toString();
        _longController.text = (selected['longitude'] ?? 80.2707).toString();
        _tzController.text = (selected['timezone'] ?? 5.5).toString();
        _selectedDate = dt;
        _dateController.text = DateFormat('dd/MM/yyyy').format(dt);
        _selectedTime = TimeOfDay.fromDateTime(dt);
        _timeController.text = "${_selectedTime.hourOfPeriod}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}";
        if (selected['gender'] != null) {
          _selectedGender = selected['gender'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;
    
    final Map? args = widget.isPopup ? null : ModalRoute.of(context)?.settings.arguments as Map?;
    final bool isKp = widget.isPopup ? widget.isKp : args?['isKp'] == true;
    final bool isNadi = widget.isPopup ? widget.isNadi : args?['isNadi'] == true;
    final bool isPrasannam = widget.isPopup ? widget.isPrasannam : args?['isPrasannam'] == true;
    final String? prasannamType = widget.isPopup ? widget.prasannamType : args?['prasannamType'];

    String title = AppLocalizations.of(context)!.horoscopeCalcTitle;
    if (isNadi) {
      title = AppLocalizations.of(context)!.nadiCalcTitle;
    } else if (isKp) {
      title = AppLocalizations.of(context)!.kpCalcTitle;
    } else if (isPrasannam) {
      switch (prasannamType) {
        case 'number':
          title = AppLocalizations.of(context)!.numPrasannamTitle;
          break;
        case 'soli':
          title = AppLocalizations.of(context)!.cowriePrasannamTitle;
          break;
        case 'vetrilai':
          title = AppLocalizations.of(context)!.betelPrasannamTitle;
          break;
        case 'kp':
          title = AppLocalizations.of(context)!.kpPrasannamTitle;
          break;
        case 'horai':
          title = AppLocalizations.of(context)!.horaiPrasannamTitle;
          break;
        default:
          title = AppLocalizations.of(context)!.prasannamTitle;
      }
    }

    if (widget.isPopup) {
      return Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 10,
        child: Container(
          width: 550,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.access_time_rounded, color: AppColors.primary),
                        tooltip: AppLocalizations.of(context)!.nowTooltip,
                        onPressed: _setCurrentDateTime,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: AppColors.primary, thickness: 1),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputField(AppLocalizations.of(context)!.nameLabel, _nameController, Icons.person_outline, null,
                          suffixIcon: IconButton(icon: const Icon(Icons.search, color: AppColors.primary), onPressed: _showSavedHoroscopeDialog)),
                        const SizedBox(height: 16),
                        if (isPrasannam && prasannamType != 'horai') ...[
                          _buildPrasannamField(prasannamType!),
                          const SizedBox(height: 16),
                        ],
                        if (!isPrasannam) ...[
                          _buildGenderSelector(),
                          const SizedBox(height: 16),
                        ],
                        if (!isPrasannam || prasannamType == 'horai') ...[
                          _buildPlaceField(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildDateField()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTimeField()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.locationDetailsLabel,
                                      style: TextStyle(
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold, 
                                        color: AppColors.primary.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(child: _buildCoordinateField('LAT', _latController, Icons.map_outlined)),
                                    const SizedBox(width: 8),
                                    Expanded(child: _buildCoordinateField('LON', _longController, Icons.explore_outlined)),
                                    const SizedBox(width: 8),
                                    Expanded(child: _buildCoordinateField('TZ', _tzController, Icons.access_time_filled_rounded)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: _saveHoroscope,
                          onChanged: (v) => setState(() => _saveHoroscope = v ?? false),
                          title: Text(
                            AppLocalizations.of(context)!.saveHoroscopeLabel,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF3E2723)),
                          ),
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20)
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: isWide ? null : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time_rounded, color: AppColors.primary),
            tooltip: AppLocalizations.of(context)!.nowTooltip,
            onPressed: _setCurrentDateTime,
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
            tooltip: 'முஹூர்த்தம்',
            onPressed: () => Navigator.pushNamed(context, '/saved_horoscopes'),
          ),
          const SizedBox(width: 8),
        ],
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
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
            Container(
              height: MediaQuery.of(context).size.width < 380 ? 10 : 20,

              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isWide && (!isPrasannam || prasannamType == 'horai'))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildInputField(AppLocalizations.of(context)!.nameLabel, _nameController, Icons.person_outline, null, 
                            suffixIcon: IconButton(icon: const Icon(Icons.search, color: AppColors.primary), onPressed: _showSavedHoroscopeDialog))),
                          const SizedBox(width: 20),
                          if (!isPrasannam)
                            Expanded(flex: 1, child: _buildGenderSelector()),
                        ],
                      )
                    else ...[
                      _buildInputField(AppLocalizations.of(context)!.nameLabel, _nameController, Icons.person_outline, null,
                        suffixIcon: IconButton(icon: const Icon(Icons.search, color: AppColors.primary), onPressed: _showSavedHoroscopeDialog)),
                      const SizedBox(height: 20),
                      if (isPrasannam && prasannamType != 'horai') ...[
                        _buildPrasannamField(prasannamType!),
                        const SizedBox(height: 20),
                      ],
                      if (!isPrasannam) ...[
                        _buildGenderSelector(),
                        const SizedBox(height: 20),
                      ],
                    ],
                    if (isPrasannam && prasannamType != 'horai' && isWide) ...[
                      _buildPrasannamField(prasannamType!),
                      const SizedBox(height: 20),
                    ],
                    if (!isPrasannam || prasannamType == 'horai') ...[
                      _buildPlaceField(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildDateField()),
                          const SizedBox(width: 15),
                          Expanded(child: _buildTimeField()),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.locationDetailsLabel,
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: AppColors.primary.withOpacity(0.8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildCoordinateField('LAT', _latController, Icons.map_outlined)),
                                SizedBox(width: MediaQuery.of(context).size.width < 360 ? 5 : 10),
                                Expanded(child: _buildCoordinateField('LON', _longController, Icons.explore_outlined)),
                                SizedBox(width: MediaQuery.of(context).size.width < 360 ? 5 : 10),
                                Expanded(child: _buildCoordinateField('TZ', _tzController, Icons.access_time_filled_rounded)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 25),
                    Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: AppColors.primary.withOpacity(0.5),
                      ),
                      child: CheckboxListTile(
                        value: _saveHoroscope,
                        onChanged: (v) => setState(() => _saveHoroscope = v ?? false),
                        title: Text(
                          AppLocalizations.of(context)!.saveHoroscopeLabel,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF3E2723)),
                        ),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
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

  Widget _buildCoordinateField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF5D1204).withOpacity(0.6))),
        ),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: MediaQuery.of(context).size.width < 360 ? 11 : 13, 
            color: AppColors.primary
          ),

          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: MediaQuery.of(context).size.width < 320 
                ? null 
                : Icon(icon, color: AppColors.primary, size: MediaQuery.of(context).size.width < 360 ? 13 : 16),

            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, String? error, {TextInputType keyboardType = TextInputType.text, Widget? suffixIcon}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF5D1204)),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      ),
      validator: (value) {
        if (error != null && (value == null || value.isEmpty)) {
          return error;
        }
        return null;
      },
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          border: InputBorder.none, 
          prefixIcon: const Icon(Icons.wc_outlined, color: AppColors.primary),
          labelText: AppLocalizations.of(context)!.genderLabel,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF795548)),
        ),
        items: ['ஆண்', 'பெண்'].map((g) => DropdownMenuItem(value: g, child: Text(g == 'ஆண்' ? AppLocalizations.of(context)!.male : AppLocalizations.of(context)!.female, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204))))).toList(),
        onChanged: (v) => setState(() => _selectedGender = v!),
      ),
    );
  }

  Widget _buildPlaceField() {
    return TextFormField(
      controller: _placeController,
      readOnly: true,
      onTap: _showLocationSearch,
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204)),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.placeOfBirthLabel,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 14),
        prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
        suffixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.8),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final bool isDesktop = defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux;

    if (isDesktop) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dateLabel,
          labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 14),
          prefixIcon: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.0)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: CustomDateInputField(
          initialDate: _selectedDate,
          onChanged: (d) {
            setState(() {
              _selectedDate = d;
              _dateController.text = DateFormat('dd/MM/yyyy').format(d);
            });
          },
        ),
      );
    }

    return TextFormField(
      controller: _dateController,
      readOnly: true,
      onTap: () => _selectDate(context),
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204)),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.dateLabel,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 14),
        prefixIcon: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.8),
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    final bool isDesktop = defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux;

    if (isDesktop) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.timeLabel,
          labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 14),
          prefixIcon: const Icon(Icons.access_time_rounded, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.0)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: CustomTimeInputField(
          initialTime: _selectedTime,
          onChanged: (t) {
            setState(() {
              _selectedTime = t;
              _timeController.text = "${t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}";
            });
          },
        ),
      );
    }

    return TextFormField(
      controller: _timeController,
      readOnly: true,
      onTap: () => _selectTime(context),
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204)),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.timeLabel,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 14),
        prefixIcon: const Icon(Icons.access_time_rounded, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), 
          borderSide: const BorderSide(color: Color(0xFFB58D3D), width: 1.8),
        ),
      ),
    );
  }

  Future<void> _generatePDF() async {
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = "-";
    }
    if (_formKey.currentState!.validate()) {
      final Map? args = widget.isPopup ? null : ModalRoute.of(context)?.settings.arguments as Map?;
      final bool isKp = widget.isPopup ? widget.isKp : args?['isKp'] == true;
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      try {
        final dt = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final ayanamsaMode = await SettingsService.getAyanamsa();
        final yearLength = await SettingsService.getDasaYearLength();

        final results = await KPService.calculateChart(
          _nameController.text,
          dt,
          double.parse(_latController.text),
          double.parse(_longController.text),
          double.tryParse(_tzController.text) ?? 5.5,
          siderealModeIndex: ayanamsaMode,
          yearLength: yearLength,
        );

        if (!mounted) return;
        Navigator.pop(context); // Remove loading

        results['lat'] = _latController.text;
        results['lon'] = _longController.text;
        results['place'] = _placeController.text;
        results['birth_dt'] = dt;
        results['name'] = _nameController.text;
        results['gender'] = _selectedGender;

        if (kIsWeb) {
          if (isKp) {
            KpOnePagePdfService.showHtmlReport(
              name: _nameController.text,
              gender: _selectedGender,
              results: results,
              l10n: AppLocalizations.of(context)!,
            );
          } else {
            OnePagePdfService.showHtmlReport(
              name: _nameController.text,
              gender: _selectedGender,
              results: results,
              l10n: AppLocalizations.of(context)!,
            );
          }
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
          
          final bytes = isKp 
              ? await KpOnePagePdfService.generate(
                  name: _nameController.text,
                  gender: _selectedGender,
                  results: results,
                  l10n: AppLocalizations.of(context)!,
                )
              : await OnePagePdfService.generate(
                  name: _nameController.text,
                  gender: _selectedGender,
                  results: results,
                  l10n: AppLocalizations.of(context)!,
                );
          
          if (!mounted) return;
          Navigator.pop(context); // Close loading
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                pdfBytes: bytes,
                fileName: "${_nameController.text.replaceAll(' ', '_')}.pdf",
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.pdfError} $e')),
        );
      }
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Submit Button
        Expanded(
          child: Container(
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
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFF5D1204),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.submitBtn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5D1204),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // PDF Button
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D1204).withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _generatePDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5D1204),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: const BorderSide(color: Color(0xFFB58D3D), width: 1.5),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, size: 20, color: Color(0xFF5D1204)),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.pdfBtn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5D1204),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrasannamField(String type) {
    String label = 'எண்';
    
    if (type == 'number') {
      label = 'ஆரூட எண் (1-108)';
    } else if (type == 'soli') {
      label = 'சோழிகளின் எண்ணிக்கை';
    } else if (type == 'vetrilai') {
      label = 'வெற்றிலைகளின் எண்ணிக்கை';
    } else if (type == 'kp') {
      label = 'KP எண் (1-249)';
    }

    return TextFormField(
      controller: _prasannamController,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF5D1204)),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 12),
        prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primary, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'மதிப்பை உள்ளிடவும்';
        int? val = int.tryParse(value);
        if (val == null) return 'சரியான எண்ணை உள்ளிடவும்';
        if (type == 'number' && (val < 1 || val > 108)) return '1-108 வரை இருக்க வேண்டும்';
        if (type == 'kp' && (val < 1 || val > 249)) return '1-249 வரை இருக்க வேண்டும்';
        return null;
      },
    );
  }
}
