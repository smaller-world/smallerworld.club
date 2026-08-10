# Design

The visual language of smaller world, for anyone (human or agent) writing UI
here.

Read this before adding a component or a page. The house style is opinionated
and already fully expressed in code — **the job is almost never to invent, it's
to match.** If a new screen feels like it needs a new token, a new font, or a
new color, that is a signal to look harder for the existing pattern first.

## The one-line summary

A warm, quiet, mobile-first personal space. Off-white paper and soft charcoal,
generous rounding, no chrome, no brand color. All the personality lives in the
_copy_ and in a handful of small handmade touches — not in the palette.

## Tokens live in CSS, not in Ruby

`app/assets/stylesheets/theme.css` is the single source of truth. Everything is
shadcn-shaped CSS variables consumed through Tailwind v4's `@theme inline`.

Never hardcode a color. Use the semantic token (`bg-muted`,
`text-muted-foreground`, `border-border`, `text-destructive`). If you need an
in-between shade, mix from a token rather than introducing a literal:

```css
hover: bg-[color-mix(in_oklch, var(--secondary), var(--foreground) _5%)];
```

### Palette

shadcn `base-luma` style on the **olive** base color, in OKLCH. It is a
near-neutral with a faint warm/olive cast (hue ~107) — never a pure gray.

- Light: `--background` pure white, `--foreground` near-black olive.
- Dark: `--background` the same near-black olive, borders as
  `oklch(1 0 0 / 10%)`.
- **There is no brand accent color.** `--primary` is just near-black (light) /
  near-white (dark). Emphasis comes from weight, size, and fill — not hue.
- `--destructive` (red) is the _only_ saturated color in the system, and it is
  reserved for genuine danger and reports. Don't reach for it for emphasis.
- Chart tokens are a monochrome ramp, consistent with the above.

### Dark mode

Dark mode is **`prefers-color-scheme` only** — there is no theme toggle and no
`data-theme` attribute. The `dark:` variant is redefined in `application.css`:

```css
@custom-variant dark {
  @media (prefers-color-scheme: dark) {
    :where(body:not(.no-dark)) & {
      @slot;
    }
  }
}
```

`body.no-dark` opts a page out entirely. Both themes must always work; never
ship a `dark:`-only or light-only screen.

## Typography

Three faces, all from Google Fonts, loaded in `Components::AppLayout`:

| Token            | Family         | Used for                                    |
| ---------------- | -------------- | ------------------------------------------- |
| `--font-heading` | **Figtree**    | headings, buttons, card titles, item titles |
| `--font-sans`    | **Manrope**    | body, the `html` default                    |
| `--font-cursive` | **Single Day** | hint alerts only                            |

`font-heading` is applied automatically to `h1`–`h6` (with `font-semibold`) and
to `.button`. When you want a piece of UI to read as a title without being a
heading element, add `font-heading` explicitly — this is common on `item-title`
and `card-title`.

`Single Day` is the app's one piece of handwriting. It appears in exactly one
place, `Components::HintAlert` — a dashed-border note with the app logo beside
it, italic, cursive, tight leading. It reads as a sticky note from the app's
author. Use `HintAlert` for those asides; don't reach for `font-cursive`
directly.

Scale is restrained: `h1` is `text-3xl`, and most page-level headings in
practice are `text-xl`/`text-2xl`. Body text is `text-sm` far more often than
`text-base`.

## Shape and depth

- `--radius: 0.625rem`, with a multiplier ramp (`--radius-sm` … `--radius-4xl`).
  Things are **very** rounded: cards `rounded-xl`, items and alerts
  `rounded-2xl`, and **all buttons are `rounded-4xl`** — full pill shape. This
  is the single most recognizable trait of the UI.
- `--radius-world-icon: calc(1 / 4.5 * 100%)` is a bespoke squircle-ish ratio
  for world icons, so they scale proportionally at every size.
- Depth is almost absent. Cards use `shadow-xs` + `ring-1 ring-foreground/10`,
  not a drop shadow. The one exception is `.world-icon`, which gets a soft
  colored glow via a `--shadow-spread` custom property that scales with icon
  size.
- **Dashed borders mean "meta"** — empty states (`.empty`), hint alerts, and
  reported post cards all use `border-dashed`. It reads as "this isn't content."

## Component architecture

UI is **Phlex components in Ruby**, not ERB. Two layers:

1. `app/components/*.rb` — Phlex classes under `Components::`, subclassing
   `Components::Base`. They emit semantic class names and `data-` attributes.
2. `app/assets/stylesheets/*.css` — one file per component, holding the actual
   Tailwind via `@apply`, imported in order by `application.css`.

Variants and sizes are **`data-` attributes styled in CSS**, never conditional
class strings in Ruby:

```css
.button {
  &[data-variant="ghost"] {
    @apply hover:bg-muted …;
  }
  &[data-size="xl"] {
    @apply h-12 gap-2 px-5 …;
  }
}
```

Composition is done with `data-slot` on children (`data-slot="card-header"`,
`item-media`, `alert-description"`), which lets a parent restyle its slots
contextually — see `.post-card` in `posts.css` overriding
`[data-slot="card-title"]`.

Cascade layers are declared up front and matter:

```css
@layer theme, base, base-components, components, utilities;
```

`base-components` holds the imported shadcn primitives (button, card, item,
alert, field…). `components` holds smaller-world-specific classes (`.post-card`,
`.world-icon`, `.world-action-button`). App styles therefore always win over
primitives without `!important`.

### Adding a component

Prefer importing from shadcn and converting — there is a dedicated skill for
this at `.agents/skills/import-shadcn-component/`, and `components.json` is
configured (style `base-luma`, base color `olive`, icon library `hugeicons`).
Follow it so styles don't drift from upstream.

## Icons

HugeIcons via `phlex-icons`, called as `Icon("huge/notification-01")`. Buttons
size their own icons (`[&_svg:not([class*='size-'])]:size-4`), so don't set a
size unless you're deliberately overriding.

Mark leading/trailing icons with `data: { icon: :inline_start }` / `:inline_end`
— buttons and fields use `has-data-[icon=…]` to tighten padding on that side
automatically.

## Layout

Mobile-first and narrow. There is no sidebar, no nav bar, no breadcrumbs.

- `.app-layout` — `flex min-h-dvh flex-col` on `<body>`, with
  `padding-top/bottom: env(safe-area-inset-*)`.
- `.page-container` — `mx-auto w-full max-w-2xl self-center p-4`. Most pages
  narrow it further to `max-w-lg`.
- The header is a single centered dropdown trigger showing the logo and the
  wordmark — that's the entire global navigation.
- Vertical rhythm is `flex flex-col gap-*` (usually `gap-4`/`gap-6`), not
  margins.
- `overflow-x: clip` on `html` (deliberately not `hidden`, so the document
  doesn't become a scroll container).

### The "back to all" pattern

Detail pages don't rely on browser back. They render an explicit
`button_back_to(label, target, variant: :secondary)` at the top, which produces
a pill button reading **"back to <label>"** with a `huge/link-backward` icon.
Any new detail page should have one. Note it's usually wrapped in
`hidden: hotwire_native_app?`, since the native shell provides its own back.

## Native app awareness

The same HTML serves web and a Hotwire Native iOS shell. `hotwire_native.css`
defines custom variants — `native:`, `not-native:`, `ios:`, `ios-app-on-mac:`,
and `with-*-bridge:` — driven by `data-hotwire-native-platform` on `<html>`.

In Ruby, use the `hotwire_native_app?` helper (available in every component).
The app header is skipped entirely in native. When a button should become a
native UI element, attach the button bridge:

```ruby
data: {
  controller: "button-bridge",
  bridge_ios_image: "person.crop.circle.fill.badge.plus",
  bridge_android_image: "person_add",
}
```

## Motion

A full easing scale is defined in `theme.css` (`--ease-out-quad`,
`--ease-out-back`, `--ease-out-expo`, …) — use those tokens rather than
`ease-in-out`.

Motion is small and functional, not decorative:

- Buttons translate down 1px on press
  (`active:not-aria-[haspopup]:translate-y-px`).
- Transitions are short: `duration-100`/`duration-200`.
- The Turbo progress bar is a 0.5px transparent→`primary` gradient.
- Loading states blur and dim in place (`.loading` + `backdrop-blur-[2px]`)
  rather than swapping in a spinner.
- Confetti is available app-wide via a fixed canvas in the layout — the one
  intentionally joyful flourish, for genuine milestones.

Skeletons (`skeletons.css`) and a shimmer plugin exist; prefer them over
spinners for content that's arriving.

## Voice

**All UI copy is lowercase.** Headings, buttons, labels, flash messages, empty
states, page titles — everything. This is the strongest single signal of the
brand and it is applied without exception.

It's warm, small, and personal, often with an em-dash aside or an exclamation
mark:

- "hi. welcome to smaller world!"
- "give a key to a new friend"
- "your report has been submitted and will be reviewed by our team."
- "so ya wanna build smaller worlds, is that right?"

Do not use title case. Do not use enterprise phrasing ("Manage Settings",
"Submit"). Prefer a verb phrase that says what actually happens ("give a key to
a new friend", "get the ios app!").

The domain vocabulary is deliberately non-technical — **worlds**, **keys**,
**friends**, **posts** — and copy should use those words, never the underlying
model names where they differ.

## Quick checklist

- [ ] Copy is entirely lowercase, warm, and uses domain words.
- [ ] Colors come from semantic tokens; no literal hex/oklch.
- [ ] Buttons are pills; cards/items are `rounded-xl`/`rounded-2xl`.
- [ ] Variants are `data-` attributes styled in CSS, not class strings in Ruby.
- [ ] `font-heading` on anything that reads as a title.
- [ ] Works in both light and dark (`prefers-color-scheme`).
- [ ] Narrow container, `flex flex-col gap-*` rhythm, safe-area aware.
- [ ] Detail pages have a `button_back_to`.
- [ ] Considered `hotwire_native_app?`.
