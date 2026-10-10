# SignVoice Feature Matrix
**Feature Classification and Implementation Status**

**Date:** 2026-10-09  
**Phase:** P0 Audit / P1 Architecture

---

## FEATURE CLASSIFICATION LEGEND

| Status | Description |
|--------|-------------|
| ✅ **COMPLETE** | Fully implemented with working logic |
| 🎭 **MOCK** | UI complete, backend logic needed |
| 🤖 **AI_DEFERRED** | AI/ML integration required (future batch) |
| ⚠️ **PARTIAL** | Partially implemented, needs completion |
| ❌ **MISSING** | Not yet implemented |
| 🔒 **BLOCKED** | Blocked by dependencies |

---

## 1. AUTHENTICATION & AUTHORIZATION

### 1.1 User Registration
- **Status:** 🎭 MOCK
- **Flutter Screens:** S06 (Đăng ký)
- **Current State:**
  - ✅ UI form with validation
  - ✅ Client-side validation (email format, password strength)
  - ✅ Terms acceptance checkbox
  - ❌ Backend user creation
  - ❌ Email uniqueness check
  - ❌ Password hashing
- **Backend Required:**
  - `POST /api/v1/auth/register`
  - MongoDB users collection
  - Password hashing (argon2/bcrypt)
  - Email normalization
  - Duplicate prevention
- **Dependencies:** Database setup, auth service
- **Priority:** P0 (Critical)
- **Batch:** 01

### 1.2 User Login
- **Status:** 🎭 MOCK
- **Flutter Screens:** S05 (Đăng nhập)
- **Current State:**
  - ✅ UI form with validation
  - ✅ Show/hide password
  - ✅ "Quên mật khẩu" link
  - ✅ "Tạo tài khoản" link
  - ❌ Real authentication
  - ❌ JWT token generation
  - ❌ Session management
- **Backend Required:**
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/refresh`
  - JWT access + refresh tokens
  - Session storage
  - Password verification
- **Dependencies:** User registration, JWT service
- **Priority:** P0 (Critical)
- **Batch:** 01

### 1.3 OAuth2 Social Login
- **Status:** ❌ MISSING
- **Flutter Screens:** S05 (buttons present)
- **Providers Required:**
  - Google OAuth2
  - Facebook OAuth2
- **Current State:**
  - ✅ UI buttons present
  - ❌ OAuth flow
  - ❌ Provider integration
  - ❌ Account linking
- **Backend Required:**
  - `POST /api/v1/auth/oauth/google`
  - `POST /api/v1/auth/oauth/facebook`
  - OAuth2 token verification
  - User creation/linking
  - Provider-specific user data mapping
- **Dependencies:** Auth service, OAuth client setup
- **Priority:** P0 (Critical)
- **Batch:** 01

### 1.4 Guest Mode
- **Status:** 🎭 MOCK
- **Flutter Screens:** S05 ("Dùng thử không cần đăng nhập")
- **Current State:**
  - ✅ UI button present
  - ✅ Guest flag in app state
  - ✅ Limited sync (no server)
  - ❌ Anonymous account creation
  - ❌ Guest → User conversion
  - ❌ Data migration
- **Backend Required:**
  - `POST /api/v1/auth/guest`
  - `POST /api/v1/auth/convert-guest`
  - Anonymous user accounts
  - Data ownership transfer
  - Merge logic
- **Dependencies:** Auth service
- **Priority:** P0 (Critical)
- **Batch:** 01

### 1.5 Password Recovery
- **Status:** 🎭 MOCK
- **Flutter Screens:** S07 (Quên mật khẩu)
- **Current State:**
  - ✅ UI form
  - ✅ Email validation
  - ✅ Success message
  - ❌ Real email sending
  - ❌ Reset token generation
  - ❌ Token verification
- **Backend Required:**
  - `POST /api/v1/auth/forgot-password`
  - `POST /api/v1/auth/reset-password`
  - Reset token generation/storage
  - Email service integration (development: mail catcher)
  - Token expiration (15-30 min)
- **Dependencies:** Auth service, email service
- **Priority:** P0 (Critical)
- **Batch:** 01

### 1.6 Password Change
- **Status:** ❌ MISSING
- **Flutter Screens:** None (needs to be added)
- **Backend Required:**
  - `POST /api/v1/auth/change-password`
  - Current password verification
  - New password validation
  - Session revocation (optional)
- **Dependencies:** Auth middleware
- **Priority:** P1 (High)
- **Batch:** 01

### 1.7 Logout
- **Status:** 🎭 MOCK
- **Flutter Screens:** S25 (Profile → Đăng xuất)
- **Current State:**
  - ✅ UI confirmation dialog
  - ✅ Local state clear
  - ❌ Token revocation
  - ❌ Session invalidation
- **Backend Required:**
  - `POST /api/v1/auth/logout`
  - Refresh token revocation
  - Session cleanup
- **Dependencies:** Auth service
- **Priority:** P0 (Critical)
- **Batch:** 01

### 1.8 Session Management
- **Status:** ❌ MISSING
- **Backend Required:**
  - JWT access tokens (15 min expiry)
  - Refresh tokens (7 days expiry)
  - Token rotation on refresh
  - Multi-device sessions
  - Session revocation
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

### 1.9 Role-Based Access Control (RBAC)
- **Status:** ❌ MISSING
- **Roles Required:**
  - **USER:** Regular user (default)
  - **STAFF:** Content contributor
  - **ADMIN:** System administrator
- **Backend Required:**
  - Role field in user model
  - Authorization middleware
  - Role-based route protection
  - Role assignment rules
- **Dependencies:** User model, auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

---

## 2. USER MANAGEMENT

### 2.1 User Profile
- **Status:** 🎭 MOCK
- **Flutter Screens:** S25 (Cá nhân), S26 (Chỉnh sửa hồ sơ)
- **Current State:**
  - ✅ Profile display (name, email, avatar)
  - ✅ Edit form (name, email, avatar color)
  - ✅ Client validation
  - ❌ Profile persistence
  - ❌ Profile update API
- **Backend Required:**
  - `GET /api/v1/auth/me`
  - `PUT /api/v1/users/profile`
  - Profile validation
  - Email change verification (optional)
- **Data Fields:**
  - Display name
  - Email
  - Avatar color (index 0-4)
  - Avatar URL (optional, future)
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

### 2.2 User Settings
- **Status:** 🎭 MOCK
- **Flutter Screens:** S27 (Voice), S28 (Appearance)
- **Settings Categories:**
  1. **Voice Settings (S27)**
     - Speech speed (0.5x - 2.0x)
     - Speech pitch (0.5x - 2.0x)
     - Auto-speak toggle
  2. **Appearance Settings (S28)**
     - Theme mode (light/dark/system)
     - Font scale (0.8x - 1.5x)
     - High contrast toggle
- **Current State:**
  - ✅ UI controls
  - ✅ Real-time preview
  - ✅ Local persistence (memory only)
  - ❌ Server persistence
  - ❌ Cross-device sync
- **Backend Required:**
  - `GET /api/v1/users/settings`
  - `PUT /api/v1/users/settings`
  - Settings validation (range checks)
  - Default values
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

### 2.3 Account Deletion
- **Status:** 🎭 MOCK
- **Flutter Screens:** S30 (Quyền riêng tư → Xóa tài khoản)
- **Current State:**
  - ✅ UI confirmation dialog
  - ❌ Real account deletion
  - ❌ Data cleanup
  - ❌ GDPR compliance
- **Backend Required:**
  - `DELETE /api/v1/users/account`
  - Cascade delete (history, favorites)
  - Soft delete vs hard delete
  - Audit trail
- **Dependencies:** Auth middleware, cascade logic
- **Priority:** P1 (High)
- **Batch:** 01

### 2.4 Data Export (GDPR)
- **Status:** ❌ MISSING
- **Flutter Screens:** S30 (Quyền riêng tư → Tải dữ liệu)
- **Backend Required:**
  - `GET /api/v1/users/data/export`
  - JSON export of user data
  - Include: profile, history, favorites, settings
  - Exclude: passwords, tokens
- **Dependencies:** Auth middleware
- **Priority:** P1 (High)
- **Batch:** 01

---

## 3. DICTIONARY SYSTEM

### 3.1 Dictionary Browse (Public)
- **Status:** 🎭 MOCK
- **Flutter Screens:** S22 (Từ điển ký hiệu)
- **Current State:**
  - ✅ UI grid/list view
  - ✅ Search functionality (client-side)
  - ✅ Category filter (client-side)
  - ✅ Favorite toggle
  - ❌ Server-side data
  - ❌ Pagination
  - ❌ Real search
- **Current Data:** 10 hardcoded entries
- **Backend Required:**
  - `GET /api/v1/dictionary`
  - Query parameters:
    - `?search=` (text search)
    - `?category=` (filter by category)
    - `?page=` (pagination)
    - `?limit=` (page size)
  - Only return PUBLISHED entries for public
  - Sort by name/created date
- **Dependencies:** Dictionary model, categories
- **Priority:** P0 (Critical)
- **Batch:** 01

### 3.2 Dictionary Detail (Public)
- **Status:** 🎭 MOCK
- **Flutter Screens:** S23 (Chi tiết ký hiệu)
- **Current State:**
  - ✅ UI display (name, category, meaning, example)
  - ✅ Instructions (only for "Xin chào")
  - ✅ Media placeholder
  - ❌ Server data
  - ❌ Media loading
- **Backend Required:**
  - `GET /api/v1/dictionary/:id`
  - Return full entry details
  - Include media URLs (if available)
  - Related entries (optional)
- **Dependencies:** Dictionary model
- **Priority:** P0 (Critical)
- **Batch:** 01

### 3.3 Dictionary Entries (Staff)
- **Status:** ❌ MISSING
- **Flutter Screens:** Not in current app (needs admin panel)
- **Required Features:**
  - Create draft entry
  - Edit own draft
  - Submit for review
  - View submission status
  - View rejection reason
  - Resubmit after rejection
- **Backend Required:**
  - `POST /api/v1/dictionary` (create draft)
  - `GET /api/v1/dictionary/drafts` (list own drafts)
  - `PUT /api/v1/dictionary/:id` (edit draft)
  - `POST /api/v1/dictionary/:id/submit` (submit for review)
- **Entry Statuses:**
  - DRAFT (editable by creator)
  - PENDING_REVIEW (submitted, locked)
  - PUBLISHED (approved, public)
  - REJECTED (rejected, editable)
  - ARCHIVED (soft deleted)
- **Dependencies:** RBAC (STAFF role), moderation system
- **Priority:** P1 (High)
- **Batch:** 01

### 3.4 Dictionary Moderation (Admin)
- **Status:** ❌ MISSING
- **Flutter Screens:** Not in current app (needs admin panel)
- **Required Features:**
  - View pending submissions
  - Review entry details
  - Approve entry (publish)
  - Reject entry (with reason)
  - View submission history
- **Backend Required:**
  - `GET /api/v1/admin/dictionary/pending`
  - `GET /api/v1/admin/dictionary/:id`
  - `POST /api/v1/admin/dictionary/:id/approve`
  - `POST /api/v1/admin/dictionary/:id/reject` (with reason)
  - Atomic status transitions
  - Audit logging
- **Dependencies:** RBAC (ADMIN role), dictionary model
- **Priority:** P1 (High)
- **Batch:** 01

### 3.5 Dictionary Data Seed
- **Status:** ❌ MISSING
- **Required:**
  - Seed script for 10 initial entries
  - Categories: Chào hỏi, Ăn uống, Sức khỏe, Cảm xúc, Khẩn cấp
  - Entries from Flutter source:
    - Xin chào (with instructions)
    - Cảm ơn
    - Xin lỗi
    - Giúp đỡ
    - Ăn
    - Uống
    - Đau
    - Tạm biệt
    - Vui
    - Buồn
- **Backend Required:**
  - Database seed script
  - Idempotent (can run multiple times)
  - All seeded entries: PUBLISHED status
- **Dependencies:** Dictionary model, categories
- **Priority:** P0 (Critical)
- **Batch:** 01

---

## 4. CATEGORIES SYSTEM

### 4.1 Category List (Public)
- **Status:** 🎭 MOCK
- **Flutter Screens:** S22 (filter dropdown)
- **Current State:**
  - ✅ UI dropdown
  - ✅ Hardcoded categories
  - ❌ Server data
- **Current Categories:**
  - Tất cả (All)
  - Chào hỏi (Greetings)
  - Ăn uống (Food & Drink)
  - Sức khỏe (Health)
  - Cảm xúc (Emotions)
  - Khẩn cấp (Emergency)
- **Backend Required:**
  - `GET /api/v1/categories`
  - Return active categories only
  - Sort by sortOrder field
- **Dependencies:** Category model
- **Priority:** P0 (Critical)
- **Batch:** 01

### 4.2 Category Management (Admin)
- **Status:** ❌ MISSING
- **Flutter Screens:** Not in current app
- **Required Features:**
  - Create category
  - Edit category (name, description, order)
  - Activate/deactivate category
  - View dictionary count per category
- **Backend Required:**
  - `POST /api/v1/admin/categories`
  - `PUT /api/v1/admin/categories/:id`
  - `DELETE /api/v1/admin/categories/:id` (soft delete)
  - Prevent delete if entries exist
- **Dependencies:** RBAC (ADMIN role)
- **Priority:** P1 (High)
- **Batch:** 01

---

## 5. FAVORITES SYSTEM

### 5.1 Add Favorite
- **Status:** 🎭 MOCK
- **Flutter Screens:** S22 (heart icon), S23 (detail)
- **Current State:**
  - ✅ UI toggle icon
  - ✅ Local state update
  - ❌ Server persistence
- **Backend Required:**
  - `POST /api/v1/favorites`
  - Body: `{ entryId: "..." }`
  - Prevent duplicates (unique constraint)
  - Return 201 Created or 409 Conflict
- **Dependencies:** Auth middleware, dictionary model
- **Priority:** P0 (Critical)
- **Batch:** 01

### 5.2 Remove Favorite
- **Status:** 🎭 MOCK
- **Flutter Screens:** S22, S23, S24
- **Current State:**
  - ✅ UI toggle icon
  - ✅ Local state update
  - ❌ Server persistence
- **Backend Required:**
  - `DELETE /api/v1/favorites/:entryId`
  - Return 204 No Content
  - Idempotent (no error if not found)
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

### 5.3 List Favorites
- **Status:** 🎭 MOCK
- **Flutter Screens:** S24 (Yêu thích)
- **Current State:**
  - ✅ UI list (filtered dictionary)
  - ✅ Search within favorites
  - ✅ Empty state
  - ❌ Server data
- **Current Data:** 2 favorites ("Xin chào", "Cảm ơn")
- **Backend Required:**
  - `GET /api/v1/favorites`
  - Return array of full dictionary entries
  - Support pagination
  - Join favorites + dictionary collections
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

---

## 6. CONVERSATION HISTORY

### 6.1 Save Conversation
- **Status:** 🎭 MOCK
- **Flutter Screens:** S13 (Save sign→speech), S18 (Save speech→text)
- **Current State:**
  - ✅ UI save button
  - ✅ Local state update
  - ✅ Timestamp generation
  - ❌ Server persistence
- **Backend Required:**
  - `POST /api/v1/history`
  - Body:
    ```json
    {
      "content": "Text content",
      "direction": "signToSpeech" | "speechToText"
    }
    ```
  - Auto-set: userId, createdAt, favorite=false
  - Return created conversation
- **Dependencies:** Auth middleware, history model
- **Priority:** P0 (Critical)
- **Batch:** 01

### 6.2 List History
- **Status:** 🎭 MOCK
- **Flutter Screens:** S20 (Lịch sử hội thoại)
- **Current State:**
  - ✅ UI list view
  - ✅ Search (client-side)
  - ✅ Filter by direction
  - ✅ Filter by favorite
  - ✅ Empty state
  - ❌ Server data
  - ❌ Pagination
- **Current Data:** 3 demo conversations
- **Backend Required:**
  - `GET /api/v1/history`
  - Query parameters:
    - `?search=` (text search in content)
    - `?direction=` (signToSpeech | speechToText)
    - `?favorite=` (true | false)
    - `?page=`
    - `?limit=`
  - Sort by createdAt DESC (newest first)
  - Return only user's own history
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

### 6.3 History Detail
- **Status:** 🎭 MOCK
- **Flutter Screens:** S21 (Chi tiết lịch sử)
- **Current State:**
  - ✅ UI display (content, direction, timestamp)
  - ✅ Copy button
  - ✅ Share button
  - ❌ Server data
- **Backend Required:**
  - `GET /api/v1/history/:id`
  - Return conversation details
  - Verify ownership (userId match)
  - Return 404 if not found or not owned
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

### 6.4 Toggle Favorite
- **Status:** 🎭 MOCK
- **Flutter Screens:** S20 (list), S21 (detail)
- **Current State:**
  - ✅ UI toggle icon
  - ✅ Local state update
  - ❌ Server persistence
- **Backend Required:**
  - `PUT /api/v1/history/:id/favorite`
  - Body: `{ favorite: true | false }`
  - Verify ownership
  - Return updated conversation
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

### 6.5 Delete Conversation
- **Status:** 🎭 MOCK
- **Flutter Screens:** S20 (long press), S21 (delete button)
- **Current State:**
  - ✅ UI confirmation dialog
  - ✅ Local state removal
  - ❌ Server deletion
- **Backend Required:**
  - `DELETE /api/v1/history/:id`
  - Verify ownership
  - Return 204 No Content
  - Permanent deletion (no soft delete for user privacy)
- **Dependencies:** Auth middleware
- **Priority:** P0 (Critical)
- **Batch:** 01

### 6.6 Clear All History
- **Status:** 🎭 MOCK
- **Flutter Screens:** S30 (Quyền riêng tư → Xóa lịch sử)
- **Current State:**
  - ✅ UI confirmation dialog
  - ✅ Local state clear
  - ❌ Server bulk deletion
- **Backend Required:**
  - `DELETE /api/v1/history` (bulk delete)
  - Delete all user's history
  - Return count of deleted items
- **Dependencies:** Auth middleware
- **Priority:** P1 (High)
- **Batch:** 01

---

## 7. SYNCHRONIZATION

### 7.1 Manual Sync
- **Status:** 🎭 MOCK
- **Flutter Screens:** S29 (Đồng bộ dữ liệu)
- **Current State:**
  - ✅ UI sync button
  - ✅ Fake sync animation (1.1s)
  - ✅ Last sync timestamp display
  - ❌ Real sync logic
  - ❌ Conflict resolution
- **Backend Required:**
  - `POST /api/v1/sync`
  - Bidirectional sync:
    - Push local changes to server
    - Pull server changes to client
  - Conflict resolution strategy:
    - Server wins (for settings)
    - Merge (for history/favorites)
    - Last-write-wins with timestamp
  - Return sync summary (items synced)
- **Dependencies:** All data APIs
- **Priority:** P1 (High)
- **Batch:** 01 or 02

### 7.2 Sync Status
- **Status:** 🎭 MOCK
- **Flutter Screens:** S29 (status display)
- **Current State:**
  - ✅ Online/offline indicator
  - ✅ Sync counts (mock)
  - ❌ Real sync status
- **Backend Required:**
  - `GET /api/v1/sync/status`
  - Return:
    - Last sync timestamp
    - Pending changes count
    - Sync enabled/disabled
- **Dependencies:** Auth middleware
- **Priority:** P1 (High)
- **Batch:** 01 or 02

### 7.3 Auto Sync
- **Status:** ❌ MISSING
- **Flutter Screens:** S29 (toggle setting)
- **Client Logic:**
  - Auto sync on app start (if online)
  - Auto sync after CRUD operations
  - Background sync (if platform supports)
- **Backend:** Uses same sync endpoints
- **Priority:** P2 (Medium)
- **Batch:** 02

---

## 8. ADMIN FEATURES

### 8.1 User Management (Admin)
- **Status:** ❌ MISSING
- **Flutter Screens:** Not in current app
- **Required Features:**
  - List all users
  - Search users
  - Filter by role/status
  - View user details
  - Activate/deactivate account
  - Change user role (with rules)
- **Backend Required:**
  - `GET /api/v1/admin/users`
  - `GET /api/v1/admin/users/:id`
  - `PUT /api/v1/admin/users/:id/status`
  - `PUT /api/v1/admin/users/:id/role`
  - Rules:
    - Cannot disable last ADMIN
    - STAFF cannot become ADMIN (need super admin)
    - Log all admin actions
- **Dependencies:** RBAC (ADMIN role), audit logging
- **Priority:** P1 (High)
- **Batch:** 01

### 8.2 Dashboard Statistics
- **Status:** ❌ MISSING
- **Flutter Screens:** Not in current app
- **Required Metrics:**
  - Total users (by role)
  - Active users (last 30 days)
  - Total dictionary entries (by status)
  - Pending reviews count
  - Total conversations
  - Total favorites
- **Backend Required:**
  - `GET /api/v1/admin/dashboard`
  - Real-time MongoDB aggregations
  - No hardcoded/fake numbers
- **Dependencies:** RBAC (ADMIN role)
- **Priority:** P1 (High)
- **Batch:** 01

### 8.3 Audit Logs
- **Status:** ❌ MISSING
- **Required Events:**
  - User registration
  - Login/logout
  - Role changes
  - Account status changes
  - Dictionary approval/rejection
  - Category management
  - Account deletion
- **Backend Required:**
  - `GET /api/v1/admin/audit-logs`
  - Query parameters: date range, actor, action type
  - Pagination
  - Do NOT log sensitive data (passwords, tokens)
- **Dependencies:** RBAC (ADMIN role), audit service
- **Priority:** P1 (High)
- **Batch:** 01

---

## 9. AI-DEPENDENT FEATURES (DEFERRED)

### 9.1 Sign Language Recognition
- **Status:** 🤖 AI_DEFERRED
- **Flutter Screens:** S09-S14
- **Current State:**
  - ✅ UI complete (camera, results, sentence builder)
  - ✅ Mock recognition results
  - ❌ Camera frame capture
  - ❌ AI model integration
  - ❌ Real-time inference
- **Backend Required (Future):**
  - `POST /api/v1/recognition/analyze`
  - Body: video frames or video URL
  - Return: detected sign ID + confidence
  - Model: Sign language classification CNN
- **Dependencies:** AI model training, video processing
- **Priority:** P2 (Future batch)
- **Batch:** AI Integration Batch (03+)

### 9.2 Speech-to-Text
- **Status:** 🤖 AI_DEFERRED
- **Flutter Screens:** S15-S19
- **Current State:**
  - ✅ UI complete (mic, listening, transcript)
  - ✅ Mock transcription
  - ❌ Real microphone capture
  - ❌ Speech recognition
- **Backend Required (Future):**
  - `POST /api/v1/speech/transcribe`
  - Body: audio stream or audio file
  - Return: transcript text
  - Integration: Google Speech-to-Text API or equivalent
- **Dependencies:** Speech recognition service
- **Priority:** P2 (Future batch)
- **Batch:** AI Integration Batch (03+)

### 9.3 Text-to-Speech
- **Status:** 🤖 AI_DEFERRED
- **Flutter Screens:** S14, S27 (demo button)
- **Current State:**
  - ✅ UI complete (waveform, controls)
  - ✅ Mock playback animation
  - ❌ Real audio generation
  - ❌ Voice settings integration
- **Backend Required (Future):**
  - `POST /api/v1/tts/synthesize`
  - Body: text, speed, pitch
  - Return: audio file URL or stream
  - Integration: Google TTS API or equivalent
- **Dependencies:** TTS service
- **Priority:** P2 (Future batch)
- **Batch:** AI Integration Batch (03+)

---

## 10. MEDIA MANAGEMENT

### 10.1 Dictionary Media
- **Status:** ⚠️ PARTIAL
- **Current State:**
  - ✅ UI placeholders
  - ❌ Media upload
  - ❌ Media storage
  - ❌ Media retrieval
- **Media Types:**
  - Images (sign demonstrations)
  - Videos (sign tutorials)
  - Thumbnails (generated)
- **Backend Required:**
  - `POST /api/v1/media/upload` (STAFF/ADMIN only)
  - `GET /api/v1/media/:id`
  - Local file storage (development)
  - S3/cloud storage (production - future)
  - File validation (type, size, content)
  - Thumbnail generation
- **Dependencies:** RBAC, file upload middleware
- **Priority:** P2 (Medium)
- **Batch:** 01 (basic) or 02 (full)

### 10.2 User Avatars
- **Status:** ⚠️ PARTIAL
- **Current State:**
  - ✅ Avatar color selection
  - ✅ Initials display
  - ❌ Custom avatar upload
- **Backend Required:**
  - `POST /api/v1/users/avatar`
  - `DELETE /api/v1/users/avatar`
  - Avatar storage
  - Image validation
  - Resize/crop
- **Dependencies:** Media service
- **Priority:** P3 (Low)
- **Batch:** 02 or later

---

## FEATURE PRIORITY SUMMARY

### P0 - Critical (Batch 01 Must-Have)
- ✅ Authentication (register, login, OAuth, guest, logout)
- ✅ User profile & settings
- ✅ Dictionary (public read, seed data)
- ✅ Categories (public read)
- ✅ Favorites (CRUD)
- ✅ History (CRUD)
- ✅ RBAC (USER/STAFF/ADMIN)
- ✅ Staff dictionary management
- ✅ Admin moderation
- ✅ Admin user management
- ✅ Dashboard statistics
- ✅ Audit logging

### P1 - High (Batch 01 Nice-to-Have)
- Password change
- Account deletion
- Data export (GDPR)
- Sync service
- Category management (admin)
- Clear all data

### P2 - Medium (Batch 02+)
- AI features (sign recognition, speech-to-text, TTS)
- Media management (full)
- Auto sync
- Advanced search
- Analytics

### P3 - Low (Future)
- Custom avatars
- Multi-language support
- Notifications
- Social features
- Accessibility enhancements

---

## BACKEND API ENDPOINT SUMMARY

### Total Endpoints Required (Batch 01): **~45 endpoints**

**Authentication (10):**
- POST /auth/register
- POST /auth/login
- POST /auth/logout
- POST /auth/refresh
- POST /auth/guest
- POST /auth/convert-guest
- POST /auth/oauth/google
- POST /auth/oauth/facebook
- POST /auth/forgot-password
- POST /auth/reset-password
- POST /auth/change-password

**User Management (7):**
- GET /auth/me
- PUT /users/profile
- GET /users/settings
- PUT /users/settings
- DELETE /users/account
- GET /users/data/export
- DELETE /users/data/local

**Dictionary (6):**
- GET /dictionary (public)
- GET /dictionary/:id (public)
- POST /dictionary (STAFF - create draft)
- PUT /dictionary/:id (STAFF - edit draft)
- POST /dictionary/:id/submit (STAFF - submit for review)
- GET /dictionary/drafts (STAFF - list own drafts)

**Categories (4):**
- GET /categories (public)
- POST /admin/categories (ADMIN)
- PUT /admin/categories/:id (ADMIN)
- DELETE /admin/categories/:id (ADMIN)

**Favorites (3):**
- GET /favorites
- POST /favorites
- DELETE /favorites/:entryId

**History (6):**
- GET /history
- GET /history/:id
- POST /history
- PUT /history/:id/favorite
- DELETE /history/:id
- DELETE /history (bulk)

**Admin (9):**
- GET /admin/users
- GET /admin/users/:id
- PUT /admin/users/:id/status
- PUT /admin/users/:id/role
- GET /admin/dictionary/pending
- POST /admin/dictionary/:id/approve
- POST /admin/dictionary/:id/reject
- GET /admin/dashboard
- GET /admin/audit-logs

**Sync (2):**
- POST /sync
- GET /sync/status

**AI (DEFERRED):**
- POST /recognition/analyze
- POST /speech/transcribe
- POST /tts/synthesize

---

**FEATURE MATRIX COMPLETE**  
**Next:** Create BASELINE_TESTS.md and RISKS.md, then proceed to architecture documents
