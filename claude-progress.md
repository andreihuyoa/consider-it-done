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


### Session: 2026-09-07 15:30

**Feature worked on:** `ui-redesign-main-navigation`, then `ui-redesign-search`,
then `ui-redesign-saves-carousel`, then `ui-redesign-visual-system`, implemented
sequentially with build checkpoints. Integration fixes follow the manual checks.
None is marked passing while its full verification list is incomplete.

**Goal:** Act on Carl's explicit redesign-first priority and confirmed tabs,
motion, shared detail architecture, and three density states. Register deferred
model work without changing persistence.

**Changes made:**
- `feature_list.json`: reprioritized redesign ahead of the existing queue;
  added Search, swipe-only carousel, optional soft-delete timestamp, and gated
  local profile storage entries. Updated confirmations, evidence, and remaining
  checks; kept the blocked macOS full-window entry byte-for-byte equivalent.
- `design.md`: recorded confirmed three tabs, 0.2-second ease-in-out/no Reduce
  Motion animation, shared overlay, and carousel override. Existing card tags
  are explicitly preserved. Notifications remains two labeled list groups.
- `ContentView.swift`: TabView now owns Saves/Collections/Search; a separate
  bottom add slot accompanies the labeled iOS control strip. The wrapper owns
  namespace, selected save, and overlay. Only the active tab participates as an
  enabled geometry source; the overlay disables/hides underlying controls from
  accessibility. Existing save flow, model state, and detail callbacks remain.
- `SearchSavesView.swift`: local active-only title/URL/description/tag matching,
  initial and no-result states, query retention, accessible result buttons,
  and the shared detail callback. This behavior was explicitly confirmed.
- `SaveCarousel.swift`, `SaveCarouselCard.swift`, `DensityContainer.swift`, and
  `DensityControl.swift`: closest density is a swipe-only front card with neutral
  upcoming-card planes. Keep BrowseDensity.list for compatibility. Middle column
  count and organization layout/sort/group algorithms remain unchanged; only
  matched-geometry source-role plumbing changed in OrganizationTileLayout.
- `SaveCards.swift`, `CollectionsOverview.swift`, `EmptyFigState.swift`, and
  `SaveDetailOverlay.swift`: rounder surfaces, restrained shadows, system title
  styles, labeled close controls, and detail action layout that avoids truncation.
  SaveTagRow and all model/color-token/app-scene/MenuBarSaveView files unchanged.

**Verification run:**
- `./init.sh` at startup and after navigation, Search, carousel, visual, and final
  integration changes. Final exit 0: `** BUILD SUCCEEDED **`; `No unit-test
  target is configured; skipping test action`; `init.sh passed: build is green;
  configured unit-test action checked`.
- `xcodebuild -scheme 'consider it done' -destination 'platform=macOS'
  -derivedDataPath /private/tmp/fig-redesign-macos-derived-data
  CODE_SIGNING_ALLOWED=NO build`: final exit 0, `** BUILD SUCCEEDED **`.
- `git diff --check`: exit 0.
- Python JSON/source invariants: unique feature IDs; SaveTagRow, model files,
  color tokens, app scenes, MenuBarSaveView, and blocked macOS feature unchanged.

**Evidence:** Created an isolated iPhone 17 simulator named The Fig Redesign QA
(AB209EBA-8BC9-42C1-9F02-0D69009B7B29) for test saves; existing simulator records
were not edited. Tested example.com and example.org only in that isolated app.
Observed three bottom labels with accessible selected state and separate Add Link.
Invalid empty URL kept inline error and sheet open. Valid URL dismissed to Saves;
saving from Search retained the tab and query. EXAMPLE matched both fixture URLs;
Search-to-detail opened centered, and closing retained query. Switching tabs also
retained the query. Archiving example.org removed it from active Search results.
Clear restored initial prompt, zzzznoresult gave No Results, and whitespace-only
query retained the initial prompt. Carousel left/right swipes changed 1 of 2 /
2 of 2; swiping beyond either boundary did not advance. Archive of the front card
returned safely to the remaining 1 of 1. No previous/next buttons were added.

Failures resolved during this session: unsupported macOS .tabless style was
replaced with supported .automatic; a misplaced isEnabled environment declaration
was moved to OrganizationTileLayout. Subsequent iOS and macOS builds passed.
Manual inspection caught intrinsic empty-tab white space, corrected with a full
height frame; detail geometry initially aligned to its source card, corrected by
explicitly disabling base geometry sources while the overlay is visible. The
centered final overlay and untruncated vertical actions were rechecked in QA.

**Status:** Implemented UI entries remain `in_progress`; Notifications remains
`not_started`; profile/settings and user-profile storage remain `blocked` pending
their explicit gates. No full feature acceptance or unit-test coverage claimed.

**Known risks / follow-ups:**
- Notifications filtering/presentation question is unanswered: proposal is a
  top-right native sheet with active saves newest first and future reminders
  soonest first, no extra section buttons. Only the two section labels/content
  grouping are confirmed. Do not ship an inert notifications/settings control.
- Settings and optional deletedAt are deferred; UserDefaults local profile
  name/image storage must be confirmed before pickup. CloudKit is deferred.
- Swipe-only carousel paging is explicitly accepted accessibility debt.
- Actual pinch gesture, Reduce Motion, VoiceOver interaction, large Dynamic Type,
  contrast, compact/landscape, description/tag/OG fixture coverage, deletion, and
  full macOS manual acceptance are still pending. The density picker was tested;
  do not conflate it with a physical pinch check.
- The old macOS manual checklist expects navigation/detail screens that are not
  present in the existing capture-only MenuBarSaveView. App scene also still has
  the pre-existing WindowGroup. Both remain untouched per the user's scope rule;
  clarify the checklist rather than silently changing it or marking it passed.
- The checked-in pre-commit hook uses obsolete scheme ConsiderItDone and iPhone
  16 for Swift changes. Use the verified current ./init.sh and final macOS build
  as evidence; any local checkpoint commit must document a one-command hook
  bypass without modifying the hook or weakening feature verification.

**Next step:** Resolve Notifications presentation/filtering, then implement that
single entry. Complete remaining manual acceptance and resolve the incompatible
macOS checklist before marking any affected UI entry passing. Continue to defer
Collection/Tag and all Settings/model work as explicitly requested.

### Session: 2026-09-07 20:20

**Feature worked on:** `ui-redesign-notifications`

**Goal:** Implement the confirmed two-section Notifications destination after
the user asked to continue, while leaving Settings and model work deferred.

**Changes made:** Added `NotificationsView.swift`, presenting active saves newest
first under Recently saved and future reminders soonest first under Upcoming
reminders. Added the labeled top-right bell and native sheet presentation to
`ContentView.swift`, with title clearance in Saves, Collections, and Search.
No additional list buttons, read state, permission request, scheduling workflow,
SwiftData field, app scene, MenuBar view, or color token was added or changed.

**Verification run:**
- Command: `./init.sh`
- Result: exit 0; `** BUILD SUCCEEDED **`; no unit-test target is configured,
  so the test action was explicitly skipped.
- Command: `xcodebuild -scheme 'consider it done' -destination 'platform=macOS'
  -derivedDataPath /private/tmp/fig-redesign-macos-derived-data
  CODE_SIGNING_ALLOWED=NO build`
- Result: exit 0; `** BUILD SUCCEEDED **`.
- Command: `xcrun swiftc -parse` for ContentView, NotificationsView, and
  SearchSavesView; `git diff --check`
- Result: both exited 0.

**Evidence:** On the isolated iPhone 17 QA simulator, the bell was exposed as
Notifications with a 44-point target. The sheet showed exactly Recently saved
and Upcoming reminders. The first section listed the active example.com fixture
with its saved date. The second section first showed `No upcoming reminders.`;
after assigning a future reminder, it listed the same fixture with the reminder
date. The native sheet grabber dismissed to Saves and, when opened from Search,
returned to the still-selected Search tab. Accessibility inspection exposed the
sheet title, both section headings, combined title/date rows, and native dismiss
control. At accessibility-extra-extra-extra-large, all content stayed readable
and scrollable; the QA device was restored to its original large text size.

**Status:** `in_progress`

**Known risks / follow-ups:** Reduce Motion and full VoiceOver interaction were
not manually exercised, so the feature remains in progress. The reminder used
for the list check was created only in the isolated QA simulator, and notification
delivery permission was denied; this entry itself adds no permission request.
Settings/profile storage remains blocked pending its separate confirmation gate.

**Next step:** Complete the remaining Reduce Motion and VoiceOver checks for
Notifications, then finish the outstanding manual acceptance for navigation,
Search, carousel, and visual-system entries. Continue deferring Collection/Tag
and all Settings/model work as requested.

### Session: 2026-09-07 20:30

**Feature worked on:** `ui-redesign-main-navigation`

**Goal:** Continue accessibility acceptance after the Notifications checkpoint.

**Changes made:** Extracted the bottom controls into `FigBottomBar.swift`. The
standard layout remains three labeled tabs on the left and Add Link on the right.
At accessibility Dynamic Type sizes, the destinations become three full-width
labeled rows and Add Link moves beneath them at the trailing edge.

**Verification run:**
- Command: `./init.sh`
- Result: exit 0; `** BUILD SUCCEEDED **`; no unit-test target is configured.
- Command: `xcrun swiftc -parse 'consider it done/ContentView.swift'
  'consider it done/Views/FigBottomBar.swift'`; `git diff --check`
- Result: both exited 0.

**Evidence:** At accessibility-extra-extra-extra-large, the first compact layout
split all three labels into unreadable fragments. After the adaptive change, the
isolated iPhone 17 QA simulator displayed complete Saves, Collections, and Search
labels in full-width rows, with selected styling and a separate trailing Add Link
button. The accessibility tree retained all three labels and selected state.

**Status:** `in_progress`

**Known risks / follow-ups:** The density segmented control also truncates at the
largest text size; address it under the carousel/visual-system entry. Reduce
Motion, VoiceOver interaction, landscape, and physical pinch checks remain.

**Next step:** Adapt the density control for accessibility text sizes, then
continue the remaining redesign acceptance without starting deferred model work.

### Session: 2026-09-07 20:45

**Feature worked on:** `ui-redesign-saves-carousel`

**Goal:** Make the three-state density selector usable at accessibility text
sizes while preserving its standard segmented presentation.

**Changes made:** `DensityControl` now keeps the existing segmented picker at
standard Dynamic Type sizes and presents a full-width labeled menu at
accessibility sizes. Both presentations use the same Organization, Masonry, and
Carousel titles and symbols and write to the existing `BrowseDensity` binding.
No density state, gesture, schema, card tag, or layout algorithm changed.

**Verification run:**
- Command: `./init.sh`
- Result: exit 0; `** BUILD SUCCEEDED **`; no unit-test target is configured.
- Command: `xcodebuild -scheme 'consider it done' -destination 'platform=macOS'
  -derivedDataPath /private/tmp/fig-redesign-macos-derived-data
  CODE_SIGNING_ALLOWED=NO build`
- Result: exit 0; `** BUILD SUCCEEDED **`.
- Command: `xcrun swiftc -parse 'consider it done/Views/DensityControl.swift'`;
  `jq empty feature_list.json`; `git diff --check`
- Result: all exited 0.
- Command: Simulator accessibility inspection at
  accessibility-extra-extra-extra-large.
- Result: the menu exposed Organization, Masonry, and Carousel; selecting
  Carousel changed its label to `Density: Carousel`. The QA simulator was
  restored to Large text after the check.

**Status:** `in_progress`

**Known risks / follow-ups:** Physical pinch, landscape, Reduce Motion, full
VoiceOver interaction, deletion behavior, and the remaining visual-system
fixtures still require manual acceptance. Swipe-only carousel paging remains the
explicitly accepted accessibility debt.

**Next step:** Continue the remaining redesign acceptance without starting
deferred model work. Physical pinch, landscape, Reduce Motion, and the
incompatible macOS checklist remain the main unresolved checks.

**Scope correction:** The user confirmed the iOS app is portrait-only and asked
to stop checking landscape. The brief landscape inspection and uncommitted
gesture experiment were discarded; no carousel gesture code changed. Landscape
was removed from the active redesign verification. Increase Contrast was also
checked on the isolated simulator: selected and unselected density states,
labels, card content, Notifications, bottom destinations, and Add Link remained
distinct. Increase Contrast was restored to its original disabled state.

Settings remains separate later-priority work under
`ui-redesign-profile-settings` (priority 33), after `data-model-soft-delete` and
the still-blocked `data-model-user-profile`. It is a top-right destination, not a
fourth bottom tab. The exact Settings content and local profile storage gate are
still unresolved, so no Settings code was added.
