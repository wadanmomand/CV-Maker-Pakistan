import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/cv_model.dart';
import '../pdf/pdf_generator.dart';
import '../state/cv_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme.dart';
import 'form_screen.dart';
import 'template_pick_screen.dart';

class PreviewScreen extends StatefulWidget {
  final CvModel cv;
  final CvProvider cvProvider;
  final SettingsProvider settingsProvider;

  const PreviewScreen({
    super.key,
    required this.cv,
    required this.cvProvider,
    required this.settingsProvider,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final int _pageCount = 1;

  void _onEditTapped() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(
          cv: widget.cv,
          cvProvider: widget.cvProvider,
          settingsProvider: widget.settingsProvider,
        ),
      ),
    );
  }

  void _onTemplateTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplatePickScreen(
          cv: widget.cv,
          cvProvider: widget.cvProvider,
          settingsProvider: widget.settingsProvider,
        ),
      ),
    );
  }

  Future<void> _onShareTapped() async {
    try {
      final pdfBytes = await PdfGenerator.generatePdf(widget.cv);
      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = widget.cv.title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final fileName = 'CV_$sanitizedTitle.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          text: '${widget.cv.title} - CV Maker Pakistan',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing PDF: $e')),
        );
      }
    }
  }

  Future<void> _onDownloadTapped() async {
    final s = widget.settingsProvider.strings;
    try {
      final pdfBytes = await PdfGenerator.generatePdf(widget.cv);
      Directory? saveDir;
      try {
        saveDir = await getDownloadsDirectory();
      } catch (_) {}
      saveDir ??= await getApplicationDocumentsDirectory();

      final sanitizedTitle = widget.cv.title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final fileName = 'CV_${sanitizedTitle}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${saveDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${s.pdfDownloadedToast}$fileName'),
            backgroundColor: AppColors.emerald,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settingsProvider.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.previewTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // WYSIWYG A4 Preview with Shadow
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              child: PdfPreview(
                build: (format) async {
                  final bytes = await PdfGenerator.generatePdf(widget.cv);
                  // Approximate page count from byte size or content
                  return bytes;
                },
                useActions: false, // We supply our own locked bottom buttons
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                scrollViewDecoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                ),
                initialPageFormat: PdfPageFormat.a4,
                pdfPreviewPageDecoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                loadingWidget: const Center(
                  child: CircularProgressIndicator(color: AppColors.emerald),
                ),
              ),
            ),
          ),

          // Soft warning if CV exceeds 2 pages
          if (_pageCount > 2)
            Container(
              width: double.infinity,
              color: const Color(0xFFFEF3C7),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.pageExceedWarning,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Action Buttons: Edit, Template, Share, Download PDF
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  offset: const Offset(0, -3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                // Edit Button
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.emerald, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _onEditTapped,
                    child: Text(
                      s.editButton,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Template Button
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.emerald, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _onTemplateTapped,
                    child: Text(
                      s.templateButton,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Share Button
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.gold, width: 1.2),
                      foregroundColor: AppColors.goldDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _onShareTapped,
                    child: Text(
                      s.shareButton,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Download PDF Button
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _onDownloadTapped,
                    child: Text(
                      s.downloadPdfButton,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
