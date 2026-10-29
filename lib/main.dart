import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'state/cv_provider.dart';
import 'state/settings_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system navigation bar & status bar colors
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  final cvProvider = CvProvider();
  await cvProvider.loadCvs();

  runApp(CvMakerApp(
    settingsProvider: settingsProvider,
    cvProvider: cvProvider,
  ));
}

class CvMakerApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final CvProvider cvProvider;

  const CvMakerApp({
    super.key,
    required this.settingsProvider,
    required this.cvProvider,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'CV Maker Pakistan',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.themeMode,
          home: HomeScreen(
            cvProvider: cvProvider,
            settingsProvider: settingsProvider,
          ),
        );
      },
    );
  }
}
