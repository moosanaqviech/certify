import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cert.dart';
import '../screens/lesson_screen.dart';
import '../state.dart';
import '../theme.dart';
import 'cert_visuals.dart';

/// Opens [CourseSheet] for [cert]. Every link opens in the in-app WebView
/// ([LessonScreen]) after the sheet closes.
Future<void> showCourseSheet(BuildContext context, Cert cert) {
  final nav = Navigator.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => CourseSheet(
      cert: cert,
      onOpen: (args) {
        Navigator.of(sheetContext).pop();
        if (args.url == cert.lessonUrl) context.read<AppState>().selectCert(cert.id);
        nav.pushNamed('/lesson', arguments: args);
      },
    ),
  );
}

/// Course detail sheet behind a card's "⋯" button. Shows only what the
/// manifest provides: stat tiles, rows and footer hide when their field is
/// absent.
class CourseSheet extends StatelessWidget {
  final Cert cert;
  final ValueChanged<LessonArgs> onOpen;

  const CourseSheet({super.key, required this.cert, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final started = cert.lessonsDone > 0;
    final stats = [
      if (cert.lessonsTotal > 0) (cert.lessonsTotal, 'Chapters'),
      if (cert.questionsTotal != null) (cert.questionsTotal!, 'Questions'),
      if (cert.mocksTotal != null) (cert.mocksTotal!, 'Mock exams'),
    ];
    final eyebrow = [cert.vendor, if (cert.level != null) cert.level!].join(' · ').toUpperCase();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                CertTile(cert: cert),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eyebrow, style: AppTheme.label(size: 10.5, color: AppTheme.inkMuted)),
                      const SizedBox(height: 3),
                      Text(cert.track, style: AppTheme.display(size: 20, height: 1.15)),
                    ],
                  ),
                ),
              ],
            ),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _StatTile(value: stats[i].$1, label: stats[i].$2)),
                  ],
                ],
              ),
            ],
            if (started) ...[
              const SizedBox(height: 16),
              CertProgress(cert: cert),
            ],
            const SizedBox(height: 18),
            CertButton(
              label: started ? 'Continue learning' : 'Start learning',
              filled: true,
              trailing: const Icon(Icons.arrow_forward, size: 16, color: AppTheme.onGold),
              onPressed: () => onOpen(LessonArgs.fromCert(cert)),
            ),
            if (cert.practiceUrl != null) ...[
              const SizedBox(height: 10),
              CertButton(
                label: 'Practice questions',
                leading: const StrokeIcon('bolt', size: 15, color: AppTheme.gold, strokeWidth: 2),
                onPressed: () => onOpen(LessonArgs(
                  url: cert.practiceUrl!,
                  title: 'Practice · ${cert.track}',
                  accent: cert.accent,
                )),
              ),
            ],
            if (cert.readyUrl != null || cert.guideUrl != null) const SizedBox(height: 10),
            if (cert.readyUrl != null)
              _LinkRow(
                icon: Icons.fact_check_outlined,
                label: 'Am I ready?',
                onTap: () => onOpen(LessonArgs(url: cert.readyUrl!, title: 'Am I ready?', accent: cert.accent)),
              ),
            if (cert.guideUrl != null)
              _LinkRow(
                icon: Icons.menu_book_outlined,
                label: 'Read the exam guide',
                onTap: () => onOpen(LessonArgs(url: cert.guideUrl!, title: 'Exam guide', accent: cert.accent)),
              ),
            if (cert.lastVerified != null) ...[
              const SizedBox(height: 14),
              Text(
                'Content verified against the exam guide on ${formatIsoDate(cert.lastVerified!)}',
                textAlign: TextAlign.center,
                style: AppTheme.body(size: 12, color: AppTheme.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        children: [
          Text('$value', style: AppTheme.display(size: 20)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.body(size: 11.5, color: AppTheme.inkMuted)),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Icon(icon, size: 19, color: AppTheme.inkSoft),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppTheme.body(size: 14.5, weight: FontWeight.w600))),
              const Icon(Icons.chevron_right, size: 18, color: AppTheme.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
