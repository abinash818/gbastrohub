const fs = require('fs');
let file = fs.readFileSync('lib/services/full_report_pdf_service.dart', 'utf-8');

// FIX PAGE 2: Reduce sizes so it fits in A5 Landscape
file = file.replace(/padding: const pw\.EdgeInsets\.symmetric\(vertical: 3\),/g, 'padding: const pw.EdgeInsets.symmetric(vertical: 0.5),');
// Note: Only replace fontSize: 14 for the rowItem text
file = file.replace(/pw\.SizedBox\(width: 150, child: pw\.Text\(label\.toTamilPdf, style: pw\.TextStyle\(font: bodyFont, fontSize: 14\)\)\),/g, 'pw.SizedBox(width: 150, child: pw.Text(label.toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 12))),');
file = file.replace(/pw\.Text\(": ", style: pw\.TextStyle\(font: bodyFont, fontSize: 14\)\),/g, 'pw.Text(": ", style: pw.TextStyle(font: bodyFont, fontSize: 12)),');
file = file.replace(/pw\.Expanded\(child: pw\.Text\(value\.toTamilPdf, style: pw\.TextStyle\(font: bodyFont, fontSize: 14\)\)\),/g, 'pw.Expanded(child: pw.Text(value.toTamilPdf, style: pw.TextStyle(font: bodyFont, fontSize: 12))),');

// Also reduce the gap above the list slightly
file = file.replace(/pw\.SizedBox\(height: 15\),\s*pw\.Padding\(\s*padding: const pw\.EdgeInsets\.only\(left: 30\)/g, 'pw.SizedBox(height: 5),\n            pw.Padding(\n              padding: const pw.EdgeInsets.only(left: 30)');


// FIX PAGE 4: Handle muruganImg == null gracefully so the Row doesn't collapse to 0 height
const oldPage4Block = `            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (muruganImg != null) pw.Image(pw.MemoryImage(muruganImg), width: 150) else pw.SizedBox(width: 150),
                pw.SizedBox(width: 30),
                pw.Expanded(
                  child: pw.Text(
                    "தங்க மான்மழு வோடாந்தித்\\nதன்மதி தலையிற் கொண்டோன்\\nமங்கையர் பதிக்குச் சொன்ன\\nமாமொழிச் சோதிடத்தை\\nஇங்குநா முரைப்பதற்கோர்\\nஇமையெனும் பிழை வராமற்\\nசெங்கண்மால் மருகன் யானைச்\\nசிரன் பதங் காப்பதாமே.\\nசுபமஸ்து...".toTamilPdf,
                    style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 1.5),
                    textAlign: pw.TextAlign.center
                  )
                )
              ]
            )`;

const newPage4Block = `            if (muruganImg != null)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(pw.MemoryImage(muruganImg), width: 150),
                  pw.SizedBox(width: 30),
                  pw.Expanded(
                    child: pw.Text(
                      "தங்க மான்மழு வோடாந்தித்\\nதன்மதி தலையிற் கொண்டோன்\\nமங்கையர் பதிக்குச் சொன்ன\\nமாமொழிச் சோதிடத்தை\\nஇங்குநா முரைப்பதற்கோர்\\nஇமையெனும் பிழை வராமற்\\nசெங்கண்மால் மருகன் யானைச்\\nசிரன் பதங் காப்பதாமே.\\nசுபமஸ்து...".toTamilPdf,
                      style: pw.TextStyle(font: bodyFont, fontSize: 13, lineSpacing: 1.5),
                      textAlign: pw.TextAlign.center
                    )
                  )
                ]
              )
            else
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                child: pw.Text(
                  "தங்க மான்மழு வோடாந்தித்\\nதன்மதி தலையிற் கொண்டோன்\\nமங்கையர் பதிக்குச் சொன்ன\\nமாமொழிச் சோதிடத்தை\\nஇங்குநா முரைப்பதற்கோர்\\nஇமையெனும் பிழை வராமற்\\nசெங்கண்மால் மருகன் யானைச்\\nசிரன் பதங் காப்பதாமே.\\nசுபமஸ்து...".toTamilPdf,
                  style: pw.TextStyle(font: bodyFont, fontSize: 14, lineSpacing: 2.0),
                  textAlign: pw.TextAlign.center
                )
              )`;

if(file.includes(oldPage4Block)) {
    file = file.replace(oldPage4Block, newPage4Block);
} else {
    console.log("Could not find Page 4 block. Maybe it has different formatting.");
}

fs.writeFileSync('lib/services/full_report_pdf_service.dart', file, 'utf-8');
console.log("Applied fixes for Page 2 and Page 4");
