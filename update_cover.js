const fs = require('fs');

let c = fs.readFileSync('lib/services/full_report_pdf_service.dart', 'utf8');

const targetStr = `                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: primaryColor, width: 1.5),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text("ஆதிகுரு ஜோதிட மென்பொருள்".toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 14)),
                      ]
                    )
                  ),
                  pw.SizedBox(height: 10),`;

const newStr = `                  pw.Container(
                    padding: const pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: primaryColor, width: 1.5),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text("ஜோதிடர் விபரம்".toTamilPdf, style: pw.TextStyle(font: headingFont, color: primaryColor, fontSize: 16)),
                        pw.SizedBox(height: 8),
                        pw.Text((astroDetails?['name'] ?? '').toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 14)),
                        if ((astroDetails?['address'] ?? '').isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text((astroDetails?['address'] ?? '').toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 12), textAlign: pw.TextAlign.center),
                        ],
                        if ((astroDetails?['phone'] ?? '').isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text("போன்: \${astroDetails?['phone']}".toTamilPdf, style: pw.TextStyle(font: bodyFont, color: primaryColor, fontSize: 12)),
                        ]
                      ]
                    )
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text("Software developed by Aadhiguru / Mobile: 9600666225", style: pw.TextStyle(font: bodyFont, color: PdfColors.black, fontSize: 10)),
                  pw.SizedBox(height: 10),`;

c = c.replace(targetStr, newStr);

fs.writeFileSync('lib/services/full_report_pdf_service.dart', c);
console.log('Cover Page updated!');
