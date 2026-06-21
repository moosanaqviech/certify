import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_what_screen.dart';
import 'screens/onboarding_cert_screen.dart';
import 'screens/onboarding_notify_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bg,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const CertifyApp(),
    ),
  );
}

class CertifyApp extends StatelessWidget {
  const CertifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certify',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding/what': (_) => const OnboardingWhatScreen(),
        '/onboarding/cert': (_) => const OnboardingCertScreen(),
        '/onboarding/notify': (_) => const OnboardingNotifyScreen(),
        '/catalog': (_) => const CatalogScreen(),
        '/lesson': (_) => const LessonScreen(),
        '/downloads': (_) => const DownloadsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
