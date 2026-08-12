import 'package:flutter_test/flutter_test.dart';
import 'package:p03_provider_crud/core/errors/api_error.dart';

void main() {
  group('ApiError Unit Tests & Sealed Switch Exhaustiveness', () {
    test('mapResponseToError memetakan HTTP Status Code dengan benar', () {
      expect(mapResponseToError(500), isA<ServerError>());
      expect(mapResponseToError(503), isA<ServerError>());
      expect(mapResponseToError(404), isA<NotFoundError>());
      expect(mapResponseToError(401), isA<ClientError>());
      expect(mapResponseToError(409), isA<ClientError>());
      expect(mapResponseToError(422), isA<ClientError>());
    });

    test('sealed switch pattern menangani semua subtype ApiError secara exhaustif', () {
      final errors = <ApiError>[
        const NetworkError(),
        const ServerError(500),
        const ClientError(400),
        const NotFoundError(),
        const ParseError(),
      ];

      for (final error in errors) {
        final label = switch (error) {
          NetworkError() => 'network',
          ServerError() => 'server',
          ClientError() => 'client',
          NotFoundError() => 'not_found',
          ParseError() => 'parse',
        };
        expect(label, isNotEmpty);
      }
    });
  });
}
