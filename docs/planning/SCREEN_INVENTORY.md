# SignVoice Screen Inventory
**Complete Catalog of All Application Screens**

**Date:** 2026-10-09  
**Total Screens:** 37 + 1 Catalog = 38  
**Source:** `lib/core/navigation.dart` + `lib/app.dart`

---

## SCREEN DIRECTORY

| ID | Name | File | Feature | Type | Status | API Needed |
|----|------|------|---------|------|--------|------------|
| S01 | Splash | auth_screens.dart | Auth | Public | ✅ Complete | None |
| S02 | Onboarding 1 | auth_screens.dart | Auth | Public | ✅ Complete | None |
| S03 | Onboarding 2 | auth_screens.dart | Auth | Public | ✅ Complete | None |
| S04 | Onboarding 3 | auth_screens.dart | Auth | Public | ✅ Complete | None |
| S05 | Đăng nhập | auth_screens.dart | Auth | Public | 🎭 Mock | POST /auth/login |
| S06 | Đăng ký | auth_screens.dart | Auth | Public | 🎭 Mock | POST /auth/register |
| S07 | Quên mật khẩu | auth_screens.dart | Auth | Public | 🎭 Mock | POST /auth/forgot-password |
| S08 | Trang chủ | home_screen.dart | Home | Private | ✅ Complete | GET /auth/me |
| S09 | Cấp quyền Camera | recognition_screens.dart | Recognition | Private | ✅ Complete | None |
| S10 | Camera sẵn sàng | recognition_screens.dart | Recognition | Private | 🎭 Mock (AI) | POST /recognition/analyze |
| S11 | Nhận diện thành công | recognition_screens.dart | Recognition | Private | 🎭 Mock (AI) | GET /dictionary/:id |
| S12 | Nhận diện thất bại | recognition_screens.dart | Recognition | Private | 🎭 Mock (AI) | N/A |
| S13 | Tạo câu | recognition_screens.dart | Recognition | Private | ✅ Complete | POST /history |
| S14 | Phát giọng nói | recognition_screens.dart | Recognition | Private | 🎭 Mock (TTS) | N/A |
| S15 | Cấp quyền Micro | speech_screens.dart | Speech | Private | ✅ Complete | None |
| S16 | Microphone sẵn sàng | speech_screens.dart | Speech | Private | 🎭 Mock (AI) | POST /speech/transcribe |
| S17 | Đang lắng nghe | speech_screens.dart | Speech | Private | 🎭 Mock (AI) | POST /speech/transcribe |
| S18 | Kết quả văn bản | speech_screens.dart | Speech | Private | ✅ Complete | POST /history |
| S19 | Văn bản toàn màn hình | speech_screens.dart | Speech | Private | ✅ Complete | N/A |
| S20 | Lịch sử hội thoại | library_screens.dart | Library | Private | 🎭 Mock | GET /history |
| S21 | Chi tiết lịch sử | library_screens.dart | Library | Private | 🎭 Mock | GET /history/:id |
| S22 | Từ điển ký hiệu | library_screens.dart | Library | Public | 🎭 Mock | GET /dictionary |
| S23 | Chi tiết ký hiệu | library_screens.dart | Library | Public | 🎭 Mock | GET /dictionary/:id |
| S24 | Yêu thích | library_screens.dart | Library | Private | 🎭 Mock | GET /favorites |
| S25 | Cá nhân | profile_screens.dart | Profile | Private | 🎭 Mock | GET /auth/me |
| S26 | Chỉnh sửa hồ sơ | profile_screens.dart | Profile | Private | 🎭 Mock | PUT /users/profile |
| S27 | Cài đặt giọng nói | profile_screens.dart | Profile | Private | 🎭 Mock | PUT /users/settings |
| S28 | Giao diện & Trợ năng | profile_screens.dart | Profile | Private | 🎭 Mock | PUT /users/settings |
| S29 | Đồng bộ dữ liệu | profile_screens.dart | Profile | Private | 🎭 Mock | POST /sync |
| S30 | Quyền riêng tư | profile_screens.dart | Profile | Private | 🎭 Mock | DELETE /users/data |
| S31 | Thông tin ứng dụng | profile_screens.dart | Profile | Private | ✅ Complete | None |
| SS01 | Loading | system_screens.dart | System | All | ✅ Complete | None |
| SS02 | Empty State | system_screens.dart | System | All | ✅ Complete | None |
| SS03 | Success | system_screens.dart | System | All | ✅ Complete | None |
| SS04 | Error | system_screens.dart | System | All | ✅ Complete | None |
| SS05 | Offline | system_screens.dart | System | All | ✅ Complete | None |
| SS06 | Quyền bị từ chối | system_screens.dart | System | All | ✅ Complete | None |
| - | Screen Catalog | system_screens.dart | Debug | Dev | ✅ Complete | None |

**Legend:**
- ✅ **Complete:** Fully functional with demo data
- 🎭 **Mock:** UI complete but needs backend API
- ❌ **Missing:** Not implemented

---

## DETAILED SCREEN ANALYSIS

### 1. AUTHENTICATION FLOW (S01-S07)

#### S01: Splash Screen
- **Purpose:** App loading and branding
- **Duration:** 1.4 seconds auto-redirect
- **Navigation:** Auto → S02 (Onboarding 1)
- **Backend:** None required
- **State:** Complete
- **Assets:** Logo, gradient background

#### S02-S04: Onboarding Screens
- **Purpose:** Feature introduction (3 steps)
- **Content:**
  - S02: "Biến ký hiệu thành lời nói"
  - S03: "Nghe và chuyển đổi giọng nói"
  - S04: "Học từ điển ký hiệu đa dạng"
- **Navigation:** Next/Skip → S05 (Login) or next onboarding
- **Backend:** None required
- **State:** Complete

#### S05: Login Screen (Đăng nhập)
- **Purpose:** User authentication
- **Input Fields:**
  - Email (validated format)
  - Password (min 8 chars, show/hide toggle)
- **Actions:**
  - Login button
  - "Quên mật khẩu?" → S07
  - "Tạo tài khoản mới" → S06
  - "Dùng thử không cần đăng nhập" → S08 (guest mode)
  - OAuth buttons: Google, Facebook (UI only)
- **Validation:** Client-side only (demo)
- **Current Behavior:** Any valid format → Success → S08
- **Backend Needed:**
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/oauth/google`
  - `POST /api/v1/auth/oauth/facebook`
  - `POST /api/v1/auth/guest`
- **State:** Mock (needs real authentication)

#### S06: Register Screen (Đăng ký)
- **Purpose:** New user registration
- **Input Fields:**
  - Display name (required)
  - Email (validated format)
  - Password (min 8 chars, show/hide toggle)
  - Confirm password (must match)
  - Terms acceptance checkbox
- **Actions:**
  - Register button
  - "Đã có tài khoản? Đăng nhập" → S05
- **Validation:**
  - Email format
  - Password length
  - Password match
  - Terms checked
- **Current Behavior:** Valid input → Success → S08
- **Backend Needed:**
  - `POST /api/v1/auth/register`
- **State:** Mock (needs real registration)

#### S07: Forgot Password Screen
- **Purpose:** Password recovery
- **Input Fields:**
  - Email (validated format)
- **Actions:**
  - "Gửi email khôi phục" button
  - "Quay lại đăng nhập" → S05
- **Current Behavior:** Shows success message (no real email)
- **Backend Needed:**
  - `POST /api/v1/auth/forgot-password`
  - `POST /api/v1/auth/reset-password` (with token)
- **State:** Mock (needs email service)

---

### 2. HOME SCREEN (S08)

#### S08: Home Screen (Trang chủ)
- **Purpose:** Main dashboard and navigation hub
- **Sections:**
  1. **Greeting Header**
     - User name display
     - Time-based greeting
  2. **Main Features**
     - "Nhận diện ký hiệu" card → S09
     - "Chuyển đổi giọng nói" card → S15
  3. **Quick Access**
     - History → S20
     - Dictionary → S22
     - Favorites → S24
  4. **Bottom Navigation**
     - Home (current)
     - History → S20
     - Dictionary → S22
     - Profile → S25
- **Backend Needed:**
  - `GET /api/v1/auth/me` (user info)
  - `GET /api/v1/dashboard/stats` (optional)
- **State:** Complete UI, needs API for real user data

---

### 3. SIGN RECOGNITION FLOW (S09-S14)

#### S09: Camera Permission Screen
- **Purpose:** Request camera access
- **Content:**
  - Permission explanation
  - "Cấp quyền Camera" button
  - "Để sau" button → S08
- **Platform:** Android/iOS system permission dialog
- **Backend:** None required
- **State:** Complete

#### S10: Camera Ready Screen
- **Purpose:** Video capture interface
- **Components:**
  - Camera preview placeholder
  - "Bắt đầu nhận diện" button → S11/S12
  - Guidance text
- **Current Behavior:** Mock camera, hardcoded success
- **Backend Needed:**
  - `POST /api/v1/recognition/analyze` (AI endpoint - DEFERRED)
- **State:** Mock (AI integration deferred)

#### S11: Recognition Success
- **Purpose:** Show detected sign
- **Display:**
  - Detected sign: "Xin chào" (hardcoded)
  - Sign category
  - Meaning
  - Example usage
- **Actions:**
  - "Thêm vào câu" → S13
  - "Xem chi tiết" → S23
  - "Nhận diện lại" → S10
- **Backend Needed:**
  - `GET /api/v1/dictionary/:id` (after AI recognition)
- **State:** Mock (AI deferred)

#### S12: Recognition Failed
- **Purpose:** Handle recognition errors
- **Error Types:**
  - No sign detected
  - Unclear gesture
  - Multiple signs
  - Poor lighting
- **Actions:**
  - "Thử lại" → S10
  - "Hướng dẫn" (tips)
  - "Thoát" → S08
- **Backend:** None required
- **State:** Complete

#### S13: Sentence Builder
- **Purpose:** Compose sentence from detected signs
- **Features:**
  - List of added signs (chips)
  - "Thêm từ khác" → S10
  - Sentence preview
  - "Phát giọng nói" → S14
  - "Lưu vào lịch sử" (saves conversation)
- **Backend Needed:**
  - `POST /api/v1/history` (save conversation)
- **State:** Complete UI, needs history API

#### S14: Voice Playback
- **Purpose:** Text-to-speech playback
- **Components:**
  - Waveform animation
  - Play/pause controls
  - Speed adjustment (from settings)
  - Sentence text display
- **Current Behavior:** Mock TTS animation
- **Backend Needed:**
  - TTS service (DEFERRED to AI batch)
- **State:** Mock (TTS deferred)

---

### 4. SPEECH-TO-TEXT FLOW (S15-S19)

#### S15: Microphone Permission Screen
- **Purpose:** Request microphone access
- **Content:**
  - Permission explanation
  - "Cấp quyền Microphone" button
  - "Để sau" button → S08
- **Platform:** Android/iOS system permission dialog
- **Backend:** None required
- **State:** Complete

#### S16: Microphone Ready
- **Purpose:** Prepare for speech capture
- **Components:**
  - Microphone icon
  - "Bắt đầu" button → S17
  - Guidance text
- **Backend:** None required
- **State:** Complete

#### S17: Listening Screen
- **Purpose:** Active speech capture
- **Components:**
  - Pulse animation
  - Real-time partial transcript (mock)
  - "Dừng" button → S18
  - Volume indicator
- **Current Behavior:** Mock listening, hardcoded result
- **Backend Needed:**
  - `POST /api/v1/speech/transcribe` (AI endpoint - DEFERRED)
- **State:** Mock (AI integration deferred)

#### S18: Transcript Result
- **Purpose:** Display transcribed text
- **Features:**
  - Full transcript text
  - Font size adjustment (pinch/buttons)
  - "Sửa" button (manual edit)
  - "Sao chép" button
  - "Toàn màn hình" → S19
  - "Lưu vào lịch sử" (saves conversation)
- **Backend Needed:**
  - `POST /api/v1/history` (save conversation)
- **State:** Complete UI, needs history API

#### S19: Fullscreen Transcript
- **Purpose:** Large text display for accessibility
- **Features:**
  - Full screen text
  - Font size controls
  - "Thu nhỏ" → S18
- **Backend:** None required (presentation only)
- **State:** Complete

---

### 5. LIBRARY FLOW (S20-S24)

#### S20: History Screen
- **Purpose:** View conversation history
- **Features:**
  - Search bar (text search)
  - Filter dropdown (direction: All/Sign→Speech/Speech→Text)
  - Favorite filter toggle
  - List of conversations
    - Content preview
    - Timestamp (relative)
    - Direction badge
    - Favorite icon
  - Long press actions:
    - Favorite toggle
    - Copy text
    - Delete (with confirmation)
  - Tap → S21 (detail view)
- **Current Data:** 3 demo conversations in memory
- **Backend Needed:**
  - `GET /api/v1/history` (with filters, pagination)
  - `POST /api/v1/history` (create)
  - `PUT /api/v1/history/:id/favorite`
  - `DELETE /api/v1/history/:id`
- **State:** Mock (needs API)

#### S21: History Detail Screen
- **Purpose:** Full conversation view
- **Display:**
  - Full text content
  - Direction badge
  - Timestamp (full format)
  - Category (if applicable)
- **Actions:**
  - Favorite toggle
  - Copy text
  - Share (system share)
  - Delete (with confirmation) → S20
- **Backend Needed:**
  - `GET /api/v1/history/:id`
  - `PUT /api/v1/history/:id/favorite`
  - `DELETE /api/v1/history/:id`
- **State:** Mock (needs API)

#### S22: Dictionary Screen
- **Purpose:** Browse sign language dictionary
- **Features:**
  - Search bar (text search)
  - Category filter dropdown (10 categories)
  - Grid/list of sign entries
    - Sign name
    - Category badge
    - Thumbnail placeholder
    - Favorite icon
  - Tap → S23 (detail view)
  - Favorite toggle (quick action)
- **Current Data:** 10 hardcoded entries (from Figma)
- **Backend Needed:**
  - `GET /api/v1/dictionary` (with filters, pagination)
  - `GET /api/v1/categories`
  - `POST /api/v1/favorites` (add)
  - `DELETE /api/v1/favorites/:id` (remove)
- **State:** Mock (needs API)

#### S23: Sign Detail Screen
- **Purpose:** Complete sign information
- **Display:**
  - Sign name (title)
  - Category
  - Meaning (description)
  - Example sentence
  - Step-by-step instructions (if available)
  - Media placeholder (video/image)
- **Actions:**
  - Favorite toggle
  - Play demo (mock animation)
  - "Thêm vào câu" → S13
  - Share
- **Current Behavior:**
  - Only "Xin chào" has detailed instructions
  - Others show basic info only
- **Backend Needed:**
  - `GET /api/v1/dictionary/:id`
  - `POST /api/v1/favorites`
  - `DELETE /api/v1/favorites/:id`
- **State:** Mock (needs API + media)

#### S24: Favorites Screen
- **Purpose:** User's favorite signs
- **Features:**
  - Same layout as S22 (dictionary)
  - Filter: Favorites only
  - Empty state if no favorites
  - Remove favorite (quick action)
- **Current Data:** 2 favorites ("Xin chào", "Cảm ơn")
- **Backend Needed:**
  - `GET /api/v1/favorites`
  - `DELETE /api/v1/favorites/:id`
- **State:** Mock (needs API)

---

### 6. PROFILE & SETTINGS FLOW (S25-S31)

#### S25: Profile Screen
- **Purpose:** User account dashboard
- **Sections:**
  1. **User Info**
     - Avatar (colored circle with initials)
     - Display name
     - Email
     - "Chỉnh sửa hồ sơ" → S26
  2. **Settings Menu**
     - Cài đặt giọng nói → S27
     - Giao diện & Trợ năng → S28
     - Đồng bộ dữ liệu → S29
     - Quyền riêng tư → S30
     - Thông tin ứng dụng → S31
  3. **Actions**
     - Đăng xuất (with confirmation)
- **Current Data:** Demo user (Nguyễn Minh Tuấn)
- **Backend Needed:**
  - `GET /api/v1/auth/me`
  - `POST /api/v1/auth/logout`
- **State:** Mock (needs API)

#### S26: Edit Profile Screen
- **Purpose:** Update user information
- **Input Fields:**
  - Display name (text input)
  - Email (text input, validated)
  - Avatar color (color picker: 5 colors)
- **Actions:**
  - "Lưu thay đổi" (validates and saves)
  - "Hủy" → S25
- **Validation:**
  - Name not empty
  - Email format
- **Current Behavior:** Changes in memory only
- **Backend Needed:**
  - `PUT /api/v1/users/profile`
- **State:** Mock (needs API)

#### S27: Voice Settings Screen
- **Purpose:** Configure TTS parameters
- **Settings:**
  - **Tốc độ đọc** (Speech speed)
    - Slider: 0.5x - 2.0x
    - Default: 1.0x
  - **Cao độ** (Pitch)
    - Slider: 0.5x - 2.0x
    - Default: 1.0x
  - **Tự động phát** (Auto-speak)
    - Toggle: Enable/disable
- **Actions:**
  - "Demo giọng nói" (test TTS with current settings)
  - "Đặt lại mặc định"
  - Auto-save on change
- **Current Behavior:** Values stored in memory
- **Backend Needed:**
  - `PUT /api/v1/users/settings`
  - `GET /api/v1/users/settings`
- **State:** Mock (needs API)

#### S28: Appearance & Accessibility Screen
- **Purpose:** UI customization
- **Settings:**
  1. **Chế độ giao diện** (Theme)
     - Radio buttons: Sáng / Tối / Theo hệ thống
  2. **Cỡ chữ** (Font scale)
     - Slider: 0.8x - 1.5x
     - Preview text
  3. **Tương phản cao** (High contrast)
     - Toggle: Enable/disable
- **Actions:**
  - Auto-save on change
  - "Đặt lại mặc định"
- **Current Behavior:**
  - Changes apply immediately to entire app
  - Values stored in memory
- **Backend Needed:**
  - `PUT /api/v1/users/settings`
  - `GET /api/v1/users/settings`
- **State:** Mock (needs API for persistence)

#### S29: Sync Screen
- **Purpose:** Cloud data synchronization
- **Display:**
  - Last sync timestamp (or "Chưa đồng bộ")
  - Sync status: Online/Offline
  - Data counts:
    - Conversations synced
    - Favorites synced
  - "Đồng bộ ngay" button
- **Actions:**
  - Manual sync trigger
  - Auto-sync toggle (settings)
- **Current Behavior:**
  - Shows fake sync animation (1.1s)
  - Updates "last sync" timestamp
  - No actual data transfer
- **Backend Needed:**
  - `POST /api/v1/sync` (bidirectional sync)
  - `GET /api/v1/sync/status`
- **State:** Mock (needs sync service)

#### S30: Privacy Screen
- **Purpose:** Data management and privacy
- **Sections:**
  1. **Dữ liệu thiết bị**
     - "Xóa lịch sử hội thoại"
     - "Xóa yêu thích"
     - "Xóa toàn bộ dữ liệu cục bộ"
  2. **Tài khoản**
     - "Tải dữ liệu của tôi"
     - "Xóa tài khoản"
- **Actions:**
  - Each action requires confirmation dialog
  - Destructive actions show warning
- **Current Behavior:**
  - Only clears in-memory data
  - Account deletion is mock action
- **Backend Needed:**
  - `DELETE /api/v1/users/data/local` (history, favorites)
  - `GET /api/v1/users/data/export` (GDPR compliance)
  - `DELETE /api/v1/users/account` (account deletion)
- **State:** Mock (needs API)

#### S31: About Screen
- **Purpose:** App information and credits
- **Display:**
  - App logo
  - App name: SignVoice
  - Version: 1.0.0+1
  - Description: "Kết nối giao tiếp, xóa nhòa khoảng cách"
  - Links:
    - Privacy policy
    - Terms of service
    - Developer website
  - "Danh mục 37 màn hình" → Catalog
  - Copyright notice
- **Backend:** None required
- **State:** Complete

---

### 7. SYSTEM STATE SCREENS (SS01-SS06)

#### SS01: Loading State
- **Purpose:** Generic loading indicator
- **Components:**
  - Logo
  - Loading spinner
  - Optional message
- **Usage:** Any async operation
- **State:** Complete

#### SS02: Empty State
- **Purpose:** No data available message
- **Components:**
  - Illustration/icon
  - "Không có dữ liệu" message
  - Optional action button
- **Usage:** Empty lists (history, favorites, etc.)
- **State:** Complete

#### SS03: Success State
- **Purpose:** Operation success feedback
- **Components:**
  - Success icon (checkmark)
  - Success message
  - "Tiếp tục" button
- **Usage:** After save, delete, etc.
- **State:** Complete

#### SS04: Error State
- **Purpose:** Error feedback
- **Components:**
  - Error icon
  - Error message
  - "Thử lại" button
  - "Quay lại" button
- **Usage:** API errors, validation errors
- **State:** Complete

#### SS05: Offline State
- **Purpose:** No network connection
- **Components:**
  - Offline icon
  - "Không có kết nối" message
  - "Thử lại" button
- **Usage:** Network connectivity issues
- **State:** Complete

#### SS06: Permission Denied
- **Purpose:** System permission rejected
- **Components:**
  - Permission icon
  - Explanation message
  - "Mở cài đặt" button (opens system settings)
  - "Để sau" button
- **Usage:** Camera/microphone permission denied
- **State:** Complete

---

### 8. DEBUG SCREEN

#### Screen Catalog
- **Purpose:** Development navigation tool
- **Display:** List of all 37 screens with IDs
- **Navigation:** Tap any screen → navigate to that screen
- **Usage:** Testing and QA
- **Access:** S31 → "Danh mục 37 màn hình" or route 'catalog'
- **State:** Complete

---

## BACKEND API REQUIREMENTS SUMMARY

### Authentication Endpoints (8)
- POST /api/v1/auth/register
- POST /api/v1/auth/login
- POST /api/v1/auth/logout
- POST /api/v1/auth/refresh
- POST /api/v1/auth/guest
- POST /api/v1/auth/oauth/google
- POST /api/v1/auth/oauth/facebook
- POST /api/v1/auth/forgot-password
- POST /api/v1/auth/reset-password

### User Endpoints (5)
- GET /api/v1/auth/me
- PUT /api/v1/users/profile
- GET /api/v1/users/settings
- PUT /api/v1/users/settings
- GET /api/v1/users/data/export
- DELETE /api/v1/users/account
- DELETE /api/v1/users/data/local

### Dictionary Endpoints (4)
- GET /api/v1/dictionary (list with filters)
- GET /api/v1/dictionary/:id
- GET /api/v1/categories
- POST /api/v1/dictionary (STAFF only)

### Favorites Endpoints (3)
- GET /api/v1/favorites
- POST /api/v1/favorites
- DELETE /api/v1/favorites/:id

### History Endpoints (5)
- GET /api/v1/history (list with filters)
- GET /api/v1/history/:id
- POST /api/v1/history
- PUT /api/v1/history/:id/favorite
- DELETE /api/v1/history/:id

### Sync Endpoints (2)
- POST /api/v1/sync
- GET /api/v1/sync/status

### AI Endpoints (DEFERRED)
- POST /api/v1/recognition/analyze
- POST /api/v1/speech/transcribe
- POST /api/v1/tts/synthesize

### Admin Endpoints (future batch)
- GET /api/v1/admin/users
- PUT /api/v1/admin/users/:id/status
- GET /api/v1/admin/dictionary/pending
- PUT /api/v1/admin/dictionary/:id/approve
- PUT /api/v1/admin/dictionary/:id/reject

**Total API Endpoints (Batch 01):** ~35-40 endpoints

---

## NAVIGATION FLOW

```
S01 (Splash)
  ↓ (auto 1.4s)
S02-S04 (Onboarding)
  ↓ (skip/next)
S05 (Login) ←→ S06 (Register)
  ↓ (auth success)   ↑
S08 (Home) ←──────────┘
  ├─→ S09-S14 (Recognition flow)
  ├─→ S15-S19 (Speech flow)
  ├─→ S20-S21 (History)
  ├─→ S22-S24 (Dictionary/Favorites)
  └─→ S25-S31 (Profile/Settings)

System States: SS01-SS06 (overlays, can appear anywhere)
```

---

## MOBILE vs WEB CONSIDERATIONS

### Mobile-Specific
- Camera access (native)
- Microphone access (native)
- System share sheet
- Native permissions dialogs
- Full screen mode

### Web-Specific
- Desktop frame (max-width: 440px, centered)
- Browser camera API
- Browser microphone API
- Web Share API (if supported)
- CORS considerations

### Shared
- All screens accessible on both platforms
- Same API endpoints
- Same data models
- Same authentication flow
- Responsive design (handled in app.dart)

---

## TESTING COVERAGE

### Screens Tested (from README)
- ✅ All 37 screens at phone dimensions
- ✅ Login form validation
- ✅ Navigation flows
- ✅ Demo data integrity

### Screens Needing Integration Tests (Post-Backend)
- 🔴 S05-S07 (Auth with real API)
- 🔴 S20-S21 (History CRUD)
- 🔴 S22-S24 (Dictionary + Favorites)
- 🔴 S25-S26 (Profile updates)
- 🔴 S27-S28 (Settings persistence)
- 🔴 S29 (Sync operations)

---

## PRIORITY MATRIX

### P0 (Critical - Batch 01)
- S05-S07: Authentication screens → Auth API
- S08: Home → User session API
- S20-S21: History → History API
- S22-S24: Dictionary/Favorites → Dictionary API
- S25-S26: Profile → User API
- S27-S28: Settings → Settings API

### P1 (High - Batch 02)
- S29: Sync → Sync service
- S30: Privacy → Data management API
- Admin screens (not in current inventory)
- Staff screens (not in current inventory)

### P2 (Deferred - AI Batch)
- S09-S14: Sign recognition → AI model integration
- S15-S19: Speech-to-text → AI model integration
- S14: TTS playback → TTS service

---

**INVENTORY COMPLETE**  
**Status:** ✅ All 37 screens documented  
**Next:** Create FEATURE_MATRIX.md with detailed API mappings
