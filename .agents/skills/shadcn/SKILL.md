---
name: shadcn
description: Use when the user asks to import, add, update, convert, or sync a shadcn component in the Rails Phlex + CSS architecture. Triggers on "import the badge component", "add the input component", "convert separator to Phlex", "update the button from shadcn", "sync card.tsx changes to CSS", "update shadcn components", etc.
---

# Shadcn

Import or update shadcn/ui components — pull TSX from the registry, then convert/sync into Rails Phlex `.rb` components + Tailwind `.css` files.

## Workflow

1. **Pull from registry**: `mise x -- bunx shadcn@latest add <name>` — lands TSX in `app/components/shadcn/<name>.tsx`
2. **Read the TSX** source and identify component type (simple vs compound) and variants
3. **Read `app/components/base.rb`** for current base class API
4. **Read an existing component pair** (e.g. `button.rb` + `buttons.css`) to confirm patterns
5. **Generate CSS** — extract Tailwind classes into `app/assets/stylesheets/<name_plural>.css`
6. **Generate Ruby** — create Phlex component at `app/components/<name>.rb`
7. **Add CSS import** — add `@import "./<name_plural>.css";` to `app/assets/stylesheets/application.css`
8. **Verify** consistency between CSS selectors and Ruby data attributes

## Update Workflow

When a component's TSX source in `app/components/shadcn/` has changed (e.g. after `mise x -- bunx shadcn@latest add <name>` to pull registry updates):

1. **Diff the TSX** — compare `app/components/shadcn/<name>.tsx` against the existing CSS in `app/assets/stylesheets/<name_plural>.css`
2. **Update the CSS** — sync any added/removed/changed Tailwind classes, variant selectors, or sub-component slots
3. **Update the Ruby** if needed — e.g. new variants, new sub-components, changed data attributes
4. **Verify** CSS selectors still match Ruby data attributes

## Locations

| What | Where |
|---|---|
| TSX source (pulled from registry) | `app/components/shadcn/<name>.tsx` |
| Ruby component | `app/components/<name>.rb` |
| CSS file | `app/assets/stylesheets/<name_plural>.css` |
| Registry config | `components.json` |

## Component Types

**Simple** (e.g. Button, Label): Single element, variants via data-attribute CSS selectors.

**Compound** (e.g. Card, Field): Root element + sub-components as instance methods.

## CSS Pattern

All styles use flat `[data-slot="..."]` selectors inside `@layer components`. Variants use data-attribute selectors, not BEM.

```css
@layer components {
  [data-slot="<name>"] {
    @apply <base classes>;
    &[data-variant="default"] { @apply <classes>; }
    &[data-size="sm"] { @apply <classes>; }
  }

  /* Sub-component slots — flat, not nested */
  [data-slot="<name>-<part>"] { @apply <classes>; }
}
```

## Ruby Pattern

`Components::Base` provides:
- `root_element(default_tag, **attributes, &content)` — renders root, merging caller overrides via `mix`
- `mix(defaults, overrides)` — deep-merges attribute hashes (class strings concatenated, data hashes merged)

```ruby
# typed: true
# frozen_string_literal: true

class Components::<Name> < Components::Base
  sig { params(variant: Symbol, size: Symbol, attributes: T.untyped).void }
  def initialize(variant: :default, size: :default, **attributes)
    super(**attributes)
    @variant = variant
    @size = size
  end

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(
      :<tag>,
      class: "group/<name>",
      data: { slot: "<name>", variant: @variant, size: @size },
      &content
    )
  end
end
```

### Compound sub-components

Use a private `slot` helper. Each TSX sub-function becomes a public instance method with the prefix stripped (`CardHeader` → `header`).

```ruby
sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
def header(**attributes, &content)
  slot("card-header", **attributes, &content)
end

private

sig do
  params(slot: String, element: Symbol, attributes: T.untyped, content: T.nilable(T.proc.void)).void
end
def slot(slot, element: :div, **attributes, &content)
  send(element, **mix({ data: { slot: } }, **attributes), &content)
end
```

For sub-components wrapping another Phlex component (e.g. `FieldLabel` renders `<Label>`):

```ruby
def label(**attributes, &content)
  render Components::Label.new(**mix({ data: { slot: "field-label" } }, **attributes), &content)
end
```

## Key Rules

- **All Tailwind utilities go in CSS**, never in Ruby — except `group/<name>` classes needed for Tailwind group selectors
- **Variants use data-attribute selectors** matching the TSX `data-*` attributes
- TSX `cva()` base → CSS `@apply` on `[data-slot]`; variant entries → `&[data-<prop>="<value>"]`
- TSX `defaultVariants` → Ruby `initialize` default param values
- TSX `asChild`/`Slot.Root` → dropped (not needed in Phlex)
- CSS file name is pluralized (`button.rb` → `buttons.css`)
- Match HTML elements from TSX (not everything is a `<div>`)

## Translating React Logic

| React Pattern | Ruby Equivalent |
|---|---|
| Conditional `null` return | `return if condition` |
| `useMemo` with derived data | Compute inline |
| `children` prop | Block parameter `&content` |
| Array of error objects | Splat strings or simple array |
| `{cond && <El/>}` | `if`/`unless` in method body |

For detailed conversion rules and examples, see [references/conversion-rules.md](references/conversion-rules.md).
