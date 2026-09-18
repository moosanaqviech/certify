import 'package:flutter/material.dart';

/// Where a cert sits in the learner's journey. Drives which card variant the
/// catalog renders. `comingSoon` certs have no real lesson content yet, so they
/// must not navigate anywhere.
enum CertStatus { inProgress, brandNew, comingSoon, locked }

/// Maps a catalog `status` string to the app's card variant.
///
/// The published catalog manifest describes *content availability*
/// (`live` / `authoring` / `retiring` / `planned`), not the learner's own
/// progress. Every state with real content collapses to a navigable card here;
/// only `planned` is gated as "coming soon". A learner's "in progress" badge is
/// a per-user concern and would be derived from local progress, not the shared
/// manifest — so it's never produced from JSON.
///
/// The older seed vocabulary (`in_progress` / `coming_soon` / `locked` / `new`)
/// is still accepted for back-compat.
CertStatus _statusFromJson(String v) => switch (v) {
      'live' || 'authoring' || 'retiring' => CertStatus.brandNew,
      'planned' => CertStatus.comingSoon,
      'in_progress' => CertStatus.inProgress,
      'coming_soon' => CertStatus.comingSoon,
      'locked' => CertStatus.locked,
      _ => CertStatus.brandNew,
    };

String _statusToJson(CertStatus s) => switch (s) {
      CertStatus.inProgress => 'in_progress',
      CertStatus.comingSoon => 'coming_soon',
      CertStatus.locked => 'locked',
      CertStatus.brandNew => 'new',
    };

/// Parses a `#RRGGBB` or `#AARRGGBB` colour string into an ARGB int, defaulting
/// to fully opaque when no alpha is given. The manifest ships colours as hex
/// (human-reviewable in the contract); the app stores them as ints internally.
int _hexToArgb(String hex) {
  var h = hex.replaceFirst('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  return int.parse(h, radix: 16);
}

String _argbToHex(int argb) =>
    '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';

/// A single downloadable study unit within a cert.
///
/// This is content metadata only — the live download state (progress, timers)
/// lives in the app state layer, not here.
class LessonUnit {
  final String id;
  final String name;

  /// Download size. Optional in the manifest (offline downloads aren't wired
  /// up yet), so it defaults to 0 when absent.
  final int sizeMb;

  /// Seeded device state, so the demo can show a finished and an in-flight
  /// download. A real backend would not send these.
  final bool downloaded;
  final bool downloading;

  const LessonUnit({
    required this.id,
    required this.name,
    this.sizeMb = 0,
    this.downloaded = false,
    this.downloading = false,
  });

  factory LessonUnit.fromJson(Map<String, dynamic> json) => LessonUnit(
        id: json['id'] as String,
        name: json['name'] as String,
        sizeMb: json['size_mb'] as int? ?? 0,
        downloaded: json['downloaded'] as bool? ?? false,
        downloading: json['downloading'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size_mb': sizeMb,
        'downloaded': downloaded,
        'downloading': downloading,
      };
}

/// A certification track. Manifest-shaped (plain JSON, hex colours, no device-
/// or user-specific fields) so a `LocalCertRepository` today and an
/// `ApiCertRepository` reading the published `catalog.json` can both produce
/// these without UI changes.
///
/// Deliberately excluded from the manifest and therefore never authoritative
/// here: per-user progress and per-device download state. `lessonsDone` remains
/// on the model for the UI but defaults to 0 — a future local-progress store
/// would overlay the real value by [id].
class Cert {
  final String id;
  final String vendor; // e.g. "Microsoft Azure"
  final String track; // e.g. "Azure Fundamentals"
  final String examCode; // e.g. "AZ-900"; empty when the vendor has no code
  final String monogram; // e.g. "Az"
  final int accentArgb;
  final int inkArgb;
  final String lessonUrl;
  final int lessonsDone;
  final int lessonsTotal;
  final CertStatus status;

  /// Optional ISO dates carried from the manifest. `availableUntil` is set for
  /// certs whose exam is being retired; `examAvailableFrom` for brand-new exams.
  /// Not rendered yet — kept so the data isn't silently dropped.
  final String? availableUntil;
  final String? examAvailableFrom;

  final List<LessonUnit> units;

  const Cert({
    required this.id,
    required this.vendor,
    required this.track,
    required this.examCode,
    required this.monogram,
    required this.accentArgb,
    required this.inkArgb,
    required this.lessonUrl,
    this.lessonsDone = 0,
    required this.lessonsTotal,
    required this.status,
    this.availableUntil,
    this.examAvailableFrom,
    this.units = const [],
  });

  Color get accent => Color(accentArgb);
  Color get ink => Color(inkArgb);

  double get progress => lessonsTotal == 0 ? 0 : lessonsDone / lessonsTotal;

  factory Cert.fromJson(Map<String, dynamic> json) => Cert(
        id: json['id'] as String,
        vendor: json['vendor'] as String,
        track: json['track'] as String,
        examCode: json['exam_code'] as String? ?? '',
        monogram: json['monogram'] as String,
        accentArgb: _hexToArgb(json['accent'] as String),
        inkArgb: _hexToArgb(json['ink'] as String),
        lessonUrl: json['lesson_url'] as String,
        lessonsDone: json['lessons_done'] as int? ?? 0,
        lessonsTotal: json['lessons_total'] as int,
        status: _statusFromJson(json['status'] as String),
        availableUntil: json['available_until'] as String?,
        examAvailableFrom: json['exam_available_from'] as String?,
        units: (json['units'] as List<dynamic>? ?? [])
            .map((u) => LessonUnit.fromJson(u as Map<String, dynamic>))
            .toList(),
      );

  /// Mirrors the manifest shape (hex colours, no per-user progress). `status`
  /// is emitted in the app's own vocabulary and is not round-tripped from the
  /// manifest's content-availability values.
  Map<String, dynamic> toJson() => {
        'id': id,
        'vendor': vendor,
        'track': track,
        'exam_code': examCode.isEmpty ? null : examCode,
        'monogram': monogram,
        'accent': _argbToHex(accentArgb),
        'ink': _argbToHex(inkArgb),
        'lesson_url': lessonUrl,
        'lessons_total': lessonsTotal,
        'status': _statusToJson(status),
        if (availableUntil != null) 'available_until': availableUntil,
        if (examAvailableFrom != null) 'exam_available_from': examAvailableFrom,
        'units': units.map((u) => u.toJson()).toList(),
      };
}
