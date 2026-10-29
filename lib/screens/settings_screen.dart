import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_strings.dart';
import '../state/cv_provider.dart';
import '../state/settings_provider.dart';
import '../theme/app_theme.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  final CvProvider cvProvider;
  final SettingsProvider settingsProvider;

  const SettingsScreen({
    super.key,
    required this.cvProvider,
    required this.settingsProvider,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showLanguageDialog() {
    final s = widget.settingsProvider.strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.languageSection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(s.romanUrduOption),
              leading: Icon(
                widget.settingsProvider.language == AppLanguage.romanUrdu
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppColors.emerald,
              ),
              onTap: () {
                widget.settingsProvider.setLanguage(AppLanguage.romanUrdu);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(s.englishOption),
              leading: Icon(
                widget.settingsProvider.language == AppLanguage.english
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppColors.emerald,
              ),
              onTap: () {
                widget.settingsProvider.setLanguage(AppLanguage.english);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final s = widget.settingsProvider.strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.themeSection),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(s.lightTheme),
              leading: Icon(
                widget.settingsProvider.themeMode == ThemeMode.light
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppColors.emerald,
              ),
              onTap: () {
                widget.settingsProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(s.darkTheme),
              leading: Icon(
                widget.settingsProvider.themeMode == ThemeMode.dark
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppColors.emerald,
              ),
              onTap: () {
                widget.settingsProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportJsonBackup() async {
    try {
      final jsonStr = await widget.cvProvider.exportJson();
      final tempDir = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      final filePath = '${tempDir.path}/cv_maker_backup_$dateStr.json';
      final file = File(filePath);
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath, mimeType: 'application/json')],
          text: 'CV Maker Pakistan - Backup JSON ($dateStr)',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup export failed: $e')),
        );
      }
    }
  }

  void _importJsonBackup() async {
    final s = widget.settingsProvider.strings;
    try {
      final pickedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (pickedFiles.isEmpty || pickedFiles.first.path == null) return;

      final file = File(pickedFiles.first.path!);
      final content = await file.readAsString();

      if (!mounted) return;

      // Ask: Merge or Replace All
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.importDialogTitle),
          content: Text(s.importDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            // Default recommended: Merge
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await widget.cvProvider.importJson(content, merge: true);
                _showImportResult(success);
              },
              child: Text(s.mergeOption, style: const TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await widget.cvProvider.importJson(content, merge: false);
                _showImportResult(success);
              },
              child: Text(s.replaceOption, style: const TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import error: $e')),
        );
      }
    }
  }

  void _showImportResult(bool success) {
    final s = widget.settingsProvider.strings;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? s.importSuccess : s.invalidJsonError),
          backgroundColor: success ? AppColors.emerald : AppColors.danger,
        ),
      );
    }
  }

  void _startDeleteAllDataFlow() {
    final s = widget.settingsProvider.strings;
    // Step 1 Dialog
    showDialog(
      context: context,
      builder: (firstDialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(s.deleteAllFirstDialogTitle)),
          ],
        ),
        content: Text(s.deleteAllFirstDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(firstDialogCtx),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(firstDialogCtx);
              _showSecondConfirmDialog();
            },
            child: Text(s.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSecondConfirmDialog() {
    final s = widget.settingsProvider.strings;
    final textController = TextEditingController();
    bool canConfirm = false;

    showDialog(
      context: context,
      builder: (secondDialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(s.deleteAllSecondDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.deleteAllSecondDialogBody),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: s.deleteConfirmWord,
                  errorText: canConfirm ? null : 'Type "${s.deleteConfirmWord}" exactly',
                ),
                onChanged: (val) {
                  setDialogState(() {
                    canConfirm = val.trim().toUpperCase() == s.deleteConfirmWord;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(secondDialogCtx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: canConfirm
                  ? () async {
                      await widget.cvProvider.deleteAllData();
                      if (secondDialogCtx.mounted) {
                        Navigator.pop(secondDialogCtx);
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(s.dataDeletedToast),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                        // Pop back to Home empty state
                        Navigator.pop(context);
                      }
                    }
                  : null,
              child: Text(s.delete, style: const TextStyle(color: Colors.white)),
            ),
          ],
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
          s.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 1. Language Row
          _buildSettingsTile(
            icon: Icons.language,
            title: s.languageSection,
            subtitle: widget.settingsProvider.language == AppLanguage.romanUrdu
                ? s.romanUrduOption
                : s.englishOption,
            onTap: _showLanguageDialog,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // 2. Theme Row
          _buildSettingsTile(
            icon: Icons.brightness_6_outlined,
            title: s.themeSection,
            subtitle: widget.settingsProvider.themeMode == ThemeMode.light
                ? s.lightTheme
                : s.darkTheme,
            onTap: _showThemeDialog,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // 3. Backup: Export JSON
          _buildSettingsTile(
            icon: Icons.upload_file_outlined,
            title: s.exportJson,
            subtitle: s.exportJsonSub,
            onTap: _exportJsonBackup,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // 4. Restore: Import JSON
          _buildSettingsTile(
            icon: Icons.file_download_outlined,
            title: s.importJson,
            subtitle: s.importJsonSub,
            onTap: _importJsonBackup,
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // 5. Privacy Policy
          _buildSettingsTile(
            icon: Icons.security_outlined,
            title: s.privacyPolicy,
            subtitle: s.privacyPolicySub,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrivacyPolicyScreen(settingsProvider: widget.settingsProvider),
                ),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 10),

          // 6. About
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: s.aboutSection,
            subtitle: '${s.appName}\n${s.appVersion}\n${s.developerName}',
            onTap: null,
            isDark: isDark,
          ),
          const SizedBox(height: 24),

          // 7. Delete All Data (Red outline row at bottom)
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.7), width: 1.5),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.danger, size: 28),
              title: Text(
                s.deleteAllData,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                s.deleteAllDataSub,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.danger),
              onTap: _startDeleteAllDataFlow,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.emerald, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? AppColors.textLight : AppColors.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: AppColors.textMuted)
            : null,
        onTap: onTap,
      ),
    );
  }
}
