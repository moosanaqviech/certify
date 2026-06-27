import 'dart:async';
import 'package:flutter/material.dart';
import 'models/cert.dart';
import 'repositories/cert_repository.dart';
import 'services/settings_store.dart';

enum DownloadState { idle, downloading, done }

/// Keys for persisted settings. Kept in one place so the storage contract is
/// easy to audit and won't drift across setters.
class _Keys {
  static const onboarding = 'onboarding_complete';
  static const selectedCert = 'selected_cert';
  static const notifStreak = 'notif_streak';
  static const notifNew = 'notif_new';
  static const notifExam = 'notif_exam';
  static const remindMinutes = 'remind_minutes';
  static const reduceMotion = 'reduce_motion';
  static const fontIdx = 'font_idx';
}

class DownloadItem {
  final String id;
  final String name;
  final int sizeMb;
  DownloadState state;
  double progress;
  Timer? timer;

  DownloadItem({
    required this.id,
    required this.name,
    required this.sizeMb,
    this.state = DownloadState.idle,
    this.progress = 0.0,
  });

  String get statusText => state == DownloadState.done ? 'Downloaded' : 'Not downloaded';
  String get pct => '${(progress * 100).round()}%';
}

class AppState extends ChangeNotifier {
  bool hasCompletedOnboarding = false;
  String selectedCert = 'databricks-dea';

  bool notifStreak = true;
  bool notifNew = true;
  bool notifExam = false;
  TimeOfDay remindAt = const TimeOfDay(hour: 20, minute: 30);

  bool reduceMotion = false;
  int fontIdx = 1;

  // Catalog, loaded from the repository seam (hardcoded today, backend later).
  List<Cert> _catalog = [];
  List<Cert> get catalog => _catalog;
  bool catalogLoading = true;

  /// The cert the user is currently focused on. Falls back to the first cert
  /// if the persisted id isn't in the catalog (e.g. after a catalog change).
  Cert? get currentCert {
    if (_catalog.isEmpty) return null;
    return _catalog.firstWhere(
      (c) => c.id == selectedCert,
      orElse: () => _catalog.first,
    );
  }

  // Live download state for the current cert's units. Rebuilt whenever the
  // catalog loads or the selected cert changes.
  List<DownloadItem> downloads = [];

  final SettingsStore _store;
  final CertRepository _certRepo;

  AppState(this._store, this._certRepo) {
    _loadSettings();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    _catalog = await _certRepo.fetchCatalog();
    catalogLoading = false;
    _rebuildDownloads();
    notifyListeners();
  }

  /// Replace the live download list with runtime items for the current cert,
  /// seeding their initial state and resuming any in-flight download.
  void _rebuildDownloads() {
    for (final d in downloads) {
      d.timer?.cancel();
    }
    final cert = currentCert;
    downloads = cert == null
        ? []
        : cert.units
            .map((u) => DownloadItem(
                  id: u.id,
                  name: u.name,
                  sizeMb: u.sizeMb,
                  state: u.downloaded
                      ? DownloadState.done
                      : u.downloading
                          ? DownloadState.downloading
                          : DownloadState.idle,
                  progress: u.downloaded ? 1.0 : (u.downloading ? 0.46 : 0.0),
                ))
            .toList();
    for (final d in downloads) {
      if (d.state == DownloadState.downloading) _startDownloadTimer(d.id);
    }
  }

  /// Hydrate in-memory state from persisted settings. Falls back to the
  /// existing defaults when a key has never been written.
  void _loadSettings() {
    hasCompletedOnboarding = _store.getBool(_Keys.onboarding) ?? hasCompletedOnboarding;
    selectedCert = _store.getString(_Keys.selectedCert) ?? selectedCert;
    notifStreak = _store.getBool(_Keys.notifStreak) ?? notifStreak;
    notifNew = _store.getBool(_Keys.notifNew) ?? notifNew;
    notifExam = _store.getBool(_Keys.notifExam) ?? notifExam;
    reduceMotion = _store.getBool(_Keys.reduceMotion) ?? reduceMotion;
    fontIdx = _store.getInt(_Keys.fontIdx) ?? fontIdx;
    final mins = _store.getInt(_Keys.remindMinutes);
    if (mins != null) {
      remindAt = TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
    }
  }

  /// Maps the three text-size choices (small / medium / large) to a global
  /// text scale. Kept modest so the precise design tokens don't overflow.
  double get textScale => const [0.9, 1.0, 1.12][fontIdx.clamp(0, 2)];

  /// Collapses an animation duration to zero when "reduce motion" is on.
  /// Call this anywhere an explicit animation duration is used.
  Duration motion(Duration full) => reduceMotion ? Duration.zero : full;

  void toggleNotif(String key) {
    switch (key) {
      case 'streak':
        notifStreak = !notifStreak;
        _store.setBool(_Keys.notifStreak, notifStreak);
      case 'new':
        notifNew = !notifNew;
        _store.setBool(_Keys.notifNew, notifNew);
      case 'exam':
        notifExam = !notifExam;
        _store.setBool(_Keys.notifExam, notifExam);
    }
    notifyListeners();
  }

  void setRemindAt(TimeOfDay time) {
    remindAt = time;
    _store.setInt(_Keys.remindMinutes, time.hour * 60 + time.minute);
    notifyListeners();
  }

  void setFontIdx(int i) {
    fontIdx = i;
    _store.setInt(_Keys.fontIdx, i);
    notifyListeners();
  }

  void toggleReduceMotion() {
    reduceMotion = !reduceMotion;
    _store.setBool(_Keys.reduceMotion, reduceMotion);
    notifyListeners();
  }

  void selectCert(String id) {
    selectedCert = id;
    _store.setString(_Keys.selectedCert, id);
    _rebuildDownloads();
    notifyListeners();
  }

  void completeOnboarding() {
    hasCompletedOnboarding = true;
    _store.setBool(_Keys.onboarding, true);
    notifyListeners();
  }

  void toggleDownload(String id) {
    final item = downloads.firstWhere((d) => d.id == id);
    if (item.state == DownloadState.done || item.state == DownloadState.downloading) {
      item.timer?.cancel();
      item.state = DownloadState.idle;
      item.progress = 0.0;
    } else {
      _startDownloadTimer(id);
    }
    notifyListeners();
  }

  void _startDownloadTimer(String id) {
    final item = downloads.firstWhere((d) => d.id == id);
    item.state = DownloadState.downloading;
    item.timer?.cancel();
    item.timer = Timer.periodic(const Duration(milliseconds: 220), (timer) {
      item.progress = (item.progress + 0.08).clamp(0.0, 1.0);
      if (item.progress >= 1.0) {
        item.state = DownloadState.done;
        timer.cancel();
      }
      notifyListeners();
    });
  }

  int get usedMb => downloads.where((d) => d.state == DownloadState.done).fold(0, (a, d) => a + d.sizeMb);
  int get totalMb => downloads.fold(0, (a, d) => a + d.sizeMb);

  @override
  void dispose() {
    for (final item in downloads) {
      item.timer?.cancel();
    }
    super.dispose();
  }
}
