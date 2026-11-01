import 'package:flutter/material.dart';
import '../models/cert.dart';
import '../theme.dart';

/// Shared visual pieces for catalog cards and the course sheet: the topic-icon
/// tile, vendor brand mark, level chip, and the metadata formatters. Everything
/// here renders only what the manifest provides — missing fields hide.

/// Topic icon keys the app can draw. Keys the manifest sends that aren't here
/// fall back to the vendor brand mark, so the site can add keys first.
const topicIconKeys = {'database', 'ml', 'genai', 'analytics', 'spark'};

/// 24×24 stroke glyph for a manifest `icon` key (same geometry as the web
/// catalog's inline SVGs), or the Practice bolt.
class StrokeIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double strokeWidth;

  const StrokeIcon(
    this.name, {
    super.key,
    this.size = 22,
    required this.color,
    this.strokeWidth = 1.75,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _StrokeIconPainter(name, color, strokeWidth),
      ),
    );
  }
}

class _StrokeIconPainter extends CustomPainter {
  final String name;
  final Color color;
  final double strokeWidth;

  _StrokeIconPainter(this.name, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path poly(List<double> xy) {
      final p = Path()..moveTo(xy[0], xy[1]);
      for (var i = 2; i < xy.length; i += 2) {
        p.lineTo(xy[i], xy[i + 1]);
      }
      return p..close();
    }

    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

    switch (name) {
      case 'database':
        canvas.drawOval(Rect.fromCenter(center: const Offset(12, 6), width: 14, height: 6), paint);
        canvas.drawPath(
          Path()
            ..moveTo(5, 6)
            ..lineTo(5, 18)
            ..cubicTo(5, 19.66, 8.13, 21, 12, 21)
            ..cubicTo(15.87, 21, 19, 19.66, 19, 18)
            ..lineTo(19, 6),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(5, 12)
            ..cubicTo(5, 13.66, 8.13, 15, 12, 15)
            ..cubicTo(15.87, 15, 19, 13.66, 19, 12),
          paint,
        );
      case 'ml':
        canvas.drawCircle(const Offset(6, 12), 2.4, paint);
        canvas.drawCircle(const Offset(18, 6), 2.4, paint);
        canvas.drawCircle(const Offset(18, 18), 2.4, paint);
        line(8.1, 10.9, 15.9, 7.1);
        line(8.1, 13.1, 15.9, 16.9);
      case 'genai':
        canvas.drawPath(poly([11, 4, 12.8, 8.7, 17.5, 10.5, 12.8, 12.3, 11, 17, 9.2, 12.3, 4.5, 10.5, 9.2, 8.7]), paint);
        canvas.drawPath(poly([18.5, 15, 19.4, 17.1, 21.5, 18, 19.4, 18.9, 18.5, 21, 17.6, 18.9, 15.5, 18, 17.6, 17.1]), paint);
      case 'analytics':
        line(4, 20, 4, 10);
        line(10, 20, 10, 4);
        line(16, 20, 16, 13);
        line(22, 20, 2, 20);
      case 'spark':
        canvas.drawPath(poly([12, 3, 14.6, 8.3, 20.5, 9.2, 16.3, 13.3, 17.3, 19.1, 12, 16.4, 6.7, 19.1, 7.7, 13.3, 3.5, 9.2, 9.4, 8.3]), paint);
      case 'bolt':
        canvas.drawPath(poly([13, 2, 3, 14, 10, 14, 9, 22, 19, 10, 12, 10]), paint);
    }
  }

  @override
  bool shouldRepaint(_StrokeIconPainter old) =>
      old.name != name || old.color != color || old.strokeWidth != strokeWidth;
}

/// Rounded-square tile tinted with the cert's vendor accent, holding the topic
/// icon — or the brand mark when the manifest has no (known) icon key.
class CertTile extends StatelessWidget {
  final Cert cert;
  final double size;
  final bool muted;

  const CertTile({super.key, required this.cert, this.size = 44, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final icon = cert.icon;
    final fg = muted ? AppTheme.inkMuted : cert.ink;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: muted ? Colors.white.withValues(alpha: 0.04) : cert.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: muted ? AppTheme.hairline : cert.accent.withValues(alpha: 0.35)),
      ),
      child: icon != null && topicIconKeys.contains(icon)
          ? Center(child: StrokeIcon(icon, size: size * 0.5, color: fg))
          : BrandMark(cert: cert, color: fg),
    );
  }
}

/// The vendor's brand mark. Renders the vendor monogram (in the cert's brand
/// colour) by default; vendors mapped in [logoAssets] show their official logo
/// instead, as supplied (not recoloured). A missing or unreadable logo file
/// falls back to the monogram, so adding logos never risks an empty badge.
class BrandMark extends StatelessWidget {
  final Cert cert;
  final Color color;
  final double padding;

  const BrandMark({super.key, required this.cert, required this.color, this.padding = 10});

  /// vendor (lower-cased) -> bundled logo asset path (see assets/brands/).
  /// Vendors not listed fall back to the monogram.
  static const Map<String, String> logoAssets = {
    'databricks': 'assets/brands/databricks.png',
    'aws': 'assets/brands/aws.png',
  };

  @override
  Widget build(BuildContext context) {
    final asset = logoAssets[cert.vendor.toLowerCase()];
    if (asset != null) {
      // Padding goes in frameBuilder so it applies only to a loaded logo; the
      // errorBuilder fallback gets the monogram's own (tighter) padding.
      return Image.asset(
        asset,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        frameBuilder: (_, child, __, ___) => Padding(padding: EdgeInsets.all(padding), child: child),
        errorBuilder: (_, __, ___) => _monogram(),
      );
    }
    return _monogram();
  }

  Widget _monogram() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              cert.monogram,
              style: AppTheme.body(size: 15, weight: FontWeight.w700, color: color),
            ),
          ),
        ),
      );
}

/// "ASSOCIATE" (gold outline) / "PROFESSIONAL" etc. (neutral outline).
class LevelChip extends StatelessWidget {
  final String level;

  const LevelChip(this.level, {super.key});

  @override
  Widget build(BuildContext context) {
    final gold = level == 'associate';
    final color = gold ? AppTheme.gold : AppTheme.inkSoft;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: gold ? AppTheme.gold.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        level.toUpperCase(),
        style: AppTheme.body(size: 10, weight: FontWeight.w700, color: color, letterSpacing: 0.8),
      ),
    );
  }
}

String _plural(int n, String one) => '$n ${n == 1 ? one : '${one}s'}';

/// "[exam_code · ]N chapters[ · N questions][ · N mock exams]" — only the parts
/// the manifest provides.
String certStatsLine(Cert cert) => [
      if (cert.examCode.isNotEmpty) cert.examCode,
      if (cert.lessonsTotal > 0) _plural(cert.lessonsTotal, 'chapter'),
      if (cert.questionsTotal != null) _plural(cert.questionsTotal!, 'question'),
      if (cert.mocksTotal != null) _plural(cert.mocksTotal!, 'mock exam'),
    ].join(' · ');

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// "2026-09-21" -> "21 Sep 2026". Returns the input unchanged if it isn't a
/// parseable date, rather than hiding it.
String formatIsoDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// Thin progress bar + "11 of 35". Only meaningful when the learner has local
/// progress; callers check [Cert.lessonsDone] first.
class CertProgress extends StatelessWidget {
  final Cert cert;

  const CertProgress({super.key, required this.cert});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: cert.progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(cert.accent),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${cert.lessonsDone} of ${cert.lessonsTotal}',
          style: AppTheme.body(size: 12, weight: FontWeight.w600, color: AppTheme.inkMuted),
        ),
      ],
    );
  }
}

/// Filled gold / outline-gold / neutral-outline button, ≥44px tall.
class CertButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final Widget? leading;
  final Widget? trailing;

  const CertButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppTheme.onGold : AppTheme.gold;
    return Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: filled ? AppTheme.gold : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: filled ? BorderSide.none : BorderSide(color: AppTheme.gold.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 6)],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.body(size: 14, weight: FontWeight.w700, color: fg),
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 6), trailing!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
