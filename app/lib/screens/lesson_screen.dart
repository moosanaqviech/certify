import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../state.dart';
import '../theme.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  double _appliedScale = 1.0;

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
      ))
      ..loadRequest(Uri.parse('https://alreadycertified.netlify.app'));
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

    return Scaffold(
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
                    onTap: () => _goHome(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2130),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: const Center(
                        child: Text('←', style: TextStyle(color: AppTheme.ink, fontSize: 19, height: 1)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        _seg(true),
                        const SizedBox(width: 5),
                        _seg(true),
                        const SizedBox(width: 5),
                        _seg(true),
                        const SizedBox(width: 5),
                        _seg(false),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const Icon(Icons.check, size: 14, color: AppTheme.snowflakeAccent),
                      const SizedBox(width: 5),
                      Text('Saved', style: AppTheme.body(size: 11.5, color: AppTheme.inkFaint)),
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
                    const Center(
                      child: CircularProgressIndicator(color: AppTheme.snowflakeAccent),
                    ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // Pop back to the catalog (home) screen regardless of how far the
  // WebView has navigated inside the lesson.
  void _goHome(BuildContext context) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.popUntil(ModalRoute.withName('/catalog'));
    }
  }

  Widget _seg(bool filled) => Expanded(
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            color: filled ? AppTheme.ink : Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
}
