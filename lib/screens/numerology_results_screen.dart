import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../data/numerology_data.dart';

class NumerologyResultsScreen extends StatefulWidget {
  final String name;
  final DateTime dob;
  final int psychicNumber;
  final int destinyNumber;
  final int nameNumber;
  final int compoundNameNumber;
  final List<List<int>> pyramidData;
  final List<List<int>> dobPyramidData;

  const NumerologyResultsScreen({
    super.key,
    required this.name,
    required this.dob,
    required this.psychicNumber,
    required this.destinyNumber,
    required this.nameNumber,
    required this.compoundNameNumber,
    required this.pyramidData,
    required this.dobPyramidData,
  });

  @override
  State<NumerologyResultsScreen> createState() => _NumerologyResultsScreenState();
}

class _NumerologyResultsScreenState extends State<NumerologyResultsScreen> {
  bool _showDobPyramid = false;

  String _getTranslatedText(String key) {
    String lang = Localizations.localeOf(context).languageCode;
    
    Map<String, Map<String, String>> translations = {
      // Results Screen
      "சால்டியன் எண் (Chaldean No)": {"en": "Chaldean Number", "hi": "चाल्डियन संख्या", "ta": "சால்டியன் எண் (Chaldean No)"},
      "பெயரின் மொத்த கூட்டு எண் (Compound Number).": {"en": "Compound Name Number.", "hi": "यौगिक नाम संख्या।", "ta": "பெயரின் மொத்த கூட்டு எண் (Compound Number)."},
      "பெயர் எண் (Root No)": {"en": "Name Number (Root)", "hi": "नाम संख्या (रूट)", "ta": "பெயர் எண் (Root No)"},
      "பெயரின் ஒற்றை இலக்க எண் (Root Number).": {"en": "Single digit root number.", "hi": "एकल अंक रूट संख्या।", "ta": "பெயரின் ஒற்றை இலக்க எண் (Root Number)."},
      "எண் கணித பலன்கள்": {"en": "Numerology Results", "hi": "अंक ज्योतिष परिणाम", "ta": "எண் கணித பலன்கள்"},
      "காரணிகள்": {"en": "Factors", "hi": "कारक", "ta": "காரணிகள்"},
      "பரிந்துரைகள் / பலன்கள்": {"en": "Recommendations / Results", "hi": "सुझाव / परिणाम", "ta": "பரிந்துரைகள் / பலன்கள்"},
      "பிறந்த தேதி பிரமிடு": {"en": "DOB Pyramid", "hi": "जन्म तिथि पिरामिड", "ta": "பிறந்த தேதி பிரமிடு"},
      "பெயர் பிரமிடு": {"en": "Name Pyramid", "hi": "नाम पिरामिड", "ta": "பெயர் பிரமிடு"},
      "தகவல்கள் இல்லை": {"en": "No Data", "hi": "कोई जानकारी नहीं", "ta": "தகவல்கள் இல்லை"},
      "பிரமிடு எண்: ": {"en": "Pyramid Number: ", "hi": "पिरामिड संख्या: ", "ta": "பிரமிடு எண்: "},
      "பெயர்": {"en": "Name", "hi": "नाम", "ta": "பெயர்"},
      "பிறந்த தேதி": {"en": "DOB", "hi": "जन्म तिथि", "ta": "பிறந்த தேதி"},

      // Table Subjects
      "UdalEnn": {"en": "Body Number (Psychic)", "hi": "शरीर संख्या (मूलांक)", "ta": "உடல் எண்"},
      "UyirEnn": {"en": "Life Number (Destiny)", "hi": "जीवन संख्या (भाग्यांक)", "ta": "உயிர் எண்"},
      "அதிர்ஷ்ட பெயருக்கான பெயர் எண்கள்": {"en": "Lucky Name Numbers", "hi": "शुभ नाम संख्या", "ta": "அதிர்ஷ்ட பெயருக்கான பெயர் எண்கள்"},
      "அதிர்ஷ்ட தொழில்": {"en": "Lucky Profession", "hi": "शुभ व्यवसाय", "ta": "அதிர்ஷ்ட தொழில்"},
      "அதிர்ஷ்ட தொழிலிற்கான பெயர் எண்கள்": {"en": "Lucky Profession Numbers", "hi": "शुभ व्यवसाय संख्या", "ta": "அதிர்ஷ்ட தொழிலிற்கான பெயர் எண்கள்"},
      "வர வாய்ப்புள்ள நோய்கள்": {"en": "Possible Diseases", "hi": "संभावित रोग", "ta": "வர வாய்ப்புள்ள நோய்கள்"},
      "அதிர்ஷ்ட எண்கள்": {"en": "Lucky Numbers", "hi": "शुभ अंक", "ta": "அதிர்ஷ்ட எண்கள்"},
      "அதிர்ஷ்ட நாட்கள்": {"en": "Lucky Dates", "hi": "शुभ तिथियां", "ta": "அதிர்ஷ்ட நாட்கள்"},
      "அதிர்ஷ்டமில்லா நாட்கள்": {"en": "Unlucky Dates", "hi": "अशुभ तिथियां", "ta": "அதிர்ஷ்டமில்லா நாட்கள்"},
      "அதிஷ்டமான நிறங்கள்": {"en": "Lucky Colors", "hi": "शुभ रंग", "ta": "அதிஷ்டமான நிறங்கள்"},
      "அதிர்ஷ்டமில்லா நிறங்கள்": {"en": "Unlucky Colors", "hi": "अशुभ रंग", "ta": "அதிர்ஷ்டமில்லா நிறங்கள்"},
      "அதிஷ்டமான கற்கள்": {"en": "Lucky Stones", "hi": "शुभ रत्न", "ta": "அதிஷ்டமான கற்கள்"},
      "ஆட்சி செய்யும் கோள்கள்": {"en": "Ruling Planets", "hi": "सत्तारूढ़ ग्रह", "ta": "ஆட்சி செய்யும் கோள்கள்"},
      "அதிர்ஷ்ட கோள்கள்": {"en": "Lucky Planets", "hi": "शुभ ग्रह", "ta": "அதிர்ஷ்ட கோள்கள்"},
      "பிரச்சனைக்கான தீர்வு": {"en": "Solution for Problems", "hi": "समस्याओं का समाधान", "ta": "பிரச்சனைக்கான தீர்வு"},
      
      // Planets
      "சூரியன்": {"en": "Sun", "hi": "सूर्य", "ta": "சூரியன்"},
      "சந்திரன்": {"en": "Moon", "hi": "चंद्र", "ta": "சந்திரன்"},
      "செவ்வாய்": {"en": "Mars", "hi": "मंगल", "ta": "செவ்வாய்"},
      "புதன்": {"en": "Mercury", "hi": "बुध", "ta": "புதன்"},
      "குரு": {"en": "Jupiter", "hi": "गुरु", "ta": "குரு"},
      "சுக்கிரன்": {"en": "Venus", "hi": "शुक्र", "ta": "சுக்கிரன்"},
      "சுக்ரன்": {"en": "Venus", "hi": "शुक्र", "ta": "சுக்கிரன்"},
      "சனி": {"en": "Saturn", "hi": "शनि", "ta": "சனி"},
      "ராகு": {"en": "Rahu", "hi": "राहु", "ta": "ராகு"},
      "கேது": {"en": "Ketu", "hi": "केतु", "ta": "கேது"},
    };

    if (translations.containsKey(key)) {
      return translations[key]?[lang] ?? key;
    }

    // For strings like "சூரியன், புதன்", "சூரியன், சுக்ரன்"
    if (key.contains(",") && !key.contains(RegExp(r'\d'))) {
      List<String> parts = key.split(",");
      List<String> translatedParts = parts.map((p) {
        String trimmed = p.trim();
        return translations[trimmed]?[lang] ?? trimmed;
      }).toList();
      return translatedParts.join(", ");
    }
    
    // For strings like "புதன் மற்றும் புதன்"
    if (key.contains(" மற்றும் ")) {
      List<String> parts = key.split(" மற்றும் ");
      List<String> translatedParts = parts.map((p) {
        String trimmed = p.trim();
        return translations[trimmed]?[lang] ?? trimmed;
      }).toList();
      return translatedParts.join(lang == 'ta' ? ' மற்றும் ' : (lang == 'en' ? ' and ' : ' और '));
    }

    return key;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final bool isWide = MediaQuery.of(context).size.width > 900;

    Widget content;
    if (isWide) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildNumberCard(_getTranslatedText("சால்டியன் எண் (Chaldean No)"), widget.compoundNameNumber, _getTranslatedText("பெயரின் மொத்த கூட்டு எண் (Compound Number)."), Icons.calculate_outlined, const Color(0xFFB58D3D)),
                const SizedBox(height: 15),
                _buildNumberCard(_getTranslatedText("பெயர் எண் (Root No)"), widget.nameNumber, _getTranslatedText("பெயரின் ஒற்றை இலக்க எண் (Root Number)."), Icons.badge_outlined, const Color(0xFF5D1204)),
                const SizedBox(height: 30),
                _buildPyramidSection(),
              ],
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 6,
            child: _buildRecommendationsSection(),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          _buildNumberCard(_getTranslatedText("சால்டியன் எண் (Chaldean No)"), widget.compoundNameNumber, _getTranslatedText("பெயரின் மொத்த கூட்டு எண் (Compound Number)."), Icons.calculate_outlined, const Color(0xFFB58D3D)),
          const SizedBox(height: 15),
          _buildNumberCard(_getTranslatedText("பெயர் எண் (Root No)"), widget.nameNumber, _getTranslatedText("பெயரின் ஒற்றை இலக்க எண் (Root Number)."), Icons.badge_outlined, const Color(0xFF5D1204)),
          const SizedBox(height: 30),
          _buildPyramidSection(),
          _buildRecommendationsSection(),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: content,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    final String key = "${widget.psychicNumber},${widget.destinyNumber}";
    final recommendations = NUMEROLOGY_RECOMMENDATIONS[key] ?? [];

    List<Map<String, String>> tableData = [];
    
    // Add UdalEnn and UyirEnn at the top as per reference image
    tableData.add({"subject": "UdalEnn", "value": "${widget.psychicNumber}"});
    tableData.add({"subject": "UyirEnn", "value": "${widget.destinyNumber}"});
    
    // Add other recommendations
    for (var rec in recommendations) {
      final sub = rec['subject'];
      if (sub != "Subject" && sub != null && sub.isNotEmpty) {
        tableData.add({
          "subject": sub,
          "value": _getTranslatedText(rec['value']?.replaceAll('\\n', '\n').trim() ?? '')
        });
      }
    }

    if (tableData.length <= 2 && recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          _getTranslatedText('எண் கணித பலன்கள்'),
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
        ),
        const SizedBox(height: 15),
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
                1: FlexColumnWidth(1.2),
              },
              border: TableBorder.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1),
              children: [
                // Header Row
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFF5D1204)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Text(_getTranslatedText("காரணிகள்"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Text(_getTranslatedText("பரிந்துரைகள் / பலன்கள்"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                    ),
                  ],
                ),
                // Data Rows
                ...tableData.map((data) {
                  final isEven = tableData.indexOf(data) % 2 == 0;
                  return TableRow(
                    decoration: BoxDecoration(color: isEven ? const Color(0xFFFAF6EE).withOpacity(0.3) : Colors.white),
                    children: [
                      _buildTableCell(_getTranslatedText(data['subject']!), isSubject: true),
                      _buildTableCell(data['value']!, isValue: true),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isSubject = false, bool isValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: isSubject ? FontWeight.bold : FontWeight.w600,
          color: isSubject ? const Color(0xFF5D1204) : const Color(0xFFE65100),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildPyramidSection() {
    final List<List<int>> activeData = _showDobPyramid ? widget.dobPyramidData : widget.pyramidData;
    final String pyramidTitle = _showDobPyramid ? "பிறந்த தேதி பிரமிடு" : "பெயர் பிரமிடு";

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
          // Toggle buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _showDobPyramid = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_showDobPyramid ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getTranslatedText("பெயர்"),
                      style: TextStyle(
                        color: !_showDobPyramid ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _showDobPyramid = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _showDobPyramid ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getTranslatedText("பிறந்த தேதி"),
                      style: TextStyle(
                        color: _showDobPyramid ? Colors.white : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.change_history_rounded, color: Color(0xFFB58D3D), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _getTranslatedText(pyramidTitle),
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          if (activeData.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(_getTranslatedText("தகவல்கள் இல்லை"), style: const TextStyle(color: Colors.grey)),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: activeData.map((row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((num) {
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
                            "$num",
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
          if (activeData.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              "${_getTranslatedText("பிரமிடு எண்: ")}${activeData.last.first}",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: const Color(0xFFB58D3D)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildHeader(DateFormat dateFormat) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        border: Border(bottom: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1.0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFFAF6EE),
            child: const Icon(Icons.person_outline_rounded, size: 36, color: Color(0xFFB58D3D)),
          ),
          const SizedBox(height: 12),
          Text(
            widget.name,
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            dateFormat.format(widget.dob),
            style: GoogleFonts.outfit(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 14),
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
}

