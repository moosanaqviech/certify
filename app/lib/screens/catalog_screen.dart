import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cert.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/app_background.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Nav bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Certify', style: AppTheme.display(size: 20)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/settings'),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161822),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.hairline),
                        ),
                        child: const Center(child: _GearIcon()),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: state.catalogLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
                        children: [
                          Text('Your catalog', style: AppTheme.display(size: 30)),
                          const SizedBox(height: 16),

                          for (final cert in state.catalog) ...[
                            _CertCard(
                              cert: cert,
                              onTap: switch (cert.status) {
                                CertStatus.inProgress || CertStatus.brandNew => () {
                                    state.selectCert(cert.id);
                                    Navigator.of(context).pushNamed('/lesson', arguments: cert);
                                  },
                                CertStatus.comingSoon => () => _showComingSoon(context, cert),
                                CertStatus.locked => null,
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          Center(
                            child: Text(
                              'More certifications are on the way.',
                              style: AppTheme.body(size: 13, color: AppTheme.inkFaint),
                            ),
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
}

/// One catalog card, rendering the in-progress / new / locked variant from the
/// cert's status. Replaces the three bespoke card widgets.
class _CertCard extends StatelessWidget {
  final Cert cert;
  final VoidCallback? onTap;

  const _CertCard({required this.cert, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (cert.status == CertStatus.locked) return _locked();
    if (cert.status == CertStatus.comingSoon) {
      return GestureDetector(onTap: onTap, child: _comingSoon());
    }
    return GestureDetector(onTap: onTap, child: _active());
  }

  Widget _active() {
    final inProgress = cert.status == CertStatus.inProgress;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Stack(
        children: [
          if (inProgress)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    center: const Alignment(-1.0, -1.0),
                    radius: 1.2,
                    colors: [cert.accent.withOpacity(0.18), Colors.transparent],
                    stops: const [0, 0.7],
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _monogram(cert),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cert.track, style: AppTheme.display(size: 20)),
                        const SizedBox(height: 2),
                        Text(cert.vendor, style: AppTheme.body(size: 13.5, color: AppTheme.inkSoft)),
                      ],
                    ),
                  ),
                  inProgress ? _badge('IN PROGRESS', cert) : _newBadge(cert),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total lessons is real content metadata; per-user progress is
                  // intentionally not shown until it can be tracked for real.
                  Text(
                    '${cert.lessonsTotal} lessons',
                    style: AppTheme.body(size: 12, color: AppTheme.inkFaint, letterSpacing: 0.03 * 12),
                  ),
                  Row(
                    children: [
                      Text(inProgress ? 'Continue' : 'Start',
                          style: AppTheme.body(size: 13.5, weight: FontWeight.w600)),
                      const SizedBox(width: 5),
                      const Icon(Icons.chevron_right, size: 15, color: AppTheme.ink),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comingSoon() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161822),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _monogram(cert),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert.track, style: AppTheme.display(size: 20)),
                    const SizedBox(height: 2),
                    Text(cert.vendor, style: AppTheme.body(size: 13.5, color: AppTheme.inkSoft)),
                  ],
                ),
              ),
              _soonBadge(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${cert.lessonsTotal} lessons',
                  style: AppTheme.body(size: 12, color: AppTheme.inkFaint, letterSpacing: 0.03 * 12)),
              Text('Coming soon',
                  style: AppTheme.body(size: 13, weight: FontWeight.w600, color: AppTheme.inkFaint)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _soonBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppTheme.hairline),
        ),
        child: Text('COMING SOON',
            style: AppTheme.body(size: 10.5, weight: FontWeight.w600, color: AppTheme.inkFaint, letterSpacing: 0.06 * 10.5)),
      );

  Widget _locked() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF13141F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.62,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  child: _codeGlyph(cert.examCode, AppTheme.inkFaint),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert.track, style: AppTheme.display(size: 20, color: AppTheme.inkSoft)),
                      const SizedBox(height: 2),
                      Text(cert.vendor, style: AppTheme.body(size: 13.5, color: AppTheme.inkFaint)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 11, color: AppTheme.inkFaint),
                      const SizedBox(width: 4),
                      Text('LOCKED',
                          style: AppTheme.body(size: 10.5, weight: FontWeight.w600, color: AppTheme.inkFaint, letterSpacing: 0.06 * 10.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.only(top: 13),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${cert.lessonsTotal} lessons · available later',
                    style: AppTheme.body(size: 12.5, color: AppTheme.inkFaint)),
                Text('Certify Pro', style: AppTheme.body(size: 13, weight: FontWeight.w600, color: cert.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _monogram(Cert cert) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: cert.accent.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cert.accent.withOpacity(0.35)),
        ),
        child: _codeGlyph(cert.examCode, cert.ink),
      );

  /// The exam code, scaled to fit the badge — distinguishes certs from the
  /// same vendor (e.g. AZ-900 vs AZ-104) better than a shared monogram.
  static Widget _codeGlyph(String code, Color color) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(code, style: AppTheme.body(size: 14, weight: FontWeight.w700, color: color)),
          ),
        ),
      );

  Widget _badge(String label, Cert cert) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: cert.accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: cert.accent.withOpacity(0.28)),
        ),
        child: Text(label,
            style: AppTheme.body(size: 10.5, weight: FontWeight.w600, color: cert.ink, letterSpacing: 0.06 * 10.5)),
      );

  Widget _newBadge(Cert cert) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cert.accent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text('New', style: AppTheme.body(size: 10.5, weight: FontWeight.w700, color: AppTheme.bg)),
      );
}

void _showComingSoon(BuildContext context, Cert cert) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          '${cert.track} is coming soon!',
          style: AppTheme.body(size: 14, weight: FontWeight.w600, color: AppTheme.ink),
        ),
        backgroundColor: AppTheme.surfaceRaised,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

class _GearIcon extends StatelessWidget {
  const _GearIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.settings_outlined, size: 20, color: AppTheme.inkSoft);
  }
}
