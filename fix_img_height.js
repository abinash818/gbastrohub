const fs = require('fs');
let file = fs.readFileSync('lib/services/full_report_pdf_service.dart', 'utf-8');

// Fix Ganapathy image
file = file.replace(/pw\.Image\(pw\.MemoryImage\(ganapathyImg\), width: 120\)/g, 'pw.Image(pw.MemoryImage(ganapathyImg), height: 120, fit: pw.BoxFit.contain)');

// Fix Murugan image (the cause of Page 4 overflow)
file = file.replace(/pw\.Image\(pw\.MemoryImage\(muruganImg\), width: 150\)/g, 'pw.Image(pw.MemoryImage(muruganImg), height: 130, fit: pw.BoxFit.contain)');

fs.writeFileSync('lib/services/full_report_pdf_service.dart', file, 'utf-8');
console.log("Image heights constrained.");
