import '../models/cert.dart';

/// The seam between the UI/state layer and the source of catalog data.
///
/// The app depends only on this interface. Today [LocalCertRepository] returns
/// a hardcoded seed; when the backend lands, an `ApiCertRepository` can return
/// the same `Future<List<Cert>>` from the network with zero UI changes. Kept
/// `Future`-based from day one so adding latency later doesn't reshape callers.
abstract class CertRepository {
  Future<List<Cert>> fetchCatalog();
}

/// In-memory catalog. Ordered India-first (Azure → AWS), with the
/// data-engineering certs kept as premium "specialization" tracks, but the
/// catalog itself is global — content is the same worldwide.
///
/// Each cert with real content points at its own lesson site; per-cert URLs
/// slot in here as new courses ship, without touching any screen.
class LocalCertRepository implements CertRepository {
  // Base site. The homepage is now the course catalog, so navigable certs must
  // point at their own course path (units & chapters), not the site root.
  static const _site = 'https://certify.courses';
  // Placeholder for coming-soon certs, which don't navigate yet; their real
  // course paths slot in here as content ships.
  static const _lessonUrl = _site;
  static const _deaUrl = '$_site/databricks-data-engineer-associate/index.html';
  static const _depUrl = '$_site/databricks-data-engineer-professional/index.html';

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
      // The only cert with real lesson content today, so it's the one that
      // actually opens. Everything below is "coming soon" and must not navigate.
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
