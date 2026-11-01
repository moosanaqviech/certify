import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../feature_flags.dart';
import '../models/cert.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/cert_visuals.dart';
import '../widgets/course_sheet.dart';
import 'lesson_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final available = state.catalog.where((c) => c.status != CertStatus.comingSoon).toList();
    final planned = state.catalog.where((c) => c.status == CertStatus.comingSoon).toList();

    void open(Cert cert, LessonArgs args) {
      if (args.url == cert.lessonUrl) state.selectCert(cert.id);
      Navigator.of(context).pushNamed('/lesson', arguments: args);
    }

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Nav bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Certify', style: AppTheme.display(size: 20)),
                    Semantics(
                      container: true,
                      button: true,
                      label: 'Settings',
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/settings'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.hairline),
                          ),
                          child: const Center(
                            child: Icon(Icons.settings_outlined, size: 20, color: AppTheme.inkSoft),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: state.catalogLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                        children: [
                          Text('Your catalog', style: AppTheme.display(size: 30)),
                          const SizedBox(height: 18),

                          // Grouped by vendor, mirroring the web catalog's
                          // provider sections. Insertion order is preserved, so
                          // the manifest's ordering drives the section order.
                          for (final group in _groupByVendor(available)) ...[
                            VendorHeader(
                              cert: group.certs.first,
                              count: group.certs.length,
                            ),
                            const SizedBox(height: 12),
                            for (final cert in group.certs) ...[
                              cert.status == CertStatus.locked
                                  ? PlannedCertCard(cert: cert, locked: true)
                                  : CertCard(
                                      cert: cert,
                                      onStart: () => open(cert, LessonArgs.fromCert(cert)),
                                      onPractice: () => open(
                                        cert,
                                        LessonArgs(
                                          url: cert.practiceUrl!,
                                          title: 'Practice · ${cert.track}',
                                          accent: cert.accent,
                                        ),
                                      ),
                                      onMore: () => showCourseSheet(context, cert),
                                    ),
                              const SizedBox(height: 12),
                            ],
                            const SizedBox(height: 14),
                          ],

                          if (planned.isNotEmpty) ...[
                            _SectionTitle(title: 'Coming soon', count: planned.length),
                            const SizedBox(height: 12),
                            for (final cert in planned) ...[
                              PlannedCertCard(
                                cert: cert,
                                onNotify: () {
                                  state.notifyWhenAvailable(cert);
                                  _snack(context, "We'll let you know when ${cert.track} launches.");
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                            const SizedBox(height: 14),
                          ],

                          Center(
                            child: Text(
                              'More certifications are on the way.',
                              style: AppTheme.body(size: 13, color: AppTheme.inkMuted),
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

/// A vendor and its certs, in catalog order.
class _VendorGroup {
  final String vendor;
  final List<Cert> certs;
  const _VendorGroup(this.vendor, this.certs);
}

/// Buckets the flat catalog by vendor while preserving first-seen order, so the
/// UI can render provider sections without the repository changing shape.
List<_VendorGroup> _groupByVendor(List<Cert> catalog) {
  final byVendor = <String, List<Cert>>{};
  for (final cert in catalog) {
    byVendor.putIfAbsent(cert.vendor, () => []).add(cert);
  }
  return [for (final e in byVendor.entries) _VendorGroup(e.key, e.value)];
}

String _certCount(int n) => '$n ${n == 1 ? 'certification' : 'certifications'}';

/// Vendor section heading: logo (monogram fallback) + vendor + cert count.
class VendorHeader extends StatelessWidget {
  /// Any cert from the vendor's group — supplies vendor name and colours.
  final Cert cert;
  final int count;

  const VendorHeader({super.key, required this.cert, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: BrandMark(cert: cert, color: cert.ink, padding: 4),
        ),
        const SizedBox(width: 10),
        Flexible(child: Text(cert.vendor, style: AppTheme.display(size: 17))),
        const SizedBox(width: 8),
        Text(_certCount(count), style: AppTheme.body(size: 12.5, color: AppTheme.inkMuted)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;

  const _SectionTitle({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(title, style: AppTheme.display(size: 17)),
        const SizedBox(width: 8),
        Text(_certCount(count), style: AppTheme.body(size: 12.5, color: AppTheme.inkMuted)),
      ],
    );
  }
}

/// A navigable course card. Every line below the title is optional and only
/// renders when the manifest (or local progress) provides it.
class CertCard extends StatelessWidget {
  final Cert cert;
  final VoidCallback onStart;
  final VoidCallback onPractice;
  final VoidCallback onMore;

  /// Defaults to [FeatureFlags.showPrices] (off); overridable for tests.
  final bool showPrices;

  const CertCard({
    super.key,
    required this.cert,
    required this.onStart,
    required this.onPractice,
    required this.onMore,
    this.showPrices = FeatureFlags.showPrices,
  });

  @override
  Widget build(BuildContext context) {
    final stats = certStatsLine(cert);
    final started = cert.lessonsDone > 0 || cert.status == CertStatus.inProgress;
    final price = cert.price;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CertTile(cert: cert),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cert.track,
                  style: AppTheme.display(size: 17, height: 1.15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (cert.level != null) ...[
                const SizedBox(width: 8),
                LevelChip(cert.level!),
              ],
            ],
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(stats, style: AppTheme.body(size: 12.5, color: AppTheme.inkMuted)),
          ],
          if (cert.lessonsDone > 0 && cert.lessonsTotal > 0) ...[
            const SizedBox(height: 10),
            CertProgress(cert: cert),
          ],
          if (showPrices && price != null) ...[
            const SizedBox(height: 8),
            Text(
              [price, if (cert.priceNote != null) cert.priceNote!].join(' · '),
              style: AppTheme.body(size: 12.5, weight: FontWeight.w600, color: AppTheme.inkSoft),
            ),
          ],
          if (cert.lastVerified != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check, size: 13, color: AppTheme.inkMuted),
                const SizedBox(width: 4),
                Text(
                  'Verified ${formatIsoDate(cert.lastVerified!)}',
                  style: AppTheme.body(size: 12, color: AppTheme.inkMuted),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (cert.practiceUrl != null) ...[
                Expanded(
                  child: CertButton(
                    label: 'Practice',
                    leading: const StrokeIcon('bolt', size: 14, color: AppTheme.gold, strokeWidth: 2),
                    onPressed: onPractice,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: CertButton(
                  label: started ? 'Continue' : 'Start',
                  filled: true,
                  trailing: const Icon(Icons.arrow_forward, size: 16, color: AppTheme.onGold),
                  onPressed: onStart,
                ),
              ),
              const SizedBox(width: 8),
              _MoreButton(label: 'More about ${cert.track}', onTap: onMore),
            ],
          ),
        ],
      ),
    );
  }
}

/// 44px "⋯" circle that opens the course sheet.
class _MoreButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MoreButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.16))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.more_horiz, size: 20, color: AppTheme.inkSoft),
          ),
        ),
      ),
    );
  }
}

/// Compact, muted card for a cert with no content yet (manifest `planned`),
/// or a locked one. Never navigates.
class PlannedCertCard extends StatelessWidget {
  final Cert cert;
  final VoidCallback? onNotify;
  final bool locked;

  const PlannedCertCard({super.key, required this.cert, this.onNotify, this.locked = false});

  @override
  Widget build(BuildContext context) {
    final meta = [cert.vendor, if (cert.examCode.isNotEmpty) cert.examCode].join(' · ');
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppTheme.frame,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          CertTile(cert: cert, size: 36, muted: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.track,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.display(size: 15, height: 1.15, color: AppTheme.inkSoft),
                ),
                const SizedBox(height: 2),
                Text(meta, style: AppTheme.body(size: 12, color: AppTheme.inkMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (locked)
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 13, color: AppTheme.inkMuted),
                const SizedBox(width: 4),
                Text('Locked', style: AppTheme.body(size: 12.5, weight: FontWeight.w600, color: AppTheme.inkMuted)),
              ],
            )
          else if (onNotify != null)
            Semantics(
              container: true,
              button: true,
              label: 'Notify me when ${cert.track} launches',
              excludeSemantics: true,
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onNotify,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.notifications_none, size: 15, color: AppTheme.inkSoft),
                          const SizedBox(width: 5),
                          Text('Notify me',
                              style: AppTheme.body(size: 13, weight: FontWeight.w600, color: AppTheme.inkSoft)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.body(size: 14, weight: FontWeight.w600, color: AppTheme.ink),
        ),
        backgroundColor: AppTheme.surfaceRaised,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}
