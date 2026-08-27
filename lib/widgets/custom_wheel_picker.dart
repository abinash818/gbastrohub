import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomWheelPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onSelect;

  const CustomWheelPicker({super.key, required this.initialDate, required this.onSelect});

  @override
  State<CustomWheelPicker> createState() => _CustomWheelPickerState();
}

class _CustomWheelPickerState extends State<CustomWheelPicker> {
  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;
  late TextEditingController _manualYearController;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate.day;
    _selectedMonth = widget.initialDate.month;
    _selectedYear = widget.initialDate.year;

    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _yearController = FixedExtentScrollController(initialItem: _selectedYear - 1900);
    _manualYearController = TextEditingController(text: _selectedYear.toString());
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _manualYearController.dispose();
    super.dispose();
  }

  void _onYearTyped(String value) {
    if (value.length == 4) {
      int? year = int.tryParse(value);
      if (year != null && year >= 1900 && year <= 2200) {
        setState(() => _selectedYear = year);
        _yearController.animateToItem(year - 1900, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = AppColors.primary;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'தேதியைத் தேர்ந்தெடுங்கள்',
                      style: const TextStyle(
                        fontSize: 18,
                        color: orangeColor,
                        fontWeight: FontWeight.w900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    height: 35,
                    child: TextField(
                      controller: _manualYearController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: orangeColor, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Year',
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: orangeColor)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                      onChanged: _onYearTyped,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: orangeColor.withOpacity(0.1), width: double.infinity),
            const SizedBox(height: 20),
            
            // The Wheel Pickers
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                   // Selection Box
                  Center(
                    child: Container(
                      height: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: orangeColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWheelColumn(
                        controller: _dayController,
                        itemCount: 31,
                        onChanged: (index) => setState(() => _selectedDay = index + 1),
                        itemBuilder: (context, index) => Text('${index + 1}'.padLeft(2, '0')),
                      ),
                      _buildWheelColumn(
                        controller: _monthController,
                        itemCount: 12,
                        onChanged: (index) => setState(() => _selectedMonth = index + 1),
                        itemBuilder: (context, index) => Text(_months[index]),
                      ),
                      _buildWheelColumn(
                        controller: _yearController,
                        itemCount: 300,
                        onChanged: (index) {
                          setState(() {
                            _selectedYear = 1900 + index;
                            if (_manualYearController.text != _selectedYear.toString()) {
                              _manualYearController.text = _selectedYear.toString();
                            }
                          });
                        },
                        itemBuilder: (context, index) => Text('${1900 + index}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildTextButton('ரத்து (Cancel)', () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  _buildTextButton('சரி (Set)', () {
                    widget.onSelect(DateTime(_selectedYear, _selectedMonth, _selectedDay));
                    Navigator.pop(context);
                  }, isPrimary: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelColumn({
    required FixedExtentScrollController controller,
    required int itemCount,
    required Function(int) onChanged,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return SizedBox(
      width: 70,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 45,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            return Center(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
                child: itemBuilder(context, index),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextButton(String label, VoidCallback onPressed, {bool isPrimary = false}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isPrimary ? AppColors.primary : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isPrimary ? FontWeight.w900 : FontWeight.normal,
        ),
      ),
    );
  }
}
