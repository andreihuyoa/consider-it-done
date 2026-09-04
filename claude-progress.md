# claude-progress.md

Session-by-session log. Read this first at the start of every session.
Append a new entry at the end of every session — never delete or rewrite
past entries.

---

## Template (copy this block for each new entry)

### Session: YYYY-MM-DD HH:MM

**Feature worked on:** `<feature_list.json id>`

**Goal:** What I set out to do this session, one or two sentences.

**Changes made:** Files touched and what changed in each, brief.

**Verification run:**
- Command: `<exact command>`
- Result: `<pass/fail + relevant output>`

**Evidence:** Copy of the actual output that proves it works (test names,
build result, or description of manual Simulator check with exact steps
taken).

**Status:** `not_started | in_progress | blocked | passing`

**Known risks / follow-ups:** Anything left unresolved, any assumption made
that needs Carl's confirmation, anything that felt like scope creep and was
deliberately not built.

**Next step:** What the next session should pick up, and why (should match
the highest-priority unfinished `feature_list.json` entry unless something
here overrides that).

---

## Log

### Session: (seed) — repo state as of last code review

**Feature worked on:** n/a — baseline

**Goal:** n/a

**Changes made:** n/a

**Verification run:** n/a

**Evidence:** Code review identified critical gaps (see `feature_list.json`
entries `data-model-reminder-viewed`, `data-model-collection-tag-relations`,
`thumbnail-rendering`, `macos-3col-branch`, `macos-full-window-app`) and
scope creep already removed/flagged (`SaveStatus`/Archive workflow,
`SaveContentType` enum, URL-pattern `LinkClassifier`).

**Status:** n/a

**Known risks / follow-ups:** Confirm with Carl whether scope-creep items
(Archive workflow, LinkClassifier) should be deleted from the codebase
entirely or left dormant/unused. Do not resolve this silently.

**Next step:** Start with `data-model-collection-tag-relations` — other
entries depend on it (see its `notes`).

### Session: 2026-08-28 03:46

**Feature worked on:** n/a — requested UI navigation/sort/archive pass is not
listed in `feature_list.json`

**Goal:** Begin the requested iOS-first navigation and save-flow UI pass only
after the required repository preflight succeeded.

**Changes made:** No source changes. The working tree already contained
uncommitted changes in `consider it done/ContentView.swift`,
`consider it done/Design/FigDesignTokens.swift`, and
`consider it done/Models/SavedItem.swift`, plus an untracked `.vscode/`
directory; these were preserved.

**Verification run:**
- Command: `./init.sh`
- Result: fail (exit 65). The script requests scheme `ConsiderItDone`, but
  `xcodebuild -list` reports only scheme `consider it done`; CoreSimulator was
  also unavailable in the restricted environment.
- Command: `xcodebuild -list`
- Result: completed; target and scheme are named `consider it done`.

**Evidence:** `xcodebuild: error: The project named "consider it done" does not
contain a scheme named "ConsiderItDone".` The requested UI work has no matching
feature entry, while AGENTS.md requires stopping and flagging an unlisted
feature instead of implementing it.

**Status:** `blocked`

**Known risks / follow-ups:** Suggested new feature entry: the requested
two-destination bottom tab bar, add-link sheet/FAB, grouped sort dropdown,
archived filter, and restore action. Before implementation, add/approve that
feature in `feature_list.json` and repair or confirm the `init.sh` scheme name.
Existing uncommitted user changes must remain isolated.

**Next step:** Carl should confirm the new feature entry and the intended
scheme/preflight fix; then rerun `./init.sh` before any UI edits.

### Session: 2026-08-28 03:54

**Feature worked on:** `ui-navigation-save-modal-sort-archive`

**Goal:** Resolve the preflight blocker, then complete the requested
iOS-first navigation, add-link modal, sort/group, and archive visibility pass.

**Changes made:** Updated `init.sh` to use the actual `consider it done`
scheme, the available iPhone 17 simulator, and an explicit no-test-target
skip. Added the requested UI feature entry to `feature_list.json`. Preserved
the existing uncommitted `ContentView.swift` work and completed its stale
`.save` cleanup. Replaced the organization segmented sort picker with a
Recent/Importance/Reminder Menu using an active-only checkmark and grouped it
with Group in one bordered container. Added dynamic Archive/Restore behavior
in `SaveDetailOverlay.swift` and removed stale `.save` cases from
`EmptyFigState.swift`.

**Verification run:**
- Command: `./init.sh`
- Result: pass; iOS build succeeded for `platform=iOS Simulator,name=iPhone
  17`, and the script reported no unit-test target is configured.
- Command: `xcodebuild -scheme 'consider it done' -sdk iphonesimulator
  -derivedDataPath /private/tmp/consider-it-done-ios-derived-data
  CODE_SIGNING_ALLOWED=NO build`
- Result: pass; iOS Simulator SDK build succeeded.
- Command: `xcodebuild -scheme 'consider it done' -destination
  'platform=macOS' -derivedDataPath /private/tmp/consider-it-done-derived-data
  CODE_SIGNING_ALLOWED=NO build`
- Result: pass; macOS compile/build succeeded.
- Command: `git diff --check`
- Result: pass.
- Command: `rg -n '\\.save|case save|saveComposer|areaPicker' 'consider it done'`
- Result: no stale navigation/composer references found.

**Evidence:** `** BUILD SUCCEEDED **` was produced by both iOS Simulator SDK
and macOS builds. `./init.sh` ended with `init.sh passed: build is green;
configured unit-test action checked`. No unit-test target exists in the
project, so no automated unit tests ran.

**Status:** `in_progress`

**Known risks / follow-ups:** Manual iOS and macOS MenuBarExtra verification
has not been performed in this session. Existing user changes in
`ContentView.swift`, `Design/FigDesignTokens.swift`, and `Models/SavedItem.swift`
remain mixed with this pass and were not discarded or committed separately.
The attached repository reference is available as an image, but no tracked
`the-fig-nav-refinements.svg` file exists.

**Next step:** Run the listed manual iOS and macOS UI checks, then update the
feature evidence/status. Keep the existing user changes intact when committing.
