import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/cert.dart';
import '../state.dart';
import '../theme.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  static const _fallbackUrl =
      'https://certify.courses/databricks-data-engineer-associate/';

  late final WebViewController _controller;
  bool _loading = true;
  double _appliedScale = 1.0;
  bool _started = false;
  Cert? _cert;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (!mounted) return;
          setState(() => _loading = false);
          // Match the lesson text to the app's text-size setting once loaded.
          _applyTextZoom(context.read<AppState>().textScale);
        },
      ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The Cert arrives as a route argument; load its URL once it's available.
    if (_started) return;
    _started = true;
    _cert = ModalRoute.of(context)?.settings.arguments as Cert?;
    _controller.loadRequest(Uri.parse(_cert?.lessonUrl ?? _fallbackUrl));
  }

  /// Scale the remote lesson's text to mirror the in-app text-size choice.
  /// `text-size-adjust` is honoured by both Android and iOS WebViews, so one
  /// CSS injection covers both platforms without platform-specific controllers.
  void _applyTextZoom(double scale) {
    _appliedScale = scale;
    final pct = (scale * 100).round();
    _controller.runJavaScript(
      "document.documentElement.style.webkitTextSizeAdjust='$pct%';"
      "document.documentElement.style.textSizeAdjust='$pct%';",
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-apply zoom if the text-size setting changes while the lesson is open.
    final scale = context.watch<AppState>().textScale;
    if (!_loading && scale != _appliedScale) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyTextZoom(scale);
      });
    }

    final accent = _cert?.accent ?? AppTheme.accent;

    // Route the Android system back button/gesture through the same handler as
    // the on-screen chevron: step back through the WebView first, then exit.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF13141F),
        body: SafeArea(
          child: Column(
            children: [
              // Native top bar
              Container(
                color: const Color(0xFF13141F),
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _onBack,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2130),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.hairline),
                        ),
                        child: const Center(
                          child: Text('←',
                              style: TextStyle(
                                  color: AppTheme.ink,
                                  fontSize: 19,
                                  height: 1)),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.check, size: 14, color: accent),
                        const SizedBox(width: 5),
                        Text('Saved',
                            style: AppTheme.body(
                                size: 11.5, color: AppTheme.inkFaint)),
                      ],
                    ),
                  ],
                ),
              ),

              Container(height: 1, color: AppTheme.hairline),

              // WebView
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_loading)
                      Center(
                        child: CircularProgressIndicator(color: accent),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step back through the WebView's own history first (a lesson returns to the
  // course's chapter catalog), and only exit to the native all-courses catalog
  // once the WebView is at its first page and can't go back any further.
  Future<void> _onBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.popUntil(ModalRoute.withName('/catalog'));
    }
  }
}
