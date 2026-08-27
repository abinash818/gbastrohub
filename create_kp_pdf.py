import os

code = r'''import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'kp_service.dart';
import 'settings_service.dart';
import 'pdf_helper_stub.dart' if (dart.library.html) 'pdf_helper_web.dart';

class KpOnePagePdfService {
  static const List<String> _validPlanets = [
    'lagna', 'asc', 'sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu', 'mandi', 'maanthi', 'gulika'
  ];

  static final Map<String, String> _tamilShort = {
    'lagna': 'லக்', 'asc': 'லக்', 'sun': 'சூரி', 'moon': 'சந்', 'mars': 'செவ்', 
    'mercury': 'புத', 'jupiter': 'குரு', 'venus': 'சுக்', 'saturn': 'சனி', 
    'rahu': 'ரா', 'ketu': 'கே', 'mandi': 'மா', 'maanthi': 'மா', 'gulika': 'கு'
  };

  static String _toTamil(String p) {
    final key = p.toLowerCase().trim();
    if (_tamilShort.containsKey(key)) return _tamilShort[key]!;
    if (_tamilShort.values.contains(p)) return p;
    for (var entry in KPService.TAMIL_PLANETS.entries) {
      if (entry.value == p || entry.key == p) {
        return _tamilShort[entry.key.toLowerCase()] ?? p;
      }
    }
    if (key.startsWith('t_')) {
      final subKey = key.substring(2);
      if (_tamilShort.containsKey(subKey)) return _tamilShort[subKey]!;
    }
    return "";
  }

  static Future<void> showHtmlReport({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
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

    final htmlContent = _buildFullHtml(name, gender, results, astro, muruganBase64, ganapathyBase64);
    printHtmlWeb(htmlContent);
  }

  static Future<Uint8List> generate({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
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

    final htmlContent = _buildFullHtml(name, gender, results, astro, muruganBase64, ganapathyBase64);
    
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

  static String _buildFullHtml(String name, String gender, Map<dynamic, dynamic> results, Map<String, dynamic> astro, String muruganBase64, String ganapathyBase64) {
    final birthDt = results['birth_dt'] as DateTime?;
    final dateStr = birthDt != null ? DateFormat('dd-MM-yyyy').format(birthDt) : "-";
    final timeStr = birthDt != null ? DateFormat('hh:mm:ss a').format(birthDt) : "-";
    final place = results['place'] ?? "-";
    final lat = results['lat']?.toString() ?? "-";
    final lon = results['lon']?.toString() ?? "-";
    final ayanamsa = results['ayanamsa'] ?? "24° 12' 51\" (KP-Newcomb)";
    final prasannaNo = results['prasannam_no'] ?? "-";
    
    String shopName = astro['shop_name'] ?? "ஆதிகுரு ஜோதிட வித்யாலயம்";
    String astroName = astro['astrologer_name'] ?? "Dr. Karunagaran";
    String address = astro['address'] ?? "சென்னை";
    String phone = astro['phone'] ?? "9800666225";
    final nowStr = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());

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
    for (var sign in KPService.SIGNS) rasiMap[sign] = [];
    final planetDetails = results['planet_details'] as Map<dynamic, dynamic>? ?? {};
    planetDetails.forEach((key, pVal) {
      if (key == 'uranus' || key == 'neptune' || key == 'pluto') return;
      final lords = pVal['lords'];
      if (lords != null && lords['sign'] != null) {
        String sign = lords['sign'];
        double lonDeg = (pVal['longitude'] ?? 0.0) % 30;
        int d = lonDeg.floor();
        int m = ((lonDeg - d) * 60).floor();
        String pName = _toTamil(key.toString());
        if (key == 'lagna') pName = "லக்";
        if (rasiMap.containsKey(sign)) {
          rasiMap[sign]!.add("$pName $d° $m'");
        }
      }
    });
    
    final cusps = results['pavagam'] as Map<dynamic, dynamic>? ?? {};
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
      }
    });

    String renderCell(String sign) {
        final items = rasiMap[sign] ?? [];
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
            pHtml += "<div style='color:black; font-weight:bold;'>$p</div>";
        }
        return bHtml + pHtml;
    }

    // Significators
    final sigs = results['significators'] as Map<dynamic, dynamic>?;
    String sigHtml = "";
    String houseSigHtml = "";
    if (sigs != null) {
        final pView = sigs['planet_view'] as Map<dynamic, dynamic>? ?? {};
        const pKeys = ["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu", "ketu"];
        for (var k in pKeys) {
            final sig = pView[k] ?? {'A': '-', 'B': '-', 'C': '-', 'D': '-'};
            final a = sig['A'].toString() == '[]' ? '-' : sig['A'].toString().replaceAll('[', '').replaceAll(']', '');
            final b = sig['B'].toString() == '[]' ? '-' : sig['B'].toString().replaceAll('[', '').replaceAll(']', '');
            final c = sig['C'].toString() == '[]' ? '-' : sig['C'].toString().replaceAll('[', '').replaceAll(']', '');
            final d = sig['D'].toString() == '[]' ? '-' : sig['D'].toString().replaceAll('[', '').replaceAll(']', '');
            
            // Nak Lord and Sub Lord
            String nakLord = "-"; String subLord = "-";
            if (planetDetails[k] != null && planetDetails[k]['lords'] != null) {
                nakLord = _toTamil(planetDetails[k]['lords']['nakLord'] ?? "");
                subLord = _toTamil(planetDetails[k]['lords']['subLord'] ?? "");
            }
            sigHtml += "<tr><td>${_toTamil(k)}</td><td>$nakLord($b)</td><td>$subLord($a)</td><td>$a, $b, $c, $d</td></tr>";
        }
        
        final hView = sigs['house_view'] as Map<dynamic, dynamic>? ?? {};
        for (int i = 1; i <= 12; i++) {
            final sig = hView[i] ?? {'A': [], 'B': [], 'C': [], 'D': []};
            final a = (sig['A'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final b = (sig['B'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final c = (sig['C'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final d = (sig['D'] as List).map((e) => _toTamil(e.toString())).join(', ');
            
            // House Lords
            String hNakLord = "-"; String hSubLord = "-";
            if (cusps[i.toString()] != null && cusps[i.toString()]['lords'] != null) {
                hNakLord = _toTamil(cusps[i.toString()]['lords']['nakLord'] ?? "");
                hSubLord = _toTamil(cusps[i.toString()]['lords']['subLord'] ?? "");
            }
            
            houseSigHtml += "<tr><td>$i</td><td>$hSubLord($a)</td><td>$hNakLord($b)</td><td>$hSubLord($c)</td><td>$a, $b, $c, $d</td></tr>";
        }
    }

    // 12 House Table
    String bhavaHtml = "";
    for (int i = 1; i <= 12; i++) {
        String signLord = "-"; String nakLord = "-"; String subLord = "-";
        if (cusps[i.toString()] != null && cusps[i.toString()]['lords'] != null) {
            signLord = _toTamil(cusps[i.toString()]['lords']['signLord'] ?? "");
            nakLord = _toTamil(cusps[i.toString()]['lords']['nakLord'] ?? "");
            subLord = _toTamil(cusps[i.toString()]['lords']['subLord'] ?? "");
        }
        bhavaHtml += "<tr><td>$i</td><td>$signLord</td><td>$nakLord</td><td>$subLord</td></tr>";
    }

    // 9 Planet Table
    String pTableHtml = "";
    const keys9 = ["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn", "rahu", "ketu"];
    for (var k in keys9) {
        String signLord = "-"; String nakLord = "-"; String subLord = "-";
        if (planetDetails[k] != null && planetDetails[k]['lords'] != null) {
            signLord = _toTamil(planetDetails[k]['lords']['signLord'] ?? "");
            nakLord = _toTamil(planetDetails[k]['lords']['nakLord'] ?? "");
            subLord = _toTamil(planetDetails[k]['lords']['subLord'] ?? "");
        }
        pTableHtml += "<tr><td>${_toTamil(k)}</td><td>$signLord</td><td>$nakLord</td><td>$subLord</td></tr>";
    }

    // Dasa
    String dasaBal = "-";
    String dasaCur = "-";
    if (results['dasa_balance'] != null) {
        final bal = results['dasa_balance'];
        dasaBal = "${bal['y']} வ ${bal['m']} மா ${bal['d']} நா";
    }
    if (results['dasa'] != null) {
        final now = DateTime.now();
        for (var d in results['dasa']) {
            if (now.isAfter(d['start']) && now.isBefore(d['end'])) {
                dasaCur = "${_toTamil(d['planet'])} திசை";
                for (var b in d['subPeriods']) {
                    if (now.isAfter(b['start']) && now.isBefore(b['end'])) {
                        dasaCur += ", ${_toTamil(b['planet'])} புக்தி";
                        for (var a in b['subPeriods']) {
                            if (now.isAfter(a['start']) && now.isBefore(a['end'])) {
                                dasaCur += ", ${_toTamil(a['planet'])} அந்தரம்";
                            }
                        }
                    }
                }
            }
        }
    }

    return \'\'\'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Tiro+Tamil:ital@0;1&display=swap');
        :root {
            --primary: #5D1204;
            --border-orange: #E65100;
            --text-red: #D32F2F;
        }
        body { 
            font-family: 'Tiro Tamil', Arial, sans-serif; 
            margin: 0; padding: 3mm; 
            font-size: 2.8mm; 
            color: #000;
            line-height: 1.1;
            width: 210mm;
            height: 297mm;
            box-sizing: border-box;
        }
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 0.5mm solid var(--border-orange); padding-bottom: 1mm; margin-bottom: 1mm; }
        .header-title { font-size: 4.5mm; font-weight: bold; color: var(--primary); }
        .header-sub { font-size: 2.8mm; color: #555; white-space: pre-line; margin-top: 1mm; }
        
        .top-info { display: flex; justify-content: space-between; font-size: 2.8mm; margin-bottom: 1mm; border-bottom: 0.2mm solid #ccc; padding-bottom: 1mm; color: var(--primary); font-weight: bold; }
        
        .main-grid { display: grid; grid-template-columns: 85mm 1fr; gap: 2mm; margin-bottom: 1mm; }
        
        .chart-box { border: 0.3mm solid var(--border-orange); border-collapse: collapse; width: 100%; height: 75mm; text-align: left; vertical-align: top; font-size: 2.5mm; }
        .chart-box td { border: 0.3mm solid var(--border-orange); width: 25%; height: 25%; position: relative; padding: 0.5mm; vertical-align: top; }
        .chart-center { font-size: 3.5mm !important; font-weight: bold; color: var(--primary); padding: 2mm !important; vertical-align: top !important; }
        
        .info-table { width: 100%; font-size: 2.8mm; margin-top: 1mm; border-collapse: collapse; }
        .info-table td { padding: 0.5mm 0; }
        .info-label { color: var(--primary); font-weight: bold; width: 35%; }
        
        .tables-row { display: grid; grid-template-columns: 1fr 1fr; gap: 2mm; }
        .data-table { width: 100%; border-collapse: collapse; font-size: 2.5mm; border: 0.3mm solid var(--border-orange); }
        .data-table th { background: #eee; color: var(--primary); border: 0.3mm solid var(--border-orange); padding: 0.5mm; font-weight: normal; }
        .data-table td { border: 0.3mm solid var(--border-orange); padding: 0.5mm; text-align: center; }
        
        .ruling-planets { border: 0.3mm solid var(--border-orange); padding: 1mm; margin-bottom: 2mm; text-align: center; font-size: 2.5mm; background: #eee;}
        .ruling-title { color: var(--text-red); font-weight: bold; font-size: 2.8mm; margin-bottom: 0.5mm; }
        
        .sig-table { width: 100%; border-collapse: collapse; font-size: 2.5mm; border: 0.3mm solid var(--border-orange); margin-top: 1mm; }
        .sig-table th { background: #eee; color: var(--primary); border: 0.3mm solid var(--border-orange); padding: 0.5mm; font-weight: normal;}
        .sig-table td { border: 0.3mm solid var(--border-orange); padding: 0.5mm; text-align: center; }
        
        .footer { text-align: center; font-size: 2.5mm; margin-top: 2mm; font-style: italic; border-top: 0.3mm dashed #ccc; padding-top: 1mm; }
    </style>
</head>
<body>
    <div class="header">
        <div style="flex: 0 0 auto;">
            \${ganapathyBase64.isNotEmpty ? '<img src="data:image/png;base64,$ganapathyBase64" style="height: 15mm; width: 12mm; object-fit: contain;" />' : ''}
        </div>
        <div style="flex: 1; text-align: center;">
            <div class="header-title">$shopName</div>
            <div class="header-sub">$astroName<br>$address</div>
            <div style="color: var(--text-red); font-size: 2.5mm; margin-top: 1mm;">$phone | $nowStr</div>
        </div>
        <div style="flex: 0 0 auto;">
            \${muruganBase64.isNotEmpty ? '<img src="data:image/png;base64,$muruganBase64" style="height: 15mm; width: 15mm; object-fit: contain;" />' : ''}
        </div>
    </div>
    
    <div class="top-info">
        <div>பாலினம்: $gender</div>
        <div>பிரசன்ன எண்: $prasannaNo</div>
        <div>கேள்வி: Home sale</div>
    </div>
    <div class="top-info" style="border:none; margin-bottom:2mm;">
        <div>அளித்த நேரம்: $timeStr</div>
        <div>நட்சத்திரம்: $rulingMoonStar</div>
        <div>லக்னம்: $rulingLagna</div>
    </div>
    
    <div class="main-grid">
        <!-- Left Side: Rasi and Info -->
        <div>
            <!-- Rasi Chart -->
            <table class="chart-box">
                <tr>
                    <td>\${renderCell('Pisces')}</td>
                    <td>\${renderCell('Aries')}</td>
                    <td>\${renderCell('Taurus')}</td>
                    <td>\${renderCell('Gemini')}</td>
                </tr>
                <tr>
                    <td>\${renderCell('Aquarius')}</td>
                    <td colspan="2" rowspan="2" class="chart-center">
                        <table class="info-table">
                            <tr><td class="info-label">தேதி</td><td>: <span style="color:var(--text-red)">$dateStr</span></td></tr>
                            <tr><td class="info-label">நேரம்</td><td>: $timeStr</td></tr>
                            <tr><td class="info-label">இடம்</td><td>: $place</td></tr>
                            <tr><td class="info-label">ரேகாம்சம்</td><td>: $lon E</td></tr>
                            <tr><td class="info-label">அட்சாம்சம்</td><td>: $lat N</td></tr>
                            <tr><td class="info-label">அயனாம்சம்</td><td>: <span style="color:var(--text-red)">$ayanamsa</span></td></tr>
                            <tr><td class="info-label">பிரசன்ன எண்</td><td>: <span style="color:var(--primary); font-weight:bold;">$prasannaNo</span></td></tr>
                        </table>
                    </td>
                    <td>\${renderCell('Cancer')}</td>
                </tr>
                <tr>
                    <td>\${renderCell('Capricorn')}</td>
                    <td>\${renderCell('Leo')}</td>
                </tr>
                <tr>
                    <td>\${renderCell('Sagittarius')}</td>
                    <td>\${renderCell('Scorpio')}</td>
                    <td>\${renderCell('Libra')}</td>
                    <td>\${renderCell('Virgo')}</td>
                </tr>
            </table>
        </div>
        
        <!-- Right Side: Data -->
        <div>
            <div class="ruling-planets">
                <div class="ruling-title">ஆளும் கிரகங்கள் &nbsp;&nbsp;&nbsp;&nbsp; $dateStr $timeStr</div>
                <div style="display:flex; justify-content:space-between; margin-top:1mm;">
                    <span style="font-weight:bold;">நாள் அதிபதி: $rulingDay</span>
                    <table style="width:70%; font-size:2.5mm; border-collapse:collapse; text-align:left;">
                        <tr style="border-bottom:0.2mm solid #ccc;"><th>கிரகம்</th><th>ரா.அ</th><th>ந.அ</th><th>உ.அ</th><th>உ.உ.அ</th></tr>
                        <tr><td>லக்னம்</td><td>$rulingLagna</td><td>$rulingLagnaStar</td><td>-</td><td>-</td></tr>
                        <tr><td>சந்திரன்</td><td>$rulingMoon</td><td>$rulingMoonStar</td><td>-</td><td>-</td></tr>
                    </table>
                </div>
            </div>
            
            <div class="tables-row">
                <table class="data-table">
                    <tr><th colspan="4" style="font-weight:bold;">12 பாவ நிலைகள்</th></tr>
                    <tr><th>பா</th><th>ந.அ</th><th>உ.அ</th><th>உ.உ</th></tr>
                    $bhavaHtml
                </table>
                <table class="data-table">
                    <tr><th colspan="4" style="font-weight:bold;">9 கிரக நிலைகள்</th></tr>
                    <tr><th>கிரகம்</th><th>ந.அ</th><th>உ.அ</th><th>உ.உ</th></tr>
                    $pTableHtml
                </table>
            </div>
            
            <div style="margin-top: 2mm; font-size: 2.8mm; text-align:right;">
                <b>தசா இருப்பு :</b> $dasaBal <br>
                <b>தசா நடப்பு :</b> <span style="color:var(--text-red)">$dasaCur</span>
            </div>
        </div>
    </div>
    
    <div style="color: green; font-weight: bold; font-size: 3.2mm; text-align: center; margin-top: 2mm;">
        கிரக தொடர்புகள் (மதி என்ற தசா, புத்திகளுக்கு)
    </div>
    <table class="sig-table" style="background:#eee;">
        <tr>
            <th>கிரகம்</th>
            <th>நட். அதிபதி</th>
            <th>உப. அதிபதி</th>
            <th>தொடர்புகள்</th>
        </tr>
        $sigHtml
    </table>
    
    <div style="color: blue; font-weight: bold; font-size: 3.2mm; text-align: center; margin-top: 2mm;">
        பாவ தொடர்புகள் (விதி என்ற கொடுப்பினைகளுக்கு)
    </div>
    <table class="sig-table" style="background:#eee;">
        <tr>
            <th>பா</th>
            <th>(அ) பாவ உ.அ</th>
            <th>(அ) வின் ந.அ</th>
            <th>(அ) வின் உ.அ</th>
            <th>தொடர்புகள்</th>
        </tr>
        $houseSigHtml
    </table>
    
    <div class="footer">
        Astrologer: $astroName, $address, Cell: $phone
    </div>
</body>
</html>
\u0027\u0027\u0027;
  }
}
'''

with open(r'c:\Users\abina\ASTROLOGY-APP\AADHIGURU\lib\services\kp_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
    f.write(code)
