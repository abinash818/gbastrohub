import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_wheel_picker.dart';
import '../services/numerology_service.dart';
import 'numerology_results_screen.dart';
import '../theme/app_colors.dart';
import '../components/custom_drawer.dart';

class NumerologyInputScreen extends StatefulWidget {
  const NumerologyInputScreen({super.key});

  @override
  State<NumerologyInputScreen> createState() => _NumerologyInputScreenState();
}

class _NumerologyInputScreenState extends State<NumerologyInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String _getTranslatedText(String key) {
    String lang = Localizations.localeOf(context).languageCode;
    Map<String, Map<String, String>> translations = {
      "பெயர் (Name)": {"en": "Name", "hi": "नाम"},
      "பிறந்த தேதி (DOB)": {"en": "Date of Birth", "hi": "जन्म तिथि"},
      "பெயரை உள்ளிடவும்": {"en": "Enter Name", "hi": "नाम दर्ज करें"},
    };
    return translations[key]?[lang] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;
    
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: isWide ? null : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 50), () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
              }
            });
          },
        ),
      ),
      drawer: isWide ? null : const CustomDrawer(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWide)
              const SizedBox(
                width: 280,
                child: CustomDrawer(),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isWide)
                              Row(
                                children: [
                                  Expanded(child: _buildInputField(_getTranslatedText('பெயர் (Name)'), _nameController, Icons.person_outline)),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildDateField(_getTranslatedText('பிறந்த தேதி (DOB)'), _dateController, Icons.calendar_month_outlined)),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildInputField(_getTranslatedText('பெயர் (Name)'), _nameController, Icons.person_outline),
                                  const SizedBox(height: 15),
                                  _buildDateField(_getTranslatedText('பிறந்த தேதி (DOB)'), _dateController, Icons.calendar_month_outlined),
                                ],
                              ),
                            const SizedBox(height: 20),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _nameController,
                              builder: (context, value, child) {
                                final text = value.text.trim();
                                if (text.isEmpty) return const SizedBox.shrink();
                                return NumerologyResultsScreen(
                                  name: text,
                                  dob: _selectedDate,
                                  psychicNumber: NumerologyService.calculatePsychicNumber(_selectedDate),
                                  destinyNumber: NumerologyService.calculateDestinyNumber(_selectedDate),
                                  nameNumber: NumerologyService.calculateNameNumber(text),
                                  compoundNameNumber: NumerologyService.calculateCompoundNameNumber(text),
                                  pyramidData: NumerologyService.calculatePyramidData(text),
                                  dobPyramidData: NumerologyService.calculateDobPyramidData(_selectedDate),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary),
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
      validator: (v) => v == null || v.isEmpty ? _getTranslatedText("பெயரை உள்ளிடவும்") : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () {
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
      },
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary),
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
}
