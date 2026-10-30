import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:tamil_pdf_shaper/tamil_pdf_shaper.dart';
import 'kp_service.dart';
import 'jamakkol_service.dart';
import 'settings_service.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class JamakkolOnePagePdfService {
  static pw.Font? _headingFont;
  static pw.Font? _bodyFont;

  static const List<String> tamilNakshatras = [
    "அசுவனி", "பரணி", "கிருத்திகை", "ரோகிணி", "மிருகசீர்ஷம்", "திருவாதிரை",
    "புனர்பூசம்", "பூசம்", "ஆயில்யம்", "மகம்", "பூரம்", "உத்திரம்",
    "அஸ்தம்", "சித்திரை", "சுவாதி", "விசாகம்", "அனுஷம்", "கேட்டை",
    "மூலம்", "பூராடம்", "உத்திராடம்", "திருவோணம்", "அவிட்டம்", "சதயம்",
    "பூரட்டாதி", "உத்திரட்டாதி", "ரேவதி"
  ];

  static const List<String> englishNakshatras = [
    "Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashirsha", "Arudra",
    "Punarvasu", "Pushya", "Aslesha", "Magha", "Purvaphalguni", "Uttaraphalguni",
    "Hasta", "Chitra", "Swati", "Vishakha", "Anuradha", "Jyeshta",
    "Mula", "Purvashada", "Uttarashada", "Shravana", "Dhanishta", "Shatabhisha",
    "Purvabhadrapada", "Uttarabhadrapada", "Revati"
  ];

  static const List<String> hindiNakshatras = [
    "अश्विनी", "भरणी", "कृत्तिका", "रोहिणी", "मृगशीर्ष", "आर्द्रा",
    "पुनर्वसु", "पुष्य", "आश्लेषा", "मघा", "पूर्वाफाल्गुनी", "उत्तराफाल्गुनी",
    "हस्त", "चित्रा", "स्वाती", "विशाखा", "अनुराधा", "ज्येष्ठा",
    "मूल", "पूर्वाषाढ़ा", "उत्तराषाढ़ा", "श्रवण", "धनिष्ठा", "शतभिषा",
    "पूर्वाभाद्रपद", "उत्तराभाद्रपद", "रेवती"
  ];

  static final Map<String, String> _engToTamStar = {
    "Ashwini": "அசுவனி", "Bharani": "பரணி", "Krittika": "கிருத்திகை", "Rohini": "ரோகிணி",
    "Mrigashirsha": "மிருகசீர்ஷம்", "Mrigashira": "மிருகசீர்ஷம்", "Arudra": "திருவாதிரை", "Ardra": "திருவாதிரை",
    "Punarvasu": "புனர்பூசம்", "Pushya": "பூசம்", "Pushyami": "பூசம்", "Aslesha": "ஆயில்யம்", "Ashlesha": "ஆயில்யம்",
    "Magha": "மகம்", "Purvaphalguni": "பூரம்", "Uttaraphalguni": "உத்திரம்", "Hastha": "அஸ்தம்", "Hasta": "அஸ்தம்",
    "Chitra": "சித்திரை", "Swati": "சுவாதி", "Vishakha": "விசாகம்", "Visakha": "விசாகம்", "Anuradha": "அனுஷம்",
    "Jyeshta": "கேட்டை", "Jyeshtha": "கேட்டை", "Mula": "மூலம்", "Moola": "மூலம்",
    "Purvashada": "பூராடம்", "PurvaAshadha": "பூராடம்", "Uttarashada": "உத்திராடம்", "UttaraAshadha": "உத்திராடம்",
    "Shravana": "திருவோணம்", "Dhanishta": "அவிட்டம்", "Shatabhisha": "சதயம்",
    "Purvabhadrapada": "பூரட்டாதி", "Uttarabhadrapada": "உத்திரட்டாதி", "Revati": "ரேவதி", "Revathi": "ரேவதி",
  };

  static final Map<String, String> _engToHiStar = {
    "Ashwini": "अश्विनी", "Bharani": "भरणी", "Krittika": "कृत्तिका", "Rohini": "रोहिणी",
    "Mrigashirsha": "मृगशीर्ष", "Mrigashira": "मृगशीर्ष", "Arudra": "आर्द्रा", "Ardra": "आर्द्रा",
    "Punarvasu": "पुनर्वसु", "Pushya": "पुष्य", "Pushyami": "पुष्य", "Aslesha": "आश्लेषा", "Ashlesha": "आश्लेषा",
    "Magha": "मघा", "Purvaphalguni": "पूर्वाफाल्गुनी", "Uttaraphalguni": "उत्तराफाल्गुनी", "Hastha": "हस्त", "Hasta": "हस्त",
    "Chitra": "चित्रा", "Swati": "स्वाती", "Vishakha": "विशाखा", "Visakha": "विशाखा", "Anuradha": "अनुराधा",
    "Jyeshta": "ज्येष्ठा", "Jyeshtha": "ज्येष्ठा", "Mula": "मूल", "Moola": "मूल",
    "Purvashada": "पूर्वाषाढ़ा", "PurvaAshadha": "पूर्वाषाढ़ा", "Uttarashada": "उत्तराषाढ़ा", "UttaraAshadha": "उत्तराषाढ़ा",
    "Shravana": "श्रवण", "Dhanishta": "धनिष्ठा", "Shatabhisha": "शतभिषा",
    "Purvabhadrapada": "पूर्वाभाद्रपद", "Uttarabhadrapada": "उत्तराभाद्रपद", "Revati": "रेवती", "Revathi": "रेवती",
  };

  static Future<void> _initFonts() async {
    if (_headingFont == null || _bodyFont == null) {
      try {
        _headingFont = await TamilPdfFont.loadCustomFont('assets/fonts/Uni_Ila.Sundaram-02_shaped.ttf');
        _bodyFont = await TamilPdfFont.loadCustomFont('assets/fonts/Uni_Ila.Sundaram-05_shaped.ttf');
      } catch (e) {
        debugPrint("Error loading shaped fonts, falling back: $e");
        _headingFont = await TamilPdfFont.load();
        _bodyFont = _headingFont;
      }
    }
  }

  static Map<String, String> _getStarPada(double deg, [String langCode = 'ta']) {
    deg = (deg % 360.0 + 360.0) % 360.0;
    int starIdx = (deg / (360.0 / 27.0)).floor() % 27;
    int pada = ((deg % (360.0 / 27.0)) / (360.0 / 108.0)).floor() + 1;
    String star;
    if (langCode == 'hi') {
      star = hindiNakshatras[starIdx];
    } else if (langCode == 'en') {
      star = englishNakshatras[starIdx];
    } else {
      star = tamilNakshatras[starIdx];
    }
    return {'star': star, 'pada': pada.toString()};
  }

  static String _getLocalizedWeekday(dynamic rawVara, DateTime dt, DateTime sunrise, AppLocalizations l10n) {
    int? idx;
    if (rawVara != null) {
      final s = rawVara.toString().trim().toLowerCase();
      final Map<String, int> engDayMap = {
        'sunday': 0, 'sun': 0,
        'monday': 1, 'mon': 1,
        'tuesday': 2, 'tue': 2,
        'wednesday': 3, 'wed': 3,
        'thursday': 4, 'thu': 4,
        'friday': 5, 'fri': 5,
        'saturday': 6, 'sat': 6,
      };
      idx = engDayMap[s];
      if (idx == null) {
        final Map<String, int> otherDayMap = {
          'ஞாயிறு': 0, 'ஞாயிற்றுக்கிழமை': 0, 'रविवार': 0,
          'திங்கள்': 1, 'திங்கட்கிழமை': 1, 'सोमवार': 1,
          'செவ்வாய்': 2, 'செவ்வாய்க்கிழமை': 2, 'मंगलवार': 2,
          'புதன்': 3, 'புதன்கிழமை': 3, 'बुधवार': 3,
          'வியாழன்': 4, 'வியாழக்கிழமை': 4, 'गुरुवार': 4,
          'வெள்ளி': 5, 'வெள்ளிக்கிழமை': 5, 'शुक्रवार': 5,
          'சனி': 6, 'சனிக்கிழமை': 6, 'शनिवार': 6,
        };
        for (var entry in otherDayMap.entries) {
          if (rawVara.toString().contains(entry.key)) {
            idx = entry.value;
            break;
          }
        }
      }
    }

    if (idx == null) {
      idx = dt.weekday % 7;
      if (dt.isBefore(sunrise)) {
        idx = (idx - 1 + 7) % 7;
      }
    }

    switch (idx % 7) {
      case 0: return l10n.sunday;
      case 1: return l10n.monday;
      case 2: return l10n.tuesday;
      case 3: return l10n.wednesday;
      case 4: return l10n.thursday;
      case 5: return l10n.friday;
      case 6: return l10n.saturday;
      default: return l10n.sunday;
    }
  }

  static String _translatePlanet(dynamic p, String langCode) {
    if (p == null) return "-";
    String s = p.toString().trim();
    if (s.isEmpty || s == "-") return "-";

    final Map<String, String> enToTa = {
      'Sun': 'சூரியன்', 'Moon': 'சந்திரன்', 'Mars': 'செவ்வாய்', 'Mercury': 'புதன்',
      'Jupiter': 'குரு', 'Venus': 'சுக்கிரன்', 'Saturn': 'சனி', 'Rahu': 'ராகு', 'Ketu': 'கேது',
      'Maanthi': 'மாந்தி', 'Gulika': 'குளிகன்',
    };
    final Map<String, String> enToHi = {
      'Sun': 'सूर्य', 'Moon': 'चंद्र', 'Mars': 'मंगल', 'Mercury': 'बुध',
      'Jupiter': 'गुरु', 'Venus': 'शुक्र', 'Saturn': 'शनि', 'Rahu': 'राहु', 'Ketu': 'केतु',
      'Maanthi': 'मांदी', 'Gulika': 'गुलिक',
    };

    if (langCode == 'hi') {
      return enToHi[s] ?? s;
    } else if (langCode == 'en') {
      return s;
    } else {
      return enToTa[s] ?? s;
    }
  }

  static String _formatDeg(double deg) {
    double degInSign = deg % 30.0;
    int d = degInSign.floor();
    int m = ((degInSign - d) * 60).floor();
    return "${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  static DateTime _parseTime(String timeStr, DateTime baseDate) {
    try {
      final parts = timeStr.trim().split(' ');
      final hms = parts[0].split(':');
      int h = int.parse(hms[0]);
      int m = int.parse(hms[1]);
      int s = hms.length > 2 ? int.parse(hms[2]) : 0;
      if (parts.length > 1) {
        if (parts[1].toUpperCase() == "PM" && h < 12) h += 12;
        if (parts[1].toUpperCase() == "AM" && h == 12) h = 0;
      }
      return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m, s);
    } catch (e) {
      return baseDate;
    }
  }

  /// Print preview on web or any platform
  static Future<void> showHtmlReport({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    required DateTime inputTime,
    required String place,
    required double lat,
    required double lon,
    required AppLocalizations l10n,
    bool isAltNaming = false,
  }) async {
    final bytes = await generate(
      name: name,
      gender: gender,
      results: results,
      inputTime: inputTime,
      place: place,
      lat: lat,
      lon: lon,
      l10n: l10n,
      isAltNaming: isAltNaming,
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'ஜாமக்கோள்_பிரசன்னம்.pdf',
    );
  }

  /// Generates the pure Dart PDF binary
  static Future<Uint8List> generate({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    required DateTime inputTime,
    required String place,
    required double lat,
    required double lon,
    required AppLocalizations l10n,
    bool isAltNaming = false,
  }) async {
    await _initFonts();
    final astro = await SettingsService.getAstrologerDetails();
    final customLogoBase64 = await SettingsService.getCustomLogo();

    Uint8List? ganapathyImg;
    Uint8List? appLogoImg;
    Uint8List? customLogoImg;
    try {
      ganapathyImg = (await rootBundle.load('assets/images/ganapathy.png')).buffer.asUint8List();
    } catch (_) {}
    try {
      appLogoImg = (await rootBundle.load('assets/images/APPLOGO.png')).buffer.asUint8List();
    } catch (_) {
      try {
        appLogoImg = (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List();
      } catch (_) {}
    }
    if (customLogoBase64 != null && customLogoBase64.isNotEmpty) {
      try {
        customLogoImg = base64Decode(customLogoBase64);
      } catch (_) {}
    }

    final pdf = pw.Document();

    // Palette
    final primaryColor = PdfColor.fromHex('#5D1204');     // Deep Maroon
    final goldAccent = PdfColor.fromHex('#B58D3D');       // Temple Gold
    final bgIvory = PdfColor.fromHex('#FFFDF9');          // Ivory background
    final borderCol = PdfColor.fromHex('#D9C3A3');        // Border
    final textDark = PdfColor.fromHex('#212121');         // Text
    final textMuted = PdfColor.fromHex('#757575');        // Muted Text
    final blueColor = PdfColor.fromHex('#0D47A1');        // Outer Planet Blue
    final greenColor = PdfColor.fromHex('#1B5E20');       // Udayam Green
    final redColor = PdfColor.fromHex('#B71C1C');         // Kavippu Red

    // Data parsing
    final outer = results['outer'] as Map<dynamic, dynamic>? ?? {};
    final notes = results['notes'] as Map<dynamic, dynamic>? ?? {};
    final strength = results['strength'] as Map<dynamic, dynamic>? ?? {};
    final inner = results['inner'] as Map<dynamic, dynamic>? ?? {};
    final udayamIdx = results['udayam_idx'] ?? 0;
    final arudamIdx = results['arudam_idx'] ?? 0;
    final kaviIdx = results['kavi_idx'] ?? 0;

    final String langCode = l10n.localeName;

    final pan = inner['panchangam'] as Map<dynamic, dynamic>? ?? {};
    final details = inner['planet_details'] as Map<dynamic, dynamic>? ?? {};

    final sunriseStr = pan['sunrise']?.toString() ?? "06:00 AM";
    final sunsetStr = pan['sunset']?.toString() ?? "06:00 PM";
    final sunrise = _parseTime(sunriseStr, inputTime);
    final sunset = _parseTime(sunsetStr, inputTime);

    final weekdayStr = _getLocalizedWeekday(pan['vara'], inputTime, sunrise, l10n);

    final moonDetails = details['moon'] ?? details['Moon'] ?? {};
    final double? moonLon = (moonDetails['longitude'] as num?)?.toDouble();
    String cleanStar = moonDetails['nakshatra']?.toString() ?? pan['nakshatra']?.toString() ?? "";
    String padaStr = moonDetails['pada']?.toString() ?? pan['pada']?.toString() ?? "-";
    
    if (moonLon != null) {
      final sp = _getStarPada(moonLon, langCode);
      cleanStar = sp['star']!;
      if (padaStr == "-") padaStr = sp['pada']!;
    } else if (cleanStar.isNotEmpty) {
      if (langCode == 'hi') {
        cleanStar = _engToHiStar[cleanStar] ?? cleanStar;
      } else if (langCode != 'en') {
        cleanStar = _engToTamStar[cleanStar] ?? cleanStar;
      }
    } else {
      cleanStar = "-";
    }

    final String padaSuffix = langCode == 'en' ? "Pada" : (langCode == 'hi' ? "चरण" : "பாதம்");
    final String starDisplay = padaStr != "-" ? "$cleanStar - $padaStr $padaSuffix" : cleanStar;

    final tamilYear = pan['tamil_year']?.toString() ?? "-";
    final tamilMonth = pan['tamil_month']?.toString() ?? "-";
    final tamilDate = pan['tamil_date']?.toString() ?? "-";

    // Gowri
    final segments = JamakkolService.calculateCurrentSegments(inputTime, sunrise, sunset, langCode: 'ta');
    final gowriStr = segments['gowri']?.toString() ?? "-";

    // Lagna
    String lagnaSign = "-";
    if (details.containsKey('lagna') && details['lagna'] != null) {
      double lDeg = (details['lagna']['longitude'] as num?)?.toDouble() ?? 0.0;
      int lIdx = (lDeg / 30.0).floor() % 12;
      lagnaSign = langCode == 'ta'
          ? (KPService.TAMIL_SIGNS[KPService.SIGNS[lIdx]] ?? KPService.SIGNS[lIdx])
          : (langCode == 'hi'
              ? (KPService.HINDI_SIGNS[KPService.SIGNS[lIdx]] ?? KPService.SIGNS[lIdx])
              : KPService.SIGNS[lIdx]);
    }

    // Kuligathi Kalams (குளிகாதி காலங்கள் 6 காலங்கள்)
    int weekdayNum = inputTime.weekday % 7;
    if (inputTime.isBefore(sunrise)) {
      weekdayNum = (weekdayNum - 1 + 7) % 7;
    }
    double dayMinutes = sunset.difference(sunrise).inMinutes.toDouble();
    if (dayMinutes <= 0) dayMinutes = 720.0;
    double daySegSecs = (dayMinutes * 60) / 8.0;

    DateTime getDaySlot(int segIdx) {
      return sunrise.add(Duration(seconds: (segIdx * daySegSecs).round()));
    }

    String formatSlot(DateTime start, DateTime end) {
      return "${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}";
    }

    // 1. ராகு காலம் (Rahu Kalam)
    int rahuSeg = const [7, 1, 6, 4, 5, 3, 2][weekdayNum];
    String rahuStr = formatSlot(getDaySlot(rahuSeg), getDaySlot(rahuSeg + 1));

    // 2. எமகண்டம் (Yamakandam)
    int yamaSeg = const [4, 3, 2, 1, 0, 6, 5][weekdayNum];
    String yamaStr = formatSlot(getDaySlot(yamaSeg), getDaySlot(yamaSeg + 1));

    // 3. குளிகை (Gulikai)
    int kuliSeg = const [6, 5, 4, 3, 2, 1, 0][weekdayNum];
    String kuligaiStr = formatSlot(getDaySlot(kuliSeg), getDaySlot(kuliSeg + 1));

    // 4. காலன் (Kalan)
    int kalanSeg = const [0, 6, 5, 4, 3, 2, 1][weekdayNum];
    String kalanStr = formatSlot(getDaySlot(kalanSeg), getDaySlot(kalanSeg + 1));

    // 5. அர்தபிரகணன் (Ardhapraharanan)
    int arthaSeg = const [3, 2, 1, 0, 6, 5, 4][weekdayNum];
    String arthaStr = formatSlot(getDaySlot(arthaSeg), getDaySlot(arthaSeg + 1));

    // 6. இரவு எமகண்டம் (Night Yamakandam)
    DateTime nextSr = sunrise.add(const Duration(days: 1));
    double nightMinutes = nextSr.difference(sunset).inMinutes.toDouble();
    if (nightMinutes <= 0) nightMinutes = 720.0;
    double nightSegSecs = (nightMinutes * 60) / 8.0;

    DateTime getNightSlot(int segIdx) {
      return sunset.add(Duration(seconds: (segIdx * nightSegSecs).round()));
    }

    int nightYamaSeg = const [0, 6, 5, 4, 3, 2, 1][weekdayNum];
    String nightYamaStr = formatSlot(getNightSlot(nightYamaSeg), getNightSlot(nightYamaSeg + 1));

    // Header info
    String shopName = astro['shop_name'] ?? astro['name'] ?? "ஜிபி அஸ்ட்ரோ ஜோதிட வித்யாலயம்";
    String astroName = astro['astrologer_name'] ?? "";
    String address = astro['address'] ?? "சென்னை";
    String phone = astro['phone'] ?? "9800666225";
    final dateStr = DateFormat('dd - MM - yyyy').format(inputTime);
    final timeStr = DateFormat('hh:mm:ss a').format(inputTime);
    final nowStr = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
    final prasannaNo = (results['prasannam_no'] ?? results['bhavar'] ?? place).toString();

    // Longitudes for points
    double uDeg = (outer['udayam_abs_deg'] as num?)?.toDouble() ?? 0.0;
    double aDeg = (outer['arudam_abs_deg'] as num?)?.toDouble() ?? 0.0;
    double kDeg = (30.0 - (aDeg % 30.0)) + (kaviIdx * 30.0);
    kDeg = (kDeg % 360.0 + 360.0) % 360.0;

    final subPlanets = results['sub_planets'] as JamakkolSubPlanets?;
    double rahuKalamDeg = subPlanets != null ? ((subPlanets.rahu.rasi - 1) * 30.0 + subPlanets.rahu.degree) : 0.0;
    double yamaDeg = subPlanets != null ? ((subPlanets.yamagandan.rasi - 1) * 30.0 + subPlanets.yamagandan.degree) : 0.0;
    double mrityuDeg = subPlanets != null ? ((subPlanets.mrityu.rasi - 1) * 30.0 + subPlanets.mrityu.degree) : 0.0;
    double maanthiDeg = (details['maanthi']?['longitude'] as num?)?.toDouble() ?? 0.0;

    final pDegs = outer['planet_degrees'] as Map? ?? {};
    final namingMap = isAltNaming ? JamakkolService.JAMAKKOL_TAMIL_ALT : JamakkolService.JAMAKKOL_TAMIL_SHORT;

    final udayaLordPlanet = JamakkolService.SIGN_LORDS[KPService.SIGNS[udayamIdx % 12]] ?? "Sun";

    final Map<String, String> outerShortTa = {
      'Sun': 'சூரி', 'Moon': 'சந்', 'Mars': 'செவ்', 'Mercury': 'புத',
      'Jupiter': 'குரு', 'Venus': 'சுக்', 'Saturn': 'சனி', 'Rahu': 'பாம்பு'
    };
    final Map<String, String> outerShortHi = {
      'Sun': 'सू', 'Moon': 'चं', 'Mars': 'मं', 'Mercury': 'बु',
      'Jupiter': 'गु', 'Venus': 'शु', 'Saturn': 'श', 'Rahu': 'रा'
    };
    final Map<String, String> outerShortEn = {
      'Sun': 'Sun', 'Moon': 'Mon', 'Mars': 'Mar', 'Mercury': 'Mer',
      'Jupiter': 'Jup', 'Venus': 'Ven', 'Saturn': 'Sat', 'Rahu': 'Rah'
    };

    // Outer planets mapped to border badges by sign
    Map<String, List<Map<String, dynamic>>> outerBadgesBySign = {};
    for (var sign in KPService.SIGNS) {
      outerBadgesBySign[sign] = [];
    }
    for (var pName in JamakkolService.JAMAKKOL_PLANETS) {
      if (pDegs.containsKey(pName)) {
        double deg = (pDegs[pName] as num).toDouble();
        int sIdx = (deg / 30.0).floor() % 12;
        String signName = KPService.SIGNS[sIdx];
        double degInSign = deg % 30.0;
        int d = degInSign.floor();
        int m = ((degInSign - d) * 60).floor();
        String pLabel = langCode == 'ta'
            ? (outerShortTa[pName] ?? pName)
            : (langCode == 'hi' ? (outerShortHi[pName] ?? pName) : (outerShortEn[pName] ?? pName));
        String degStr = "${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
        bool isLord = (pName == udayaLordPlanet);
        outerBadgesBySign[signName]?.add({
          'name': pLabel,
          'deg': degStr,
          'isUdayaLord': isLord,
        });
      }
    }

    // Inner circle items mapped by sign (Lagna, Subplanets, Gochara grahas)
    Map<String, List<Map<String, dynamic>>> innerItemsBySign = {};
    for (var sign in KPService.SIGNS) {
      innerItemsBySign[sign] = [];
    }

    // 1. Lagna
    if (details.containsKey('lagna') && details['lagna'] != null) {
      double lDeg = (details['lagna']['longitude'] as num?)?.toDouble() ?? 0.0;
      int sIdx = (lDeg / 30.0).floor() % 12;
      double degInSign = lDeg % 30.0;
      int d = degInSign.floor();
      int m = ((degInSign - d) * 60).floor();
      String lPrefix = langCode == 'ta' ? 'லக்' : (langCode == 'hi' ? 'लग्न' : 'Asc');
      innerItemsBySign[KPService.SIGNS[sIdx]]?.add({
        'type': 'lagna',
        'label': "$lPrefix ${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
        'deg': degInSign,
      });
    }

    // 2. Subplanets
    if (subPlanets != null) {
      void addSub(String nameTa, String nameHi, String nameEn, SubPlanetResult sp, String type) {
        String sign = KPService.SIGNS[sp.rasi - 1];
        double degInSign = sp.degree;
        int d = degInSign.floor();
        int m = ((degInSign - d) * 60).floor();
        String name = langCode == 'ta' ? nameTa : (langCode == 'hi' ? nameHi : nameEn);
        innerItemsBySign[sign]?.add({
          'type': type,
          'label': "$name ${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
          'deg': degInSign,
        });
      }
      addSub('ரா.கா', 'रा', 'Rah', subPlanets.rahu, 'sub_rahu');
      addSub('எம', 'यम', 'Yama', subPlanets.yamagandan, 'sub_yama');
      addSub('மிரு', 'मृ', 'Mri', subPlanets.mrityu, 'sub_mrityu');
    }

    // 3. Maanthi
    if (details.containsKey('maanthi') && details['maanthi'] != null) {
      double mLon = (details['maanthi']['longitude'] as num?)?.toDouble() ?? 0.0;
      int sIdx = (mLon / 30.0).floor() % 12;
      double degInSign = mLon % 30.0;
      int d = degInSign.floor();
      int m = ((degInSign - d) * 60).floor();
      String mPrefix = langCode == 'ta' ? 'மாந்' : (langCode == 'hi' ? 'मां' : 'Maa');
      innerItemsBySign[KPService.SIGNS[sIdx]]?.add({
        'type': 'gochara',
        'label': "$mPrefix ${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
        'deg': degInSign,
      });
    }

    // 4. Gochara Planets
    final pInfo = inner['planet_info'] as Map<dynamic, dynamic>? ?? {};
    double sunLon = (details['sun']?['longitude'] as num?)?.toDouble() ?? 0.0;

    final gocharaPlanetsList = [
      {'key': 'sun', 'ta': 'சூ', 'hi': 'सू', 'en': 'Sun'},
      {'key': 'moon', 'ta': 'சந்', 'hi': 'चं', 'en': 'Mon'},
      {'key': 'mars', 'ta': 'செவ்', 'hi': 'मं', 'en': 'Mar'},
      {'key': 'mercury', 'ta': 'புத', 'hi': 'बु', 'en': 'Mer'},
      {'key': 'jupiter', 'ta': 'குரு', 'hi': 'गु', 'en': 'Jup'},
      {'key': 'venus', 'ta': 'சுக்', 'hi': 'शु', 'en': 'Ven'},
      {'key': 'saturn', 'ta': 'சனி', 'hi': 'श', 'en': 'Sat'},
      {'key': 'rahu', 'ta': 'ராகு', 'hi': 'राहु', 'en': 'Rah'},
      {'key': 'ketu', 'ta': 'கேது', 'hi': 'केतु', 'en': 'Ket'},
    ];

    for (var gp in gocharaPlanetsList) {
      final pKey = gp['key']!;
      if (details.containsKey(pKey) && details[pKey] != null) {
        double lon = (details[pKey]['longitude'] as num?)?.toDouble() ?? 0.0;
        int sIdx = (lon / 30.0).floor() % 12;
        double degInSign = lon % 30.0;
        int d = degInSign.floor();
        int m = ((degInSign - d) * 60).floor();

        String capKey = pKey[0].toUpperCase() + pKey.substring(1);
        bool isRetro = pInfo[capKey]?['isRetro'] ?? false;
        bool isCombust = JamakkolService.isPlanetCombust(capKey, lon, sunLon, isRetro);

        String name = langCode == 'ta' ? gp['ta']! : (langCode == 'hi' ? gp['hi']! : gp['en']!);
        String suffix = "";
        if (isRetro && pKey != 'rahu' && pKey != 'ketu') {
          suffix += (langCode == 'en') ? "R" : "வ";
        }
        if (isCombust) {
          if (suffix.isNotEmpty) suffix += ",";
          suffix += (langCode == 'en') ? "C" : ((langCode == 'hi') ? "अ" : "அ");
        }
        if (suffix.isNotEmpty) {
          name = "$name($suffix)";
        }

        innerItemsBySign[KPService.SIGNS[sIdx]]?.add({
          'type': 'gochara',
          'label': "$name ${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
          'deg': degInSign,
        });
      }
    }

    // Sort inner items by degree (reverse signs: Sagittarius, Capricorn, Aquarius, Pisces)
    const reverseSigns = {"Sagittarius", "Capricorn", "Aquarius", "Pisces"};
    for (var sign in KPService.SIGNS) {
      final list = innerItemsBySign[sign] ?? [];
      if (reverseSigns.contains(sign)) {
        list.sort((a, b) => (b['deg'] as double).compareTo(a['deg'] as double));
      } else {
        list.sort((a, b) => (a['deg'] as double).compareTo(b['deg'] as double));
      }
    }

    // Kathir maps
    final kathirMap = strength['rasi_kathir_map'] as Map<dynamic, dynamic>? ?? {};
    final bhavasList = strength['bhavas'] as List<dynamic>? ?? [];
    Map<String, dynamic> bhavaBySign = {};
    for (var b in bhavasList) {
      if (b is Map && b['sign'] != null) {
        bhavaBySign[b['sign']] = b;
      }
    }

    final udayamSign = KPService.SIGNS[udayamIdx % 12];
    final arudamSign = KPService.SIGNS[arudamIdx % 12];
    final kavippuSign = KPService.SIGNS[kaviIdx % 12];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(12),
        theme: pw.ThemeData.withFont(base: _bodyFont!, bold: _headingFont!),
        build: (pw.Context context) {
          return pw.Container(
            // Royal Outer Frame Border
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: primaryColor, width: 1.5),
            ),
            padding: const pw.EdgeInsets.all(3),
            child: pw.Container(
              // Inner Gold Accent Border
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: goldAccent, width: 0.8),
                color: bgIvory,
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // -----------------------------------------------------------
                  // 1. TOP HEADER: Pillaiyar Suzhi & Astrologer Banner
                  // -----------------------------------------------------------
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text("உ".toTamilPdf, style: pw.TextStyle(font: _headingFont, fontSize: 16, color: primaryColor)),
                        pw.Container(width: 18, height: 1.0, color: primaryColor, margin: const pw.EdgeInsets.only(top: 1)),
                        pw.Container(width: 18, height: 1.0, color: primaryColor, margin: const pw.EdgeInsets.only(top: 1)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 3),

                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderCol, width: 0.8),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      color: PdfColors.white,
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // Left: Astrologer Photo (customLogo) or Ganapathy fallback
                        if (customLogoImg != null)
                          pw.Container(
                            width: 48,
                            height: 48,
                            child: pw.ClipOval(
                              child: pw.Image(pw.MemoryImage(customLogoImg), fit: pw.BoxFit.cover),
                            ),
                          )
                        else if (ganapathyImg != null)
                          pw.Container(
                            width: 44,
                            height: 44,
                            child: pw.Image(pw.MemoryImage(ganapathyImg), fit: pw.BoxFit.contain),
                          )
                        else
                          pw.SizedBox(width: 44),

                        // Center: Astrologer Details
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Text(shopName.toTamilPdf, style: pw.TextStyle(font: _headingFont, fontSize: 14, color: primaryColor)),
                              if (astroName.isNotEmpty)
                                pw.Text(astroName.toTamilPdf, style: pw.TextStyle(font: _headingFont, fontSize: 9.5, color: textDark)),
                              pw.Text("$address | செல்: $phone".toTamilPdf, style: pw.TextStyle(font: _bodyFont, fontSize: 8.5, color: textMuted)),
                            ],
                          ),
                        ),

                        // Right: Ganapathy (when customLogo is on left) or App Logo
                        if (customLogoImg != null && ganapathyImg != null)
                          pw.Container(
                            width: 44,
                            height: 44,
                            child: pw.Image(pw.MemoryImage(ganapathyImg), fit: pw.BoxFit.contain),
                          )
                        else if (appLogoImg != null)
                          pw.Container(
                            width: 44,
                            height: 44,
                            child: pw.Image(pw.MemoryImage(appLogoImg), fit: pw.BoxFit.contain),
                          )
                        else
                          pw.SizedBox(width: 44),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 3),

                  // Title Bar with Software Developer Credit
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 8),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          "ஜாமக்கோள் பிரசன்னம்".toTamilPdf,
                          style: pw.TextStyle(font: _headingFont, fontSize: 12.0, color: PdfColors.white),
                        ),
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 2),
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 1.8),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#2D0802'),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                            border: pw.Border.all(color: PdfColor.fromHex('#FFE082'), width: 0.6),
                          ),
                          child: pw.Text(
                            "SOFTWARE DEVELOPED BY GBASTRO SUITE / MO. NO - 9787067910 / 7373411173",
                            style: pw.TextStyle(
                              font: _headingFont,
                              fontSize: 7.0,
                              color: PdfColor.fromHex('#FFE082'), // Bright Radiant Temple Gold
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                  ),

                  pw.SizedBox(height: 4),

                  // -----------------------------------------------------------
                  // 2. PRASANNA DETAILS (3-Column Box)
                  // -----------------------------------------------------------
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderCol, width: 0.8),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      color: PdfColors.white,
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Column 1
                        pw.Expanded(
                          flex: 30,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("பெயர்", name, font: _bodyFont, primaryColor: primaryColor, labelWidth: 54, fontSize: 7.0),
                              _buildDetailRow("பிரசன்ன தேதி", dateStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 54, fontSize: 7.0),
                              _buildDetailRow("பிரசன்ன நேரம்", timeStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 54, fontSize: 7.0),
                              _buildDetailRow("ஊர் / இடம்", prasannaNo, font: _bodyFont, primaryColor: primaryColor, labelWidth: 54, fontSize: 7.0),
                              _buildDetailRow("பாலினம்", gender, font: _bodyFont, primaryColor: primaryColor, labelWidth: 54, fontSize: 7.0),
                              _buildDetailRow("சூரிய உதயம்", sunriseStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 54, fontSize: 7.0),
                            ],
                          ),
                        ),
                        pw.Container(width: 0.8, height: 68, color: borderCol, margin: const pw.EdgeInsets.symmetric(horizontal: 6)),
                        // Column 2
                        pw.Expanded(
                          flex: 34,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("லக்னம்", lagnaSign, font: _bodyFont, primaryColor: primaryColor, labelWidth: 52, fontSize: 7.0),
                              _buildDetailRow("தமிழ் தேதி", "$tamilYear, $tamilMonth $tamilDate", font: _bodyFont, primaryColor: primaryColor, labelWidth: 52, fontSize: 7.0),
                              _buildDetailRow(langCode == 'ta' ? "கிழமை" : (langCode == 'hi' ? "वार" : "Weekday"), weekdayStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 52, fontSize: 7.0),
                              _buildDetailRow(langCode == 'ta' ? "நட்சத்திரம்" : (langCode == 'hi' ? "நक्षत्र" : "Nakshatra"), starDisplay, font: _bodyFont, primaryColor: primaryColor, labelWidth: 52, fontSize: 7.0),
                              _buildDetailRow("கௌரி", gowriStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 52, fontSize: 7.0),
                              _buildDetailRow("சூரிய அஸ்தமனம்", sunsetStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 52, fontSize: 7.0),
                            ],
                          ),
                        ),
                        pw.Container(width: 0.8, height: 68, color: borderCol, margin: const pw.EdgeInsets.symmetric(horizontal: 6)),
                        // Column 3: குளிகாதி காலங்கள்
                        pw.Expanded(
                          flex: 36,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("ராகு காலம்", rahuStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 56, fontSize: 7.0),
                              _buildDetailRow("எமகண்டம்", yamaStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 56, fontSize: 7.0),
                              _buildDetailRow("குளிகை", kuligaiStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 56, fontSize: 7.0),
                              _buildDetailRow("காலன்", kalanStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 56, fontSize: 7.0),
                              _buildDetailRow("அர்தபிரகணன்", arthaStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 56, fontSize: 7.0),
                              _buildDetailRow("இரவு எமகண்டம்", nightYamaStr, font: _bodyFont, primaryColor: primaryColor, labelWidth: 56, fontSize: 7.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 5),

                  // -----------------------------------------------------------
                  // 3. DUAL CHARTS SIDE-BY-SIDE (ENLARGED & PROMINENT)
                  // -----------------------------------------------------------
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Chart 1: ஜாமக்கோள் பிரசன்னம்
                      pw.Expanded(
                        child: _buildJamakkolChart(
                          outerBadgesBySign: outerBadgesBySign,
                          innerItemsBySign: innerItemsBySign,
                          udayamSign: udayamSign,
                          arudamSign: arudamSign,
                          kavippuSign: kavippuSign,
                          uDeg: uDeg,
                          aDeg: aDeg,
                          kDeg: kDeg,
                          langCode: langCode,
                          font: _bodyFont!,
                          headingFont: _headingFont!,
                          primaryColor: primaryColor,
                          borderCol: primaryColor,
                          bgIvory: bgIvory,
                          blueColor: blueColor,
                          greenColor: greenColor,
                          redColor: redColor,
                        ),
                      ),

                      pw.SizedBox(width: 8),

                      // Chart 2: கதிர்கள் கட்டம்
                      pw.Expanded(
                        child: _buildKathirgalChart(
                          kathirMap: kathirMap,
                          bhavaBySign: bhavaBySign,
                          strength: strength,
                          udayamSign: udayamSign,
                          arudamSign: arudamSign,
                          kavippuSign: kavippuSign,
                          font: _bodyFont!,
                          headingFont: _headingFont!,
                          primaryColor: primaryColor,
                          borderCol: primaryColor,
                          bgIvory: bgIvory,
                          goldAccent: goldAccent,
                          greenColor: greenColor,
                          blueColor: blueColor,
                          redColor: redColor,
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 4),

                  // -----------------------------------------------------------
                  // 4. SUBTITLE: (கிரக பாதசாரம் மற்றும் நிலைகள்)
                  // -----------------------------------------------------------
                  pw.Center(
                    child: pw.Text(
                      (langCode == 'ta'
                          ? "(கிரக பாதசாரம் மற்றும் நிலைகள்)"
                          : (langCode == 'hi' ? "(ग्रह पदचार एवं स्थिति)" : "(Planetary Positions & Padacharam)")).toTamilPdf,
                      style: pw.TextStyle(font: _headingFont, fontSize: 8.8, color: primaryColor),
                    ),
                  ),

                  pw.SizedBox(height: 2.5),

                  // -----------------------------------------------------------
                  // 5. DUAL TABLES SIDE-BY-SIDE (ENLARGED FONT & ROW HEIGHT)
                  // -----------------------------------------------------------
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Table 1: ஜாமக்கோள்கள் மற்றும் முக்கிய புள்ளிகள்
                      pw.Expanded(
                        child: _buildPointsTable(
                          uDeg: uDeg,
                          aDeg: aDeg,
                          kDeg: kDeg,
                          rahuKalamDeg: rahuKalamDeg,
                          yamaDeg: yamaDeg,
                          mrityuDeg: mrityuDeg,
                          maanthiDeg: maanthiDeg,
                          pDegs: pDegs,
                          namingMap: namingMap,
                          font: _bodyFont!,
                          headingFont: _headingFont!,
                          primaryColor: primaryColor,
                          borderCol: borderCol,
                          bgIvory: bgIvory,
                          langCode: langCode,
                        ),
                      ),

                      pw.SizedBox(width: 8),

                      // Table 2: கோச்சார கிரகங்கள்
                      pw.Expanded(
                        child: _buildGocharaTable(
                          details: details,
                          inner: inner,
                          notes: notes,
                          font: _bodyFont!,
                          headingFont: _headingFont!,
                          primaryColor: primaryColor,
                          borderCol: borderCol,
                          bgIvory: bgIvory,
                          langCode: langCode,
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 3.5),

                  // -----------------------------------------------------------
                  // 6. FLOATING CARD: ஜாமக்கோள் பிரசன்ன விபரம் (16 Points in 2 Columns)
                  // -----------------------------------------------------------
                  _buildJamakkolNotesCard(
                    notes: notes,
                    font: _bodyFont!,
                    headingFont: _headingFont!,
                    primaryColor: primaryColor,
                    borderCol: borderCol,
                    goldAccent: goldAccent,
                    langCode: langCode,
                  ),

                  pw.Spacer(),

                  // -----------------------------------------------------------
                  // 7. FOOTER
                  // -----------------------------------------------------------
                  pw.Container(
                    padding: const pw.EdgeInsets.only(top: 2),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: borderCol, width: 0.5)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("GB ASTRO ஜோதிட மென்பொருள்".toTamilPdf, style: pw.TextStyle(font: _bodyFont, fontSize: 6.8, color: textMuted)),
                        pw.Text("அறிக்கை அச்சிடப்பட்ட நேரம்: $nowStr".toTamilPdf, style: pw.TextStyle(font: _bodyFont, fontSize: 6.8, color: textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // ---------------------------------------------------------------------------
  // HELPER: DETAIL ROW
  // ---------------------------------------------------------------------------
  static pw.Widget _buildDetailRow(
    String label,
    String value, {
    required pw.Font? font,
    required PdfColor primaryColor,
    double labelWidth = 54,
    double fontSize = 7.0,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: labelWidth,
            child: pw.Text(
              label.toTamilPdf,
              style: pw.TextStyle(font: font, fontSize: fontSize, color: primaryColor),
            ),
          ),
          pw.Text(": ", style: pw.TextStyle(font: font, fontSize: fontSize, color: primaryColor)),
          pw.Expanded(
            child: pw.Text(
              value.toTamilPdf,
              style: pw.TextStyle(font: font, fontSize: fontSize, color: PdfColor.fromHex('#212121')),
              maxLines: 1,
              overflow: pw.TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHorizontalBadge(List<Map<String, dynamic>> items, pw.Font font) {
    if (items.isEmpty) return pw.SizedBox();
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: items.map((item) {
          final isLord = item['isUdayaLord'] as bool;
          final bgCol = isLord ? PdfColor.fromHex('#1B5E20') : PdfColor.fromHex('#D84315');
          return pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 1.0),
            padding: const pw.EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
            decoration: pw.BoxDecoration(
              color: bgCol,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3.5)),
              border: pw.Border.all(color: PdfColors.white, width: 0.8),
            ),
            child: pw.Text(
              "${item['name']} ${item['deg']}".toTamilPdf,
              style: pw.TextStyle(font: font, fontSize: 7.2, color: PdfColors.white),
            ),
          );
        }).toList(),
      ),
    );
  }

  static pw.Widget _buildVerticalBadge(List<Map<String, dynamic>> items, pw.Font font) {
    if (items.isEmpty) return pw.SizedBox();
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: items.map((item) {
          final isLord = item['isUdayaLord'] as bool;
          final bgCol = isLord ? PdfColor.fromHex('#1B5E20') : PdfColor.fromHex('#D84315');
          return pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 1.0),
            padding: const pw.EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
            decoration: pw.BoxDecoration(
              color: bgCol,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3.5)),
              border: pw.Border.all(color: PdfColors.white, width: 0.8),
            ),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  item['name'].toString().toTamilPdf,
                  style: pw.TextStyle(font: font, fontSize: 7.2, color: PdfColors.white),
                ),
                pw.Text(
                  item['deg'].toString().toTamilPdf,
                  style: pw.TextStyle(font: font, fontSize: 6.5, color: PdfColors.white),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: CHART 1 (JAMAKKOL PRASANNAM)
  // ---------------------------------------------------------------------------
  static pw.Widget _buildJamakkolChart({
    required Map<String, List<Map<String, dynamic>>> outerBadgesBySign,
    required Map<String, List<Map<String, dynamic>>> innerItemsBySign,
    required String udayamSign,
    required String arudamSign,
    required String kavippuSign,
    required double uDeg,
    required double aDeg,
    required double kDeg,
    required String langCode,
    required pw.Font font,
    required pw.Font headingFont,
    required PdfColor primaryColor,
    required PdfColor borderCol,
    required PdfColor bgIvory,
    required PdfColor blueColor,
    required PdfColor greenColor,
    required PdfColor redColor,
  }) {
    pw.Widget cell(String sign) {
      final items = innerItemsBySign[sign] ?? [];

      bool isUdayam = sign == udayamSign;
      bool isArudam = sign == arudamSign;
      bool isKavippu = sign == kavippuSign;

      PdfColor cellBg = bgIvory;
      if (isUdayam) {
        cellBg = PdfColor.fromHex('#E8F5E9');
      } else if (isArudam) {
        cellBg = PdfColor.fromHex('#E3F2FD');
      } else if (isKavippu) {
        cellBg = PdfColor.fromHex('#FFEBEE');
      }

      String udayamLabel = "";
      if (isUdayam) {
        double degInSign = uDeg % 30.0;
        int d = degInSign.floor();
        int m = ((degInSign - d) * 60).floor();
        String prefix = langCode == 'ta' ? 'உத' : (langCode == 'hi' ? 'उदा' : 'Uda');
        udayamLabel = "$prefix ${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
      }

      String arudamLabel = "";
      if (isArudam) {
        double degInSign = aDeg % 30.0;
        int d = degInSign.floor();
        int m = ((degInSign - d) * 60).floor();
        String prefix = langCode == 'ta' ? 'ஆரூ' : (langCode == 'hi' ? 'आरू' : 'Aru');
        arudamLabel = "$prefix ${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
      }

      String kavippuLabel = "";
      if (isKavippu) {
        double degInSign = kDeg % 30.0;
        int d = degInSign.floor();
        int m = ((degInSign - d) * 60).floor();
        String prefix = langCode == 'ta' ? 'கவி' : (langCode == 'hi' ? 'कवि' : 'Kav');
        kavippuLabel = "$prefix ${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
      }

      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderCol, width: 0.5),
          color: cellBg,
        ),
        padding: const pw.EdgeInsets.all(1.5),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            // Top: Badges for Udayam, Arudam, Kavippu
            if (isUdayam || isArudam || isKavippu)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 1.0),
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    if (isUdayam)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.8),
                        decoration: pw.BoxDecoration(
                          color: greenColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
                        ),
                        child: pw.Text(
                          udayamLabel.toTamilPdf,
                          style: pw.TextStyle(font: headingFont, fontSize: 5.5, color: PdfColors.white),
                        ),
                      ),
                    if (isArudam)
                      pw.Container(
                        margin: const pw.EdgeInsets.only(left: 1),
                        padding: const pw.EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.8),
                        decoration: pw.BoxDecoration(
                          color: blueColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
                        ),
                        child: pw.Text(
                          arudamLabel.toTamilPdf,
                          style: pw.TextStyle(font: headingFont, fontSize: 5.5, color: PdfColors.white),
                        ),
                      ),
                    if (isKavippu)
                      pw.Container(
                        margin: const pw.EdgeInsets.only(left: 1),
                        padding: const pw.EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.8),
                        decoration: pw.BoxDecoration(
                          color: redColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
                        ),
                        child: pw.Text(
                          kavippuLabel.toTamilPdf,
                          style: pw.TextStyle(font: headingFont, fontSize: 5.5, color: PdfColors.white),
                        ),
                      ),
                  ],
                ),
              ),

            // Inner Items (Subplanets, Lagna, Gochara grahas)
            ...items.map((item) {
              final type = item['type'] as String;
              final label = item['label'] as String;

              if (type == 'sub_yama') {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 0.8),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 1.5, vertical: 0.5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFF59D'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
                    border: pw.Border.all(color: PdfColor.fromHex('#FBC02D'), width: 0.4),
                  ),
                  child: pw.Text(
                    label.toTamilPdf,
                    style: pw.TextStyle(font: headingFont, fontSize: 5.0, color: PdfColor.fromHex('#E65100')),
                  ),
                );
              } else if (type == 'sub_rahu') {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 0.8),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 1.5, vertical: 0.5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#EDE7F6'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
                    border: pw.Border.all(color: PdfColor.fromHex('#7B1FA2'), width: 0.4),
                  ),
                  child: pw.Text(
                    label.toTamilPdf,
                    style: pw.TextStyle(font: headingFont, fontSize: 5.0, color: PdfColor.fromHex('#4A148C')),
                  ),
                );
              } else if (type == 'sub_mrityu') {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 0.8),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 1.5, vertical: 0.5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#ECEFF1'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
                    border: pw.Border.all(color: PdfColor.fromHex('#607D8B'), width: 0.4),
                  ),
                  child: pw.Text(
                    label.toTamilPdf,
                    style: pw.TextStyle(font: headingFont, fontSize: 5.0, color: PdfColor.fromHex('#263238')),
                  ),
                );
              } else if (type == 'lagna') {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 0.8),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 1.5, vertical: 0.5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E8F5E9'),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1.5)),
                    border: pw.Border.all(color: PdfColor.fromHex('#2E7D32'), width: 0.4),
                  ),
                  child: pw.Text(
                    label.toTamilPdf,
                    style: pw.TextStyle(font: headingFont, fontSize: 5.0, color: PdfColor.fromHex('#1B5E20')),
                  ),
                );
              } else {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 0.5),
                  child: pw.Text(
                    label.toTamilPdf,
                    style: pw.TextStyle(font: headingFont, fontSize: 5.2, color: blueColor),
                  ),
                );
              }
            }),
          ],
        ),
      );
    }

    // Center 2x2 Box
    pw.Widget centerBox() {
      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderCol, width: 0.5),
          color: PdfColors.white,
        ),
        padding: const pw.EdgeInsets.all(3),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              "ஜாமக்கோள்".toTamilPdf,
              style: pw.TextStyle(font: headingFont, fontSize: 10.0, color: primaryColor),
            ),
            pw.Text(
              "பிரசன்னக் கட்டம்".toTamilPdf,
              style: pw.TextStyle(font: headingFont, fontSize: 10.0, color: primaryColor),
            ),
            pw.Container(width: 44, height: 0.6, color: primaryColor, margin: const pw.EdgeInsets.symmetric(vertical: 2.0)),
            pw.Text("உதயம்: ${KPService.TAMIL_SIGNS[udayamSign]}".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.2, color: greenColor)),
            pw.Text("ஆரூடம்: ${KPService.TAMIL_SIGNS[arudamSign]}".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.2, color: blueColor)),
            pw.Text("கவிப்பு: ${KPService.TAMIL_SIGNS[kavippuSign]}".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.2, color: redColor)),
          ],
        ),
      );
    }

    const double chartH = 205.0;
    const double outerBadgeH = 18.0;
    const double outerBadgeW = 30.0;

    return pw.Container(
      height: chartH,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // 1. Top Outer Badges Row (Pisces, Aries, Taurus, Gemini)
          pw.Container(
            height: outerBadgeH,
            child: pw.Row(
              children: [
                pw.SizedBox(width: outerBadgeW),
                pw.Expanded(child: _buildHorizontalBadge(outerBadgesBySign['Pisces'] ?? [], headingFont)),
                pw.Expanded(child: _buildHorizontalBadge(outerBadgesBySign['Aries'] ?? [], headingFont)),
                pw.Expanded(child: _buildHorizontalBadge(outerBadgesBySign['Taurus'] ?? [], headingFont)),
                pw.Expanded(child: _buildHorizontalBadge(outerBadgesBySign['Gemini'] ?? [], headingFont)),
                pw.SizedBox(width: outerBadgeW),
              ],
            ),
          ),

          // 2. Middle Section: Left Badges | 4x4 Grid | Right Badges
          pw.Expanded(
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Left Column: Row 0 corner, Aquarius, Capricorn, Row 3 corner
                pw.Container(
                  width: outerBadgeW,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Expanded(flex: 1, child: pw.SizedBox()),
                      pw.Expanded(flex: 1, child: _buildVerticalBadge(outerBadgesBySign['Aquarius'] ?? [], headingFont)),
                      pw.Expanded(flex: 1, child: _buildVerticalBadge(outerBadgesBySign['Capricorn'] ?? [], headingFont)),
                      pw.Expanded(flex: 1, child: pw.SizedBox()),
                    ],
                  ),
                ),

                // Center: 4x4 Rasi Grid
                pw.Expanded(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: borderCol, width: 0.8)),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        // Row 0: Pisces, Aries, Taurus, Gemini
                        pw.Expanded(
                          flex: 1,
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              pw.Expanded(flex: 1, child: cell('Pisces')),
                              pw.Expanded(flex: 1, child: cell('Aries')),
                              pw.Expanded(flex: 1, child: cell('Taurus')),
                              pw.Expanded(flex: 1, child: cell('Gemini')),
                            ],
                          ),
                        ),
                        // Middle Section (Rows 1 & 2)
                        pw.Expanded(
                          flex: 2,
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              pw.Expanded(
                                flex: 1,
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                                  children: [
                                    pw.Expanded(flex: 1, child: cell('Aquarius')),
                                    pw.Expanded(flex: 1, child: cell('Capricorn')),
                                  ],
                                ),
                              ),
                              pw.Expanded(flex: 2, child: centerBox()),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                                  children: [
                                    pw.Expanded(flex: 1, child: cell('Cancer')),
                                    pw.Expanded(flex: 1, child: cell('Leo')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Row 3: Sagittarius, Scorpio, Libra, Virgo
                        pw.Expanded(
                          flex: 1,
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              pw.Expanded(flex: 1, child: cell('Sagittarius')),
                              pw.Expanded(flex: 1, child: cell('Scorpio')),
                              pw.Expanded(flex: 1, child: cell('Libra')),
                              pw.Expanded(flex: 1, child: cell('Virgo')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Column: Row 0 corner, Cancer, Leo, Row 3 corner
                pw.Container(
                  width: outerBadgeW,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Expanded(flex: 1, child: pw.SizedBox()),
                      pw.Expanded(flex: 1, child: _buildVerticalBadge(outerBadgesBySign['Cancer'] ?? [], headingFont)),
                      pw.Expanded(flex: 1, child: _buildVerticalBadge(outerBadgesBySign['Leo'] ?? [], headingFont)),
                      pw.Expanded(flex: 1, child: pw.SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Outer Badges Row (Sagittarius, Scorpio, Libra, Virgo)
          pw.Container(
            height: outerBadgeH,
            child: pw.Row(
              children: [
                pw.SizedBox(width: outerBadgeW),
                pw.Expanded(child: _buildHorizontalBadge(outerBadgesBySign['Sagittarius'] ?? [], headingFont)),
                pw.Expanded(child: _buildHorizontalBadge(outerBadgesBySign['Scorpio'] ?? [], headingFont)),
                pw.Expanded(child: _buildHorizontalBadge(outerBadgesBySign['Libra'] ?? [], headingFont)),
                pw.Expanded(child: _buildHorizontalBadge(outerBadgesBySign['Virgo'] ?? [], headingFont)),
                pw.SizedBox(width: outerBadgeW),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: CHART 2 (KATHIRGAL CHART)
  // ---------------------------------------------------------------------------
  static pw.Widget _buildKathirgalChart({
    required Map<dynamic, dynamic> kathirMap,
    required Map<String, dynamic> bhavaBySign,
    required Map<dynamic, dynamic> strength,
    required String udayamSign,
    required String arudamSign,
    required String kavippuSign,
    required pw.Font font,
    required pw.Font headingFont,
    required PdfColor primaryColor,
    required PdfColor borderCol,
    required PdfColor bgIvory,
    required PdfColor goldAccent,
    required PdfColor greenColor,
    required PdfColor blueColor,
    required PdfColor redColor,
  }) {
    pw.Widget cell(String sign) {
      final bData = bhavaBySign[sign] as Map<String, dynamic>?;
      final totalK = bData?['totalDisplay'] ?? kathirMap[sign] ?? "-";
      final rasiK = bData?['rasiDisplay'] ?? JamakkolService.RASI_KATHIR[sign]?.toString() ?? "-";
      final planetK = bData?['planetDisplay'] ?? "0";

      bool isUdayam = sign == udayamSign;
      bool isArudam = sign == arudamSign;
      bool isKavippu = sign == kavippuSign;

      PdfColor cellBg = bgIvory;
      if (isUdayam) {
        cellBg = PdfColor.fromHex('#E8F5E9');
      } else if (isArudam) {
        cellBg = PdfColor.fromHex('#E3F2FD');
      } else if (isKavippu) {
        cellBg = PdfColor.fromHex('#FFEBEE');
      }

      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderCol, width: 0.6),
          color: cellBg,
        ),
        padding: const pw.EdgeInsets.all(2.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Top: Badges (No sign name)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                if (isUdayam)
                  pw.Text("(உத)".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 6.5, color: greenColor))
                else if (isArudam)
                  pw.Text("(ஆரூ)".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 6.5, color: blueColor))
                else if (isKavippu)
                  pw.Text("(கவி)".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 6.5, color: redColor))
                else
                  pw.SizedBox(height: 8),
              ],
            ),

            // Middle: Total Kathir
            pw.Center(
              child: pw.Text(
                "$totalK கதிர்".toTamilPdf,
                style: pw.TextStyle(font: headingFont, fontSize: 9.5, color: primaryColor),
              ),
            ),

            // Bottom: Formula (Rasi + Planet)
            pw.Text(
              "ராசி:$rasiK + கிர:$planetK".toTamilPdf,
              style: pw.TextStyle(font: font, fontSize: 5.8, color: textColDark),
            ),
          ],
        ),
      );
    }

    // Center 2x2 Box
    pw.Widget centerBox() {
      final uTotal = strength['udayam']?['totalDisplay'] ?? strength['udayam']?['total'] ?? "-";
      final aTotal = strength['arudam']?['totalDisplay'] ?? strength['arudam']?['total'] ?? "-";
      final kTotal = strength['kavi']?['totalDisplay'] ?? strength['kavi']?['total'] ?? "-";

      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderCol, width: 0.6),
          color: PdfColors.white,
        ),
        padding: const pw.EdgeInsets.all(4),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              "கதிர்கள்".toTamilPdf,
              style: pw.TextStyle(font: headingFont, fontSize: 11.5, color: primaryColor),
            ),
            pw.Container(width: 46, height: 0.6, color: primaryColor, margin: const pw.EdgeInsets.symmetric(vertical: 2.5)),
            pw.Text("உதயக் கதிர்: $uTotal".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: greenColor)),
            pw.Text("ஆருடக் கதிர்: $aTotal".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: blueColor)),
            pw.Text("கவிப்புக் கதிர்: $kTotal".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: redColor)),
          ],
        ),
      );
    }

    const double chartH = 205;

    return pw.Container(
      height: chartH,
      decoration: pw.BoxDecoration(border: pw.Border.all(color: borderCol, width: 1.0)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(flex: 1, child: cell('Pisces')),
                pw.Expanded(flex: 1, child: cell('Aries')),
                pw.Expanded(flex: 1, child: cell('Taurus')),
                pw.Expanded(flex: 1, child: cell('Gemini')),
              ],
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Expanded(flex: 1, child: cell('Aquarius')),
                      pw.Expanded(flex: 1, child: cell('Capricorn')),
                    ],
                  ),
                ),
                pw.Expanded(flex: 2, child: centerBox()),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Expanded(flex: 1, child: cell('Cancer')),
                      pw.Expanded(flex: 1, child: cell('Leo')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Expanded(flex: 1, child: cell('Sagittarius')),
                pw.Expanded(flex: 1, child: cell('Scorpio')),
                pw.Expanded(flex: 1, child: cell('Libra')),
                pw.Expanded(flex: 1, child: cell('Virgo')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const PdfColor textColDark = PdfColor.fromInt(0xFF263238);

  // ---------------------------------------------------------------------------
  // HELPER: TABLE 1 (JAMAKKOL GRAHAS & KEY POINTS)
  // ---------------------------------------------------------------------------
  static pw.Widget _buildPointsTable({
    required double uDeg,
    required double aDeg,
    required double kDeg,
    required double rahuKalamDeg,
    required double yamaDeg,
    required double mrityuDeg,
    required double maanthiDeg,
    required Map pDegs,
    required Map namingMap,
    required pw.Font font,
    required pw.Font headingFont,
    required PdfColor primaryColor,
    required PdfColor borderCol,
    required PdfColor bgIvory,
    required String langCode,
  }) {
    List<Map<String, dynamic>> rows = [
      {'num': '1', 'name': 'உதயம்', 'deg': uDeg},
      {'num': '2', 'name': 'ஆரூடம்', 'deg': aDeg},
      {'num': '3', 'name': 'கவிப்பு', 'deg': kDeg},
      {'num': '4', 'name': 'இராகு காலம்', 'deg': rahuKalamDeg},
      {'num': '5', 'name': 'எமகண்டன்', 'deg': yamaDeg},
      {'num': '6', 'name': 'மிருத்யு', 'deg': mrityuDeg},
      {'num': '7', 'name': 'குளிகன்/மாந்தி', 'deg': maanthiDeg},
      {'num': '8', 'name': 'பாம்பு', 'deg': (pDegs['Rahu'] as num?)?.toDouble() ?? 0.0},
      {'num': '9', 'name': 'சூரியன்', 'deg': (pDegs['Sun'] as num?)?.toDouble() ?? 0.0},
      {'num': '10', 'name': 'சந்திரன்', 'deg': (pDegs['Moon'] as num?)?.toDouble() ?? 0.0},
      {'num': '11', 'name': 'செவ்வாய்', 'deg': (pDegs['Mars'] as num?)?.toDouble() ?? 0.0},
      {'num': '12', 'name': 'புதன்', 'deg': (pDegs['Mercury'] as num?)?.toDouble() ?? 0.0},
      {'num': '13', 'name': 'குரு', 'deg': (pDegs['Jupiter'] as num?)?.toDouble() ?? 0.0},
      {'num': '14', 'name': 'சுக்கிரன்', 'deg': (pDegs['Venus'] as num?)?.toDouble() ?? 0.0},
      {'num': '15', 'name': 'சனி', 'deg': (pDegs['Saturn'] as num?)?.toDouble() ?? 0.0},
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderCol, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Column(
        children: [
          // Table Header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 4),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(2.5), topRight: pw.Radius.circular(2.5)),
            ),
            child: pw.Center(
              child: pw.Text(
                "ஜாமக்கோள்கள் மற்றும் முக்கிய புள்ளிகள்".toTamilPdf,
                style: pw.TextStyle(font: headingFont, fontSize: 8.5, color: PdfColors.white),
              ),
            ),
          ),
          // Sub Header Row
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 3),
            color: PdfColor.fromHex('#F5ECE3'),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 95, child: pw.Text("கிரகம் / புள்ளி".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: primaryColor))),
                pw.SizedBox(width: 60, child: pw.Text("பாகை".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: primaryColor), textAlign: pw.TextAlign.center)),
                pw.Expanded(child: pw.Text("நட்சத்திரம்/பாதம்".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: primaryColor), textAlign: pw.TextAlign.right)),
              ],
            ),
          ),
          // Data Rows
          ...rows.map((r) {
            double deg = r['deg'] as double;
            var sp = _getStarPada(deg, langCode);
            String degStr = _formatDeg(deg);
            String label = "${r['num']}. ${r['name']}";
            bool isEven = int.parse(r['num']) % 2 == 0;

            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 1.6, horizontal: 3),
              decoration: pw.BoxDecoration(
                color: isEven ? PdfColor.fromHex('#FAF7F2') : PdfColors.white,
                border: pw.Border(top: pw.BorderSide(color: borderCol, width: 0.3)),
              ),
              child: pw.Row(
                children: [
                  pw.SizedBox(width: 95, child: pw.Text(label.toTamilPdf, style: pw.TextStyle(font: font, fontSize: 7.2, color: textColDark))),
                  pw.SizedBox(width: 60, child: pw.Text(degStr.toTamilPdf, style: pw.TextStyle(font: font, fontSize: 7.2, color: primaryColor), textAlign: pw.TextAlign.center)),
                  pw.Expanded(child: pw.Text("${sp['star']} - ${sp['pada']}".toTamilPdf, style: pw.TextStyle(font: font, fontSize: 7.2, color: textColDark), textAlign: pw.TextAlign.right)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: TABLE 2 (GOCHARA GRAHAS)
  // ---------------------------------------------------------------------------
  static pw.Widget _buildGocharaTable({
    required Map details,
    required Map inner,
    required Map notes,
    required pw.Font font,
    required pw.Font headingFont,
    required PdfColor primaryColor,
    required PdfColor borderCol,
    required PdfColor bgIvory,
    required String langCode,
  }) {
    final planetsList = [
      {'name': '1. லக்னம்', 'key': 'lagna'},
      {'name': '2. சூரியன்', 'key': 'sun'},
      {'name': '3. சந்திரன்', 'key': 'moon'},
      {'name': '4. செவ்வாய்', 'key': 'mars'},
      {'name': '5. புதன்', 'key': 'mercury'},
      {'name': '6. குரு', 'key': 'jupiter'},
      {'name': '7. சுக்கிரன்', 'key': 'venus'},
      {'name': '8. சனி', 'key': 'saturn'},
      {'name': '9. ராகு', 'key': 'rahu'},
      {'name': '10. கேது', 'key': 'ketu'},
      {'name': '11. மாந்தி', 'key': 'maanthi'},
    ];

    // Extra Rows to maintain symmetrical 15 rows with Table 1
    final uLord = notes['udayam_lord_house']?.toString() ?? "-";
    final aLord = notes['arudam_lord_house']?.toString() ?? "-";
    final bLord = notes['badhaka_lord_details'] as Map? ?? {};
    final eLord = notes['eighth_lord_details'] as Map? ?? {};

    String uLordStr = "-";
    if (uLord != "-") {
      uLordStr = langCode == 'en' ? "House $uLord" : (langCode == 'hi' ? "$uLord भाव" : "$uLord-ம் பாவம்");
    }

    String aLordStr = "-";
    if (aLord != "-") {
      aLordStr = langCode == 'en' ? "House $aLord" : (langCode == 'hi' ? "$aLord भाव" : "$aLord-ம் பாவம்");
    }

    String bLordStr = "-";
    if (bLord.isNotEmpty && bLord['lord'] != null) {
      String p = _translatePlanet(bLord['lord'], langCode);
      String h = bLord['house']?.toString() ?? "";
      bLordStr = langCode == 'en' ? "$p (in $h)" : (langCode == 'hi' ? "$p ($h में)" : "$p ($h-ல்)");
    }

    String eLordStr = "-";
    if (eLord.isNotEmpty && eLord['lord'] != null) {
      String p = _translatePlanet(eLord['lord'], langCode);
      String h = eLord['house']?.toString() ?? "";
      eLordStr = langCode == 'en' ? "$p (in $h)" : (langCode == 'hi' ? "$p ($h में)" : "$p ($h-ல்)");
    }

    final extraRows = [
      {'name': '12. உதயாதிபதி நின்ற பாவம்', 'val': uLordStr},
      {'name': '13. ஆருடாதிபதி நின்ற பாவம்', 'val': aLordStr},
      {'name': '14. பாதகாதிபதி நின்ற பாவம்', 'val': bLordStr},
      {'name': '15. எட்டாம் அதிபதி நின்ற பாவம்', 'val': eLordStr},
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderCol, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Column(
        children: [
          // Table Header
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 4),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(2.5), topRight: pw.Radius.circular(2.5)),
            ),
            child: pw.Center(
              child: pw.Text(
                "கோச்சார கிரகங்கள்".toTamilPdf,
                style: pw.TextStyle(font: headingFont, fontSize: 8.5, color: PdfColors.white),
              ),
            ),
          ),
          // Sub Header Row
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 3),
            color: PdfColor.fromHex('#F5ECE3'),
            child: pw.Row(
              children: [
                pw.SizedBox(width: 95, child: pw.Text("கிரகம்".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: primaryColor))),
                pw.SizedBox(width: 60, child: pw.Text("பாகை".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: primaryColor), textAlign: pw.TextAlign.center)),
                pw.Expanded(child: pw.Text("நட்சத்திரம்/பாதம்".toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.5, color: primaryColor), textAlign: pw.TextAlign.right)),
              ],
            ),
          ),
          // Planet Rows
          ...planetsList.map((p) {
            String key = p['key']!;
            double deg = 0.0;
            String spStr = "-";
            if (details.containsKey(key) && details[key] != null) {
              deg = (details[key]['longitude'] as num?)?.toDouble() ?? 0.0;
              var sp = _getStarPada(deg, langCode);
              spStr = "${sp['star']} - ${sp['pada']}";
            }
            String degStr = _formatDeg(deg);
            int idx = planetsList.indexOf(p) + 1;
            bool isEven = idx % 2 == 0;

            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 1.6, horizontal: 3),
              decoration: pw.BoxDecoration(
                color: isEven ? PdfColor.fromHex('#FAF7F2') : PdfColors.white,
                border: pw.Border(top: pw.BorderSide(color: borderCol, width: 0.3)),
              ),
              child: pw.Row(
                children: [
                  pw.SizedBox(width: 95, child: pw.Text(p['name']!.toTamilPdf, style: pw.TextStyle(font: font, fontSize: 7.2, color: textColDark))),
                  pw.SizedBox(width: 60, child: pw.Text(degStr.toTamilPdf, style: pw.TextStyle(font: font, fontSize: 7.2, color: primaryColor), textAlign: pw.TextAlign.center)),
                  pw.Expanded(child: pw.Text(spStr.toTamilPdf, style: pw.TextStyle(font: font, fontSize: 7.2, color: textColDark), textAlign: pw.TextAlign.right)),
                ],
              ),
            );
          }),

          // Extra Symmetrical Rows
          ...extraRows.map((r) {
            int idx = planetsList.length + extraRows.indexOf(r) + 1;
            bool isEven = idx % 2 == 0;
            return pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 1.6, horizontal: 3),
              decoration: pw.BoxDecoration(
                color: isEven ? PdfColor.fromHex('#FAF7F2') : PdfColors.white,
                border: pw.Border(top: pw.BorderSide(color: borderCol, width: 0.3)),
              ),
              child: pw.Row(
                children: [
                  pw.SizedBox(width: 145, child: pw.Text(r['name']!.toTamilPdf, style: pw.TextStyle(font: font, fontSize: 6.8, color: textColDark))),
                  pw.Expanded(child: pw.Text(r['val']!.toTamilPdf, style: pw.TextStyle(font: headingFont, fontSize: 7.0, color: primaryColor), textAlign: pw.TextAlign.right)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: FLOATING CARD - JAMAKKOL PRASANNA VIVARAM (16 POINTS IN 2 COLUMNS)
  // ---------------------------------------------------------------------------
  static pw.Widget _buildJamakkolNotesCard({
    required Map<dynamic, dynamic> notes,
    required pw.Font font,
    required pw.Font headingFont,
    required PdfColor primaryColor,
    required PdfColor borderCol,
    required PdfColor goldAccent,
    required String langCode,
  }) {
    final isTa = langCode == 'ta';
    final isHi = langCode == 'hi';

    String getPName(dynamic name) {
      if (name == null) return "-";
      String n = name.toString().trim();
      if (n.toLowerCase() == 'rahu' || n == 'ராகு') {
        return isTa ? "பாம்பு" : (isHi ? "राहु" : "Snake");
      }
      return _translatePlanet(n, langCode);
    }

    String getStarLordName(dynamic name) {
      if (name == null) return "-";
      return _translatePlanet(name.toString().trim(), langCode);
    }

    String getRName(dynamic name) {
      if (name == null) return "-";
      String n = name.toString().trim();
      if (n.isEmpty || n == "-") return "-";
      if (isTa) {
        return KPService.TAMIL_SIGNS[n] ?? _engToTamStar[n] ?? n;
      } else if (isHi) {
        return KPService.HINDI_SIGNS[n] ?? _engToHiStar[n] ?? n;
      }
      return n;
    }

    String formatDegVal(num? val) {
      if (val == null) return "00:00";
      double d = (val.toDouble() % 30.0 + 30.0) % 30.0;
      int deg = d.floor();
      int min = ((d - deg) * 60).floor();
      return "${deg.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}";
    }

    // 1. Udayam star pada
    final uStar = notes['udayam_star'] as Map? ?? {};
    String uStarStr = "-";
    if (uStar.isNotEmpty) {
      String degStr = formatDegVal(uStar['deg'] as num?);
      String nak = getRName(uStar['nakshatra']);
      String pada = (uStar['pada'] ?? "-").toString();
      String lord = getStarLordName(uStar['lord']);
      String lordship = (uStar['lordship'] ?? "").toString();
      uStarStr = "$degStr $nak $pada $lord $lordship".trim();
    }

    // 2. Planet contacting Udayam
    final uContacts = notes['udayam_contact'] as List? ?? [];
    String uContactStr = "-";
    if (uContacts.isNotEmpty) {
      uContactStr = uContacts.map((c) {
        String p = getPName(c['planet']);
        String degStr = formatDegVal(c['deg'] as num?);
        String h = (c['house'] ?? "").toString();
        String l = (c['lordship'] ?? "").toString();
        return isTa 
            ? "$p\_$degStr / பாவம் $h / $l"
            : (isHi ? "$p\_$degStr / भाव $h / $l" : "$p\_$degStr / H$h / $l");
      }).join(", ");
    }

    // 3. Crossed planet
    final crossed = notes['crossed_planet'] as Map?;
    String crossedStr = "-";
    if (crossed != null) {
      String p = getPName(crossed['planet']);
      String l = (crossed['lordship'] ?? "").toString();
      String degStr = formatDegVal(crossed['deg'] as num?);
      crossedStr = "$p $l = $degStr";
    }

    // 4. Udayam lord house
    String uLordHouseStr = (notes['udayam_lord_house'] ?? "-").toString();

    // 5. Planet contacting Arudam
    final aContact = notes['arudam_contact'] as Map?;
    String aContactStr = "-";
    if (aContact != null) {
      String p = getPName(aContact['planet']);
      String degStr = formatDegVal(aContact['deg'] as num?);
      String nak = getRName(aContact['nakshatra']);
      String pada = (aContact['pada'] ?? "").toString();
      aContactStr = "$p\_$degStr $nak $pada".trim();
    }

    // 6. Arudam House
    final aHouse = notes['arudam_house_details'] as Map? ?? {};
    String aHouseStr = "-";
    if (aHouse.isNotEmpty) {
      String h = (aHouse['house'] ?? "").toString();
      String lord = getPName(aHouse['lord']);
      String lShip = (aHouse['lordship'] ?? "").toString();
      String degStr = formatDegVal(aHouse['deg'] as num?);
      String nak = getRName(aHouse['nakshatra']);
      String pada = (aHouse['pada'] ?? "").toString();
      aHouseStr = "$h $lord $lShip $degStr $nak $pada".trim();
    }

    // 7. Arudam lord house
    String aLordHouseStr = (notes['arudam_lord_house'] ?? "-").toString();

    // 8. Kavippu House
    final kHouse = notes['kavi_house_details'] as Map? ?? {};
    String kHouseStr = "-";
    if (kHouse.isNotEmpty) {
      String h = (kHouse['house'] ?? "").toString();
      String degStr = formatDegVal(kHouse['deg'] as num?);
      String nak = getRName(kHouse['nakshatra']);
      String pada = (kHouse['pada'] ?? "").toString();
      kHouseStr = "$h $degStr $nak $pada".trim();
    }

    // 9. Planet covered by Kavippu
    final kPlanet = notes['kavi_planet_details'] as Map?;
    String kPlanetStr = "-";
    if (kPlanet != null) {
      String p = getPName(kPlanet['planet']);
      String l = (kPlanet['lordship'] ?? "").toString();
      String degStr = formatDegVal(kPlanet['deg'] as num?);
      String nak = getRName(kPlanet['nakshatra']);
      String pada = (kPlanet['pada'] ?? "").toString();
      kPlanetStr = "$p - $l = $degStr $nak $pada".trim();
    }

    // 10. Udayam vs Arudam
    String uVsAStr = (notes['udayam_vs_arudam'] ?? "-").toString();

    // 11. Udayam vs Kavippu
    String uVsKStr = (notes['udayam_vs_kavi'] ?? "-").toString();

    // 12. Arudam vs Udayam
    String aVsUStr = (notes['arudam_vs_udayam'] ?? "-").toString();

    // 13. Arudam vs Kavippu
    String aVsKStr = (notes['arudam_vs_kavi'] ?? "-").toString();

    // 14. Sootchuma Rasi
    final sootchuma = notes['sootchuma_details'] as Map? ?? {};
    String sootchumaStr = getRName(sootchuma['rasi'] ?? "-");

    // 15. Outer Planet Ucham / Neecham
    final uchamList = (notes['ucham_planets'] as List?)?.cast<String>() ?? [];
    final neechamList = (notes['neecham_planets'] as List?)?.cast<String>() ?? [];
    List<String> unParts = [];
    if (uchamList.isNotEmpty) {
      String uNames = uchamList.map((p) => _translatePlanet(p, langCode)).join(", ");
      unParts.add(isTa ? "உச்சம் _ $uNames" : (isHi ? "उच्च _ $uNames" : "Exalted _ $uNames"));
    }
    if (neechamList.isNotEmpty) {
      String nNames = neechamList.map((p) => _translatePlanet(p, langCode)).join(", ");
      unParts.add(isTa ? "நீச்சம் _ $nNames" : (isHi ? "नीच _ $nNames" : "Debilitated _ $nNames"));
    }
    String uchamNeechamStr = unParts.isNotEmpty ? unParts.join(", ") : "-";

    // 16. Rasi Parivarthanai
    final pDetails = notes['parivarthana_details'] as List? ?? [];
    String parivarthanaiDisplayStr = "-";
    if (pDetails.isNotEmpty) {
      parivarthanaiDisplayStr = pDetails.map((d) {
        String s1 = getRName(d['sign1'] ?? "");
        String s2 = getRName(d['sign2'] ?? "");
        String p1 = _translatePlanet(d['planet1'] ?? "", langCode);
        String p2 = _translatePlanet(d['planet2'] ?? "", langCode);
        return "${s1}_${s2} ($p1, $p2)";
      }).join(", ");
    }

    final col1Items = [
      {'name': isTa ? '1. உதயம் நின்ற நட்சத்திர பாதம்' : (isHi ? '1. उदय नक्षत्र पाद' : '1. Udayam Star Pada'), 'val': uStarStr},
      {'name': isTa ? '2. உதயம் தொடர்பு கொள்ளும் கிரகம்' : (isHi ? '2. उदय संपर्क ग्रह' : '2. Planet Contacting Udayam'), 'val': uContactStr},
      {'name': isTa ? '3. உதயத்தைக் கடந்த கிரகம்' : (isHi ? '3. उदय पार किया ग्रह' : '3. Planet Passed Udayam'), 'val': crossedStr},
      {'name': isTa ? '4. உதயாதிபதி நின்ற பாவம்' : (isHi ? '4. उदयाधिपति भाव' : '4. Udayam Lord House'), 'val': uLordHouseStr},
      {'name': isTa ? '5. ஆருடம் தொடர்பு கொள்ளும் கிரகம்' : (isHi ? '5. आरूढ़ संपर्क ग्रह' : '5. Planet Contacting Arudam'), 'val': aContactStr},
      {'name': isTa ? '6. ஆருடம் உள்ள பாவம்' : (isHi ? '6. आरूढ़ भाव विवरण' : '6. Arudam House Details'), 'val': aHouseStr},
      {'name': isTa ? '7. ஆருட அதிபதி நின்ற பாவம்' : (isHi ? '7. आरूढ़ाधिपति भाव' : '7. Arudam Lord House'), 'val': aLordHouseStr},
      {'name': isTa ? '8. கவிப்புள்ள பாவம்' : (isHi ? '8. कविप्पु भाव विवरण' : '8. Kavippu House Details'), 'val': kHouseStr},
    ];

    final col2Items = [
      {'name': isTa ? '9. கவிக்கப்படும் கிரகம்' : (isHi ? '9. कविप्पु ग्रसित ग्रह' : '9. Planet Covered by Kavippu'), 'val': kPlanetStr},
      {'name': isTa ? '10. உதயம் vs ஆருடம்' : (isHi ? '10. उदय vs आरूढ़' : '10. Udayam vs Arudam'), 'val': uVsAStr},
      {'name': isTa ? '11. உதயம் vs கவிப்பு' : (isHi ? '11. उदय vs कविप्पु' : '11. Udayam vs Kavippu'), 'val': uVsKStr},
      {'name': isTa ? '12. ஆருடம் vs உதயம்' : (isHi ? '12. आरूढ़ vs उदय' : '12. Arudam vs Udayam'), 'val': aVsUStr},
      {'name': isTa ? '13. ஆருடம் vs கவிப்பு' : (isHi ? '13. आरूढ़ vs कविप्पु' : '13. Arudam vs Kavippu'), 'val': aVsKStr},
      {'name': isTa ? '14. சூட்சும ராசி' : (isHi ? '14. सूक्ष्म राशि' : '14. Sootchuma Rasi'), 'val': sootchumaStr},
      {'name': isTa ? '15. உச்சம் / நீச்சம்' : (isHi ? '15. उच्च / नीच' : '15. Exalted / Debilitated'), 'val': uchamNeechamStr},
      {'name': isTa ? '16. இராசி பரிவர்த்தனை' : (isHi ? '16. राशि परिवर्तन' : '16. Rasi Parivarthanai'), 'val': parivarthanaiDisplayStr},
    ];

    pw.Widget buildNoteRow(Map<String, String> item, bool isEven) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.2, horizontal: 3),
        decoration: pw.BoxDecoration(
          color: isEven ? PdfColor.fromHex('#FAF7F2') : PdfColors.white,
          border: pw.Border(top: pw.BorderSide(color: borderCol, width: 0.3)),
        ),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 110,
              child: pw.Text(
                item['name']!.toTamilPdf,
                style: pw.TextStyle(font: font, fontSize: 6.6, color: PdfColor.fromHex('#2E2E2E')),
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
              ),
            ),
            pw.Text(": ", style: pw.TextStyle(font: font, fontSize: 6.6, color: primaryColor)),
            pw.Expanded(
              child: pw.Text(
                item['val']!.toTamilPdf,
                style: pw.TextStyle(font: headingFont, fontSize: 6.6, color: primaryColor),
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 3.5),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#DFD5C6'), // subtle warm drop-shadow offset
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3.5)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 1.2, right: 1.2),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
          border: pw.Border.all(color: goldAccent, width: 0.7),
        ),
        child: pw.Column(
          children: [
            // Floating Card Header Banner
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 2.2, horizontal: 6),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: const pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(2.5),
                  topRight: pw.Radius.circular(2.5),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(width: 3, height: 7.5, color: goldAccent, margin: const pw.EdgeInsets.only(right: 5)),
                      pw.Text(
                        (isTa ? "ஜாமக்கோள் பிரசன்ன விபரம்" : (isHi ? "जामक्कोल प्रश्न विवरण" : "Jamakkol Prasanna Notes")).toTamilPdf,
                        style: pw.TextStyle(font: headingFont, fontSize: 8.0, color: PdfColors.white),
                      ),
                    ],
                  ),
                  pw.Text(
                    (isTa ? "(முக்கிய குறிப்புகள் 1 - 16)" : (isHi ? "(मुख्य बिंदु 1 - 16)" : "(Key Notes 1 - 16)")).toTamilPdf,
                    style: pw.TextStyle(font: font, fontSize: 6.5, color: goldAccent),
                  ),
                ],
              ),
            ),
            // Floating Card 2-Column Body
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left Column: Items 1 to 8
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      for (int i = 0; i < col1Items.length; i++)
                        buildNoteRow(col1Items[i], i % 2 == 1),
                    ],
                  ),
                ),
                // Center Divider
                pw.Container(width: 0.5, height: 8 * 12.0, color: borderCol),
                // Right Column: Items 9 to 16
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      for (int i = 0; i < col2Items.length; i++)
                        buildNoteRow(col2Items[i], i % 2 == 1),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
