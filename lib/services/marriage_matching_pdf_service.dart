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
import 'matching_result.dart';
import 'pdf_helper_stub.dart' if (dart.library.html) 'pdf_helper_web.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';
import 'astro_data.dart';

class MarriageMatchingPdfService {
  static Future<void> showHtmlReport({
    required Map<String, dynamic> girlFullData,
    required Map<String, dynamic> boyFullData,
    required List<MatchingResult> results,
    required String totalScore,
    required bool isMatchPresent,
    required AppLocalizations l10n,
  }) async {
    if (!kIsWeb) return;
    final astro = await SettingsService.getAstrologerDetails();
    
    String muruganBase64 = "";
    String ganapathyBase64 = "";
    try {
      final byteDataM = await rootBundle.load('assets/images/muruga.png');
      muruganBase64 = base64Encode(byteDataM.buffer.asUint8List());
      final byteDataG = await rootBundle.load('assets/images/ganapathy.png');
      ganapathyBase64 = base64Encode(byteDataG.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error loading images: $e");
    }

    final htmlContent = _buildFullHtml(girlFullData, boyFullData, results, totalScore, astro, muruganBase64, ganapathyBase64, isMatchPresent, l10n);
    printHtmlWeb(htmlContent);
  }

  static Future<Uint8List> generate({
    required Map<String, dynamic> girlFullData,
    required Map<String, dynamic> boyFullData,
    required List<MatchingResult> results,
    required String totalScore,
    required bool isMatchPresent,
    required AppLocalizations l10n,
  }) async {
    final astro = await SettingsService.getAstrologerDetails();
    
    String muruganBase64 = "";
    String ganapathyBase64 = "";
    try {
      final byteDataM = await rootBundle.load('assets/images/muruga.png');
      muruganBase64 = base64Encode(byteDataM.buffer.asUint8List());
      final byteDataG = await rootBundle.load('assets/images/ganapathy.png');
      ganapathyBase64 = base64Encode(byteDataG.buffer.asUint8List());
    } catch (e) {
      debugPrint("Error loading images: $e");
    }

    if (kIsWeb) {
      final pdf = pw.Document();
      return pdf.save(); // Direct generation not fully supported on web without html to pdf
    }
    
    try {
      final htmlContent = _buildFullHtml(girlFullData, boyFullData, results, totalScore, astro, muruganBase64, ganapathyBase64, isMatchPresent, l10n);
      final Directory tempDir = await getTemporaryDirectory();
      final File pdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(htmlContent, tempDir.path, "matching_${DateTime.now().millisecondsSinceEpoch}");
      final Uint8List bytes = await pdfFile.readAsBytes();
      await pdfFile.delete();
      return bytes;
    } catch (e) {
      final pdf = pw.Document();
      return pdf.save();
    }
  }

  static String _buildFullHtml(Map<String, dynamic> girlFullData, Map<String, dynamic> boyFullData, List<MatchingResult> results, String totalScore, Map<String, String> astro, String muruganBase64, String ganapathyBase64, bool isMatchPresent, AppLocalizations l10n) {
    String shopName = astro['name'] ?? "ஆதிகுரு ஜோதிட வித்யாலயம்";
    String astroName = astro['name'] != null ? "" : "Dr. Karunagaran";
    String address = astro['address'] ?? "ஆதிகுரு ஜோதிட வித்தியாலயம், சென்னை";
    String phone = astro['phone'] ?? "Ph: 9600666225";
    
    final nowStr = DateFormat('dd/MM/yyyy  hh:mm:ss a').format(DateTime.now());

    String ganapathyImgHtml = ganapathyBase64.isNotEmpty ? '<img src="data:image/png;base64,$ganapathyBase64" height="50" alt="Ganapathy"/>' : '';
    String muruganImgHtml = muruganBase64.isNotEmpty ? '<img src="data:image/png;base64,$muruganBase64" height="50" width="45" style="object-fit: fill;" alt="Murugan"/>' : '';

    // Extracting details for Girl
    final gName = girlFullData['name'] ?? "-";
    final gDob = girlFullData['birth_dt'] != null ? DateFormat('dd/MM/yyyy').format(girlFullData['birth_dt']) : "-";
    final gTob = girlFullData['panchangam']?['birth_time'] ?? girlFullData['tob'] ?? "-";
    final gDtStr = "$gDob $gTob";
    final gPlace = girlFullData['place'] ?? "-";
    final gRasi = KPService.TAMIL_SIGNS[girlFullData['planet_details']?['moon']?['rasi']] ?? "-";
    final gNak = girlFullData['planet_details']?['moon']?['nakshatra'] ?? "-";
    final gPada = "${girlFullData['planet_details']?['moon']?['pada']}ம் பாதம்";
    final gStarStr = "$gRasi, $gNak - $gPada";
    final gLagna = KPService.TAMIL_SIGNS[girlFullData['planet_details']?['lagna']?['rasi']] ?? "-";
    
    // Extracting details for Boy
    final bName = boyFullData['name'] ?? "-";
    final bDob = boyFullData['birth_dt'] != null ? DateFormat('dd/MM/yyyy').format(boyFullData['birth_dt']) : "-";
    final bTob = boyFullData['panchangam']?['birth_time'] ?? boyFullData['tob'] ?? "-";
    final bDtStr = "$bDob $bTob";
    final bPlace = boyFullData['place'] ?? "-";
    final bRasi = KPService.TAMIL_SIGNS[boyFullData['planet_details']?['moon']?['rasi']] ?? "-";
    final bNak = boyFullData['planet_details']?['moon']?['nakshatra'] ?? "-";
    final bPada = "${boyFullData['planet_details']?['moon']?['pada']}${l10n.localeName == 'ta' ? 'ம் பாதம்' : ' Pada'}";
    final bStarStr = "$bRasi, $bNak - $bPada";
    final bLagna = KPService.TAMIL_SIGNS[boyFullData['planet_details']?['lagna']?['rasi']] ?? "-";

    final langCode = l10n.localeName;

    String _getDasaBalance(Map<String, dynamic> data) {
      final dasaList = data['dasa'] as List? ?? [];
      final birthDt = data['birth_dt'] as DateTime?;
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
          final lordTamil = KPService.TAMIL_PLANET_SHORT[firstDasa['lord']] ?? KPService.TAMIL_PLANETS[firstDasa['lord']] ?? firstDasa['lord'] ?? "-";
          String yrStr = langCode == 'en' ? 'Y' : (langCode == 'hi' ? 'वर्ष' : 'வரு');
          String moStr = langCode == 'en' ? 'M' : (langCode == 'hi' ? 'माह' : 'மா');
          String daStr = langCode == 'en' ? 'D' : (langCode == 'hi' ? 'दिन' : 'நா');
          return "$lordTamil: $years $yrStr, $months $moStr, $days $daStr";
        }
      }
      return "-";
    }

    String _getCurrentDasa(Map<String, dynamic> data) {
      final dasaList = data['dasa'] as List? ?? [];
      final now = DateTime.now();
      for (var d in dasaList) {
        final start = d['start'] as DateTime?; final end = d['end'] as DateTime?;
        if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) {
          final dLord = KPService.TAMIL_PLANET_SHORT[d['lord']] ?? KPService.TAMIL_PLANETS[d['lord']] ?? d['lord'];
          
          String bukthi = "";
          String bStartStr = "";
          for (var b in d['subPeriods'] as List? ?? []) {
             final bs = b['start'] as DateTime?; final be = b['end'] as DateTime?;
             if (bs != null && be != null && now.isAfter(bs) && now.isBefore(be)) {
                bukthi = KPService.TAMIL_PLANET_SHORT[b['lord']] ?? KPService.TAMIL_PLANETS[b['lord']] ?? b['lord'];
                bStartStr = DateFormat('dd/MM/yy').format(bs);
                break;
             }
          }
          return "$dLord/$bukthi (${langCode == 'en' ? 'From' : (langCode == 'hi' ? 'से' : 'லிருந்து')} $bStartStr)";
        }
      }
      return "-";
    }

    final gDasaBal = _getDasaBalance(girlFullData);
    final bDasaBal = _getDasaBalance(boyFullData);
    final gCurrDasa = _getCurrentDasa(girlFullData);
    final bCurrDasa = _getCurrentDasa(boyFullData);

    // Panchangam Details
    final gPan = girlFullData['panchangam'] ?? {};
    final bPan = boyFullData['panchangam'] ?? {};
    
    String gVara = gPan['vara'] ?? (girlFullData['birth_dt'] != null ? KPService.VARA_TAMIL[girlFullData['birth_dt'].weekday % 7] : "");
    String bVara = bPan['vara'] ?? (boyFullData['birth_dt'] != null ? KPService.VARA_TAMIL[boyFullData['birth_dt'].weekday % 7] : "");
    
    String gTamilDt = "${gPan['tamil_year'] ?? ''} ${langCode == 'en' ? 'Year' : (langCode == 'hi' ? 'वर्ष' : 'வருடம்')}, ${gPan['tamil_month'] ?? ''} ${gPan['tamil_date'] ?? ''}, $gVara";
    String bTamilDt = "${bPan['tamil_year'] ?? ''} ${langCode == 'en' ? 'Year' : (langCode == 'hi' ? 'वर्ष' : 'வருடம்')}, ${bPan['tamil_month'] ?? ''} ${bPan['tamil_date'] ?? ''}, $bVara";

    // 9 Bukthis list
    List<Map<String, dynamic>> _getNext9Bukthis(Map<String, dynamic> data) {
      final dasaList = data['dasa'] as List? ?? [];
      final now = DateTime.now();
      List<Map<String, dynamic>> bukthis = [];
      
      bool foundCurrent = false;

      Map<String, String> shortNames = {
        'சூரியன்': 'சூரி', 'சந்திரன்': 'சந்', 'செவ்வாய்': 'செவ்', 'புதன்': 'புத',
        'குரு': 'குரு', 'சுக்கிரன்': 'சுக்', 'சனி': 'சனி', 'ராகு': 'ராகு', 'கேது': 'கேது'
      };

      for (var d in dasaList) {
        for (int i = 0; i < (d['subPeriods'] as List? ?? []).length; i++) {
          var b = d['subPeriods'][i];
          final start = b['start'] as DateTime?;
          final end = b['end'] as DateTime?;
          
          if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) {
             foundCurrent = true;
          }
          
          if (foundCurrent && start != null && end != null) {
             final dLord = shortNames[d['lord']] ?? d['lord'];
             final bLord = shortNames[b['lord']] ?? b['lord'];
             bukthis.add({
               'name': "$dLord/$bLord",
               'period': DateFormat('dd/MM/yyyy').format(start),
               'isNewDasa': i == 0 // highlight if it's the start of a new dasa
             });
             if (bukthis.length == 10) return bukthis; // Current + next 9
          }
        }
      }
      return bukthis;
    }

    final gBukthis = _getNext9Bukthis(girlFullData);
    final bBukthis = _getNext9Bukthis(boyFullData);

    String html = """
    <!DOCTYPE html>
    <html lang="ta">
    <head>
      <meta charset="utf-8"/>
      <title>Marriage Matching Report</title>
      <style>
        :root { --border-orange: #E0D4BE; --header-blue: #5D1204; --text-red: #5D1204; --text-green: #B58D3D; }
        body { font-family: sans-serif; margin: 0; padding: 10px; color: #333; font-size: 10px; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
        @media screen {
          body { background: #f3f4f6; display: flex; flex-direction: column; align-items: center; }
          .page { background: white; width: 21cm; height: 29.7cm; padding: 5mm; box-shadow: 0 0 10px rgba(0,0,0,0.1); margin: 10px 0; position: relative; box-sizing: border-box; }
          .inner-page { border: 1.5px solid var(--text-red); padding: 5mm; height: 100%; box-sizing: border-box; }
          .print-btn { position: fixed; top: 20px; right: 20px; background: var(--text-red); color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; font-weight: bold; font-size: 14px; z-index: 1000; }
          .print-btn:hover { background: #3E0A02; }
        }
        @media print {
          @page { size: 21cm 29.7cm; margin: 0; }
          body { background: white; padding: 0; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
          .page { width: 21cm; height: 29.7cm; padding: 5mm; box-shadow: none; margin: 0; box-sizing: border-box; }
          .inner-page { border: 1.5px solid var(--text-red); padding: 5mm; box-sizing: border-box; height: 100%; }
          .no-print { display: none !important; }
        }
        .header { border-bottom: 2px solid var(--text-red); margin-bottom: 6px; padding-bottom: 4px; }
        .header-top { display: flex; justify-content: space-between; }
        h1, h2, h3, h4 { margin: 0; color: var(--text-red); text-align: center; }
        h1 { font-size: 15px; font-weight: bold; }
        h2 { font-size: 12px; font-weight: normal; margin-top: 2px; }
        .title-box { background: var(--text-red); color: white; text-align: center; padding: 3px; margin: 6px 0; font-size: 12px; font-weight: bold; border-radius: 3px; }
        
        .table-container { display: flex; justify-content: space-between; gap: 10px; margin-bottom: 6px; }
        .section-box { border: 1.5px solid var(--border-orange); border-radius: 5px; padding: 5px; width: 48%; }
        .section-title { color: var(--text-red); font-weight: bold; font-size: 11px; margin-bottom: 4px; border-bottom: 1px solid var(--border-orange); padding-bottom: 2px; text-align: center; }
        
        table { width: 100%; border-collapse: collapse; margin-bottom: 6px; font-size: 9px; }
        th, td { border: 1px solid var(--border-orange); padding: 2px 4px; text-align: left; }
        th { background: #fdfaf6; color: var(--text-red); font-weight: bold; }
        .col-header { background: #fdfaf6; font-weight: bold; text-align: center; color: var(--text-red); }
        .match-good { color: green; font-weight: bold; }
        .match-avg { color: orange; font-weight: bold; }
        .match-bad { color: red; font-weight: bold; }
        
        .chart-table { width: 100%; height: 100%; border-collapse: collapse; table-layout: fixed; }
        .chart-table td { border: 1.5px solid var(--text-red); height: 66px; padding: 1px; vertical-align: top; text-align: center; position: relative; font-size: 9.5px; }
        .chart-center { text-align: center !important; vertical-align: middle !important; font-weight: bold; color: var(--text-red); font-size: 12px !important; }
        .chart-box { border: 1.5px solid var(--text-red); padding: 2px; width: 48%; }
        
        .footer { text-align: center; font-size: 8px; color: #666; border-top: 1px solid #ccc; padding-top: 4px; margin-top: auto; }
      </style>
    </head>
    <body>
      <button class="no-print print-btn" onclick="window.print()">Print PDF</button>
      
      <!-- SINGLE PAGE -->
      <div class="page">
        <div class="inner-page" style="display: flex; flex-direction: column;">
          <div class="header">
            <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
              <!-- Left side: Ganapathy Image -->
              <div style="width: 15%; text-align: left;">
                 $ganapathyImgHtml
              </div>
              
              <!-- Center: Astrologer Address Details -->
              <div style="width: 70%; text-align: center;">
                 <h1 style="font-size: 15px; font-weight: bold; color: var(--text-red); margin: 0;">$shopName</h1>
                 <h2 style="font-size: 11px; font-weight: normal; color: var(--text-red); margin: 3px 0;">
                    $address ${astroName.isNotEmpty ? ' | Astrologer: $astroName' : ''}
                 </h2>
                 <div style="font-size: 9px; color: #555; margin-top: 5px;">
                    <b>Contact:</b> $phone &nbsp;|&nbsp; <b>Date:</b> $nowStr
                 </div>
              </div>

              <!-- Right side: Murugan Image -->
              <div style="width: 15%; text-align: right;">
                 $muruganImgHtml
              </div>
            </div>
          </div>
          
          <div class="title-box">${langCode == 'en' ? 'Marriage Matching' : (langCode == 'hi' ? 'विवाह मिलान' : 'திருமணப் பொருத்தம்')} (Marriage Matching)</div>
          
          <table>
            <tr>
              <th width="20%">${langCode == 'en' ? 'Details' : (langCode == 'hi' ? 'विवरण' : 'விவரம்')}</th>
              <th width="40%" class="col-header" style="color: #D81B60;">${langCode == 'en' ? 'Female' : (langCode == 'hi' ? 'कन्या' : 'பெண்')} (Female)</th>
              <th width="40%" class="col-header" style="color: #1565C0;">${langCode == 'en' ? 'Male' : (langCode == 'hi' ? 'वर' : 'ஆண்')} (Male)</th>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Name' : (langCode == 'hi' ? 'नाम' : 'பெயர்')}</b></td>
              <td style="color: #D81B60; font-weight: bold; font-size: 13px;">$gName</td>
              <td style="color: #1565C0; font-weight: bold; font-size: 13px;">$bName</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Birth Date, Time' : (langCode == 'hi' ? 'जन्म तिथि, समय' : 'பிறந்த தேதி, நேரம்')}</b></td>
              <td>$gDtStr</td>
              <td>$bDtStr</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Birth Place' : (langCode == 'hi' ? 'जन्म स्थान' : 'பிறந்த இடம்')}</b></td>
              <td>$gPlace</td>
              <td>$bPlace</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Tamil Date, Day' : (langCode == 'hi' ? 'तमिल तिथि, दिन' : 'தமிழ் தேதி, கிழமை')}</b></td>
              <td>$gTamilDt</td>
              <td>$bTamilDt</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Thithi' : (langCode == 'hi' ? 'तिथि' : 'திதி')}</b></td>
              <td>${gPan['tithi'] ?? "-"}</td>
              <td>${bPan['tithi'] ?? "-"}</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Yoga' : (langCode == 'hi' ? 'योग' : 'யோகம்')}</b></td>
              <td>${gPan['yoga'] ?? "-"}</td>
              <td>${bPan['yoga'] ?? "-"}</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Karana' : (langCode == 'hi' ? 'करण' : 'கரணம்')}</b></td>
              <td>${gPan['karana'] ?? "-"}</td>
              <td>${bPan['karana'] ?? "-"}</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Lagna' : (langCode == 'hi' ? 'लग्न' : 'லக்னம்')}</b></td>
              <td>$gLagna</td>
              <td>$bLagna</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Rasi, Nakshatra, Pada' : (langCode == 'hi' ? 'राशि, नक्षत्र, पाद' : 'ராசி, நட்சத்திரம், பாதம்')}</b></td>
              <td style="font-weight: bold;">$gStarStr</td>
              <td style="font-weight: bold;">$bStarStr</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Dasa Balance at Birth' : (langCode == 'hi' ? 'जन्म के समय दशा शेष' : 'பிறக்கும் போது தசா இருப்பு')}</b></td>
              <td>$gDasaBal</td>
              <td>$bDasaBal</td>
            </tr>
            <tr>
              <td><b>${langCode == 'en' ? 'Current Dasa Bukthi' : (langCode == 'hi' ? 'वर्तमान दशा भुक्ति' : 'நடப்பு தசா புத்தி')}</b></td>
              <td>$gCurrDasa</td>
              <td>$bCurrDasa</td>
            </tr>
          </table>

          <div class="title-box">${langCode == 'en' ? 'Rasi Charts' : (langCode == 'hi' ? 'राशि चक्र' : 'ராசி கட்டங்கள்')}</div>
          <div class="table-container">
            <div class="chart-box">
              ${_buildChartHtml(girlFullData['rasi'], langCode == 'en' ? 'Female Chart' : (langCode == 'hi' ? 'कन्या चक्र' : 'பெண் ராசி'), langCode)}
            </div>
            <div class="chart-box">
              ${_buildChartHtml(boyFullData['rasi'], langCode == 'en' ? 'Male Chart' : (langCode == 'hi' ? 'वर चक्र' : 'ஆண் ராசி'), langCode)}
            </div>
          </div>
          
          <div class="table-container">
            <!-- Left Side: 10 Matchings (55% width) -->
            <div style="width: 55%;">
              <div class="title-box">${langCode == 'en' ? '10 Matchings' : (langCode == 'hi' ? '10 गुण मिलान' : '10 பொருத்தங்கள் (10 Matchings)')}</div>
              <table>
                <tr>
                  <th width="25%">${langCode == 'en' ? 'Matching' : (langCode == 'hi' ? 'मिलान' : 'பொருத்தம்')}</th>
                  <th width="25%">${langCode == 'en' ? 'Female' : (langCode == 'hi' ? 'कन्या' : 'பெண்')}</th>
                  <th width="25%">${langCode == 'en' ? 'Male' : (langCode == 'hi' ? 'वर' : 'ஆண்')}</th>
                  <th width="25%">${langCode == 'en' ? 'Result' : (langCode == 'hi' ? 'परिणाम' : 'முடிவு')}</th>
                </tr>
                ${results.map((r) {
                  String pName = r.name.replaceAll('ப் பொருத்தம்', '').replaceAll(' பொருத்தம்', '').trim();
                  String statusClass = r.result == AstroData.matchUththamam ? 'match-good' : (r.result == AstroData.matchMadhythiyam ? 'match-avg' : 'match-bad');
                  return "<tr><td><b>$pName</b></td><td>${r.girlValue.isNotEmpty ? r.girlValue : '-'}</td><td>${r.boyValue.isNotEmpty ? r.boyValue : '-'}</td><td class='$statusClass'>${r.result}</td></tr>";
                }).join('')}
              </table>
              
              <div style="margin-top: 5px; border: 1.5px solid var(--border-orange); border-radius: 5px; padding: 4px; text-align: center;">
                 <span style="background: var(--text-red); color: white; padding: 4px 15px; border-radius: 15px; font-weight: bold; font-size: 13px;">
                    ${langCode == 'en' ? 'Total Match:' : (langCode == 'hi' ? 'कुल मिलान:' : 'மொத்த பொருத்தம்:')} $totalScore / 11 ${langCode == 'en' ? 'Matches' : (langCode == 'hi' ? 'गुण' : 'உண்டு')}
                 </span>
              </div>
            </div>

            <!-- Right Side: 9 Bukthis (43% width) -->
            <div style="width: 43%;">
              <div class="title-box">${langCode == 'en' ? 'Current & Next 9 Bukthis' : (langCode == 'hi' ? 'वर्तमान और अगले 9 भुक्ति' : 'நடப்பு, அடுத்து வரும் 9 புத்திகள்')}</div>
              <div style="display: flex; justify-content: space-between; gap: 5px;">
                <div class="section-box" style="width: 48%; padding: 3px;">
                  <div class="section-title" style="color: #D81B60; font-size: 10px;">${langCode == 'en' ? 'Female' : (langCode == 'hi' ? 'कन्या' : 'பெண் (Female)')}</div>
                  <table style="font-size: 9px; margin-bottom: 0;">
                    <tr><th>${langCode == 'en' ? 'Dasa/Bukthi' : (langCode == 'hi' ? 'दशा/भुक्ति' : 'தசை/புத்தி')}</th><th>${langCode == 'en' ? 'Start' : (langCode == 'hi' ? 'आरंभ' : 'ஆரம்பம்')}</th></tr>
                    ${gBukthis.map((b) {
                      String nameHtml = b['isNewDasa'] == true ? "<span style='color:red; font-weight:bold;'>${b['name']}</span>" : b['name']!;
                      return "<tr><td>$nameHtml</td><td>${b['period']}</td></tr>";
                    }).join('')}
                  </table>
                </div>
                <div class="section-box" style="width: 48%; padding: 3px;">
                  <div class="section-title" style="color: #1565C0; font-size: 10px;">${langCode == 'en' ? 'Male' : (langCode == 'hi' ? 'वर' : 'ஆண் (Male)')}</div>
                  <table style="font-size: 9px; margin-bottom: 0;">
                    <tr><th>${langCode == 'en' ? 'Dasa/Bukthi' : (langCode == 'hi' ? 'दशा/भुक्ति' : 'தசை/புத்தி')}</th><th>${langCode == 'en' ? 'Start' : (langCode == 'hi' ? 'आरंभ' : 'ஆரம்பம்')}</th></tr>
                    ${bBukthis.map((b) {
                      String nameHtml = b['isNewDasa'] == true ? "<span style='color:red; font-weight:bold;'>${b['name']}</span>" : b['name']!;
                      return "<tr><td>$nameHtml</td><td>${b['period']}</td></tr>";
                    }).join('')}
                  </table>
                </div>
              </div>
            </div>
          </div>


          <div class="title-box" style="margin-top: 10px; width: 100%;">${langCode == 'en' ? 'Astrologer Notes' : (langCode == 'hi' ? 'ज्योतिषी की टिप्पणी' : 'ஜோதிடர் குறிப்பு')}</div>
          <div style="min-height: 35px; padding: 10px; border: 1.5px dashed var(--border-orange); border-radius: 5px; margin-top: 5px; text-align: center; font-size: 11px; font-weight: bold; line-height: 1.5; color: #1E3A8A;">
              ${langCode == 'en' ? 'Based on star matching, dosha matching, lagna matching, and dasa bukthi matching, the match is ' + (isMatchPresent ? 'PRESENT' : 'NOT PRESENT') : (langCode == 'hi' ? 'नक्षत्र मिलान, दोष मिलान, लग्न मिलान और दशा भुक्ति मिलान के आधार पर, मिलान ' + (isMatchPresent ? 'उपस्थित है' : 'नहीं है') : 'நட்சத்திர பொருத்தம், திருமண சார்ந்த தோஷ பொருத்தம், லக்ன பொருத்தம், பாவக இணைவு, கிரக இணைவு, தசா புத்தி பொருத்தம் ஆகியவற்றைக் கொண்டு பலன் பார்த்ததில் பொருத்தம் ' + (isMatchPresent ? "உள்ளது" : "இல்லை"))}
          </div>

          <div class="footer">${langCode == 'en' ? 'Disclaimer: This astrologer note is the personal opinion of the astrologer. The software is not responsible for these predictions.' : (langCode == 'hi' ? 'अस्वीकरण: यह ज्योतिषी टिप्पणी ज्योतिषी की व्यक्तिगत राय है। सॉफ्टवेयर इन भविष्यवाणियों के लिए जिम्मेदार नहीं है।' : 'பொறுப்புத்துறப்பு: இந்த ஜோதிடர் குறிப்பு ஜோதிடரின் தனிப்பட்ட கருத்தாகும். இதில் உள்ள பலன்களுக்கும் மென்பொருளுக்கும் எவ்வித தொடர்பும் இல்லை.')}</div>
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
    
    return html;
  }

  static String _buildChartHtml(dynamic chartData, String title, String langCode) {
    if (chartData == null || chartData is! Map) return "<div style='text-align:center; padding: 20px;'>Chart Data Not Available</div>";
    
    Map<String, List<String>> rasiMap = {};
    chartData.forEach((key, val) {
      if (val is List) {
        rasiMap[key.toString()] = val.map((e) => e.toString()).toList();
      }
    });

    String getPl(String sign) {
      final items = rasiMap[sign] ?? [];
      final highlighted = items.map((p) {
        if (p.contains('லக்') || p.toLowerCase().contains('lagna') || p.toLowerCase().contains('asc')) {
          String lagnaStr = langCode == 'en' ? 'Lag' : (langCode == 'hi' ? 'लग्न' : 'லக்');
          return "<span style='color: #D81B60; font-weight: 900; font-size: 11px;'>$lagnaStr</span>";
        }
        return p;
      }).toList();
      return highlighted.join('<br>');
    }

    return """
    <table class="chart-table">
      <tr>
        <td>${getPl('Pisces')}</td>
        <td>${getPl('Aries')}</td>
        <td>${getPl('Taurus')}</td>
        <td>${getPl('Gemini')}</td>
      </tr>
      <tr>
        <td>${getPl('Aquarius')}</td>
        <td colspan="2" rowspan="2" class="chart-center">$title</td>
        <td>${getPl('Cancer')}</td>
      </tr>
      <tr>
        <td>${getPl('Capricorn')}</td>
        <td>${getPl('Leo')}</td>
      </tr>
      <tr>
        <td>${getPl('Sagittarius')}</td>
        <td>${getPl('Scorpio')}</td>
        <td>${getPl('Libra')}</td>
        <td>${getPl('Virgo')}</td>
      </tr>
    </table>
    """;
  }
}
