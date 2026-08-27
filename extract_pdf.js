const fs = require('fs');

let content = fs.readFileSync('lib/services/full_report_pdf_service.dart', 'utf8');

const importReplacement = `import 'dart:typed_data';\nimport 'palangal_service.dart';`;
content = content.replace("import 'dart:typed_data';", importReplacement);

const ashtakavargaBlock = `
            // Ashtakavarga Output (Basic table)
            if (ashtakavarga.isNotEmpty && ashtakavarga['individual'] != null) ...[
               pw.NewPage(),
               sectionTitle("அஷ்டவர்க்கம் (Ashtakavarga)"),
               ...((ashtakavarga['individual'] as Map<dynamic, dynamic>).entries.map((entry) {
                  final pName = KPService.TAMIL_PLANETS[entry.key] ?? entry.key.toString();
                  final points = entry.value as List<int>;
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("$pName பரல்கள்".toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 12)),
                        pw.SizedBox(height: 5),
                        pw.Text(points.join(" | ").toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 10))
                      ]
                    )
                  );
               }).toList())
            ]
`;

const newAshtakavargaBlock = `
            // Ashtakavarga Output (Basic table)
            if (ashtakavarga.isNotEmpty && ashtakavarga['individual'] != null) ...[
               pw.NewPage(),
               sectionTitle("அஷ்டவர்க்கம் (Ashtakavarga)"),
               ...((ashtakavarga['individual'] as Map<dynamic, dynamic>).entries.map((entry) {
                  final pName = KPService.TAMIL_PLANETS[entry.key] ?? entry.key.toString();
                  final points = entry.value as List<int>;
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("$pName பரல்கள்".toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 12)),
                        pw.SizedBox(height: 5),
                        pw.Text(points.join(" | ").toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 10))
                      ]
                    )
                  );
               }).toList()),
               
               if (ashtakavarga['total'] != null) ...[
                 pw.SizedBox(height: 20),
                 sectionTitle("சர்வ அஷ்டவர்க்கம்"),
                 (() {
                   Map<String, List<String>> sarvaMap = {};
                   List<dynamic> totalPoints = ashtakavarga['total'];
                   for (int i = 0; i < 12; i++) {
                     if (i < totalPoints.length) sarvaMap[KPService.SIGNS[i]] = [totalPoints[i].toString()];
                   }
                   return chartBox(sarvaMap, "சர்வ\\nஅஷ்டவர்க்கம்");
                 })(),
               ],

               if (ashtakavarga['pindas'] != null) ...[
                 pw.SizedBox(height: 20),
                 sectionTitle("பிண்டங்கள்"),
                 (() {
                   final pindas = (ashtakavarga['pindas'] as Map).cast<String, dynamic>();
                   final planets = ["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn"];
                   return pw.Table(
                     border: pw.TableBorder.all(color: borderColor),
                     children: [
                       pw.TableRow(
                         decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F4EFE3')),
                         children: ["கிரகம்", "ராசி பிண்டம்", "கிரக பிண்டம்", "சேர்த்திய பிண்டம்"].map((t) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center))).toList()
                       ),
                       ...planets.map((p) {
                         final pPinda = (pindas[p] as Map? ?? {}).cast<String, dynamic>();
                         final pName = KPService.TAMIL_PLANETS[p] ?? p;
                         return pw.TableRow(
                           children: [
                             pName,
                             pPinda['rasi']?.toString() ?? "0",
                             pPinda['graha']?.toString() ?? "0",
                             pPinda['total']?.toString() ?? "0",
                           ].map((t) => pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(t.toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 10), textAlign: pw.TextAlign.center))).toList()
                         );
                       }).toList()
                     ]
                   );
                 })(),
               ],
            ],

            pw.NewPage(),
            sectionTitle("பொது பலன்கள் (Predictions)"),
            (() {
              final pancha = results['panchangam'] ?? {};
              final basics = results['planet_details'] ?? {};
              final moon = basics['moon'] ?? {};
              final lagna = basics['lagna'] ?? {};
              
              Map<String, dynamic>? activeDasa;
              Map<String, dynamic>? activeBukthi;
              final now = DateTime.now();
              for (var d in dasaList) {
                if (now.isAfter(d['start']) && now.isBefore(d['end'])) {
                  activeDasa = d;
                  for (var b in (d['subPeriods'] as List? ?? [])) {
                    if (now.isAfter(b['start']) && now.isBefore(b['end'])) {
                      activeBukthi = b;
                      break;
                    }
                  }
                  break;
                }
              }

              final String dasaPalanText = activeDasa != null 
                ? "நடப்பு தசை: \${activeDasa['lord']} (\${DateFormat('dd-MM-yyyy').format(activeDasa['end'])} வரை)\\n\${PalangalService.getDetailedDasaPalan(activeDasa['lord'])}\\n\\nநடப்பு புத்தி: \${activeBukthi?['lord'] ?? '-'} (\${activeBukthi != null ? DateFormat('dd-MM-yyyy').format(activeBukthi['end']) : '-'} வரை)\\n\${PalangalService.getDetailedBhuktiPalan(activeBukthi?['lord'])}" 
                : "தசா புத்தி விபரங்கள் இல்லை";

              final palangalListItems = [
                {"title": "லக்ன பலன்", "content": PalangalService.getDetailedLagnaPalan(lagna['rasi'])},
                {"title": "ராசி பலன்", "content": PalangalService.getDetailedRasiPalan(moon['rasi'])},
                {"title": "நட்சத்திர பலன்", "content": PalangalService.getDetailedNakshatraPalan(moon['nakshatra'], moon['pada'])},
                {"title": "யோகம்", "content": PalangalService.getDetailedYogaPalan(pancha['yoga'])},
                {"title": "கர்ணம்", "content": PalangalService.getDetailedKaranaPalan(pancha['karana']?.toString())},
                {"title": "கிழமை", "content": PalangalService.getDetailedWeekdayPalan(pancha['vara'])},
                {"title": "திதி", "content": PalangalService.getDetailedThithiPalan(pancha['tithi'])},
                {"title": "தசா புத்தி பலன்", "content": dasaPalanText},
              ];

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: palangalListItems.map((item) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 15),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item['title']!.toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 13, decoration: pw.TextDecoration.underline)),
                        pw.SizedBox(height: 6),
                        pw.Text(item['content']!.toTamilPdf, style: pw.TextStyle(font: bodyFont, color: PdfColors.black, fontSize: 11)),
                      ]
                    )
                  );
                }).toList()
              );
            })(),
`;

content = content.replace(ashtakavargaBlock.trim(), newAshtakavargaBlock.trim());

fs.writeFileSync('lib/services/full_report_pdf_service.dart', content);
