const fs = require('fs');

const bak = fs.readFileSync('lib/services/full_report_pdf_service.dart.bak', 'utf-8');
const curr = fs.readFileSync('lib/services/full_report_pdf_service.dart', 'utf-8');

const bakLines = bak.split('\n');
const currLines = curr.split('\n');

// Extract colors
const colors = bakLines.slice(21, 26).join('\n'); // primaryColor to borderColor

// Extract sectionTitle
const sectionTitle = bakLines.slice(43, 59).join('\n');

// Extract chartBox
const chartBox = bakLines.slice(74, 132).join('\n');

// Extract old MultiPage content (from "ராசி மற்றும் நவாம்ச சக்கரம்")
const oldContent = bakLines.slice(271, 513).join('\n');

// Create the new MultiPage block
const newMultiPage = `
    // ----------------------------------------------------
    // OLD PAGES (Restored)
    // ----------------------------------------------------
    pdf.addPage(pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(25),
        theme: pw.ThemeData.withFont(base: bodyFont),
        buildBackground: buildPageBorder,
      ),
      header: (context) => buildHeader(context),
      build: (context) {
        return [
${oldContent}
        ];
      }
    ));
`;

// Insert colors, sectionTitle, chartBox
const insertionPoint1 = currLines.findIndex(l => l.includes('final now = DateTime.now();'));

currLines.splice(insertionPoint1 + 1, 0, colors, sectionTitle, chartBox);

// Replace the comment at the end
const insertionPoint2 = currLines.findIndex(l => l.includes('// End of 9 Pages as requested.'));

currLines.splice(insertionPoint2, 1, newMultiPage);

fs.writeFileSync('lib/services/full_report_pdf_service.dart', currLines.join('\n'), 'utf-8');
console.log('Done!');
