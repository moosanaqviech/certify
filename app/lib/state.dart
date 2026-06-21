import 'dart:async';
import 'package:flutter/material.dart';

enum DownloadState { idle, downloading, done }

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
  String selectedCert = 'databricks';

  bool notifStreak = true;
  bool notifNew = true;
  bool notifExam = false;
  TimeOfDay remindAt = const TimeOfDay(hour: 20, minute: 30);

  bool reduceMotion = false;
  int fontIdx = 1;

  final List<DownloadItem> downloads = [
    DownloadItem(id: 'u1', name: 'Foundations of the Lakehouse', sizeMb: 42, state: DownloadState.done, progress: 1.0),
    DownloadItem(id: 'u2', name: 'Delta Lake & ACID tables', sizeMb: 58, state: DownloadState.downloading, progress: 0.46),
    DownloadItem(id: 'u3', name: 'ELT pipelines with Spark', sizeMb: 71),
    DownloadItem(id: 'u4', name: 'Productionizing workflows', sizeMb: 63),
  ];

  AppState() {
    _startDownloadTimer('u2');
  }

  void toggleNotif(String key) {
    switch (key) {
      case 'streak': notifStreak = !notifStreak;
      case 'new': notifNew = !notifNew;
      case 'exam': notifExam = !notifExam;
    }
    notifyListeners();
  }

  void setRemindAt(TimeOfDay time) {
    remindAt = time;
    notifyListeners();
  }

  void setFontIdx(int i) {
    fontIdx = i;
    notifyListeners();
  }

  void toggleReduceMotion() {
    reduceMotion = !reduceMotion;
    notifyListeners();
  }

  void selectCert(String id) {
    selectedCert = id;
    notifyListeners();
  }

  void completeOnboarding() {
    hasCompletedOnboarding = true;
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
