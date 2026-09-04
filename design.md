# The Fig — Product Design Direction

**Status:** Working design source of truth

**Platform priority:** iOS first; macOS remains a MenuBarExtra companion

**Last updated:** 2026-09-04

## Purpose

The Fig is a calm, tactile place for links worth returning to. It should feel
closer to a small personal collection of objects than a productivity dashboard
or a social feed.

The interface should make each save feel considered without competing with the
saved content. Warm paper-like surfaces, restrained color, editorial type, and
softly dimensional cards carry the personality. Interaction stays quick and
predictable.

## Experience principles

1. **Saved things should feel like objects.** Cards have a clear face, gentle
   depth, and enough breathing room to feel handled rather than packed into a
   database table.
2. **Content is the decoration.** Use the real Open Graph thumbnail when one is
   available. Do not generate substitute artwork, decorative thumbnails, or
   unrelated 3D imagery.
3. **Depth should be quiet.** Shape, tonal layers, and soft shadow create depth.
   Avoid thick outlines, glossy effects, glass everywhere, and dramatic
   perspective.
4. **Motion explains, then gets out of the way.** Animate card selection,
   density changes, sheets, and direct press feedback. Routine scrolling,
   filtering, and repeated navigation should not perform for the user.
5. **The app must remain recognizably native.** Use SwiftUI behaviors, Dynamic
   Type, system sheets, semantic controls, and accessibility settings even when
   the visual treatment is custom.
6. **The library should become quieter as it grows.** Strong hierarchy and
   adaptive density matter more than adding labels, icons, or controls.

## Reference translation

These references are inspiration, not templates to reproduce.

### [Mobile Learning App UI with Animated Quiz Cards](https://dribbble.com/shots/27445267-Mobile-Learning-App-UI-with-Animated-Quiz-Cards)

Use:

- a light, spacious canvas with one dominant content card;
- simple circular or capsule controls with generous hit areas;
- a clear split between visual media and a compact information region;
- playful motion only when it explains a change of state.

Do not use:

- learning-specific navigation or progress patterns;
- decorative character imagery that competes with saved content;
- persistent card animation.

### [Kraving Car mobile app design — 3D icons](https://dribbble.com/shots/27688174-Kraving-Car-mobile-app-design-3D-icons)

Use:

- tall cards with a large tonal visual field and a concise editorial caption;
- rounded shapes, controlled cropping, and generous internal spacing;
- depth through an object sitting within a field, plus a soft card shadow;
- deliberate contrast between the card and the surrounding canvas.

Adapt for The Fig:

- keep The Fig's warm light palette instead of adopting the reference's dark,
  pink, and red palette;
- let the saved thumbnail be the hero object;
- when no thumbnail exists, use a quiet tonal field and source mark only;
- reserve stacked backing layers for collections or grouped sources, where the
  layers communicate meaning.

## Visual character

The intended character is **warm, collected, tactile, and lightly playful**.
It is not cute, glossy, futuristic, or corporate. A useful test is that a screen
should still feel composed when every image is removed.

The dominant visual rhythm is:

`warm canvas → dimensional card → real content → concise metadata`

## Color system

The existing repository palette is authoritative.

| Role                 | Token                  | Value            | Use                                        |
| -------------------- | ---------------------- | ---------------- | ------------------------------------------ |
| Canvas               | `figBackground`        | `#F3EDE2`        | App and sheet backgrounds                  |
| Primary surface      | `figSurface`           | `#FFFAF2`        | Cards, active navigation, elevated panels  |
| Recessed surface     | `figSurfaceMuted`      | `#ECE5D9`        | Controls, empty media, inactive navigation |
| Soft surface         | `figSurfaceSoft`       | `#FBF7F0`        | Stacked card backing and subtle separation |
| Primary text         | `figTextPrimary`       | `#2F332F`        | Titles and essential actions               |
| Secondary text       | `figTextSoft`          | `#565B54`        | Descriptions and URLs                      |
| Muted text           | `figTextMuted`         | `#747870`        | Counts, labels, and metadata               |
| Border               | `figBorder`            | `#747870`        | Low-opacity control outlines only          |
| Strong border        | `figBorderStrong`      | `#2F332F`        | Rare high-contrast separation              |
| Primary action       | `figAccent`            | `#EE9B1A`        | Save action, FAB, focused action only      |
| Semantic green       | `figSuccess`           | `#5F7D67`        | Success, confirmed, completed states       |
| Semantic green field | `figSuccessBackground` | `#E4EFDA`        | Success field and selected semantic state  |
| Shadow               | `figShadow`            | `#484030` at 18% | Elevated cards and focused panels          |

### Color rules

- Orange is an action accent, not a general decoration color.
- Green is semantic. Do not use it randomly to make screens more colorful.
- Cards default to the primary surface. The green field is reserved for a real
  semantic state; a no-image hero card uses `figSurfaceMuted` instead.
- Information must never rely on color alone. Pair archive, reminder, selected,
  and success colors with a label, symbol, shape, or checkmark.
- Do not add gradients. Variation comes from content, spacing, and layered
  surfaces.

Dark mode is not defined yet. Do not auto-invert these values or invent a dark
palette without a separate approved direction.

## Typography

Use the system font so The Fig inherits native rendering, Dynamic Type, and
platform familiarity.

| Content                 | SwiftUI text style       | Treatment                                       |
| ----------------------- | ------------------------ | ----------------------------------------------- |
| Screen title            | `.largeTitle`            | Bold, compact copy, one line when possible      |
| Section or detail title | `.title2` / `.title3`    | Bold, two lines maximum in cards                |
| Card title              | `.headline`              | Bold; the strongest element below the image     |
| Description             | `.subheadline` / `.body` | Regular, relaxed line spacing                   |
| Controls                | `.callout`               | Bold only for the active or primary label       |
| Metadata                | `.footnote`              | Regular or semibold; never lighter than legible |

Rules:

- Prefer `bold()` to manually choosing a bold font weight in implementation.
- Do not use fixed point sizes for normal interface text.
- Avoid `.caption2`. Use `.caption` only when the content remains comfortably
  legible at all accessibility sizes.
- Titles use sentence case. Avoid all caps.
- Keep card descriptions to useful summaries; do not fill space with metadata.

## Spacing and shape

Use a restrained base scale: `4, 8, 12, 16, 24, 32` points. These are layout
intent values, not permission to force content into fixed frames.

| Element                  | Baseline treatment                           |
| ------------------------ | -------------------------------------------- |
| Screen horizontal inset  | 24 pt regular; may reduce on compact widths  |
| Card content inset       | 16 pt compact cards; 20 pt hero/detail cards |
| Card internal gap        | 8–12 pt                                      |
| Grid gap                 | 12 pt                                        |
| Major section gap        | 24–32 pt                                     |
| Standard control radius  | 12 pt                                        |
| Save card radius         | 20 pt                                        |
| Large panel/sheet radius | 24–28 pt where the system does not supply it |
| Pills and chips          | Capsule                                      |

Every interactive target must be at least `44 × 44` points even when its visible
shape is smaller.

## Elevation and card depth

The card look is the signature of the product. It should feel dimensional at a
glance and almost flat during use.

### Standard save card

- One primary surface with a 20 pt continuous corner radius.
- No strong border. If separation is needed, use a one-point low-contrast stroke
  close to the surface color.
- Use a soft ambient shadow based on `figShadow`; favor a broad blur and small
  downward offset. The shadow must not form a dark halo.
- The media region occupies roughly 55–65% of a tall card when an image is
  available.
- Media clips to the card's upper contour. The text region remains calm and
  light.
- The source mark sits inside the media field near the top trailing corner when
  legible, otherwise directly above the title.

### Hero save card

The supplied “Recent Figs” mockup establishes the preferred hero composition:

1. a large tonal media field, using real imagery or `figSurfaceMuted`;
2. a compact source mark near the top trailing edge;
3. title, short description, and tags anchored near the bottom;
4. a single soft card shadow against the warm canvas.

The mockup's pale green field is a useful depth reference, but it is not the
default empty-image color because green is reserved for semantic states in this
product.

The hero treatment is for the first or actively featured save. It must not make
every card enormous. At larger Dynamic Type sizes, the information region grows
and the media region yields space rather than clipping text.

### Collection and grouped-source cards

Use two offset backing planes behind the front card. The stack communicates that
the object contains multiple saves; it is not a decorative effect for individual
items.

- Backing offsets should be small and even.
- Backing planes use `figSurfaceSoft` and `figSurfaceMuted`.
- Only the front plane receives the main shadow.
- The count remains visible without opening the collection.

### Thumbnail rules

- Show the real Open Graph image only.
- Preserve a useful focal area with `scaledToFill` and predictable clipping.
- Never fabricate a fallback thumbnail, illustration, or 3D object.
- The no-image state is a flat recessed field with the source mark and enough
  contrast to remain intentional.
- Images are decorative to VoiceOver when the title already communicates the
  saved item; otherwise provide a meaningful accessibility label.

## Card information hierarchy

Show only what helps recognition:

1. Thumbnail or tonal media field
2. Source mark
3. Title
4. Short description, when useful
5. Up to three tags

Tags use compact light-surface pills with text such as `#design`, rather than a
row of uncontained words. If more than three tags exist, show `+N` instead of
wrapping the card into an unpredictable height.

URLs belong in list and detail contexts, not on the visual grid card.

## Screen composition

### The Fig

- The header has one strong title and one short contextual line.
- Density, sort, grouping, and archive controls sit below the header as one quiet
  control region; they should not compete with the first card.
- The content area begins close enough to the controls to read as the result of
  those choices.
- Scrolling content must clear both the bottom navigation and the add button.

The supplied mockup uses **Recent Figs** as the screen title. This is a good
contextual title when the active sort is Recent, but implementation should not
replace the current **The Fig** title until the naming rule for Importance,
Reminder, and Archived states is confirmed.

### Density levels

The three density levels represent different jobs, not just three card sizes.

| Density      | Job                    | Card treatment                                            |
| ------------ | ---------------------- | --------------------------------------------------------- |
| Organization | Understand the library | Mixed-height tiles or meaningful source/collection stacks |
| Grid         | Browse visually        | Two-column iOS masonry; image-forward cards               |
| List         | Find and scan          | Full-width rows with thumbnail, title, URL, and tags      |

Pinch transitions snap between these three states. Avoid continuous card scaling,
which makes text and hit targets feel unstable.

### Collections

Collections should feel like physical stacks of saves, not folders. Use the
stacked-card treatment, a collection name, and a link count. Avoid folder icons
unless future research shows users cannot understand the metaphor.

### Add-link sheet

- Use a native medium sheet on iOS.
- Focus the URL field when appropriate without forcing the keyboard after every
  return to the app.
- Make **Save Link** the only orange-filled action.
- Keep **Paste** secondary.
- Validation appears next to the field and stays until corrected.
- Successful save dismisses the sheet without moving the user to another tab.

### Save detail

- The selected card should visually expand into a focused surface when Reduce
  Motion is off.
- Keep the thumbnail, source, title, and description together at the top.
- Open Link is primary. Collection, reminder, archive/restore, and remove are
  progressively quieter actions.
- Remove remains destructive and requires confirmation.
- Opening detail records the item as viewed but never hides or archives it.

### Bottom navigation and add action

- Keep exactly two destinations: **The Fig** and **Collections**.
- Keep the add action separate and thumb reachable.
- Navigation labels remain visible; do not replace both destinations with
  unexplained icon-only circles from the visual references.
- The active destination uses a surface change plus text emphasis, not color
  alone.
- The add button may be circular, but its accessibility label must be “Add Link.”

## Motion and interaction

Motion should make the interface feel responsive, not busy.

| Interaction      | Purpose                       | Direction                                                   |
| ---------------- | ----------------------------- | ----------------------------------------------------------- |
| Card press       | Immediate tactile feedback    | Scale to about 0.98, 100–140 ms                             |
| Card to detail   | Preserve spatial context      | Interruptible spring, subtle or no bounce                   |
| Detail dismissal | Return to origin              | Slightly faster than entry                                  |
| Density change   | Explain layout reorganization | Short spring; animate position and opacity                  |
| Sheet            | Platform familiarity          | Use the native system transition                            |
| Filter or sort   | Fast state feedback           | Avoid decorative entrance sequences                         |
| Archive/restore  | Confirm state change          | Brief opacity/position transition plus visible label change |

Rules:

- Do not animate from scale zero.
- Do not add continuous floating, pulsing, or parallax to save cards.
- Keep routine UI transitions under 300 ms.
- Prefer springs for interruptible gestures and direct manipulation.
- Press feedback begins immediately; never use an ease-in entrance that makes
  the interface feel late.
- When Reduce Motion is enabled, replace spatial card/detail and density motion
  with a short opacity transition or no animation.
- Haptics, if added later, should confirm meaningful actions such as a completed
  save or density snap—not every tap.

## Accessibility and resilience

- Support Dynamic Type without clipping titles, hiding actions, or fixing card
  heights around one text size.
- At accessibility sizes, allow the grid to collapse toward one column when
  required for readable cards.
- Use real `Button`, `Link`, `Menu`, and `Toggle` controls rather than tap
  gestures for actions.
- Icon-only visuals still need text labels for VoiceOver and Voice Control.
- Reading order follows visual order: source, title, description, tags, state.
- Combine a card into one understandable accessibility element when its internal
  labels do not need separate focus.
- Respect Increase Contrast and Differentiate Without Color.
- Do not communicate archived, selected, overdue, or successful state with color
  alone.
- Decorative stacked planes and shadows are hidden from assistive technology.
- Layout must work in compact iPhone widths, landscape, and larger text without
  reading `UIScreen.main.bounds`.

## Platform behavior

### iOS

iOS defines the primary experience. Use its safe areas, sheet behavior, touch
targets, Dynamic Type, and gesture conventions as the baseline.

### macOS

The current macOS product is MenuBarExtra-only. Preserve the same information
hierarchy and visual language, but adapt layout to pointer input and available
popover width. The middle masonry density uses three columns only when the
container can support readable cards. A full WindowGroup app is outside the
current approved scope.

## Empty, loading, and error states

- Prefer native `ContentUnavailableView` for empty results and empty collections.
- Empty-state copy should explain the next action in one sentence.
- While link metadata loads, show a small native progress indicator near the
  save action; do not introduce a full-screen loader.
- A missing thumbnail is a valid content state, not an error.
- URL errors remain inline in the add sheet and must describe how to recover.

## Implementation guardrails

- Keep visual constants centralized in `FigDesignTokens.swift` or focused token
  types rather than scattering values across views.
- Use SwiftUI colors or asset catalog colors, not UIKit colors.
- Prefer flexible frames and adaptive containers over fixed screen measurements.
- Keep each substantial view in its own Swift file.
- Preserve the existing SwiftData model and public behavior unless an approved
  feature explicitly requires a change.
- Do not add a third-party UI or animation framework without approval.
- No gradients, synthetic thumbnail generation, oEmbed imagery, or SF Symbol
  decoration without a functional reason.

## Design acceptance checklist

A screen or component is ready to ship only when:

- [ ] The visual hierarchy remains clear with images disabled.
- [ ] Every action has a 44 × 44 pt hit area and an accessible label.
- [ ] Dynamic Type does not clip or overlap card content.
- [ ] The no-thumbnail state looks intentional without generated artwork.
- [ ] Selected and semantic states are understandable without color.
- [ ] Reduce Motion removes large spatial transitions.
- [ ] Press feedback is immediate and subtle.
- [ ] Routine transitions complete in under 300 ms.
- [ ] Scrolling content clears the bottom navigation and add action.
- [ ] iOS behavior is manually checked in Simulator or on device.
- [ ] macOS MenuBarExtra remains usable after shared-view changes.

## Open decisions

These choices are intentionally not resolved by this document:

1. Whether the product name shown in the interface is **The Fig** or
   **Consider It Done**.
2. Whether the default heading should remain **The Fig** or become contextual,
   such as **Recent Figs**.
3. Whether dark mode belongs in the first release and, if so, what authored
   palette should replace the current light-only values.
4. Whether haptic feedback should accompany save completion and density snaps.

Until each choice is confirmed, preserve the current product behavior.
