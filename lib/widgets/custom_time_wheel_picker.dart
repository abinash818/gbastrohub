import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTimeWheelPicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final int initialSecond;
  final bool showSeconds;
  final Function(TimeOfDay)? onSelect;
  final Function(TimeOfDay, int)? onSelectWithSeconds;

  const CustomTimeWheelPicker({
    super.key,
    required this.initialTime,
    this.initialSecond = 0,
    this.showSeconds = false,
    this.onSelect,
    this.onSelectWithSeconds,
  });

  @override
  State<CustomTimeWheelPicker> createState() => _CustomTimeWheelPickerState();
}

class _CustomTimeWheelPickerState extends State<CustomTimeWheelPicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late int _selectedSecond;
  late DayPeriod _selectedPeriod;

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _secondController;
  late FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hourOfPeriod == 0 ? 12 : widget.initialTime.hourOfPeriod;
    _selectedMinute = widget.initialTime.minute;
    _selectedSecond = widget.initialSecond.clamp(0, 59);
    _selectedPeriod = widget.initialTime.period;

    _hourController = FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _secondController = FixedExtentScrollController(initialItem: _selectedSecond);
    _periodController = FixedExtentScrollController(initialItem: _selectedPeriod.index);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = AppColors.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: widget.showSeconds ? 340 : 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'நேரத்தைத் தேர்ந்தெடுங்கள்',
                  style: TextStyle(
                    fontSize: 18,
                    color: orangeColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Container(height: 1, color: orangeColor.withOpacity(0.1), width: double.infinity),
            const SizedBox(height: 12),
            if (widget.showSeconds)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    SizedBox(width: 52, child: Text('மணி', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    SizedBox(width: 52, child: Text('நிமிடம்', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    SizedBox(width: 52, child: Text('விநாடி', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    SizedBox(width: 52, child: Text('', textAlign: TextAlign.center)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                   // Selection Box
                  Center(
                    child: Container(
                      height: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        width: widget.showSeconds ? 52 : 60,
                        controller: _hourController,
                        itemCount: 12,
                        onChanged: (index) => setState(() => _selectedHour = index + 1),
                        itemBuilder: (context, index) => Text('${index + 1}'.padLeft(2, '0')),
                      ),
                      _buildWheelColumn(
                        width: widget.showSeconds ? 52 : 60,
                        controller: _minuteController,
                        itemCount: 60,
                        onChanged: (index) => setState(() => _selectedMinute = index),
                        itemBuilder: (context, index) => Text('$index'.padLeft(2, '0')),
                      ),
                      if (widget.showSeconds)
                        _buildWheelColumn(
                          width: 52,
                          controller: _secondController,
                          itemCount: 60,
                          onChanged: (index) => setState(() => _selectedSecond = index),
                          itemBuilder: (context, index) => Text('$index'.padLeft(2, '0')),
                        ),
                      _buildWheelColumn(
                        width: widget.showSeconds ? 52 : 60,
                        controller: _periodController,
                        itemCount: 2,
                        onChanged: (index) => setState(() => _selectedPeriod = DayPeriod.values[index]),
                        itemBuilder: (context, index) => Text(index == 0 ? 'AM' : 'PM'),
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
                    int hour = _selectedHour;
                    if (_selectedPeriod == DayPeriod.pm && hour != 12) hour += 12;
                    if (_selectedPeriod == DayPeriod.am && hour == 12) hour = 0;
                    final time = TimeOfDay(hour: hour, minute: _selectedMinute);
                    Navigator.pop(context);
                    if (widget.onSelectWithSeconds != null) {
                      widget.onSelectWithSeconds!(time, _selectedSecond);
                    } else if (widget.onSelect != null) {
                      widget.onSelect!(time);
                    }
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
    double width = 60,
  }) {
    return SizedBox(
      width: width,
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
