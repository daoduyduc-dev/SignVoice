# Non-AI baseline audit

Date: 2026-10-16. Reviewer role: independent verification. Source reviewed:
`32a3674` (pushed baseline `78efbe2` plus delivery documentation), in the isolated
`non-ai-audit` worktree. This is a source/contract audit; no live database or secrets
were accessed, and no database-backed tests were run.

## Active implementation boundary

`lib/main.dart` -> `lib/app.dart` -> `AccessGate` -> `screenFor` routes normal users
to `lib/features/{auth,home,library,profile,recognition,speech}/*`. The similarly named
`lib/screens/user/*` are not the routed implementation. Only AuthProvider and
AdminWorkspaceService are installed globally; StaffProvider is installed on the staff
dashboard. Existing dictionary/favorites/history/settings/profile providers are not
wired to these active user screens. Therefore fixing only those unused screens or
providers cannot complete the requested flows.

## Blocking findings, ordered for delivery

| Priority | Finding and evidence | Required closure / verification |
| --- | --- | --- |
| P1 security | `backend/src/routes/user.routes.ts:106-116` applies the whole body with `$set` to a settings document, including schema-defined `userId`. An authenticated user can reassign their settings to another valid user ID if the target has no settings, causing cross-account mutation/denial of intended defaults. | Strict allowlist validation; reject ownership/ID/timestamps and unknown fields; always derive owner from authenticated request. Test two accounts and both existing/missing target settings. |
| P1 integration | Active S20/S21 history reads and mutates only `AppState.history`; backend `/history` is **dictionary view history** (`SearchHistory`), not conversations. No API exists for the active conversation content/direction/favorite/detail/save/delete lifecycle. `Conversation.model.ts` has unrelated assistant-message semantics and is not mounted. | Define one explicit manual-conversation contract, add owned CRUD/filter/pagination/favorite/clear APIs and connect active screens. Keep search history separate; test user A cannot read/update/delete user B records. |
| P1 integration | Active S22/S23/S24 favorite buttons call `state.toggleSign`, and favorite listing resolves the in-memory set via dictionary requests. No `/favorites` API is invoked (`library_screens.dart:262,449,542`). Refresh/login clears all favorites. | Server-owned IDs and persisted list/mutations; disable or explicitly restrict guests in both layers; test add/remove/reload/account switch plus missing/unpublished entries. |
| P1 integration | S26 profile edit modifies `state.name/email` only (`profile_screens.dart:209-210`); avatar is an immediate local mutation before save. Server profile accepts only displayName/avatarUrl, so the current editable email field has no matching update contract. | Persist validated profile, retain inputs on failed save, apply avatar only on confirmed save; make email immutable or implement a deliberate collision-safe email-change contract. |
| P1 integration | S27/S28 voice/appearance/accessibility settings change AppState only. BE settings has `theme: LIGHT/DARK/SYSTEM`, `fontSize`, notification/privacy flags; FE settings model has lowercase theme/language/notifications and no font/voice/contrast fields. | Agree DTO, extend settings schema for supported non-AI preferences, load/apply persisted values and validate ranges; test reload and concurrent account transitions. |
| P1 integration | S29 invokes `simulateSync()` (1100 ms timer), and S30 clears local collections; “delete account” only logs out. Export and self-account deletion endpoints/UI are absent. | Real reload with truthful per-resource failures; owned server history/data deletion; explicit self-account deletion that revokes sessions and cleans/anonymizes related records; downloadable owned export. Test effects by reloading APIs and denied credentials. |
| P1 security/integration | Draft ownership differs by endpoint: `/dictionary/:id` checks STAFF creator in `dictionary.service.ts:189`, while `/staff/content/:id` calls `management.updateDictionary` with no creator check. A STAFF denied the first endpoint can edit another staff member's draft through the latter; rejection follows the same unrestricted path. | Choose/document the intended ownership rule and enforce it in a shared mutation boundary across all aliases. Test owner/non-owner/custom permission roles for every write path. |
| P1 integration | Staff dashboard always fails loading stats: `StaffService.getStats` decodes `data.stats`, server returns `data` directly. Its actions push `/staff/content` and `/staff/users`, neither registered in `app.dart`. | Correct the stats DTO and add complete staff list/detail/edit/user routes with RBAC, loading/error/empty/pagination states; interaction tests must tap actual dashboard actions. |
| P1 feature | OAuth is absent: only unused env credential fields exist; Google button shows a toast; Facebook button and all initiation/state/callback/exchange endpoints are missing. | Configurable Google/Facebook code flow; bounded single-use state bound to initiating browser, provider identity validation, safe collision behavior, no tokens in URL. Missing config explicit while local login works. Test mocked provider boundary now; real credential/domain acceptance remains external. |
| P1 correctness/privacy | `clearLocalData()` clears history/favorites/sentence/selectedHistoryId only (`app_state.dart:170`). `transcript`, `detectedSign`, selected dictionary entry, avatar, theme/accessibility/voice preferences and sync metadata survive logout/account switch. Selected conversation silently falls back to the first record if its ID is absent. | Reset every account-owned state value, cancel/ignore stale in-flight responses, load defaults/new-account settings; selected detail must show not-found rather than a different record. Account A/B tests across every state category. |
| P1 truthfulness | Home loads fixed `signs[0..3]`, and active recognition/speech screens still produce and save fixed demo detections/transcripts. This violates the requested non-AI boundary. | Home uses real published dictionary and persisted recent history. Recognition/STT/TTS unavailable states must be explicit and unable to fabricate results; manually entered text may be saved through the real history contract. |

## API compatibility traps when wiring existing services

These are currently dormant for normal user screens but will break a straightforward
“install existing providers” implementation:

| Existing FE consumer | Actual backend output |
| --- | --- |
| `UserService.getProfile/updateProfile`: `data.user` | Raw user object in `data` |
| `UserService.getSettings/updateSettings`: `data.settings` | Raw settings object in `data` |
| `FavoritesService.getFavorites/addFavorite`: `data.favorites/data.favorite` | Array / raw favorite in `data` |
| `HistoryService.getHistory`: `data.history` | Search-history array in `data` |
| `StaffService.getContent`: `data.entries` | `data.items` |
| Staff content/user detail and mutation decode `data.entry/data.user` | Raw document in `data` |
| `DictionaryEntryModel.categoryId/createdBy`: String | Populated objects in dictionary detail/list and staff responses |
| `FavoriteModel.id/entryId/entry`: String/String/separate entry | `_id`; populated `entryId` object or null, with no separate `entry` |

Use controlled HTTP tests with the real FE service/model decoders and actual response
fixtures; providers faked above the decoder do not catch these failures.

## Additional release gates

1. **Favorites integrity:** POST accepts any syntactically valid entry ID without checking
   existence/publication. Read population can return `entryId:null`. Routes bypass model
   favorite counter methods, so entry.favoriteCount never tracks route mutations. Reject
   invalid/non-public targets and guarantee idempotent counters (including bulk/account deletes).
2. **Input validation:** public dictionary/favorites/history/staff pagination uses unchecked
   parseInt/Number; negative, NaN, arrays/objects and arbitrary staff sort/search expressions
   reach queries. Some staff detail/approve/reject paths lack ObjectId validation. Return
   consistent 400 for malformed input; bound pagination/search/sort and escape literal regex.
   Legacy dictionary update validates category ID syntax but not category existence/activity;
   legacy publish permits inactive categories and increments cached counts separately from
   admin mutations. Share validation/status/count logic across all routes.
3. **Guest boundary:** private user/favorites/history routes use requireAuth alone; the
   existing requirePermanentAccount is unused there. Match the chosen guest restrictions in
   server, active UI and conversion flow. Active register always creates a new user; it never
   calls `convertGuest`, so trial data cannot transfer to a permanent account.
4. **Session and sensitive identity:** session termination checks sessions:write but does not
   check the target account's permission set, unlike account management. A limited custom
   session manager can revoke a more privileged administrator's sessions; close this if the
   existing “cannot manage higher permissions” contract applies. `User` embeds provider access/
   refresh tokens without select:false; raw profile/staff/admin user responses would disclose
   them once OAuth stores tokens. Use explicit safe DTOs and avoid storing unneeded provider tokens.
5. **Account/security completion:** no change-password controller/route/UI despite existing
   validation schema, no current-user device/session management UI, no active logout-all action.
   Login/register/guest creation have no request rate limiting. Add explicit tests for these
   boundaries. Management mutations currently write no AuditLog (only auth/password reset do);
   record actor/target/action without secrets for role/status/content/session changes.
6. **Dictionary detail freshness:** S23 renders only the selected list snapshot (or default
   demo entry on direct navigation); it does not fetch real detail, detect a later archive/delete,
   or record a normal signed-in dictionary view. Missing video toggles a fake playing state.
   Fetch by stable ID, handle 404/archived content explicitly, expose a real media link or
   unavailable media state, and avoid duplicate category-name filtering after server ID filter.
7. **Hosting:** ApiConfig's default is `http://localhost:3000/api/v1`, reproducing phone failure
   unless every web build passes the relative override. Default web to same-origin `/api/v1`,
   keep native configurable, document PUBLIC_ORIGIN/CORS/OAuth callbacks for localhost vs.
   changing Conveyor domain, and verify public build contains no hardcoded local API.
8. **Verification isolation:** current backend suites call connectDatabase with environment
   MONGODB_URI and perform mutations/deletes; vitest.config.ts has no dedicated database
   override/guard. Require an isolated test database/name guard before executing the full suite.

## Delivery acceptance evidence still needed

- Backend contract/ownership/RBAC/status tests on an isolated test database.
- Active routed Flutter interactions and real service DTO tests for refresh/restart and
  account changes, including API errors and missing/deleted resources.
- Full analyzer/test/web build; supported Android build and real phone test of public origin.
- OAuth mocked protocol tests plus explicit manual setup/checklist; live Google/Facebook
  acceptance is pending credentials and registered callback origins, not “100% verified”.

No code changes are included in this audit.
