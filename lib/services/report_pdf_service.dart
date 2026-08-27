import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tamil_pdf_shaper/tamil_pdf_shaper.dart';
import '../utils/constants.dart';
import 'kp_service.dart';
import 'package:intl/intl.dart';

class ReportPdfService {
  static Future<Uint8List> generateHoroscopePdf({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
    Uint8List? leftLogoBytes,
    Uint8List? rightLogoBytes,
  }) async {
    final pdf = pw.Document();
    final tamilFont = await TamilPdfFont.load();

    final primaryColor = PdfColor.fromHex('#5D1204');
    final secondaryColor = PdfColor.fromHex('#B58D3D');
    final bgColor = PdfColor.fromHex('#FAF6EE');
    final borderColor = PdfColor.fromHex('#E0D4BE');

    final Map<String, List<String>> rasiData = _castToChartMap(results['rasi']);
    final Map<String, List<String>> amsamData = _castToChartMap(results['navamsa']);
    final Map<String, List<String>> pavagamData = _castToChartMap(results['pavagam']);
    
    final details = results['planet_details'] as Map<dynamic, dynamic>? ?? {};
    final panchangam = results['panchangam'] as Map<dynamic, dynamic>? ?? {};
    final dasaList = results['dasa'] as List<dynamic>? ?? [];
    final birthDt = results['birth_dt'] as DateTime?;
    final place = results['place'] ?? "-";
    final lat = results['lat']?.toString() ?? "-";
    final lon = results['lon']?.toString() ?? "-";
    final timezone = results['timezone']?.toString() ?? "-";

    final now = DateTime.now();
    int currentDasaIdx = -1;
    for (int i = 0; i < dasaList.length; i++) {
        final d = dasaList[i];
        final start = d['start'] as DateTime?;
        final end = d['end'] as DateTime?;
        if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) {
            currentDasaIdx = i;
            break;
        }
    }

    final currentDasa = currentDasaIdx != -1 ? dasaList[currentDasaIdx] : null;
    final List<dynamic> currentBhuktis = currentDasa?['subPeriods'] ?? [];
    
    String currentBhuktiName = "-";
    for (var b in currentBhuktis) {
        final start = b['start'] as DateTime?;
        final end = b['end'] as DateTime?;
        if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) {
            currentBhuktiName = b['lord'] ?? "-";
            break;
        }
    }

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
            dasaBalance = "${firstDasa['lord']} - $years வ, $months மா, $days நா";
        }
    }

    pw.Widget sectionTitle(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 8, bottom: 4),
        decoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
        ),
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          children: [
            pw.Text("◈", style: pw.TextStyle(color: primaryColor, fontSize: 10)),
            pw.SizedBox(width: 4),
            pw.Text(title.toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ]
        )
      );
    }

    pw.Widget infoItem(String label, String value, {PdfColor? valueColor}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 70, child: pw.Text(label.toTamilPdf, style: pw.TextStyle(color: PdfColors.grey700, fontSize: 9))),
            pw.Text(": ", style: pw.TextStyle(color: PdfColors.grey700, fontSize: 9)),
            pw.Expanded(child: pw.Text(value.toTamilPdf, style: pw.TextStyle(color: valueColor ?? primaryColor, fontSize: 9, fontWeight: pw.FontWeight.bold))),
          ]
        )
      );
    }

    pw.Widget chartBox(Map<String, List<String>> chartData, String title) {
      Map<int, List<String>> rasiMap = {};
      final List<String> SIGNS = [
        "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
        "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
      ];
      chartData.forEach((sign, planets) {
        int rasiIdx = SIGNS.indexOf(sign) + 1;
        if (rasiIdx > 0) rasiMap[rasiIdx] = planets;
      });

      pw.Widget cell(int? idx) {
        if (idx == null) return pw.Container();
        final planets = rasiMap[idx] ?? [];
        return pw.Container(
          padding: const pw.EdgeInsets.all(2),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderColor, width: 0.5),
            color: bgColor,
          ),
          child: pw.Center(
            child: pw.Text(planets.join(" ").toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 7, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)
          )
        );
      }

      return pw.Expanded(
        child: pw.Column(
          children: [
            pw.Text(title.toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 10, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Container(
              width: 140, height: 140,
              decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor, width: 1.5)),
              child: pw.Column(
                children: [
                  pw.Expanded(child: pw.Row(children: [pw.Expanded(child: cell(12)), pw.Expanded(child: cell(1)), pw.Expanded(child: cell(2)), pw.Expanded(child: cell(3))])),
                  pw.Expanded(child: pw.Row(children: [
                    pw.Expanded(child: cell(11)), 
                    pw.Expanded(flex: 2, child: pw.Container(
                      decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor, width: 0.5), color: PdfColor.fromHex('#F4EFE3')),
                      child: pw.Center(child: pw.Text(title.toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 12, fontWeight: pw.FontWeight.bold)))
                    )), 
                    pw.Expanded(child: cell(4))
                  ])),
                  pw.Expanded(child: pw.Row(children: [pw.Expanded(child: cell(10)), pw.Expanded(flex: 2, child: pw.Container()), pw.Expanded(child: cell(5))])),
                  pw.Expanded(child: pw.Row(children: [pw.Expanded(child: cell(9)), pw.Expanded(child: cell(8)), pw.Expanded(child: cell(7)), pw.Expanded(child: cell(6))])),
                ]
              )
            )
          ]
        )
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        theme: pw.ThemeData.withFont(base: tamilFont),
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(22),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 2),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Container(
                margin: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: primaryColor, width: 0.5), // inner border
                ),
                padding: const pw.EdgeInsets.all(12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header
                    pw.Container(
                      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2))),
                      padding: const pw.EdgeInsets.only(bottom: 5),
                      margin: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          leftLogoBytes != null ? pw.Image(pw.MemoryImage(leftLogoBytes), width: 50, height: 50) : pw.Container(width: 50),
                          pw.Column(
                            children: [
                              pw.Text("GB ASTRO", style: pw.TextStyle(color: primaryColor, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                              pw.Text("ஜாதக அறிக்கை (HOROSCOPE REPORT)".toTamilPdf, style: pw.TextStyle(color: PdfColors.grey700, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            ]
                          ),
                          rightLogoBytes != null ? pw.Image(pw.MemoryImage(rightLogoBytes), width: 50, height: 50) : pw.Container(width: 50),
                        ]
                      )
                    ),
                    
                    sectionTitle("ஜாதகர் விவரங்கள்"),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: bgColor,
                        border: pw.Border.all(color: borderColor),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                infoItem("பெயர்", name),
                                infoItem("பாலினம்", gender),
                                infoItem("பிறந்த தேதி", birthDt != null ? DateFormat('dd/MM/yyyy').format(birthDt) : "-"),
                                infoItem("நேரம்", birthDt != null ? DateFormat('hh:mm a').format(birthDt) : "-"),
                                infoItem("இடம்", place),
                              ]
                            )
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                infoItem("அட்சரேகை", lat),
                                infoItem("தீர்க்கரேகை", lon),
                                infoItem("நேர மண்டலம்", timezone),
                                infoItem("தசா இருப்பு", dasaBalance, valueColor: secondaryColor),
                                infoItem("நடப்பு தசை", currentDasa?['lord'] ?? "-"),
                                infoItem("நடப்பு புக்தி", currentBhuktiName),
                              ]
                            )
                          ),
                        ]
                      )
                    ),

                    sectionTitle("பஞ்சாங்க விவரங்கள்"),
                    pw.Table(
                      border: pw.TableBorder.all(color: borderColor),
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F4EFE3')),
                          children: ["தமிழ் வருடம்", "மாதம் / தேதி", "வாரம்", "பட்சம்", "சூரிய உதயம்", "சூரிய அஸ்தமனம்"]
                            .map((t) => pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)))
                            .toList()
                        ),
                        pw.TableRow(
                          children: [
                            panchangam['tamil_year'] ?? "-",
                            "${panchangam['tamil_month'] ?? "-"} / ${panchangam['tamil_date'] ?? "-"}",
                            panchangam['vara'] ?? "-",
                            panchangam['paksham'] ?? "-",
                            panchangam['sunrise'] ?? "-",
                            panchangam['sunset'] ?? "-"
                          ].map((t) => pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(t.toString().toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center))).toList()
                        ),
                        pw.TableRow(
                          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F4EFE3')),
                          children: [
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text("திதி".toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text("நட்சத்திரம்".toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text("யோகம்".toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                            pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text("கரணம்".toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                            pw.Container(), pw.Container()
                          ]
                        ),
                        pw.TableRow(
                          children: [
                            panchangam['tithi'] ?? "-",
                            panchangam['nakshatra'] ?? "-",
                            panchangam['yoga'] ?? "-",
                            panchangam['karana'] ?? "-",
                            "", ""
                          ].map((t) => pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(t.toString().toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center))).toList()
                        ),
                      ]
                    ),

                    sectionTitle("கட்டங்கள் (ASTROLOGICAL CHARTS)"),
                    pw.Row(
                      children: [
                        chartBox(rasiData, "ராசி (RASI)"),
                        pw.SizedBox(width: 10),
                        chartBox(amsamData, "அம்சம் (NAVAMSA)"),
                        pw.SizedBox(width: 10),
                        chartBox(pavagamData, "பாவகம் (BHAVA)"),
                      ]
                    ),

                    pw.SizedBox(height: 10),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              sectionTitle("கிரக பாதசாரம்"),
                              pw.Table(
                                border: pw.TableBorder.all(color: borderColor),
                                children: [
                                  pw.TableRow(
                                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F4EFE3')),
                                    children: ["கிரகம்", "ராசி", "நட்சத்திரம்", "பாதம்", "பாகை"]
                                      .map((t) => pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)))
                                      .toList()
                                  ),
                                  ...['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu', 'Maanthi', 'Lagna'].map((pKey) {
                                    final p = details[pKey.toLowerCase()] ?? details[pKey] ?? {};
                                    String pName = KPService.TAMIL_PLANETS[pKey] ?? (pKey == 'Lagna' ? 'லக்னம்' : pKey);
                                    String rasi = SIGNS_TAMIL[p['rasi']] ?? p['rasi'] ?? "-";
                                    String nak = p['nakshatra'] ?? "-";
                                    String pada = p['pada']?.toString() ?? "-";
                                    String deg = p['longitude'] != null ? KPService.formatAbsoluteDegrees(p['longitude']) : "-";
                                    return pw.TableRow(
                                      children: [pName, rasi, nak, pada, deg]
                                        .map((t) => pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8), textAlign: pw.TextAlign.center)))
                                        .toList()
                                    );
                                  }).toList()
                                ]
                              )
                            ]
                          )
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              sectionTitle("தசா புக்தி விபரங்கள்"),
                              pw.Table(
                                border: pw.TableBorder.all(color: borderColor),
                                children: [
                                  pw.TableRow(
                                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F4EFE3')),
                                    children: ["புக்தி", "ஆரம்பம்", "முடிவு"]
                                      .map((t) => pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)))
                                      .toList()
                                  ),
                                  ...currentBhuktis.map((d) {
                                    final start = d['start'] as DateTime?;
                                    final end = d['end'] as DateTime?;
                                    String lord = d['lord'] ?? "-";
                                    String startStr = start != null ? DateFormat('dd/MM/yyyy').format(start) : "-";
                                    String endStr = end != null ? DateFormat('dd/MM/yyyy').format(end) : "-";
                                    bool isActive = false;
                                    if (start != null && end != null && now.isAfter(start) && now.isBefore(end)) isActive = true;
                                    
                                    return pw.TableRow(
                                      decoration: isActive ? pw.BoxDecoration(color: bgColor) : null,
                                      children: [lord, startStr, endStr]
                                        .map((t) => pw.Padding(padding: const pw.EdgeInsets.all(2), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(color: isActive ? PdfColors.red800 : primaryColor, fontSize: 8, fontWeight: isActive ? pw.FontWeight.bold : pw.FontWeight.normal), textAlign: pw.TextAlign.center)))
                                        .toList()
                                    );
                                  }).toList()
                                ]
                              )
                            ]
                          )
                        )
                      ]
                    ),

                    pw.Spacer(),
                    pw.Center(
                      child: pw.Text("Generated by GB ASTRO".toTamilPdf, style: pw.TextStyle(color: PdfColors.grey500, fontSize: 7))
                    )
                  ]
                )
              )
            )
          );
        }
      )
    );
    return pdf.save();
  }

  static Map<String, String> SIGNS_TAMIL = {
    'Aries': 'மேஷம்', 'Taurus': 'ரிஷபம்', 'Gemini': 'மிதுனம்', 'Cancer': 'கடகம்',
    'Leo': 'சிம்மம்', 'Virgo': 'கன்னி', 'Libra': 'துலாம்', 'Scorpio': 'விருச்சிகம்',
    'Sagittarius': 'தனுசு', 'Capricorn': 'மகரம்', 'Aquarius': 'கும்பம்', 'Pisces': 'மீனம்'
  };

  static Map<String, List<String>> _castToChartMap(dynamic data) {
    if (data == null || data is! Map) return {};
    return data.map((key, value) {
      if (value is List) {
        return MapEntry(key.toString(), List<String>.from(value.map((e) => e.toString())));
      }
      return MapEntry(key.toString(), <String>[]);
    });
  }
}
