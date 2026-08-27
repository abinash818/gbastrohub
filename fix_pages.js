const fs = require('fs');
let file = fs.readFileSync('lib/services/full_report_pdf_service.dart', 'utf-8');

// 1. Fix "hora planets maraiyuthu" (hidden planets in small cells)
// Replace planets.join("\n") with planets.join(" ")
file = file.replace(/planets\.join\("\\n"\)/g, 'planets.join(" ")');

// 2. Fix empty pages by reducing SizedBox heights and lineSpacings
// Page 4: Kadavul Vazhthu
file = file.replace(/pw\.SizedBox\(height: 40\),/g, 'pw.SizedBox(height: 15),');
file = file.replace(/lineSpacing: 2\.5\),/g, 'lineSpacing: 1.5),');

// Page 7: Date Long Format
file = file.replace(/pw\.SizedBox\(height: 80\),/g, 'pw.SizedBox(height: 20),');
file = file.replace(/style: pw\.TextStyle\(font: bodyFont, fontSize: 15, lineSpacing: 3\.5\),/g, 'style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 2.0),');

// Page 8: Location Details
file = file.replace(/pw\.SizedBox\(height: 80\),/g, 'pw.SizedBox(height: 20),');
file = file.replace(/style: pw\.TextStyle\(font: bodyFont, fontSize: 15, lineSpacing: 3\.5\),/g, 'style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 2.0),');

// Page 9: Ephemeris Details
file = file.replace(/pw\.SizedBox\(height: 60\),/g, 'pw.SizedBox(height: 20),');
file = file.replace(/pw\.SizedBox\(height: 30\),/g, 'pw.SizedBox(height: 15),');

// 3. Move Sani to 2nd column in Ashtakavarga
// Currently it is: ...((ashtakavarga['individual'] ... ).toList()),
// We will replace the block generating individual points with a pw.Wrap
const ashtakavargaBlockOld = `               ...((ashtakavarga['individual'] as Map<dynamic, dynamic>).entries.map((entry) {
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
               }).toList()),`;

const ashtakavargaBlockNew = `               pw.Wrap(
                 spacing: 40,
                 runSpacing: 10,
                 children: (ashtakavarga['individual'] as Map<dynamic, dynamic>).entries.map((entry) {
                    final pName = KPService.TAMIL_PLANETS[entry.key] ?? entry.key.toString();
                    final points = entry.value as List<int>;
                    return pw.Container(
                      width: 160,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("$pName பரல்கள்".toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 12)),
                          pw.SizedBox(height: 5),
                          pw.Text(points.join(" | ").toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 10))
                        ]
                      )
                    );
                 }).toList()
               ),`;

if(file.includes(ashtakavargaBlockOld)) {
    file = file.replace(ashtakavargaBlockOld, ashtakavargaBlockNew);
} else {
    console.log("Could not find the exact Ashtakavarga block. Please check syntax.");
}

fs.writeFileSync('lib/services/full_report_pdf_service.dart', file, 'utf-8');
console.log("Applied empty page and ashtakavarga fixes!");
