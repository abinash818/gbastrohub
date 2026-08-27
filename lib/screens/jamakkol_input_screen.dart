import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_wheel_picker.dart';
import '../widgets/custom_time_wheel_picker.dart';
import '../widgets/location_search_dialog.dart';
import '../services/location_data.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../components/custom_drawer.dart';

import 'package:flutter/foundation.dart';
import '../widgets/custom_date_input_field.dart';
import '../widgets/custom_time_input_field.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class JamakkolInputScreen extends StatefulWidget {
  final bool isPopup;
  const JamakkolInputScreen({super.key, this.isPopup = false});

  @override
  State<JamakkolInputScreen> createState() => _JamakkolInputScreenState();
}

class _JamakkolInputScreenState extends State<JamakkolInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _tzController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedSecond = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.fromDateTime(now);
    _selectedSecond = now.second;
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _updateTimeFieldDisplay();
    _loadDefaultLocation();
  }

  void _updateTimeFieldDisplay() {
    final periodStr = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final hr = _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    _timeController.text = "$hr:${_selectedTime.minute.toString().padLeft(2, '0')}:${_selectedSecond.toString().padLeft(2, '0')} $periodStr";
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
      final now = DateTime.now();
      _selectedDate = now;
      _selectedTime = TimeOfDay.fromDateTime(now);
      _selectedSecond = now.second;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      _updateTimeFieldDisplay();
    });
  }

  Future<int?> _promptForSeconds(BuildContext context, int initialSeconds) async {
    final secondsController = TextEditingController(text: initialSeconds.toString());
    return await showDialog<int>(
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
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final dt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
        _selectedSecond,
      );

      final inputs = {
        'date': dt,
        'lat': double.parse(_latController.text),
        'lon': double.parse(_longController.text),
        'tz': double.tryParse(_tzController.text) ?? 5.5,
        'place': _placeController.text,
      };

      if (widget.isPopup) {
        Navigator.pop(context);
      }
      Navigator.pushNamed(context, '/jamakkol', arguments: inputs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;

    if (widget.isPopup) {
      return Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.jamakkolPrasannamTitle, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20)),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.access_time_rounded, color: AppColors.primary), onPressed: _setCurrentDateTime),
                      IconButton(icon: const Icon(Icons.close, color: AppColors.primary), onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                ],
              ),
              const Divider(color: AppColors.primary, thickness: 1),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPlaceField(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildDateField()),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTimeField()),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        border: Border.all(color: const Color(0xFFE65100), width: 1.5),
                      ),
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: const Color(0xFF5D1204), elevation: 0),
                        child: Text(AppLocalizations.of(context)!.submitBtn, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.jamakkolPrasannamTitle, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20)),
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
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPlaceField(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTimeField()),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                height: 60,
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
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF5D1204),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.submitBtn,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF5D1204)),
                  ),
                ),
              ),
            ],
                      ),
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

  Widget _buildPlaceField() {
    return TextFormField(
      controller: _placeController,
      readOnly: true,
      onTap: () async {
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
      },
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204), fontSize: 14),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.placeLabel,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 13),
        prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
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
          labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 13),
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
          onChanged: (d) => setState(() {
            _selectedDate = d;
            _dateController.text = DateFormat('dd/MM/yyyy').format(d);
          }),
        ),
      );
    }

    return TextFormField(
      controller: _dateController,
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
        labelText: AppLocalizations.of(context)!.dateLabel,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 13),
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
      return Row(
        children: [
          Expanded(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.timeLabel,
                labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 13),
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
                onChanged: (t) => setState(() {
                  _selectedTime = t;
                  _updateTimeFieldDisplay();
                }),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: _selectedSecond.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.localeName == 'ta' ? 'விநாடி' : 'Sec',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              onChanged: (val) {
                setState(() {
                  _selectedSecond = int.tryParse(val) ?? 0;
                  if (_selectedSecond < 0) _selectedSecond = 0;
                  if (_selectedSecond > 59) _selectedSecond = 59;
                });
              },
            ),
          ),
        ],
      );
    }

    return TextFormField(
      controller: _timeController,
      readOnly: true,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => CustomTimeWheelPicker(
            initialTime: _selectedTime,
            onSelect: (time) async {
              final sec = await _promptForSeconds(context, _selectedSecond);
              setState(() {
                _selectedTime = time;
                _selectedSecond = sec ?? _selectedSecond;
                _updateTimeFieldDisplay();
              });
            },
          ),
        );
      },
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204), fontSize: 14),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.timeLabel,
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.5), fontSize: 13),
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
}
