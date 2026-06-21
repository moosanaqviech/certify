import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _barCtrl;
  late final Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _barAnim = Tween<double>(begin: -1.3, end: 3.3).animate(
      CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut),
    );

    Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding/what');
    });
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const Spacer(),
            Column(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E2130), Color(0xFF13141F)],
                    ),
                    border: Border.all(color: AppTheme.hairline),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.22),
                        blurRadius: 38,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'C',
                      style: AppTheme.display(
                        size: 42,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Certify', style: AppTheme.display(size: 48)),
                const SizedBox(height: 12),
                Text(
                  'STUDY · CERTIFY · REPEAT',
                  style: AppTheme.body(
                    size: 12,
                    weight: FontWeight.w600,
                    color: AppTheme.inkFaint,
                    letterSpacing: 0.24 * 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 56),
              child: SizedBox(
                width: 130,
                height: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withOpacity(0.10)),
                      AnimatedBuilder(
                        animation: _barAnim,
                        builder: (_, __) {
                          return FractionallySizedBox(
                            widthFactor: 0.4,
                            alignment: Alignment(_barAnim.value, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
