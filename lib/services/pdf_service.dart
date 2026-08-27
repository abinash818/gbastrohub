import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'report_pdf_service.dart';
import '../screens/pdf_viewer_screen.dart';

class PdfService {
  static Future<void> generateAndHandle({
    required BuildContext context,
    required String name,
    required String gender,
    required Map<dynamic, dynamic> results,
  }) async {
    // Show loading
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));

    Uint8List? leftLogoBytes;
    Uint8List? rightLogoBytes;
    
    try {
      leftLogoBytes = (await rootBundle.load('assets/images/murugan_icon.png')).buffer.asUint8List();
      rightLogoBytes = (await rootBundle.load('assets/images/muruga_logo.jpg')).buffer.asUint8List();
    } catch (e) {
      debugPrint("Logo Load Error: $e");
    }

    try {
      final pdfBytes = await ReportPdfService.generateHoroscopePdf(
        name: name,
        gender: gender,
        results: results,
        leftLogoBytes: leftLogoBytes,
        rightLogoBytes: rightLogoBytes,
      );
      
      if (!context.mounted) return;
      Navigator.pop(context); // Hide loading

      if (kIsWeb) {
        // web printing could be handled via the printing package if added, else we just do nothing or use a blob url.
        // For now, web is secondary.
      } else {
        final targetFileName = "Horoscope_${name.replaceAll(' ', '_')}.pdf";
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              pdfBytes: pdfBytes,
              fileName: targetFileName,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Hide loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }
}
