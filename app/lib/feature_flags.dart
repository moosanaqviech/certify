/// Compile-time feature flags. Override at build time with
/// `--dart-define=SHOW_PRICES=true`; swap for a remote-config lookup once one
/// exists, keeping these names as the defaults.
class FeatureFlags {
  /// Shows the catalog's display-only `price` / `price_note` line on cards.
  ///
  /// OFF by default. Selling web unlocks from inside the iOS/Android app can
  /// conflict with App Store guideline 3.1.1 and Google Play's payments
  /// policy, so the app never links to a purchase — at most it shows the price.
  static const bool showPrices =
      bool.fromEnvironment('SHOW_PRICES', defaultValue: false);
}
