import 'package:flutter/material.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const PrivacyPolicyScreen({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final s = settingsProvider.strings;
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
          s.privacyPolicy,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for CV Maker Pakistan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textLight : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Developer: Aatish Studio  |  Effective Date: October 2026',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const Divider(height: 24),
            _buildSection(
              title: '1. On-Device Storage & Zero Server Rule',
              content:
                  'CV Maker Pakistan is built as a fully offline-first utility. All resume details (including full names, contact numbers, email addresses, educational history, work experience, and profile photos) are stored strictly in an encrypted on-device SQLite database on your local phone. We have zero servers, zero external databases, zero user registration, and zero cloud synchronization.',
              isDark: isDark,
            ),
            _buildSection(
              title: '2. Profile Photos & Media',
              content:
                  'Profile photos selected for your CV are saved strictly in your device\'s local application sandbox storage. Photos are never uploaded, analyzed, or transmitted anywhere. When you delete a CV or choose "Delete All Data", the associated local photo file is permanently deleted immediately from your storage.',
              isDark: isDark,
            ),
            _buildSection(
              title: '3. PDF Generation & Sharing',
              content:
                  'All PDF documents are generated directly on your device utilizing on-device rendering algorithms. Your resume documents contain real, selectable text without any watermarks. Documents are only shared or transferred when you explicitly initiate a share action through your phone\'s system share sheet (e.g., via WhatsApp, Gmail, or local printing). The application never auto-transmits or backs up files silently.',
              isDark: isDark,
            ),
            _buildSection(
              title: '4. Backup & Restore (Local JSON)',
              content:
                  'Backup export and restore features operate purely through local JSON files on your device. You have complete ownership and control over where your backup file is stored or shared.',
              isDark: isDark,
            ),
            _buildSection(
              title: '5. Advertising',
              content:
                  'This build contains Google AdMob test banner placements only. No third-party data tracking or behavioral targeting SDKs are integrated.',
              isDark: isDark,
            ),
            _buildSection(
              title: '6. Contact & Support',
              content:
                  'If you have any questions or feedback regarding this privacy policy or your data rights, please contact Aatish Studio via the developer channel.',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.goldLight : AppColors.emerald,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textLight : AppColors.textDark,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
