import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_background.dart';

class OnboardingWhatScreen extends StatelessWidget {
  const OnboardingWhatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/catalog', (_) => false),
                      child: Text('Skip', style: AppTheme.body(size: 14, weight: FontWeight.w600, color: AppTheme.inkFaint)),
                    ),
                  ],
                ),
              ),

              // Progress dots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    _dot(true),
                    const SizedBox(width: 7),
                    _dot(false),
                    const SizedBox(width: 7),
                    _dot(false),
                  ],
                ),
              ),

              const Spacer(),

              // Illustration
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: 210,
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 30,
                        top: 8,
                        child: Transform.rotate(
                          angle: -0.122,
                          child: Container(
                            width: 150,
                            height: 96,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161822),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.hairline),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 38,
                        child: Container(
                          width: 170,
                          height: 104,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2130),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.databricksAccent.withOpacity(0.30)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppTheme.databricksAccent.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(color: AppTheme.databricksAccent.withOpacity(0.4)),
                                    ),
                                    child: Center(child: Text('D', style: AppTheme.display(size: 15, color: AppTheme.databricksInk))),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(width: 78, height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(8))),
                                ],
                              ),
                              const SizedBox(height: 9),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: SizedBox(
                                  height: 5,
                                  child: Stack(children: [
                                    Container(color: Colors.white.withOpacity(0.08)),
                                    FractionallySizedBox(widthFactor: 0.46, child: Container(color: AppTheme.databricksAccent)),
                                  ]),
                                ),
                              ),
                              const SizedBox(height: 5),
                              FractionallySizedBox(
                                widthFactor: 0.6,
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Every cert,\none quiet shelf.',
                      style: AppTheme.display(size: 36, height: 1.05),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pick a certification, study at your pace, and pick up exactly where you left off. No noise, no streaks to chase — just the work.',
                      style: AppTheme.body(size: 16.5, color: AppTheme.inkSoft, height: 1.55),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
                child: _PrimaryButton(
                  label: 'Continue',
                  onTap: () => Navigator.of(context).pushNamed('/onboarding/cert'),
                ),
              ),
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

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.ink,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.body(size: 16, weight: FontWeight.w700, color: AppTheme.bg),
        ),
      ),
    );
  }
}
