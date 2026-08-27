const fs = require('fs');

let c = fs.readFileSync('lib/screens/horoscope_results_screen.dart', 'utf8');

const newMethods = 
  "  Future<void> _handleFullReport() async {\n" +
  "    setState(() => _isGenerating = true);\n" +
  "    \n" +
  "    showDialog(\n" +
  "      context: context,\n" +
  "      barrierDismissible: false,\n" +
  "      builder: (c) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),\n" +
  "    );\n" +
  "    \n" +
  "    try {\n" +
  "      final astroDetails = await SettingsService.getAstrologerDetails();\n" +
  "      final bytes = await FullReportPdfService.generateFullHoroscopePdf(\n" +
  "        name: widget.results['name'] ?? widget.name,\n" +
  "        gender: widget.results['gender'] ?? '-',\n" +
  "        results: widget.results,\n" +
  "        astroDetails: astroDetails,\n" +
  "      );\n" +
  "      if (!mounted) return;\n" +
  "      Navigator.pop(context); // Close loading\n" +
  "      \n" +
  "      Navigator.push(\n" +
  "        context,\n" +
  "        MaterialPageRoute(\n" +
  "          builder: (context) => PdfViewerScreen(\n" +
  "            pdfBytes: bytes,\n" +
  "            fileName: 'FullHoroscope_${widget.name.replaceAll(\\' \\', \\'_\\')}.pdf',\n" +
  "          ),\n" +
  "        ),\n" +
  "      );\n" +
  "    } catch (e) {\n" +
  "      if (mounted) {\n" +
  "        Navigator.pop(context);\n" +
  "        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));\n" +
  "      }\n" +
  "    } finally {\n" +
  "      if (mounted) {\n" +
  "        setState(() => _isGenerating = false);\n" +
  "      }\n" +
  "    }\n" +
  "  }\n";

// Insert the method before the last brace
const lastBraceIdx = c.lastIndexOf('}');
c = c.substring(0, lastBraceIdx) + newMethods + '}\n';

fs.writeFileSync('lib/screens/horoscope_results_screen.dart', c);
console.log('Added _handleFullReport');
