import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'kp_service.dart';
import 'settings_service.dart';
import 'pdf_helper_stub.dart' if (dart.library.html) 'pdf_helper_web.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class GbOnePagePdfService {
  static String _toLocal(String p, String langCode) {
    final key = p.toLowerCase().trim();
    final Map<String, String> shortMap = langCode == 'en' 
        ? KPService.ENGLISH_PLANET_SHORT 
        : (langCode == 'hi' ? KPService.HINDI_PLANET_SHORT : KPService.TAMIL_PLANET_SHORT);
    final Map<String, String> fullMap = langCode == 'en' 
        ? KPService.ENGLISH_PLANETS 
        : (langCode == 'hi' ? KPService.HINDI_PLANETS : KPService.TAMIL_PLANETS);
    
    if (shortMap.containsKey(key)) return shortMap[key]!;
    if (shortMap.values.contains(p)) return p;
    for (var entry in fullMap.entries) {
      if (entry.value == p || entry.key == p) {
        return shortMap[entry.key] ?? shortMap[entry.key.toLowerCase()] ?? p;
      }
    }
    return p;
  }

  static final Map<String, String> _engToTam = {
    "Aries": "மேஷம்", "Taurus": "ரிஷபம்", "Gemini": "மிதுனம்", "Cancer": "கடகம்",
    "Leo": "சிம்மம்", "Virgo": "கன்னி", "Libra": "துலாம்", "Scorpio": "விருச்சிகம்",
    "Sagittarius": "தனுசு", "Capricorn": "மகரம்", "Aquarius": "கும்பம்", "Pisces": "மீனம்",
    "Ashwini": "அசுவனி", "Bharani": "பரணி", "Krittika": "கிருத்திகை", "Rohini": "ரோகிணி",
    "Mrigashirsha": "மிருகசீர்ஷம்", "Mrigashira": "மிருகசீர்ஷம்", "Arudra": "திருவாதிரை", "Ardra": "திருவாதிரை",
    "Punarvasu": "புனர்பூசம்", "Pushya": "பூசம்", "Pushyami": "பூசம்", "Aslesha": "ஆயில்யம்", "Ashlesha": "ஆயில்யம்",
    "Magha": "மகம்", "Purvaphalguni": "பூரம்", "Uttaraphalguni": "உத்திரம்", "Hastha": "அஸ்தம்", "Hasta": "அஸ்தம்",
    "Chitra": "சித்திரை", "Swati": "சுவாதி", "Vishakha": "விசாகம்", "Visakha": "விசாகம்", "Anuradha": "அனுஷம்",
    "Jyeshta": "கேட்டை", "Jyeshtha": "கேட்டை", "Mula": "மூலம்", "Moola": "மூலம்",
    "Purvashada": "பூராடம்", "PurvaAshadha": "பூராடம்", "Uttarashada": "உத்திராடம்", "UttaraAshadha": "உத்திராடம்",
    "Shravana": "திருவோணம்", "Dhanishta": "அவிட்டம்", "Shatabhisha": "சதயம்",
    "Purvabhadrapada": "பூரட்டாதி", "Uttarabhadrapada": "உத்திரட்டாதி", "Revati": "ரேவதி", "Revathi": "ரேவதி",
    "Sunday": "ஞாயிறு", "Monday": "திங்கள்", "Tuesday": "செவ்வாய்", "Wednesday": "புதன்",
    "Thursday": "வியாழன்", "Friday": "வெள்ளி", "Saturday": "சனி",
    "Bava": "பவம்", "Balava": "பாலவம்", "Kaulava": "கௌலவம்", "Taitila": "தைதுலை", "Garaja": "கரசை",
    "Vanija": "வணிசை", "Vishti": "பத்திரை", "Shakuni": "சகுனி", "Chatushpada": "சதுஷ்பாதம்", "Nagawa": "நாகவம்",
    "Kimstughna": "கிம்துக்கினம்",
    "Vishkumbha": "விஷ்கம்பம்", "Priti": "பிரீதி", "Ayushman": "ஆயுஷ்மான்", "Saubhagya": "சௌபாக்கியம்",
    "Sobhana": "சோபனம்", "Atiganda": "அதிகண்டம்", "Sukarma": "சுகர்மம்", "Dhriti": "திருதி",
    "Shula": "சூலம்", "Ganda": "கண்டம்", "Vriddhi": "விருத்தி", "Dhruva": "துருவம்",
    "Vyaghata": "வியாகாதம்", "Harshana": "ஹர்ஷணம்", "Vajra": "வஜ்ரம்", "Siddhi": "சித்தி",
    "Vyatipata": "வியதீபாதம்", "Variyan": "வரியான்", "Parigha": "பரிகம்", "Shiva": "சிவம்",
    "Siddha": "சித்தம்", "Sadhya": "சாத்தியம்", "Shubha": "சுபம்", "Shukla": "சுக்கிலம்",
    "Brahma": "பிரம்மா", "Indra": "ஐந்திரம்", "Vaidhriti": "வைதிருதி"
  };

  static String _normalizeTamil(String text) {
    if (text.isEmpty || text == "-") return text;
    String res = text;
    _engToTam.forEach((eng, tam) {
      res = res.replaceAll(RegExp(r'\b' + eng + r'\b', caseSensitive: false), tam);
    });
    return res;
  }

  static Future<void> showHtmlReport({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    required AppLocalizations l10n,
  }) async {
    if (!kIsWeb) return;
    final astro = await SettingsService.getAstrologerDetails();
    
    String gbLogoBase64 = "";
    String ganapathyBase64 = "";
    try {
      final byteDataL = await rootBundle.load('assets/images/logo.png');
      gbLogoBase64 = base64Encode(byteDataL.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error loading GB logo: $e");
    }
    try {
      final byteDataG = await rootBundle.load('assets/images/ganapathy.png');
      ganapathyBase64 = base64Encode(byteDataG.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error loading Ganapathy: $e");
    }

    final htmlContent = _buildFullHtml(name, gender, results, astro, gbLogoBase64, ganapathyBase64, l10n);
    printHtmlWeb(htmlContent);
  }

  static Future<Uint8List> generate({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    required AppLocalizations l10n,
  }) async {
    final astro = await SettingsService.getAstrologerDetails();
    
    String gbLogoBase64 = "";
    String ganapathyBase64 = "";
    try {
      final byteDataL = await rootBundle.load('assets/images/logo.png');
      gbLogoBase64 = base64Encode(byteDataL.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error loading GB logo: $e");
    }
    try {
      final byteDataG = await rootBundle.load('assets/images/ganapathy.png');
      ganapathyBase64 = base64Encode(byteDataG.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error loading Ganapathy: $e");
    }

    if (kIsWeb) return _generateDirectPdf(name, gender, results, astro);
    try {
      final htmlContent = _buildFullHtml(name, gender, results, astro, gbLogoBase64, ganapathyBase64, l10n);
      final Directory tempDir = await getTemporaryDirectory();
      final File pdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, 
        tempDir.path, 
        "gb_horoscope_${DateTime.now().millisecondsSinceEpoch}"
      );
      final Uint8List bytes = await pdfFile.readAsBytes();
      await pdfFile.delete();
      return bytes;
    } catch (e) {
      return _generateDirectPdf(name, gender, results, astro);
    }
  }

  static Future<Uint8List> _generateDirectPdf(String name, String gender, Map results, Map<String, String> astro) async {
    final pdf = pw.Document();
    return pdf.save();
  }

  static String _buildFullHtml(
    String name, 
    String gender, 
    Map results, 
    Map<String, String> astro, 
    String gbLogoBase64, 
    String ganapathyBase64, 
    AppLocalizations l10n
  ) {
    final String langCode = l10n.localeName;
    final details = results['planet_details'] as Map? ?? {};
    final pan = results['panchangam'] as Map? ?? {};
    final birthDt = results['birth_dt'] as DateTime?;
    
    // Recursive search variables
    String age = pan['age_display']?.toString() ?? pan['age']?.toString() ?? "";
    String birthTime = pan['birth_time']?.toString() ?? pan['time']?.toString() ?? pan['tob']?.toString() ?? "";
    String place = results['place']?.toString() ?? "";
    String shopName = ""; 
    String astroName = ""; 
    String address = ""; 
    String phone = "";
    
    void findDeep(dynamic data) {
      if (data is Map) {
        data.forEach((k, v) {
          final kStr = k.toString().toLowerCase();
          if (age.isEmpty && (kStr == 'age' || kStr == 'age_display')) age = v.toString();
          if (birthTime.isEmpty && (kStr == 'birth_time' || kStr == 'time' || kStr == 'tob')) birthTime = v.toString();
          if (place.isEmpty && (kStr == 'place' || kStr == 'pob' || kStr == 'city')) place = v.toString();
          if (shopName.isEmpty && (kStr.contains('shop_name') || kStr.contains('center_name'))) shopName = v.toString();
          if (astroName.isEmpty && (kStr.contains('astrologer_name') || kStr.contains('author'))) astroName = v.toString();
          if (address.isEmpty && kStr.contains('address')) address = v.toString();
          if (phone.isEmpty && (kStr.contains('phone') || kStr.contains('mobile'))) phone = v.toString();
          findDeep(v);
        });
      } else if (data is List) {
        for (var item in data) findDeep(item);
      }
    }
    findDeep(results);
    
    if (age.isEmpty && birthDt != null) {
      final now = DateTime.now();
      int years = now.year - birthDt.year;
      int months = now.month - birthDt.month;
      int days = now.day - birthDt.day;
      if (days < 0) { months -= 1; days += 30; }
      if (months < 0) { years -= 1; months += 12; }
      age = "$years வயது, $months மாதம், $days நாள்";
    }

    final aName = (astro['name'] ?? "").trim();
    final aAddr = (astro['address'] ?? "").trim();
    final aPhone = (astro['phone'] ?? "").trim();

    if (shopName.isEmpty) {
      shopName = aName.isNotEmpty ? aName : "ஜிபி அஸ்ட்ரோ ஜோதிட நிலையம்";
    }
    if (address.isEmpty) {
      address = aAddr.isNotEmpty ? aAddr : "GB ASTRO CENTRE, தமிழ்நாடு";
    }
    if (phone.isEmpty) {
      phone = aPhone.isNotEmpty ? aPhone : "9600666225";
    }
    if (place.isEmpty) place = "சென்னை";
    
    final dateStr = birthDt != null ? DateFormat('dd . MM . yyyy').format(birthDt) : "-";
    final dasaList = results['dasa'] as List? ?? [];
    
    // Astrological details extraction
    final moonDetails = details['moon'] ?? details['Moon'] ?? {};
    final lagnaDetails = details['lagna'] ?? details['Lagna'] ?? {};
    final nakshatraStr = _normalizeTamil(moonDetails['nakshatra']?.toString() ?? pan['nakshatra']?.toString() ?? "-");
    final padaStr = moonDetails['pada']?.toString() ?? "-";
    final weekdayRaw = pan['vara']?.toString() ?? (birthDt != null ? KPService.VARA_TAMIL[birthDt.weekday % 7] : "-");
    final weekdayStr = _normalizeTamil(weekdayRaw);
    final thithiRaw = pan['tithi']?.toString() ?? "-";
    final pakshamStr = pan['paksham']?.toString() ?? "";
    String cleanThithi = thithiRaw;
    if (cleanThithi.contains("(") && cleanThithi.contains(")")) {
      // already has paksham inside parentheses, don't duplicate
    } else if (pakshamStr.isNotEmpty && !cleanThithi.contains(pakshamStr)) {
      cleanThithi = "$cleanThithi ($pakshamStr)";
    }
    final yogaStr = _normalizeTamil(pan['yoga']?.toString() ?? pan['nithya_yoga']?.toString() ?? "-");
    final karanaStr = _normalizeTamil(pan['karana']?.toString() ?? "-");
    final rasiStr = KPService.TAMIL_SIGNS[moonDetails['lords']?['sign']] ?? KPService.TAMIL_SIGNS[moonDetails['rasi']] ?? moonDetails['rasi'] ?? pan['rasi'] ?? "-";
    final lagnaSignStr = KPService.TAMIL_SIGNS[lagnaDetails['lords']?['sign']] ?? KPService.TAMIL_SIGNS[lagnaDetails['rasi']] ?? lagnaDetails['rasi'] ?? "-";
    final double? lagnaLon = double.tryParse(lagnaDetails['longitude']?.toString() ?? "");
    final lagnaDegStr = lagnaLon != null ? KPService.formatAbsoluteDegrees(lagnaLon % 30) : "";

    final sunriseStr = pan['sunrise']?.toString() ?? "06:00:00 AM";
    final sunsetStr = pan['sunset']?.toString() ?? "06:00:00 PM";
    final tamilYear = pan['tamil_year']?.toString() ?? "-";
    final tamilMonth = pan['tamil_month']?.toString() ?? "-";
    final tamilDate = pan['tamil_date']?.toString() ?? "-";

    // Special Calculations: Yogi / Avayogi / Suniya / Badhaka / Marana
    final specialCalc = results['yogi_avayogi'] as Map? ?? {};
    final yogiData = specialCalc['yogi'] as Map? ?? {};
    final avayogiData = specialCalc['avayogi'] as Map? ?? {};
    
    String yogiPlanet = yogiData['planet_tamil']?.toString() ?? yogiData['planet']?.toString() ?? "-";
    String avayogiPlanet = avayogiData['planet_tamil']?.toString() ?? avayogiData['planet']?.toString() ?? "-";
    String yogiNak = yogiData['nakshatra_tamil']?.toString() ?? yogiData['nakshatra']?.toString() ?? "";
    String avayogiNak = avayogiData['nakshatra_tamil']?.toString() ?? avayogiData['nakshatra']?.toString() ?? "";

    final suniyaRasi = pan['suniya_rasi']?.toString() ?? "-";
    final suniyaNak = pan['suniya_nakshatra']?.toString() ?? "-";

    // Suniya Lord (திதி சூன்ய கிரகம்)
    String suniyaLord = "-";
    if (suniyaRasi != "-") {
      final firstRasi = suniyaRasi.split(',').first.trim();
      final rIdx = KPService.TAMIL_SIGNS.values.toList().indexOf(firstRasi);
      if (rIdx != -1) {
        final lordName = KPService.SIGN_LORDS[rIdx % 12];
        suniyaLord = KPService.TAMIL_PLANETS[lordName] ?? lordName;
      }
    }

    // Planetary roles: Badhaka / Marana / Kudumba / Ashtama
    final roles = results['planetary_roles'] as Map? ?? {};
    final badhakaData = roles['badhaka'] as Map? ?? {};
    String badhakaLord = badhakaData['lord_tamil']?.toString() ?? badhakaData['lord']?.toString() ?? "-";
    
    // Lowest degree (குறைந்த பாகை கிரகம்) & Highest degree (அதிக பாகை கிரகம்)
    final List<String> pList7 = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    String minDegPlanet = "-";
    String maxDegPlanet = "-";
    double minDeg = 999.0;
    double maxDeg = -1.0;

    for (var pKey in pList7) {
      final p = details[pKey.toLowerCase()] ?? details[pKey] ?? {};
      double? lon = double.tryParse(p['longitude']?.toString() ?? "");
      if (lon != null) {
        double degInSign = lon % 30;
        if (degInSign < minDeg) {
          minDeg = degInSign;
          String pName = KPService.TAMIL_PLANETS[pKey] ?? _toLocal(pKey, langCode);
          minDegPlanet = "$pName (${KPService.formatAbsoluteDegrees(degInSign)})";
        }
        if (degInSign > maxDeg) {
          maxDeg = degInSign;
          String pName = KPService.TAMIL_PLANETS[pKey] ?? _toLocal(pKey, langCode);
          maxDegPlanet = "$pName (${KPService.formatAbsoluteDegrees(degInSign)})";
        }
      }
    }

    // 1. Planetary Table Rows (11 rows)
    final List<String> pOrder = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu', 'Lagna', 'Maanthi'];
    String pTableHtml = "";
    for (var pKey in pOrder) {
      final p = details[pKey.toLowerCase()] ?? details[pKey] ?? {};
      double? lon = double.tryParse(p['longitude']?.toString() ?? "");
      String pDegStr = lon != null ? KPService.formatAbsoluteDegrees(lon % 30) : "-";
      String nakStr = p['nakshatra']?.toString() ?? "-";
      nakStr = _normalizeTamil(nakStr);
      String pada = p['pada']?.toString() ?? "";
      if (pada.isNotEmpty) nakStr = "$nakStr ($pada)";

      String pLocal = _toLocal(pKey, langCode);
      pTableHtml += """
      <tr>
        <td style="font-weight: bold; color: #1E3A8A; background: #F8FAFC;">$pLocal</td>
        <td style="color: #B45309; font-weight: bold;">$pDegStr</td>
        <td style="color: #047857;">$nakStr</td>
      </tr>
      """;
    }

    // 2. Dasa Periods Table Rows (Dasa Balance + 9 Mahadasas)
    String dasaTableHtml = "";
    if (dasaList.isNotEmpty) {
      final firstDasa = dasaList[0];
      int years = firstDasa['balance_y'] ?? 0;
      int months = firstDasa['balance_m'] ?? 0;
      int days = firstDasa['balance_d'] ?? 0;
      String lordLocal = KPService.TAMIL_PLANETS[firstDasa['lord']] ?? firstDasa['lord'] ?? "-";
      String balanceStr = "$lordLocal ($years வ, $months ம, $days நா)";
      
      final firstEnd = firstDasa['end'] as DateTime?;
      String firstEndStr = firstEnd != null ? DateFormat('dd/MM/yyyy').format(firstEnd) : "-";
      int ageAtFirstEnd = birthDt != null && firstEnd != null ? firstEnd.year - birthDt.year : years;

      dasaTableHtml += """
      <tr style="background: #FEF3C7; font-weight: bold;">
        <td style="color: #B45309;">இரு: $balanceStr</td>
        <td style="color: #DC2626;">$firstEndStr</td>
        <td style="color: #1E3A8A;">$ageAtFirstEnd வ</td>
      </tr>
      """;

      // Next 9 Mahadasas
      for (int i = 0; i < dasaList.length && i < 9; i++) {
        final d = dasaList[i];
        String dLord = KPService.TAMIL_PLANETS[d['lord']] ?? d['lord'] ?? "-";
        final end = d['end'] as DateTime?;
        String endStr = end != null ? DateFormat('dd/MM/yyyy').format(end) : "-";
        int ageAtEnd = birthDt != null && end != null ? end.year - birthDt.year : 0;
        
        dasaTableHtml += """
        <tr>
          <td style="font-weight: bold; color: #1E3A8A;">$dLord தசா</td>
          <td style="color: #DC2626;">$endStr</td>
          <td style="color: #047857; font-weight: bold;">$ageAtEnd வ</td>
        </tr>
        """;
      }
    }

    // 3. Rasi & Navamsa Charts
    final rasiChartHtml = _buildChartHtml("ராசி", _getSafeChartMap(results, 'rasi', langCode), true);
    final navamsaChartHtml = _buildChartHtml("நவாம்சம்", _getSafeChartMap(results, 'navamsa', langCode), false);

    return """
    <!DOCTYPE html>
    <html lang="ta">
    <head>
      <meta charset="utf-8"/>
      <meta name="viewport" content="width=794, initial-scale=1.0, maximum-scale=1.0"/>
      <title>Horoscope - $name</title>
      <style>
        :root {
          --primary-blue: #1E3A8A;
          --secondary-blue: #2563EB;
          --accent-red: #DC2626;
          --accent-green: #059669;
          --accent-gold: #D97706;
          --bg-light: #F8FAFC;
          --border-color: #CBD5E1;
        }
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; width: 794px; }
        body {
          font-family: 'Noto Sans Tamil', 'Latha', 'Mukta Vaani', sans-serif, -apple-system;
          color: #1E293B;
          font-size: 11px;
          -webkit-print-color-adjust: exact !important;
          print-color-adjust: exact !important;
          background: white;
        }
        .page {
          background: white;
          width: 794px;
          min-height: 1123px;
          padding: 12px 16px;
          position: relative;
          overflow: hidden;
        }
        .inner-page {
          border: 2.5px solid #1E3A8A;
          outline: 1.5px solid #D97706;
          outline-offset: -4px;
          border-radius: 8px;
          padding: 12px 14px;
          min-height: 1090px;
          overflow: hidden;
          background: #FFFFFF;
          box-shadow: 0 4px 14px rgba(30, 58, 138, 0.08);
        }
        @media screen {
          body { background: #f1f5f9; display: flex; flex-direction: column; align-items: center; }
          .print-btn {
            position: fixed;
            top: 20px;
            right: 20px;
            background: linear-gradient(135deg, #1E3A8A, #2563EB);
            color: white;
            border: none;
            padding: 10px 22px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            font-size: 13px;
            z-index: 1000;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
          }
          .print-btn:hover { background: #1E3A8A; }
        }
        @media print {
          @page { size: A4; margin: 0; }
          html, body { width: 100%; }
          body { background: white; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
          .page { width: 100%; padding: 12px 16px; box-shadow: none; margin: 0; height: 297mm; }
          .inner-page { border: 2.5px solid #1E3A8A; outline: 1.5px solid #D97706; outline-offset: -4px; height: 100%; }
          .no-print { display: none !important; }
        }

        /* HEADER */
        .header {
          border-bottom: 2px solid #2563EB;
          padding-bottom: 6px;
          margin-bottom: 6px;
        }
        .header-top {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }
        .header-title {
          color: #1E3A8A;
          font-weight: 900;
          font-size: 19px;
          line-height: 1.2;
          letter-spacing: 0.5px;
        }
        .header-sub {
          font-size: 10.5px;
          color: #475569;
          margin-top: 3px;
          line-height: 1.3;
        }
        .banner {
          background: linear-gradient(90deg, #1E3A8A 0%, #2563EB 30%, #059669 70%, #1E3A8A 100%);
          color: #FEF08A;
          text-align: center;
          padding: 5px 6px;
          font-weight: 800;
          font-size: 11.5px;
          margin: 5px 0 7px 0;
          border-radius: 4px;
          letter-spacing: 0.8px;
          box-shadow: 0 2px 4px rgba(30, 58, 138, 0.15);
        }
        .sub-header-title {
          text-align: center;
          font-size: 14.5px;
          font-weight: 900;
          color: #DC2626;
          background: linear-gradient(90deg, #FEF2F2, #FEE2E2, #FEF2F2);
          border: 1.5px solid #F87171;
          border-radius: 5px;
          padding: 4px 0;
          margin-bottom: 8px;
          letter-spacing: 1.5px;
          box-shadow: 0 1px 3px rgba(220, 38, 38, 0.1);
        }

        /* 2-COLUMN DETAILS */
        .details-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 14px;
          margin-bottom: 9px;
          background: #F8FAFC;
          border: 1.5px solid #BFDBFE;
          border-radius: 6px;
          padding: 7px 12px;
        }
        .detail-row {
          display: flex;
          align-items: center;
          margin-bottom: 3.8px;
          font-size: 10.5px;
          line-height: 1.32;
          overflow: hidden;
        }
        .detail-label {
          width: 142px;
          min-width: 142px;
          color: #1E3A8A;
          font-weight: bold;
          white-space: nowrap;
        }
        .detail-val {
          color: #0F172A;
          font-weight: 600;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          flex: 1;
        }
        .highlight-red { color: #DC2626; font-weight: bold; }
        .highlight-blue { color: #2563EB; font-weight: bold; }
        .highlight-green { color: #059669; font-weight: bold; }
        .highlight-gold { color: #D97706; font-weight: bold; }

        /* TABLES SECTION */
        .tables-row {
          display: grid;
          grid-template-columns: 1.05fr 1fr;
          gap: 12px;
          margin-bottom: 9px;
        }
        .astro-table {
          width: 100%;
          border-collapse: collapse;
          border: 1.5px solid #93C5FD;
          font-size: 10px;
          table-layout: fixed;
          background: white;
          border-radius: 4px;
          overflow: hidden;
        }
        .astro-table th {
          background: linear-gradient(135deg, #1E3A8A, #3B82F6);
          color: white;
          padding: 4.5px 2px;
          border: 1px solid #93C5FD;
          font-size: 10.5px;
          font-weight: bold;
          text-align: center;
        }
        .astro-table.dasa-th {
          border: 1.5px solid #A7F3D0;
        }
        .astro-table.dasa-th th {
          background: linear-gradient(135deg, #065F46, #059669, #10B981);
          border: 1px solid #A7F3D0;
        }
        .astro-table td {
          border: 0.8px solid #E2E8F0;
          padding: 3px 3px;
          text-align: center;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        /* CHARTS SECTION */
        .charts-row {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 14px;
          margin-top: 6px;
        }
        .chart-box-wrapper {
          border-radius: 6px;
          padding: 3px;
          background: #FFFFFF;
        }
        .grid-chart {
          width: 100%;
          border-collapse: collapse;
          table-layout: fixed;
          background: white;
        }
        .grid-chart td {
          height: 60px;
          text-align: center;
          font-size: 9.5px;
          font-weight: bold;
          padding: 1px;
          vertical-align: middle;
          background: #FFFFFF;
          overflow: hidden;
          word-break: break-all;
        }
        .grid-chart-rasi {
          border: 2px solid #2563EB;
        }
        .grid-chart-rasi td {
          border: 1px solid #BFDBFE;
        }
        .grid-chart-rasi .chart-center-cell {
          text-align: center;
          vertical-align: middle;
          background: linear-gradient(135deg, #EFF6FF, #DBEAFE) !important;
          border: 1.5px solid #2563EB !important;
        }
        .grid-chart-rasi .chart-center-title {
          color: #1E3A8A;
          font-size: 15px;
          font-weight: 900;
          letter-spacing: 0.5px;
        }
        .grid-chart-navamsa {
          border: 2px solid #059669;
        }
        .grid-chart-navamsa td {
          border: 1px solid #A7F3D0;
        }
        .grid-chart-navamsa .chart-center-cell {
          text-align: center;
          vertical-align: middle;
          background: linear-gradient(135deg, #ECFDF5, #D1FAE5) !important;
          border: 1.5px solid #059669 !important;
        }
        .grid-chart-navamsa .chart-center-title {
          color: #065F46;
          font-size: 15px;
          font-weight: 900;
          letter-spacing: 0.5px;
        }
        .cell-item {
          font-size: 9px;
          line-height: 1.22;
          margin: 1px 0;
          font-weight: 600;
        }
        .cell-lagna {
          color: #FFFFFF !important;
          background: #DC2626 !important;
          border-radius: 3px;
          padding: 1.5px 4.5px;
          font-weight: 900;
          display: inline-block;
          box-shadow: 0 1px 2px rgba(220, 38, 38, 0.3);
        }
      </style>
    </head>
    <body>
      <button class="print-btn no-print" onclick="window.print()">🖨️ பிரிண்ட் / PDF சேமிக்க</button>
      <div class="page">
        <div class="inner-page">
          <!-- HEADER -->
          <div class="header">
            <div class="header-top">
              <!-- Left Side: GB Astro Logo -->
              <div style="flex: 0 0 auto; text-align: left; margin-right: 12px;">
                ${gbLogoBase64.isNotEmpty ? '<img src="data:image/png;base64,$gbLogoBase64" style="height: 64px; width: 64px; object-fit: contain; border-radius: 50%; border: 1.5px solid #2563EB;" alt="GB Astro Logo" />' : ''}
              </div>

              <!-- Center: Center Name, Address & Phone from Settings -->
              <div style="flex: 1; text-align: center; min-width: 0;">
                <div class="header-title">${shopName}</div>
                <div class="header-sub">${astroName.isNotEmpty ? '$astroName | ' : ''}$address</div>
                <div style="color: #DC2626; font-size: 10.5px; font-weight: bold; margin-top: 3px;">📞 $phone</div>
              </div>

              <!-- Right Side: Ganapathy Image -->
              <div style="flex: 0 0 auto; text-align: right; margin-left: 12px;">
                ${ganapathyBase64.isNotEmpty ? '<img src="data:image/png;base64,$ganapathyBase64" style="height: 64px; width: 64px; object-fit: contain; border-radius: 50%; border: 1.5px solid #D97706;" alt="Ganapathy" />' : ''}
              </div>
            </div>
          </div>

          <!-- BANNER & SUBHEADER -->
          <div class="banner">✦ SOFTWARE DEVELOPED BY GBASTRO SUITE / MO. NO - 9787067950 / 9600666225 ✦</div>
          <div class="sub-header-title">✦ திருக்கணிதம் ✦</div>

          <!-- 2-COLUMN DETAILS -->
          <div class="details-grid">
            <!-- LEFT COLUMN (11 Fields) -->
            <div>
              <div class="detail-row"><span class="detail-label">ஜாதகர் பெயர் :</span> <span class="detail-val highlight-red">$name</span></div>
              <div class="detail-row"><span class="detail-label">பிறந்த தேதி :</span> <span class="detail-val highlight-blue">$dateStr</span></div>
              <div class="detail-row"><span class="detail-label">பிறந்த நேரம் :</span> <span class="detail-val">$birthTime</span></div>
              <div class="detail-row"><span class="detail-label">பிறந்த ஊர் :</span> <span class="detail-val">$place</span></div>
              <div class="detail-row"><span class="detail-label">சூரிய உதயம் :</span> <span class="detail-val highlight-gold">$sunriseStr</span></div>
              <div class="detail-row"><span class="detail-label">சூரிய அஸ்தமனம் :</span> <span class="detail-val">$sunsetStr</span></div>
              <div class="detail-row"><span class="detail-label">பாலினம் :</span> <span class="detail-val">${(gender.toLowerCase().contains('male') || gender == 'ஆண்') ? 'ஆண்' : 'பெண்'}</span></div>
              <div class="detail-row"><span class="detail-label">தமிழ் தேதி :</span> <span class="detail-val">$tamilYear, $tamilMonth - $tamilDate</span></div>
              <div class="detail-row"><span class="detail-label">ஜென்ம நட்சத்திரம் :</span> <span class="detail-val highlight-green">$nakshatraStr - $padaStr பாதம்</span></div>
              <div class="detail-row"><span class="detail-label">ஜென்ம ராசி :</span> <span class="detail-val highlight-blue">$rasiStr</span></div>
              <div class="detail-row"><span class="detail-label">ஜென்ம லக்னம் :</span> <span class="detail-val highlight-red">$lagnaSignStr $lagnaDegStr</span></div>
            </div>

            <!-- RIGHT COLUMN (11 Fields) -->
            <div>
              <div class="detail-row"><span class="detail-label">கிழமை :</span> <span class="detail-val">$weekdayStr</span></div>
              <div class="detail-row"><span class="detail-label">திதி :</span> <span class="detail-val">$cleanThithi</span></div>
              <div class="detail-row"><span class="detail-label">யோகம் :</span> <span class="detail-val">$yogaStr</span></div>
              <div class="detail-row"><span class="detail-label">கரணம் :</span> <span class="detail-val">$karanaStr</span></div>
              <div class="detail-row"><span class="detail-label">யோகி / அவயோகி :</span> <span class="detail-val highlight-green">$yogiPlanet / <span class="highlight-red">$avayogiPlanet</span></span></div>
              <div class="detail-row"><span class="detail-label">தி. ராசி / நட் :</span> <span class="detail-val highlight-gold">$suniyaRasi / $suniyaNak</span></div>
              <div class="detail-row"><span class="detail-label">திதி சூன்ய கிரகம் :</span> <span class="detail-val highlight-red">$suniyaLord</span></div>
              <div class="detail-row"><span class="detail-label">அவயோகி கிரகம் :</span> <span class="detail-val highlight-red">$avayogiPlanet ${avayogiNak.isNotEmpty ? '($avayogiNak)' : ''}</span></div>
              <div class="detail-row"><span class="detail-label">கு. பா. கிரகம் :</span> <span class="detail-val highlight-blue">$minDegPlanet</span></div>
              <div class="detail-row"><span class="detail-label">அ. பா. கிரகம் :</span> <span class="detail-val highlight-red">$maxDegPlanet</span></div>
              <div class="detail-row"><span class="detail-label">வயது :</span> <span class="detail-val highlight-green">$age</span></div>
            </div>
          </div>

          <!-- TABLES ROW -->
          <div class="tables-row">
            <!-- LEFT TABLE: PLANETARY POSITIONS -->
            <div>
              <table class="astro-table">
                <thead>
                  <tr>
                    <th style="width: 25%;">கிரகம்</th>
                    <th style="width: 37%;">பாகை / கலை</th>
                    <th style="width: 38%;">நட்சத்திரம் (பாதம்)</th>
                  </tr>
                </thead>
                <tbody>
                  $pTableHtml
                </tbody>
              </table>
            </div>

            <!-- RIGHT TABLE: DASA BALANCE & MAHADASAS -->
            <div>
              <table class="astro-table dasa-th">
                <thead>
                  <tr>
                    <th style="width: 48%;">தசா இருப்பு</th>
                    <th style="width: 32%;">முடிவு தேதி</th>
                    <th style="width: 20%;">வருடம்</th>
                  </tr>
                </thead>
                <tbody>
                  $dasaTableHtml
                </tbody>
              </table>
            </div>
          </div>

          <!-- CHARTS ROW -->
          <div class="charts-row">
            <div class="chart-box-wrapper">
              $rasiChartHtml
            </div>
            <div class="chart-box-wrapper">
              $navamsaChartHtml
            </div>
          </div>

        </div>
      </div>
    </body>
    </html>
    """;
  }

  static String _buildChartHtml(String title, Map<int, List<String>> rasiMap, bool isRasiChart) {
    String chartClass = isRasiChart ? "grid-chart grid-chart-rasi" : "grid-chart grid-chart-navamsa";
    String cell(int? idx) {
      if (idx == null) return "";
      final list = rasiMap[idx] ?? [];
      return list.map((p) {
        bool isLagna = p.startsWith("லக்") || p.startsWith("உத") || p.startsWith("Asc") || p.startsWith("Lagna");
        bool isMoon = p.startsWith("சந்") || p.startsWith("Moon");
        bool isRetro = p.contains("(வ)") || p.contains("(R)");
        if (isLagna) {
          return "<div class='cell-item cell-lagna'>$p</div>";
        }
        String colorStyle = isMoon 
            ? "color: #2563EB; font-weight: 800;" 
            : (isRetro 
                ? "color: #DC2626; font-weight: 800;" 
                : (isRasiChart ? "color: #1E3A8A; font-weight: 700;" : "color: #065F46; font-weight: 700;"));
        return "<div class='cell-item' style='$colorStyle'>$p</div>";
      }).join("");
    }

    return """
    <table class="$chartClass">
      <tr>
        <td>${cell(12)}</td>
        <td>${cell(1)}</td>
        <td>${cell(2)}</td>
        <td>${cell(3)}</td>
      </tr>
      <tr>
        <td>${cell(11)}</td>
        <td colspan="2" rowspan="2" class="chart-center-cell">
          <div class="chart-center-title">$title</div>
        </td>
        <td>${cell(4)}</td>
      </tr>
      <tr>
        <td>${cell(10)}</td>
        <td>${cell(5)}</td>
      </tr>
      <tr>
        <td>${cell(9)}</td>
        <td>${cell(8)}</td>
        <td>${cell(7)}</td>
        <td>${cell(6)}</td>
      </tr>
    </table>
    """;
  }

  static double _extractDegree(String item) {
    final reg = RegExp(r'(\d+)[°:](\d+)?');
    final match = reg.firstMatch(item);
    if (match != null) {
      double deg = double.tryParse(match.group(1) ?? "0") ?? 0.0;
      double min = double.tryParse(match.group(2) ?? "0") ?? 0.0;
      return deg + (min / 60.0);
    }
    return 0.0;
  }

  static Map<int, List<String>> _getSafeChartMap(Map results, String key, String langCode) {
    final Map<int, List<String>> rasiMap = {};
    if (results.containsKey(key) && results[key] is Map) {
      final Map raw = results[key];
      raw.forEach((s, pList) {
        int idx = _getSignIdx(s.toString());
        if (idx != -1) {
          final List<String> planets = pList is List ? pList.map((e) => e.toString()).toList() : [pList.toString()];
          final List<String> cleanPlanets = [];
          for (var p in planets) {
            final trimmed = p.trim();
            if (trimmed.isEmpty) continue;
            final firstWord = trimmed.split(' ').first;
            const romanNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'];
            if (romanNumerals.contains(firstWord)) continue;
            
            final localizedName = _toLocal(firstWord, langCode);
            if (localizedName.isNotEmpty) {
              cleanPlanets.add(trimmed.replaceFirst(firstWord, localizedName));
            } else {
              cleanPlanets.add(trimmed);
            }
          }

          // Degree-based sorting:
          // 1..8 (Aries..Scorpio): column (0 deg top to 30 deg bottom) -> ascending
          // 9..12 (Sagittarius..Pisces): column-reverse (0 deg bottom to 30 deg top) -> descending
          if (idx >= 9 && idx <= 12) {
            cleanPlanets.sort((a, b) => _extractDegree(b).compareTo(_extractDegree(a)));
          } else {
            cleanPlanets.sort((a, b) => _extractDegree(a).compareTo(_extractDegree(b)));
          }

          rasiMap[idx] = cleanPlanets;
        }
      });
    }
    return rasiMap;
  }

  static int _getSignIdx(String sign) {
    final s = sign.toLowerCase().trim();
    if (s.contains('ari') || s.contains('மேஷ') || s.contains('मेष')) return 1;
    if (s.contains('tau') || s.contains('ரிஷ') || s.contains('वृष')) return 2;
    if (s.contains('gem') || s.contains('மிது') || s.contains('मिथ')) return 3;
    if (s.contains('can') || s.contains('கட') || s.contains('कर्क')) return 4;
    if (s.contains('leo') || s.contains('சிம்') || s.contains('सिंह')) return 5;
    if (s.contains('vir') || s.contains('கன்') || s.contains('कन')) return 6;
    if (s.contains('lib') || s.contains('துலா') || s.contains('तुला')) return 7;
    if (s.contains('sco') || s.contains('விரு') || s.contains('वृश्चि')) return 8;
    if (s.contains('sag') || s.contains('தனு') || s.contains('धनु')) return 9;
    if (s.contains('cap') || s.contains('மக') || s.contains('मकर')) return 10;
    if (s.contains('aqu') || s.contains('கும்') || s.contains('कुंभ')) return 11;
    if (s.contains('pis') || s.contains('மீன') || s.contains('मीन')) return 12;
    return -1;
  }
}

typedef GpOnePagePdfService = GbOnePagePdfService;
typedef AbOnePagePdfService = GbOnePagePdfService;
