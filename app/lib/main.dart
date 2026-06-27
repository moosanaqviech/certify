import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'services/settings_store.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bg,
  ));

  final settingsStore = SharedPrefsSettingsStore();
  await settingsStore.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(settingsStore),
      child: const CertifyApp(),
    ),
  );
}

class CertifyApp extends StatelessWidget {
  const CertifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp(
      title: 'Certify',
      theme: state.reduceMotion
          ? AppTheme.theme.copyWith(pageTransitionsTheme: _noPageTransitions)
          : AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      // Apply the user's text-size and reduce-motion preferences app-wide.
      // Reading them here (via context.watch above) means a toggle in Settings
      // re-themes every screen instantly.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(state.textScale),
            disableAnimations: state.reduceMotion,
          ),
          child: child!,
        );
      },
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

/// Used when "reduce motion" is on: route changes appear instantly instead of
/// sliding/fading in.
const _noPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _NoTransitionsBuilder(),
    TargetPlatform.iOS: _NoTransitionsBuilder(),
    TargetPlatform.linux: _NoTransitionsBuilder(),
    TargetPlatform.macOS: _NoTransitionsBuilder(),
    TargetPlatform.windows: _NoTransitionsBuilder(),
  },
);

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
