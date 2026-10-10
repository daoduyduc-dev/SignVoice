# SignVoice Frontend Integration Handoff

**Backend Version:** 1.0.0  
**Date:** 2026-10-09  
**Batch:** 01 Complete  
**Target:** Flutter Android & Web  

---

## 1. API BASE CONFIGURATION

### Local Development
```
BASE_URL: http://localhost:3000
API_PREFIX: /api/v1
```

### API Endpoints Format
```
http://localhost:3000/api/v1/{resource}
```

---

## 2. AUTHENTICATION FLOW

### 2.1 Registration (S06)
```
POST /api/v1/auth/register
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "Test1234",      // Min 8 chars, letter + number
  "displayName": "User Name"
}

Response (201):
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "displayName": "User Name",
      "role": "USER",
      "isGuest": false
    },
    "tokens": {
      "accessToken": "eyJhbGc...",
      "refreshToken": "eyJhbGc...",
      "accessTokenExpiresAt": "2026-10-09T15:15:00.000Z",
      "refreshTokenExpiresAt": "2026-10-16T15:00:00.000Z"
    }
  }
}
```

### 2.2 Login (S05)
```
POST /api/v1/auth/login
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "Test1234"
}

Response (200): Same as registration
```

### 2.3 Guest Mode (S05)
```
POST /api/v1/auth/guest

Response (201):
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "displayName": "Guest_abc123",
      "role": "USER",
      "isGuest": true
    },
    "tokens": { ... }
  }
}
```

### 2.4 Convert Guest (S06)
```
POST /api/v1/auth/convert-guest
Authorization: Bearer {accessToken}
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "Test1234",
  "displayName": "Real Name"
}

Response (200): Same as registration
```

### 2.5 Token Refresh
```
POST /api/v1/auth/refresh
Content-Type: application/json

Request:
{
  "refreshToken": "eyJhbGc..."
}

Response (200):
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "accessTokenExpiresAt": "2026-10-09T15:30:00.000Z",
    "refreshTokenExpiresAt": "2026-10-16T15:15:00.000Z"
  }
}
```

**Token Management:**
- Access token: 15 minutes
- Refresh token: 7 days
- Store both securely (Flutter secure_storage)
- Refresh when access token expires (401 error)

### 2.6 Get Current User (S25)
```
GET /api/v1/auth/me
Authorization: Bearer {accessToken}

Response (200):
{
  "success": true,
  "data": {
    "id": "507f1f77bcf86cd799439011",
    "email": "user@example.com",
    "displayName": "User Name",
    "avatarUrl": null,
    "role": "USER",
    "accountType": "LOCAL",
    "isGuest": false,
    "status": "ACTIVE",
    "createdAt": "2026-10-09T14:00:00.000Z"
  }
}
```

### 2.7 Logout (S25)
```
POST /api/v1/auth/logout
Authorization: Bearer {accessToken}

Response (200):
{
  "success": true,
  "data": {
    "message": "Logged out successfully"
  }
}
```

---

## 3. DICTIONARY API (S20, S22, S23)

### 3.1 Get Dictionary Entries
```
GET /api/v1/dictionary?categoryId={id}&search={query}&difficulty={level}&limit=20&skip=0
Authorization: Bearer {accessToken} (optional - for history tracking)

Response (200):
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "word": "Xin chào",
      "definition": "Greeting used to say hello",
      "videoUrl": "https://example.com/video.mp4",
      "thumbnailUrl": "https://example.com/thumb.jpg",
      "categoryId": {
        "_id": "507f...",
        "name": "Greetings",
        "slug": "greetings",
        "icon": "👋"
      },
      "tags": ["greeting", "hello"],
      "difficulty": "BEGINNER",
      "viewCount": 150,
      "favoriteCount": 25,
      "status": "PUBLISHED",
      "publishedAt": "2026-10-01T00:00:00.000Z"
    }
  ],
  "pagination": {
    "total": 100,
    "limit": 20,
    "skip": 0
  }
}
```

### 3.2 Get Entry Detail (S23)
```
GET /api/v1/dictionary/{entryId}
Authorization: Bearer {accessToken} (optional)

Response (200): Single entry object
```

### 3.3 Get Popular Entries (S08)
```
GET /api/v1/dictionary/popular?limit=10

Response (200):
{
  "success": true,
  "data": [ /* array of entries */ ]
}
```

---

## 4. CATEGORIES API (S22)

### 4.1 Get All Categories
```
GET /api/v1/categories

Response (200):
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Greetings",
      "slug": "greetings",
      "description": "Common greetings and introductions",
      "icon": "👋",
      "sortOrder": 1,
      "wordCount": 15,
      "parentId": null
    }
  ]
}
```

### 4.2 Get Category by Slug
```
GET /api/v1/categories/{slug}

Response (200): Single category object
```

---

## 5. FAVORITES API (S24)

### 5.1 Get User Favorites
```
GET /api/v1/favorites?limit=20&skip=0
Authorization: Bearer {accessToken}

Response (200):
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "userId": "507f...",
      "entryId": {
        "_id": "507f...",
        "word": "Xin chào",
        "definition": "...",
        "videoUrl": "...",
        "thumbnailUrl": "...",
        "categoryId": "507f...",
        "status": "PUBLISHED"
      },
      "notes": "Practice this daily",
      "createdAt": "2026-10-08T10:00:00.000Z"
    }
  ]
}
```

### 5.2 Add Favorite (S23)
```
POST /api/v1/favorites
Authorization: Bearer {accessToken}
Content-Type: application/json

Request:
{
  "entryId": "507f1f77bcf86cd799439011",
  "notes": "Optional personal note"
}

Response (201):
{
  "success": true,
  "data": { /* favorite object */ }
}
```

### 5.3 Remove Favorite (S24)
```
DELETE /api/v1/favorites/{entryId}
Authorization: Bearer {accessToken}

Response (200):
{
  "success": true,
  "data": {
    "message": "Favorite removed"
  }
}
```

---

## 6. HISTORY API (S21)

### 6.1 Get Search History
```
GET /api/v1/history?limit=50&skip=0
Authorization: Bearer {accessToken}

Response (200):
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "userId": "507f...",
      "entryId": {
        "_id": "507f...",
        "word": "Xin chào",
        /* ... entry details ... */
      },
      "viewedAt": "2026-10-09T14:30:00.000Z",
      "createdAt": "2026-10-08T10:00:00.000Z"
    }
  ]
}
```

### 6.2 Clear History (S21)
```
DELETE /api/v1/history
Authorization: Bearer {accessToken}

Response (200):
{
  "success": true,
  "data": {
    "message": "History cleared",
    "deletedCount": 42
  }
}
```

---

## 7. USER PROFILE & SETTINGS (S25-S31)

### 7.1 Get Profile (S25)
```
GET /api/v1/users/profile
Authorization: Bearer {accessToken}

Response (200): Same as /auth/me
```

### 7.2 Update Profile (S26)
```
PATCH /api/v1/users/profile
Authorization: Bearer {accessToken}
Content-Type: application/json

Request:
{
  "displayName": "New Name",
  "avatarUrl": "https://example.com/avatar.jpg"
}

Response (200):
{
  "success": true,
  "data": { /* updated user object */ }
}
```

### 7.3 Get Settings (S27-S31)
```
GET /api/v1/users/settings
Authorization: Bearer {accessToken}

Response (200):
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "507f...",
    "theme": "SYSTEM",
    "fontSize": 16,
    "notificationsEnabled": true,
    "notificationPreferences": {
      "newWords": true,
      "favorites": true,
      "updates": true
    },
    "shareUsageData": false,
    "createdAt": "2026-10-09T14:00:00.000Z",
    "updatedAt": "2026-10-09T14:00:00.000Z"
  }
}
```

### 7.4 Update Settings (S27-S31)
```
PATCH /api/v1/users/settings
Authorization: Bearer {accessToken}
Content-Type: application/json

Request:
{
  "theme": "DARK",
  "fontSize": 18,
  "notificationsEnabled": false
}

Response (200): Updated settings object
```

---

## 8. ERROR HANDLING

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "AUTH_INVALID_CREDENTIALS",
    "message": "Invalid credentials"
  },
  "requestId": "req_1791557246411_a4iqscvtcba"
}
```

### Common Error Codes
- `AUTH_REQUIRED`: Authentication required
- `AUTH_TOKEN_INVALID`: Invalid or malformed token
- `AUTH_TOKEN_EXPIRED`: Token expired (refresh it)
- `AUTH_INVALID_CREDENTIALS`: Wrong email/password
- `AUTH_EMAIL_ALREADY_EXISTS`: Email already registered
- `VALIDATION_ERROR`: Invalid input data
- `NOT_FOUND`: Resource not found
- `FORBIDDEN`: Insufficient permissions
- `INTERNAL_SERVER_ERROR`: Server error

### HTTP Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation error)
- `401`: Unauthorized (auth required or invalid token)
- `403`: Forbidden (insufficient permissions)
- `404`: Not Found
- `409`: Conflict (duplicate resource)
- `500`: Internal Server Error

---

## 9. AUTHENTICATION IMPLEMENTATION

### Dart/Flutter Example
```dart
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiClient {
  final String baseUrl = 'http://localhost:3000/api/v1';
  final storage = FlutterSecureStorage();
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Store tokens securely
      await storage.write(
        key: 'accessToken',
        value: data['data']['tokens']['accessToken'],
      );
      await storage.write(
        key: 'refreshToken',
        value: data['data']['tokens']['refreshToken'],
      );
      
      return data['data'];
    } else {
      throw Exception('Login failed');
    }
  }
  
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  Future<List<dynamic>> getDictionaryEntries() async {
    final headers = await getAuthHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/dictionary'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else if (response.statusCode == 401) {
      // Token expired, refresh it
      await refreshToken();
      return getDictionaryEntries(); // Retry
    } else {
      throw Exception('Failed to load entries');
    }
  }
  
  Future<void> refreshToken() async {
    final refreshToken = await storage.read(key: 'refreshToken');
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(
        key: 'accessToken',
        value: data['data']['accessToken'],
      );
      await storage.write(
        key: 'refreshToken',
        value: data['data']['refreshToken'],
      );
    } else {
      // Refresh failed, logout user
      await storage.deleteAll();
      // Navigate to login screen
    }
  }
}
```

---

## 10. KNOWN LIMITATIONS & NOTES

1. **OAuth Not Implemented:** Google/Facebook OAuth models exist but live integration requires credentials.

2. **AI Features Deferred:** Sign recognition (S09-S14) and speech-to-text (S15-S19) require AI/ML integration.

3. **Media Upload:** Backend expects videoUrl/thumbnailUrl strings. File upload endpoints not implemented - use external CDN or add file upload separately.

4. **Rate Limiting:** Not implemented - add before production.

5. **Email Verification:** Registration doesn't send verification emails in development.

6. **CORS:** Configured for localhost. Update for production domains.

7. **HTTPS:** Local development uses HTTP. Use HTTPS in production.

8. **Guest Data Migration:** Guest accounts can be converted to permanent accounts. Their favorites/history are preserved.

9. **History Auto-Recording:** Viewing a dictionary entry automatically records it in history if user is authenticated.

10. **Conversation Model:** Exists but AI chat not implemented. Reserved for future AI integration.

---

## 11. TEST ACCOUNTS

Use registration endpoint to create test accounts. Default role is USER.

For STAFF/ADMIN testing, manually update role in MongoDB:
```javascript
db.users.updateOne(
  { email: "admin@test.com" },
  { $set: { role: "ADMIN" } }
)
```

---

## 12. SUPPORT & NEXT STEPS

**Backend Status:** ✅ READY FOR INTEGRATION

**Frontend Tasks:**
1. Implement API client with token management
2. Integrate authentication flow (S05-S07)
3. Integrate dictionary browsing (S20, S22, S23)
4. Integrate favorites (S24)
5. Integrate history (S21)
6. Integrate profile & settings (S25-S31)
7. Test on Android and Web
8. Plan AI feature integration for Batch 02

**Questions:** Refer to backend team or check source code in `backend/src/`
