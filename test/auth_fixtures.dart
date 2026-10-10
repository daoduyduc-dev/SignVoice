import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sign_voice/models/user_model.dart';
import 'package:sign_voice/providers/auth_provider.dart';
import 'package:sign_voice/services/api/api_client.dart';
import 'package:sign_voice/services/auth/auth_service.dart';
import 'package:sign_voice/services/storage/token_store.dart';
import 'package:sign_voice/services/admin/admin_workspace_service.dart';
import 'package:sign_voice/core/app_state.dart';

class DemoDictionaryService extends AdminWorkspaceService {
  @override
  Future<List<AdminRecord>> activeCategories() async => signs
      .map((sign) => sign.category)
      .toSet()
      .map((name) => {'_id': name, 'name': name})
      .toList();
  @override
  Future<AdminPageData> published({
    int page = 1,
    String search = '',
    String? categoryId,
  }) async => AdminPageData(
    signs
        .where(
          (sign) =>
              (search.isEmpty || sign.name.contains(search)) &&
              (categoryId == null || sign.category == categoryId),
        )
        .map(
          (sign) => {
            '_id': sign.name,
            'word': sign.name,
            'definition': sign.meaning,
            'usageExample': sign.example,
            'categoryId': {'name': sign.category},
          },
        )
        .toList(),
    1,
    1,
    signs.length,
  );
}

class MemoryTokenStore implements TokenStore {
  String? accessToken;
  String? refreshToken;
  String? role;
  int writes = 0;
  @override
  Future<String?> getAccessToken() async => accessToken;
  @override
  Future<String?> getRefreshToken() async => refreshToken;
  @override
  Future<String?> getUserRole() async => role;
  @override
  Future<bool> isAuthenticated() async => accessToken != null;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    writes++;
  }

  @override
  Future<void> saveUserInfo({
    required String userId,
    required String role,
  }) async => this.role = role;
  @override
  Future<void> clearAll() async {
    accessToken = null;
    refreshToken = null;
    role = null;
  }
}

UserModel testUser({UserRole role = UserRole.user, bool guest = false}) =>
    UserModel(
      id: '0123456789abcdef01234567',
      email: guest ? null : 'user@example.com',
      displayName: 'Test User',
      accountType: guest ? AccountType.guest : AccountType.local,
      role: role,
      status: AccountStatus.active,
      isGuest: guest,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

class FakeAuthService extends AuthService {
  FakeAuthService({this.restoredUser, this.role = UserRole.user})
    : super(
        apiClient: ApiClient(
          client: MockClient((_) async => http.Response('{}', 500)),
          tokenStorage: MemoryTokenStore(),
          useRefreshCookie: false,
        ),
        tokenStorage: MemoryTokenStore(),
      );
  final UserModel? restoredUser;
  final UserRole role;
  bool failLogin = false;
  @override
  Future<UserModel?> restoreSession() async => restoredUser;
  @override
  Future<UserModel> getCurrentUser() async =>
      restoredUser ?? testUser(role: role);
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (failLogin) throw Exception('Invalid credentials');
    return testUser(role: role);
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async =>
      testUser(role: role).copyWith(displayName: displayName, email: email);
  @override
  Future<UserModel> loginAsGuest() async => testUser(guest: true);
  @override
  Future<void> logout() async {}
}

Future<AuthProvider> authenticatedProvider({
  UserRole role = UserRole.user,
}) async {
  final provider = AuthProvider(
    authService: FakeAuthService(restoredUser: testUser(role: role)),
  );
  await provider.initialize();
  return provider;
}
