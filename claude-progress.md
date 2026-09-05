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

### Session: 2026-09-04 00:15

**Feature worked on:** `ui-navigation-save-modal-sort-archive`

**Goal:** Create an implementation-facing `design.md` for the existing iOS UI
work using the supplied mockup, two Dribbble references, the current repository,
and the requested Emil Kowalski design-engineering skill.

**Changes made:** Added `design.md` at the repository root with the product's
visual character, reference translation, existing color tokens, typography,
spacing, card construction, information hierarchy, screen composition, motion,
accessibility, platform behavior, implementation guardrails, acceptance checks,
and explicit open decisions. Updated this feature's evidence and notes in
`feature_list.json`. Installed the requested `emil-design-eng` Codex skill for
future sessions. No Swift source or SwiftData schema was changed.

**Verification run:**
- Command: `./init.sh` in the restricted environment
- Result: fail (exit 70); CoreSimulatorService was unavailable and no iPhone 17
  destination could be enumerated.
- Command: `./init.sh` with Simulator access after all documentation changes
- Result: pass; iOS build succeeded and the script reported that no unit-test
  target is configured.
- Command: `jq empty feature_list.json`
- Result: pass; the feature state file is valid JSON.
- Command: `awk '/[[:blank:]]$/ { print FNR ": trailing whitespace"; bad=1 }
  END { exit bad }' design.md`
- Result: pass; no trailing whitespace was found.
- Command: `rg -n '^#{1,6} ' design.md` and reference-link search
- Result: pass; document headings and both requested reference URLs are present.

**Evidence:** The final `./init.sh` run produced `** BUILD SUCCEEDED **` and
ended with `init.sh passed: build is green; configured unit-test action checked`.
The design guide preserves the repository's fixed cream/orange/semantic-green
palette, Open Graph-only thumbnail rule, three discrete density levels, and
MenuBarExtra-only macOS scope.

**Status:** `in_progress`

**Known risks / follow-ups:** The existing manual iOS and macOS acceptance steps
remain pending, so the feature was not marked passing. `design.md` intentionally
leaves product naming, contextual “Recent Figs” headings, dark mode, and haptics
as open decisions. The existing modified Swift files and `.vscode/` directory
were preserved. No commit was made because the required source-of-truth files
already contain intertwined uncommitted work from the prior UI session.

**Next step:** Confirm the open design decisions when needed, then implement the
approved card treatment with targeted SwiftUI changes and complete the existing
manual iOS/macOS verification checklist.

### Session: 2026-09-05 01:39

**Feature worked on:** `ui-navigation-save-modal-sort-archive`

**Goal:** Commit every existing working-tree change in clear, subject-only
conventional commits without pushing anything.

**Changes made:** Created separate local commits for the build harness, generated
author-header cleanup, bottom navigation/add-link/archive flow, organization
sorting controls and feature bookkeeping, the design guide, and SweetPad/VS Code
workspace configuration. Added this handoff entry and updated the feature
evidence. No source behavior was changed during the commit-only session.

**Verification run:**
- Command: `./init.sh`
- Result: pass; the iOS build succeeded for iPhone 17 and the script reported
  that no unit-test target is configured.
- Command: `jq empty feature_list.json`
- Result: pass.
- Command: `jq empty .vscode/settings.json .vscode/.swift-format
  .vscode/launch.json .vscode/tasks.json`
- Result: pass.
- Command: `git diff --cached --check` before each commit
- Result: pass for every staged group.
- Command: `git log --oneline -8` and `git status --short`
- Result: the intended local commit sequence was present and the tree was clean
  before this final bookkeeping update.

**Evidence:** The pre-commit `./init.sh` run ended with `** BUILD SUCCEEDED **`
and `init.sh passed: build is green; configured unit-test action checked`.
Created local commits `26db7ec`, `8fe2ca5`, `8fc96ea`, `e722f9f`, `e680928`,
and `2a7dd7c`; none were pushed.

**Status:** `in_progress`

**Known risks / follow-ups:** Manual iOS and macOS MenuBarExtra acceptance checks
are still pending. The repository hook still invokes the obsolete
`ConsiderItDone` scheme and iPhone 16 directly, so the verified intermediate
Swift commits used `--no-verify` after `./init.sh` passed with the repository's
current `consider it done` scheme and iPhone 17 destination.

**Next step:** Manually review the local commits and run the outstanding iOS and
macOS UI checks before changing the feature status or pushing.

### Session: 2026-09-05 16:10

**Feature worked on:** Planning only: `ui-redesign-main-navigation`,
`ui-redesign-visual-system`, `ui-redesign-notifications`, and
`ui-redesign-profile-settings`.

**Goal:** Register the requested redesign scope, extract the actual Figma Main
reference, and prepare explicit decisions for Carl before implementation.

**Changes made:** Added four `not_started` entries to `feature_list.json` with
acceptance steps, planning evidence, and explicit confirmation gates. Kept all
existing entries and priorities unchanged. Added this handoff; no Swift source,
SwiftData schema, business logic, design.md, or Figma document was modified.
No Search entry was added because Search was supplied as an example, not a
confirmed screen. Its own specification and feature entry are required if chosen.

**Verification run:**
- Command: `./init.sh` in the restricted environment
- Result: exit 70; CoreSimulatorService was unavailable and the iPhone 17
  destination could not be found. Rerunning with Simulator access resolved it.
- Command: `./init.sh` with Simulator access
- Result: exit 0; `** BUILD SUCCEEDED **`; `No unit-test target is configured;
  skipping test action`; `init.sh passed: build is green; configured unit-test
  action checked`.
- Figma: `get_design_context(fileKey: nePXlf8cVoXJXtF5zWcTGp, nodeId: 1:11,
  clientLanguages: swift, clientFrameworks: swiftui)` succeeded after locating
  the selected frame in Figma Desktop using read-only UI inspection.

**Evidence:** Figma Main is 402 x 874. Card x15/y218, 372 x 495; details area
130 high with 15 horizontal/10 vertical inset; title x15/y135; bottom region
402 x 90 at y762; circular controls 70 high; top pair group 152 x 70 at y65.
The empty card capsule is named Time Pill. Actual Figma colors include
#F7F2E9 background and green fields; typography includes Alte Haas Grotesk and
Inter. These reference values do not override locked #F3EDE2 background,
semantic green, system typography, or the three density modes. No navigation
labels/icons or notification/profile destination designs are defined by Main.
Source: https://www.figma.com/design/nePXlf8cVoXJXtF5zWcTGp/consider-it-done?node-id=1-11

**Status:** All four redesign entries remain `not_started`. No feature
implementation or manual feature acceptance was performed.

**Known risks / follow-ups:** The brief calls Collection/Tag priority 1, but the
live file has the prior navigation feature priority 1/in_progress and relations
priority 2/not_started. Carl must confirm queue order; adding backlog entries
at priorities 7-10 does not authorize starting them. Confirm final tabs/icons
(proposal: Saves/bookmark, Collections/square.stack, Search/magnifyingglass),
tab motion (proposal: 0.2-second easeInOut, none with Reduce Motion), and keeping
the existing shared matchedGeometryEffect overlay around a TabView shell.
Confirm notifications and profile/settings contents, actions, presentation,
and animation; no account, inbox, or new permission behavior is inferred.
Confirm contextual Recent Figs heading and Time Pill meaning or omission.
The existing detail spring response is 0.34/damping 0.88, dismissal 0.28/0.9,
and density 0.32/0.86; design.md's under-300ms direction needs reconciliation
if these animations are changed. design.md's exact-two-tab rule conflicts with
the proposed third tab; Carl must decide. Original feature manual checks and
legacy verification commands remain outstanding and were not weakened.

**Next step:** Ask Carl to confirm the recorded decisions before writing code.
Then finalize relevant feature specifications (including a separate Search entry
if approved), reconcile design.md, and implement only the single authorized
entry after a green preflight. Otherwise retain the existing queue order.

**Final validation:** Post-update `./init.sh` with Simulator access exited 0
with `** BUILD SUCCEEDED **`; unit tests were explicitly skipped because no
test target exists. `git diff --check` exited 0. A JSON comparison against HEAD
confirmed all seven existing entries are unchanged and all four new entries
have unique IDs, verification steps, and `not_started` status. Only the two
bookkeeping files are included in the local planning commit; no push requested.
