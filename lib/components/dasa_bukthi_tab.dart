import 'package:flutter/material.dart';
import '../services/astro_translation_service.dart';

class DasaBukthiTab extends StatefulWidget {
  final Map<String, dynamic> fullData;

  const DasaBukthiTab({super.key, required this.fullData});

  @override
  State<DasaBukthiTab> createState() => _DasaBukthiTabState();
}

class _DasaBukthiTabState extends State<DasaBukthiTab> {
  Map<String, dynamic>? _selectedDasa;
  Map<String, dynamic>? _selectedBukthi;
  Map<String, dynamic>? _selectedAntharam;
  Map<String, dynamic>? _selectedSookshmam;
  Map<String, dynamic>? _selectedPranam;

  @override
  void initState() {
    super.initState();
    _initCurrentDasa();
  }

  String _getTranslatedText(String key) {
    String lang = Localizations.localeOf(context).languageCode;

    Map<String, Map<String, String>> translations = {
      "தசாபுத்தி விவரங்கள் இல்லை": {
        "en": "No Dasa Bukthi details",
        "hi": "कोई दशा भुक्ति विवरण नहीं",
      },
      "தசை": {"en": "Dasa", "hi": "दशा"},
      "புத்தி": {"en": "Bukthi", "hi": "भुक्ति"},
      "அந்தரம்": {"en": "Antharam", "hi": "अन्तरम"},
      "சூட்சுமம்": {"en": "Sookshmam", "hi": "सूक्ष्मम"},
      "பிராணம்": {"en": "Pranam", "hi": "प्राण"},
      "அதிபதி": {"en": "Lord", "hi": "स्वामी"},
      "ஆரம்பம்": {"en": "Start", "hi": "आरंभ"},
      "முடிவு": {"en": "End", "hi": "अंत"},
      "நடப்பு தசா புத்தி": {
        "en": "Current Dasa Bukthi",
        "hi": "वर्तमान दशा भुक्ति",
      },
      "எதுவும் தேர்ந்தெடுக்கப்படவில்லை": {
        "en": "Nothing selected",
        "hi": "कुछ भी नहीं चुना गया",
      },

      "தசை:": {"en": "Dasa:", "hi": "दशा:"},
      "புத்தி:": {"en": "Bukthi:", "hi": "भुक्ति:"},
      "அந்தரம்:": {"en": "Antharam:", "hi": "अन्तरम:"},
      "சூட்சுமம்:": {"en": "Sookshmam:", "hi": "सूक्ष्मम:"},
      "பிராணம்:": {"en": "Pranam:", "hi": "प्राण:"},

      // Planets/Lords in Tamil
      "சூரியன்": {"en": "Sun", "hi": "सूर्य"},
      "சந்திரன்": {"en": "Moon", "hi": "चंद्र"},
      "செவ்வாய்": {"en": "Mars", "hi": "मंगल"},
      "புதன்": {"en": "Mercury", "hi": "बुध"},
      "குரு": {"en": "Jupiter", "hi": "गुरु"},
      "சுக்கிரன்": {"en": "Venus", "hi": "शुक्र"},
      "சனி": {"en": "Saturn", "hi": "शनि"},
      "ராகு": {"en": "Rahu", "hi": "राहु"},
      "கேது": {"en": "Ketu", "hi": "केतु"},
    };

    return translations[key]?[lang] ?? key;
  }

  void _initCurrentDasa() {
    final List<dynamic>? dasaList = widget.fullData['dasa'];
    if (dasaList == null || dasaList.isEmpty) return;

    DateTime now = DateTime.now();
    final birthDt = widget.fullData['birth_dt'] as DateTime?;
    if (birthDt != null && now.isBefore(birthDt)) {
      now = birthDt;
    }

    for (var d in dasaList) {
      final dStart = d['start'] as DateTime?;
      final dEnd = d['end'] as DateTime?;
      if (dStart != null && dEnd != null && !now.isBefore(dStart) && now.isBefore(dEnd)) {
        _selectedDasa = d;
        final subPeriods = d['subPeriods'] as List?;
        if (subPeriods != null) {
          for (var b in subPeriods) {
            final bStart = b['start'] as DateTime?;
            final bEnd = b['end'] as DateTime?;
            if (bStart != null && bEnd != null && !now.isBefore(bStart) && now.isBefore(bEnd)) {
              _selectedBukthi = b;
              final antharams = b['subPeriods'] as List?;
              if (antharams != null) {
                for (var a in antharams) {
                  final aStart = a['start'] as DateTime?;
                  final aEnd = a['end'] as DateTime?;
                  if (aStart != null && aEnd != null && !now.isBefore(aStart) && now.isBefore(aEnd)) {
                    _selectedAntharam = a;
                    final sookshmams = a['subPeriods'] as List?;
                    if (sookshmams != null) {
                      for (var s in sookshmams) {
                        final sStart = s['start'] as DateTime?;
                        final sEnd = s['end'] as DateTime?;
                        if (sStart != null && sEnd != null && !now.isBefore(sStart) && now.isBefore(sEnd)) {
                          _selectedSookshmam = s;
                          final pranams = s['subPeriods'] as List?;
                          if (pranams != null) {
                            for (var p in pranams) {
                              final pStart = p['start'] as DateTime?;
                              final pEnd = p['end'] as DateTime?;
                              if (pStart != null && pEnd != null && !now.isBefore(pStart) && now.isBefore(pEnd)) {
                                _selectedPranam = p;
                                break;
                              }
                            }
                          }
                          break;
                        }
                      }
                    }
                    break;
                  }
                }
              }
              break;
            }
          }
        }
        break;
      }
    }

    if (_selectedDasa == null && dasaList.isNotEmpty) {
      _selectedDasa = dasaList.first;
      final subPeriods = _selectedDasa!['subPeriods'] as List? ?? [];
      if (subPeriods.isNotEmpty) {
        _selectedBukthi = subPeriods.firstWhere(
          (b) => !(b['end'] as DateTime).isBefore(birthDt ?? dasaList.first['start']),
          orElse: () => subPeriods.first,
        );
      }
    }
  }

  String _calculateAge(DateTime? targetDate) {
    if (targetDate == null)
      return "${_getTranslatedAgePrefix()} 0 ${_getTranslatedAgeUnits()[0]}, 0 ${_getTranslatedAgeUnits()[1]}, 0 ${_getTranslatedAgeUnits()[2]}";
    final dob = widget.fullData['birth_dt'] as DateTime?;
    if (dob == null)
      return "${_getTranslatedAgePrefix()} 0 ${_getTranslatedAgeUnits()[0]}, 0 ${_getTranslatedAgeUnits()[1]}, 0 ${_getTranslatedAgeUnits()[2]}";

    int years = targetDate.year - dob.year;
    int months = targetDate.month - dob.month;
    int days = targetDate.day - dob.day;

    if (days < 0) {
      months -= 1;
      days += DateTime(targetDate.year, targetDate.month, 0).day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (years < 0) years = 0;
    if (months < 0) months = 0;
    if (days < 0) days = 0;

    return "${_getTranslatedAgePrefix()} $years ${_getTranslatedAgeUnits()[0]}, $months ${_getTranslatedAgeUnits()[1]}, $days ${_getTranslatedAgeUnits()[2]}";
  }

  String _getTranslatedAgePrefix() {
    String lang = Localizations.localeOf(context).languageCode;
    if (lang == 'en') return "Age :";
    if (lang == 'hi') return "आयु :";
    return "வயது :";
  }

  List<String> _getTranslatedAgeUnits() {
    String lang = Localizations.localeOf(context).languageCode;
    if (lang == 'en') return ["y", "m", "d"];
    if (lang == 'hi') return ["व", "म", "दि"];
    return ["வ", "மா", "நா"];
  }

  String _formatDateOnly(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return "$d-$m-$y";
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;

    if (isWide) {
      return _buildWideDasaView();
    } else {
      return _buildDasaView();
    }
  }

  Widget _buildDasaView() {
    final List<dynamic>? dasaList = widget.fullData['dasa'];
    if (dasaList == null)
      return Center(
        child: Text(_getTranslatedText('தசாபுத்தி விவரங்கள் இல்லை')),
      );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 1. Dasa Section
          _buildDasaSection(
            _getTranslatedText("தசை"),
            dasaList,
            _selectedDasa,
            (selected) {
              setState(() {
                if (_selectedDasa == selected) {
                  _selectedDasa = null;
                  _selectedBukthi = null;
                  _selectedAntharam = null;
                  _selectedSookshmam = null;
                  _selectedPranam = null;
                } else {
                  _selectedDasa = selected;
                  _selectedBukthi = null;
                  _selectedAntharam = null;
                  _selectedSookshmam = null;
                  _selectedPranam = null;
                }
              });
            },
          ),

          // 2. Bhukti Section
          if (_selectedDasa != null) ...[
            const SizedBox(height: 20),
            _buildDasaSection(
              _getTranslatedText("புத்தி"),
              _selectedDasa!['subPeriods'] ?? [],
              _selectedBukthi,
              (selected) {
                setState(() {
                  if (_selectedBukthi == selected) {
                    _selectedBukthi = null;
                    _selectedAntharam = null;
                    _selectedSookshmam = null;
                    _selectedPranam = null;
                  } else {
                    _selectedBukthi = selected;
                    _selectedAntharam = null;
                    _selectedSookshmam = null;
                    _selectedPranam = null;
                  }
                });
              },
            ),
          ],

          // 3. Antharam Section
          if (_selectedBukthi != null) ...[
            const SizedBox(height: 20),
            _buildDasaSection(
              _getTranslatedText("அந்தரம்"),
              _selectedBukthi!['subPeriods'] ?? [],
              _selectedAntharam,
              (selected) {
                setState(() {
                  if (_selectedAntharam == selected) {
                    _selectedAntharam = null;
                    _selectedSookshmam = null;
                    _selectedPranam = null;
                  } else {
                    _selectedAntharam = selected;
                    _selectedSookshmam = null;
                    _selectedPranam = null;
                  }
                });
              },
            ),
          ],

          // 4. Sookshmam Section
          if (_selectedAntharam != null) ...[
            const SizedBox(height: 20),
            _buildDasaSection(
              _getTranslatedText("சூட்சுமம்"),
              _selectedAntharam!['subPeriods'] ?? [],
              _selectedSookshmam,
              (selected) {
                setState(() {
                  if (_selectedSookshmam == selected) {
                    _selectedSookshmam = null;
                    _selectedPranam = null;
                  } else {
                    _selectedSookshmam = selected;
                    _selectedPranam = null;
                  }
                });
              },
            ),
          ],

          // 5. Pranam Section
          if (_selectedSookshmam != null) ...[
            const SizedBox(height: 20),
            _buildDasaSection(
              _getTranslatedText("பிராணம்"),
              _selectedSookshmam!['subPeriods'] ?? [],
              _selectedPranam,
              (selected) {
                setState(() {
                  if (_selectedPranam == selected) {
                    _selectedPranam = null;
                  } else {
                    _selectedPranam = selected;
                  }
                });
              },
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDasaSection(
    String title,
    List<dynamic> periods,
    Map<String, dynamic>? selectedItem,
    Function(Map<String, dynamic>) onSelect,
  ) {
    final List<dynamic> displayList = selectedItem != null
        ? [selectedItem]
        : periods;
    final bool isHeaderStyle = selectedItem != null;

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF5D1204),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            border: TableBorder.all(
              color: const Color(0xFFB58D3D).withOpacity(0.3),
              width: 0.8,
            ),
            columnWidths: const {
              0: FixedColumnWidth(35),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF5D1204)),
                children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Text(
                        "No",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Text(
                        _getTranslatedText("அதிபதி"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Text(
                        _getTranslatedText("ஆரம்பம்"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Text(
                        _getTranslatedText("முடிவு"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ...List.generate(displayList.length, (index) {
                final p = displayList[index];
                int originalIdx = periods.indexOf(p) + 1;

                final bool isToday =
                    DateTime.now().isAfter(p['start']) &&
                    DateTime.now().isBefore(p['end']);

                return TableRow(
                  children: [
                    _buildInteractiveCell(
                      originalIdx.toString(),
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isHeaderStyle,
                    ),
                    _buildInteractiveCell(
                      AstroTranslationService.translate(context, p['lord']?.toString().trim() ?? "-", isPlanet: true),
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isHeaderStyle,
                    ),
                    _buildInteractiveCell(
                      _formatDateOnly(p['start']),
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isHeaderStyle,
                    ),
                    _buildInteractiveCell(
                      _formatDateOnly(p['end']),
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isHeaderStyle,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveCell(
    String text, {
    required VoidCallback onTap,
    bool isToday = false,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isToday
              ? const Color(0xFFFFD54F).withOpacity(0.3)
              : (isSelected ? const Color(0xFFFAF6EE) : Colors.white),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF5D1204),
            fontWeight: (isToday || isSelected)
                ? FontWeight.w900
                : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildWideDasaView() {
    final List<dynamic>? dasaList = widget.fullData['dasa'];
    if (dasaList == null)
      return Center(
        child: Text(_getTranslatedText('தசாபுத்தி விவரங்கள் இல்லை')),
      );

    final selectedBukthiList = _selectedDasa != null
        ? (_selectedDasa!['subPeriods'] as List? ?? [])
        : [];
    final selectedAntharamList = _selectedBukthi != null
        ? (_selectedBukthi!['subPeriods'] as List? ?? [])
        : [];
    final selectedSookshmamList = _selectedAntharam != null
        ? (_selectedAntharam!['subPeriods'] as List? ?? [])
        : [];
    final selectedPranamList = _selectedSookshmam != null
        ? (_selectedSookshmam!['subPeriods'] as List? ?? [])
        : [];

    DateTime? activeDate =
        _selectedPranam?['start'] ??
        _selectedSookshmam?['start'] ??
        _selectedAntharam?['start'] ??
        _selectedBukthi?['start'] ??
        _selectedDasa?['start'];

    String currentSelectionStr = "";
    if (_selectedDasa != null)
      currentSelectionStr +=
          "${_getTranslatedText("தசை:")} ${_getTranslatedText(_selectedDasa!['lord'])}\n";
    if (_selectedBukthi != null)
      currentSelectionStr +=
          "${_getTranslatedText("புத்தி:")} ${_getTranslatedText(_selectedBukthi!['lord'])}\n";
    if (_selectedAntharam != null)
      currentSelectionStr +=
          "${_getTranslatedText("அந்தரம்:")} ${_getTranslatedText(_selectedAntharam!['lord'])}\n";
    if (_selectedSookshmam != null)
      currentSelectionStr +=
          "${_getTranslatedText("சூட்சுமம்:")} ${_getTranslatedText(_selectedSookshmam!['lord'])}\n";
    if (_selectedPranam != null)
      currentSelectionStr +=
          "${_getTranslatedText("பிராணம்:")} ${_getTranslatedText(_selectedPranam!['lord'])}";

    String dateRangeStr = "";
    if (_selectedPranam != null) {
      dateRangeStr =
          "${_formatDateOnly(_selectedPranam!['start'])}  -  ${_formatDateOnly(_selectedPranam!['end'])}";
    } else if (_selectedSookshmam != null) {
      dateRangeStr =
          "${_formatDateOnly(_selectedSookshmam!['start'])}  -  ${_formatDateOnly(_selectedSookshmam!['end'])}";
    } else if (_selectedAntharam != null) {
      dateRangeStr =
          "${_formatDateOnly(_selectedAntharam!['start'])}  -  ${_formatDateOnly(_selectedAntharam!['end'])}";
    } else if (_selectedBukthi != null) {
      dateRangeStr =
          "${_formatDateOnly(_selectedBukthi!['start'])}  -  ${_formatDateOnly(_selectedBukthi!['end'])}";
    } else if (_selectedDasa != null) {
      dateRangeStr =
          "${_formatDateOnly(_selectedDasa!['start'])}  -  ${_formatDateOnly(_selectedDasa!['end'])}";
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDasaTableWide(
                          _getTranslatedText("தசை"),
                          dasaList,
                          _selectedDasa,
                          (selected) {
                            setState(() {
                              _selectedDasa = selected;
                              _selectedBukthi = null;
                              _selectedAntharam = null;
                              _selectedSookshmam = null;
                              _selectedPranam = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDasaTableWide(
                          _getTranslatedText("புத்தி"),
                          selectedBukthiList,
                          _selectedBukthi,
                          (selected) {
                            setState(() {
                              _selectedBukthi = selected;
                              _selectedAntharam = null;
                              _selectedSookshmam = null;
                              _selectedPranam = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDasaTableWide(
                          _getTranslatedText("அந்தரம்"),
                          selectedAntharamList,
                          _selectedAntharam,
                          (selected) {
                            setState(() {
                              _selectedAntharam = selected;
                              _selectedSookshmam = null;
                              _selectedPranam = null;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDasaTableWide(
                          _getTranslatedText("சூட்சுமம்"),
                          selectedSookshmamList,
                          _selectedSookshmam,
                          (selected) {
                            setState(() {
                              _selectedSookshmam = selected;
                              _selectedPranam = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (selectedPranamList.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDasaTableWide(
                            _getTranslatedText("பிராணம்"),
                            selectedPranamList,
                            _selectedPranam,
                            (selected) {
                              setState(() {
                                _selectedPranam = selected;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _getTranslatedText("நடப்பு தசா புத்தி"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF5D1204),
                    ),
                  ),
                  const Divider(color: Color(0xFFB58D3D)),
                  const SizedBox(height: 10),
                  Text(
                    currentSelectionStr.isEmpty
                        ? _getTranslatedText("எதுவும் தேர்ந்தெடுக்கப்படவில்லை")
                        : currentSelectionStr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _calculateAge(activeDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dateRangeStr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDasaTableWide(
    String title,
    List<dynamic> periods,
    Map<String, dynamic>? selectedItem,
    Function(Map<String, dynamic>) onSelect,
  ) {
    if (periods.isEmpty) return const SizedBox();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF5D1204),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            border: TableBorder.all(
              color: const Color(0xFFB58D3D).withOpacity(0.3),
              width: 0.8,
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAF6EE)),
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _getTranslatedText("அதிபதி"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF5D1204),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _getTranslatedText("ஆரம்பம்"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF5D1204),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _getTranslatedText("முடிவு"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF5D1204),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ...periods.map((p) {
                final bool isSelected = selectedItem == p;
                final bool isToday =
                    DateTime.now().isAfter(p['start']) &&
                    DateTime.now().isBefore(p['end']);

                return TableRow(
                  children: [
                    _buildInteractiveCellWide(
                      AstroTranslationService.translate(context, p['lord']?.toString().trim() ?? "-", isPlanet: true),
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isSelected,
                    ),
                    _buildInteractiveCellWide(
                      _formatDateOnly(p['start']),
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isSelected,
                    ),
                    _buildInteractiveCellWide(
                      _formatDateOnly(p['end']),
                      onTap: () => onSelect(p),
                      isToday: isToday,
                      isSelected: isSelected,
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveCellWide(
    String text, {
    required VoidCallback onTap,
    bool isToday = false,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: isToday
              ? const Color(0xFFFFD54F).withOpacity(0.3)
              : (isSelected ? const Color(0xFFE8F5E9) : Colors.white),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isToday ? Colors.red.shade900 : const Color(0xFF5D1204),
            fontWeight: (isToday || isSelected)
                ? FontWeight.w900
                : FontWeight.w500,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}
