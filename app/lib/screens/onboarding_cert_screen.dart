import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../state.dart';
import '../widgets/app_background.dart';

class OnboardingCertScreen extends StatelessWidget {
  const OnboardingCertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    _dot(false),
                    const SizedBox(width: 7),
                    _dot(true),
                    const SizedBox(width: 7),
                    _dot(false),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Where do you\nwant to start?', style: AppTheme.display(size: 34, height: 1.06)),
                    const SizedBox(height: 8),
                    Text(
                      'You can add more later — nothing is locked in.',
                      style: AppTheme.body(size: 15.5, color: AppTheme.inkSoft, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _CertOption(
                      id: 'databricks',
                      letter: 'D',
                      certName: 'Databricks',
                      subtitle: 'Data Engineer Associate',
                      letterColor: AppTheme.databricksInk,
                      accentColor: AppTheme.databricksAccent,
                      selected: state.selectedCert == 'databricks',
                      onTap: () => state.selectCert('databricks'),
                    ),
                    const SizedBox(height: 12),
                    _CertOption(
                      id: 'snowflake',
                      letter: 'S',
                      certName: 'Snowflake',
                      subtitle: 'SnowPro Core',
                      letterColor: AppTheme.snowflakeInk,
                      accentColor: AppTheme.snowflakeAccent,
                      selected: state.selectedCert == 'snowflake',
                      onTap: () => state.selectCert('snowflake'),
                    ),
                    const SizedBox(height: 12),
                    _CertOption(
                      id: 'dbt',
                      letter: 'd',
                      certName: 'dbt',
                      subtitle: 'Analytics Engineer',
                      letterColor: AppTheme.dbtInk,
                      accentColor: AppTheme.dbtAccent,
                      selected: state.selectedCert == 'dbt',
                      onTap: () => state.selectCert('dbt'),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
                child: _PrimaryButton(
                  label: 'Continue',
                  onTap: () => Navigator.of(context).pushNamed('/onboarding/notify'),
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

class _CertOption extends StatelessWidget {
  final String id;
  final String letter;
  final String certName;
  final String subtitle;
  final Color letterColor;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  const _CertOption({
    required this.id,
    required this.letter,
    required this.certName,
    required this.subtitle,
    required this.letterColor,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? accentColor.withOpacity(0.12) : const Color(0xFF161822),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accentColor : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.4)),
              ),
              child: Center(child: Text(letter, style: AppTheme.display(size: 20, color: letterColor))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(certName, style: AppTheme.display(size: 17, color: AppTheme.ink)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: AppTheme.body(size: 13, color: AppTheme.inkSoft)),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? accentColor : Colors.transparent,
                border: Border.all(color: selected ? accentColor : Colors.white.withOpacity(0.2), width: 1.5),
              ),
              child: selected
                  ? Icon(Icons.check, size: 13, color: AppTheme.bg)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
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
