# Independent OAuth review

Date: 2026-10-16. Reviewed implementation `e0081cf` with test isolation guard
`50bce7b`, in `task/non-ai-oauth-review`. Verdict: **changes required** for R1.
No product code was changed during review.

## R1 — incorrect current password logs out a valid user (P1)

`backend/src/services/auth.service.ts:560-561` responds with HTTP 401
`AUTH_INVALID_CREDENTIALS` when password-change proof is wrong, despite a valid access
session. The real `ApiClient._request` catches UnauthorizedException and calls
`_invalidateSession`; this clears token storage and notifies AuthProvider. Consequently
AuthProvider.changePassword returns false but the previously authenticated user is logged
out and cannot correct the form without signing in again. Server sessions are still valid.

Independently reproduced with a controlled HTTP boundary and the real
AuthProvider/AuthService/ApiClient: login -> valid access token -> wrong-password response
401 -> `auth.isAuthenticated == false`, access token null, sessionInvalidated counter 1.
Existing backend test currently expects this 401, so its passing result does not establish
the correct frontend lifecycle.

Return a 400/422 proof-validation error consistently with profile/email/delete proof
failures, reserving authentication 401 for invalid access credentials; add a real-client
regression that asserts false operation result **and preserved authentication/tokens**, then
successful retry. The review reproduction is retained below for adoption in tests.

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sign_voice/providers/auth_provider.dart';
import 'package:sign_voice/services/api/api_client.dart';
import 'package:sign_voice/services/auth/auth_service.dart';
import 'auth_fixtures.dart';

void main() {
  test('review reproduction: wrong proof invalidates a valid session', () async {
    final store = MemoryTokenStore();
    final api = ApiClient(tokenStorage: store, client: MockClient((req) async {
      if (req.url.path.endsWith('/login')) {
        return http.Response(jsonEncode({'success': true, 'data': {
          'user': testUser().toJson(),
          'tokens': {'accessToken': 'valid-access', 'refreshToken': 'valid-refresh'},
        }}), 200);
      }
      return http.Response(jsonEncode({'success': false, 'error': {
        'code': 'AUTH_INVALID_CREDENTIALS', 'message': 'Wrong current password',
      }}), 401);
    }));
    final auth = AuthProvider(authService: AuthService(apiClient: api, tokenStorage: store));
    expect(await auth.login(email: 'user@example.com', password: 'Password123'), true);
    expect(await auth.changePassword(currentPassword: 'wrong', newPassword: 'Password456'), false);
    // These assertions reproduce the defect; invert for the corrected regression.
    expect(auth.isAuthenticated, false);
    expect(store.accessToken, isNull);
    expect(api.sessionInvalidated.value, 1);
    auth.dispose();
    api.dispose();
  });
}
```

## Accepted evidence

- Guarded database run: **60/60 passed**, across oauth (25), auth (9), auth-security
  (15), password-reset (11). Dedicated databases were
  `signvoice_test_oauth_review_{1..4}`; credentials were derived in process and never
  printed. No normal user database was queried or mutated.
- Standalone Flutter OAuth tests: **4/4 passed**. Additional independent R1 reproduction:
  **1/1 passed**, confirming the defect described above.
- Backend typecheck passed. OpenAPI validation passed; route coverage **68/68**.
- Focused Flutter analyzer exited 1 on **five info-level curly-brace diagnostics** in
  auth_screens.dart (273,279,306) and auth_service.dart (40,44). No errors/warnings
  reported in the focused files. Full app compilation is deferred until sibling
  `AppState.bindAccount` implementation is merged.

## Protocol/source review

The implementation uses fixed environment-derived origins/callbacks, rejects unsafe and
cross-site destinations, and preserves email/guest methods without provider config.
State uses cryptographic randomness, browser/provider/destination binding, short expiry,
and atomic findOneAndDelete; denial consumes the state before returning a safe error.
Google code exchange uses the official library plus audience/issuer/expiry/subject,
verified email and request nonce checks, with S256 PKCE. Facebook code exchange checks
debug_token app/user/type/validity/expiry and matching /me identity with appsecret_proof.
Only subject identifies an existing social account; local-email collisions are rejected.
Named unique subject/email indexes and duplicate-key recovery address first-login races;
User.init is awaited before OAuth resolution. Providers' tokens are no longer schema
fields and are not persisted or returned. Success/error redirects contain no tokens,
and completion requires the exact allowed frontend Origin before rotating a real persisted
refresh session. Explicit safe user DTOs are used for OAuth responses.

Setup documentation matches implementation env names and exact callbacks, including
localhost HTTP only outside production, same-origin public HTTPS, changing Conveyor
origins in both server config/provider consoles, absent credentials, web-only native
limitation and index readiness/migration instructions. No blind production index sync
or data migration was performed.

Reference checked: [Google OpenID Connect](https://developers.google.com/identity/openid-connect/openid-connect).
The [Meta debug_token reference](https://developers.facebook.com/docs/graph-api/reference/debug_token/)
again returned HTTP 429 to the research tool. Therefore no new claim about current Meta
console policy or live compatibility is established by this review.

## Remaining acceptance boundaries

- R1 must be fixed and independently rerun before approval.
- Full integrated Flutter analyzer/test/build, routed initial callback and account-bound
  state lifecycle await sibling FE integration; standalone mocks cannot establish these.
- Real Google/Facebook consent, real browser cookie navigation and phone/Conveyor login
  remain unverified until credentials and registered origins exist. Existing tests mock
  the external provider network/verifier while exercising real DB/session routes.
- Unique index creation failure is fail-closed during user resolution. Existing deployment
  index readiness remains an operator prerequisite, as documented; no existing production
  indexes/data were inspected.
