/// Konfigurasi API yang membaca variabel dari `--dart-define`.
class ApiConfig {
  const ApiConfig._();

  /// URL utama REST API dari `--dart-define=API_BASE_URL=...`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Token otentikasi dari `--dart-define=API_TOKEN=...`.
  static const String token = String.fromEnvironment(
    'API_TOKEN',
    defaultValue: '',
  );

  /// Durasi timeout standar untuk koneksi HTTP (10 detik).
  static const Duration timeout = Duration(seconds: 10);

  /// Menentukan apakah aplikasi berjalan dalam mode Mock (offline fixture).
  static bool get useMock => baseUrl.isEmpty;
}
