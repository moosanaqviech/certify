import 'package:shared_preferences/shared_preferences.dart';

/// Persists small key-value user settings.
///
/// This is the seam: the UI/state layer depends on this interface, never on a
/// concrete storage engine. Today it's backed by [SharedPreferences] (on-device
/// only). When the backend lands, a `BackendSettingsStore` can implement the
/// same interface and sync these values to the server without any UI changes.
///
/// Reads are synchronous (values are cached in memory after [load]); writes are
/// fire-and-forget so setters in the app state stay synchronous.
abstract class SettingsStore {
  /// Must be awaited once before the store is read.
  Future<void> load();

  bool? getBool(String key);
  int? getInt(String key);
  String? getString(String key);

  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setString(String key, String value);
}

class SharedPrefsSettingsStore implements SettingsStore {
  SharedPreferences? _prefs;

  SharedPreferences get _p {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('SettingsStore.load() must be awaited before use.');
    }
    return prefs;
  }

  @override
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  bool? getBool(String key) => _p.getBool(key);

  @override
  int? getInt(String key) => _p.getInt(key);

  @override
  String? getString(String key) => _p.getString(key);

  @override
  Future<void> setBool(String key, bool value) => _p.setBool(key, value);

  @override
  Future<void> setInt(String key, int value) => _p.setInt(key, value);

  @override
  Future<void> setString(String key, String value) => _p.setString(key, value);
}
