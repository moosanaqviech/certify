import 'package:certify/models/cert.dart';
import 'package:certify/repositories/cert_repository.dart';
import 'package:certify/screens/catalog_screen.dart';
import 'package:certify/screens/lesson_screen.dart';
import 'package:certify/services/notification_service.dart';
import 'package:certify/services/settings_store.dart';
import 'package:certify/state.dart';
import 'package:certify/widgets/cert_visuals.dart';
import 'package:certify/widgets/course_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Map<String, dynamic> _baseJson() => {
      'id': 'databricks-dea',
      'vendor': 'Databricks',
      'track': 'Data Engineer Associate',
      'exam_code': null,
      'monogram': 'D',
      'accent': '#8D7BF6',
      'ink': '#B4A9FF',
      'lesson_url': 'https://certify.courses/databricks-data-engineer-associate/index.html',
      'lessons_total': 35,
      'status': 'live',
    };

Map<String, dynamic> _fullJson() => {
      ..._baseJson(),
      'exam_code': 'DEA-02',
      'questions_total': 420,
      'mocks_total': 3,
      'level': 'associate',
      'last_verified': '2026-09-21',
      'icon': 'database',
      'practice_url': 'https://certify.courses/practice/databricks-de-associate',
      'ready_url': 'https://certify.courses/ready/databricks-de-associate',
      'guide_url': 'https://certify.courses/guide/databricks-de-associate',
      'price': r'$9.99',
      'price_note': 'one-time unlock after free Unit 1',
    };

/// [Cert.fromJson] then overlay local progress, as the app would.
Cert _withProgress(Cert c, int done) => Cert(
      id: c.id,
      vendor: c.vendor,
      track: c.track,
      examCode: c.examCode,
      monogram: c.monogram,
      accentArgb: c.accentArgb,
      inkArgb: c.inkArgb,
      lessonUrl: c.lessonUrl,
      lessonsDone: done,
      lessonsTotal: c.lessonsTotal,
      status: c.status,
      questionsTotal: c.questionsTotal,
      mocksTotal: c.mocksTotal,
      level: c.level,
      lastVerified: c.lastVerified,
      icon: c.icon,
      practiceUrl: c.practiceUrl,
      readyUrl: c.readyUrl,
      guideUrl: c.guideUrl,
      price: c.price,
      priceNote: c.priceNote,
    );

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)),
    );

class _MemoryStore implements SettingsStore {
  final _m = <String, Object>{};
  @override
  Future<void> load() async {}
  @override
  bool? getBool(String key) => _m[key] as bool?;
  @override
  int? getInt(String key) => _m[key] as int?;
  @override
  String? getString(String key) => _m[key] as String?;
  @override
  Future<void> setBool(String key, bool value) async => _m[key] = value;
  @override
  Future<void> setInt(String key, int value) async => _m[key] = value;
  @override
  Future<void> setString(String key, String value) async => _m[key] = value;
}

class _NoopNotifications implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleDailyReminder(TimeOfDay time) async {}
  @override
  Future<void> cancelDailyReminder() async {}
}

class _FixedRepo implements CertRepository {
  final List<Cert> certs;
  _FixedRepo(this.certs);
  @override
  Future<List<Cert>> fetchCatalog() async => certs;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('Cert JSON', () {
    test('parses and re-emits the optional fields', () {
      final cert = Cert.fromJson(_fullJson());
      expect(cert.questionsTotal, 420);
      expect(cert.mocksTotal, 3);
      expect(cert.level, 'associate');
      expect(cert.lastVerified, '2026-09-21');
      expect(cert.icon, 'database');
      expect(cert.readyUrl, endsWith('/ready/databricks-de-associate'));
      final out = cert.toJson();
      for (final k in [
        'questions_total', 'mocks_total', 'level', 'last_verified', 'icon',
        'practice_url', 'ready_url', 'guide_url', 'price', 'price_note',
      ]) {
        expect(out[k], _fullJson()[k], reason: k);
      }
    });

    test('tolerates every optional field being absent', () {
      final cert = Cert.fromJson(_baseJson());
      expect(cert.questionsTotal, isNull);
      expect(cert.practiceUrl, isNull);
      expect(cert.toJson().containsKey('questions_total'), isFalse);
    });
  });

  group('CertCard', () {
    testWidgets('renders every field when present', (tester) async {
      final cert = _withProgress(Cert.fromJson(_fullJson()), 11);
      var practice = 0, start = 0, more = 0;
      await tester.pumpWidget(_host(CertCard(
        cert: cert,
        onStart: () => start++,
        onPractice: () => practice++,
        onMore: () => more++,
      )));

      expect(find.byType(StrokeIcon), findsWidgets);
      expect(find.text('Data Engineer Associate'), findsOneWidget);
      expect(find.text('ASSOCIATE'), findsOneWidget);
      expect(find.text('DEA-02 · 35 chapters · 420 questions · 3 mock exams'), findsOneWidget);
      expect(find.text('11 of 35'), findsOneWidget);
      expect(find.text('Verified 21 Sep 2026'), findsOneWidget);
      // Price is behind the showPrices flag, which is off by default.
      expect(find.textContaining(r'$9.99'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Practice'));
      await tester.tap(find.bySemanticsLabel('Continue'));
      await tester.tap(find.bySemanticsLabel('More about Data Engineer Associate'));
      expect([practice, start, more], [1, 1, 1]);

      for (final label in ['Practice', 'Continue', 'More about Data Engineer Associate']) {
        expect(tester.getSize(find.bySemanticsLabel(label)).height, greaterThanOrEqualTo(44), reason: label);
      }
    });

    testWidgets('shows the price line only when the flag is on', (tester) async {
      await tester.pumpWidget(_host(CertCard(
        cert: Cert.fromJson(_fullJson()),
        onStart: () {},
        onPractice: () {},
        onMore: () {},
        showPrices: true,
      )));
      expect(find.text(r'$9.99 · one-time unlock after free Unit 1'), findsOneWidget);
    });

    testWidgets('with only lessons_total shows just the essentials', (tester) async {
      final cert = Cert.fromJson({..._baseJson(), 'vendor': 'Oracle', 'monogram': 'Jv'});
      await tester.pumpWidget(_host(CertCard(cert: cert, onStart: () {}, onPractice: () {}, onMore: () {})));

      expect(find.text('35 chapters'), findsOneWidget);
      expect(find.text('Jv'), findsOneWidget); // monogram fallback in the tile
      expect(find.byType(StrokeIcon), findsNothing);
      expect(find.byType(LevelChip), findsNothing);
      expect(find.byType(CertProgress), findsNothing);
      expect(find.textContaining('Verified'), findsNothing);
      expect(find.bySemanticsLabel('Practice'), findsNothing);
      expect(find.bySemanticsLabel('Start'), findsOneWidget);
      expect(find.bySemanticsLabel('More about Data Engineer Associate'), findsOneWidget);
    });

    testWidgets('mapped vendor shows its bundled logo instead of the monogram', (tester) async {
      final cert = Cert.fromJson(_baseJson()); // Databricks -> assets/brands/databricks.png
      await tester.runAsync(() async {
        await tester.pumpWidget(_host(CertCard(cert: cert, onStart: () {}, onPractice: () {}, onMore: () {})));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('D'), findsNothing);
    });
  });

  testWidgets('planned certs move to a Coming soon section with Notify me', (tester) async {
    final live = Cert.fromJson(_baseJson());
    final planned = Cert.fromJson({
      ..._baseJson(),
      'id': 'azure-dp700',
      'vendor': 'Microsoft Azure',
      'track': 'Data Engineer',
      'exam_code': 'DP-700',
      'monogram': 'Az',
      'lesson_url': 'https://certify.courses',
      'lessons_total': 0,
      'status': 'planned',
    });
    final store = _MemoryStore()..setBool('notif_new', false);
    final state = AppState(store, _FixedRepo([live, planned]), _NoopNotifications());

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: const MaterialApp(home: CatalogScreen()),
    ));
    await tester.pump();

    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.byType(CertCard), findsOneWidget);
    expect(find.widgetWithText(PlannedCertCard, 'Data Engineer'), findsOneWidget);
    expect(find.text('Microsoft Azure · DP-700'), findsOneWidget);
    // The planned cert's vendor gets no section of its own.
    expect(find.byType(VendorHeader), findsOneWidget);

    await tester.ensureVisible(find.byType(PlannedCertCard));
    await tester.pumpAndSettle();
    final notify = find.bySemanticsLabel('Notify me when Data Engineer launches');
    expect(tester.getSize(notify).height, greaterThanOrEqualTo(44));
    await tester.tap(notify);
    await tester.pump();
    expect(state.notifNew, isTrue);
    expect(find.text("We'll let you know when Data Engineer launches."), findsOneWidget);
  });

  testWidgets('"⋯" opens the course sheet from the catalog', (tester) async {
    final state = AppState(_MemoryStore(), _FixedRepo([Cert.fromJson(_fullJson())]), _NoopNotifications());
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: state,
      child: const MaterialApp(home: CatalogScreen()),
    ));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('More about Data Engineer Associate'));
    await tester.pumpAndSettle();
    expect(find.byType(CourseSheet), findsOneWidget);
    expect(find.text('DATABRICKS · ASSOCIATE'), findsOneWidget);
  });

  group('CourseSheet', () {
    testWidgets('hides stats and rows the manifest does not provide', (tester) async {
      final cert = Cert.fromJson(_baseJson());
      await tester.pumpWidget(_host(CourseSheet(cert: cert, onOpen: (_) {})));

      expect(find.text('DATABRICKS'), findsOneWidget);
      expect(find.text('Chapters'), findsOneWidget);
      expect(find.text('Questions'), findsNothing);
      expect(find.text('Mock exams'), findsNothing);
      expect(find.bySemanticsLabel('Start learning'), findsOneWidget);
      expect(find.bySemanticsLabel('Practice questions'), findsNothing);
      expect(find.bySemanticsLabel('Am I ready?'), findsNothing);
      expect(find.bySemanticsLabel('Read the exam guide'), findsNothing);
      expect(find.textContaining('Content verified'), findsNothing);
    });

    testWidgets('shows everything and opens each URL', (tester) async {
      final cert = _withProgress(Cert.fromJson(_fullJson()), 11);
      final opened = <LessonArgs>[];
      await tester.pumpWidget(_host(CourseSheet(cert: cert, onOpen: opened.add)));

      expect(find.text('DATABRICKS · ASSOCIATE'), findsOneWidget);
      expect(find.text('420'), findsOneWidget);
      expect(find.text('Mock exams'), findsOneWidget);
      expect(find.text('11 of 35'), findsOneWidget);
      expect(find.text('Content verified against the exam guide on 21 Sep 2026'), findsOneWidget);

      for (final label in ['Continue learning', 'Practice questions', 'Am I ready?', 'Read the exam guide']) {
        await tester.ensureVisible(find.bySemanticsLabel(label));
        await tester.tap(find.bySemanticsLabel(label));
      }
      expect(opened.map((a) => a.url), [
        cert.lessonUrl,
        cert.practiceUrl,
        cert.readyUrl,
        cert.guideUrl,
      ]);
    });
  });
}
