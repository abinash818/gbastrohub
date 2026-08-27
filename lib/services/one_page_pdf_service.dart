import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'kp_service.dart';
import 'settings_service.dart';
import 'pdf_helper_stub.dart' if (dart.library.html) 'pdf_helper_web.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class OnePagePdfService {
  static const List<String> _validPlanets = [
    'lagna', 'asc', 'sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu', 'mandi', 'maanthi', 'gulika'
  ];

  static String _toLocal(String p, String langCode) {
    final key = p.toLowerCase().trim();
    final Map<String, String> shortMap = langCode == 'en' ? KPService.ENGLISH_PLANET_SHORT : (langCode == 'hi' ? KPService.HINDI_PLANET_SHORT : KPService.TAMIL_PLANET_SHORT);
    final Map<String, String> fullMap = langCode == 'en' ? KPService.ENGLISH_PLANETS : (langCode == 'hi' ? KPService.HINDI_PLANETS : KPService.TAMIL_PLANETS);
    
    if (shortMap.containsKey(key)) return shortMap[key]!;
    if (shortMap.values.contains(p)) return p;
    for (var entry in fullMap.entries) {
      if (entry.value == p || entry.key == p) {
        return shortMap[entry.key] ?? shortMap[entry.key.toLowerCase()] ?? p;
      }
    }
    if (key.startsWith('t_')) {
      final subKey = key.substring(2);
      if (shortMap.containsKey(subKey)) return shortMap[subKey]!;
    }
    return p;
  }

  static String _getLocalSign(String sign, String langCode) {
    final Map<String, String> signMap = langCode == 'en' ? KPService.ENGLISH_SIGNS : (langCode == 'hi' ? KPService.HINDI_SIGNS : KPService.TAMIL_SIGNS);
    return signMap[sign] ?? sign;
  }

  static Future<void> showHtmlReport({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    required AppLocalizations l10n,
  }) async {
    if (!kIsWeb) return;
    final transitResults = await _getLiveTransit(results);
    final astro = await SettingsService.getAstrologerDetails();
    
    String muruganBase64 = "";
    String ganapathyBase64 = "";
    try {
      final byteData = await rootBundle.load('assets/images/muruga.png');
      muruganBase64 = base64Encode(byteData.buffer.asUint8List());
      final byteDataG = await rootBundle.load('assets/images/ganapathy.png');
      ganapathyBase64 = base64Encode(byteDataG.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error loading images: $e");
    }

    final htmlContent = _buildFullHtml(name, gender, results, transitResults, astro, muruganBase64, ganapathyBase64, l10n);
    printHtmlWeb(htmlContent);
  }

  static Future<Uint8List> generate({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    required AppLocalizations l10n,
  }) async {
    final transitResults = await _getLiveTransit(results);
    final astro = await SettingsService.getAstrologerDetails();
    
    String muruganBase64 = "";
    String ganapathyBase64 = "";
    try {
      final byteData = await rootBundle.load('assets/images/muruga.png');
      muruganBase64 = base64Encode(byteData.buffer.asUint8List());
      final byteDataG = await rootBundle.load('assets/images/ganapathy.png');
      ganapathyBase64 = base64Encode(byteDataG.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error loading images: $e");
    }

    if (kIsWeb) return _generateDirectPdf(name, gender, results, transitResults, astro);
    try {
      final htmlContent = _buildFullHtml(name, gender, results, transitResults, astro, muruganBase64, ganapathyBase64, l10n);
      final Directory tempDir = await getTemporaryDirectory();
      final File pdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(htmlContent, tempDir.path, "horoscope_${DateTime.now().millisecondsSinceEpoch}");
      final Uint8List bytes = await pdfFile.readAsBytes();
      await pdfFile.delete();
      return bytes;
    } catch (e) {
      return _generateDirectPdf(name, gender, results, transitResults, astro);
    }
  }

  static Future<Map<String, dynamic>?> _getLiveTransit(Map results) async {
    try {
      double? lat, lon, tz;
      void findLoc(dynamic data) {
        if (data is Map) {
          data.forEach((k, v) {
            final kStr = k.toString().toLowerCase();
            if (kStr == 'lat' || kStr == 'latitude') lat ??= double.tryParse(v.toString());
            if (kStr == 'lon' || kStr == 'longitude') lon ??= double.tryParse(v.toString());
            if (kStr == 'timezone' || kStr == 'tz') tz ??= double.tryParse(v.toString());
            if (lat == null || lon == null) findLoc(v);
          });
        } else if (data is List) {
          for (var item in data) if (lat == null || lon == null) findLoc(item);
        }
      }
      findLoc(results);
      lat ??= 13.0827; lon ??= 80.2707; tz ??= 5.5;
      return await KPService.calculateChart("Transit", DateTime.now(), lat!, lon!, tz!);
    } catch (e) {
      debugPrint("Transit Calc Error: $e");
    }
    return null;
  }

  static Future<Uint8List> _generateDirectPdf(String name, String gender, Map results, Map? transit, Map<String, String> astro) async {
    final pdf = pw.Document();
    return pdf.save();
  }

  static String _buildFullHtml(String name, String gender, Map results, Map? transitResults, Map<String, String> astro, String muruganBase64, String ganapathyBase64, AppLocalizations l10n) {
    final String langCode = l10n.localeName;
    final details = results['planet_details'] as Map? ?? {};
    final pan = results['panchangam'] as Map? ?? {};
    final birthDt = results['birth_dt'] as DateTime?;
    
    // Recursive search variables
    String age = pan['age_display']?.toString() ?? pan['age']?.toString() ?? "";
    String birthTime = pan['birth_time']?.toString() ?? pan['time']?.toString() ?? pan['tob']?.toString() ?? "";
    String shopName = ""; String astroName = ""; String address = ""; String phone = "";
    
    // Single robust recursive search function
    void findDeep(dynamic data) {
      if (data is Map) {
        data.forEach((k, v) {
          final kStr = k.toString().toLowerCase();
          if (age.isEmpty && (kStr == 'age' || kStr == 'age_display')) age = v.toString();
          if (birthTime.isEmpty && (kStr == 'birth_time' || kStr == 'time' || kStr == 'tob')) birthTime = v.toString();
          
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
    
    // Manual Age Calculation if still empty
    if (age.isEmpty && birthDt != null) {
      final now = DateTime.now();
      int years = now.year - birthDt.year;
      int months = now.month - birthDt.month;
      int days = now.day - birthDt.day;
      if (days < 0) { months -= 1; days += 30; }
      if (months < 0) { years -= 1; months += 12; }
      age = "$years வயது, $months மாதம், $days நாள்";
    }

    // Fallbacks if not found in data
    if (shopName.isEmpty) shopName = astro['name'] ?? "ஜிபி அஸ்ட்ரோ ஜோதிட வித்யாலயம்";
    if (astroName.isEmpty) astroName = astro['name'] != null ? "" : "Dr. Karunagaran";
    if (address.isEmpty) address = astro['address'] ?? "ஜிபி அஸ்ட்ரோ ஜோதிட வித்தியாலயம், சென்னை";
    if (phone.isEmpty) phone = astro['phone'] ?? "Ph: 9600666225";
    
    final dateStr = birthDt != null ? DateFormat('dd . MM . yyyy').format(birthDt) : "-";
    final nowStr = DateFormat('dd/MM/yyyy  hh:mm:ss a').format(DateTime.now());
    final transitDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final dasaList = results['dasa'] as List? ?? [];
    
    // Astrological details extraction
    final moonDetails = details['moon'] ?? details['Moon'] ?? {};
    final nakshatraStr = moonDetails['nakshatra']?.toString() ?? pan['nakshatra']?.toString() ?? "-";
    final padaStr = moonDetails['pada']?.toString() ?? "-";
    final weekdayStr = pan['vara']?.toString() ?? (birthDt != null ? KPService.VARA_TAMIL[birthDt.weekday % 7] : "-");
    
    String dasaBalance = "-";
    if (dasaList.isNotEmpty && birthDt != null) {
      final firstDasa = dasaList[0];
      final end = firstDasa['end'] as DateTime?;
      if (end != null) {
        final diff = end.difference(birthDt);
        int totalDays = diff.inDays;
        int years = (totalDays / 365.25).floor();
        totalDays = (totalDays % 365.25).floor();
        int months = (totalDays / 30.44).floor();
        int days = (totalDays % 30.44).floor();
        final String lordLocal = langCode == 'en' 
            ? (KPService.ENGLISH_PLANETS[firstDasa['lord']] ?? firstDasa['lord'] ?? "-") 
            : (langCode == 'hi' 
                ? (KPService.HINDI_PLANETS[firstDasa['lord']] ?? firstDasa['lord'] ?? "-") 
                : (KPService.TAMIL_PLANETS[firstDasa['lord']] ?? firstDasa['lord'] ?? "-"));
        final String yStr = langCode == 'en' ? 'y' : (langCode == 'hi' ? 'वर्ष' : 'வரு');
        final String mStr = langCode == 'en' ? 'm' : (langCode == 'hi' ? 'महीने' : 'மா');
        final String dStr = langCode == 'en' ? 'd' : (langCode == 'hi' ? 'दिन' : 'நா');
        dasaBalance = "$lordLocal - $years $yStr, $months $mStr, $days $dStr";
      }
    }
    
    final tamilYear = pan['tamil_year']?.toString() ?? "-";
    final tamilMonth = pan['tamil_month']?.toString() ?? "-";
    final tamilDate = pan['tamil_date']?.toString() ?? "-";
    final thithiStr = pan['tithi']?.toString() ?? "-";
    final pakshamStr = pan['paksham']?.toString() ?? "-";
    final rasiStr = KPService.TAMIL_SIGNS[moonDetails['lords']?['sign']] ?? KPService.TAMIL_SIGNS[moonDetails['rasi']] ?? moonDetails['rasi'] ?? pan['rasi'] ?? "-";
    final suniyaStr = pan['suniya_rasi']?.toString() ?? "-";

    final now = DateTime.now();
    
    Map? currentDasa; Map? currentBukthi; List bukthiList = []; List antharamList = [];
    for (var d in dasaList) {
      final start = d['start'] as DateTime?; final end = d['end'] as DateTime?;
      if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) {
        currentDasa = d; bukthiList = d['subPeriods'] as List? ?? []; break;
      }
    }
    if (bukthiList.isNotEmpty) {
      for (var b in bukthiList) {
        final start = b['start'] as DateTime?; final end = b['end'] as DateTime?;
        if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) {
          currentBukthi = b; antharamList = b['subPeriods'] as List? ?? []; break;
        }
      }
    }

    String strength = results['planets_strength']?.toString() ?? results['strength']?.toString() ?? results['balam']?.toString() ?? "-";

    return """
    <!DOCTYPE html>
    <html lang="ta">
    <head>
      <meta charset="utf-8"/>
      <meta name="viewport" content="width=794, initial-scale=1.0, maximum-scale=1.0"/>
      <title>Horoscope - $name</title>
      <style>
        :root { --border-orange: #E0D4BE; --header-blue: #5D1204; --text-red: #5D1204; --text-green: #B58D3D; }
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; width: 794px; }
        body { font-family: sans-serif; color: #333; font-size: 11px; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; background: white; }
        .page { background: white; width: 794px; min-height: 1123px; padding: 18px; position: relative; overflow: hidden; }
        .inner-page { border: 1.5px solid var(--text-red); padding: 14px; min-height: 1080px; overflow: hidden; }
        @media screen {
          body { background: #f3f4f6; display: flex; flex-direction: column; align-items: center; }
          .print-btn { position: fixed; top: 20px; right: 20px; background: var(--text-red); color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-weight: bold; font-size: 14px; z-index: 1000; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
          .print-btn:hover { background: #3E0A02; }
        }
        @media print {
          @page { size: A4; margin: 0; }
          html, body { width: 100%; }
          body { background: white; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
          .page { width: 100%; padding: 18px; box-shadow: none; margin: 0; height: 297mm; }
          .inner-page { border: 1.5px solid var(--text-red); padding: 14px; height: 100%; }
          .no-print { display: none !important; }
        }
        .header { border-bottom: 2px solid var(--text-red); margin-bottom: 8px; padding-bottom: 5px; }
        .header-top { display: flex; justify-content: space-between; }
        .header-title { color: var(--text-red); font-weight: bold; font-size: 18px; line-height: 1.2; word-break: break-word; }
        .header-sub { font-size: 10px; color: #555; line-height: 1.3; word-break: break-word; }
        .banner { background: var(--text-red); color: white; text-align: center; padding: 5px; font-weight: bold; font-size: 16px; margin: 5px 0; border-radius: 3px; overflow: hidden; }
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 10px; border-bottom: 1px solid #eee; padding-bottom: 3px; }
        .detail-row { display: flex; margin-bottom: 2px; overflow: hidden; }
        .detail-row span:last-child { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; }
        .detail-label { width: 105px; min-width: 105px; color: var(--text-red); font-weight: bold; }
        .charts-row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 10px; }
        .grid-chart { width: 100%; border-collapse: collapse; border: 1.8px solid var(--text-red); table-layout: fixed; }
        .grid-chart td { border: 1.2px solid var(--text-red); height: 50px; text-align: center; font-size: 10px; font-weight: bold; padding: 1px; vertical-align: middle; background: #FAF6EE; overflow: hidden; word-break: break-all; }
        .chart-title { color: var(--text-red); font-size: 12px; font-weight: bold; line-height: 1.1; }
        .chart-sub { font-size: 8px; font-weight: normal; line-height: 1; }
        .middle-row { display: grid; grid-template-columns: 200px 1fr; gap: 12px; margin-bottom: 10px; }
        .planetary-table { width: 100%; border-collapse: collapse; border: 1px solid var(--border-orange); font-size: 10px; table-layout: fixed; }
        .planetary-table th { background: var(--text-red); color: white; padding: 3px; border: 1px solid var(--border-orange); overflow: hidden; }
        .planetary-table td { border: 1px solid var(--border-orange); padding: 3px; text-align: center; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .ashta-table { width: 100%; border-collapse: collapse; border: 1.2px solid var(--border-orange); font-size: 10px; text-align: center; table-layout: fixed; }
        .ashta-table td { border: 1.2px solid var(--border-orange); padding: 4px; overflow: hidden; }
        .timeline-row { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; }
        .timeline-table { width: 100%; border-collapse: collapse; border: 1.2px solid var(--border-orange); font-size: 9px; text-align: center; table-layout: fixed; }
        .timeline-table th { background: #F4EFE3; color: var(--text-red); padding: 3px; border: 1.2px solid var(--border-orange); overflow: hidden; }
        .timeline-table td { border: 1.2px solid var(--border-orange); padding: 3px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .highlight-row { background: #FAF6EE; font-weight: bold; border: 1.5px solid var(--text-green); }
      </style>
    </head>
    <body>
      <button class="print-btn no-print" onclick="window.print()">Print A4 PDF</button>
      <div class="page">
        <div class="inner-page">
          <div class="header">
            <div class="header-top" style="display: flex; justify-content: space-between; align-items: center;">
              <!-- Left side: Ganapathy Image -->
              <div style="flex: 0 0 auto; text-align: left; margin-right: 15px;">
                 ${ganapathyBase64.isNotEmpty ? '<img src="data:image/png;base64,$ganapathyBase64" style="height: 72px; width: auto; object-fit: contain;" alt="Ganapathy" />' : ''}
              </div>
              
              <!-- Center: Astrologer Address -->
              <div style="flex: 1; text-align: center; min-width: 0;">
                <div class="header-title">${shopName}</div>
                <div class="header-sub" style="white-space: pre-line;">$astroName\n$address</div>
                <div style="color: var(--text-red); font-size: 10px; margin-top: 5px;">$phone | $nowStr</div>
              </div>

              <!-- Right side: Murugan Image -->
              <div style="flex: 0 0 auto; text-align: right; margin-left: 15px;">
                 ${muruganBase64.isNotEmpty ? '<img src="data:image/png;base64,$muruganBase64" style="height: 72px; width: 65px; object-fit: contain;" alt="Murugan" />' : ''}
              </div>
            </div>
          </div>
          <div class="banner">Software Developed by GB Astro | Mobile: +91 96006 66225 <span style="font-size: 12px; font-weight: normal; margin-left: 6px;"> </span></div>
          <div class="details-grid">
            <div>
              <div class="detail-row"><span class="detail-label">${l10n.nameLabel}</span>: <span style="color:var(--text-red)">$name</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.genderLabel}</span>: <span style="color:#333">${(gender.toLowerCase().contains('male') || gender == 'ஆண்' || gender == 'Male') ? l10n.male : l10n.female}</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.ageFormat(0,0,0).split(':')[0]}</span>: <span style="color:#333">$age</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.nakshatraLabel}</span>: <span style="color:#333">$nakshatraStr - $padaStr</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.rasiLabel}</span>: <span style="color:#333">$rasiStr</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.day}</span>: <span style="color:#333">$weekdayStr</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.dasa}</span>: <span style="color:var(--text-red)">$dasaBalance</span></div>
            </div>
            <div>
              <div class="detail-row"><span class="detail-label">${l10n.dateLabel}</span>: <span style="color:var(--text-red)">$dateStr</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.tamilDate}</span>: <span style="color:#333">$tamilYear, $tamilMonth - $tamilDate</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.tithiLabel}</span>: <span style="color:#333">$thithiStr</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.paksham}</span>: <span style="color:#333">$pakshamStr</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.timeLabel}</span>: <span style="color:#333">${birthTime.isEmpty ? '-' : birthTime}</span></div>
              <div class="detail-row"><span class="detail-label">${l10n.placeLabel}</span>: <span style="color:#333">${results['place'] ?? '-'}</span></div>
            </div>
          </div>
          <div class="charts-row">
            ${_buildChartHtml(l10n.rasiChart.split('(')[0].trim(), _getSafeChartMap(results, 'rasi', langCode), " ", langCode)}
            ${_buildChartHtml(langCode == 'en' ? "Navamsa" : (langCode == 'hi' ? "नवांश" : "நவாம்சம்"), _getSafeChartMap(results, 'navamsa', langCode), " ", langCode)}
            ${_buildChartHtml(l10n.bhavaChart.split('(')[0].trim(), _getSafeChartMap(results, 'pavagam', langCode), " ", langCode)}
          </div>
          <div class="middle-row">
            ${_buildChartHtml(langCode == 'en' ? "Transit" : (langCode == 'hi' ? "गोचर" : "கோட்சாரம்"), _getSafeChartMap(transitResults ?? results, 'transit_rasi', langCode), transitDate, langCode, true)}
            <div><div style="font-size: 10px; color: var(--text-red); font-weight: bold; margin-bottom: 2px;">$strength</div>${_buildPlanetTableHtml(details, l10n, langCode)}</div>
          </div>
          <div style="text-align: center; color: var(--text-red); font-weight: bold; font-size: 13px; margin: 8px 0 3px 0;">${l10n.sarvaAshtakavarga}</div>
          ${_buildAshtaTableHtml(results['ashtakavarga'], results, langCode)}
          <div class="timeline-row" style="margin-top: 10px;">
            ${_buildTimelineHtml(l10n.dasaTitle, dasaList, l10n.dasaTitle, currentDasa, l10n, langCode)}
            ${_buildTimelineHtml(l10n.bukthiTitle, bukthiList, l10n.bukthiTitle, currentBukthi, l10n, langCode)}
            ${_buildTimelineHtml(l10n.antharamTitle, antharamList, l10n.antharamTitle, null, l10n, langCode)}
          </div>
        </div>
      </div>
    
<div class="zoom-controls">
  <button onclick="zoomIn()" title="Zoom In">+</button>
  <button onclick="zoomOut()" title="Zoom Out">-</button>
  <button onclick="window.print()" title="Print/Save PDF">🖨</button>
</div>
<style>
  .zoom-controls { position: fixed; bottom: 20px; right: 20px; display: flex; flex-direction: column; gap: 10px; z-index: 1000; }
  .zoom-controls button { width: 45px; height: 45px; border-radius: 50%; border: none; background: #5D1204; color: white; font-size: 24px; cursor: pointer; box-shadow: 0 4px 6px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center; }
  .zoom-controls button:hover { background: #B58D3D; }
  @media print { .zoom-controls { display: none !important; } }
</style>
<script>
  let currentZoom = 1.0;
  function zoomIn() {
    currentZoom += 0.1;
    document.body.style.zoom = currentZoom;
  }
  function zoomOut() {
    currentZoom -= 0.1;
    if(currentZoom < 0.3) currentZoom = 0.3;
    document.body.style.zoom = currentZoom;
  }
</script>

</body>
    </html>
    """;
  }

  static String _buildChartHtml(String title, Map<int, List<String>> rasiMap, String subText, String langCode, [bool isRed = false]) {
    String cell(int? idx) {
      if (idx == null) return "";
      final list = rasiMap[idx] ?? [];
      return list.map((p) => "<div>$p</div>").join("");
    }
    final tColor = "var(--text-red)";
    return """
    <table class="grid-chart">
      <tr><td>${cell(12)}</td><td>${cell(1)}</td><td>${cell(2)}</td><td>${cell(3)}</td></tr>
      <tr><td>${cell(11)}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title" style="color: $tColor">$title</div><div class="chart-sub">$subText</div></td><td>${cell(4)}</td></tr>
      <tr><td>${cell(10)}</td><td>${cell(5)}</td></tr>
      <tr><td>${cell(9)}</td><td>${cell(8)}</td><td>${cell(7)}</td><td>${cell(6)}</td></tr>
    </table>
    """;
  }

  static String _buildPlanetTableHtml(Map details, AppLocalizations l10n, String langCode) {
    final List<String> order = ['Lagna', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu', 'Maanthi'];
    String rows = "";
    for (var pKey in order) {
      final p = details[pKey.toLowerCase()] ?? details[pKey] ?? {};
      double? lon = double.tryParse(p['longitude']?.toString() ?? "");
      String starLord = p['star_lord']?.toString() ?? p['starlord']?.toString() ?? "";
      if (starLord.isEmpty && lon != null) starLord = KPService.getKPLords(lon)['nakLord'] ?? "";
      String dignity = p['dignity']?.toString() ?? "";
      if (dignity.isEmpty && lon != null) {
        final rasi = KPService.SIGNS[(lon / 30).floor() % 12];
        dignity = KPService.getPlanetDignity(pKey == 'Lagna' ? 'Lagna' : (pKey[0].toUpperCase() + pKey.substring(1).toLowerCase()), rasi);
      }
      rows += "<tr><td style='color: var(--text-red)'>${_toLocal(pKey, langCode)}</td><td style='color: var(--text-red)'>${lon != null ? KPService.formatAbsoluteDegrees(lon) : "-"}</td><td style='color: var(--text-green)'>${p['nakshatra'] ?? "-"}.${p['pada'] ?? ""}</td><td style='color: var(--text-red)'>${_toLocal(starLord, langCode)}</td><td>$dignity</td></tr>";
    }
    return "<table class='planetary-table'><thead><tr><th>${l10n.planet}</th><th>${l10n.degree}</th><th>${l10n.nakshatraLabel}</th><th>${l10n.starLord}</th><th>-</th></tr></thead><tbody>$rows</tbody></table>";
  }

  static String _buildAshtaTableHtml(dynamic av, Map results, String langCode) {
    final List<String> displaySignsEn = ['Ar', 'Ta', 'Ge', 'Ca', 'Le', 'Vi', 'Li', 'Sc', 'Sa', 'Cp', 'Aq', 'Pi'];
    final List<String> displaySignsTa = ['மேஷ', 'ரிஷ', 'மிது', 'கட', 'சிம்', 'கன்', 'துலா', 'விரு', 'தனு', 'மக', 'கும்', 'மீன'];
    final List<String> displaySignsHi = ['मेष', 'वृष', 'मिथ', 'कर्क', 'सिंह', 'कन्', 'तुला', 'वृश्चि', 'धनु', 'मकर', 'कुंभ', 'मीन'];
    final List<String> displaySigns = langCode == 'en' ? displaySignsEn : (langCode == 'hi' ? displaySignsHi : displaySignsTa);
    av ??= results['ashtakavarga'] ?? results['ashta'] ?? results['av'];
    final Map avMap = av is Map ? av : {};
    final total = avMap['total'] as List? ?? avMap['Total'] as List? ?? List.filled(12, 0);
    String header = "<tr>" + displaySigns.map((s) => "<td style='background:#FAF6EE; color: var(--text-red); font-weight: bold;'>$s</td>").join() + "</tr>";
    String values = "<tr>" + total.map((v) => "<td style='font-weight:bold; color:var(--text-red)'>$v</td>").join() + "</tr>";
    return "<table class=\"ashta-table\">$header$values</table>";
  }

  static String _buildTimelineHtml(String title, List list, String type, Map? currentItem, AppLocalizations l10n, String langCode) {
    String rows = "";
    final now = DateTime.now();
    for (var d in list.take(9)) {
      final start = d['start'] as DateTime?; final end = d['end'] as DateTime?;
      final startStr = start != null ? DateFormat('dd/MM/yyyy').format(start) : "-";
      final endStr = end != null ? DateFormat('dd/MM/yyyy').format(end) : "-";
      bool isCurrent = start != null && end != null && now.isAfter(start) && now.isBefore(end);
      String highlight = isCurrent ? "class='highlight-row'" : "";
      rows += "<tr $highlight><td style='color: var(--text-red)'>${_toLocal(d['lord']?.toString() ?? "-", langCode)}</td><td>$startStr</td><td>$endStr</td></tr>";
    }
    return "<div><div style='text-align: center; color: var(--text-red); font-weight: bold; font-size: 11px; margin-bottom: 2px;'>$title</div><table class='timeline-table'><thead><tr><th>$type</th><th>${l10n.start}</th><th>${l10n.end}</th></tr></thead><tbody>$rows</tbody></table></div>";
  }

  static Map<int, List<String>> _getSafeChartMap(Map results, String key, String langCode) {
    final Map<int, List<String>> rasiMap = {};
    final lookupKey = (key == 'transit_rasi') ? 'rasi' : key;
    if (results.containsKey(lookupKey) && results[lookupKey] is Map) {
      final Map raw = results[lookupKey];
      raw.forEach((s, pList) {
        int idx = _getSignIdx(s.toString());
        if (idx != -1) {
          final List<String> planets = pList is List ? pList.map((e) => e.toString()).toList() : [pList.toString()];
          final List<String> cleanPlanets = [];
          for (var p in planets) {
            final trimmed = p.trim();
            if (trimmed.isEmpty) continue;
            
            // Split by space to separate planet name from degrees/details
            final firstWord = trimmed.split(' ').first;
            
            // Filter out house cusps (which are Roman numerals: I, II, III...)
            const romanNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'];
            if (romanNumerals.contains(firstWord)) {
              cleanPlanets.add(trimmed);
              continue;
            }
            
            // Translate the planet
            final localizedName = _toLocal(firstWord, langCode);
            if (localizedName.isNotEmpty) {
              cleanPlanets.add(trimmed.replaceFirst(firstWord, localizedName));
            } else {
              cleanPlanets.add(trimmed);
            }
          }
          if (cleanPlanets.isNotEmpty) {
            rasiMap.putIfAbsent(idx + 1, () => []).addAll(cleanPlanets);
          }
        }
      });
    }
    return rasiMap;
  }

  static int _getSignIdx(String s) {
    int idx = KPService.SIGNS.indexOf(s);
    if (idx == -1) idx = KPService.TAMIL_SIGNS.values.toList().indexOf(s);
    if (idx == -1) idx = (int.tryParse(s) ?? 1) - 1;
    return idx;
  }
}
