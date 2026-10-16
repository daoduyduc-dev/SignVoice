import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:sign_voice/features/auth/oauth_complete_screen.dart';
import 'package:sign_voice/providers/auth_provider.dart';
import 'package:sign_voice/services/api/api_client.dart';
import 'package:sign_voice/services/auth/auth_service.dart';

import 'auth_fixtures.dart';

void main() {
  test(
    'OAuth completion bootstraps user and metadata without prior local login',
    () async {
      final store = MemoryTokenStore();
      final api = ApiClient(
        tokenStorage: store,
        useRefreshCookie: true,
        client: MockClient((req) async {
          expect(req.method, 'POST');
          expect(req.url.path, '/api/v1/auth/oauth/complete');
          expect(req.headers['Authorization'], isNull);
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'user': testUser().toJson(),
                'tokens': {
                  'accessToken': 'oauth-access',
                  'refreshToken': 'oauth-refresh',
                },
              },
            }),
            200,
          );
        }),
      );
      final auth = AuthProvider(
        authService: AuthService(apiClient: api, tokenStorage: store),
      );
      expect(await auth.completeOAuth(), isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(store.role, 'USER');
      expect(store.accessToken, 'oauth-access');
      auth.dispose();
      api.dispose();
    },
  );
  test(
    'disabled providers are explicit and never synthesize a login',
    () async {
      final store = MemoryTokenStore();
      final api = ApiClient(
        tokenStorage: store,
        client: MockClient((req) async {
          expect(req.url.path, '/api/v1/auth/oauth/providers');
          return http.Response(
            '{"success":true,"data":{"google":false,"facebook":false}}',
            200,
          );
        }),
      );
      final service = AuthService(apiClient: api, tokenStorage: store);
      expect(await service.oauthProviders(), {
        'google': false,
        'facebook': false,
      });
      expect(store.accessToken, isNull);
      api.dispose();
    },
  );
  testWidgets(
    'callback cancellation shows safe explanation without session completion',
    (tester) async {
      final api = ApiClient(
        tokenStorage: MemoryTokenStore(),
        client: MockClient((_) async => throw StateError('Must not call API')),
      );
      final auth = AuthProvider(
        authService: AuthService(
          apiClient: api,
          tokenStorage: MemoryTokenStore(),
        ),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: auth,
          child: const MaterialApp(
            home: OAuthCompleteScreen(error: 'OAUTH_CANCELLED'),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('Bạn đã hủy đăng nhập'), findsOneWidget);
      expect(find.text('Quay lại đăng nhập'), findsOneWidget);
      expect(auth.isAuthenticated, isFalse);
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
      api.dispose();
    },
  );
  testWidgets(
    'callback failed completion stays unauthenticated with retry navigation',
    (tester) async {
      final store = MemoryTokenStore();
      final api = ApiClient(
        tokenStorage: store,
        client: MockClient(
          (_) async => http.Response(
            '{"error":{"code":"OAUTH_SESSION_MISSING","message":"Phiên không tồn tại"}}',
            401,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
      final auth = AuthProvider(
        authService: AuthService(apiClient: api, tokenStorage: store),
      );
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: auth,
          child: const MaterialApp(home: OAuthCompleteScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Phiên không tồn tại'), findsOneWidget);
      expect(auth.isAuthenticated, isFalse);
      expect(store.accessToken, isNull);
      await tester.pumpWidget(const SizedBox());
      auth.dispose();
      api.dispose();
    },
  );
}
