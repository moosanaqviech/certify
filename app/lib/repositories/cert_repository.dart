import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import '../models/cert.dart';
import '../services/settings_store.dart';

/// The seam between the UI/state layer and the source of catalog data.
///
/// The app depends only on this interface. [ApiCertRepository] reads the live
/// catalog manifest published at `https://certify.courses/catalog.json`, which
/// is the single source of truth shared with the website. [LocalCertRepository]
/// remains as a hardcoded fixture for tests. Kept `Future`-based so network
/// latency never reshapes callers.
abstract class CertRepository {
  Future<List<Cert>> fetchCatalog();
}

/// Reads the catalog from the published manifest so the app and website can
/// never drift: the site generates `catalog.json` from its real course content
/// and the app fetches it here.
///
/// Resolution order, so there is always a catalog to show:
///   1. Network — fetch the live manifest and write it through to the cache.
///   2. Cache — the last manifest that fetched successfully (survives offline
///      launches and flaky networks).
///   3. Bundle — `assets/catalog.json` shipped with the build, so a first
///      launch with no network still shows a catalog.
///
/// Only catalog/content metadata comes from here. Per-user progress and
/// per-device download state stay local and are merged by cert id elsewhere.
class ApiCertRepository implements CertRepository {
  final String catalogUrl;
  final SettingsStore _cache;
  final Duration _timeout;

  /// Key under which the last good manifest JSON is cached.
  static const _cacheKey = 'cached_catalog_json';

  /// Bundled fallback shipped in the app (registered in pubspec.yaml assets).
  static const _bundledAsset = 'assets/catalog.json';

  ApiCertRepository({
    required this.catalogUrl,
    required SettingsStore cache,
    Duration timeout = const Duration(seconds: 6),
  })  : _cache = cache,
        _timeout = timeout;

  @override
  Future<List<Cert>> fetchCatalog() async {
    // 1. Network-first. On success, cache the raw JSON so the next cold start
    //    (or any offline launch) has a fresh copy to fall back to.
    try {
      final jsonStr = await _fetchOverNetwork();
      final certs = _parse(jsonStr);
      await _cache.setString(_cacheKey, jsonStr);
      return certs;
    } catch (_) {
      // Fall through to the offline fallbacks below.
    }

    // 2. Last-good cached manifest from a previous successful fetch.
    final cached = _cache.getString(_cacheKey);
    if (cached != null) {
      try {
        return _parse(cached);
      } catch (_) {
        // Corrupt cache: ignore and fall through to the bundled copy.
      }
    }

    // 3. Bundled manifest — guarantees a catalog with no network and no cache.
    final bundled = await rootBundle.loadString(_bundledAsset);
    return _parse(bundled);
  }

  Future<String> _fetchOverNetwork() async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request =
          await client.getUrl(Uri.parse(catalogUrl)).timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Catalog fetch failed: HTTP ${response.statusCode}');
      }
      return await response.transform(utf8.decoder).join().timeout(_timeout);
    } finally {
      client.close(force: true);
    }
  }

  List<Cert> _parse(String jsonStr) {
    final root = json.decode(jsonStr) as Map<String, dynamic>;
    final certs = root['certs'] as List<dynamic>;
    return certs
        .map((c) => Cert.fromJson(c as Map<String, dynamic>))
        .toList(growable: false);
  }
}

/// In-memory catalog fixture. No longer the app's source of truth — the app
/// reads the published manifest via [ApiCertRepository]. Kept for tests and
/// offline development so a catalog can be built without any I/O. Because it is
/// not backed by the live manifest, its contents will drift from the site; do
/// not rely on it for real catalog data.
class LocalCertRepository implements CertRepository {
  // Base site. The homepage is now the course catalog, so navigable certs must
  // point at their own course path (units & chapters), not the site root.
  static const _site = 'https://certify.courses';
  // Placeholder for coming-soon certs, which don't navigate yet; their real
  // course paths slot in here as content ships.
  static const _lessonUrl = _site;
  static const _deaUrl = '$_site/databricks-data-engineer-associate/index.html';
  static const _depUrl = '$_site/databricks-data-engineer-professional/index.html';
  static const _awsDeaUrl = '$_site/aws-data-engineer-associate/index.html';

  // Per-vendor colours (ARGB). A backend would supply these as ints too.
  static const _azureAccent = 0xFF3B82F6;
  static const _azureInk = 0xFF8AB4F8;
  static const _awsAccent = 0xFFF59E0B;
  static const _awsInk = 0xFFF7C873;
  static const _databricksAccent = 0xFF8D7BF6;
  static const _databricksInk = 0xFFB4A9FF;
  static const _snowflakeAccent = 0xFF5EC8C0;
  static const _snowflakeInk = 0xFF7FD8D0;
  static const _dbtAccent = 0xFF7C8CF8;
  static const _dbtInk = 0xFF9AA6FB;

  @override
  Future<List<Cert>> fetchCatalog() async {
    return const [
      // Certs with real lesson content (this and AWS Data Engineer Associate
      // below) actually open; everything marked "coming soon" must not navigate.
      Cert(
        id: 'databricks-dea',
        vendor: 'Databricks',
        track: 'Data Engineer Associate',
        examCode: 'DEA',
        monogram: 'D',
        accentArgb: _databricksAccent,
        inkArgb: _databricksInk,
        lessonUrl: _deaUrl,
        lessonsDone: 11,
        lessonsTotal: 26,
        status: CertStatus.inProgress,
        units: [
          LessonUnit(id: 'dea-u1', name: 'Foundations of the Lakehouse', sizeMb: 42, downloaded: true),
          LessonUnit(id: 'dea-u2', name: 'Delta Lake & ACID tables', sizeMb: 58, downloading: true),
          LessonUnit(id: 'dea-u3', name: 'ELT pipelines with Spark', sizeMb: 71),
          LessonUnit(id: 'dea-u4', name: 'Productionizing workflows', sizeMb: 63),
        ],
      ),
      Cert(
        id: 'databricks-dep',
        vendor: 'Databricks',
        track: 'Data Engineer Professional',
        examCode: 'DEP',
        monogram: 'D',
        accentArgb: _databricksAccent,
        inkArgb: _databricksInk,
        lessonUrl: _depUrl,
        lessonsDone: 0,
        lessonsTotal: 37,
        status: CertStatus.brandNew,
      ),
      Cert(
        id: 'azure-az900',
        vendor: 'Microsoft Azure',
        track: 'Azure Fundamentals',
        examCode: 'AZ-900',
        monogram: 'Az',
        accentArgb: _azureAccent,
        inkArgb: _azureInk,
        lessonUrl: _lessonUrl,
        lessonsDone: 0,
        lessonsTotal: 26,
        status: CertStatus.comingSoon,
      ),
      Cert(
        id: 'azure-az104',
        vendor: 'Microsoft Azure',
        track: 'Azure Administrator',
        examCode: 'AZ-104',
        monogram: 'Az',
        accentArgb: _azureAccent,
        inkArgb: _azureInk,
        lessonUrl: _lessonUrl,
        lessonsDone: 0,
        lessonsTotal: 24,
        status: CertStatus.comingSoon,
      ),
      // Live on the site: real lesson content, so this one navigates.
      Cert(
        id: 'aws-dea',
        vendor: 'AWS',
        track: 'Data Engineer Associate',
        examCode: 'DEA-C01',
        monogram: 'aws',
        accentArgb: _awsAccent,
        inkArgb: _awsInk,
        lessonUrl: _awsDeaUrl,
        lessonsDone: 0,
        lessonsTotal: 36,
        status: CertStatus.brandNew,
      ),
      Cert(
        id: 'aws-clf',
        vendor: 'AWS',
        track: 'Cloud Practitioner',
        examCode: 'CLF-C02',
        monogram: 'aws',
        accentArgb: _awsAccent,
        inkArgb: _awsInk,
        lessonUrl: _lessonUrl,
        lessonsDone: 0,
        lessonsTotal: 20,
        status: CertStatus.comingSoon,
      ),
      Cert(
        id: 'aws-saa',
        vendor: 'AWS',
        track: 'Solutions Architect Associate',
        examCode: 'SAA-C03',
        monogram: 'aws',
        accentArgb: _awsAccent,
        inkArgb: _awsInk,
        lessonUrl: _lessonUrl,
        lessonsDone: 0,
        lessonsTotal: 28,
        status: CertStatus.comingSoon,
      ),
      Cert(
        id: 'snowflake-core',
        vendor: 'Snowflake',
        track: 'SnowPro Core',
        examCode: 'COF-C02',
        monogram: 'S',
        accentArgb: _snowflakeAccent,
        inkArgb: _snowflakeInk,
        lessonUrl: _lessonUrl,
        lessonsDone: 0,
        lessonsTotal: 22,
        status: CertStatus.comingSoon,
      ),
      Cert(
        id: 'dbt-analytics',
        vendor: 'dbt',
        track: 'Analytics Engineer',
        examCode: 'dbt-AE',
        monogram: 'dbt',
        accentArgb: _dbtAccent,
        inkArgb: _dbtInk,
        lessonUrl: _lessonUrl,
        lessonsDone: 0,
        lessonsTotal: 22,
        status: CertStatus.comingSoon,
      ),
    ];
  }
}
