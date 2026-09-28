# The Fig — Product Design Direction

**Status:** Working design source of truth

**Platform priority:** iOS first; macOS remains a MenuBarExtra companion

**Last updated:** 2026-09-28 (dark mode, Figtree, save card anatomy, user
edits, density control removal — see “Confirmed decisions — 2026-09-28”)

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
   Avoid thick outlines, glossy effects, and dramatic perspective. Liquid
   Glass is used only on floating controls: the bottom bar, the add button,
   and controls that sit on top of imagery (see “Save detail”).
4. **Motion explains, then gets out of the way.** Animate card selection,
   density changes, sheets, and direct press feedback. Routine scrolling,
   filtering, and repeated navigation should not perform for the user.
5. **Native behavior, own personality.** Apple's Human Interface Guidelines are
   the UX baseline: SwiftUI behaviors, Dynamic Type, semantic controls, hit
   targets, and accessibility settings. They are not the visual personality.
   Avoid stock-looking UI (default bordered buttons, system alerts and
   confirmation dialogs, blue tint, plain form rows) where a composed,
   editorial treatment fits: serif italic headings, full-bleed imagery,
   circular icon actions, soft pills, and inline states. Visual references
   for this direction: [Branding for Property management platform](https://dribbble.com/shots/27765686-Branding-for-Property-management-platform)
   and the nutrition/stays branding boards Andrei shared on 2026-09-28.
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

The existing light palette is authoritative. The dark palette was drafted
from the 2026-09-28 save card mockup (near-black canvas, charcoal card) and
is **pending visual review on device**. Its values may be tuned, but the
light/dark token structure may not.

Every token has a light and a dark value, and the system appearance picks
between them. Views reference only the token names, never raw values or
`colorScheme` checks.

| Role                 | Token                  | Light            | Dark (draft)     | Use                                        |
| -------------------- | ---------------------- | ---------------- | ---------------- | ------------------------------------------ |
| Canvas               | `figBackground`        | `#F3EDE2`        | `#0A0A0A`        | App and sheet backgrounds                  |
| Primary surface      | `figSurface`           | `#FFFAF2`        | `#1C1C1C`        | Cards, active navigation, elevated panels  |
| Recessed surface     | `figSurfaceMuted`      | `#ECE5D9`        | `#2A2A2A`        | Controls, empty media, inactive navigation |
| Soft surface         | `figSurfaceSoft`       | `#FBF7F0`        | `#232323`        | Stacked card backing and subtle separation |
| Primary text         | `figTextPrimary`       | `#2F332F`        | `#F5F5F5`        | Titles and essential actions               |
| Secondary text       | `figTextSoft`          | `#565B54`        | `#A3A3A3`        | Descriptions and domains                   |
| Muted text           | `figTextMuted`         | `#747870`        | `#8A8A8A`        | Counts, labels, and metadata               |
| Border               | `figBorder`            | `#747870`        | `#8A8A8A`        | Low-opacity outlines and card dividers     |
| Strong border        | `figBorderStrong`      | `#2F332F`        | `#F5F5F5`        | Rare high-contrast separation              |
| Accent (sage)        | `figAccent`            | `#56735D`        | `#8FB097`        | Primary actions, FAB, source pills, toggles |
| Semantic green       | `figSuccess`           | `#5F7D67`        | `#8FB097`        | Success, confirmed, completed states       |
| Semantic green field | `figSuccessBackground` | `#E4EFDA`        | `#1F2A22`        | Success field and selected semantic state  |
| Shadow               | `figShadow`            | `#484030` at 18% | `#000000` at 50% | Elevated cards and focused panels          |

In dark mode, depth comes mainly from the surface stepping up from the canvas
(`#0A0A0A` → `#1C1C1C` → `#2A2A2A`), because shadows barely show on a
near-black canvas. Content on an accent fill uses `figSurface`: cream in light
mode, charcoal in dark mode.

### Color rules

- **Sage green is the accent (since 2026-09-28).** Orange (`#EE9B1A`) is
  retired. `figAccent` is a deeper sage (`#56735D`) than `figSuccess`
  (`#5F7D67`) so that cream text on it passes 4.5:1 (5.04:1; the lighter
  sage measures 4.38:1). The system `AccentColor` uses the same values.
- The accent marks primary actions and identity labels (the source pill). It
  is not a general decoration color; surfaces stay neutral.
- Cards default to the primary surface; a no-image hero card uses
  `figSurfaceMuted`, not a green field.
- Information must never rely on color alone. Pair archive, reminder, selected,
  and success colors with a label, symbol, shape, or checkmark.
- Do not add gradients. Variation comes from content, spacing, and layered
  surfaces.

- Support light and dark mode fully. Every screen, sheet, card, and state must
  be checked in both appearances. Do not auto-invert values or hard-code a
  single appearance.
- Store adaptive tokens as asset catalog color sets (Any + Dark appearance)
  and expose them through `FigDesignTokens.swift`, so existing token names
  stay the same.
- Increase Contrast must remain legible in both appearances.

## Typography

Two bundled typefaces (both SIL Open Font License, license embedded in the
font files):

- **Vollkorn Medium Italic** for headings: screen titles, section titles,
  sheet titles, and save titles on cards, tiles, lists, and detail.
- **Figtree** for everything else: descriptions, labels, controls, metadata,
  and icons.

Both are applied with the normal `.font(...)` modifier through two tokens in
`FigDesignTokens.swift`, and both scale with Dynamic Type through
`relativeTo:`:

- `.font(.heading(.title2))` gives Vollkorn Medium Italic.
- `.font(.text(.callout, weight: .semibold))` gives Figtree.

| Content                 | Token                                   | Treatment                                       |
| ----------------------- | --------------------------------------- | ----------------------------------------------- |
| Screen title            | `.heading(.largeTitle)`                 | One line when possible                          |
| Detail title            | `.heading(.title)`                      | Wraps freely                                    |
| Section or sheet title  | `.heading(.title2)` / `.heading(.title3)` |                                               |
| Card title              | `.heading(.headline)`; hero `.heading(.title2)` | Two lines maximum (hero: three)         |
| Description             | `.text(.subheadline)` / `.text(.body)`  | Regular, relaxed line spacing                   |
| Controls                | `.text(.callout)`                       | Semibold only for the active or primary label   |
| Metadata                | `.text(.footnote)`                      | Regular or medium; never lighter than legible   |

Letter spacing is tightened once for the whole app with
`.tracking(.textTracking)` (−0.2 pt) at the root views, never per view.

Rules:

- Do not use fixed point sizes for normal interface text. A custom font base
  size is allowed only when it scales through `relativeTo:`.
- Headings carry the personality; keep them short. Do not set body copy,
  buttons, or labels in Vollkorn.
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
- Media clips to the card's upper contour. The text region remains calm.
- The source sits in the card footer (see “Save card anatomy”), not on the
  media field.

### Save card anatomy (confirmed 2026-09-28)

From top to bottom:

1. **Media.** The user's custom image if set, otherwise the Open Graph image,
   otherwise the flat `figSurfaceMuted` field. Clipped to the upper contour.
2. **Title.** Card title style, bold, at most two lines.
3. **Description.** Secondary text, at most two lines. Hidden when empty.
4. **Tags.** Up to three tag pills plus `+N`, using the existing card tag
   rendering. Hidden when there are no tags.
5. **Divider.** A hairline in `figBorder` at low opacity, inset to the
   content margins.
6. **Source footer.** The source pill, then a circular **Open Link** button
   (↗, `arrow.up.right`) on the trailing edge. The link itself is not shown,
   because Open Link covers it.

Source footer rules:

- **Source pill** (`SaveSourcePill`, shared by cards and detail): one sage
  capsule (`figAccent` fill, `figSurface` text) with the platform name in
  `.text(.footnote, weight: .semibold)`. Names: Instagram, X, YouTube, Reddit,
  Facebook, Web. It shows one label only (no separate mark), and it looks the
  same size everywhere.
- The Open Link button has a visible diameter of about 40 pt, a 44 × 44 pt hit
  area, `figSurfaceMuted` fill, and the accessibility label “Open Link”. It
  opens the link directly. Tapping anywhere else on the card still opens the
  save detail.
- Title and description show the user's edited text when present (see “Save
  detail”).

### Hero save card

The supplied “Recent Figs” mockup establishes the preferred hero composition:

1. a large tonal media field, using real imagery or `figSurfaceMuted`;
2. title, short description, and tags below the media;
3. the source footer from “Save card anatomy” (superseding the earlier
   top-trailing source mark);
4. a single soft card shadow against the canvas.

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

- Image priority: **user-added image → Open Graph image → no-image field**.
- Users may add or replace a save's image at any time, from the save detail.
  The Open Graph image is kept separately. Removing the custom image brings
  the Open Graph image back.
- Preserve a useful focal area with `scaledToFill` and predictable clipping.
- Never fabricate a fallback thumbnail, illustration, or 3D object. A
  user-chosen photo is real content, not a fallback.
- The no-image state is a flat recessed field with the source mark and enough
  contrast to remain intentional.
- Images are decorative to VoiceOver when the title already communicates the
  saved item; otherwise provide a meaningful accessibility label.

## Card information hierarchy

Show only what helps recognition:

1. Image or tonal media field
2. Title
3. Short description, when useful
4. Up to three tags
5. Source footer: platform, domain, Open Link

Tags use compact light-surface pills with text such as `#design`, rather than a
row of uncontained words. If more than three tags exist, show `+N` instead of
wrapping the card into an unpredictable height.

Full URLs belong in list and detail contexts. A grid card shows the domain
only, in the source footer.

## Screen composition

### The Fig

- The header has one strong title and one short contextual line.
- Sort, grouping, and archive controls sit below the header as one quiet
  control region; they should not compete with the first card. There is **no
  visible density picker**. Pinch is the density control (see “Density
  levels”).
- The content area begins close enough to the controls to read as the result of
  those choices.
- Scrolling content must clear both the bottom navigation and the add button.

The supplied mockup uses **Recent Figs** as the screen title. This is a good
contextual title when the active sort is Recent, but implementation should not
replace the current **The Fig** title until the naming rule for Importance,
Reminder, and Archived states is confirmed.

### Density levels

The three density levels represent different jobs, not just three card sizes.

| Density      | Job                    | Card treatment                                                  |
| ------------ | ---------------------- | --------------------------------------------------------------- |
| Organization | Understand the library | Mixed-height tiles or meaningful source/collection stacks       |
| Grid         | Browse visually        | Two-column iOS masonry; image-forward cards                     |
| Carousel     | Focus on one save      | Front card with upcoming saves stacked behind; swipe left/right |

Carousel layout (2026-09-28): the carousel does not scroll. The card fills the
space between the header controls and the bottom bar (capped at 640 pt), so
every card has the same size and position. The hero media flexes and crops to
fill (`SaveThumbnail(fillsAvailableHeight:)`), and the text region keeps its
natural height. The bottom bar's measured height is reserved below it; scroll
layouts reserve the same height with `contentMargins`.

Organization tiles hug their content (no fixed minimum heights) and use the
same full-name source pill as cards.

Pinch transitions snap between these three states. Avoid continuous card scaling,
which makes text and hit targets feel unstable.

The visible density picker was removed on 2026-09-28, so pinch is the only
on-screen control. For people who cannot pinch:

- The saves area exposes two named accessibility actions, **Closer layout**
  and **Wider layout**, for VoiceOver, Voice Control, and Switch Control.
- On macOS and on iPad with a hardware keyboard, **⌘ +** and **⌘ −** step
  through the densities.
- A future onboarding flow will teach the pinch gesture (tracked as a
  separate deferred feature). Until then, nothing on screen announces it.

### Collections

Collections should feel like physical stacks of saves, not folders. Use the
stacked-card treatment, a collection name, and a link count. Avoid folder icons
unless future research shows users cannot understand the metaphor.

### Add-link sheet

- Use a native medium sheet on iOS.
- Focus the URL field when appropriate without forcing the keyboard after every
  return to the app.
- Make **Save Link** the only accent-filled action.
- Keep **Paste** secondary.
- Validation appears next to the field and stays until corrected.
- Successful save dismisses the sheet without moving the user to another tab.

### Save detail

A focused card over a scrim, composed rather than a stack of system controls:

1. **Media.** Full-bleed image across the top (240 pt; 96 pt flat field when
   there is no image). The source pill (same component as on cards) sits
   bottom left, so it never reads as a second close button. A glass close
   button floats top right.
2. **Meta line.** “Saved Sep 21 at 5:08 AM” (date and time) in muted Figtree.
3. **Title** in `.heading(.title)`, then the **description** in Figtree body,
   then tags. The URL is not shown; Open Link covers it.
4. **Reminder row.** A soft `figSurfaceMuted` panel with a bell, “Remind me”,
   and a toggle. When on, date and time pickers appear inside the panel as two
   pills with no inline label; they wrap onto two lines when space is short.
5. **Action row.** Quiet 44 pt circular icon buttons on the left: Edit
   (pencil), Add to Collection (icon only;
   a menu of collections), Archive/Restore, and Remove (red trash). On the
   right, the one filled action: a 56 pt sage **Open Link** circle with ↗.
   Every icon button has an accessibility label.

Rules:

- The selected card should visually expand into a focused surface when Reduce
  Motion is off.
- The card hugs its content and scrolls only when taller than the screen.
- **Edit mode** (pencil) shows only the editable fields: title, description,
  and image actions, plus **Cancel** and **Save**. Tags, reminder, the action
  row, Open Link, and the close button are hidden. Tapping the scrim or
  dragging down does not dismiss while editing.
- **Nothing is written until Save.** Title, description, and image are
  drafts; the header image previews the draft. Cancel discards them. The
  description is filled in automatically from Open Graph when a link is
  saved. An empty title is not saved. Clearing the description leaves it
  empty; it is not re-fetched.
- **Image actions:** Add Image / Replace Image (system photo picker) and **Use
  Original Image**, which drops the custom image and brings back the link's
  Open Graph image. It reads “Remove Image” when the link had none.
- **Remove is confirmed inline.** Tapping the trash replaces the action row
  with “Remove this save?” plus Cancel and a red Remove, in place. There is no
  system confirmation dialog, and there is only one Remove control on screen
  at a time.
- Opening detail records the item as viewed but never hides or archives it.

### Bottom navigation and add action

- Keep exactly three destinations: **Saves**, **Collections**, and **Search** (confirmed 2026-09-07).
- Keep the add action separate and thumb reachable.
- Navigation labels remain visible; do not replace both destinations with
  unexplained icon-only circles from the visual references.
- The active destination uses a surface change plus text emphasis, not color
  alone.
- The add button may be circular, but its accessibility label must be “Add Link.”
- There is no background strip behind the bar. The destination group sits on
  Liquid Glass (`glassEffect`, interactive), and the add button is sage-
  tinted glass. Both share a `GlassEffectContainer`. The system tab bar is
  hidden inside each tab.

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
- [ ] The screen is checked in both light and dark appearance.
- [ ] Headings use `.heading(...)`, all other text uses `.text(...)`, and both
      scale with Dynamic Type.
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
3. ~~Whether dark mode belongs in the first release.~~ Resolved 2026-09-28:
   yes. The draft dark palette is in “Color system”, pending device review.
4. Whether haptic feedback should accompany save completion and density snaps.
5. What the future onboarding flow contains beyond teaching pinch-to-change
   layout.

Until each choice is confirmed, preserve the current product behavior.

## Confirmed redesign decisions — 2026-09-07

The redesign now precedes Collection/Tag relationship work. Implement entries
one at a time. The bottom navigation uses TabView with Saves (`bookmark`),
Collections (`square.stack`), and Search (`magnifyingglass`), and a separate
right-hand Add Link action. The view wrapping TabView owns the shared namespace,
selected save, and SaveDetailOverlay; card matched-geometry IDs and tags stay
unchanged. Tab changes use 0.2-second ease-in-out, with no animation for Reduce
Motion. Keep existing detail and density springs; do not replace detail with a
NavigationStack push.

Closest density is now a swipe-only card carousel with a front card and upcoming
cards behind. This explicitly overrides the earlier full-card list direction.
Middle density retains the current masonry column count; farthest retains the
existing OrganizationGrid and OrganizationTileLayout with sort/group and source
stacks. Preserve exactly three pinch states. Carousel backing cards are approved;
use neutral surfaces and reserve green for semantic states. Known accepted
accessibility debt: no previous/next buttons for carousel paging. Preserve existing
card tag rendering.

Search matches active saves locally by title, URL, description, and tag name and
opens the shared detail overlay. Notifications contains only the two labeled list
sections Recently saved and Upcoming reminders, without extra section buttons.
Settings/model work follows the redesign in separate entries. Optional deletedAt
and profile name/image storage are not part of this UI pass; UserDefaults profile
storage remains a proposal requiring confirmation, and CloudKit sync is deferred.

## Confirmed decisions — 2026-09-28

Confirmed by Andrei in the 2026-09-28 session, from the annotated save card
mockup. These override conflicting text elsewhere in this document.

1. **Dark mode is in scope.** The light palette is unchanged. The dark palette
   is drafted from the mockup and needs a device review before it is final.
2. **Typography** (revised later on 2026-09-28): Vollkorn Medium Italic for
   headings and Figtree for body text. The original note read: Figtree with
   slightly tightened tracking, still scaled
   through Dynamic Type. This replaces “use the system font”.
3. **The save card follows “Save card anatomy”.** The source footer (platform
   mark, platform name, domain, Open Link button) replaces the top-trailing
   source mark. Tags stay on the card because earlier decisions preserved the
   existing tag rendering. The mockup omits them; confirm or remove them during
   the card entry.
4. **Users can edit a save's title and description.** The description is
   still auto-filled from Open Graph when the link is saved.
5. **Users can add their own image at any time.** It is stored separately from
   the Open Graph image, which is restored when the custom image is removed.
6. **An X/Twitter source is added** (hosts `x.com`, `twitter.com`, `t.co`),
   shown as “X”.
7. **The visible density picker is removed.** Pinch remains, backed by named
   accessibility actions and ⌘ +/− keyboard shortcuts.
8. **Onboarding is deferred** to a separate feature. It will at least teach
   pinch-to-change layout. Its content is an open decision.

## Confirmed decisions — 2026-09-28 (review round)

After Andrei's device testing:

1. Headings use Vollkorn Medium Italic and body text uses Figtree, both through
   the plain `.font(...)` modifier (`.heading(_:)`, `.text(_:weight:)`).
2. The bottom bar file/type is `BottomBar`. It has no background strip; it
   uses Liquid Glass for the destination group and a tinted-glass add button.
3. Cards and detail no longer show the link text; Open Link (↗) covers it.
4. Add to Collection is icon-only.
5. The detail card is redesigned (see “Save detail”), with inline delete
   confirmation replacing the system confirmation dialog.
6. Apple HIG is the UX baseline, not the visual personality (principle 5).
7. Avoid renaming existing, generally named functions and variables when
   restyling.

## Confirmed decisions — 2026-09-28 (accent and editing)

1. Sage green replaces orange as the accent everywhere, from now on
   (`figAccent` = `#56735D` / `#8FB097`; system `AccentColor` matches). Green is
   no longer reserved for semantic states only.
2. The source is shown as one sage pill (`SaveSourcePill`) with the same text
   size on cards and in detail. It replaces the doubled mark and name.
3. Edits to title, description, and image are drafts until Save. Edit mode
   hides everything except the editable fields and Cancel/Save. Use Original
   Image stays.

## Confirmed decisions — 2026-09-28 (layouts)

1. The Organization layout uses the full-name source pill, and its tiles have
   no fixed minimum height (no empty space under titles). Emphasized tiles
   still allow four title lines.
2. The carousel fits the screen without scrolling, and every card keeps the
   same frame regardless of image aspect ratio.
