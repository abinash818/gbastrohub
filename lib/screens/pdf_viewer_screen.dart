import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../theme/app_colors.dart';
import 'dart:typed_data';
import 'dart:io';

class PdfViewerScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isFullscreen = false;
  double _zoomScale = 0.8; // default to slightly smaller so 1 page fits nicely

  void _zoomIn() {
    setState(() {
      if (_zoomScale < 8.0) _zoomScale += 0.25;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoomScale > 0.3) _zoomScale -= 0.25;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullscreen ? null : AppBar(
        title: Text(widget.fileName.replaceAll('_', ' '), 
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.primary, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          PdfPreview(
            build: (format) => widget.pdfBytes,
            allowPrinting: true,
            allowSharing: true,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            maxPageWidth: MediaQuery.of(context).size.width * _zoomScale,
            pdfFileName: widget.fileName,
            loadingWidget: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            actions: [
              PdfPreviewAction(
                icon: const Icon(Icons.zoom_in),
                onPressed: (context, build, pageFormat) => _zoomIn(),
              ),
              PdfPreviewAction(
                icon: const Icon(Icons.zoom_out),
                onPressed: (context, build, pageFormat) => _zoomOut(),
              ),
              PdfPreviewAction(
                icon: Icon(_isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded),
                onPressed: (context, build, pageFormat) {
                  setState(() {
                    _isFullscreen = !_isFullscreen;
                  });
                },
              ),
            ],
          ),
          if (_isFullscreen)
            Positioned(
              top: 10,
              left: 10,
              child: FloatingActionButton.small(
                backgroundColor: Colors.white,
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  backgroundColor: AppColors.primary,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.zoom_in, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  backgroundColor: AppColors.primary,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.zoom_out, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
