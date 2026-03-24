---
name: import-shadcn-component
description: Convert a shadcn/ui React TSX component into a Rails Phlex `.rb` component + Tailwind `.css` file. Use when the user asks to import, convert, port, or add a shadcn component, or when referencing a TSX source from the Vite preset project. Triggers on requests like "import the badge component", "convert separator.tsx", "add the input component", etc.
---

# Import Shadcn Component

Convert a shadcn/ui TSX component from the Vite preset source into the Rails Phlex + Tailwind CSS architecture used in this project.

## Source and Target Locations

- **TSX source**: `vendor/javascript/shadcn-vite-preset/src/components/ui/<name>.tsx`
- **Ruby target**: `app/components/<name>.rb`
- **CSS target**: `app/assets/stylesheets/<name_plural>.css`

## Conversion Workflow

1. Read the TSX source file
2. Read `app/components/base.rb` for the current base class API
3. Read an existing component pair (e.g. `button.rb` + `buttons.css` or `card.rb` + `cards.css`) to confirm the current patterns in use
4. Identify the component type (simple vs compound) and its variants
5. Generate the CSS file — extract all Tailwind classes from TSX into `@layer components` rules
6. Generate the Ruby file — create the Phlex component class
7. Add `@import "./<name_plural>.css";` to `app/assets/stylesheets/application.css`
8. Verify consistency between CSS selectors and Ruby data attributes

For detailed conversion rules and examples, see [references/conversion-rules.md](references/conversion-rules.md).

## Component Types

**Simple** (like Button): Single element, variants via data-attribute CSS selectors, only `view_template` needed.

**Compound** (like Card, Field): Root element + sub-components. Root uses `view_template`; sub-components become instance methods.

## Quick Reference

### CSS Pattern

All styles use flat `[data-slot="..."]` selectors. Variants use data-attribute selectors (`&[data-variant="..."]`), not BEM modifier classes.

```css
@layer components {
  /* Root element */
  [data-slot="<name>"] {
    @apply <root tailwind classes>;

    /* Variants via data attributes */
    &[data-variant="default"] { @apply <classes>; }
    &[data-variant="outline"] { @apply <classes>; }

    /* Sizes via data attributes */
    &[data-size="sm"] { @apply <classes>; }
    &[data-size="default"] { @apply <classes>; }
  }

  /* Sub-component slots (compound components) — flat, not nested */
  [data-slot="<name>-<part>"] { @apply <classes>; }
}
```

### Ruby Pattern

The `root_component` helper (from `Components::Base`) handles merging `class:` and `data:` from both the component definition and caller overrides. There is no `root_class` helper — pass `class:` directly to `root_component`.

```ruby
# typed: true
# frozen_string_literal: true

class Components::<Name> < Components::Base
  sig { params(variant: Symbol, size: Symbol, options: T.untyped).void }
  def initialize(variant: :default, size: :default, **options)
    super(**options)
    @variant = variant
    @size = size
  end

  sig { override.params(block: T.proc.bind(T.self_type).void).void }
  def view_template(&block)
    root_component(
      :<tag>,
      class: "group/<name>",
      data: { slot: "<name>", variant: @variant, size: @size },
      &block
    )
  end
end
```

## Key Rules

- **All Tailwind utilities go in CSS**, never in Ruby (except `group/<name>` classes needed for Tailwind group selectors)
- **Variants use data-attribute selectors** — if TSX sets `data-variant={variant}`, CSS uses `&[data-variant="value"]`. If TSX sets `data-orientation`, CSS uses `&[data-orientation="value"]`. Match whatever data attributes the TSX uses.
- TSX `cva()` base classes → CSS `@apply` on the `[data-slot]` root selector
- TSX `cva()` variant entries → CSS `&[data-<prop>="<value>"]` selectors (not BEM classes)
- TSX `defaultVariants` → Ruby `initialize` default param values
- TSX `data-slot` attributes are preserved exactly
- TSX `asChild`/`Slot.Root` patterns are dropped (not needed in Phlex)
- TSX `cn(base, className)` → Ruby passes `class:` to `root_component`, which merges with caller's `class:` via `class_names`
- CSS file name is pluralized (`button.rb` → `buttons.css`, `card.rb` → `cards.css`)

## Non-div Sub-components

Not all sub-components render `<div>`. Match the HTML element from the TSX:

| TSX Element | Ruby Helper |
|---|---|
| `<div>` | `div_with_slot` (private helper) |
| `<p>` | Create a `p_with_slot` helper or use `p(data: { slot: ... })` directly |
| `<fieldset>` | `send(tag, data: { slot: ... })` with configurable tag |
| `<legend>` | Same pattern — use the native Phlex element method |
| Another component (e.g. `<Label>`) | `render Components::Label.new(data: { slot: ... })` |

## Composing with Other Components

When a TSX sub-component wraps another component (e.g. `FieldLabel` renders `<Label>`), use `render Components::X.new(...)` in the Ruby method. Pass the `data: { slot: ... }` and any class overrides through to the inner component.

## Translating React Logic

TSX components may contain React-specific patterns (`useMemo`, conditional `null` returns, state hooks, error deduplication). Simplify these to Ruby idioms:

- Conditional rendering → guard clauses (`return if ...`)
- `useMemo` with derived values → compute inline in the method
- Array of error objects → accept simpler Ruby types (e.g. splat strings)
- `children` prop fallback → block parameter with `yield_content(&block)`
