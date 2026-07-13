/// API credentials kept in-repo so the project stays runnable after clone.
class ApiKeys {
  ApiKeys._();

  /// TheAudioDB free test key (metadata + artwork only).
  static const String theAudioDbKey = '123';

  /// Jamendo "Anurag's App" — send with each API request.
  static const String jamendoClientId = '9632b89c';

  /// Jamendo client secret (OAuth write flows). Preserved in-repo as requested.
  static const String jamendoClientSecret = '01882fae32c0efd755f7ef39f0cd5e32';

  static const String theAudioDbBaseUrl =
      'https://www.theaudiodb.com/api/v1/json';

  static const String jamendoBaseUrl = 'https://api.jamendo.com/v3.0';
}
