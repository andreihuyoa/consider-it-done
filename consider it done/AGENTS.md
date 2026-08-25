# AGENTS.md

## Project
Native iOS-first (SwiftUI, iOS 17+), macOS-secondary bookmark/saves aggregator.
Users capture links from any app via the Share Extension, organize into flat
Collections (no nesting), tag freely, and get nudged back to unread saves via
reminders, a weekly digest, and widgets.

## Stack
- Swift 5.10+, SwiftUI only — no UIKit unless a SwiftUI API gap requires it
  (state the gap in a comment if so).
- SwiftData + CloudKit for persistence/sync. No third-party persistence layer.
- WidgetKit for widgets, `MenuBarExtra` for the macOS menu bar surface.
- `UNUserNotificationCenter` for all notifications — no EventKit/Reminders integration.
- Foundation Models framework (on-device) for tag/action suggestion, digest
  theming, and natural-language search. No network calls, no third-party AI SDKs.
- No third-party grid/masonry libraries. Masonry is built on SwiftUI's `Layout`
  protocol.

## Non-negotiables
- No fallback logic unless explicitly specified in the task. If Open Graph
  data is missing, the item saves with title/URL only — do not add a snapshot
  or alternate-source fallback unless asked.
- No placeholder code, no TODOs left in committed code.
- Do not introduce dependencies (SPM packages) without asking first.
- Do not rename existing public types/properties once established — ask before
  changing a model's public shape.
- One main screen with view-state (segmented filter + grid/list toggle +
  expanding detail), not a multi-route navigation stack. Only genuinely
  separate surfaces: Share Extension, Settings, macOS menu bar panel.

## Architecture conventions
- MVVM: SwiftData `@Model` types are the source of truth; Views own
  `@Query`/`@State`; business logic (OG parsing, tag suggestion, digest
  generation) lives in plain Swift services injected via `@Environment` or
  initializers — not static singletons.
- Flat many-to-many relationships only (`SavedItem <<-->> Collection`,
  `SavedItem <<-->> Tag`). No nested folders/collections in MVP scope.
- Keep the Share Extension target thin: parse OG tags, write a `SavedItem`
  via the shared SwiftData container (App Group), nothing else. AI
  suggestion runs in the main app on next launch, not inside the extension.

## Design system (must be followed exactly, not approximated)
Tokens — define once as a `Color` extension / `Asset Catalog`, reference
everywhere, never hardcode hex in views:

| Token | Hex | Use |
|---|---|---|
| `textPrimary` | #2F332F | primary text |
| `textMuted` | #747870 | secondary text |
| `textSoft` | #565B54 | tertiary text |
| `background` | #F3EDE2 | app background |
| `surface` | #FFFAF2 | cards |
| `surfaceMuted` | #ECE5D9 | recessed surfaces |
| `surfaceSoft` | #FBF7F0 | elevated-but-quiet surfaces |
| `border` | #747870 | default border |
| `borderStrong` | #2F332F | emphasized border |
| `accent` (interactive) | #EE9B1A | save button, active tab, selected state, primary CTA — used sparingly |
| `success` (semantic only) | #5F7D67 on #E4EFDA | viewed indicator, reminder-set confirmation — never used for navigation |
| `shadow` | rgba(72,64,48,0.18) | soft shadow only, no drop-shadow-on-everything |

Rules:
- 8pt spacing grid, no arbitrary spacing values.
- Understated type scale — no display-size headlines. Differentiate hierarchy
  primarily by weight, secondarily by size.
- `accent` is the only saturated color used for interactive elements. `success`
  green is semantic-only and must never appear on a button/tab/nav element.
- No gradients. No default SF Symbol icon soup — pick one icon set/weight and
  use consistently.
- Motion is functional, not decorative: `matchedGeometryEffect` for
  card→detail, `.scrollTransition` for scroll reveals, `PhaseAnimator` for the
  save-confirmation micro-interaction, staggered entrance capped at ~15 items.
  Do not add animation to elements where it doesn't communicate state change.

## Apple HIG compliance
Follow [Designing for iOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)
and [Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos)
on top of the token/motion rules above — the token table governs *what*
colors/spacing to use, HIG governs *how* controls behave per platform.

**iOS**
- Support Dynamic Type. Use SwiftUI's built-in text styles (`.font(.body)`,
  `.font(.headline)`, etc.) scaled from the type scale, not fixed point sizes.
- Support Dark Mode via semantic `Color` assets (not just the light values in
  the token table) — define a dark variant per token in the Asset Catalog. If
  Dark Mode is deferred for MVP, that must be an explicit decision, not a gap:
  ask before skipping it.
- Respect reachability: primary actions (save, add to collection, dismiss
  detail) live in the middle/bottom of the screen, not top-only. Detail
  overlay must support swipe-to-dismiss in addition to any close button.
- Respect Reduce Motion accessibility setting — stagger/scroll-transition
  animations must degrade to instant/cross-fade when enabled.

**macOS**
- Menu bar (`MenuBarExtra`) is the only committed macOS surface for MVP per
  current scope — confirm before assuming a full resizable main window is
  in scope; if one is needed, it must support standard resize/full-screen
  and follow the same view-state model as iOS (not a separate design).
- Any macOS commands beyond the menu bar popover should go through the
  standard `Commands` scene modifier (menu bar app menu), not custom UI
  chrome, and should have keyboard shortcuts where an obvious one exists
  (e.g. ⌘F for search).

## Definition of done
- Builds with no warnings introduced.
- New Swift files respect existing folder structure (Models/, Views/,
  Services/, Widgets/, ShareExtension/, MenuBarExtra/).
- Any new SwiftData model change includes a migration plan note in the PR
  description, not just the schema change.
- UI changes are checked against the token table above before considered done.
