import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../theme/app_colors.dart';
import 'dart:typed_data';

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
  final TransformationController _transformationController = TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.05) {
      setState(() {
        _currentScale = scale;
      });
    }
  }

  void _zoomIn() {
    final next = (_currentScale + 0.8).clamp(1.0, 15.0);
    _zoomTo(next);
  }

  void _zoomOut() {
    final next = (_currentScale - 0.8).clamp(1.0, 15.0);
    _zoomTo(next);
  }

  void _resetZoom() {
    _zoomTo(1.0);
  }

  void _zoomTo(double scale) {
    if (scale <= 1.0) {
      _transformationController.value = Matrix4.identity();
    } else {
      final size = MediaQuery.of(context).size;
      final x = (size.width - size.width * scale) / 2;
      final y = (size.height - size.height * scale) / 2;
      _transformationController.value = Matrix4(
        scale, 0, 0, 0,
        0, scale, 0, 0,
        0, 0, 1, 0,
        x, y, 0, 1,
      );
    }
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
          PdfPreview.builder(
            build: (format) => widget.pdfBytes,
            dpi: 220,
            allowPrinting: true,
            allowSharing: true,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            pdfFileName: widget.fileName,
            loadingWidget: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            actions: [
              PdfPreviewAction(
                icon: Icon(_isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded),
                onPressed: (context, build, pageFormat) {
                  setState(() {
                    _isFullscreen = !_isFullscreen;
                  });
                },
              ),
            ],
            pagesBuilder: (context, pages) {
              return InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 15.0,
                panEnabled: true,
                scaleEnabled: true,
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: pages.map((page) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image(
                          image: page.image,
                          fit: BoxFit.contain,
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              );
            },
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
                GestureDetector(
                  onTap: _resetZoom,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${(_currentScale * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  backgroundColor: AppColors.primary,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.zoom_in, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  backgroundColor: AppColors.primary,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.zoom_out, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
