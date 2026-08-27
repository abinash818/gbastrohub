import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/matching_engine.dart';
import '../services/matching_result.dart';
import '../services/astro_data.dart';
import '../services/kp_service.dart';
import '../components/custom_drawer.dart';
import '../components/south_indian_chart.dart';
import '../theme/app_colors.dart';
import '../components/dasa_bukthi_tab.dart';

import '../services/marriage_matching_pdf_service.dart';
import '../screens/pdf_viewer_screen.dart';
import 'package:flutter/foundation.dart';
import '../l10n/app_localizations.dart';

class MarriageMatchingResultsScreen extends StatefulWidget {
  final String girlStar;
  final int girlPada;
  final String boyStar;
  final int boyPada;
  final Map<String, dynamic>? girlFullData;
  final Map<String, dynamic>? boyFullData;

  const MarriageMatchingResultsScreen({
    super.key,
    required this.girlStar,
    required this.girlPada,
    required this.boyStar,
    required this.boyPada,
    this.girlFullData,
    this.boyFullData,
  });

  @override
  State<MarriageMatchingResultsScreen> createState() => _MarriageMatchingResultsScreenState();
}

class _MarriageMatchingResultsScreenState extends State<MarriageMatchingResultsScreen> {
  bool _isGenerating = false;

  String _getTranslatedText(String key) {
    String lang = Localizations.localeOf(context).languageCode;
    
    Map<String, Map<String, String>> translations = {
      "பொருத்த முடிவுகள்": {"en": "Matching Results", "hi": "मिलान परिणाम"},
      "பொருத்தம் உள்ளதா?": {"en": "Is there a Match?", "hi": "क्या मिलान है?"},
      "ஜோதிடர் குறிப்பில் என்ன இடம்பெற வேண்டும்?": {"en": "What should be noted by the Astrologer?", "hi": "ज्योतिषी द्वारा क्या ध्यान दिया जाना चाहिए?"},
      "பொருத்தம் இல்லை": {"en": "No Match", "hi": "मिलान नहीं"},
      "பொருத்தம் உள்ளது": {"en": "Match Found", "hi": "मिलान मिला"},
      
      "விவரம்": {"en": "Details", "hi": "विवरण"},
      "பெண் ஜாதகம்": {"en": "Bride Horoscope", "hi": "दुल्हन की कुंडली"},
      "ஆண் ஜாதகம்": {"en": "Groom Horoscope", "hi": "दूल्हे की कुंडली"},
      "பெண் தசா புத்தி": {"en": "Bride Dasa Bukthi", "hi": "दुल्हन की दशा भुक्ति"},
      "ஆண் தசா புத்தி": {"en": "Groom Dasa Bukthi", "hi": "दूल्हे की दशा भुक्ति"},
      "பொருத்தம்": {"en": "Matching", "hi": "मिलान"},
      
      "பெண் விவரம்": {"en": "Bride Details", "hi": "दुल्हन का विवरण"},
      "ஆண் விவரம்": {"en": "Groom Details", "hi": "दूल्हे का विवरण"},
      "பெயர்": {"en": "Name", "hi": "नाम"},
      "ராசி": {"en": "Rasi", "hi": "राशि"},
      "நட்சத்திரம்": {"en": "Star", "hi": "नक्षत्र"},
      "பாதம்": {"en": "Pada", "hi": "पद"},
      "லக்னம்": {"en": "Lagna", "hi": "लग्न"},
      
      "பஞ்சாங்க விவரங்கள்": {"en": "Panchangam Details", "hi": "पंचांग विवरण"},
      "தமிழ் வருடம்": {"en": "Tamil Year", "hi": "तमिल वर्ष"},
      "தமிழ் தேதி": {"en": "Tamil Date", "hi": "तमिल तिथि"},
      "திதி": {"en": "Tithi", "hi": "तिथि"},
      "யோகம்": {"en": "Yoga", "hi": "योग"},
      "கரணம்": {"en": "Karana", "hi": "करण"},
      
      "ராசி கட்டம்": {"en": "Rasi Chart", "hi": "राशि चक्र"},
      "அம்ச கட்டம்": {"en": "Amsam Chart", "hi": "नवांश चक्र"},
      "பாவக கட்டம்": {"en": "Pavagam Chart", "hi": "भाव चक्र"},
      
      "பெண்": {"en": "Bride", "hi": "दुल्हन"},
      "ஆண்": {"en": "Groom", "hi": "दूल्हा"},
      "மொத்த பொருத்தம்:": {"en": "Total Match:", "hi": "कुल मिलान:"},
      "பத்து பொருத்தங்கள்": {"en": "Ten Matches", "hi": "दस मिलान"},
      
      "ஜாதக ரீதியான தோஷங்கள்": {"en": "Horoscope Doshas", "hi": "कुंडली दोष"},
      "செவ்வாய் தோஷம் (Mars)": {"en": "Mars Dosha (Chevvai)", "hi": "मंगल दोष"},
      "ராகு-கேது தோஷம் (Rahu-Ketu)": {"en": "Rahu-Ketu Dosha", "hi": "राहु-केतु दोष"},
      "தசா சந்தி (Dasa Sandhi)": {"en": "Dasa Sandhi", "hi": "दशा संधि"},
      
      "இருக்கிறது": {"en": "Yes", "hi": "हाँ"},
      "இல்லை": {"en": "No", "hi": "नहीं"},
      "தசா சந்தி உள்ளது": {"en": "Dasa Sandhi Exists", "hi": "दशा संधि है"},
      "தசா சந்தி இல்லை": {"en": "No Dasa Sandhi", "hi": "दशा संधि नहीं है"},
      "பொருத்தம்: உத்தமம்": {"en": "Match: Uthamam", "hi": "मिलान: उत्तम"},
      "பொருத்தம்: அதமம்": {"en": "Match: Adhamam", "hi": "मिलान: अधम"},
      
      // Values to translate
      "உத்தமம்": {"en": "Uthamam", "hi": "उत्तम"},
      "மத்திமம்": {"en": "Mathimam", "hi": "मध्यम"},
      "அதமம்": {"en": "Adhamam", "hi": "अधम"},
      "தினப் பொருத்தம்": {"en": "Dina Match", "hi": "दिन मिलान"},
      "கணப் பொருத்தம்": {"en": "Gana Match", "hi": "गण मिलान"},
      "மகேந்திரப் பொருத்தம்": {"en": "Mahendra Match", "hi": "महेन्द्र मिलान"},
      "ஸ்திரீ தீர்க்கப் பொருத்தம்": {"en": "Stree Dheerga Match", "hi": "स्त्री दीर्घ मिलान"},
      "யோனிப் பொருத்தம்": {"en": "Yoni Match", "hi": "योनि मिलान"},
      "ராசிப் பொருத்தம்": {"en": "Rasi Match", "hi": "राशि मिलान"},
      "ராசி அதிபதிப் பொருத்தம்": {"en": "Rasi Athipathi Match", "hi": "राश्याधिपति मिलान"},
      "வசியப் பொருத்தம்": {"en": "Vasiya Match", "hi": "वश्य मिलान"},
      "ரஜ்ஜுப் பொருத்தம்": {"en": "Rajju Match", "hi": "रज्जु मिलान"},
      "வேதைப் பொருத்தம்": {"en": "Vedhai Match", "hi": "वेध मिलान"},
      "நாடிப் பொருத்தம்": {"en": "Nadi Match", "hi": "नाड़ी मिलान"},

      // Panchangam/Astrology values
      "பராபவ": {"en": "Parabhava", "hi": "पराभव"},
      "ஆடி": {"en": "Aadi", "hi": "आडी"},
      "புதன்": {"en": "Wednesday", "hi": "बुधवार"},
      "சப்தமி": {"en": "Saptami", "hi": "सप्तमी"},
      "சூலம்": {"en": "Soolam", "hi": "शूल"},
      "கண்டம்": {"en": "Kandam", "hi": "गण्ड"},
      "பவம்": {"en": "Bavam", "hi": "बव"},
      "அசுவனி": {"en": "Ashwini", "hi": "अश्विनी"}, "பரணி": {"en": "Bharani", "hi": "भरणी"}, "கிருத்திகை": {"en": "Krittika", "hi": "कृत्तिका"}, "ரோகிணி": {"en": "Rohini", "hi": "रोहिणी"}, "மிருகசீர்ஷம்": {"en": "Mrigashirsha", "hi": "मृगशीर्ष"}, "திருவாதிரை": {"en": "Arudra", "hi": "आर्द्रा"}, "புனர்பூசம்": {"en": "Punarvasu", "hi": "पुनर्वसु"}, "பூசம்": {"en": "Pushya", "hi": "पुष्य"}, "ஆயில்யம்": {"en": "Aslesha", "hi": "आश्लेषा"}, "மகம்": {"en": "Magha", "hi": "मघा"}, "பூரம்": {"en": "Purvaphalguni", "hi": "पूर्वाफाल्गुनी"}, "உத்திரம்": {"en": "Uttaraphalguni", "hi": "उत्तराफाल्गुनी"}, "அஸ்தம்": {"en": "Hastha", "hi": "हस्त"}, "சித்திரை": {"en": "Chitra", "hi": "चित्रा"}, "சுவாதி": {"en": "Swati", "hi": "स्वाती"}, "விசாகம்": {"en": "Vishakha", "hi": "विशाखा"}, "அனுஷம்": {"en": "Anuradha", "hi": "अनुराधा"}, "கேட்டை": {"en": "Jyeshta", "hi": "ज्येष्ठा"}, "மூலம்": {"en": "Mula", "hi": "मूल"}, "பூராடம்": {"en": "Purvashada", "hi": "पूर्वाषाढ़ा"}, "உத்திராடம்": {"en": "Uttarashada", "hi": "उत्तराषाढ़ा"}, "திருவோணம்": {"en": "Shravana", "hi": "श्रवण"}, "அவிட்டம்": {"en": "Dhanishta", "hi": "धनिष्ठा"}, "சதயம்": {"en": "Shatabhisha", "hi": "शतभिषा"}, "பூரட்டாதி": {"en": "Purvabhadrapada", "hi": "पूर्वाभाद्रपद"}, "உத்திரட்டாதி": {"en": "Uttarabhadrapada", "hi": "उत्तराभाद्रपद"}, "ரேவதி": {"en": "Revati", "hi": "रेवती"},
      "மேஷம்": {"en": "Aries", "hi": "मेष"}, "ரிஷபம்": {"en": "Taurus", "hi": "वृषभ"}, "மிதுனம்": {"en": "Gemini", "hi": "मिथुन"}, "கடகம்": {"en": "Cancer", "hi": "कर्क"}, "சிம்மம்": {"en": "Leo", "hi": "सिंह"}, "கன்னி": {"en": "Virgo", "hi": "कन्या"}, "துலாம்": {"en": "Libra", "hi": "तुला"}, "விருச்சிகம்": {"en": "Scorpio", "hi": "वृश्चिक"}, "தனுசு": {"en": "Sagittarius", "hi": "धनु"}, "மகரம்": {"en": "Capricorn", "hi": "मकर"}, "கும்பம்": {"en": "Aquarius", "hi": "कुंभ"}, "மீனம்": {"en": "Pisces", "hi": "मीन"},
      
      // Pada representation
      "1-ம் பாதம்": {"en": "1st Pada", "hi": "1म पद", "ta": "1-ம் பாதம்"},
      "2-ம் பாதம்": {"en": "2nd Pada", "hi": "2म पद", "ta": "2-ம் பாதம்"},
      "3-ம் பாதம்": {"en": "3rd Pada", "hi": "3म पद", "ta": "3-ம் பாதம்"},
      "4-ம் பாதம்": {"en": "4th Pada", "hi": "4म पद", "ta": "4-ம் பாதம்"},
      
      // Match Details
      "தேவ கணம்": {"en": "Deva Ganam", "hi": "देव गण"},
      "மனுஷ கணம்": {"en": "Manusha Ganam", "hi": "मनुष्य गण"},
      "ராட்சச கணம்": {"en": "Ratchasa Ganam", "hi": "राक्षस गण"},
      
      "சிரசு/தலை ரஜ்ஜு": {"en": "Head Rajju", "hi": "शिर रज्जु"},
      "கண்ட/கழுத்து ரஜ்ஜு": {"en": "Neck Rajju", "hi": "कंठ रज्जु"},
      "உதர/வயிறு ரஜ்ஜு": {"en": "Stomach Rajju", "hi": "उदर रज्जु"},
      "தொடை ரஜ்ஜு": {"en": "Thigh Rajju", "hi": "ऊरु रज्जु"},
      "பாத ரஜ்ஜு": {"en": "Foot Rajju", "hi": "पाद रज्जु"},
      
      "பார்சுவ நாடி": {"en": "Parsva Nadi", "hi": "पार्श्व नाड़ी"},
      "மத்திய நாடி": {"en": "Madhya Nadi", "hi": "मध्य नाड़ी"},
      "சமான நாடி": {"en": "Samana Nadi", "hi": "समान नाड़ी"},

      "குதிரை": {"en": "Horse", "hi": "अश्व"}, "ஆண் குதிரை": {"en": "Male Horse", "hi": "नर अश्व"}, "பெண் குதிரை": {"en": "Female Horse", "hi": "मादा अश्व"},
      "யானை": {"en": "Elephant", "hi": "गज"}, "ஆண் யானை": {"en": "Male Elephant", "hi": "नर गज"}, "பெண் யானை": {"en": "Female Elephant", "hi": "मादा गज"},
      "ஆடு": {"en": "Goat", "hi": "मेष"}, "ஆண் ஆடு": {"en": "Male Goat", "hi": "नर मेष"}, "பெண் ஆடு": {"en": "Female Goat", "hi": "मादा मेष"},
      "பாம்பு": {"en": "Snake", "hi": "सर्प"}, "ஆண் நாகம்": {"en": "Male Snake", "hi": "नर सर्प"}, "பெண் சாரை": {"en": "Female Snake", "hi": "मादा सर्प"},
      "நாய்": {"en": "Dog", "hi": "श्वान"}, "ஆண் நாய்": {"en": "Male Dog", "hi": "नर श्वान"}, "பெண் நாய்": {"en": "Female Dog", "hi": "मादा श्वान"},
      "பூனை": {"en": "Cat", "hi": "मार्जार"}, "ஆண் பூனை": {"en": "Male Cat", "hi": "नर मार्जार"}, "பெண் பூனை": {"en": "Female Cat", "hi": "मादा मार्जार"},
      "எலி": {"en": "Rat", "hi": "मूषक"}, "ஆண் எலி": {"en": "Male Rat", "hi": "नर मूषक"}, "பெண் எலி": {"en": "Female Rat", "hi": "मादा मूषक"},
      "பசு": {"en": "Cow", "hi": "गौ"}, "பெண் பசு": {"en": "Female Cow", "hi": "मादा गौ"},
      "புலி": {"en": "Tiger", "hi": "व्याघ्र"}, "ஆண் புலி": {"en": "Male Tiger", "hi": "नर व्याघ्र"}, "பெண் புலி": {"en": "Female Tiger", "hi": "मादा व्याघ्र"},
      "எருமை": {"en": "Buffalo", "hi": "महिष"}, "ஆண் எருமை": {"en": "Male Buffalo", "hi": "नर महिष"}, "பெண் எருமை": {"en": "Female Buffalo", "hi": "मादा महिष"},
      "மான்": {"en": "Deer", "hi": "मृग"}, "ஆண் மான்": {"en": "Male Deer", "hi": "नर मृग"}, "பெண் மான்": {"en": "Female Deer", "hi": "मादा मृग"},
      "குரங்கு": {"en": "Monkey", "hi": "वानर"}, "ஆண் குரங்கு": {"en": "Male Monkey", "hi": "नर वानर"}, "பெண் குரங்கு": {"en": "Female Monkey", "hi": "मादा वानर"},
      "கீரி": {"en": "Mongoose", "hi": "नकुल"}, "ஆண் கீரி": {"en": "Male Mongoose", "hi": "नर नकुल"},
      "சிங்கம்": {"en": "Lion", "hi": "सिंह"}, "ஆண் சிங்கம்": {"en": "Male Lion", "hi": "नर सिंह"}, "பெண் சிங்கம்": {"en": "Female Lion", "hi": "मादा सिंह"},

      "சூரியன்": {"en": "Sun", "hi": "सूर्य"},
      "சந்திரன்": {"en": "Moon", "hi": "चंद्र"},
      "செவ்வாய்": {"en": "Mars", "hi": "मंगल"},
      "புதன்": {"en": "Mercury", "hi": "बुध"},
      "குரு": {"en": "Jupiter", "hi": "गुरु"},
      "சுக்கிரன்": {"en": "Venus", "hi": "शुक्र"},
      "சனி": {"en": "Saturn", "hi": "शनि"},
      "ராகு": {"en": "Rahu", "hi": "राहु"},
      "கேது": {"en": "Ketu", "hi": "केतु"},
      
      "தேவ": {"en": "Deva", "hi": "देव"},
      "மனுஷ": {"en": "Manusha", "hi": "मनुष्य"},
      "ராட்சச": {"en": "Ratchasa", "hi": "राक्षस"},
      "சிரசு/தலை": {"en": "Head", "hi": "शिर"},
      "கண்ட/கழுத்து": {"en": "Neck", "hi": "कंठ"},
      "உதர/வயிறு": {"en": "Stomach", "hi": "उदर"},
      "தொடை": {"en": "Thigh", "hi": "ऊरु"},
      "பாத": {"en": "Foot", "hi": "पाद"},
      "பார்சுவ": {"en": "Parsva", "hi": "पार्श्व"},
      "மத்திய": {"en": "Madhya", "hi": "मध्य"},
      "சமான": {"en": "Samana", "hi": "समान"},
    };

    // Try full string matching first
    if (translations.containsKey(key)) {
      return translations[key]?[lang] ?? key;
    }
    
    // For values like "தேவ ↔ தேவ", "குதிரை ↔ குதிரை", we split and translate each part
    if (key.contains(" ↔ ")) {
      List<String> parts = key.split(" ↔ ");
      String left = translations[parts[0]]?[lang] ?? parts[0];
      String right = translations[parts[1]]?[lang] ?? parts[1];
      return "$left ↔ $right";
    }

    return key;
  }

  Future<void> _handlePdfReport(List<MatchingResult> results, String totalScore, bool isMatchPresent) async {
    if (kIsWeb) {
      MarriageMatchingPdfService.showHtmlReport(
        girlFullData: widget.girlFullData!,
        boyFullData: widget.boyFullData!,
        results: results,
        totalScore: totalScore,
        isMatchPresent: isMatchPresent,
        l10n: AppLocalizations.of(context)!,
      );
    } else {
      if (_isGenerating) return;
      setState(() => _isGenerating = true);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
      
      try {
        final bytes = await MarriageMatchingPdfService.generate(
          girlFullData: widget.girlFullData!,
          boyFullData: widget.boyFullData!,
          results: results,
          totalScore: totalScore,
          isMatchPresent: isMatchPresent,
          l10n: AppLocalizations.of(context)!,
        );
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfBytes: bytes,
              fileName: "MarriageMatching_${widget.girlFullData!['name']}_${widget.boyFullData!['name']}.pdf".replaceAll(' ', '_'),
            ),
          ),
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e")));
        }
      } finally {
        if (mounted) setState(() => _isGenerating = false);
      }
    }
  }

  void _promptPdfReport(List<MatchingResult> results, String totalScore) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTranslatedText("பொருத்தம் உள்ளதா?"), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: Text(_getTranslatedText("ஜோதிடர் குறிப்பில் என்ன இடம்பெற வேண்டும்?")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePdfReport(results, totalScore, false);
            },
            child: Text(_getTranslatedText("பொருத்தம் இல்லை"), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePdfReport(results, totalScore, true);
            },
            child: Text(_getTranslatedText("பொருத்தம் உள்ளது"), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 900;

    final results = MatchingEngine.calculateAll(widget.girlStar, widget.girlPada, widget.boyStar, widget.boyPada);
    final totalScore = MatchingEngine.calculateTotalScore(results);
    final scoreStr = MatchingEngine.getFractionalScore(totalScore);

    Map<String, DoshaInfo>? doshas;
    if (widget.girlFullData != null && widget.boyFullData != null) {
      doshas = MatchingEngine.calculateDoshas(widget.girlFullData!, widget.boyFullData!);
    }

    final bool hasFullData = widget.girlFullData != null && widget.boyFullData != null;

    if (!hasFullData) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_getTranslatedText('பொருத்த முடிவுகள்'), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20)),
          centerTitle: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: isWide ? null : Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: _buildMatchingView(results, scoreStr, null),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_getTranslatedText('பொருத்த முடிவுகள்'), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 20)),
          centerTitle: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
              tooltip: "PDF Report",
              onPressed: () => _promptPdfReport(results, scoreStr),
            ),
          ],
          leading: isWide ? null : Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: const Color(0xFF5D1204).withOpacity(0.5),
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13.5),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Tab(text: _getTranslatedText("விவரம்")),
              Tab(text: _getTranslatedText("பெண் ஜாதகம்")),
              Tab(text: _getTranslatedText("ஆண் ஜாதகம்")),
              Tab(text: _getTranslatedText("பெண் தசா புத்தி")),
              Tab(text: _getTranslatedText("ஆண் தசா புத்தி")),
              Tab(text: _getTranslatedText("பொருத்தம்")),
            ],
          ),
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: TabBarView(
                      children: [
                        _buildBioView(),
                        _buildGirlChartsView(),
                        _buildBoyChartsView(),
                        DasaBukthiTab(fullData: widget.girlFullData!),
                        DasaBukthiTab(fullData: widget.boyFullData!),
                        _buildMatchingView(results, scoreStr, doshas),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPersonBioCard(_getTranslatedText("பெண் விவரம்"), widget.girlFullData!, const Color(0xFFD81B60))),
              const SizedBox(width: 12),
              Expanded(child: _buildPersonBioCard(_getTranslatedText("ஆண் விவரம்"), widget.boyFullData!, const Color(0xFF1565C0))),
            ],
          ),
          const SizedBox(height: 20),
          _buildPanchangamComparison(),
        ],
      ),
    );
  }

  Widget _buildPersonBioCard(String title, Map<String, dynamic> data, Color genderColor) {
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.outfit(color: const Color(0xFF5D1204), fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: genderColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFB58D3D)),
          _bioRow(_getTranslatedText("பெயர்"), data['name'] ?? "-"),
          _bioRow(_getTranslatedText("ராசி"), _getTranslatedText(KPService.TAMIL_SIGNS[data['planet_details']['moon']['rasi']] ?? data['planet_details']['moon']['rasi'] ?? "-")),
          _bioRow(_getTranslatedText("நட்சத்திரம்"), _getTranslatedText(data['planet_details']['moon']['nakshatra'] ?? "-")),
          _bioRow(_getTranslatedText("பாதம்"), _getTranslatedText("${data['planet_details']['moon']['pada']}-ம் பாதம்")),
          _bioRow(_getTranslatedText("லக்னம்"), _getTranslatedText(KPService.TAMIL_SIGNS[data['planet_details']['lagna']['rasi']] ?? data['planet_details']['lagna']['rasi'] ?? "-")),
        ],
      ),
    );
  }

  Widget _bioRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF5D1204))),
        ],
      ),
    );
  }

  Widget _buildPanchangamComparison() {
    final gPan = widget.girlFullData!['panchangam'] ?? {};
    final bPan = widget.boyFullData!['panchangam'] ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(_getTranslatedText("பஞ்சாங்க விவரங்கள்"), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
          const Divider(height: 24, color: Color(0xFFB58D3D)),
          _panRow(_getTranslatedText("தமிழ் வருடம்"), _getTranslatedText(gPan['tamil_year'] ?? "-"), _getTranslatedText(bPan['tamil_year'] ?? "-")),
          _panRow(_getTranslatedText("தமிழ் தேதி"), gPan['tamil_date']?.toString() ?? "-", bPan['tamil_date']?.toString() ?? "-"),
          _panRow(_getTranslatedText("திதி"), _getTranslatedText(gPan['tithi'] ?? "-"), _getTranslatedText(bPan['tithi'] ?? "-")),
          _panRow(_getTranslatedText("யோகம்"), _getTranslatedText(gPan['yoga'] ?? "-"), _getTranslatedText(bPan['yoga'] ?? "-")),
          _panRow(_getTranslatedText("கரணம்"), _getTranslatedText(gPan['karana']?.toString() ?? "-"), _getTranslatedText(bPan['karana']?.toString() ?? "-")),
        ],
      ),
    );
  }

  Widget _panRow(String label, String girlVal, String boyVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(girlVal, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFD81B60)))),
          Expanded(flex: 3, child: Text(boyVal, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1565C0)))),
        ],
      ),
    );
  }

  Widget _buildGirlChartsView() {
    return _buildChartsView(widget.girlFullData!, "பெண்");
  }

  Widget _buildBoyChartsView() {
    return _buildChartsView(widget.boyFullData!, "ஆண்");
  }

  Widget _buildChartsView(Map<String, dynamic> data, String label) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartSection(_getTranslatedText("ராசி கட்டம்"), data['rasi']),
          const SizedBox(height: 32),
          _buildChartSection(_getTranslatedText("அம்ச கட்டம்"), data['navamsa']),
          const SizedBox(height: 32),
          _buildChartSection(_getTranslatedText("பாவக கட்டம்"), data['pavagam']),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, dynamic chartData) {
    return SouthIndianChart(
      rasiMap: _castChartMap(chartData),
      centerLabel: title.split(' ')[0],
    );
  }

  Map<String, List<String>> _castChartMap(dynamic data) {
    if (data == null || data is! Map) return {};
    return data.map((key, value) {
      if (value is List) {
        return MapEntry(key.toString(), List<String>.from(value.map((e) => e.toString())));
      }
      return MapEntry(key.toString(), <String>[]);
    });
  }

  Widget _buildMatchingView(List<MatchingResult> results, String scoreStr, Map<String, DoshaInfo>? doshas) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              border: Border(bottom: BorderSide(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5D1204).withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryMini(_getTranslatedText("பெண்"), widget.girlStar, widget.girlPada, const Color(0xFFD81B60)),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF6EE),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 28),
                    ),
                    _buildSummaryMini(_getTranslatedText("ஆண்"), widget.boyStar, widget.boyPada, const Color(0xFF1565C0)),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D1204),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFB58D3D), width: 1.5),
                  ),
                  child: Text(
                    "${_getTranslatedText("மொத்த பொருத்தம்:")} $scoreStr / 11",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (doshas != null) _buildDoshaSection(doshas),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                  child: Text(_getTranslatedText("பத்து பொருத்தங்கள்"), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: const Color(0xFF5D1204))),
                ),
                ...results.map((r) => _buildResultCard(r)).toList(),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDoshaSection(Map<String, DoshaInfo> doshas) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(_getTranslatedText("ஜாதக ரீதியான தோஷங்கள்"), style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: const Color(0xFF5D1204))),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.4), width: 1.2),
              boxShadow: [BoxShadow(color: const Color(0xFF5D1204).withOpacity(0.04), blurRadius: 15)],
            ),
            child: Column(
              children: [
                _buildDoshaRow(_getTranslatedText("செவ்வாய் தோஷம் (Mars)"), doshas['girl']!.hasChevvai, doshas['boy']!.hasChevvai),
                const Divider(height: 30, color: Color(0xFFB58D3D)),
                _buildDoshaRow(_getTranslatedText("ராகு-கேது தோஷம் (Rahu-Ketu)"), doshas['girl']!.hasRahuKethu, doshas['boy']!.hasRahuKethu),
                const Divider(height: 30, color: Color(0xFFB58D3D)),
                _buildDasaSandhiRow(_getTranslatedText("தசா சந்தி (Dasa Sandhi)"), doshas['dasa_sandhi']!),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDoshaRow(String title, bool girlStatus, bool boyStatus) {
    bool isMatch = girlStatus == boyStatus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF5D1204))),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _doshaTag(_getTranslatedText("பெண்"), _getTranslatedText(girlStatus ? "இருக்கிறது" : "இல்லை"), girlStatus ? const Color(0xFFD32F2F) : const Color(0xFF388E3C)),
            _doshaTag(_getTranslatedText("ஆண்"), _getTranslatedText(boyStatus ? "இருக்கிறது" : "இல்லை"), boyStatus ? const Color(0xFFD32F2F) : const Color(0xFF388E3C)),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isMatch ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isMatch ? const Color(0xFF81C784) : const Color(0xFFE57373), width: 1.0),
            ),
            child: Text(
              _getTranslatedText(isMatch ? "பொருத்தம்: உத்தமம்" : "பொருத்தம்: அதமம்"),
              style: TextStyle(color: isMatch ? const Color(0xFF388E3C) : const Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDasaSandhiRow(String title, DoshaInfo sandhi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF5D1204))),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getTranslatedText(sandhi.hasDasaSandhi ? "தசா சந்தி உள்ளது" : "தசா சந்தி இல்லை"),
              style: TextStyle(color: sandhi.hasDasaSandhi ? const Color(0xFFD32F2F) : const Color(0xFF388E3C), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Flexible(
              child: Text(
                sandhi.details,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _doshaTag(String label, String status, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12.5)),
      ],
    );
  }

  Widget _buildSummaryMini(String label, String star, int pada, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 4),
        Text(_getTranslatedText(star), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF5D1204))),
        const SizedBox(height: 2),
        Text(_getTranslatedText("$pada-ம் பாதம்"), style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildResultCard(MatchingResult r) {
    bool isGood = r.result == AstroData.matchUththamam;
    bool isMid = r.result == AstroData.matchMadhythiyam;
    Color statusColor = isGood ? const Color(0xFF388E3C) : (isMid ? const Color(0xFFF57C00) : const Color(0xFFD32F2F));
    IconData icon = isGood ? Icons.check_circle_rounded : (isMid ? Icons.info_rounded : Icons.cancel_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB58D3D).withOpacity(0.3), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D1204).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getTranslatedText(r.name), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5, color: const Color(0xFF5D1204))),
                if (r.girlValue.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text("${_getTranslatedText(r.girlValue)} ↔ ${_getTranslatedText(r.boyValue)}", style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          Text(_getTranslatedText(r.result), style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }
}
