import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'kp_service.dart';
import 'settings_service.dart';
import 'pdf_helper_stub.dart' if (dart.library.html) 'pdf_helper_web.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class KpOnePagePdfService {
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
    return "";
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

    final htmlContent = _buildFullHtml(name, gender, results, astro, muruganBase64, ganapathyBase64, l10n);
    printHtmlWeb(htmlContent);
  }

  static Future<Uint8List> generate({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    required AppLocalizations l10n,
  }) async {
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

    final htmlContent = _buildFullHtml(name, gender, results, astro, muruganBase64, ganapathyBase64, l10n);
    
    if (kIsWeb) {
      printHtmlWeb(htmlContent);
      return Uint8List(0);
    }
    
    final Directory tempDir = await getTemporaryDirectory();
    final File pdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(htmlContent, tempDir.path, "kp_horoscope_${DateTime.now().millisecondsSinceEpoch}");
    final Uint8List bytes = await pdfFile.readAsBytes();
    await pdfFile.delete();
    return bytes;
  }


  static String _buildFullHtml(String name, String gender, Map<dynamic, dynamic> results, Map<String, dynamic> astro, String muruganBase64, String ganapathyBase64, AppLocalizations l10n) {
    final String langCode = l10n.localeName;
    final birthDt = results['birth_dt'] as DateTime?;
    final dateStr = birthDt != null ? DateFormat('dd . MM . yyyy').format(birthDt) : "-";
    final birthTime = birthDt != null ? DateFormat('hh:mm:ss a').format(birthDt) : "-";
    final timeStr = birthTime;
    final place = results['place'] ?? "-";
    final lat = results['lat']?.toString() ?? "-";
    final lon = results['lon']?.toString() ?? "-";
    final ayanamsa = results['ayanamsa'] ?? "24° 12' 51\" (KP-Newcomb)";
    final prasannaNo = results['prasannam_no'] ?? "-";
    
    String shopName = astro['shop_name'] ?? astro['name'] ?? "ஜிபி அஸ்ட்ரோ ஜோதிட வித்யாலயம்";
    String astroName = astro['astrologer_name'] ?? (astro['name'] != null ? "" : "Dr. Karunagaran");
    String address = astro['address'] ?? "சென்னை";
    String phone = astro['phone'] ?? "9800666225";
    final nowStr = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    final pan = results['panchangam'] ?? {};
    final details = results['planet_details'] ?? {};
    final moonDetails = details['moon'] ?? details['Moon'] ?? {};
    final nakshatraStr = moonDetails['nakshatra']?.toString() ?? pan['nakshatra']?.toString() ?? "-";
    final padaStr = moonDetails['pada']?.toString() ?? "-";
    final weekdayStr = pan['vara']?.toString() ?? (birthDt != null ? KPService.VARA_TAMIL[birthDt.weekday % 7] : "-");
    
    String age = results['age'] ?? "";
    if (age.isEmpty && birthDt != null) {
      final now = DateTime.now();
      int years = now.year - birthDt.year;
      int months = now.month - birthDt.month;
      int days = now.day - birthDt.day;
      if (days < 0) { months -= 1; days += 30; }
      if (months < 0) { years -= 1; months += 12; }
      age = "$years வயது, $months மாதம், $days நாள்";
    }

    final dasaList = results['dasa'] as List? ?? [];
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

    // Ruling Planets
    String rulingDay = "-"; String rulingMoon = "-"; String rulingMoonStar = "-"; String rulingLagna = "-"; String rulingLagnaStar = "-";
    if (results['panchangam'] != null) rulingDay = results['panchangam']['vara'] ?? "-";
    if (results['planet_details'] != null && results['planet_details']['moon'] != null) {
      rulingMoon = KPService.TAMIL_PLANETS[results['planet_details']['moon']['lords']?['signLord']] ?? "-";
      rulingMoonStar = KPService.TAMIL_PLANETS[results['planet_details']['moon']['lords']?['nakLord']] ?? "-";
    }
    if (results['planet_details'] != null && results['planet_details']['lagna'] != null) {
      rulingLagna = KPService.TAMIL_PLANETS[results['planet_details']['lagna']['lords']?['signLord']] ?? "-";
      rulingLagnaStar = KPService.TAMIL_PLANETS[results['planet_details']['lagna']['lords']?['nakLord']] ?? "-";
    }

    // Chart Gen
    Map<String, List<String>> rasiMap = {};
    Map<String, List<String>> bhavaMap = {};
    for (var sign in KPService.SIGNS) {
        rasiMap[sign] = [];
        bhavaMap[sign] = [];
    }
    final planetDetails = results['planet_details'] as Map<dynamic, dynamic>? ?? {};
    planetDetails.forEach((key, pVal) {
      if (key == 'uranus' || key == 'neptune' || key == 'pluto') return;
      final lords = pVal['lords'];
      if (lords != null && lords['sign'] != null) {
        String sign = lords['sign'];
        double lonDeg = (pVal['longitude'] ?? 0.0) % 30;
        int d = lonDeg.floor();
        int m = ((lonDeg - d) * 60).floor();
        String pName = _toLocal(key.toString(), langCode);
        if (key == 'lagna') pName = langCode == 'en' ? "Asc" : (langCode == 'hi' ? "ल" : "லக்");
        if (rasiMap.containsKey(sign)) {
          rasiMap[sign]!.add("$pName $d° $m'");
        }
      }
      
      // Bhava mapping
      final hNum = pVal['house'];
      if (hNum != null) {
          final cuspsData = results['houses_data'] as Map<dynamic, dynamic>? ?? {};
          final hData = cuspsData[hNum] ?? cuspsData[hNum.toString()];
          if (hData != null && hData['lords'] != null && hData['lords']['sign'] != null) {
              String bSign = hData['lords']['sign'];
              String pName = _toLocal(key.toString(), langCode);
              if (key == 'lagna') pName = langCode == 'en' ? "Asc" : (langCode == 'hi' ? "ल" : "லக்");
              if (bhavaMap.containsKey(bSign)) {
                  bhavaMap[bSign]!.add(pName);
              }
          }
      }
    });

    final cusps = results['houses_data'] as Map<dynamic, dynamic>? ?? {};
    cusps.forEach((key, cVal) {
      final lords = cVal['lords'];
      if (lords != null && lords['sign'] != null) {
        String sign = lords['sign'];
        double lonDeg = (cVal['longitude'] ?? 0.0) % 30;
        int d = lonDeg.floor();
        int m = ((lonDeg - d) * 60).floor();
        if (rasiMap.containsKey(sign)) {
          rasiMap[sign]!.add("$key) $d° $m'");
        }
        if (bhavaMap.containsKey(sign)) {
          bhavaMap[sign]!.add("$key)");
        }
      }
    });

    String renderCell(String sign, Map<String, List<String>> map) {
        final items = map[sign] ?? [];
        if (items.isEmpty) return "";
        // Split planets and cusps
        List<String> planets = items.where((i) => !i.contains(')')).toList();
        List<String> bavas = items.where((i) => i.contains(')')).toList();
        
        String bHtml = "";
        for (var b in bavas) {
            bHtml += "<div style='color:var(--text-red); font-weight:bold;'>$b</div>";
        }
        String pHtml = "";
        for (var p in planets) {
            pHtml += "<div>$p</div>";
        }
        return bHtml + pHtml;
    }

    // Sig Tables
    final sigs = results['significators'] as Map<dynamic, dynamic>?;
    String sigHtml = "";
    
    String topHouseSigHtml = "";
    final hSigs = sigs?['house_view'] as Map<dynamic, dynamic>?;
    if (hSigs != null) {
      for (int i = 1; i <= 12; i++) {
        final s = hSigs[i] ?? hSigs[i.toString()];
        if (s != null) {
          String a = (s['A'] as List).join(',');
          String b = (s['B'] as List).join(',');
          String c = (s['C'] as List).join(',');
          String d = (s['D'] as List).join(',');
          topHouseSigHtml += "<tr><td>$i</td><td style='color:blue;'>$a</td><td style='color:blue;'>$b</td><td style='color:blue;'>$c</td><td style='color:blue;'>$d</td></tr>";
        }
      }
    }
    if (sigs != null && sigs['planet_view'] != null) {
        final pView = sigs['planet_view'];
        final List<String> order = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu'];
        for (var k in order) {
            final sig = pView[k];
            if (sig == null) continue;
            String nakLord = "-"; String subLord = "-";
            if (planetDetails[k] != null && planetDetails[k]['lords'] != null) {
                nakLord = _toLocal(planetDetails[k]['lords']['nakLord'] ?? "", langCode);
                subLord = _toLocal(planetDetails[k]['lords']['subLord'] ?? "", langCode);
            }
            final aList = (sig['A'] as String).split(',').where((e)=>e.isNotEmpty).toList();
            final bList = (sig['B'] as String).split(',').where((e)=>e.isNotEmpty).toList();
            final cList = (sig['C'] as String).split(',').where((e)=>e.isNotEmpty).toList();
            final dList = (sig['D'] as String).split(',').where((e)=>e.isNotEmpty).toList();
            final a = aList.join(', ');
            final b = bList.join(', ');
            final c = cList.join(', ');
            final d = dList.join(', ');
            
            final allSigs = [...aList, ...bList, ...cList, ...dList].join(', ');
            String col2 = b.isNotEmpty ? "$nakLord($b)" : nakLord;
            String col3 = a.isNotEmpty ? "$subLord($a)" : subLord;
            sigHtml += "<tr><td>${_toLocal(k, langCode)}</td><td>$col2</td><td>$col3</td><td>$allSigs</td></tr>";
        }
    }
    
    String houseSigHtml = "";
    if (sigs != null && sigs['house_view'] != null) {
        final hView = sigs['house_view'];
        for (int i = 1; i <= 12; i++) {
            final sig = hView[i] ?? hView[i.toString()];
            if (sig == null) continue;
            String hNakLord = "-"; String hSubLord = "-";
            if (cusps[i] != null && cusps[i]['lords'] != null) {
                hNakLord = _toLocal(cusps[i]['lords']['nakLord'] ?? "", langCode);
                hSubLord = _toLocal(cusps[i]['lords']['subLord'] ?? "", langCode);
            } else if (cusps[i.toString()] != null && cusps[i.toString()]['lords'] != null) {
                hNakLord = _toLocal(cusps[i.toString()]['lords']['nakLord'] ?? "", langCode);
                hSubLord = _toLocal(cusps[i.toString()]['lords']['subLord'] ?? "", langCode);
            }
            final aList = (sig['A'] as List).map((e) => _toLocal(e.toString(), langCode)).where((e)=>e.isNotEmpty).toList();
            final bList = (sig['B'] as List).map((e) => _toLocal(e.toString(), langCode)).where((e)=>e.isNotEmpty).toList();
            final cList = (sig['C'] as List).map((e) => _toLocal(e.toString(), langCode)).where((e)=>e.isNotEmpty).toList();
            final dList = (sig['D'] as List).map((e) => _toLocal(e.toString(), langCode)).where((e)=>e.isNotEmpty).toList();
            final a = aList.join(', ');
            final b = bList.join(', ');
            final c = cList.join(', ');
            final d = dList.join(', ');
            
            final allSigs = [...aList, ...bList, ...cList, ...dList].join(', ');
            String col2 = b.isNotEmpty ? "$hSubLord($b)" : hSubLord;
            String col3 = a.isNotEmpty ? "$hNakLord($a)" : hNakLord;
            houseSigHtml += "<tr><td>$i</td><td>$col2</td><td>$col3</td><td>$hNakLord</td><td>$allSigs</td></tr>";
        }
    }
    
    String pTableHtml = "";
    final List<String> order = ['lagna', 'sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu'];
    for (int i = 1; i <= 12; i++) {
        final cD = cusps[i] ?? cusps[i.toString()];
        if (cD == null) continue;
        String signLord = "-"; String nakLord = "-"; String subLord = "-";
        if (cD['lords'] != null) {
            signLord = _toLocal(cD['lords']['signLord'] ?? "", langCode);
            nakLord = _toLocal(cD['lords']['nakLord'] ?? "", langCode);
            subLord = _toLocal(cD['lords']['subLord'] ?? "", langCode);
        }
        
        String pStr = "";
        if (i <= 10) {
            final k = order[i-1];
            if (planetDetails[k] != null && planetDetails[k]['lords'] != null) {
                String pSignLord = _toLocal(planetDetails[k]['lords']['signLord'] ?? "", langCode);
                String pNakLord = _toLocal(planetDetails[k]['lords']['nakLord'] ?? "", langCode);
                String pSubLord = _toLocal(planetDetails[k]['lords']['subLord'] ?? "", langCode);
                pStr = "<td>${_toLocal(k, langCode)}</td><td>$pSignLord</td><td>$pNakLord</td><td>$pSubLord</td>";
            } else {
                pStr = "<td>-</td><td>-</td><td>-</td><td>-</td>";
            }
        } else {
            pStr = "<td></td><td></td><td></td><td></td>";
        }
        
        pTableHtml += "<tr><td>$i</td><td>$nakLord</td><td>$subLord</td><td>$signLord</td> $pStr </tr>";
    }

    // Dasa
    String dasaCur = "-";
    if (results['dasa'] != null) {
        final now = DateTime.now();
        for (var d in results['dasa']) {
            if (now.isAfter(d['start']) && now.isBefore(d['end'])) {
                dasaCur = "${_toLocal(d['lord'] ?? '', langCode)} ${l10n.dasaTitle}";
                for (var b in d['subPeriods']) {
                    if (now.isAfter(b['start']) && now.isBefore(b['end'])) {
                        dasaCur += ", ${_toLocal(b['lord'] ?? '', langCode)} ${l10n.bukthiTitle}";
                        for (var a in b['subPeriods']) {
                            if (now.isAfter(a['start']) && now.isBefore(a['end'])) {
                                dasaCur += ", ${_toLocal(a['lord'] ?? '', langCode)} ${l10n.antharamTitle}";
                            }
                        }
                    }
                }
            }
        }
    }

    String r(String sign) => renderCell(sign, rasiMap);
    String b(String sign) => renderCell(sign, bhavaMap);

    return """
    <!DOCTYPE html>
    <html lang="ta">
    <head>
      <meta charset="utf-8"/>
      <meta name="viewport" content="width=794, initial-scale=1.0, maximum-scale=1.0"/>
      <title>Horoscope - $name</title>
      <style>
        * { box-sizing: border-box; }
        :root { --border-orange: #E0D4BE; --header-blue: #5D1204; --text-red: #5D1204; --text-green: #B58D3D; }
        html, body { margin: 0; padding: 0; width: 794px; }
        body { font-family: sans-serif; color: #333; font-size: 10px; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; background: white; }
        .page { background: white; width: 794px; min-height: 1123px; padding: 10px; position: relative; overflow: hidden; }
        .inner-page { border: 0.5px solid var(--text-red); padding: 8px; min-height: 1095px; display: flex; flex-direction: column; overflow: hidden; }
        @media screen {
          body { background: #f3f4f6; display: flex; flex-direction: column; align-items: center; }
        }
        @media print {
          @page { size: A4; margin: 0; }
          html, body { width: 100%; }
          body { background: white; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
          .page { width: 100%; padding: 10px; box-shadow: none; margin: 0; height: 297mm; overflow: hidden; }
          .inner-page { border: 0.5px solid var(--text-red); padding: 8px; height: 100%; display: flex; flex-direction: column; }
        }
        .header { border-bottom: 1px solid var(--text-red); margin-bottom: 4px; padding-bottom: 3px; }
        .header-top { display: flex; justify-content: space-between; }
        .header-title { color: var(--text-red); font-weight: bold; font-size: 14px; line-height: 1.1; }
        .header-sub { font-size: 9px; color: #555; line-height: 1.2; }
        .banner { background: var(--text-red); color: white; text-align: center; padding: 2px; font-weight: bold; font-size: 12px; margin: 3px 0; border-radius: 2px; }
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; margin-bottom: 4px; border-bottom: 1px solid #eee; padding-bottom: 3px; }
        .detail-row { display: flex; margin-bottom: 1px; font-size: 9px; }
        .detail-label { width: 78px; color: var(--text-red); font-weight: bold; }
        
        .grid-chart { width: 100%; border-collapse: collapse; table-layout: fixed; }
        .grid-chart td { border: 1px solid var(--text-red); height: 44px; text-align: center; font-size: 8px; font-weight: bold; padding: 1px; vertical-align: middle; background: #FAF6EE; }
        .chart-title { color: var(--text-red); font-size: 10px; font-weight: bold; line-height: 1.1; margin-bottom: 2px; }
        
        .patha-tables { display: flex; justify-content: space-between; margin-bottom: 4px; }
        .data-table { width: 49%; border-collapse: collapse; font-size: 8px; border: 1px solid var(--border-orange); table-layout: fixed; overflow: hidden; }
        .data-table th { background: #eee; border: 1px solid var(--border-orange); padding: 1px; font-weight: bold; color: var(--text-red); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .data-table td { border: 1px solid var(--border-orange); padding: 1px; text-align: center; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        
        .sig-table { font-size: 10px; width: 100%; border-collapse: collapse; margin-top: 3px; text-align: left; }
        .sig-table th { text-align: left; padding: 1px 0; }
        .sig-table td { padding: 1px 0; }

        .timeline-row { display: flex; gap: 6px; margin-top: 4px; }
        
        .footer { text-align: center; font-size: 6px; margin-top: 4px; font-style: italic; border-top: 1px dashed #ccc; padding-top: 2px; }
        .print-btn {
           position: fixed;
           top: 15px;
           right: 15px;
           background: var(--text-red);
           color: white;
           border: none;
           padding: 6px 14px;
           font-size: 11px;
           font-weight: bold;
           border-radius: 3px;
           cursor: pointer;
           z-index: 1000;
           box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        }
        .print-btn:hover { background: #4A0E03; }
        @media print { .print-btn { display: none !important; } }</style>
    </head>
    <body>
      <button class="print-btn" onclick="window.print()">🖨️ Print / Save PDF</button>
      <div class="page">
        <div class="inner-page">
          <div class="header">
            <div class="header-top" style="display: flex; justify-content: space-between; align-items: center;">
              <div style="flex: 0 0 auto; text-align: left; margin-right: 15px;">
                 ${ganapathyBase64.isNotEmpty ? '<img src="data:image/png;base64,$ganapathyBase64" style="height: 55px; width: 44px; object-fit: contain;" alt="Ganapathy" />' : ''}
              </div>
              <div style="flex: 1; text-align: center; min-width: 0;">
                <div class="header-title">${shopName}</div>
                 <div class="header-sub" style="white-space: pre-line; margin-top: 3px;">$astroName<br>$address</div>
                 <div style="color: var(--text-red); font-size: 9px; margin-top: 3px;">$phone | $nowStr</div>
              </div>
              <div style="flex: 0 0 auto; text-align: right; margin-left: 15px;">
                 ${muruganBase64.isNotEmpty ? '<img src="data:image/png;base64,$muruganBase64" style="height: 55px; width: 51px; object-fit: contain;" alt="Murugan" />' : ''}
              </div>
            </div>
          </div>
          <div class="banner">Software Developed by GB Astro | Mobile: +91 96006 66225 <span style="font-size: 12px; font-weight: normal; margin-left: 6px;"> </span></div>
          <div class="details-grid">
            <div>
              <div class="detail-row"><span class="detail-label">பெயர்</span>: <span style="color:var(--text-red)">$name</span></div>
              <div class="detail-row"><span class="detail-label">பாலினம்</span>: <span style="color:#333">${(gender.toLowerCase().contains('male') || gender == 'ஆண்') ? 'ஆண்' : 'பெண்'}</span></div>
              <div class="detail-row"><span class="detail-label">வயது</span>: <span style="color:#333">$age</span></div>
              <div class="detail-row"><span class="detail-label">நட்சத்திரம்</span>: <span style="color:#333">$nakshatraStr - $padaStr பாதம்</span></div>
              <div class="detail-row"><span class="detail-label">இராசி</span>: <span style="color:#333">$rasiStr இராசி</span></div>
              <div class="detail-row"><span class="detail-label">கிழமை</span>: <span style="color:#333">$weekdayStr</span></div>
              <div class="detail-row"><span class="detail-label">தசா இருப்பு</span>: <span style="color:var(--text-red)">$dasaBalance</span></div>
            </div>
            <div>
              <div class="detail-row"><span class="detail-label">பிறந்த தேதி</span>: <span style="color:var(--text-red)">$dateStr</span></div>
              <div class="detail-row"><span class="detail-label">தமிழ் தேதி</span>: <span style="color:#333">$tamilYear வருடம், $tamilMonth - $tamilDate</span></div>
              <div class="detail-row"><span class="detail-label">பிறந்த திதி</span>: <span style="color:#333">$thithiStr</span></div>
              <div class="detail-row"><span class="detail-label">பட்சம்</span>: <span style="color:#333">$pakshamStr</span></div>
              <div class="detail-row"><span class="detail-label">திதி சூன்யம்</span>: <span style="color:#333">$suniyaStr</span></div>
              <div class="detail-row"><span class="detail-label">நேரம்</span>: <span style="color:#333">${birthTime.isEmpty ? '-' : birthTime}</span></div>
              <div class="detail-row"><span class="detail-label">இடம்</span>: <span style="color:#333">${place}</span></div>
            </div>
            <div style="grid-column: 1 / -1; display:flex; justify-content:space-between; border-top: 1px dashed #ccc; padding-top:1mm;">
                <div class="detail-row"><span class="detail-label" style="width:25mm;">அயனாம்சம்</span>: <span style="color:#333">$ayanamsa</span></div>
                <div class="detail-row"><span class="detail-label" style="width:25mm;">ரேகாம்சம்</span>: <span style="color:#333">$lon E</span></div>
                <div class="detail-row"><span class="detail-label" style="width:25mm;">அட்சாம்சம்</span>: <span style="color:#333">$lat N</span></div>
                <div class="detail-row"><span class="detail-label" style="width:30mm;">பிரசன்ன எண்</span>: <span style="color:var(--text-red)">$prasannaNo</span></div>
            </div>
          </div>
          
          <div class="top-charts-grid">
          <div style="display: flex; justify-content: space-between; gap: 4mm; margin-bottom: 2mm;">
              <div style="flex: 1;">
                  <table class="grid-chart" style="max-width: 100%;">
                  <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
                  <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">ராசி கட்டம்</div></td><td>${r('Cancer')}</td></tr>
                  <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
                  <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
              </table>
              </div>
              <div style="flex: 1;">
                  <table class="grid-chart" style="max-width: 100%;">
                  <tr><td>${b('Pisces')}</td><td>${b('Aries')}</td><td>${b('Taurus')}</td><td>${b('Gemini')}</td></tr>
                  <tr><td>${b('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">பாவக கட்டம்</div></td><td>${b('Cancer')}</td></tr>
                  <tr><td>${b('Capricorn')}</td><td>${b('Leo')}</td></tr>
                  <tr><td>${b('Sagittarius')}</td><td>${b('Scorpio')}</td><td>${b('Libra')}</td><td>${b('Virgo')}</td></tr>
              </table>
              </div>
          </div>
              <div style="display: flex; justify-content: space-between; gap: 4mm;">
                  <table class="data-table">
                      <tr><th colspan="4">12 பாவ நிலைகள்</th><th colspan="4" style="border-left:0.5mm solid var(--border-orange);">கிரக நிலைகள்</th></tr>
                      <tr>
                          <td>பா</td><td>ந.அ</td><td>உ.அ</td><td>உ.உ</td>
                          <td style="border-left:0.5mm solid var(--border-orange);">கிரகம்</td><td>ந.அ</td><td>உ.அ</td><td>உ.உ</td>
                      </tr>
                      $pTableHtml
                  </table>
                  <table class="data-table">
                      <tr><th colspan="5">பாவ தொடர்புகள் (A, B, C, D)</th></tr>
                      <tr>
                          <td>பா</td><td>A</td><td>B</td><td>C</td><td>D</td>
                      </tr>
                      $topHouseSigHtml
                  </table>
              </div>
          </div>
          
          <div style="text-align:right; font-size: 3.0mm; font-weight:bold; color:var(--text-red); margin-bottom:1mm;">தசா நடப்பு : $dasaCur</div>
          <div style="color:var(--text-green); font-weight:bold; text-align:center; font-size: 4.2mm; margin-bottom:1mm;">கிரக தொடர்புகள் (மதி என்ற தசா, புத்திகளுக்கு)</div>
          <table class="sig-table">
              <tr>
                  <th style="width:10%">கிரகம்</th>
                  <th style="width:25%">நட். அதிபதி</th>
                  <th style="width:25%">உப. அதிபதி</th>
                  <th style="width:40%">தொடர்புகள்</th>
              </tr>
              $sigHtml
          </table>
          
          <div style="color:var(--text-green); font-weight:bold; text-align:center; font-size: 4.2mm; margin-top:2mm; margin-bottom:1mm;">பாவ தொடர்புகள்</div>
          <table class="sig-table">
              <tr>
                  <th style="width:10%">பாவம்</th>
                  <th style="width:20%">உப. அதிபதி</th>
                  <th style="width:20%">நட். அதிபதி</th>
                  <th style="width:15%">அதிபதி</th>
                  <th style="width:35%">தொடர்புகள்</th>
              </tr>
              $houseSigHtml
          </table>
          
          <div style="flex: 1; min-height: 5mm; border: 0.3mm solid var(--border-orange); border-radius: 1mm; padding: 1mm; margin-top: 1.5mm; display: flex; flex-direction: column; background: #fff;">
             <div style="color: var(--header-blue); font-weight: bold; font-size: 3.0mm; margin-bottom: 0mm;">✍️ ஜோதிடர் குறிப்பு:</div>
             <div style="flex: 1; background-image: linear-gradient(to bottom, transparent 95%, #e0e0e0 95%); background-size: 100% 5mm; margin-top: 1mm;"></div>
          </div>
          <div class="footer" style="margin-top: auto;">Created by GB Astro Astrology Software | Mobile: +91 96006 66225</div>
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

}
