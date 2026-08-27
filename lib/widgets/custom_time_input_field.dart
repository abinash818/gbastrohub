import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class CustomTimeInputField extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onChanged;

  const CustomTimeInputField({
    super.key,
    required this.initialTime,
    required this.onChanged,
  });

  @override
  State<CustomTimeInputField> createState() => _CustomTimeInputFieldState();
}

class _CustomTimeInputFieldState extends State<CustomTimeInputField> {
  late TextEditingController _hourCtrl;
  late TextEditingController _minuteCtrl;
  late DayPeriod _period;

  final FocusNode _hourFocus = FocusNode();
  final FocusNode _minuteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    int h = widget.initialTime.hourOfPeriod;
    if (h == 0) h = 12;
    _hourCtrl = TextEditingController(text: h.toString().padLeft(2, '0'));
    _minuteCtrl = TextEditingController(text: widget.initialTime.minute.toString().padLeft(2, '0'));
    _period = widget.initialTime.period;

    _hourFocus.addListener(() {
      if (_hourFocus.hasFocus) {
        Future.microtask(() => _hourCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _hourCtrl.text.length));
      }
    });
    _minuteFocus.addListener(() {
      if (_minuteFocus.hasFocus) {
        Future.microtask(() => _minuteCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _minuteCtrl.text.length));
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomTimeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime != widget.initialTime) {
      int h = widget.initialTime.hourOfPeriod;
      if (h == 0) h = 12;
      if (!_hourFocus.hasFocus) _hourCtrl.text = h.toString().padLeft(2, '0');
      if (!_minuteFocus.hasFocus) _minuteCtrl.text = widget.initialTime.minute.toString().padLeft(2, '0');
      _period = widget.initialTime.period;
    }
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _hourFocus.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  void _notifyChange() {
    int? h = int.tryParse(_hourCtrl.text);
    int? m = int.tryParse(_minuteCtrl.text);

    if (h != null) {
      bool needUpdate = false;
      if (h > 12 && h <= 23) {
        h = h - 12;
        _period = DayPeriod.pm;
        needUpdate = true;
      } else if ((h == 0 && _hourCtrl.text.length == 2) || h == 24) {
        h = 12;
        _period = DayPeriod.am;
        needUpdate = true;
      }

      if (needUpdate) {
        _hourCtrl.text = h.toString().padLeft(2, '0');
        if (_hourFocus.hasFocus) {
          _hourCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _hourCtrl.text.length));
        }
        setState(() {});
      }

      if (m != null && h >= 1 && h <= 12 && m >= 0 && m <= 59) {
        int hour24 = h;
        if (_period == DayPeriod.am && h == 12) hour24 = 0;
        if (_period == DayPeriod.pm && h < 12) hour24 = h + 12;
        widget.onChanged(TimeOfDay(hour: hour24, minute: m));
      }
    }
  }

  void _togglePeriod() {
    setState(() {
      _period = _period == DayPeriod.am ? DayPeriod.pm : DayPeriod.am;
    });
    // Manually trigger widget.onChanged to respect the toggled period
    int? h = int.tryParse(_hourCtrl.text);
    int? m = int.tryParse(_minuteCtrl.text);
    if (h != null && m != null && h >= 1 && h <= 12 && m >= 0 && m <= 59) {
        int hour24 = h;
        if (_period == DayPeriod.am && h == 12) hour24 = 0;
        if (_period == DayPeriod.pm && h < 12) hour24 = h + 12;
        widget.onChanged(TimeOfDay(hour: hour24, minute: m));
    }
  }

  Widget _buildField(TextEditingController ctrl, FocusNode focus, int maxLength, String hint, FocusNode? nextFocus, FocusNode? prevFocus) {
    return SizedBox(
      width: 28,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowRight && ctrl.selection.baseOffset == ctrl.text.length) {
              if (nextFocus != null) {
                nextFocus.requestFocus();
                return KeyEventResult.handled;
              }
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && ctrl.selection.baseOffset == 0) {
              if (prevFocus != null) {
                prevFocus.requestFocus();
                return KeyEventResult.handled;
              }
            }
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: ctrl,
          focusNode: focus,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: maxLength,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
          decoration: InputDecoration(
            counterText: "",
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onChanged: (val) {
            if (val.length == maxLength && nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
            _notifyChange();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildField(_hourCtrl, _hourFocus, 2, "HH", _minuteFocus, null),
        const Text(":", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
        _buildField(_minuteCtrl, _minuteFocus, 2, "MM", null, _hourFocus),
        const SizedBox(width: 4),
        InkWell(
          onTap: _togglePeriod,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _period == DayPeriod.am ? "AM" : "PM",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
