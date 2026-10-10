# SignVoice MongoDB Schema Design
**Complete Database Schema for Node.js/Mongoose Implementation**

**Version:** 1.0  
**Date:** 2026-10-09  
**Database:** MongoDB 6.x/7.x  
**ODM:** Mongoose 8.x

---

## COLLECTIONS OVERVIEW

| Collection | Purpose | Est. Size | Indexes |
|------------|---------|-----------|---------|
| users | User accounts | 10K-1M | 3 |
| auth_sessions | Refresh tokens | 10K-1M | 2 |
| user_settings | User preferences | 10K-1M | 1 |
| categories | Dictionary categories | <100 | 2 |
| dictionary_entries | Sign language content | 1K-10K | 4 |
| favorites | User favorites | 100K-10M | 1 |
| conversations | User history | 100K-10M | 2 |
| audit_logs | System audit trail | 100K+ | 2 |

---

## 1. users

**Purpose:** User accounts with authentication and profile data

```javascript
{
  _id: ObjectId,                     // Auto-generated
  email: String,                     // Original email
  normalizedEmail: String,           // lowercase, unique index
  passwordHash: String?,             // null for OAuth-only users
  displayName: String,               // User's name
  avatarColor: Number,               // 0-4 color index
  avatarUrl: String?,                // Optional custom avatar URL
  role: String,                      // "USER" | "STAFF" | "ADMIN"
  status: String,                    // "ACTIVE" | "DISABLED"
  guest: Boolean,                    // true for guest accounts
  
  // OAuth fields
  oauthProvider: String?,            // "google" | "facebook" | null
  oauthId: String?,                  // Provider user ID
  
  // Metadata
  guestConvertedAt: Date?,           // When guest converted to user
  lastLoginAt: Date?,                // Last successful login
  createdAt: Date,                   // Auto-managed by Mongoose
  updatedAt: Date                    // Auto-managed by Mongoose
}
```

**Mongoose Schema:**
```typescript
const UserSchema = new Schema({
  email: {
    type: String,
    required: function() { return !this.guest; },
    trim: true
  },
  normalizedEmail: {
    type: String,
    unique: true,
    sparse: true, // Allow null for guests
    lowercase: true
  },
  passwordHash: String,
  displayName: {
    type: String,
    required: true,
    trim: true,
    minlength: 1,
    maxlength: 100
  },
  avatarColor: {
    type: Number,
    default: 0,
    min: 0,
    max: 4
  },
  avatarUrl: String,
  role: {
    type: String,
    enum: ['USER', 'STAFF', 'ADMIN'],
    default: 'USER'
  },
  status: {
    type: String,
    enum: ['ACTIVE', 'DISABLED'],
    default: 'ACTIVE'
  },
  guest: {
    type: Boolean,
    default: false
  },
  oauthProvider: {
    type: String,
    enum: ['google', 'facebook']
  },
  oauthId: String,
  guestConvertedAt: Date,
  lastLoginAt: Date
}, {
  timestamps: true
});

// Indexes
UserSchema.index({ normalizedEmail: 1 }, { unique: true, sparse: true });
UserSchema.index({ role: 1 });
UserSchema.index({ status: 1 });
UserSchema.index({ oauthProvider: 1, oauthId: 1 }, { sparse: true });

// Virtual: Don't return passwordHash
UserSchema.set('toJSON', {
  transform: (doc, ret) => {
    delete ret.passwordHash;
    return ret;
  }
});
```

**Sample Document:**
```json
{
  "_id": "670d1234567890abcdef1234",
  "email": "nguyen@example.com",
  "normalizedEmail": "nguyen@example.com",
  "passwordHash": "$argon2id$v=19$m=65536...",
  "displayName": "Nguyễn Văn A",
  "avatarColor": 2,
  "role": "USER",
  "status": "ACTIVE",
  "guest": false,
  "lastLoginAt": "2026-10-09T10:30:00.000Z",
  "createdAt": "2026-10-01T08:00:00.000Z",
  "updatedAt": "2026-10-09T10:30:00.000Z"
}
```

---

## 2. auth_sessions

**Purpose:** Refresh token storage for session management

```javascript
{
  _id: ObjectId,
  userId: ObjectId,                  // ref: users
  refreshTokenHash: String,          // Hashed refresh token
  deviceInfo: {                      // Optional device tracking
    platform: String?,               // "web" | "android" | "ios"
    userAgent: String?
  },
  createdAt: Date,
  expiresAt: Date,                   // 7 days from creation
  revokedAt: Date?                   // Set when logged out
}
```

**Mongoose Schema:**
```typescript
const AuthSessionSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  refreshTokenHash: {
    type: String,
    required: true
  },
  deviceInfo: {
    platform: String,
    userAgent: String
  },
  expiresAt: {
    type: Date,
    required: true,
    index: true
  },
  revokedAt: Date
}, {
  timestamps: { createdAt: true, updatedAt: false }
});

// Indexes
AuthSessionSchema.index({ userId: 1, expiresAt: 1 });
AuthSessionSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index
```

---

## 3. user_settings

**Purpose:** User preferences (theme, font, speech settings)

```javascript
{
  _id: ObjectId,
  userId: ObjectId,                  // ref: users, unique
  
  // Appearance
  themeMode: String,                 // "light" | "dark" | "system"
  fontScale: Number,                 // 0.8 - 1.5
  highContrast: Boolean,
  
  // Voice/Speech
  speechSpeed: Number,               // 0.5 - 2.0
  speechPitch: Number,               // 0.5 - 2.0
  autoSpeak: Boolean,
  
  updatedAt: Date
}
```

**Mongoose Schema:**
```typescript
const UserSettingsSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  themeMode: {
    type: String,
    enum: ['light', 'dark', 'system'],
    default: 'light'
  },
  fontScale: {
    type: Number,
    default: 1.0,
    min: 0.8,
    max: 1.5
  },
  highContrast: {
    type: Boolean,
    default: false
  },
  speechSpeed: {
    type: Number,
    default: 1.0,
    min: 0.5,
    max: 2.0
  },
  speechPitch: {
    type: Number,
    default: 1.0,
    min: 0.5,
    max: 2.0
  },
  autoSpeak: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: { createdAt: false, updatedAt: true }
});

// Index
UserSettingsSchema.index({ userId: 1 });
```

---

## 4. categories

**Purpose:** Dictionary entry categories

```javascript
{
  _id: ObjectId,
  name: String,                      // Display name
  slug: String,                      // URL-friendly, unique
  description: String?,
  isActive: Boolean,
  sortOrder: Number,                 // Display order
  createdAt: Date,
  updatedAt: Date
}
```

**Mongoose Schema:**
```typescript
const CategorySchema = new Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  slug: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  description: {
    type: String,
    maxlength: 500
  },
  isActive: {
    type: Boolean,
    default: true
  },
  sortOrder: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Indexes
CategorySchema.index({ slug: 1 }, { unique: true });
CategorySchema.index({ isActive: 1, sortOrder: 1 });
```

**Seed Data (10 entries from Flutter):**
```json
[
  { "name": "Chào hỏi", "slug": "chao-hoi", "sortOrder": 1 },
  { "name": "Ăn uống", "slug": "an-uong", "sortOrder": 2 },
  { "name": "Sức khỏe", "slug": "suc-khoe", "sortOrder": 3 },
  { "name": "Cảm xúc", "slug": "cam-xuc", "sortOrder": 4 },
  { "name": "Khẩn cấp", "slug": "khan-cap", "sortOrder": 5 }
]
```

---

## 5. dictionary_entries

**Purpose:** Sign language dictionary content

```javascript
{
  _id: ObjectId,
  title: String,                     // Sign name (e.g., "Xin chào")
  normalizedTitle: String,           // lowercase for search
  categoryId: ObjectId,              // ref: categories
  meaning: String,                   // Definition
  example: String,                   // Usage example
  instructions: String?,             // Step-by-step guide
  tags: [String],                    // Search keywords
  mediaRefs: [{                      // Media files (future)
    type: String,                    // "image" | "video"
    url: String
  }],
  
  // Moderation workflow
  status: String,                    // See statuses below
  createdBy: ObjectId,               // ref: users (STAFF)
  updatedBy: ObjectId?,              // ref: users (last editor)
  reviewedBy: ObjectId?,             // ref: users (ADMIN who reviewed)
  reviewReason: String?,             // Rejection reason
  revision: Number,                  // Version number
  
  // Timestamps
  createdAt: Date,
  updatedAt: Date,
  publishedAt: Date?,                // When approved
  submittedAt: Date?                 // When submitted for review
}
```

**Status Values:**
- `DRAFT` - Being edited by STAFF
- `PENDING_REVIEW` - Submitted, awaiting approval
- `PUBLISHED` - Approved and public
- `REJECTED` - Rejected by admin
- `ARCHIVED` - Soft deleted

**Mongoose Schema:**
```typescript
const DictionaryEntrySchema = new Schema({
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200
  },
  normalizedTitle: {
    type: String,
    required: true,
    lowercase: true
  },
  categoryId: {
    type: Schema.Types.ObjectId,
    ref: 'Category',
    required: true
  },
  meaning: {
    type: String,
    required: true,
    maxlength: 1000
  },
  example: {
    type: String,
    required: true,
    maxlength: 500
  },
  instructions: {
    type: String,
    maxlength: 2000
  },
  tags: [String],
  mediaRefs: [{
    type: { type: String, enum: ['image', 'video'] },
    url: String
  }],
  status: {
    type: String,
    enum: ['DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'REJECTED', 'ARCHIVED'],
    default: 'DRAFT'
  },
  createdBy: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  updatedBy: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  },
  reviewedBy: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  },
  reviewReason: String,
  revision: {
    type: Number,
    default: 1
  },
  publishedAt: Date,
  submittedAt: Date
}, {
  timestamps: true
});

// Indexes
DictionaryEntrySchema.index({ status: 1, categoryId: 1 });
DictionaryEntrySchema.index({ normalizedTitle: 'text', meaning: 'text' });
DictionaryEntrySchema.index({ createdBy: 1, status: 1 });
DictionaryEntrySchema.index({ publishedAt: -1 });
```

---

## 6. favorites

**Purpose:** User's favorite dictionary entries

```javascript
{
  _id: ObjectId,
  userId: ObjectId,                  // ref: users
  entryId: ObjectId,                 // ref: dictionary_entries
  createdAt: Date
}
```

**Mongoose Schema:**
```typescript
const FavoriteSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  entryId: {
    type: Schema.Types.ObjectId,
    ref: 'DictionaryEntry',
    required: true
  }
}, {
  timestamps: { createdAt: true, updatedAt: false }
});

// Compound unique index
FavoriteSchema.index({ userId: 1, entryId: 1 }, { unique: true });
```

---

## 7. conversations

**Purpose:** User conversation history (sign→speech, speech→text)

```javascript
{
  _id: ObjectId,
  userId: ObjectId,                  // ref: users
  content: String,                   // Conversation text
  direction: String,                 // "signToSpeech" | "speechToText"
  favorite: Boolean,
  createdAt: Date
}
```

**Mongoose Schema:**
```typescript
const ConversationSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    required: true,
    maxlength: 5000
  },
  direction: {
    type: String,
    enum: ['signToSpeech', 'speechToText'],
    required: true
  },
  favorite: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: { createdAt: true, updatedAt: false }
});

// Indexes
ConversationSchema.index({ userId: 1, createdAt: -1 });
ConversationSchema.index({ userId: 1, favorite: 1, createdAt: -1 });
```

---

## 8. audit_logs

**Purpose:** System audit trail for admin actions

```javascript
{
  _id: ObjectId,
  actorId: ObjectId,                 // ref: users (who did the action)
  action: String,                    // Action type
  targetType: String,                // "User" | "DictionaryEntry" | etc.
  targetId: ObjectId?,               // Target resource ID
  metadata: Object,                  // Safe additional data
  createdAt: Date
}
```

**Action Types:**
- `USER_REGISTERED`
- `USER_LOGGED_IN`
- `USER_ROLE_CHANGED`
- `USER_STATUS_CHANGED`
- `DICT_ENTRY_APPROVED`
- `DICT_ENTRY_REJECTED`
- `CATEGORY_CREATED`
- `CATEGORY_UPDATED`
- `ACCOUNT_DELETED`

**Mongoose Schema:**
```typescript
const AuditLogSchema = new Schema({
  actorId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  action: {
    type: String,
    required: true
  },
  targetType: String,
  targetId: Schema.Types.ObjectId,
  metadata: Schema.Types.Mixed
}, {
  timestamps: { createdAt: true, updatedAt: false }
});

// Indexes
AuditLogSchema.index({ createdAt: -1 });
AuditLogSchema.index({ actorId: 1, createdAt: -1 });

// TTL index: Delete logs older than 90 days
AuditLogSchema.index({ createdAt: 1 }, { expireAfterSeconds: 7776000 });
```

---

## DATABASE INITIALIZATION SCRIPT

```typescript
// scripts/seed.ts
async function seedDatabase() {
  // 1. Check environment
  if (process.env.NODE_ENV === 'production') {
    throw new Error('Cannot seed production database');
  }

  // 2. Create categories (idempotent)
  const categories = [
    { name: 'Chào hỏi', slug: 'chao-hoi', sortOrder: 1 },
    { name: 'Ăn uống', slug: 'an-uong', sortOrder: 2 },
    { name: 'Sức khỏe', slug: 'suc-khoe', sortOrder: 3 },
    { name: 'Cảm xúc', slug: 'cam-xuc', sortOrder: 4 },
    { name: 'Khẩn cấp', slug: 'khan-cap', sortOrder: 5 }
  ];
  
  for (const cat of categories) {
    await Category.findOneAndUpdate(
      { slug: cat.slug },
      cat,
      { upsert: true, new: true }
    );
  }

  // 3. Create admin user (idempotent)
  const adminEmail = 'admin@signvoice.local';
  const existingAdmin = await User.findOne({ normalizedEmail: adminEmail });
  
  if (!existingAdmin) {
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin123456';
    const hashedPassword = await hashPassword(adminPassword);
    
    await User.create({
      email: adminEmail,
      normalizedEmail: adminEmail,
      passwordHash: hashedPassword,
      displayName: 'Admin',
      role: 'ADMIN',
      avatarColor: 0
    });
    console.log('✅ Admin user created');
  }

  // 4. Create dictionary entries (idempotent)
  const chaoHoiCat = await Category.findOne({ slug: 'chao-hoi' });
  const entries = [
    {
      title: 'Xin chào',
      meaning: 'Dùng để chào hỏi khi gặp mặt...',
      example: 'Xin chào, tôi tên là Minh.',
      instructions: 'Đưa bàn tay phải lên...',
      categoryId: chaoHoiCat._id
    },
    // ... (10 entries total from Flutter source)
  ];
  
  for (const entry of entries) {
    await DictionaryEntry.findOneAndUpdate(
      { normalizedTitle: entry.title.toLowerCase(), status: 'PUBLISHED' },
      {
        ...entry,
        normalizedTitle: entry.title.toLowerCase(),
        status: 'PUBLISHED',
        createdBy: adminUser._id,
        publishedAt: new Date()
      },
      { upsert: true, new: true }
    );
  }

  console.log('✅ Database seeded successfully');
}
```

---

**MONGODB SCHEMA COMPLETE**  
**Total Collections:** 8  
**Total Indexes:** 18  
**Ready for:** Mongoose model implementation
