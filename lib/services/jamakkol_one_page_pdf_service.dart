import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'kp_service.dart';
import 'jamakkol_service.dart';
import 'settings_service.dart';
import 'pdf_helper_stub.dart' if (dart.library.html) 'pdf_helper_web.dart';
import 'package:astrology_flutter/l10n/app_localizations.dart';

class JamakkolOnePagePdfService {
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

    final htmlContent = _buildFullHtml(name, gender, results, inputTime, place, lat, lon, isAltNaming, astro, muruganBase64, ganapathyBase64, l10n);
    printHtmlWeb(htmlContent);
  }

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

    final htmlContent = _buildFullHtml(name, gender, results, inputTime, place, lat, lon, isAltNaming, astro, muruganBase64, ganapathyBase64, l10n);
    
    if (kIsWeb) {
      printHtmlWeb(htmlContent);
      return Uint8List(0);
    }
    
    final Directory tempDir = await getTemporaryDirectory();
    final File pdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(htmlContent, tempDir.path, "jamakkol_${DateTime.now().millisecondsSinceEpoch}");
    final Uint8List bytes = await pdfFile.readAsBytes();
    await pdfFile.delete();
    return bytes;
  }


  static String _toLocal(String p, String langCode) {
    if (p.isEmpty) return "-";
    final shortMap = langCode == 'en' ? JamakkolService.JAMAKKOL_ENGLISH_SHORT : (langCode == 'hi' ? JamakkolService.JAMAKKOL_HINDI_SHORT : JamakkolService.JAMAKKOL_TAMIL_SHORT);
    final fullMap = langCode == 'en' ? KPService.ENGLISH_PLANETS : (langCode == 'hi' ? KPService.HINDI_PLANETS : KPService.TAMIL_PLANETS);
    final kpShortMap = langCode == 'en' ? KPService.ENGLISH_PLANET_SHORT : (langCode == 'hi' ? KPService.HINDI_PLANET_SHORT : KPService.TAMIL_PLANET_SHORT);
    
    for (var entry in fullMap.entries) {
      if (entry.value == p || entry.key.toLowerCase() == p.toLowerCase()) {
        String key = entry.key;
        String capitalizedKey = key[0].toUpperCase() + key.substring(1);
        return shortMap[key] ?? shortMap[capitalizedKey] ?? kpShortMap[key] ?? kpShortMap[capitalizedKey] ?? fullMap[key] ?? p;
      }
    }
    
    String capitalizedP = p[0].toUpperCase() + p.substring(1);
    return shortMap[capitalizedP] ?? kpShortMap[capitalizedP] ?? fullMap[capitalizedP] ?? p;
  }

  static String _formatDateOnly(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
  }

  static String _buildTimelineHtml(String title, List<dynamic> periods, String suffix, Map<String, dynamic>? selectedItem, AppLocalizations l10n, DateTime inputTime) {
    if (periods.isEmpty) return "<div style='flex: 1; text-align: center; border: 0.3mm solid var(--border-orange); border-radius: 1mm; padding: 2mm;'>$title விபரங்கள் இல்லை</div>";

    List<dynamic> displayList = [];
    if (selectedItem != null) {
      int idx = periods.indexOf(selectedItem);
      if (idx != -1) {
        displayList = periods.sublist(idx).take(9).toList();
      } else {
        displayList = [selectedItem];
      }
    } else {
      displayList = periods.take(9).toList();
    }
    
    String tableHtml = "<table style='width: 100%; border-collapse: collapse; font-size: 2.2mm;'>";
    tableHtml += "<tr style='background: var(--header-blue); color: white;'><th style='padding: 1mm;'>அதிபதி</th><th style='padding: 1mm;'>ஆரம்பம்</th><th style='padding: 1mm;'>முடிவு</th></tr>";
    
    for (var p in displayList) {
      final isToday = p == selectedItem || (selectedItem == null && inputTime.compareTo(p['start']) >= 0 && inputTime.compareTo(p['end']) <= 0);
      final bg = isToday ? "background: rgba(181, 141, 61, 0.2); font-weight: bold;" : "";
      
      tableHtml += "<tr style='$bg text-align: center; border-bottom: 0.3mm solid var(--border-orange);'>";
      tableHtml += "<td style='padding: 1mm; border: 0.3mm solid var(--border-orange);'>${_toLocal(p['lord'] ?? "-", l10n.localeName)}</td>";
      tableHtml += "<td style='padding: 1mm; border: 0.3mm solid var(--border-orange);'>${_formatDateOnly(p['start'])}</td>";
      tableHtml += "<td style='padding: 1mm; border: 0.3mm solid var(--border-orange);'>${_formatDateOnly(p['end'])}</td>";
      tableHtml += "</tr>";
    }
    tableHtml += "</table>";

    return """
    <div style='flex: 1; border: 0.5mm solid var(--border-orange); border-radius: 1.5mm; overflow: hidden; margin: 0 1mm;'>
      <div style='background: #eee; color: var(--text-red); font-weight: bold; text-align: center; padding: 1mm; font-size: 2.0mm; border-bottom: 0.5mm solid var(--border-orange);'>$title</div>
      $tableHtml
    </div>
    """;
  }

  static Map<String, String> _getStarPada(double deg) {
    String star = KPService.NAKSHATRAS[(deg / (360/27)).floor() % 27];
    int pada = ((deg % (360/27)) / (360/108)).floor() + 1;
    return {'star': star, 'pada': pada.toString()};
  }

  static String _buildFullHtml(String name, String gender, Map<dynamic, dynamic> results, DateTime inputTime, String place, double lat, double lon, bool isAltNaming, Map<String, dynamic> astro, String muruganBase64, String ganapathyBase64, AppLocalizations l10n) {
    final dateStr = DateFormat('dd . MM . yyyy').format(inputTime);
    final timeStr = DateFormat('hh:mm:ss a').format(inputTime);
    
    String shopName = astro['shop_name'] ?? astro['name'] ?? "ஜிபி அஸ்ட்ரோ ஜோதிட வித்யாலயம்";
    String astroName = astro['astrologer_name'] ?? (astro['name'] != null ? "" : "Dr. Karunagaran");
    String address = astro['address'] ?? "சென்னை";
    String phone = astro['phone'] ?? "9800666225";
    final nowStr = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    final outer = results['outer'] as Map<dynamic, dynamic>? ?? {};
    final notes = results['notes'] as Map<dynamic, dynamic>? ?? {};
    final strength = results['strength'] as Map<dynamic, dynamic>? ?? {};
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

    final lagnaSign = KPService.TAMIL_SIGNS[details['lagna']?['rasi']] ?? "-";
    final udayamSign = KPService.TAMIL_SIGNS[KPService.SIGNS[udayamIdx % 12]] ?? "-";
    final arudamSign = KPService.TAMIL_SIGNS[KPService.SIGNS[arudamIdx % 12]] ?? "-";
    final kavippuSign = KPService.TAMIL_SIGNS[KPService.SIGNS[kaviIdx % 12]] ?? "-";

    DateTime parseTime(String timeStr, DateTime baseDate) {
      try {
        final parts = timeStr.split(' ');
        final hms = parts[0].split(':');
        int h = int.parse(hms[0]);
        int m = int.parse(hms[1]);
        int s = hms.length > 2 ? int.parse(hms[2]) : 0;
        if (parts[1] == "PM" && h < 12) h += 12;
        if (parts[1] == "AM" && h == 12) h = 0;
        return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m, s);
      } catch (e) {
        return baseDate;
      }
    }
    final sunrise = parseTime(pan['sunrise'] ?? "06:00 AM", inputTime);
    final sunset = parseTime(pan['sunset'] ?? "06:00 PM", inputTime);
    final segments = JamakkolService.calculateCurrentSegments(inputTime, sunrise, sunset, langCode: l10n.localeName);
    final gowriStr = segments['gowri'] ?? "-";

    final ayanamsa = inner['ayanamsa'] ?? "24° 12' 51\" (KP-Newcomb)";
    final prasannaNo = results['prasannam_no'] ?? "-";

    final isTa = l10n.localeName == 'ta';
    final isHi = l10n.localeName == 'hi';

    // Helper: Translate planet name
    String getPName(String name) {
      return KPService.TAMIL_PLANETS[name] ?? name;
    }
    
    // Helper: Translate rasi name
    String getRName(String name) {
      return KPService.TAMIL_SIGNS[name] ?? name;
    }

    // 1. Planet contacting Udayam
    final uContacts = notes['udayam_contact'] as List? ?? [];
    String uContactStr = "-";
    if (uContacts.isNotEmpty) {
      uContactStr = uContacts.map((c) {
        String p = getPName(c['planet']);
        double deg = c['deg'] % 30;
        int d = deg.floor();
        int m = ((deg - d) * 60).floor();
        String degStr = "${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
        return isTa 
            ? "$p\_$degStr / பாவம் ${c['house']} / ${c['lordship']}"
            : (isHi ? "$p\_$degStr / भाव ${c['house']} / ${c['lordship']}" : "$p\_$degStr / House ${c['house']} / ${c['lordship']}");
      }).join(", ");
    }

    // 2. Udayam star pada
    final uStar = notes['udayam_star'] as Map? ?? {};
    String uStarStr = "-";
    if (uStar.isNotEmpty) {
      double uDeg = uStar['deg'] % 30;
      int ud = uDeg.floor();
      int um = ((uDeg - ud) * 60).floor();
      uStarStr = "${ud.toString().padLeft(2, '0')}:${um.toString().padLeft(2, '0')} ${getRName(uStar['nakshatra'])} ${uStar['pada']} ${getPName(uStar['lord'])} ${uStar['lordship']}";
    }

    // 3. Crossed planet
    final crossed = notes['crossed_planet'] as Map?;
    String crossedStr = "-";
    if (crossed != null) {
      double cDeg = crossed['deg'] % 30;
      int cd = cDeg.floor();
      int cm = ((cDeg - cd) * 60).floor();
      String cDegStr = "${cd.toString().padLeft(2, '0')}:${cm.toString().padLeft(2, '0')}";
      crossedStr = "${getPName(crossed['planet'])} ${crossed['lordship']} = $cDegStr";
    }

    // 4. Arudam House
    final aHouse = notes['arudam_house_details'] as Map? ?? {};
    String aHouseStr = "-";
    if (aHouse.isNotEmpty) {
      double aDeg = aHouse['deg'] % 30;
      int ad = aDeg.floor();
      int am = ((aDeg - ad) * 60).floor();
      String aDegStr = "${ad.toString().padLeft(2, '0')}:${am.toString().padLeft(2, '0')}";
      aHouseStr = "${aHouse['house']} ${getPName(aHouse['lord'])} ${aHouse['lordship']} $aDegStr ${getRName(aHouse['nakshatra'])} ${aHouse['pada']}";
    }

    // 5. Planet contacting Arudam
    final aContact = notes['arudam_contact'] as Map?;
    String aContactStr = "-";
    if (aContact != null) {
      double acDeg = aContact['deg'] % 30;
      int acd = acDeg.floor();
      int acm = ((acDeg - acd) * 60).floor();
      String acDegStr = "${acd.toString().padLeft(2, '0')}:${acm.toString().padLeft(2, '0')}";
      aContactStr = "${getPName(aContact['planet'])}\_$acDegStr ${getRName(aContact['nakshatra'])} ${aContact['pada']}";
    }

    // 6. Kavippu House
    final kHouse = notes['kavi_house_details'] as Map? ?? {};
    String kHouseStr = "-";
    if (kHouse.isNotEmpty) {
      double kDeg = kHouse['deg'] % 30;
      int kd = kDeg.floor();
      int km = ((kDeg - kd) * 60).floor();
      String kDegStr = "${kd.toString().padLeft(2, '0')}:${km.toString().padLeft(2, '0')}";
      kHouseStr = "${kHouse['house']} $kDegStr ${getRName(kHouse['nakshatra'])} ${kHouse['pada']}";
    }

    // 7. Planet covered by Kavippu
    final kPlanet = notes['kavi_planet_details'] as Map?;
    String kPlanetStr = "-";
    if (kPlanet != null) {
      double kpDeg = kPlanet['deg'] % 30;
      int kpd = kpDeg.floor();
      int kpm = ((kpDeg - kpd) * 60).floor();
      String kpDegStr = "${kpd.toString().padLeft(2, '0')}:${kpm.toString().padLeft(2, '0')}";
      kPlanetStr = "${getPName(kPlanet['planet'])} - ${kPlanet['lordship']} = $kpDegStr ${getRName(kPlanet['nakshatra'])} ${kPlanet['pada']}";
    }

    // 8. Arudam Lord House
    String aLordHouseStr = (notes['arudam_lord_house'] ?? "-").toString();

    // 9. Arudam vs Udayam
    String aVsUStr = (notes['arudam_vs_udayam'] ?? "-").toString();

    // 10. Arudam vs Kavippu
    String aVsKStr = (notes['arudam_vs_kavi'] ?? "-").toString();

    // 11. 8th Lord
    final eLord = notes['eighth_lord_details'] as Map? ?? {};
    String eLordStr = "-";
    if (eLord.isNotEmpty) {
      eLordStr = isTa 
          ? "${getPName(eLord['lord'])} \_ ${eLord['house']}-ல்"
          : (isHi ? "${getPName(eLord['lord'])} \_ ${eLord['house']} वें भाव में" : "${getPName(eLord['lord'])} in House ${eLord['house']}");
    }

    // 12. Badhakadhipathi
    final bLord = notes['badhaka_lord_details'] as Map? ?? {};
    String bLordStr = "-";
    if (bLord.isNotEmpty) {
      String bTypeLabel = isTa
          ? (bLord['type_offset'] == 11 ? "சர ராசி 11" : (bLord['type_offset'] == 9 ? "ஸ்திர ராசி 9" : "உபய ராசி 7"))
          : (isHi ? (bLord['type_offset'] == 11 ? "चर राशि 11" : (bLord['type_offset'] == 9 ? "स्थिर राशि 9" : "द्विस्वभाव राशि 7")) : "Badhaka House ${bLord['type_offset']}");
      bLordStr = isTa
          ? "${getPName(bLord['lord'])} ($bTypeLabel) ${bLord['house']} \_ல்"
          : (isHi ? "${getPName(bLord['lord'])} ($bTypeLabel) ${bLord['house']} वें भाव में" : "${getPName(bLord['lord'])} ($bTypeLabel) in House ${bLord['house']}");
    }

    // 13. Parivarthanai
    final parivarthanas = notes['parivarthana'] as List? ?? [];
    String parivarthanaiStr = parivarthanas.isEmpty 
        ? (isTa ? "இல்லை" : (isHi ? "नहीं है" : "None"))
        : parivarthanas.map((p) {
            final parts = p.toString().split('-');
            return "${getPName(parts[0])} - ${getPName(parts[1])}";
          }).join(", ");

    // 14. Sootchuma Rasi
    final sootchuma = notes['sootchuma_details'] as Map? ?? {};
    String sootchumaStr = "-";
    if (sootchuma.isNotEmpty) {
      sootchumaStr = isTa
          ? "${getRName(sootchuma['rasi'])} (துல்லியமாக: ${getRName(sootchuma['pada_rasi'])} - ${getRName(sootchuma['pada_nakshatra'])} ${sootchuma['pada_num']})"
          : "${getRName(sootchuma['rasi'])} (Precise: ${getRName(sootchuma['pada_rasi'])} - ${getRName(sootchuma['pada_nakshatra'])} ${sootchuma['pada_num']})";
    }

    // Chart Gen
    Map<String, List<String>> rasiMap = {};
    for (var sign in KPService.SIGNS) rasiMap[sign] = [];
    
    final langCode = l10n.localeName;
    String udayamLabel = langCode == 'en' ? 'Ud' : (langCode == 'hi' ? 'उद' : 'உத');
    String arudamLabel = langCode == 'en' ? 'Ar' : (langCode == 'hi' ? 'आ' : 'ஆரூ');
    String kaviLabel = langCode == 'en' ? 'Ka' : (langCode == 'hi' ? 'क' : 'கவி');

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
        if (rasiMap.containsKey(jUdayamSign)) rasiMap[jUdayamSign]?.add("<span style='color:green; font-weight:bold'>$udayamLabel&nbsp;${jd.toString().padLeft(2, '0')}:${jm.toString().padLeft(2, '0')}</span>");
      } else {
        String k = pKey.toString();
        String pName = _toLocal(k, langCode);
        if (k == 'sun') pName = langCode == 'en' ? 'Sun' : (langCode == 'hi' ? 'सू' : 'சூ');
        if (k == 'moon') pName = langCode == 'en' ? 'Mon' : (langCode == 'hi' ? 'चं' : 'சந்');
        if (rasiMap.containsKey(sign)) rasiMap[sign]!.add("$pName&nbsp;${d.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}");
      }
    });

    double aDeg = (outer['arudam_abs_deg'] ?? 0.0).toDouble();
    double aDegInSign = aDeg % 30.0;
    int aD = aDegInSign.floor();
    int aM = ((aDegInSign - aD) * 60).floor();
    if (rasiMap.containsKey(KPService.SIGNS[arudamIdx % 12])) {
        rasiMap[KPService.SIGNS[arudamIdx % 12]]?.add("<span style='color:red; font-weight:bold'>$arudamLabel&nbsp;${aD.toString().padLeft(2, '0')}:${aM.toString().padLeft(2, '0')}</span>");
    }
    
    double kDegInSign = 30.0 - aDegInSign;
    if (kDegInSign >= 30.0) kDegInSign = 29.9999;
    int kD = kDegInSign.floor();
    int kM = ((kDegInSign - kD) * 60).floor();
    if (rasiMap.containsKey(KPService.SIGNS[kaviIdx % 12])) {
        rasiMap[KPService.SIGNS[kaviIdx % 12]]?.add("<span style='color:purple; font-weight:bold'>$kaviLabel&nbsp;${kD.toString().padLeft(2, '0')}:${kM.toString().padLeft(2, '0')}</span>");
    }

    String renderOuterLabel(String sign) {
        final borderPlanets = outer['border_planets'] as Map? ?? {};
        if (borderPlanets.containsKey(sign)) {
            String label = borderPlanets[sign].toString();
            // In PDF we can use &nbsp; for space
            return label.replaceAll(' ', '&nbsp;');
        }
        return "";
    }

    String r(String sign) {
        final innerItems = rasiMap[sign] ?? [];
        String innerHtml = innerItems.join('<br>');
        String outerHtml = renderOuterLabel(sign);
        
        String outerDiv = "";
        if (outerHtml.isNotEmpty) {
            String style = "";
            if (['Aries', 'Taurus', 'Gemini'].contains(sign)) {
                style = "position: absolute; bottom: 100%; left: 0; right: 0; text-align: center; padding-bottom: 1.5mm; color: #1E3A8A; font-weight: bold; font-size: 2.2mm; white-space: nowrap;";
            } else if (['Cancer', 'Leo', 'Virgo'].contains(sign)) {
                style = "position: absolute; left: 100%; top: 50%; transform: translateY(-50%); writing-mode: vertical-rl; padding-top: 1.5mm; color: #1E3A8A; font-weight: bold; font-size: 2.2mm; white-space: nowrap;";
            } else if (['Libra', 'Scorpio', 'Sagittarius'].contains(sign)) {
                style = "position: absolute; top: 100%; left: 0; right: 0; text-align: center; padding-top: 1.5mm; color: #1E3A8A; font-weight: bold; font-size: 2.2mm; white-space: nowrap;";
            } else if (['Capricorn', 'Aquarius', 'Pisces'].contains(sign)) {
                style = "position: absolute; right: 100%; top: 50%; transform: translateY(-50%) rotate(180deg); writing-mode: vertical-rl; padding-top: 1.5mm; color: #1E3A8A; font-weight: bold; font-size: 2.2mm; white-space: nowrap;";
            }
            outerDiv = "<div style='$style'>$outerHtml</div>";
        }

        return """
        <div style='position: relative; height: 100%; width: 100%;'>
            $outerDiv
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

    String udayamName = langCode == 'en' ? 'Udayam' : (langCode == 'hi' ? 'उदयम' : 'உதயம்');
    String arudamName = langCode == 'en' ? 'Arudam' : (langCode == 'hi' ? 'आरूढम' : 'ஆரூடம்');
    String kavippuName = langCode == 'en' ? 'Kavippu' : (langCode == 'hi' ? 'कविप्पु' : 'கவிப்பு');

    void addOuterRow(String name, double deg) {
      int d = deg.floor();
      int m = ((deg - d) * 60).floor();
      var sp = _getStarPada(deg);
      outerPathaHtml += "<tr><td>$name</td><td>$d° $m'</td><td>${sp['star']}</td><td>${sp['pada']}</td></tr>";
    }
    addOuterRow(udayamName, uDeg);
    addOuterRow(arudamName, aDegPatha);
    addOuterRow(kavippuName, kDeg);
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
      String name = _toLocal(nameKey, langCode);
      if (key == 'lagna') name = langCode == 'en' ? 'Lagna' : (langCode == 'hi' ? 'लग्न' : 'லக்னம்');
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
      for (var d in dasaList) {
        if (inputTime.compareTo(d['start']) >= 0 && inputTime.compareTo(d['end']) <= 0) {
          currentDasa = d;
          bukthiList = d['subPeriods'] ?? [];
          for (var b in bukthiList) {
            if (inputTime.compareTo(b['start']) >= 0 && inputTime.compareTo(b['end']) <= 0) {
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
        html { -webkit-text-size-adjust: none; text-size-adjust: none; }
        :root { --border-orange: #E0D4BE; --header-blue: #5D1204; --text-red: #5D1204; --text-green: #B58D3D; }
        body { font-family: sans-serif; margin: 0; padding: 2mm; color: #333; font-size: 2.8mm; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
        @media screen {
          body { background: #f3f4f6; display: flex; flex-direction: column; align-items: center; }
          .page { background: white; width: 210mm; min-height: 297mm; padding: 4mm; box-shadow: 0 0 3mm rgba(0,0,0,0.1); margin: 4mm 0; position: relative; box-sizing: border-box; overflow: hidden; }
          .inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; min-height: 285mm; box-sizing: border-box; display: flex; flex-direction: column; }
        }
        @media print {
          @page { size: A4; margin: 0mm; }
          body { background: white; padding: 5mm; -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
          .page { width: 100%; padding: 0; box-shadow: none; margin: 0; box-sizing: border-box; height: 287mm; overflow: hidden; }
          .inner-page { border: 0.5mm solid var(--text-red); padding: 2mm; box-sizing: border-box; height: 100%; display: flex; flex-direction: column; }
        }
        .header { border-bottom: 0.5mm solid var(--text-red); margin-bottom: 1.5mm; padding-bottom: 1mm; }
        .header-top { display: flex; justify-content: space-between; }
        .header-title { color: var(--text-red); font-weight: bold; font-size: 5.5mm; line-height: 1.1; }
        .header-sub { font-size: 2.8mm; color: #555; line-height: 1.2; }
        .banner { background: var(--text-red); color: white; text-align: center; padding: 0.8mm; font-weight: bold; font-size: 4.4mm; margin: 1mm 0; border-radius: 1mm; }
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 2mm; margin-bottom: 1.5mm; border-bottom: 0.3mm solid #eee; padding-bottom: 1mm; }
        .detail-row { display: flex; margin-bottom: 0.3mm; font-size: 2.9mm; }
        .detail-label { width: 28mm; color: var(--text-red); font-weight: bold; }
        
        .grid-chart { width: 100%; max-width: 100mm; margin: 0 auto; border-collapse: collapse; table-layout: fixed; }
        .grid-chart td { border: 0.3mm solid var(--text-red); height: 19.2mm; text-align: center; font-size: 2.4mm; font-weight: bold; padding: 0; vertical-align: middle; background: #FAF6EE; }
        .chart-title { color: var(--text-red); font-size: 3.5mm; font-weight: bold; line-height: 1.1; margin-bottom: 1mm; }
        
        .patha-tables { display: flex; justify-content: space-between; margin-bottom: 1.5mm; }
        .data-table { width: 48%; border-collapse: collapse; font-size: 2.1mm; border: 0.3mm solid var(--border-orange); }
        .data-table th { background: #eee; border: 0.3mm solid var(--border-orange); padding: 0.5mm; font-weight: bold; color: var(--text-red); }
        .data-table td { border: 0.3mm solid var(--border-orange); padding: 0.5mm; text-align: center; }

        .timeline-row { display: flex; gap: 2mm; margin-top: 1.5mm; }
        
        .footer { text-align: center; font-size: 2.0mm; margin-top: 1.5mm; font-style: italic; border-top: 0.3mm dashed #ccc; padding-top: 0.5mm; }
        .print-btn {
           position: fixed;
           top: 5mm;
           right: 5mm;
           background: var(--text-red);
           color: white;
           border: none;
           padding: 2mm 5mm;
           font-size: 3.8mm;
           font-weight: bold;
           border-radius: 1mm;
           cursor: pointer;
           z-index: 1000;
           box-shadow: 0 1mm 2mm rgba(0,0,0,0.3);
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
              <div style="flex: 0 0 auto; text-align: left; margin-right: 4mm;">
                 ${ganapathyBase64.isNotEmpty ? '<img src="data:image/png;base64,$ganapathyBase64" style="height: 19.5mm; width: 15.6mm; object-fit: contain;" alt="Ganapathy" />' : ''}
              </div>
              <div style="flex: 1; text-align: center; min-width: 0;">
                <div class="header-title">${shopName}</div>
                <div class="header-sub" style="white-space: pre-line; margin-top: 1mm;">$astroName<br>$address</div>
                <div style="color: var(--text-red); font-size: 2.8mm; margin-top: 1mm;">$phone | $nowStr</div>
              </div>
              <div style="flex: 0 0 auto; text-align: right; margin-left: 4mm;">
                 ${muruganBase64.isNotEmpty ? '<img src="data:image/png;base64,$muruganBase64" style="height: 19.5mm; width: 18mm; object-fit: contain;" alt="Murugan" />' : ''}
              </div>
            </div>
          </div>
          <div class="banner">ஜாமக்கோள் பிரசன்னம் <span style="font-size: 2.5mm; font-weight: normal; margin-left: 1.5mm;"> </span></div>
          
          <div class="details-grid">
            <div>
              <div class="detail-row"><span class="detail-label">பெயர்</span>: <span style="color:var(--text-red)">$name</span></div>
              <div class="detail-row"><span class="detail-label">நட்சத்திரம்</span>: <span style="color:#333">$nakshatraStr - $padaStr பாதம்</span></div>
              <div class="detail-row"><span class="detail-label">இராசி</span>: <span style="color:#333">$rasiStr இராசி</span></div>
              <div class="detail-row"><span class="detail-label">தேதி</span>: <span style="color:var(--text-red)">$dateStr</span></div>
              <div class="detail-row"><span class="detail-label">நேரம்</span>: <span style="color:#333">${timeStr}</span></div>
            </div>
            <div>
              <div class="detail-row"><span class="detail-label">தமிழ் தேதி</span>: <span style="color:#333">$tamilYear வருடம், $tamilMonth - $tamilDate</span></div>
              <div class="detail-row"><span class="detail-label">திதி</span>: <span style="color:#333">$thithiStr</span></div>
              <div class="detail-row"><span class="detail-label">பட்சம்</span>: <span style="color:#333">$pakshamStr</span></div>
              <div class="detail-row"><span class="detail-label">கிழமை</span>: <span style="color:#333">$weekdayStr</span></div>
            </div>
          </div>

          <div style="display: flex; margin: 2mm 0; align-items: stretch; border: 0.5mm solid #1E3A8A; border-radius: 1mm; background: #FAF6EE;">
            <div style="flex: 0 0 55%; padding: 10mm 10mm; background: #fff; box-sizing: border-box;">
                <table class="grid-chart" style="margin: 0; border: 0.5mm solid var(--text-red); background: #FAF6EE; width: 100%;">
                    <tr><td>${r('Pisces')}</td><td>${r('Aries')}</td><td>${r('Taurus')}</td><td>${r('Gemini')}</td></tr>
                    <tr><td>${r('Aquarius')}</td><td colspan="2" rowspan="2" style="text-align: center; background: #fff;"><div class="chart-title" style="font-size:3mm;">${langCode == 'en' ? 'Jamakkol<br>Prasannam Chart' : (langCode == 'hi' ? 'जामक्कोल<br>प्रसन्नम कुंडली' : 'ஜாமக்கோள்<br>பிரசன்னம் கட்டம்')}</div></td><td>${r('Cancer')}</td></tr>
                    <tr><td>${r('Capricorn')}</td><td>${r('Leo')}</td></tr>
                    <tr><td>${r('Sagittarius')}</td><td>${r('Scorpio')}</td><td>${r('Libra')}</td><td>${r('Virgo')}</td></tr>
                </table>
            </div>
            
            <div style="flex: 1; border-left: 0.5mm solid #1E3A8A; padding: 2mm 3mm; display: flex; flex-direction: column; justify-content: center;">
                <div style="background: var(--header-blue); color: white; padding: 1mm; font-size: 2.2mm; font-weight: bold; text-align: center; border-radius: 0.5mm; margin-bottom: 1.5mm;">
                   📄 ஜாமக்கோள் குறிப்புகள்
                </div>
                
                <table style="width: 100%; font-size: 2.2mm; line-height: 1.4; margin-bottom: 1mm;">
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">1. உதயம் தொடர்பு கொள்ளும் கிரகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$uContactStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">2. உதயம் நின்ற நட்சத்திர பாதம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$uStarStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">3. உதயத்தை கடந்த கிரகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$crossedStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">4. ஆருடம் உள்ள பாவம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$aHouseStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">5. ஆருடம் தொடர்பு கொள்ளும் கிரகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$aContactStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">6. கவிப்புள்ள பாவம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$kHouseStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">7. கவிக்கப்படும் கிரகம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$kPlanetStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">8. ஆருடாதிபதி நின்ற பாவம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$aLordHouseStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">9. ஆருடம் vs உதயம்</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$aVsUStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">10. ஆருடம் vs கவிப்பு</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$aVsKStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">11. அஷ்டமாதிபதி</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$eLordStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">12. பாதகாதிபதி</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$bLordStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">13. இராசிப் பரிவர்த்தனை</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$parivarthanaiStr</td></tr>
                  <tr><td style="color: #555; font-weight: bold; padding-bottom: 0.2mm;">14. சூட்சும ராசி</td><td style="text-align: right; color: var(--header-blue); font-weight: bold;">$sootchumaStr</td></tr>
                </table>

                <div style="background: var(--header-blue); color: white; padding: 1mm; font-size: 2.2mm; font-weight: bold; text-align: center; border-radius: 0.5mm; margin-bottom: 1.5mm;">
                   ⚡ கதிர் பலம் (Strength)
                </div>
                
                <table style="width: 100%; font-size: 2.2mm; line-height: 1.4; border-collapse: collapse;">
                  <tr style="border-bottom: 0.3mm solid #ccc; color: #555;">
                     <th style="text-align: left; padding-bottom: 0.5mm;">அம்சம்</th>
                     <th style="text-align: center; padding-bottom: 0.5mm;">ராசி</th>
                     <th style="text-align: center; padding-bottom: 0.5mm;">அதிபதி</th>
                     <th style="text-align: right; padding-bottom: 0.5mm;">மொத்தம்</th>
                  </tr>
                  <tr>
                     <td style="color: var(--header-blue); font-weight: bold; padding: 0.5mm 0;">உதயம்</td>
                     <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['udayam']?['rasi'] ?? '-'}</td>
                     <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['udayam']?['lord'] ?? '-'}</td>
                     <td style="text-align: right; color: #E65100; font-weight: bold;">${strength['udayam']?['total'] ?? '-'}</td>
                  </tr>
                  <tr>
                     <td style="color: var(--header-blue); font-weight: bold; padding: 0.5mm 0;">ஆரூடம்</td>
                     <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['arudam']?['rasi'] ?? '-'}</td>
                     <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['arudam']?['lord'] ?? '-'}</td>
                     <td style="text-align: right; color: #E65100; font-weight: bold;">${strength['arudam']?['total'] ?? '-'}</td>
                  </tr>
                  <tr>
                     <td style="color: var(--header-blue); font-weight: bold; padding: 0.5mm 0;">கவிப்பு</td>
                     <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['kavi']?['rasi'] ?? '-'}</td>
                     <td style="text-align: center; color: var(--header-blue); font-weight: bold;">${strength['kavi']?['lord'] ?? '-'}</td>
                     <td style="text-align: right; color: #E65100; font-weight: bold;">${strength['kavi']?['total'] ?? '-'}</td>
                  </tr>
                  <tr style="border-top: 0.3mm solid #ccc;">
                     <td colspan="3" style="color: var(--header-blue); font-weight: bold; padding-top: 1mm;">ஜாமக் கிரகம் (${strength['jamam']?['planet'] ?? '-'})</td>
                     <td style="text-align: right; color: #E65100; font-weight: bold; padding-top: 1mm;">${strength['jamam']?['total'] ?? '-'}</td>
                  </tr>
                </table>
            </div>
          </div>

          
          
          <div style="color:var(--text-red); font-weight:bold; text-align:center; font-size: 3.5mm; margin-bottom:1.5mm;">${langCode == 'en' ? 'Padasaram (Planets and Key Points)' : (langCode == 'hi' ? 'पादसारम (ग्रह और मुख्य बिंदु)' : 'பாதசாரம் (கிரகங்கள் மற்றும் முக்கிய புள்ளிகள்)')}</div>
          <div class="patha-tables">
              <table class="data-table">
                  <tr><th colspan="4">${langCode == 'en' ? 'Jamakkol Planets & Points' : (langCode == 'hi' ? 'जामक्कोल ग्रह और बिंदु' : 'ஜாம கிரகங்கள் மற்றும் முக்கிய புள்ளிகள்')}</th></tr>
                  <tr><th>${l10n.planet}</th><th>${langCode == 'en' ? 'Degree' : (langCode == 'hi' ? 'अंश' : 'பாகை')}</th><th>${l10n.nakshatraLabel}</th><th>${langCode == 'en' ? 'Pada' : (langCode == 'hi' ? 'पाद' : 'பாதம்')}</th></tr>
                  $outerPathaHtml
              </table>
              <table class="data-table">
                  <tr><th colspan="4">${langCode == 'en' ? 'Inner Chart Planets' : (langCode == 'hi' ? 'आंतरिक चक्र ग्रह' : 'உள்வட்ட கிரகங்கள்')}</th></tr>
                  <tr><th>${l10n.planet}</th><th>${langCode == 'en' ? 'Degree' : (langCode == 'hi' ? 'अंश' : 'பாகை')}</th><th>${l10n.nakshatraLabel}</th><th>${langCode == 'en' ? 'Pada' : (langCode == 'hi' ? 'पाद' : 'பாதம்')}</th></tr>
                  $innerPathaHtml
              </table>
          </div>

          <div class="timeline-row" style="margin-top: 0;">
            ${_buildTimelineHtml(l10n.dasaTitle, dasaList, l10n.dasaTitle, currentDasa, l10n, inputTime)}
            ${_buildTimelineHtml(l10n.bukthiTitle, bukthiList, l10n.bukthiTitle, currentBukthi, l10n, inputTime)}
            <div style="flex: 1; border: 0.5mm solid var(--text-red); border-radius: 1.5mm; overflow: hidden; margin: 0 1mm; padding: 2mm; display: flex; flex-direction: column; justify-content: space-evenly; background: linear-gradient(135deg, #FFFDF8, #FAF6EE); box-shadow: inset 0 0 1mm rgba(93,18,4,0.1);">
               <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 0.3mm dashed #E0D4BE; padding-bottom: 1mm;">
                  <b style="color:var(--text-red); font-size: 3.5mm; letter-spacing: 0.5px;">${l10n.localeName == 'en' ? "Lagna" : (l10n.localeName == 'hi' ? "लग्न" : "லக்னம்")}</b> 
                  <span style="font-weight:bold; color:var(--text-red); font-size: 4.2mm; background: rgba(181, 141, 61, 0.2); padding: 0.5mm 2mm; border-radius: 1mm;">$lagnaSign</span>
               </div>
               <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 0.3mm dashed #E0D4BE; padding: 1mm 0;">
                  <b style="color:var(--text-red); font-size: 3.5mm; letter-spacing: 0.5px;">${l10n.localeName == 'en' ? "Udayam" : (l10n.localeName == 'hi' ? "उदयम" : "உதயம்")}</b> 
                  <span style="font-weight:bold; color:var(--text-red); font-size: 4.2mm; background: rgba(181, 141, 61, 0.2); padding: 0.5mm 2mm; border-radius: 1mm;">$udayamSign</span>
               </div>
               <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 0.3mm dashed #E0D4BE; padding: 1mm 0;">
                  <b style="color:var(--text-red); font-size: 3.5mm; letter-spacing: 0.5px;">${l10n.localeName == 'en' ? "Arudam" : (l10n.localeName == 'hi' ? "आरूढम" : "ஆரூடம்")}</b> 
                  <span style="font-weight:bold; color:var(--text-red); font-size: 4.2mm; background: rgba(181, 141, 61, 0.2); padding: 0.5mm 2mm; border-radius: 1mm;">$arudamSign</span>
               </div>
               <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 0.3mm dashed #E0D4BE; padding: 1mm 0;">
                  <b style="color:var(--text-red); font-size: 3.5mm; letter-spacing: 0.5px;">${l10n.localeName == 'en' ? "Kavippu" : (l10n.localeName == 'hi' ? "कविप्पु" : "கவிப்பு")}</b> 
                  <span style="font-weight:bold; color:var(--text-red); font-size: 4.2mm; background: rgba(181, 141, 61, 0.2); padding: 0.5mm 2mm; border-radius: 1mm;">$kavippuSign</span>
               </div>
               <div style="display: flex; justify-content: space-between; align-items: center; padding-top: 1mm;">
                  <b style="color:var(--text-red); font-size: 3.5mm; letter-spacing: 0.5px;">${l10n.localeName == 'en' ? "Gowri" : (l10n.localeName == 'hi' ? "गौरी" : "கௌரி")}</b> 
                  <span style="font-weight:bold; color:var(--text-red); font-size: 4.2mm; background: rgba(181, 141, 61, 0.2); padding: 0.5mm 2mm; border-radius: 1mm;">$gowriStr</span>
               </div>
            </div>
          </div>

          <div class="footer">Created by GB Astro Astrology Software | Mobile: +91 96006 66225</div>
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