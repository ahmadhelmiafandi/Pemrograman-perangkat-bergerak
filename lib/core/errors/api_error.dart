/// Hirarki error terstruktur untuk API layer menggunakan Dart 3 sealed class.
sealed class ApiError implements Exception {
  const ApiError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Error koneksi/jaringan (mis. socket exception, timeout, offline).
class NetworkError extends ApiError {
  const NetworkError([super.message = 'Network error: tidak ada koneksi.']);
}

/// Error dari server HTTP 5xx (mis. 500, 502, 503).
class ServerError extends ApiError {
  const ServerError(this.status, [String? message])
      : super(message ?? 'Server error ($status): coba lagi nanti atau pakai fallback.');
  final int status;
}

/// Error dari permintaan klien HTTP 4xx (mis. 400, 401, 403, 409, 422).
class ClientError extends ApiError {
  const ClientError(this.status, [String? message])
      : super(message ?? 'Client error ($status): permintaan tidak valid.');
  final int status;
}

/// Error khusus untuk resource tidak ditemukan (HTTP 404).
class NotFoundError extends ApiError {
  const NotFoundError([super.message = 'Task tidak ditemukan (404).']);
}

/// Error penafsiran/parsing JSON response.
class ParseError extends ApiError {
  const ParseError([super.message = 'Response tidak dapat di-parse.']);
}

/// Memetakan HTTP Status Code ke subtype [ApiError] terstruktur.
ApiError mapResponseToError(int status) {
  if (status >= 500) return ServerError(status);
  if (status == 404) return const NotFoundError();
  if (status >= 400) return ClientError(status);
  return ClientError(status, 'Unexpected status $status');
}
