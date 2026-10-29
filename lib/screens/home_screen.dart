import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/sample_cvs.dart';
import '../l10n/app_strings.dart';
import '../models/cv_model.dart';
import '../pdf/pdf_generator.dart';
import '../state/cv_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/test_ad_banner.dart';
import 'form_screen.dart';
import 'preview_screen.dart';
import 'samples_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final CvProvider cvProvider;
  final SettingsProvider settingsProvider;

  const HomeScreen({
    super.key,
    required this.cvProvider,
    required this.settingsProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Reload immediately upon creation
    widget.cvProvider.loadCvs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.cvProvider.loadCvs();
    }
  }

  Future<void> _refreshData() async {
    await widget.cvProvider.loadCvs();
  }

  void _openCreateCv() async {
    final newCv = CvModel(
      title: 'My CV',
      template: 'classic',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final cvId = await widget.cvProvider.createCv(newCv);
    newCv.id = cvId;

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(
          cv: newCv,
          cvProvider: widget.cvProvider,
          settingsProvider: widget.settingsProvider,
        ),
      ),
    );
    // STALE-REFRESH RULE: Always reload when returning
    await _refreshData();
  }

  void _openEditCv(CvModel cv) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(
          cv: cv,
          cvProvider: widget.cvProvider,
          settingsProvider: widget.settingsProvider,
        ),
      ),
    );
    // STALE-REFRESH RULE: Always reload when returning
    await _refreshData();
  }

  void _openPreview(CvModel cv) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(
          cv: cv,
          cvProvider: widget.cvProvider,
          settingsProvider: widget.settingsProvider,
        ),
      ),
    );
    await _refreshData();
  }

  void _openSamples() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SamplesScreen(
          cvProvider: widget.cvProvider,
          settingsProvider: widget.settingsProvider,
        ),
      ),
    );
    await _refreshData();
  }

  void _useSample(SampleCvDefinition sampleDef) async {
    final sampleCv = sampleDef.createSampleCv();
    final newId = await widget.cvProvider.createCv(sampleCv);
    sampleCv.id = newId;

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(
          cv: sampleCv,
          cvProvider: widget.cvProvider,
          settingsProvider: widget.settingsProvider,
          initialStep: 0, // Starts at Step 1 Personal per locked rule
        ),
      ),
    );
    await _refreshData();
  }

  void _showRenameDialog(CvModel cv) {
    final s = widget.settingsProvider.strings;
    final textController = TextEditingController(text: cv.title);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(s.renameCv),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: cv.title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newTitle = textController.text.trim();
              if (newTitle.isNotEmpty && newTitle != cv.title) {
                await widget.cvProvider.updateTitle(cv.id!, newTitle);
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              await _refreshData();
            },
            child: Text(s.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(CvModel cv) {
    final s = widget.settingsProvider.strings;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(s.deleteCvConfirmTitle),
        content: Text(s.deleteCvConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await widget.cvProvider.deleteCv(cv.id!);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              await _refreshData();
            },
            child: Text(s.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _shareCvPdf(CvModel cv) async {
    try {
      final pdfBytes = await PdfGenerator.generatePdf(cv);
      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = cv.title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final filePath = '${tempDir.path}/CV_$sanitizedTitle.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'application/pdf')],
          text: '${cv.title} - CV Maker Pakistan',
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

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settingsProvider.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([widget.cvProvider, widget.settingsProvider]),
      builder: (context, _) {
        final cvs = widget.cvProvider.cvs;
        final allSamples = SampleCvsData.getAllSamples();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.emerald,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.edit_document, color: AppColors.gold, size: 28),
            ),
            title: Text(
              s.myCvs,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: 'Settings',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        cvProvider: widget.cvProvider,
                        settingsProvider: widget.settingsProvider,
                      ),
                    ),
                  );
                  await _refreshData();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Top Action Strip
              Container(
                color: AppColors.emerald,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white, size: 24),
                        label: Text(
                          s.createNewCv,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        onPressed: _openCreateCv,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Sample CVs horizontal strip
                    Row(
                      children: [
                        Text(
                          s.sampleCvs,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _openSamples,
                          child: Row(
                            children: [
                              Text(
                                'View All (6)',
                                style: TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.goldLight, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: allSamples.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final sample = allSamples[index];
                          return ActionChip(
                            avatar: Icon(sample.icon, size: 16, color: AppColors.emerald),
                            label: Text(
                              sample.roleName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.emeraldDark,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            onPressed: () => _useSample(sample),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // CV List or Empty State
              Expanded(
                child: widget.cvProvider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.emerald))
                    : cvs.isEmpty
                        ? _buildEmptyState(s, isDark, allSamples)
                        : RefreshIndicator(
                            color: AppColors.emerald,
                            onRefresh: _refreshData,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              itemCount: cvs.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final cv = cvs[index];
                                return _buildCvCard(cv, s, isDark);
                              },
                            ),
                          ),
              ),

              // Bottom Test AdMob Banner
              const TestAdBannerWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(AppStrings s, bool isDark, List<SampleCvDefinition> samples) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.emeraldTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 48,
                color: AppColors.emerald,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              s.emptyTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                s.createFirstCv,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: _openCreateCv,
            ),
            const SizedBox(height: 24),
            Text(
              '${s.sampleCvs} se shuru karein:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: samples.map((sample) {
                return OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.emerald,
                    side: const BorderSide(color: AppColors.emerald),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: Icon(sample.icon, size: 16),
                  label: Text(sample.roleName, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _useSample(sample),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCvCard(CvModel cv, AppStrings s, bool isDark) {
    final templateDisplayName = cv.template[0].toUpperCase() + cv.template.substring(1);
    final cardBg = isDark ? AppColors.cardDark : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cv.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textLight : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldTint,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              templateDisplayName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emeraldDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${s.lastUpdated}: ${_formatDate(cv.updatedAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                  onSelected: (value) async {
                    switch (value) {
                      case 'duplicate':
                        await widget.cvProvider.duplicateCv(cv.id!);
                        await _refreshData();
                        break;
                      case 'rename':
                        _showRenameDialog(cv);
                        break;
                      case 'share':
                        _shareCvPdf(cv);
                        break;
                      case 'delete':
                        _confirmDelete(cv);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          const Icon(Icons.copy, size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          Text(s.duplicate),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note, size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          Text(s.rename),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.share_outlined, size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 10),
                          Text(s.sharePdf),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                          const SizedBox(width: 10),
                          Text(s.delete, style: const TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.emerald,
                      side: const BorderSide(color: AppColors.emerald, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(s.edit, style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _openEditCv(cv),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: Text(s.viewPdf, style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _openPreview(cv),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
