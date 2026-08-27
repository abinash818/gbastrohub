const fs = require('fs');
let file = fs.readFileSync('lib/services/full_report_pdf_service.dart', 'utf-8');

// 1. Fix pageTheme margins
// We have three occurrences of: margin: const pw.EdgeInsets.all(12),
// But some of them are for buildPageBorder!
// In buildPageBorder:
// child: pw.Container(
//   margin: const pw.EdgeInsets.all(12),
// Let's replace the pageTheme margins which are currently 12
file = file.replace(/pageFormat: PdfPageFormat\.a5\.landscape,\s*margin: const pw\.EdgeInsets\.all\(\d+\),/g, 'pageFormat: PdfPageFormat.a5.landscape,\n        margin: const pw.EdgeInsets.all(35),');

// 2. Fix Pindangal Data (Lowercase to Capitalized planets)
file = file.replace(/final planets = \["sun", "moon", "mars", "mercury", "jupiter", "venus", "saturn"\];/g, 'final planets = ["Sun", "Moon", "Mars", "Mercury", "Jupiter", "Venus", "Saturn"];');

// 3. Move Pindangal to New Page
file = file.replace(/if \(ashtakavarga\['pindas'\] != null\) \.\.\.\[/g, "if (ashtakavarga['pindas'] != null) ...[\n                 pw.NewPage(),");

// 4. Change spaceBetween to spaceAround for Rasi/Navamsa chart
file = file.replace(/mainAxisAlignment: pw\.MainAxisAlignment\.spaceBetween,/g, 'mainAxisAlignment: pw.MainAxisAlignment.spaceAround,');

// 5. Let's make sure the table for Pindangal doesn't touch anything by adding some extra padding if needed, but page margin should cover it.

fs.writeFileSync('lib/services/full_report_pdf_service.dart', file, 'utf-8');
console.log("Fixes applied successfully.");
