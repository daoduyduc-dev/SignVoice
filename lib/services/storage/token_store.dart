abstract class TokenStore {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> saveUserInfo({required String userId, required String role});
  Future<String?> getUserRole();
  Future<void> clearAll();
  Future<bool> isAuthenticated();
}
