import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class CustomDateInputField extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onChanged;

  const CustomDateInputField({
    super.key,
    required this.initialDate,
    required this.onChanged,
  });

  @override
  State<CustomDateInputField> createState() => _CustomDateInputFieldState();
}

class _CustomDateInputFieldState extends State<CustomDateInputField> {
  late TextEditingController _dayCtrl;
  late TextEditingController _monthCtrl;
  late TextEditingController _yearCtrl;

  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _dayCtrl = TextEditingController(text: widget.initialDate.day.toString().padLeft(2, '0'));
    _monthCtrl = TextEditingController(text: widget.initialDate.month.toString().padLeft(2, '0'));
    _yearCtrl = TextEditingController(text: widget.initialDate.year.toString());

    _dayFocus.addListener(() {
      if (_dayFocus.hasFocus) {
        Future.microtask(() => _dayCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _dayCtrl.text.length));
      }
    });
    _monthFocus.addListener(() {
      if (_monthFocus.hasFocus) {
        Future.microtask(() => _monthCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _monthCtrl.text.length));
      }
    });
    _yearFocus.addListener(() {
      if (_yearFocus.hasFocus) {
        Future.microtask(() => _yearCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _yearCtrl.text.length));
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomDateInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      if (!_dayFocus.hasFocus) _dayCtrl.text = widget.initialDate.day.toString().padLeft(2, '0');
      if (!_monthFocus.hasFocus) _monthCtrl.text = widget.initialDate.month.toString().padLeft(2, '0');
      if (!_yearFocus.hasFocus) _yearCtrl.text = widget.initialDate.year.toString();
    }
  }

  @override
  void dispose() {
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _notifyChange() {
    int? d = int.tryParse(_dayCtrl.text);
    int? m = int.tryParse(_monthCtrl.text);
    int? y = int.tryParse(_yearCtrl.text);

    if (d != null && m != null && y != null) {
      if (d >= 1 && d <= 31 && m >= 1 && m <= 12 && y >= 1900 && y <= 2100) {
        widget.onChanged(DateTime(y, m, d));
      }
    }
  }

  Widget _buildField(TextEditingController ctrl, FocusNode focus, int maxLength, String hint, FocusNode? nextFocus, FocusNode? prevFocus) {
    return SizedBox(
      width: maxLength == 4 ? 46 : 28,
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
        _buildField(_dayCtrl, _dayFocus, 2, "DD", _monthFocus, null),
        const Text("/", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
        _buildField(_monthCtrl, _monthFocus, 2, "MM", _yearFocus, _dayFocus),
        const Text("/", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
        _buildField(_yearCtrl, _yearFocus, 4, "YYYY", null, _monthFocus),
      ],
    );
  }
}
