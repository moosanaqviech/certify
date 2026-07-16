import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets/app_background.dart';

class OnboardingNotifyScreen extends StatelessWidget {
  const OnboardingNotifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [SizedBox(width: 48), SizedBox()],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    _dot(false),
                    const SizedBox(width: 7),
                    _dot(false),
                    const SizedBox(width: 7),
                    _dot(true),
                  ],
                ),
              ),

              const Spacer(),

              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E2130), Color(0xFF13141F)],
                  ),
                  border: Border.all(color: AppTheme.hairline),
                  boxShadow: [
                    BoxShadow(color: AppTheme.accent.withOpacity(0.18), blurRadius: 40, offset: const Offset(0, 14)),
                  ],
                ),
                child: const Center(child: _BellIcon()),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A nudge, only\nwhen it helps.', style: AppTheme.display(size: 34, height: 1.06)),
                    const SizedBox(height: 14),
                    Text(
                      "We'll remind you at a time you choose, flag new certifications, and give you a heads-up before exams. Nothing more.",
                      style: AppTheme.body(size: 16, color: AppTheme.inkSoft, height: 1.55),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
                child: GestureDetector(
                  onTap: () async {
                    final state = context.read<AppState>();
                    final navigator = Navigator.of(context);
                    await state.enableStudyReminders();
                    state.completeOnboarding();
                    navigator.pushNamedAndRemoveUntil('/catalog', (_) => false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Turn on reminders',
                      textAlign: TextAlign.center,
                      style: AppTheme.body(size: 16, weight: FontWeight.w700, color: AppTheme.bg),
                    ),
                  ),
                ),
              ),

              TextButton(
                onPressed: () async {
                  final state = context.read<AppState>();
                  final navigator = Navigator.of(context);
                  await state.declineStudyReminders();
                  state.completeOnboarding();
                  navigator.pushNamedAndRemoveUntil('/catalog', (_) => false);
                },
                child: Text('Not now', style: AppTheme.body(size: 15, weight: FontWeight.w600, color: AppTheme.inkSoft)),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) => Container(
        width: active ? 24 : 10,
        height: 4,
        decoration: BoxDecoration(
          color: active ? AppTheme.ink : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

class _BellIcon extends StatelessWidget {
  const _BellIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(48, 48),
      painter: _BellPainter(),
    );
  }
}

class _BellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.width / 24;
    final path = Path();
    // Bell body
    path.moveTo(6 * s, 16 * s);
    path.cubicTo(6 * s, 13.5 * s, 7.8 * s, 10.5 * s, 12 * s, 10.5 * s);
    path.cubicTo(16.2 * s, 10.5 * s, 18 * s, 13.5 * s, 18 * s, 16 * s);
    path.lineTo(19.8 * s, 18.2 * s);
    path.lineTo(4.2 * s, 18.2 * s);
    path.close();
    canvas.drawPath(path, paint);

    // Clapper
    canvas.drawArc(
      Rect.fromCenter(center: Offset(12 * s, 19.5 * s), width: 4.4 * s, height: 4.4 * s),
      0,
      3.14159,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
