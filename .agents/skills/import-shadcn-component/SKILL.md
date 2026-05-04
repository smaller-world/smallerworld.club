---
name: import-shadcn-component
description: Import, convert, or update shadcn/ui components into Rails Phlex + Tailwind CSS. Use when asked to import, add, convert, port, sync, or update a shadcn component. Also use when updating components to prevent style drift after shadcn TSX changes.
---

# Import Shadcn Component

Convert shadcn/ui TSX components into Rails Phlex `.rb` components + Tailwind `.css` files.

## Workflow

1. **Pull from registry**: `mise x -- bunx shadcn@latest add <name>` → lands in `app/components/shadcn/<name>.tsx`
2. **Read the TSX** and identify component type (simple, input-like, or JS-heavy)
3. **Read `app/components/base.rb`** for current base class API
4. **Read an existing component pair** (e.g. `button.rb` + `buttons.css`) to confirm patterns
5. **Generate CSS** at `app/assets/stylesheets/<name_plural>.css`
6. **Generate Ruby** at `app/components/<name>.rb`
7. **Add CSS import** to `app/assets/stylesheets/application.css`
8. **Verify** CSS selectors match Ruby classes and data attributes

## Update Workflow

When syncing after shadcn TSX changes:

1. **Diff the TSX** against existing CSS
2. **Update CSS** — sync added/removed/changed Tailwind classes
3. **Update Ruby** if needed — new variants, sub-components, data attributes
4. **Verify** selectors still match

## Component Types

### Simple Components

Examples: Button, Badge, Label, Separator, Card

Straightforward conversion — CSS closely mimics shadcn, Ruby is minimal.

### Input-like Components

Examples: Textarea, FileInput, PhoneNumberInput

Inherit from `Components::Input` to get `form:` and `field:` param handling for Rails form builder integration. See `textarea.rb` for the pattern.

### JS-heavy Components

Examples: Dialog, Combobox, DropdownMenu, Select

These require careful research and may diverge from shadcn markup:

1. **Read shadcn TSX** — understand visual intent and CSS classes
2. **Look up shadcn docs** (web search) — understand intended behavior
3. **Inspect BaseUI source** (`node_modules/@base-ui/react/...`) — understand what React primitives shadcn uses and what data attributes they expose (e.g., `data-open`, `data-closed`)
4. **Read Tailwind Plus Elements docs** ([references/tailwind-plus-elements.md](references/tailwind-plus-elements.md)) — find equivalent element, understand its markup and data attributes
5. **Reconcile differences** — Tailwind Plus Elements may use different data attributes than BaseUI; adapt CSS transitions accordingly
6. **Brainstorm with user** — propose approach before implementing

For JS-heavy components, the goal is to visually match shadcn while using Tailwind Plus Elements for interactivity. Markup may need to differ. Use Stimulus controllers to bridge feature gaps between Tailwind Plus Elements and BaseUI.

## CSS Pattern

Use **class selectors** (not `[data-slot]`) as primary selectors. Variants use data-attribute selectors.

```css
@layer components {
  .button {
    @apply inline-flex items-center ...;

    &[data-variant="default"] { @apply bg-primary ...; }
    &[data-variant="outline"] { @apply border-border ...; }
    &[data-size="default"] { @apply h-9 ...; }
    &[data-size="sm"] { @apply h-8 ...; }
  }

  /* Sub-component slots — flat, not nested */
  .card-header { @apply grid auto-rows-min ...; }
  .card-content { @apply px-6 ...; }
}
```

### Key CSS Rules

- **Class selectors** (`.button`, `.input`) as primary selectors
- **Data attributes for variants** (`&[data-variant="..."]`, `&[data-size="..."]`)
- **`data-slot` is kept** for `has-[data-slot=...]:` selectors but not as primary selector
- **Mimic shadcn CSS** as closely as possible for visual fidelity
- **Adapt transitions** for Tailwind Plus Elements data attributes (`data-closed`, `data-enter`, `data-leave`) instead of BaseUI attributes when needed
- CSS file name is **pluralized** (`button.rb` → `buttons.css`)

## Ruby Pattern

`Components::Base` provides:
- `root_element(tag, **attributes, &content)` — renders root, merges caller overrides via `mix`
- `mix(defaults, overrides)` — deep-merges attribute hashes

```ruby
# typed: true
# frozen_string_literal: true

class Components::Button < Components::Base
  sig { params(variant: Symbol, size: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, size: :default, **attributes)
    super(**attributes)
    @variant = variant
    @size = size
  end

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :button,
      type: "button",
      class: "button group/button",
      data: { slot: "button", variant: @variant, size: @size },
      &content
    )
  end
end
```

### Compound Sub-components

Use a private `slot` helper. TSX sub-functions become public methods with prefix stripped (`CardHeader` → `header`).

```ruby
def header(**attributes, &content)
  slot("card-header", **attributes, &content)
end

private

def slot(name, element: :div, **attributes, &content)
  send(element, **mix({ class: name, data: { slot: name } }, attributes), &content)
end
```

### Custom HTML Elements

For Tailwind Plus Elements, register them with Phlex:

```ruby
register_element :el_dialog           # renders <el-dialog>
register_element :el_dialog_backdrop  # renders <el-dialog-backdrop>
register_element :el_autocomplete     # renders <el-autocomplete>
```

### Key Ruby Rules

- **`class:` contains the CSS class** (`.button`) plus `group/<name>` for Tailwind group selectors
- **`data: { slot: }` is kept** for consistency with shadcn and `has-[data-slot=...]:` selectors
- TSX `defaultVariants` → Ruby `initialize` default param values
- TSX `asChild`/`Slot.Root` → dropped (not needed in Phlex)
- Use Sorbet `sig` annotations

## Translation Reference

| TSX Concept | CSS | Ruby |
|---|---|---|
| `cva()` base | `.class-name { @apply ...; }` | `class: "class-name"` |
| `cva()` variant | `&[data-variant="value"]` | `data: { variant: @variant }` |
| `defaultVariants` | — | `initialize` defaults |
| `data-slot="X"` | `.X` (primary), `[data-slot="X"]` (for `has-`) | `class: "X", data: { slot: "X" }` |
| Sub-function `CardHeader` | `.card-header` | `def header(...)` |
| `asChild` / `Slot.Root` | — | dropped |

## Resources

- **Tailwind Plus Elements**: [references/tailwind-plus-elements.md](references/tailwind-plus-elements.md)
- **BaseUI source**: `node_modules/@base-ui/react/`
- **Existing components**: `app/components/*.rb` + `app/assets/stylesheets/*.css`
