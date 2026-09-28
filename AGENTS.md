# AGENTS.md

This repository is designed for long-running coding-agent work (Codex). The
goal is not to maximize raw code output. The goal is to leave the repo in a
state where the next session can continue without guessing, and where every
completed feature has actual test evidence behind it — not a claim.

## Project

"Consider It Done" — iOS-first (macOS secondary) bookmark/saves aggregator.
SwiftUI + SwiftData. Universal save layer via Share Extension. See
`docs/PRODUCT.md` for the full spec (collections, tags, reminders, weekly
digest) if that file exists; otherwise defer to the prompts in
`docs/prompts/` and ask before assuming product behavior.

## Session start (do this in order, every session)

1. Confirm working directory with `pwd`.
2. Read `claude-progress.md` for the latest verified state and next step.
3. Read `feature_list.json` and choose the **single** highest-priority entry
   with `status` of `not_started` or `in_progress`. Do not pick a
   `blocked` entry unless the blocker is explicitly resolved by the user in
   this session.
4. Review recent commits with `git log --oneline -10`.
5. Run `./init.sh` — this builds the project and runs the unit test suite.
   Do not start new work on a red build.

## Scope rules (non-negotiable)

- **One feature at a time.** Work only on the `feature_list.json` entry you
  selected. Do not touch unrelated files.
- **No unspecced features.** If a feature is not an entry in
  `feature_list.json`, it does not get built — flag it as a suggested new
  entry in `claude-progress.md` instead and stop.
- **No silent scope decisions.** Anything not explicitly specified (new
  enums, new workflows, new architectural patterns, macOS full-window app,
  new dependencies) must be raised as an explicit open question and
  confirmed by Carl before you write code for it. This includes decisions
  that "seem obviously right" — raise them anyway.
- **Data model changes require a migration note.** SwiftData model changes
  must state whether they are lightweight-migration-safe; if not, say so
  explicitly and stop for confirmation.
- **Preserve existing public API / SwiftData schema** unless the selected
  feature entry explicitly requires changing it.

## Definition of done

A feature entry may only be marked `status: passing` in `feature_list.json`
if **all** of the following are true:

- [ ] The behavior described in `user_visible_behavior` is implemented.
- [ ] Every command listed in that entry's `verification` array was actually
      run in this session (not assumed, not "should pass").
- [ ] All verification commands exited 0 / produced the expected result.
- [ ] The `evidence` field is filled in with the real output (test names
      that passed, relevant log lines, or a description of manual UI
      verification performed in Simulator).
- [ ] `./init.sh` still passes after the change (no regressions introduced).
- [ ] The repo is restartable: `./init.sh` runs clean from a fresh checkout
      state.

If any verification step fails, set `status: blocked`, record the failure
in `evidence`, and describe the blocker in `claude-progress.md`. Do not mark
`passing` and move on. Do not weaken or remove a verification step to make
it pass — if a step seems wrong, flag it and ask.

## Source of truth files

- `feature_list.json` — machine-readable feature state. Authoritative for
  "what exists / what's done." Never build something not listed here.
- `claude-progress.md` — session-by-session narrative log. Read first,
  append at the end. Never delete prior entries.
- `init.sh` — standard startup + verification path (build + unit tests).
- `docs/prompts/` — original phased build prompts (MVP, Phase 2 AI). Treat
  as historical spec reference, not live task state.

## Design/architecture conventions (do not violate silently)

- Color tokens: light mode uses `#F3EDE2` bg, `#FFFAF2` surface, and a sage
  green accent `#56735D` (`figAccent`; orange is retired as of 2026-09-28).
  `#5F7D67` / `#E4EFDA` remain the success tokens. Light and dark mode are both supported, and every
  token has a dark value. The full adaptive table is in `design.md` → “Color
  system”. Views use token names only. No gradients, no default SF Symbol
  soup.
- Typography: Vollkorn Medium Italic for headings, Figtree for body text (both
  bundled, OFL). Use `.font(.heading(...))` / `.font(.text(...))`; both scale
  with Dynamic Type. See `design.md` → “Typography”.
- Apple HIG is the UX baseline (behavior, accessibility, Dynamic Type), not the
  app's visual personality. Avoid stock-looking system UI where design.md
  specifies a custom treatment.
- Don't rename existing, generally named functions, types, or variables as a
  side effect of restyling.
- `Collection` and `Tag` must be proper SwiftData `@Model` types with
  relationships — never raw arrays on `SavedItem`.
- Thumbnails: automatic images come from Open Graph image parsing only. No
  oEmbed, no generated or placeholder thumbnails. A user may attach their own
  image to a save. It is stored separately and takes priority over the OG
  image; that is user content, not a fallback mechanism.
- Grid: pinch-to-zoom, 3 discrete density levels (organization → masonry
  2-col iOS / 3-col macOS → carousel), via `MagnifyGesture` snapping between
  states. There is no visible density picker. Non-pinch access is only
  through accessibility actions and ⌘ +/− shortcuts (see `design.md` →
  “Density levels”).
- macOS scope is `MenuBarExtra`-only until Carl explicitly confirms a full
  `WindowGroup` app. Do not build a full window app speculatively.
- On-device AI (Apple Foundation Models) is Phase 2. Do not pull it into
  MVP work.

## Wrap-up (before ending every session)

1. Update `claude-progress.md` with this session's entry (see template at
   top of that file).
2. Update `feature_list.json` — status, verification, evidence, notes for
   the feature(s) touched.
3. Record any unresolved risk or blocker explicitly, in both files.
4. Commit with a descriptive message only once the repo is in a state where
   `./init.sh` passes.
5. Leave the repo clean enough that the next session can run `./init.sh`
   immediately with no manual fixups.

## When stuck

- Architecture decisions not covered above → ask Carl, do not guess.
- Ambiguous product behavior → check `docs/prompts/`, then ask.
- Repeated verification failures (2+ attempts) → set `status: blocked`,
  write up the failure clearly in `claude-progress.md`, stop and ask rather
  than continuing to patch.
