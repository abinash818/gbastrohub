import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/numerology_service.dart';
import '../theme/app_colors.dart';

class VehicleMobileNumerologyView extends StatefulWidget {
  final TextEditingController? controller;
  const VehicleMobileNumerologyView({super.key, this.controller});

  @override
  State<VehicleMobileNumerologyView> createState() => _VehicleMobileNumerologyViewState();
}

class _VehicleMobileNumerologyViewState extends State<VehicleMobileNumerologyView> {
  late TextEditingController _inputController;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _inputController = widget.controller!;
    } else {
      _inputController = TextEditingController();
      _isInternalController = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _inputController.dispose();
    }
    super.dispose();
  }

  String _getTranslatedText(String key) {
    String lang = Localizations.localeOf(context).languageCode;
    Map<String, Map<String, String>> translations = {
      "வாகனம் / மொபைல் எண் (Vehicle / Mobile No)": {
        "en": "Vehicle / Mobile No",
        "hi": "वाहन / मोबाइल नंबर"
      },
      "எ.கா: TN 76 K 5406 அல்லது 9876543210": {
        "en": "e.g.: TN 76 K 5406 or 9876543210",
        "hi": "उदा: TN 76 K 5406 या 9876543210"
      },
      "சால்டியன் கூட்டு எண் (Chaldean No)": {
        "en": "Chaldean Compound No",
        "hi": "चाल्डियन यौगिक संख्या"
      },
      "மொத்த கூட்டு எண் (Compound Number).": {
        "en": "Total compound sum of letters and digits.",
        "hi": "अक्षरों और अंकों का कुल योग।"
      },
      "எளிய எண் (Root No)": {
        "en": "Root Number (Single Digit)",
        "hi": "मूलांक (एकल अंक)"
      },
      "ஒற்றை இலக்க எண் (Root Number).": {
        "en": "Single digit root number.",
        "hi": "एकल अंक रूट संख्या।"
      },
      "எழுத்து & எண் மதிப்பு (Chaldean Values)": {
        "en": "Chaldean Value Breakdown",
        "hi": "चाल्डियन मान विवरण"
      },
      "வாகனம் / மொபைல் பிரமிடு": {
        "en": "Vehicle / Mobile Pyramid",
        "hi": "वाहन / मोबाइल पिरामिड"
      },
      "பிரமிடு உச்ச எண்: ": {
        "en": "Pyramid Peak Number: ",
        "hi": "पिरामिड शीर्ष संख्या: "
      },
      "பிரமிடு எண் = ": {
        "en": "Pyramid No = ",
        "hi": "पिरामिड संख्या = "
      },
      "ஆளும் கிரகம்: ": {
        "en": "Ruling Planet: ",
        "hi": "सत्तारूढ़ ग्रह: "
      },
      "எண் பலன்கள் & சிறப்புகள்": {
        "en": "Numerological Attributes",
        "hi": "अंक ज्योतिष विशेषताएं"
      },
      "காரணிகள்": {"en": "Factors", "hi": "कारक"},
      "விவரங்கள்": {"en": "Details", "hi": "विवरण"},
      "ஆளும் கிரகம்": {"en": "Ruling Planet", "hi": "सत्तारूढ़ ग्रह"},
      "அதிர்ஷ்ட நிறம்": {"en": "Lucky Color", "hi": "शुभ रंग"},
      "உலோகம்": {"en": "Metal", "hi": "धातु"},
      "நட்பு எண்கள்": {"en": "Friendly Numbers", "hi": "मित्र अंक"},
      "முக்கிய பலன்": {"en": "Key Quality", "hi": "प्रमुख प्रभाव"},
    };
    return translations[key]?[lang] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(),
        const SizedBox(height: 20),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _inputController,
          builder: (context, value, child) {
            final rawText = value.text.trim();
            final cleanText = rawText.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

            if (cleanText.isEmpty) {
              return _buildEmptyPlaceholder();
            }

            final int compound = NumerologyService.calculateAlphanumericCompoundNumber(cleanText);
            final int root = NumerologyService.calculateAlphanumericRootNumber(cleanText);
            final List<Map<String, dynamic>> breakdown = NumerologyService.getCharacterBreakdown(cleanText);
            final List<List<int>> pyramid = NumerologyService.calculateAlphanumericPyramidData(cleanText);
            final Map<String, String> rootAttrs = NumerologyService.getNumberAttributes(root);
            final int peak = pyramid.isNotEmpty && pyramid.last.isNotEmpty ? pyramid.last.first : 0;
            final Map<String, String> peakAttrs = NumerologyService.getNumberAttributes(peak);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNumberCard(
                  _getTranslatedText("சால்டியன் கூட்டு எண் (Chaldean No)"),
                  compound,
                  _getTranslatedText("மொத்த கூட்டு எண் (Compound Number)."),
                  Icons.calculate_outlined,
                  const Color(0xFFB58D3D),
                ),
                const SizedBox(height: 14),
                _buildNumberCard(
                  _getTranslatedText("எளிய எண் (Root No)"),
                  root,
                  "${_getTranslatedText("ஒற்றை இலக்க எண் (Root Number).")} ${_getTranslatedText("ஆளும் கிரகம்: ")}${rootAttrs['planet']}",
                  Icons.stars_rounded,
                  const Color(0xFF5D1204),
                ),
                const SizedBox(height: 18),
                _buildBreakdownSection(breakdown),
                const SizedBox(height: 18),
                _buildPyramidSection(pyramid, peak, peakAttrs),
                const SizedBox(height: 18),
                _buildAttributesTable(root, rootAttrs),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return TextFormField(
      controller: _inputController,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5D1204), fontSize: 15),
      decoration: InputDecoration(
        labelText: _getTranslatedText("வாகனம் / மொபைல் எண் (Vehicle / Mobile No)"),
        hintText: _getTranslatedText("எ.கா: TN 76 K 5406 அல்லது 9876543210"),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        labelStyle: TextStyle(color: const Color(0xFF5D1204).withOpacity(0.6), fontSize: 13),
        prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.primary),
        suffixIcon: _inputController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                onPressed: () {
                  _inputController.clear();
                  setState(() {});
                },
              )
            : null,
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
      onChanged: (_) {
        setState(() {});
      },
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_filled_outlined, size: 48, color: const Color(0xFFB58D3D).withOpacity(0.7)),
          const SizedBox(height: 12),
          Text(
            "வாகனம் அல்லது மொபைல் எண்ணை உள்ளிடவும்",
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5D1204),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "செலிடியன் (Chaldean) முறையில் கூட்டு எண், ஒற்றை எண் மற்றும் முழு பிரமிடு உடனடியாக கணக்கிடப்படும்.",
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(String title, int number, String description, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
            ),
            child: Center(
              child: Text(
                "$number",
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: accentColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: accentColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection(List<Map<String, dynamic>> breakdown) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.view_column_outlined, size: 18, color: Color(0xFFB58D3D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getTranslatedText("எழுத்து & எண் மதிப்பு (Chaldean Values)"),
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: breakdown.map((item) {
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.5), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${item['char']}",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5D1204),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D1204),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${item['value']}",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPyramidSection(List<List<int>> pyramidData, int peak, Map<String, String> peakAttrs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.change_history_rounded, color: Color(0xFFB58D3D), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _getTranslatedText("வாகனம் / மொபைல் பிரமிடு"),
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: pyramidData.map((row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((val) {
                      bool isTail = row.length == 1;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isTail ? const Color(0xFF5D1204) : const Color(0xFFFAF6EE),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            "$val",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isTail ? FontWeight.w900 : FontWeight.w700,
                              color: isTail ? Colors.white : const Color(0xFF5D1204),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          if (pyramidData.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF6EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    "${_getTranslatedText("பிரமிடு எண் = ")}${NumerologyService.formatPyramidResult(pyramidData)}",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFF5D1204)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${_getTranslatedText("ஆளும் கிரகம்: ")}${peakAttrs['planet']}",
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB58D3D)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttributesTable(int root, Map<String, String> attrs) {
    final List<Map<String, String>> rows = [
      {"subject": "ஆளும் கிரகம்", "value": attrs['planet'] ?? '-'},
      {"subject": "அதிர்ஷ்ட நிறம்", "value": attrs['color'] ?? '-'},
      {"subject": "உலோகம்", "value": attrs['metal'] ?? '-'},
      {"subject": "நட்பு எண்கள்", "value": attrs['friendly'] ?? '-'},
      {"subject": "முக்கிய பலன்", "value": attrs['quality'] ?? '-'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getTranslatedText('எண் பலன்கள் & சிறப்புகள்'),
          style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D1204).withOpacity(0.04),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1.4),
              },
              border: TableBorder.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFF5D1204)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(
                        _getTranslatedText("காரணிகள்"),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(
                        _getTranslatedText("விவரங்கள்"),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                ...rows.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final r = entry.value;
                  final isEven = idx % 2 == 0;
                  return TableRow(
                    decoration: BoxDecoration(
                      color: isEven ? const Color(0xFFFAF6EE).withOpacity(0.3) : Colors.white,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Text(
                          _getTranslatedText(r['subject']!),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D1204),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Text(
                          r['value']!,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE65100),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
