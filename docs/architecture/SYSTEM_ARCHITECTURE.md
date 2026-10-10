# SignVoice System Architecture
**Backend Implementation - Node.js + Express + TypeScript + MongoDB**

**Version:** 1.0  
**Date:** 2026-10-09  
**Status:** Design Phase  
**Batch:** 01 - Backend Foundation

---

## 1. SYSTEM OVERVIEW

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
├──────────────────────┬──────────────────────────────────────────┤
│   Flutter Web App    │      Flutter Mobile App                  │
│   (Browser)          │      (Android/iOS)                       │
│                      │                                          │
│   - Chrome/Edge      │      - Native camera/mic                │
│   - Desktop frame    │      - Secure storage                   │
│   - CORS enabled     │      - System permissions               │
└──────────┬───────────┴────────────────┬─────────────────────────┘
           │                            │
           │  REST API (HTTPS)          │  REST API (HTTPS)
           │  JSON                      │  JSON
           │                            │
┌──────────▼────────────────────────────▼─────────────────────────┐
│                         API GATEWAY                              │
│                    Express.js Server                             │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Middleware Chain                                          │ │
│  │  • CORS                                                    │ │
│  │  • JSON Body Parser                                       │ │
│  │  • Cookie Parser                                          │ │
│  │  • Request ID                                             │ │
│  │  • Request Logging                                        │ │
│  │  • Helmet (Security Headers)                              │ │
│  │  • Auth Middleware (JWT Verification)                     │ │
│  │  • RBAC Middleware (Role Verification)                    │ │
│  │  • Error Handler                                          │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────┬───────────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           │               │               │
┌──────────▼────┐ ┌────────▼──────┐ ┌────▼──────────┐
│  Auth Module  │ │  User Module  │ │  Dict Module  │
│               │ │               │ │               │
│ • Register    │ │ • Profile     │ │ • Browse      │
│ • Login       │ │ • Settings    │ │ • Detail      │
│ • OAuth       │ │ • Data Export │ │ • CRUD        │
│ • Guest       │ │ • Delete      │ │ • Moderation  │
│ • Refresh     │ │               │ │               │
│ • Logout      │ └───────────────┘ └───────────────┘
└───────────────┘
           │
┌──────────▼──────┬────────────────┬──────────────────┐
│  Fav Module     │  History Mod   │  Admin Module    │
│                 │                │                  │
│ • Add/Remove    │ • CRUD         │ • User Mgmt      │
│ • List          │ • Search       │ • Moderation     │
│                 │ • Filter       │ • Dashboard      │
│                 │                │ • Audit Logs     │
└─────────────────┴────────────────┴──────────────────┘
           │
           │ Mongoose ODM
           │
┌──────────▼───────────────────────────────────────────┐
│                    DATA LAYER                        │
│                 MongoDB Database                     │
│                                                      │
│  ┌──────────┐  ┌────────────┐  ┌─────────────────┐ │
│  │  users   │  │  auth_     │  │  dictionary_    │ │
│  │          │  │  sessions  │  │  entries        │ │
│  └──────────┘  └────────────┘  └─────────────────┘ │
│                                                      │
│  ┌──────────┐  ┌────────────┐  ┌─────────────────┐ │
│  │  user_   │  │  convers-  │  │  categories     │ │
│  │  settings│  │  ations    │  │                 │ │
│  └──────────┘  └────────────┘  └─────────────────┘ │
│                                                      │
│  ┌──────────┐  ┌────────────┐                      │
│  │favorites │  │  audit_    │                      │
│  │          │  │  logs      │                      │
│  └──────────┘  └────────────┘                      │
└──────────────────────────────────────────────────────┘
```

### 1.2 Technology Stack

**Backend Framework:**
- **Runtime:** Node.js 20.x LTS (or 24.x if stable and compatible)
- **Framework:** Express.js 4.x
- **Language:** TypeScript 5.x (strict mode)
- **Build:** tsc (TypeScript compiler)

**Database:**
- **DBMS:** MongoDB 6.x or 7.x
- **ODM:** Mongoose 8.x
- **Local Dev:** Docker Compose
- **Production:** MongoDB Atlas (future)

**Authentication:**
- **Strategy:** JWT (JSON Web Tokens)
- **Access Token:** 15 minutes expiry
- **Refresh Token:** 7 days expiry
- **Password Hash:** argon2 (primary) or bcrypt (fallback)
- **OAuth2:** Google + Facebook

**Validation:**
- **Library:** zod (TypeScript-first schema validation)
- **Strategy:** DTO validation at controller layer

**Security:**
- **Helmet:** Security headers
- **CORS:** Cross-origin resource sharing
- **Rate Limit:** express-rate-limit (auth endpoints)

**Testing:**
- **Framework:** Vitest (or Jest)
- **Integration:** Supertest
- **Coverage:** Minimum 70%

**Development:**
- **Hot Reload:** nodemon or tsx
- **Linting:** ESLint + TypeScript ESLint
- **Formatting:** Prettier
- **Git Hooks:** Husky (optional)

---

## 2. MODULE ARCHITECTURE

### 2.1 Backend Directory Structure

```
backend/
├── src/
│   ├── app.ts                     # Express app configuration
│   ├── server.ts                  # HTTP server entry point
│   │
│   ├── config/
│   │   ├── env.ts                 # Environment variables
│   │   ├── database.ts            # MongoDB connection
│   │   └── constants.ts           # Application constants
│   │
│   ├── common/
│   │   ├── errors/
│   │   │   ├── AppError.ts        # Custom error class
│   │   │   └── errorCodes.ts     # Error code constants
│   │   │
│   │   ├── middlewares/
│   │   │   ├── auth.middleware.ts      # JWT verification
│   │   │   ├── rbac.middleware.ts      # Role checking
│   │   │   ├── validate.middleware.ts  # Input validation
│   │   │   ├── errorHandler.ts         # Global error handler
│   │   │   └── requestLogger.ts        # Request logging
│   │   │
│   │   ├── utils/
│   │   │   ├── jwt.utils.ts       # JWT generation/verification
│   │   │   ├── hash.utils.ts      # Password hashing
│   │   │   ├── normalize.ts       # Email normalization
│   │   │   └── pagination.ts      # Pagination helpers
│   │   │
│   │   └── types/
│   │       ├── express.d.ts       # Express type extensions
│   │       ├── auth.types.ts      # Auth-related types
│   │       └── common.types.ts    # Shared types
│   │
│   ├── modules/
│   │   │
│   │   ├── auth/
│   │   │   ├── auth.routes.ts         # Auth endpoints
│   │   │   ├── auth.controller.ts     # Request handling
│   │   │   ├── auth.service.ts        # Business logic
│   │   │   ├── auth.dto.ts            # DTOs with validation
│   │   │   ├── auth.repository.ts     # Database queries
│   │   │   └── oauth.service.ts       # OAuth integration
│   │   │
│   │   ├── users/
│   │   │   ├── users.routes.ts
│   │   │   ├── users.controller.ts
│   │   │   ├── users.service.ts
│   │   │   ├── users.dto.ts
│   │   │   ├── users.repository.ts
│   │   │   ├── user.model.ts          # Mongoose schema
│   │   │   └── userSettings.model.ts
│   │   │
│   │   ├── dictionary/
│   │   │   ├── dictionary.routes.ts
│   │   │   ├── dictionary.controller.ts
│   │   │   ├── dictionary.service.ts
│   │   │   ├── dictionary.dto.ts
│   │   │   ├── dictionary.repository.ts
│   │   │   ├── dictionaryEntry.model.ts
│   │   │   └── moderation.service.ts
│   │   │
│   │   ├── categories/
│   │   │   ├── categories.routes.ts
│   │   │   ├── categories.controller.ts
│   │   │   ├── categories.service.ts
│   │   │   ├── categories.dto.ts
│   │   │   ├── categories.repository.ts
│   │   │   └── category.model.ts
│   │   │
│   │   ├── favorites/
│   │   │   ├── favorites.routes.ts
│   │   │   ├── favorites.controller.ts
│   │   │   ├── favorites.service.ts
│   │   │   ├── favorites.dto.ts
│   │   │   ├── favorites.repository.ts
│   │   │   └── favorite.model.ts
│   │   │
│   │   ├── history/
│   │   │   ├── history.routes.ts
│   │   │   ├── history.controller.ts
│   │   │   ├── history.service.ts
│   │   │   ├── history.dto.ts
│   │   │   ├── history.repository.ts
│   │   │   └── conversation.model.ts
│   │   │
│   │   ├── admin/
│   │   │   ├── admin.routes.ts
│   │   │   ├── users.admin.controller.ts
│   │   │   ├── moderation.admin.controller.ts
│   │   │   ├── dashboard.admin.controller.ts
│   │   │   ├── admin.service.ts
│   │   │   └── auditLog.model.ts
│   │   │
│   │   └── sync/
│   │       ├── sync.routes.ts
│   │       ├── sync.controller.ts
│   │       └── sync.service.ts
│   │
│   └── routes/
│       └── index.ts                   # Route aggregator
│
├── tests/
│   ├── unit/
│   │   ├── services/
│   │   ├── utils/
│   │   └── middlewares/
│   │
│   ├── integration/
│   │   ├── auth.test.ts
│   │   ├── users.test.ts
│   │   ├── dictionary.test.ts
│   │   ├── favorites.test.ts
│   │   ├── history.test.ts
│   │   └── admin.test.ts
│   │
│   ├── setup.ts                       # Test setup
│   └── helpers.ts                     # Test utilities
│
├── scripts/
│   ├── seed.ts                        # Database seeding
│   ├── create-admin.ts                # Create admin account
│   └── cleanup.ts                     # Database cleanup
│
├── package.json
├── tsconfig.json
├── .env.example
├── .gitignore
├── docker-compose.yml                 # MongoDB setup
└── README.md
```

### 2.2 Layer Responsibilities

#### **Controller Layer**
- Receives HTTP requests
- Validates request format (basic)
- Calls service layer
- Formats HTTP responses
- Handles HTTP status codes
- **Should NOT:**
  - Contain business logic
  - Access database directly
  - Handle errors (caught by middleware)

#### **Service Layer**
- Contains business logic
- Orchestrates operations
- Validates business rules
- Calls repository layer
- Handles transactions (if needed)
- **Should NOT:**
  - Access HTTP request/response directly
  - Format HTTP responses
  - Contain database queries

#### **Repository Layer**
- Encapsulates database operations
- Constructs MongoDB queries
- Handles Mongoose models
- Returns domain objects
- **Should NOT:**
  - Contain business logic
  - Format responses
  - Validate business rules

#### **DTO Layer**
- Defines request/response shapes
- Contains validation schemas (zod)
- Type-safe data transfer
- **Used for:**
  - Request body validation
  - Query parameter validation
  - Response serialization

---

## 3. AUTHENTICATION & AUTHORIZATION

### 3.1 Authentication Flow

```
┌──────────────┐
│   Client     │
└──────┬───────┘
       │
       │ POST /api/v1/auth/register or /login
       │ Body: { email, password }
       │
┌──────▼────────┐
│  Controller   │
│  • Validate   │
└──────┬────────┘
       │
┌──────▼────────┐
│   Service     │
│  • Verify     │
│  • Hash pwd   │
│  • Create     │
└──────┬────────┘
       │
┌──────▼────────┐
│  Repository   │
│  • MongoDB    │
└──────┬────────┘
       │
┌──────▼────────────────────────┐
│   JWT Service                 │
│  • Generate access token      │
│  • Generate refresh token     │
│  • Store refresh token hash   │
└──────┬────────────────────────┘
       │
┌──────▼────────────────────────┐
│   Response                    │
│  {                            │
│    success: true,             │
│    data: {                    │
│      accessToken,             │
│      refreshToken,            │
│      user: { id, name, ... }  │
│    }                          │
│  }                            │
└───────────────────────────────┘
```

### 3.2 JWT Token Structure

**Access Token:**
```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "role": "USER" | "STAFF" | "ADMIN",
  "guest": false,
  "iat": 1696840000,
  "exp": 1696840900,
  "iss": "signvoice-api",
  "aud": "signvoice-client"
}
```

**Refresh Token:**
```json
{
  "sub": "user_id",
  "type": "refresh",
  "iat": 1696840000,
  "exp": 1697444800,
  "jti": "unique_token_id"
}
```

### 3.3 Authorization Matrix (RBAC)

| Endpoint | Public | USER | STAFF | ADMIN |
|----------|--------|------|-------|-------|
| **Auth** |
| POST /auth/register | ✅ | ✅ | ✅ | ✅ |
| POST /auth/login | ✅ | ✅ | ✅ | ✅ |
| POST /auth/logout | - | ✅ | ✅ | ✅ |
| GET /auth/me | - | ✅ | ✅ | ✅ |
| **Dictionary (Public)** |
| GET /dictionary | ✅ | ✅ | ✅ | ✅ |
| GET /dictionary/:id | ✅ | ✅ | ✅ | ✅ |
| **Dictionary (Staff)** |
| POST /dictionary | - | - | ✅ | ✅ |
| PUT /dictionary/:id | - | - | ✅(own) | ✅ |
| POST /dictionary/:id/submit | - | - | ✅(own) | ✅ |
| **Dictionary (Admin)** |
| POST /admin/dictionary/:id/approve | - | - | - | ✅ |
| POST /admin/dictionary/:id/reject | - | - | - | ✅ |
| **Favorites** |
| GET /favorites | - | ✅ | ✅ | ✅ |
| POST /favorites | - | ✅ | ✅ | ✅ |
| DELETE /favorites/:id | - | ✅(own) | ✅(own) | ✅(own) |
| **History** |
| GET /history | - | ✅ | ✅ | ✅ |
| POST /history | - | ✅ | ✅ | ✅ |
| DELETE /history/:id | - | ✅(own) | ✅(own) | ✅(own) |
| **Admin** |
| GET /admin/users | - | - | - | ✅ |
| PUT /admin/users/:id/role | - | - | - | ✅ |
| GET /admin/dashboard | - | - | - | ✅ |
| GET /admin/audit-logs | - | - | - | ✅ |

**Legend:**
- ✅ = Allowed
- ✅(own) = Allowed only for own resources
- - = Not allowed

### 3.4 Middleware Chain for Protected Routes

```typescript
// Example: Protected route with RBAC
router.post('/dictionary',
  authMiddleware,           // Step 1: Verify JWT
  requireRole('STAFF'),     // Step 2: Check role
  validate(createDictDto),  // Step 3: Validate input
  dictionaryController.create
);

// Middleware execution order:
1. authMiddleware
   - Extract Bearer token from Authorization header
   - Verify JWT signature
   - Decode payload
   - Fetch user from database (verify not disabled)
   - Attach user to req.user
   - next()

2. requireRole('STAFF')
   - Check req.user.role === 'STAFF' or 'ADMIN'
   - If not → 403 Forbidden
   - next()

3. validate(createDictDto)
   - Parse request body with zod schema
   - If invalid → 400 Bad Request
   - Attach validated data to req.validated
   - next()

4. Controller
   - Use req.user for authorization context
   - Use req.validated for safe data
   - Call service layer
```

---

## 4. DATA FLOW PATTERNS

### 4.1 Standard CRUD Flow

```
HTTP Request
    │
    ├─→ Middleware Chain
    │   ├─→ CORS
    │   ├─→ JSON Parser
    │   ├─→ Auth (if protected)
    │   └─→ Validation
    │
    ├─→ Controller
    │   ├─→ Extract params/body/query
    │   └─→ Call Service
    │
    ├─→ Service
    │   ├─→ Business logic
    │   ├─→ Authorization checks
    │   └─→ Call Repository
    │
    ├─→ Repository
    │   ├─→ Construct query
    │   ├─→ Execute MongoDB operation
    │   └─→ Return domain object
    │
    ├─→ Service
    │   └─→ Return result
    │
    ├─→ Controller
    │   └─→ Format response
    │
    └─→ HTTP Response
        {
          success: true,
          data: {...}
        }
```

### 4.2 Error Flow

```
Error Thrown Anywhere
    │
    ├─→ Express Error Handler (errorHandler middleware)
    │   ├─→ Is AppError? → Use defined status + message
    │   ├─→ Is Mongoose Error? → Transform to AppError
    │   ├─→ Is JWT Error? → 401 Unauthorized
    │   └─→ Unknown → 500 Internal Server Error
    │
    ├─→ Log Error (don't expose stack to client)
    │
    └─→ HTTP Response
        {
          success: false,
          error: {
            code: "ERROR_CODE",
            message: "Human-readable message"
          },
          requestId: "..."
        }
```

### 4.3 Authentication Token Flow

```
┌─────────────────────────────────────────────────────────┐
│  Client Login                                           │
└───────────────────┬─────────────────────────────────────┘
                    │
          POST /auth/login
                    │
┌───────────────────▼─────────────────────────────────────┐
│  Server: Verify credentials                             │
│  Generate:                                              │
│  - Access Token (15min)                                 │
│  - Refresh Token (7 days, hashed + stored in DB)       │
└───────────────────┬─────────────────────────────────────┘
                    │
          ┌─────────▼─────────┐
          │  Client stores:   │
          │  - Access Token   │
          │  - Refresh Token  │
          └─────────┬─────────┘
                    │
    ┌───────────────┴───────────────┐
    │                               │
    │  API Calls                    │  Token Refresh
    │  (Access Token)               │  (when expired)
    │                               │
┌───▼────────────────┐     ┌────────▼──────────┐
│  Protected Route   │     │  POST /auth/      │
│  Auth Middleware   │     │  refresh          │
│  Verify Access     │     │                   │
│  Token             │     │  Verify Refresh   │
└────────────────────┘     │  Generate new     │
                           │  Access Token     │
                           │  Rotate Refresh   │
                           └───────────────────┘
```

---

## 5. DATABASE DESIGN

### 5.1 MongoDB Collections

**Primary Collections:**
1. `users` - User accounts
2. `auth_sessions` - Refresh tokens
3. `user_settings` - User preferences
4. `categories` - Dictionary categories
5. `dictionary_entries` - Sign language dictionary
6. `favorites` - User favorites
7. `conversations` - User history
8. `audit_logs` - System audit trail

**Collection Relationships:**
```
users (1) ──< (N) auth_sessions
users (1) ──< (1) user_settings
users (1) ──< (N) favorites
users (1) ──< (N) conversations
users (1) ──< (N) audit_logs (as actor)

categories (1) ──< (N) dictionary_entries

dictionary_entries (1) ──< (N) favorites
```

### 5.2 Indexing Strategy

**users:**
- `normalizedEmail` (unique)
- `role` (non-unique)
- `status` (non-unique)

**dictionary_entries:**
- `status` + `categoryId` (compound)
- `normalizedTitle` (text search)
- `createdAt` (sorting)

**favorites:**
- `userId` + `entryId` (unique compound)

**conversations:**
- `userId` + `createdAt` (compound, sorting)
- `direction` (non-unique)

**audit_logs:**
- `createdAt` (TTL index, 90 days retention)

---

## 6. API DESIGN PRINCIPLES

### 6.1 REST API Structure

**Base URL:** `/api/v1`

**Endpoint Naming:**
- Use nouns (not verbs): `/users` not `/getUsers`
- Use plural for collections: `/dictionary` not `/dictionaries` (exception)
- Use nested resources: `/dictionary/:id/submit`
- Admin endpoints: `/admin/users` not `/users/admin`

**HTTP Methods:**
- GET: Retrieve resource(s)
- POST: Create resource
- PUT: Update resource (full)
- PATCH: Update resource (partial)
- DELETE: Delete resource

**Status Codes:**
- 200 OK: Success (GET, PUT, PATCH)
- 201 Created: Resource created (POST)
- 204 No Content: Success, no body (DELETE)
- 400 Bad Request: Invalid input
- 401 Unauthorized: Missing/invalid auth
- 403 Forbidden: Insufficient permissions
- 404 Not Found: Resource not found
- 409 Conflict: Duplicate resource
- 422 Unprocessable Entity: Validation failed
- 500 Internal Server Error: Server error

### 6.2 Response Format

**Success Response:**
```json
{
  "success": true,
  "data": {
    ...
  },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Email hoặc mật khẩu không đúng"
  },
  "requestId": "req_abc123"
}
```

**Pagination:**
```
GET /api/v1/dictionary?page=2&limit=20

Response meta:
{
  "page": 2,
  "limit": 20,
  "total": 150,
  "totalPages": 8
}
```

### 6.3 Error Code Convention

```typescript
// Error codes follow pattern: CONTEXT_REASON
AUTH_INVALID_CREDENTIALS
AUTH_EMAIL_ALREADY_EXISTS
AUTH_TOKEN_EXPIRED
AUTH_TOKEN_INVALID

USER_NOT_FOUND
USER_ALREADY_DISABLED

DICT_ENTRY_NOT_FOUND
DICT_NOT_PUBLISHED
DICT_ALREADY_SUBMITTED

FAVORITE_ALREADY_EXISTS
FAVORITE_NOT_FOUND

HISTORY_NOT_FOUND
HISTORY_NOT_OWNED

RBAC_INSUFFICIENT_PERMISSIONS
RBAC_FORBIDDEN_ACTION

VALIDATION_FAILED
VALIDATION_INVALID_EMAIL
VALIDATION_PASSWORD_TOO_SHORT

INTERNAL_SERVER_ERROR
DATABASE_CONNECTION_ERROR
```

---

## 7. SECURITY ARCHITECTURE

### 7.1 Security Layers

```
┌────────────────────────────────────────────────┐
│  Network Layer                                 │
│  • HTTPS (production)                          │
│  • CORS restrictions                           │
│  • Rate limiting                               │
└───────────────────┬────────────────────────────┘
                    │
┌───────────────────▼────────────────────────────┐
│  Application Layer                             │
│  • Helmet (security headers)                   │
│  • Input validation (zod)                      │
│  • Output sanitization                         │
│  • JWT verification                            │
└───────────────────┬────────────────────────────┘
                    │
┌───────────────────▼────────────────────────────┐
│  Authorization Layer                           │
│  • RBAC enforcement                            │
│  • Resource ownership check                    │
│  • Action permissions                          │
└───────────────────┬────────────────────────────┘
                    │
┌───────────────────▼────────────────────────────┐
│  Data Layer                                    │
│  • Password hashing (argon2)                   │
│  • Token hashing (refresh tokens)              │
│  • MongoDB injection prevention                │
│  • Sensitive field exclusion                   │
└────────────────────────────────────────────────┘
```

### 7.2 Security Checklist

**Authentication:**
- [x] Passwords hashed with argon2/bcrypt
- [x] JWT properly signed (HS256 or RS256)
- [x] Access tokens short-lived (15 min)
- [x] Refresh tokens rotated on use
- [x] Refresh tokens stored hashed
- [x] Logout revokes refresh tokens
- [x] No tokens in URLs or logs

**Authorization:**
- [x] RBAC enforced on server side
- [x] Never trust client-provided role
- [x] Resource ownership verified
- [x] Admin actions logged

**Input Validation:**
- [x] All user input validated
- [x] Email normalized before use
- [x] SQL/NoSQL injection prevented
- [x] XSS prevention (output escaping)
- [x] CSRF protection (SameSite cookies)

**Data Protection:**
- [x] Sensitive fields never returned (passwordHash)
- [x] MongoDB queries parameterized
- [x] Environment secrets not committed
- [x] Audit logs for sensitive actions

---

## 8. DEPLOYMENT ARCHITECTURE

### 8.1 Local Development

```
┌──────────────────────────────────────────┐
│  Developer Machine (Windows)             │
│                                          │
│  ├─ Flutter App                          │
│  │  └─ flutter run -d chrome            │
│  │                                       │
│  ├─ Backend API                          │
│  │  └─ npm run dev (port 3000)          │
│  │                                       │
│  └─ MongoDB                              │
│     └─ docker-compose up (port 27017)   │
│                                          │
│  All on localhost                        │
└──────────────────────────────────────────┘
```

### 8.2 Docker Compose Setup

```yaml
# docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:7
    container_name: signvoice_mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: signvoice
      MONGO_INITDB_ROOT_PASSWORD: dev_password
      MONGO_INITDB_DATABASE: signvoice
    volumes:
      - mongodb_data:/data/db
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/signvoice --quiet
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  mongodb_data:
    name: signvoice_mongodb_data
```

### 8.3 Environment Configuration

**.env (Development):**
```bash
NODE_ENV=development
PORT=3000

# Database
MONGODB_URI=mongodb://signvoice:dev_password@localhost:27017/signvoice?authSource=admin

# JWT
JWT_ACCESS_SECRET=generate_secure_random_secret_here
JWT_REFRESH_SECRET=generate_different_secure_secret
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# CORS
WEB_ORIGIN=http://localhost:8080
CORS_ALLOWED_ORIGINS=http://localhost:8080,http://localhost:3000

# OAuth (to be configured)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_APP_SECRET=your_facebook_app_secret

# Logging
LOG_LEVEL=debug
```

---

## 9. TESTING STRATEGY

### 9.1 Test Pyramid

```
         ┌─────────────┐
         │  E2E Tests  │  ← 10% (Manual)
         │   (Manual)  │
         └─────────────┘
            ┌───────────────┐
            │  Integration  │  ← 30%
            │     Tests     │
            └───────────────┘
               ┌─────────────────┐
               │   Unit Tests    │  ← 60%
               │                 │
               └─────────────────┘
```

### 9.2 Test Coverage Requirements

**Unit Tests (60%):**
- All services
- All utilities
- All validators
- Critical business logic

**Integration Tests (30%):**
- All API endpoints
- Auth flows
- RBAC scenarios
- Database operations
- Error handling

**E2E Tests (10%):**
- Manual testing with Flutter app
- Critical user flows
- Cross-platform verification

### 9.3 Test Environment

```typescript
// Test database: signvoice_test
// Isolated from development database
// Cleaned before each test suite

beforeAll(async () => {
  await connectTestDatabase();
});

beforeEach(async () => {
  await clearDatabase();
});

afterAll(async () => {
  await disconnectDatabase();
});
```

---

## 10. MONITORING & LOGGING

### 10.1 Logging Strategy

**Log Levels:**
- **ERROR:** Application errors, crashes
- **WARN:** Warnings, recoverable errors
- **INFO:** Important events (login, logout, moderation)
- **DEBUG:** Detailed info (development only)

**What to Log:**
- ✅ Request/response (without sensitive data)
- ✅ Authentication events
- ✅ Authorization failures
- ✅ Database errors
- ✅ Business logic errors
- ❌ Passwords, tokens (never)
- ❌ Full stack traces to client

**Log Format:**
```json
{
  "timestamp": "2026-10-09T10:30:00.000Z",
  "level": "info",
  "message": "User logged in",
  "requestId": "req_abc123",
  "userId": "user_xyz",
  "ip": "127.0.0.1",
  "userAgent": "Mozilla/5.0..."
}
```

### 10.2 Health Checks

**Liveness:** `GET /health/live`
- Returns 200 if server is running

**Readiness:** `GET /health/ready`
- Returns 200 if server + MongoDB ready
- Returns 503 if MongoDB disconnected

---

## 11. SCALABILITY CONSIDERATIONS

### 11.1 Current Architecture (Batch 01)
- **Monolithic:** Single Node.js process
- **Database:** Single MongoDB instance
- **Session:** Stateless JWT (scales horizontally)

### 11.2 Future Scaling (Post-Batch 01)
- **Horizontal:** Multiple Node.js instances behind load balancer
- **Database:** MongoDB replica set
- **Caching:** Redis for frequently accessed data
- **CDN:** For static media files
- **Queue:** Bull/BullMQ for async jobs (AI processing)

---

**SYSTEM ARCHITECTURE COMPLETE**  
**Status:** ✅ Design finalized  
**Next:** MongoDB Schema detailed design, API Contract (OpenAPI), Technical Decisions
