---
name: import-shadcn-component
description: Convert a shadcn/ui React TSX component into a Rails Phlex `.rb` component + Tailwind `.css` file. Use when the user asks to import, convert, port, or add a shadcn component, or when referencing a TSX source from the Vite preset project. Triggers on requests like "import the badge component", "convert separator.tsx", "add the input component", etc.
---

# Import Shadcn Component

Convert a shadcn/ui TSX component from the Vite preset source into the Rails Phlex + Tailwind CSS architecture used in this project.

## Source and Target Locations

- **TSX source**: Check `vendor/javascript/shadcn-vite-preset/src/components/ui/<name>.tsx` first. If not present, run `bunx shadcn@latest add <name> --path app/components/shadcn --overwrite` to import it into `app/components/shadcn/<name>.tsx`.
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

The `root_element` helper (from `Components::Base`) renders the root tag, merging caller-provided attributes via `mix`. It takes a default element tag and `**attributes`. There is no `root_class` or `root_component` helper — use `root_element`.

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
    root_element(:div, **root_attributes, &content)
  end

  private

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def root_attributes
    {
      class: "group/<name>",
      data: {
        slot: "<name>",
        variant: @variant,
        size: @size,
      },
    }
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
- TSX `cn(base, className)` → Ruby passes attributes through `root_element`, which merges with caller overrides via `mix`
- CSS file name is pluralized (`button.rb` → `buttons.css`, `card.rb` → `cards.css`)

## Non-div Sub-components

Not all sub-components render `<div>`. Match the HTML element from the TSX. Use the native Phlex element method with `mix` to merge slot data:

| TSX Element | Ruby Pattern |
|---|---|
| `<div>` | `div(**mix({ data: { slot: "..." } }, attributes), &block)` |
| `<p>` | `p(**mix({ data: { slot: "..." } }, attributes), &block)` |
| `<h3>` | `h3(**mix({ data: { slot: "..." } }, attributes), &block)` |
| `<fieldset>` | `send(tag, **mix({ data: { slot: "..." } }, attributes), &block)` with configurable tag |
| Another component (e.g. `<Label>`) | `Components::Label(data: { slot: "..." })` |

## Composing with Other Components

When a TSX sub-component wraps another component (e.g. `FieldLabel` renders `<Label>`), use Phlex kit syntax: `Components::X(...)`. Pass the `data: { slot: ... }` and any class overrides through to the inner component.

**Gotcha — `data-slot` merging**: When you pass `data: { slot: "foo" }` to a component that already sets its own `data-slot`, the `mix` helper concatenates both into `data-slot="bar foo"`. This breaks CSS `[data-slot="foo"]` exact-match selectors. To avoid this, wrap the component in a container element with the outer slot instead:

```ruby
# WRONG — produces data-slot="button dialog-close"
Components::Button(data: { slot: "dialog-close" }) { "Close" }

# RIGHT — separate elements, separate slots
div(data: { slot: "dialog-close" }) do
  Components::Button() { "Close" }
end
```

## Custom HTML Elements

Components that use web components (e.g. `<el-dialog>`, `<trix-editor>`) must register them with Phlex. Use `register_element` — underscores are converted to dashes automatically:

```ruby
class Components::Dialog < Components::Base
  register_element :el_dialog          # renders <el-dialog>
  register_element :el_dialog_backdrop # renders <el-dialog-backdrop>
  register_element :el_dialog_panel    # renders <el-dialog-panel>
end
```

Phlex's `tag()` method requires a Symbol — calling `tag("el-dialog")` with a String will raise `Phlex::ArgumentError`.

Note: Sorbet won't recognize methods defined by `register_element` — this is expected; ignore typing errors on those.

## Native Element CSS Conflicts

When styling native semantic elements like `<dialog>`, `<details>`, or `<summary>`, `@layer components` has **lower specificity** than browser UA stylesheets. This means your `@apply` rules may be silently overridden.

For example, a `<dialog>` element is hidden by default via `display: none` in the UA stylesheet. If your CSS sets `@apply flex`, the `@layer components` rule loses to the UA rule. Fix with state-scoped selectors:

```css
[data-slot="dialog-content"] {
  @apply items-center justify-center; /* layout props ready */

  &[open] {
    @apply flex; /* only override display when dialog is actually open */
  }
}
```

## Translating React Logic

TSX components may contain React-specific patterns (`useMemo`, conditional `null` returns, state hooks, error deduplication). Simplify these to Ruby idioms:

- Conditional rendering → guard clauses (`return if ...`)
- `useMemo` with derived values → compute inline in the method
- Array of error objects → accept simpler Ruby types (e.g. splat strings)
- `children` prop fallback → block parameter with `yield` (not `yield_content` — that method doesn't exist in this Phlex version)
