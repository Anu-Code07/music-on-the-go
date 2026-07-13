/// Third-party API config for Discover / artwork lookup.
///
/// Override at build time for production:
/// `flutter build ipa --dart-define=JAMENDO_CLIENT_ID=your_id`
class ApiKeys {
  ApiKeys._();

  static const String theAudioDbKey = String.fromEnvironment(
    'THEAUDIODB_KEY',
    defaultValue: '123',
  );

  static const String jamendoClientId = String.fromEnvironment(
    'JAMENDO_CLIENT_ID',
    defaultValue: '9632b89c',
  );

  static const String theAudioDbBaseUrl =
      'https://www.theaudiodb.com/api/v1/json';

  static const String jamendoBaseUrl = 'https://api.jamendo.com/v3.0';
}
