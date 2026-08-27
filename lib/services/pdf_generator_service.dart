import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import 'kp_service.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  static final PdfColor primaryColor = PdfColor.fromInt(0xFF5D1204); // Maroon
  static final PdfColor secondaryColor = PdfColor.fromInt(0xFFB58D3D); // Gold/Terracotta
  static final PdfColor backgroundColor = PdfColor.fromInt(0xFFFAF6EE); // Cream background
  static final PdfColor borderColor = PdfColor.fromInt(0xFFE0D4BE); // Border

  static Future<Uint8List> generateHoroscopePdf({
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
  }) async {
    final pdf = pw.Document();
    final tamilFont = await PdfGoogleFonts.hindMaduraiRegular();
    final tamilFontBold = await PdfGoogleFonts.hindMaduraiBold();

    final Map<String, List<String>> rasiData = _castToChartMap(results['rasi']);
    final Map<String, List<String>> amsamData = _castToChartMap(results['navamsa']);
    final Map<String, List<String>> pavagamData = _castToChartMap(results['pavagam']);
    
    final details = results['planet_details'] as Map<dynamic, dynamic>? ?? {};
    final panchangam = results['panchangam'] as Map<dynamic, dynamic>? ?? {};
    final dasaList = results['vimshottari'] as List<dynamic>? ?? [];
    final birthDt = results['birth_dt'] as DateTime?;
    final place = results['place'] ?? "-";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: tamilFont, bold: tamilFontBold),
        margin: const pw.EdgeInsets.all(25),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header & Title
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text("GB ASTRO", 
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    pw.Text("ஜாதக அறிக்கை", style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                    pw.Divider(color: primaryColor, thickness: 1),
                  ],
                ),
              ),

              // 2. Personal & Birth Info Grid
              _sectionTitle("ஜாதகர் விவரங்கள்"),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor), 
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  color: backgroundColor,
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        _infoItem("பெயர்", name, flex: 2),
                        _infoItem("பாலினம்", gender, flex: 1),
                        _infoItem("பிறந்த தேதி", birthDt != null ? DateFormat('dd/MM/yyyy').format(birthDt) : "-", flex: 1.5),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        _infoItem("நேரம்", birthDt != null ? DateFormat('hh:mm a').format(birthDt) : "-", flex: 1),
                        _infoItem("இடம்", place, flex: 3),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // 3. Panchangam Table
              _sectionTitle("பஞ்சாங்க விவரங்கள்"),
              _buildPanchangamTable(panchangam),

              pw.SizedBox(height: 12),

              // 4. Charts Section (Rasi, Amsam, Pavagam)
              _sectionTitle("கட்டங்கள்"),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _chartBox("ராசி", rasiData),
                  _chartBox("அம்சம்", amsamData),
                  _chartBox("பாவகம்", pavagamData),
                ],
              ),

              pw.SizedBox(height: 12),

              // 5. Planet Positions & Dasa Side-by-Side
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Planet Positions (Left)
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("கிரக பாதசாரம்"),
                        _buildPlanetTable(details),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  // Dasa Periods (Right)
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _sectionTitle("தசா காலங்கள்"),
                        _buildDasaTable(dasaList),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Center(
                child: pw.Text("Generated by S&B Astrology Software | GB Astro",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4, top: 4),
      child: pw.Text(title, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
    );
  }

  static pw.Widget _infoItem(String label, String value, {double flex = 1}) {
    return pw.Expanded(
      flex: (flex * 10).toInt(),
      child: pw.Row(
        children: [
          pw.Text("$label: ", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
        ],
      ),
    );
  }

  static pw.Widget _buildPanchangamTable(Map<dynamic, dynamic> pan) {
    return pw.Table(
      border: pw.TableBorder.all(color: borderColor),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: backgroundColor),
          children: [
            _tableHeaderCell("தமிழ் வருடம்"),
            _tableHeaderCell("திதி"),
            _tableHeaderCell("நட்சத்திரம்"),
            _tableHeaderCell("யோகம்"),
            _tableHeaderCell("கரணம்"),
            _tableHeaderCell("வாரம்"),
          ],
        ),
        pw.TableRow(
          children: [
            _tableCell(pan['tamil_year'] ?? "-"),
            _tableCell(pan['tithi'] ?? "-"),
            _tableCell(pan['nakshatra'] ?? "-"),
            _tableCell(pan['yoga'] ?? "-"),
            _tableCell(pan['karana']?.toString() ?? "-"),
            _tableCell(pan['vara'] ?? "-"),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPlanetTable(Map<dynamic, dynamic> details) {
    final List<String> planetsOrder = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu', 'Lagna'];
    
    return pw.Table(
      border: pw.TableBorder.all(color: borderColor),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: backgroundColor),
          children: [
            _tableHeaderCell("கிரகம்"),
            _tableHeaderCell("ராசி"),
            _tableHeaderCell("நட்சத்திரம்"),
            _tableHeaderCell("பாதம்"),
            _tableHeaderCell("பாகை"),
          ],
        ),
        ...planetsOrder.map((pKey) {
          final p = details[pKey.toLowerCase()] ?? details[pKey] ?? {};
          return pw.TableRow(
            children: [
              _tableCell(KPService.TAMIL_PLANETS[pKey] ?? (pKey == 'Lagna' ? 'லக்னம்' : pKey)),
              _tableCell(KPService.TAMIL_SIGNS[p['rasi']] ?? p['rasi'] ?? "-"),
              _tableCell(p['nakshatra'] ?? "-"),
              _tableCell(p['pada']?.toString() ?? "-"),
              _tableCell(p['longitude'] != null ? KPService.formatAbsoluteDegrees(p['longitude']) : "-"),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildDasaTable(List<dynamic> dasaList) {
    // Show only the first 9 major Dasas
    final displayList = dasaList.take(9).toList();
    
    return pw.Table(
      border: pw.TableBorder.all(color: borderColor),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: backgroundColor),
          children: [
            _tableHeaderCell("தசை"),
            _tableHeaderCell("ஆரம்பம்"),
            _tableHeaderCell("முடிவு"),
          ],
        ),
        ...displayList.map((d) {
          final start = d['start'] as DateTime?;
          final end = d['end'] as DateTime?;
          return pw.TableRow(
            children: [
              _tableCell(KPService.TAMIL_PLANETS[d['lord']] ?? d['lord']),
              _tableCell(start != null ? DateFormat('MM/yyyy').format(start) : "-"),
              _tableCell(end != null ? DateFormat('MM/yyyy').format(end) : "-"),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Center(child: pw.Text(text, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor))),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Center(child: pw.Text(text, style: const pw.TextStyle(fontSize: 8))),
    );
  }

  static pw.Widget _chartBox(String title, Map<String, List<String>> data) {
    return pw.Column(
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
        pw.SizedBox(height: 2),
        _pwSouthIndianChart(data, title),
      ],
    );
  }

  static pw.Widget _pwSouthIndianChart(Map<String, List<String>> data, String centerLabel) {
    final Map<int, List<String>> rasiMap = {};
    data.forEach((planet, list) {
      for (var rasiStr in list) {
        final rasiIdx = int.tryParse(rasiStr) ?? 0;
        if (rasiIdx > 0) {
          rasiMap.putIfAbsent(rasiIdx, () => []).add(planet);
        }
      }
    });

    return pw.Container(
      width: 165,
      height: 165,
      decoration: pw.BoxDecoration(border: pw.Border.all(color: primaryColor, width: 1.5)),
      child: pw.GridView(
        crossAxisCount: 4,
        children: List.generate(16, (i) {
          final row = i ~/ 4;
          final col = i % 4;
          final key = "$row,$col";
          final rasiIdx = RASI_GRID[key];

          if (rasiIdx == null) {
            if (row == 1 && col == 1) {
              return pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor, width: 0.2)),
                child: pw.Center(child: pw.Text(centerLabel, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor))),
              );
            }
            return pw.Container();
          }

          final rawPlanets = rasiMap[rasiIdx] ?? [];
          // Shorten names for the small chart cells
          final planets = rawPlanets.map((p) => KPService.TAMIL_PLANETS[p]?.substring(0, 2) ?? p.substring(0, 2)).toList();

          return pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border.all(color: borderColor, width: 0.5), color: backgroundColor),
            padding: const pw.EdgeInsets.all(1),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Wrap(
                  spacing: 1,
                  runSpacing: 1,
                  children: planets.map((p) => pw.Text(p, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: primaryColor))).toList(),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

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
