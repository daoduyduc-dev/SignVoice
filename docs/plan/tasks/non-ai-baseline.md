---
id: non-ai-baseline
scope: repository baseline
status: in-progress
depends-on: []
---

## Objective

Return the project to the user's pushed origin/main commit `78efbe2`, preserving a recovery
copy of all recent AI work. Do not reset unrelated files or remove installed models/software.

## Context

Read docs/INDEX.md and docs/NON_AI_DELIVERY.md. Current branch task/non-ai-baseline.
All 22 currently modified tracked paths are the AI changes from this conversation.
The untracked android/build directory existed before AI work and must be left untouched.

## Path

Restore only the tracked paths currently reported by `git diff --name-only origin/main`.
Move these explicitly known AI additions to an ignored recovery directory under `.runtime`:
docs/LM_STUDIO_LOCAL.md, lib/ai_test_page.dart, lib/config/ai_config.dart,
lib/services/lm_studio_service.dart, lib/services/video_analysis_service.dart,
scripts/start-video-ai.ps1, test/ai_test_page_test.dart, test/lm_studio_service_test.dart,
test/video_analysis_service_test.dart, video_backend/.
Do not move the entire lib/config directory if it contains other files.
Do not move the new delivery docs or touch secrets in backend/.env.

## Implementation

First save a binary patch for tracked changes and copies of the listed additions in a
timestamped ignored recovery folder; verify all destination/source absolute paths remain
under this workspace before any move. Preserve original filenames and a restoration manifest.
Restore the tracked paths from origin/main, then move only the listed AI additions out of the
active project. Restore pub packages/generated registrants using flutter pub get.
Stop only the video AI process started by this conversation if its executable/command line
and listening port match the recorded local runtime metadata. Do not close the user's LM Studio.
Verify no active LM Studio imports/routes/packages remain. Record results in this task doc.
Commit only the delivery docs and any necessary baseline cleanup evidence on this branch.

## Verification

git diff origin/main should show delivery docs only, no active AI additions. Preserve
android/build and backend/.env. Run the baseline analyzer/tests and document pre-existing
failures rather than correcting application features in this task. Report the commit and
backup location for orchestrator merge.
