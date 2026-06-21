import 'package:flutter/material.dart';
import '../theme.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  // In production: receive the lesson URL as a route argument and load it in a WebView.
  // For now, this screen shows the native chrome + mocked lesson content.

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => Navigator.of(context).pop(),
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
                  // Segmented progress
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

            // Webview boundary label
            Container(
              color: const Color(0xFF161822),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.12), style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '↓  EXISTING WEB PAGE · WEBVIEW  ↓',
                    style: AppTheme.mono(size: 9.5, color: const Color(0xFF4A4C5E)),
                  ),
                ),
              ),
            ),

            // Lesson content (mocked webview area)
            Expanded(
              child: Container(
                color: const Color(0xFF161822),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(30, 18, 30, 0),
                  children: [
                    Text('MODULE 2 · LESSON 4', style: AppTheme.label(size: 12, color: AppTheme.inkFaint)),
                    const SizedBox(height: 14),
                    Text(
                      'Delta Lake gives you ACID tables',
                      style: AppTheme.display(size: 29, height: 1.1),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Every write is a transaction. Readers always see a consistent snapshot, even while a job is still writing.',
                      style: AppTheme.body(size: 16, color: AppTheme.inkSoft, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    _PillCard(
                      title: 'Atomic commits',
                      body: 'A write either lands fully or not at all.',
                    ),
                    const SizedBox(height: 10),
                    _PillCard(
                      title: 'Time travel',
                      body: 'Query any previous version of a table.',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom nav
            Container(
              color: const Color(0xFF161822),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 54,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2130),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: const Center(
                        child: Text('←', style: TextStyle(color: AppTheme.inkSoft, fontSize: 20, height: 1)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.ink,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Continue',
                          textAlign: TextAlign.center,
                          style: AppTheme.body(size: 16, weight: FontWeight.w700, color: AppTheme.bg),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

class _PillCard extends StatelessWidget {
  final String title;
  final String body;

  const _PillCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2130),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$title\n', style: AppTheme.body(size: 15, weight: FontWeight.w600, color: AppTheme.ink)),
            TextSpan(text: body, style: AppTheme.body(size: 14.5, color: AppTheme.inkSoft, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
