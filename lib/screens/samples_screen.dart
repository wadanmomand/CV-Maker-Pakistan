import 'package:flutter/material.dart';
import '../data/sample_cvs.dart';
import '../state/cv_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme.dart';
import 'form_screen.dart';

class SamplesScreen extends StatelessWidget {
  final CvProvider cvProvider;
  final SettingsProvider settingsProvider;

  const SamplesScreen({
    super.key,
    required this.cvProvider,
    required this.settingsProvider,
  });

  void _onUseSample(BuildContext context, SampleCvDefinition sampleDef) async {
    final sampleCv = sampleDef.createSampleCv();
    // Inserts new CV into SQLite
    final newId = await cvProvider.createCv(sampleCv);
    sampleCv.id = newId;

    if (!context.mounted) return;
    // Opens form at Step 1 Personal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(
          cv: sampleCv,
          cvProvider: cvProvider,
          settingsProvider: settingsProvider,
          initialStep: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = settingsProvider.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final samples = SampleCvsData.getAllSamples();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.sampleCvsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Subtitle header notice
          Container(
            width: double.infinity,
            color: AppColors.emerald,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Text(
              s.sampleNotice,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            ),
          ),

          // Scrollable list of 6 sample role cards
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: samples.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sample = samples[index];
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Emerald Circle Role Icon (Simple line icon, NOT emoji)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.emeraldTint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sample.icon,
                            color: AppColors.emerald,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Role name and description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sample.roleName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sample.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Gold Use Sample button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _onUseSample(context, sample),
                          child: Text(
                            s.useSampleButton,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
