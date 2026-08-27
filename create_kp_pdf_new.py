import sys
import re

def main():
    with open('lib/services/kp_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    # The HTML string generation in _buildFullHtml
    # We want to replace everything from the beginning of _buildFullHtml up to `return """`
    
    # Actually, let's just generate the entire _buildFullHtml method text.
    # I will replace the entire method!

    new_method = r'''
  static String _buildFullHtml(String name, String gender, Map<dynamic, dynamic> results, Map<String, dynamic> astro, String muruganBase64, String ganapathyBase64) {
    final birthDt = results['birth_dt'] as DateTime?;
    final dateStr = birthDt != null ? DateFormat('dd . MM . yyyy').format(birthDt) : "-";
    final birthTime = birthDt != null ? DateFormat('hh:mm:ss a').format(birthDt) : "-";
    final timeStr = birthTime;
    final place = results['place'] ?? "-";
    final lat = results['lat']?.toString() ?? "-";
    final lon = results['lon']?.toString() ?? "-";
    final ayanamsa = results['ayanamsa'] ?? "24° 12' 51\" (KP-Newcomb)";
    final prasannaNo = results['prasannam_no'] ?? "-";
    
    String shopName = astro['shop_name'] ?? astro['name'] ?? "ஆதிகுரு ஜோதிட வித்யாலயம்";
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
        final lordTamil = KPService.TAMIL_PLANETS[firstDasa['lord']] ?? firstDasa['lord'] ?? "-";
        dasaBalance = "$lordTamil - $years வரு, $months மா, $days நா";
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
        String pName = _toTamil(key.toString());
        if (key == 'lagna') pName = "லக்";
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
              String pName = _toTamil(key.toString());
              if (key == 'lagna') pName = "லக்";
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
    if (sigs != null && sigs['planet_view'] != null) {
        final pView = sigs['planet_view'];
        final List<String> order = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu'];
        for (var k in order) {
            final sig = pView[k];
            if (sig == null) continue;
            String nakLord = "-"; String subLord = "-";
            if (planetDetails[k] != null && planetDetails[k]['lords'] != null) {
                nakLord = _toTamil(planetDetails[k]['lords']['nakLord'] ?? "");
                subLord = _toTamil(planetDetails[k]['lords']['subLord'] ?? "");
            }
            final a = (sig['A'] as String).split(',').where((e)=>e.isNotEmpty).join(', ');
            final b = (sig['B'] as String).split(',').where((e)=>e.isNotEmpty).join(', ');
            final c = (sig['C'] as String).split(',').where((e)=>e.isNotEmpty).join(', ');
            final d = (sig['D'] as String).split(',').where((e)=>e.isNotEmpty).join(', ');
            sigHtml += "<tr><td>${_toTamil(k)}</td><td>$nakLord($b)</td><td>$subLord($a)</td><td>$a, $b, $c, $d</td></tr>";
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
                hNakLord = _toTamil(cusps[i]['lords']['nakLord'] ?? "");
                hSubLord = _toTamil(cusps[i]['lords']['subLord'] ?? "");
            } else if (cusps[i.toString()] != null && cusps[i.toString()]['lords'] != null) {
                hNakLord = _toTamil(cusps[i.toString()]['lords']['nakLord'] ?? "");
                hSubLord = _toTamil(cusps[i.toString()]['lords']['subLord'] ?? "");
            }
            final a = (sig['A'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final b = (sig['B'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final c = (sig['C'] as List).map((e) => _toTamil(e.toString())).join(', ');
            final d = (sig['D'] as List).map((e) => _toTamil(e.toString())).join(', ');
            houseSigHtml += "<tr><td>$i</td><td>-($b)</td><td>-($a)</td><td>-($hNakLord)</td><td>$a, $b, $c, $d</td></tr>";
        }
    }
    
    String pTableHtml = "";
    final List<String> order = ['lagna', 'sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu'];
    for (int i = 1; i <= 12; i++) {
        final cD = cusps[i] ?? cusps[i.toString()];
        if (cD == null) continue;
        String signLord = "-"; String nakLord = "-"; String subLord = "-";
        if (cD['lords'] != null) {
            signLord = _toTamil(cD['lords']['signLord'] ?? "");
            nakLord = _toTamil(cD['lords']['nakLord'] ?? "");
            subLord = _toTamil(cD['lords']['subLord'] ?? "");
        }
        
        String pStr = "";
        if (i <= 10) {
            final k = order[i-1];
            if (planetDetails[k] != null && planetDetails[k]['lords'] != null) {
                String pSignLord = _toTamil(planetDetails[k]['lords']['signLord'] ?? "");
                String pNakLord = _toTamil(planetDetails[k]['lords']['nakLord'] ?? "");
                String pSubLord = _toTamil(planetDetails[k]['lords']['subLord'] ?? "");
                pStr = "<td>${_toTamil(k)}</td><td>$pSignLord</td><td>$pNakLord</td><td>$pSubLord</td>";
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
                dasaCur = "${_toTamil(d['lord'] ?? '')} திசை";
                for (var b in d['subPeriods']) {
                    if (now.isAfter(b['start']) && now.isBefore(b['end'])) {
                        dasaCur += ", ${_toTamil(b['lord'] ?? '')} புக்தி";
                        for (var a in b['subPeriods']) {
                            if (now.isAfter(a['start']) && now.isBefore(a['end'])) {
                                dasaCur += ", ${_toTamil(a['lord'] ?? '')} அந்தரம்";
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
      <title>Horoscope - $name</title>
      <style>
        :root { --border-orange: #E0D4BE; --header-blue: #5D1204; --text-red: #5D1204; --text-green: #B58D3D; }
        body { font-family: sans-serif; margin: 0; padding: 4mm; color: #333; font-size: 3mm; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
        @media screen {
          body { background: #f3f4f6; display: flex; flex-direction: column; align-items: center; }
          .page { background: white; width: 210mm; min-height: 297mm; padding: 5mm; box-shadow: 0 0 3mm rgba(0,0,0,0.1); margin: 5mm 0; position: relative; box-sizing: border-box; }
          .inner-page { border: 0.5mm solid var(--text-red); padding: 3mm; min-height: 285mm; box-sizing: border-box; }
        }
        @media print {
          @page { size: A4; margin: 5mm; }
          body { background: white; padding: 0; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
          .page { width: 100%; padding: 0; box-shadow: none; margin: 0; box-sizing: border-box; height: 287mm; }
          .inner-page { border: 0.5mm solid var(--text-red); padding: 3mm; box-sizing: border-box; height: 100%; }
        }
        .header { border-bottom: 0.5mm solid var(--text-red); margin-bottom: 2mm; padding-bottom: 1.5mm; }
        .header-top { display: flex; justify-content: space-between; }
        .header-title { color: var(--text-red); font-weight: bold; font-size: 5.5mm; line-height: 1.2; }
        .header-sub { font-size: 2.8mm; color: #555; line-height: 1.3; }
        .banner { background: var(--text-red); color: white; text-align: center; padding: 1mm; font-weight: bold; font-size: 4.5mm; margin: 1mm 0; border-radius: 1mm; }
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 3mm; margin-bottom: 2mm; border-bottom: 0.3mm solid #eee; padding-bottom: 1.5mm; }
        .detail-row { display: flex; margin-bottom: 0.5mm; }
        .detail-label { width: 30mm; color: var(--text-red); font-weight: bold; }
        
        .top-charts-grid { display: grid; grid-template-columns: 1fr 1fr 1.3fr; gap: 2mm; margin-bottom: 2mm; }
        
        .grid-chart { width: 100%; border-collapse: collapse; border: 0.5mm solid var(--text-red); table-layout: fixed; }
        .grid-chart td { border: 0.3mm solid var(--text-red); height: 16mm; text-align: center; font-size: 2.5mm; font-weight: bold; padding: 0.5mm; vertical-align: middle; background: #FAF6EE; }
        .chart-title { color: var(--text-red); font-size: 3.2mm; font-weight: bold; line-height: 1.1; margin-bottom: 1mm; }
        
        .ruling-planets { border: 0.3mm solid var(--border-orange); padding: 1mm; text-align: center; font-size: 2.5mm; background: #eee; margin-bottom: 1mm;}
        .ruling-title { color: var(--text-red); font-weight: bold; font-size: 2.8mm; margin-bottom: 0.5mm; }
        
        .data-table { width: 100%; border-collapse: collapse; font-size: 2.2mm; border: 0.3mm solid var(--border-orange); }
        .data-table th { background: #eee; color: var(--primary); border: 0.3mm solid var(--border-orange); padding: 0.5mm; font-weight: normal; }
        .data-table td { border: 0.3mm solid var(--border-orange); padding: 0.5mm; text-align: center; }

        .sig-table { width: 100%; border-collapse: collapse; font-size: 2.4mm; border: 0.3mm solid var(--border-orange); margin-top: 1mm; }
        .sig-table th { background: #eee; color: var(--primary); border: 0.3mm solid var(--border-orange); padding: 0.5mm; font-weight: normal;}
        .sig-table td { border: 0.3mm solid var(--border-orange); padding: 0.5mm; text-align: center; }
        
        .footer { text-align: center; font-size: 2.5mm; margin-top: 2mm; font-style: italic; border-top: 0.3mm dashed #ccc; padding-top: 1mm; }
      </style>
    </head>
    <body>
      <div class="page">
        <div class="inner-page">
          <div class="header">
            <div class="header-top" style="display: flex; justify-content: space-between; align-items: center;">
              <div style="flex: 0 0 auto; text-align: left; margin-right: 15px;">
                 ${ganapathyBase64.isNotEmpty ? '<img src="data:image/png;base64,$ganapathyBase64" style="height: 19.5mm; width: 15.6mm; object-fit: contain;" alt="Ganapathy" />' : ''}
              </div>
              <div style="flex: 1; text-align: center; min-width: 0;">
                <div class="header-title">${shopName}</div>
                <div class="header-sub" style="white-space: pre-line; margin-top: 1mm;">$astroName<br>$address</div>
                <div style="color: var(--text-red); font-size: 2.8mm; margin-top: 1mm;">$phone | $nowStr</div>
              </div>
              <div style="flex: 0 0 auto; text-align: right; margin-left: 15px;">
                 ${muruganBase64.isNotEmpty ? '<img src="data:image/png;base64,$muruganBase64" style="height: 19.5mm; width: 18mm; object-fit: contain;" alt="Murugan" />' : ''}
              </div>
            </div>
          </div>
          <div class="banner">ஆதிகுரு ஜோதிட வித்யாலயம் <span style="font-size: 12px; font-weight: normal; margin-left: 6px;"> </span></div>
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
              <table class="grid-chart">
                  <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
                  <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">ராசி கட்டம்</div></td><td>${r('Cancer')}</td></tr>
                  <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
                  <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
              </table>
              <table class="grid-chart">
                  <tr><td>${b('Pisces')}</td><td>${b('Aries')}</td><td>${b('Taurus')}</td><td>${b('Gemini')}</td></tr>
                  <tr><td>${b('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">பாவக கட்டம்</div></td><td>${b('Cancer')}</td></tr>
                  <tr><td>${b('Capricorn')}</td><td>${b('Leo')}</td></tr>
                  <tr><td>${b('Sagittarius')}</td><td>${b('Scorpio')}</td><td>${b('Libra')}</td><td>${b('Virgo')}</td></tr>
              </table>
              <div>
                  <div class="ruling-planets">
                      <div class="ruling-title">ஆளும் கிரகங்கள் &nbsp;&nbsp;&nbsp;&nbsp; $dateStr $timeStr</div>
                      <table style="width:100%; text-align:left; font-size:2.2mm;">
                          <tr><td style="font-weight:bold;">நாள் அதிபதி</td><td>: $rulingDay</td><th style="color:var(--text-red);">கிரகம்</th><th style="color:var(--text-red);">ரா.அ</th><th style="color:var(--text-red);">ந-அ</th></tr>
                          <tr><td colspan="2"></td><td>லக்னம்</td><td>$rulingLagna</td><td>$rulingLagnaStar</td></tr>
                          <tr><td colspan="2"></td><td>சந்திரன்</td><td>$rulingMoon</td><td>$rulingMoonStar</td></tr>
                      </table>
                  </div>
                  <table class="data-table">
                      <tr><th colspan="4">12 பாவ நிலைகள்</th><th colspan="4" style="border-left:0.5mm solid var(--border-orange);">கிரக நிலைகள்</th></tr>
                      <tr>
                          <td>பா</td><td>ந.அ</td><td>உ.அ</td><td>உ.உ</td>
                          <td style="border-left:0.5mm solid var(--border-orange);">கிரகம்</td><td>ந.அ</td><td>உ.அ</td><td>உ.உ</td>
                      </tr>
                      $pTableHtml
                  </table>
              </div>
          </div>
          
          <div style="text-align:right; font-size: 2.5mm; font-weight:bold; color:var(--text-red); margin-bottom:1mm;">தசா நடப்பு : $dasaCur</div>
          <div style="color:var(--text-green); font-weight:bold; text-align:center; font-size: 3.5mm; margin-bottom:1mm;">கிரக தொடர்புகள் (மதி என்ற தசா, புத்திகளுக்கு)</div>
          <table class="sig-table">
              <tr>
                  <th style="width:10%">கிரகம்</th>
                  <th style="width:25%">நட். அதிபதி</th>
                  <th style="width:25%">உப. அதிபதி</th>
                  <th style="width:40%">தொடர்புகள்</th>
              </tr>
              $sigHtml
          </table>
          
          <div style="color:var(--text-green); font-weight:bold; text-align:center; font-size: 3.5mm; margin:2mm 0 1mm 0; color:blue;">பாவ தொடர்புகள் (விதி என்ற கொடுப்பினைகளுக்கு)</div>
          <table class="sig-table">
              <tr>
                  <th style="width:5%">பா</th>
                  <th style="width:20%">(அ) பாவ உ.அ</th>
                  <th style="width:20%">(அ) வின் ந.அ</th>
                  <th style="width:20%">(அ) வின் உ.அ</th>
                  <th style="width:35%">தொடர்புகள்</th>
              </tr>
              $houseSigHtml
          </table>

          <div class="footer">Created by Aadhiguru Astrology Software</div>
        </div>
      </div>
    </body>
    </html>
    """;
  }
'''

    # Find the start of _buildFullHtml
    start_str = '  static String _buildFullHtml'
    start_idx = content.find(start_str)
    
    # Find the end of the class
    last_brace_idx = content.rfind('}')
    
    if start_idx != -1 and last_brace_idx != -1:
        new_content = content[:start_idx] + new_method + '\n}\n'
        with open('lib/services/kp_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Successfully updated kp_one_page_pdf_service.dart")
    else:
        print("Failed to find boundaries")

if __name__ == '__main__':
    main()
