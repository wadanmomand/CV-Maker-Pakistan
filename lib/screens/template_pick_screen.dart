import 'package:flutter/material.dart';
import '../models/cv_model.dart';
import '../state/cv_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme.dart';
import 'preview_screen.dart';

class TemplatePickScreen extends StatefulWidget {
  final CvModel cv;
  final CvProvider cvProvider;
  final SettingsProvider settingsProvider;

  const TemplatePickScreen({
    super.key,
    required this.cv,
    required this.cvProvider,
    required this.settingsProvider,
  });

  @override
  State<TemplatePickScreen> createState() => _TemplatePickScreenState();
}

class _TemplatePickScreenState extends State<TemplatePickScreen> {
  late String _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = widget.cv.template.toLowerCase();
    if (!['classic', 'modern', 'minimal', 'photo'].contains(_selectedTemplate)) {
      _selectedTemplate = 'classic';
    }
  }

  void _onUseTemplate() async {
    widget.cv.template = _selectedTemplate;
    await widget.cvProvider.updateTemplate(widget.cv.id!, _selectedTemplate);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewScreen(
          cv: widget.cv,
          cvProvider: widget.cvProvider,
          settingsProvider: widget.settingsProvider,
        ),
      ),
    );
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
          s.chooseTemplate,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Subtitle Header
          Container(
            width: double.infinity,
            color: AppColors.emerald,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              s.chooseTemplateSubtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
          ),

          // 2x2 Grid of Templates
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: [
                  _buildTemplateCard(
                    id: 'classic',
                    title: s.templateClassic,
                    subtitle: s.templateClassicSub,
                    isDark: isDark,
                    thumbnailBuilder: () => _buildClassicThumbnail(),
                  ),
                  _buildTemplateCard(
                    id: 'modern',
                    title: s.templateModern,
                    subtitle: s.templateModernSub,
                    isDark: isDark,
                    thumbnailBuilder: () => _buildModernThumbnail(),
                  ),
                  _buildTemplateCard(
                    id: 'minimal',
                    title: s.templateMinimal,
                    subtitle: s.templateMinimalSub,
                    isDark: isDark,
                    thumbnailBuilder: () => _buildMinimalThumbnail(),
                  ),
                  _buildTemplateCard(
                    id: 'photo',
                    title: s.templatePhoto,
                    subtitle: s.templatePhotoSub, // "Includes photo"
                    isDark: isDark,
                    thumbnailBuilder: () => _buildPhotoThumbnail(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, -3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _onUseTemplate,
                child: Text(
                  s.useTemplate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard({
    required String id,
    required String title,
    required String subtitle,
    required bool isDark,
    required Widget Function() thumbnailBuilder,
  }) {
    final isSelected = _selectedTemplate == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTemplate = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.gold : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.gold.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini A4 page preview representation
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D2A) : const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2C394B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: thumbnailBuilder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? AppColors.textLight : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Gold check badge if selected
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 15, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Thumbnail Renderers ---
  Widget _buildClassicThumbnail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 8, width: 45, color: AppColors.emerald),
        const SizedBox(height: 4),
        Container(height: 3, width: 60, color: Colors.grey.shade400),
        const SizedBox(height: 6),
        Container(height: 1, color: AppColors.emerald),
        const SizedBox(height: 6),
        Container(height: 5, width: 30, color: AppColors.emerald),
        const SizedBox(height: 3),
        Container(height: 3, width: 80, color: Colors.grey.shade300),
        const SizedBox(height: 2),
        Container(height: 3, width: 70, color: Colors.grey.shade300),
        const SizedBox(height: 6),
        Container(height: 5, width: 35, color: AppColors.emerald),
        const SizedBox(height: 3),
        Container(height: 3, width: 85, color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildModernThumbnail() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 28,
          decoration: BoxDecoration(
            color: AppColors.emerald.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Container(width: 14, height: 14, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.emerald)),
              const SizedBox(height: 6),
              Container(height: 3, width: 18, color: AppColors.emerald),
              const SizedBox(height: 4),
              Container(height: 2, width: 20, color: Colors.grey.shade400),
              const SizedBox(height: 6),
              Container(height: 3, width: 18, color: AppColors.emerald),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Main
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 7, width: 40, color: AppColors.emerald),
              const SizedBox(height: 4),
              Container(height: 3, width: 45, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Container(height: 4, width: 30, color: AppColors.emerald),
              const SizedBox(height: 3),
              Container(height: 3, width: double.infinity, color: Colors.grey.shade300),
              const SizedBox(height: 2),
              Container(height: 3, width: 40, color: Colors.grey.shade300),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalThumbnail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 6, width: 45, color: Colors.black87),
        const SizedBox(height: 3),
        Container(height: 2, width: 50, color: Colors.grey.shade500),
        const SizedBox(height: 8),
        Container(height: 1, color: Colors.grey.shade300),
        const SizedBox(height: 8),
        Container(height: 4, width: 25, color: Colors.black87),
        const SizedBox(height: 3),
        Container(height: 2, width: 75, color: Colors.grey.shade400),
        const SizedBox(height: 6),
        Container(height: 4, width: 25, color: Colors.black87),
        const SizedBox(height: 3),
        Container(height: 2, width: 70, color: Colors.grey.shade400),
      ],
    );
  }

  Widget _buildPhotoThumbnail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.emerald.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.emerald),
                child: const Icon(Icons.person, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 5, width: 35, color: AppColors.emerald),
                  const SizedBox(height: 2),
                  Container(height: 2, width: 25, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 4, width: 30, color: AppColors.emerald),
        const SizedBox(height: 3),
        Container(height: 3, width: double.infinity, color: Colors.grey.shade300),
        const SizedBox(height: 6),
        Container(height: 4, width: 30, color: AppColors.emerald),
        const SizedBox(height: 3),
        Container(height: 3, width: 65, color: Colors.grey.shade300),
      ],
    );
  }
}
