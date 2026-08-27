import sys
import re

def main():
    with open('lib/services/jamakkol_one_page_pdf_service.dart', 'r', encoding='utf-8') as f:
        content = f.read()

    new_method = r'''
  static String _toTamil(String p) {
    if (p.isEmpty) return "-";
    final _tamilShort = {
      'sun': 'சூரி', 'moon': 'சந்', 'mars': 'செவ்', 'mercury': 'புத',
      'jupiter': 'குரு', 'venus': 'சுக்', 'saturn': 'சனி',
      'rahu': 'ரா', 'ketu': 'கே', 'lagna': 'லக்'
    };
    for (var entry in KPService.TAMIL_PLANETS.entries) {
      if (entry.value == p || entry.key == p) {
        return _tamilShort[entry.key.toLowerCase()] ?? p;
      }
    }
    return _tamilShort[p.toLowerCase()] ?? p;
  }

  static String _formatDateOnly(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
  }

  static String _buildTimelineHtml(String title, List<dynamic> periods, String suffix, Map<String, dynamic>? selectedItem) {
    if (periods.isEmpty) return "<div style='flex: 1; text-align: center; border: 0.3mm solid var(--border-orange); border-radius: 1mm; padding: 2mm;'>$title விபரங்கள் இல்லை</div>";

    final displayList = selectedItem != null ? [selectedItem] : periods;
    
    String tableHtml = "<table style='width: 100%; border-collapse: collapse; font-size: 2.2mm;'>";
    tableHtml += "<tr style='background: var(--header-blue); color: white;'><th style='padding: 1mm;'>அதிபதி</th><th style='padding: 1mm;'>ஆரம்பம்</th><th style='padding: 1mm;'>முடிவு</th></tr>";
    
    for (var p in displayList) {
      final isToday = selectedItem == null && DateTime.now().isAfter(p['start']) && DateTime.now().isBefore(p['end']);
      final bg = isToday ? "background: rgba(181, 141, 61, 0.2); font-weight: bold;" : "";
      
      tableHtml += "<tr style='$bg text-align: center; border-bottom: 0.3mm solid var(--border-orange);'>";
      tableHtml += "<td style='padding: 1mm; border: 0.3mm solid var(--border-orange);'>${_toTamil(p['lord'] ?? "-")}</td>";
      tableHtml += "<td style='padding: 1mm; border: 0.3mm solid var(--border-orange);'>${_formatDateOnly(p['start'])}</td>";
      tableHtml += "<td style='padding: 1mm; border: 0.3mm solid var(--border-orange);'>${_formatDateOnly(p['end'])}</td>";
      tableHtml += "</tr>";
    }
    tableHtml += "</table>";

    return """
    <div style='flex: 1; border: 0.5mm solid var(--border-orange); border-radius: 1.5mm; overflow: hidden; margin: 0 1mm;'>
      <div style='background: #eee; color: var(--text-red); font-weight: bold; text-align: center; padding: 1mm; font-size: 2.5mm; border-bottom: 0.5mm solid var(--border-orange);'>$title</div>
      $tableHtml
    </div>
    """;
  }

  static Map<String, String> _getStarPada(double deg) {
    String star = KPService.NAKSHATRAS[(deg / (360/27)).floor() % 27];
    int pada = ((deg % (360/27)) / (360/108)).floor() + 1;
    return {'star': star, 'pada': pada.toString()};
  }

  static String _buildFullHtml(String name, String gender, Map<dynamic, dynamic> results, DateTime inputTime, String place, double lat, double lon, bool isAltNaming, Map<String, dynamic> astro, String muruganBase64, String ganapathyBase64) {
    final dateStr = DateFormat('dd . MM . yyyy').format(inputTime);
    final timeStr = DateFormat('hh:mm:ss a').format(inputTime);
    
    String shopName = astro['shop_name'] ?? astro['name'] ?? "ஆதிகுரு ஜோதிட வித்யாலயம்";
    String astroName = astro['astrologer_name'] ?? (astro['name'] != null ? "" : "Dr. Karunagaran");
    String address = astro['address'] ?? "சென்னை";
    String phone = astro['phone'] ?? "9800666225";
    final nowStr = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    final outer = results['outer'] as Map<dynamic, dynamic>? ?? {};
    final inner = results['inner'] as Map<dynamic, dynamic>? ?? {};
    final udayamIdx = results['udayam_idx'] ?? 0;
    final arudamIdx = results['arudam_idx'] ?? 0;
    final kaviIdx = results['kavi_idx'] ?? 0;

    final pan = inner['panchangam'] ?? {};
    final details = inner['planet_details'] ?? {};
    final moonDetails = details['moon'] ?? details['Moon'] ?? {};
    final nakshatraStr = moonDetails['nakshatra']?.toString() ?? pan['nakshatra']?.toString() ?? "-";
    final padaStr = moonDetails['pada']?.toString() ?? "-";
    final weekdayStr = pan['vara']?.toString() ?? KPService.VARA_TAMIL[inputTime.weekday % 7] ?? "-";
    
    String age = "-"; // Age can be calculated if birth time is available, else leave blank.
    
    final tamilYear = pan['tamil_year']?.toString() ?? "-";
    final tamilMonth = pan['tamil_month']?.toString() ?? "-";
    final tamilDate = pan['tamil_date']?.toString() ?? "-";
    final thithiStr = pan['tithi']?.toString() ?? "-";
    final pakshamStr = pan['paksham']?.toString() ?? "-";
    final rasiStr = KPService.TAMIL_SIGNS[moonDetails['lords']?['sign']] ?? KPService.TAMIL_SIGNS[moonDetails['rasi']] ?? moonDetails['rasi'] ?? pan['rasi'] ?? "-";
    final suniyaStr = pan['suniya_rasi']?.toString() ?? "-";

    final ayanamsa = inner['ayanamsa'] ?? "24° 12' 51\" (KP-Newcomb)";
    final prasannaNo = results['prasannam_no'] ?? "-";

    // Chart Gen
    Map<String, List<String>> rasiMap = {};
    for (var sign in KPService.SIGNS) rasiMap[sign] = [];
    
    // Inner Planets
    details.forEach((pKey, pVal) {
      String sign = pVal['rasi'];
      double pLon = (pVal['longitude'] ?? 0.0) % 30;
      int d = pLon.floor();
      int m = ((pLon - d) * 60).floor();
      
      if (pKey == 'lagna') {
        String jUdayamSign = KPService.SIGNS[udayamIdx % 12];
        double jUdayamDeg = (outer['udayam_abs_deg'] ?? 0.0) % 30;
        int jd = jUdayamDeg.floor();
        int jm = ((jUdayamDeg - jd) * 60).floor();
        if (rasiMap.containsKey(jUdayamSign)) rasiMap[jUdayamSign]?.add("<span style='color:green; font-weight:bold'>உத $jd° $jm'</span>");
      } else {
        String k = pKey.toString();
        String pName = KPService.TAMIL_PLANET_SHORT[k[0].toUpperCase() + k.substring(1)] ?? k;
        if (k == 'sun') pName = 'சூ';
        if (k == 'moon') pName = 'சந்';
        if (rasiMap.containsKey(sign)) rasiMap[sign]!.add("$pName $d° $m'");
      }
    });

    double aDeg = (outer['arudam_abs_deg'] ?? 0.0).toDouble();
    int aD = aDeg.floor();
    int aM = ((aDeg - aD) * 60).floor();
    if (rasiMap.containsKey(KPService.SIGNS[arudamIdx % 12])) {
        rasiMap[KPService.SIGNS[arudamIdx % 12]]?.add("<span style='color:red; font-weight:bold'>ஆரூ $aD° $aM'</span>");
    }
    if (rasiMap.containsKey(KPService.SIGNS[kaviIdx % 12])) {
        rasiMap[KPService.SIGNS[kaviIdx % 12]]?.add("<span style='color:purple; font-weight:bold'>கவி</span>");
    }

    String renderOuterLabel(String sign) {
        final namingMap = isAltNaming ? JamakkolService.JAMAKKOL_TAMIL_ALT : JamakkolService.JAMAKKOL_TAMIL_SHORT;
        final pDegs = outer['planet_degrees'] as Map? ?? {};
        List<String> items = [];
        
        for (var pName in JamakkolService.JAMAKKOL_PLANETS) {
            double deg = (pDegs[pName] ?? 0.0).toDouble();
            String pSign = KPService.SIGNS[(deg / 30).floor() % 12];
            if (pSign == sign) {
                double lon = deg % 30;
                int d = lon.floor();
                int m = ((lon - d) * 60).floor();
                items.add("<span style='color:var(--text-green); font-weight:bold; font-size:2mm;'>${namingMap[pName] ?? pName} $d° $m'</span>");
            }
        }
        return items.join('<br>');
    }

    String r(String sign) {
        final innerItems = rasiMap[sign] ?? [];
        String innerHtml = innerItems.join('<br>');
        String outerHtml = renderOuterLabel(sign);
        return """
        <div style='position: relative; height: 100%; width: 100%;'>
            <div style='position: absolute; top: 0; left: 0; padding: 1mm; text-align: left;'>$outerHtml</div>
            <div style='position: absolute; bottom: 0; right: 0; padding: 1mm; text-align: right;'>$innerHtml</div>
        </div>
        """;
    }

    // Pathasaram Tables
    String outerPathaHtml = "";
    double uDeg = outer['udayam_abs_deg'] ?? 0.0;
    double aDegPatha = outer['arudam_abs_deg'] ?? 0.0;
    double kDeg = (30.0 - (aDegPatha % 30.0)) + (kaviIdx * 30.0);
    kDeg = (kDeg % 360.0 + 360.0) % 360.0;

    void addOuterRow(String name, double deg) {
      int d = deg.floor();
      int m = ((deg - d) * 60).floor();
      var sp = _getStarPada(deg);
      outerPathaHtml += "<tr><td>$name</td><td>$d° $m'</td><td>${sp['star']}</td><td>${sp['pada']}</td></tr>";
    }
    addOuterRow("உதயம்", uDeg);
    addOuterRow("ஆரூடம்", aDegPatha);
    addOuterRow("கவிப்பு", kDeg);
    final pDegs = outer['planet_degrees'] as Map? ?? {};
    final namingMap = isAltNaming ? JamakkolService.JAMAKKOL_TAMIL_ALT : JamakkolService.JAMAKKOL_TAMIL_SHORT;
    for (var pName in JamakkolService.JAMAKKOL_PLANETS) {
      double deg = (pDegs[pName] ?? 0.0).toDouble();
      addOuterRow(namingMap[pName] ?? pName, deg);
    }

    String innerPathaHtml = "";
    final keys = ['lagna', 'sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 'saturn', 'rahu', 'ketu'];
    for (var key in keys) {
      if (!details.containsKey(key)) continue;
      double deg = (details[key]['longitude'] ?? 0.0).toDouble();
      String nameKey = key[0].toUpperCase() + key.substring(1);
      String name = KPService.TAMIL_PLANETS[nameKey] ?? nameKey;
      if (key == 'lagna') name = 'லக்னம்';
      int d = deg.floor();
      int m = ((deg - d) * 60).floor();
      var sp = _getStarPada(deg);
      innerPathaHtml += "<tr><td>$name</td><td>$d° $m'</td><td>${sp['star']}</td><td>${sp['pada']}</td></tr>";
    }

    // Dasa
    final dasaList = inner['dasa'] as List<dynamic>? ?? [];
    Map<String, dynamic>? currentDasa;
    Map<String, dynamic>? currentBukthi;
    List<dynamic> bukthiList = [];
    List<dynamic> antharamList = [];

    if (dasaList.isNotEmpty) {
      final now = DateTime.now();
      for (var d in dasaList) {
        if (now.isAfter(d['start']) && now.isBefore(d['end'])) {
          currentDasa = d;
          bukthiList = d['subPeriods'] ?? [];
          for (var b in bukthiList) {
            if (now.isAfter(b['start']) && now.isBefore(b['end'])) {
              currentBukthi = b;
              antharamList = b['subPeriods'] ?? [];
              break;
            }
          }
          break;
        }
      }
    }

    return """
    <!DOCTYPE html>
    <html lang="ta">
    <head>
      <meta charset="utf-8"/>
      <title>Jamakkol - $name</title>
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
        
        .grid-chart { width: 100%; max-width: 130mm; margin: 0 auto 3mm auto; border-collapse: collapse; border: 0.5mm solid var(--text-red); table-layout: fixed; }
        .grid-chart td { border: 0.3mm solid var(--text-red); height: 26mm; text-align: center; font-size: 2.8mm; font-weight: bold; padding: 0; vertical-align: middle; background: #FAF6EE; }
        .chart-title { color: var(--text-red); font-size: 3.5mm; font-weight: bold; line-height: 1.2; margin-bottom: 1mm; }
        
        .patha-tables { display: flex; justify-content: space-between; margin-bottom: 3mm; }
        .data-table { width: 48%; border-collapse: collapse; font-size: 2.5mm; border: 0.3mm solid var(--border-orange); }
        .data-table th { background: #eee; color: var(--primary); border: 0.3mm solid var(--border-orange); padding: 1mm; font-weight: bold; color: var(--text-red); }
        .data-table td { border: 0.3mm solid var(--border-orange); padding: 1mm; text-align: center; }

        .timeline-row { display: flex; gap: 2mm; margin-top: 2mm; }
        
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
          <div class="banner">ஜாமக்கோள் பிரசன்னம் <span style="font-size: 12px; font-weight: normal; margin-left: 6px;"> </span></div>
          
          <div class="details-grid">
            <div>
              <div class="detail-row"><span class="detail-label">பெயர்</span>: <span style="color:var(--text-red)">$name</span></div>
              <div class="detail-row"><span class="detail-label">நட்சத்திரம்</span>: <span style="color:#333">$nakshatraStr - $padaStr பாதம்</span></div>
              <div class="detail-row"><span class="detail-label">இராசி</span>: <span style="color:#333">$rasiStr இராசி</span></div>
              <div class="detail-row"><span class="detail-label">கிழமை</span>: <span style="color:#333">$weekdayStr</span></div>
            </div>
            <div>
              <div class="detail-row"><span class="detail-label">தேதி</span>: <span style="color:var(--text-red)">$dateStr</span></div>
              <div class="detail-row"><span class="detail-label">தமிழ் தேதி</span>: <span style="color:#333">$tamilYear வருடம், $tamilMonth - $tamilDate</span></div>
              <div class="detail-row"><span class="detail-label">திதி</span>: <span style="color:#333">$thithiStr</span></div>
              <div class="detail-row"><span class="detail-label">பட்சம்</span>: <span style="color:#333">$pakshamStr</span></div>
              <div class="detail-row"><span class="detail-label">நேரம்</span>: <span style="color:#333">${timeStr}</span></div>
              <div class="detail-row"><span class="detail-label">இடம்</span>: <span style="color:#333">${place}</span></div>
            </div>
          </div>

          <table class="grid-chart">
              <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
              <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center;"><div class="chart-title">ஜாமக்கோள்<br>பிரசன்னம் கட்டம்</div></td><td>${r('Cancer')}</td></tr>
              <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
              <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
          </table>
          
          <div style="color:var(--text-red); font-weight:bold; text-align:center; font-size: 3.5mm; margin-bottom:1.5mm;">பாதசாரம் (கிரகங்கள் மற்றும் முக்கிய புள்ளிகள்)</div>
          <div class="patha-tables">
              <table class="data-table">
                  <tr><th colspan="4">ஜாம கிரகங்கள் மற்றும் முக்கிய புள்ளிகள்</th></tr>
                  <tr><th>பெயர்</th><th>பாகை</th><th>நட்சத்திரம்</th><th>பாதம்</th></tr>
                  $outerPathaHtml
              </table>
              <table class="data-table">
                  <tr><th colspan="4">உள்வட்ட கிரகங்கள்</th></tr>
                  <tr><th>கிரகம்</th><th>பாகை</th><th>நட்சத்திரம்</th><th>பாதம்</th></tr>
                  $innerPathaHtml
              </table>
          </div>

          <div style="color:var(--text-red); font-weight:bold; text-align:center; font-size: 3.5mm; margin-bottom:1.5mm;">தசாபுக்தி விவரங்கள்</div>
          <div class="timeline-row">
            ${_buildTimelineHtml("தசைகள்", dasaList, "தசை", currentDasa)}
            ${_buildTimelineHtml("புத்திகள்", bukthiList, "புக்தி", currentBukthi)}
            ${_buildTimelineHtml("அந்தரம்", antharamList, "அந்தரம்", null)}
          </div>

          <div class="footer">Created by Aadhiguru Astrology Software</div>
        </div>
      </div>
    </body>
    </html>
    """;
  }
'''

    start_str = '  static String _buildFullHtml'
    start_idx = content.find(start_str)
    last_brace_idx = content.rfind('}')
    
    if start_idx != -1 and last_brace_idx != -1:
        new_content = content[:start_idx] + new_method + '\n}\n'
        with open('lib/services/jamakkol_one_page_pdf_service.dart', 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Updated jamakkol_one_page_pdf_service.dart successfully!")
    else:
        print("Failed to find boundaries")

if __name__ == '__main__':
    main()
