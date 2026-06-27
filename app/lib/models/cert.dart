import 'package:flutter/material.dart';

/// Where a cert sits in the learner's journey. Drives which card variant the
/// catalog renders. `comingSoon` certs have no real lesson content yet, so they
/// must not navigate anywhere.
enum CertStatus { inProgress, brandNew, comingSoon, locked }

CertStatus _statusFromJson(String v) => switch (v) {
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

/// A single downloadable study unit within a cert.
///
/// This is content metadata only — the live download state (progress, timers)
/// lives in the app state layer, not here.
class LessonUnit {
  final String id;
  final String name;
  final int sizeMb;

  /// Seeded device state, so the demo can show a finished and an in-flight
  /// download. A real backend would not send these.
  final bool downloaded;
  final bool downloading;

  const LessonUnit({
    required this.id,
    required this.name,
    required this.sizeMb,
    this.downloaded = false,
    this.downloading = false,
  });

  factory LessonUnit.fromJson(Map<String, dynamic> json) => LessonUnit(
        id: json['id'] as String,
        name: json['name'] as String,
        sizeMb: json['size_mb'] as int,
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

/// A certification track. Backend-shaped (plain JSON, colours as ARGB ints, no
/// device- or locale-specific fields) so a `LocalCertRepository` today and an
/// API-backed one later can both produce these without UI changes.
class Cert {
  final String id;
  final String vendor; // e.g. "Microsoft Azure"
  final String track; // e.g. "Azure Fundamentals"
  final String examCode; // e.g. "AZ-900"
  final String monogram; // e.g. "Az"
  final int accentArgb;
  final int inkArgb;
  final String lessonUrl;
  final int lessonsDone;
  final int lessonsTotal;
  final CertStatus status;
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
    required this.lessonsDone,
    required this.lessonsTotal,
    required this.status,
    this.units = const [],
  });

  Color get accent => Color(accentArgb);
  Color get ink => Color(inkArgb);

  double get progress => lessonsTotal == 0 ? 0 : lessonsDone / lessonsTotal;

  factory Cert.fromJson(Map<String, dynamic> json) => Cert(
        id: json['id'] as String,
        vendor: json['vendor'] as String,
        track: json['track'] as String,
        examCode: json['exam_code'] as String,
        monogram: json['monogram'] as String,
        accentArgb: json['accent_argb'] as int,
        inkArgb: json['ink_argb'] as int,
        lessonUrl: json['lesson_url'] as String,
        lessonsDone: json['lessons_done'] as int,
        lessonsTotal: json['lessons_total'] as int,
        status: _statusFromJson(json['status'] as String),
        units: (json['units'] as List<dynamic>? ?? [])
            .map((u) => LessonUnit.fromJson(u as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'vendor': vendor,
        'track': track,
        'exam_code': examCode,
        'monogram': monogram,
        'accent_argb': accentArgb,
        'ink_argb': inkArgb,
        'lesson_url': lessonUrl,
        'lessons_done': lessonsDone,
        'lessons_total': lessonsTotal,
        'status': _statusToJson(status),
        'units': units.map((u) => u.toJson()).toList(),
      };
}
