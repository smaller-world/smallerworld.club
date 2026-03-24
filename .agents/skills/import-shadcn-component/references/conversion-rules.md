# Conversion Rules: TSX to Phlex + CSS

## Table of Contents

- [CSS Generation Rules](#css-generation-rules)
- [Ruby Generation Rules](#ruby-generation-rules)
- [Example: Simple Component (Button)](#example-simple-component-button)
- [Example: Compound Component (Card)](#example-compound-component-card)
- [Non-div Sub-components and Composition](#non-div-sub-components-and-composition)
- [Translating React Logic](#translating-react-logic)
- [Translation Table](#translation-table)
- [Naming Conventions](#naming-conventions)

## CSS Generation Rules

### Structure

Wrap all styles in `@layer components { ... }`. Use flat `[data-slot="..."]` selectors — do NOT nest them under a root class.

### Root element styles

- Use `[data-slot="<name>"]` as the selector
- Extract the Tailwind utility string from `className={cn(...)}` or `cva()` base into `@apply`

### Variants (from `cva()` or conditional classes)

Use **data-attribute selectors** that match the TSX `data-*` attributes. Do NOT use BEM-style modifier classes.

- If TSX sets `data-variant={variant}`: use `&[data-variant="<value>"]`
- If TSX sets `data-size={size}`: use `&[data-size="<value>"]`
- If TSX sets `data-orientation={orientation}`: use `&[data-orientation="<value>"]`
- General rule: mirror whatever `data-*` attribute the TSX uses

### Sub-component slots (compound components)

- Each TSX sub-function with `data-slot="X"` becomes a flat `[data-slot="X"] { @apply ...; }` selector
- These are siblings of the root selector, NOT nested inside it

### Style adjustments

The TSX classes are ported as-is into `@apply`. Minor adjustments may be needed:
- Some classes may be added or tweaked for the server-rendered context (e.g. `[a]:hover:` selectors)

## Ruby Generation Rules

### Base class helpers

`Components::Base` provides:
- `root_component(default_tag, **options, &block)` — renders the root element, merging `class:` and `data:` from both the component definition and caller overrides. Handles `:component` override for tag swapping.
- `class_names(...)` — from Phlex::Rails, merges CSS class strings
- There is **no `root_class` helper**. Pass `class:` directly to `root_component`.

### Class structure

```ruby
# typed: true
# frozen_string_literal: true

class Components::<Name> < Components::Base
```

### Initialize

- Accept variant/size params matching TSX props, with defaults matching `defaultVariants`
- Always include `**options` and call `super(**options)`
- Use Sorbet `sig` annotations

### view_template (root element)

- Call `root_component(:<tag>, class: "...", data: { slot: ..., ... }, &block)`
- The `class:` string contains only `group/<name>` classes (for Tailwind group selectors) — all visual styles live in CSS
- The `data:` hash mirrors all `data-*` attributes from TSX (slot, variant, size, orientation, etc.)

### Sub-component methods (compound components)

- For `<div>` sub-components: create a private `div_with_slot(slot, **options, &block)` helper
- For other HTML elements (`<p>`, `<fieldset>`, `<legend>`, etc.): create equivalent helpers or use the Phlex element method directly
- For sub-components that wrap another Phlex component: use `render Components::X.new(data: { slot: ... }, ...)`
- Each TSX sub-function becomes a public instance method
- Method names drop the component prefix: `CardHeader` -> `header`, `FieldDescription` -> `description`
- Add `group/<name>` class in Ruby when needed for Tailwind group selectors
- Accept `**options, &block` params

### Sorbet signatures

Every method gets a `sig`:
- `initialize`: `sig { params(..., options: T.untyped).void }`
- `view_template`: `sig { override.params(block: T.proc.bind(T.self_type).void).void }`
- Sub-component methods: `sig { params(options: T.untyped, block: T.proc.bind(T.self_type).void).void }`

## Example: Simple Component (Button)

### TSX Source (abbreviated)

```tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center ...",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/80",
        outline: "border-border bg-input/30 hover:bg-input/50 ...",
      },
      size: {
        default: "h-9 gap-1.5 px-3 ...",
        sm: "h-8 gap-1 px-3 ...",
        icon: "size-9",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  }
)

function Button({ variant = "default", size = "default", ... }) {
  return <button data-slot="button" data-variant={variant} data-size={size} className={cn(buttonVariants({ variant, size, className }))} {...props} />
}
```

### Generated CSS (`buttons.css`)

```css
@layer components {
  [data-slot="button"] {
    @apply inline-flex items-center justify-center ...;

    /* == Variants == */

    &[data-variant="default"] { @apply bg-primary text-primary-foreground ...; }
    &[data-variant="outline"] { @apply border-border bg-input/30 ...; }

    /* == Sizes == */

    &[data-size="default"] { @apply h-9 gap-1.5 px-3 ...; }
    &[data-size="sm"] { @apply h-8 gap-1 px-3 ...; }
    &[data-size="icon"] { @apply size-9; }
  }
}
```

Note: Variant and size selectors use `data-variant` and `data-size` attributes, matching what the TSX sets.

### Generated Ruby (`button.rb`)

```ruby
# typed: true
# frozen_string_literal: true

class Components::Button < Components::Base
  sig { params(variant: Symbol, size: Symbol, options: T.untyped).void }
  def initialize(variant: :default, size: :default, **options)
    super(**options)
    @variant = variant
    @size = size
  end

  sig { override.params(block: T.proc.bind(T.self_type).void).void }
  def view_template(&block)
    root_component(
      :button,
      class: "group/button",
      data: { slot: "button", variant: @variant, size: @size },
      &block
    )
  end
end
```

## Example: Compound Component (Card)

### TSX Source (abbreviated)

```tsx
function Card({ ... }) {
  return <div data-slot="card" className={cn("flex flex-col ...", className)} {...props} />
}
function CardHeader({ ... }) {
  return <div data-slot="card-header" className={cn("grid auto-rows-min ...", className)} {...props} />
}
function CardTitle({ ... }) { ... }
function CardContent({ ... }) { ... }
function CardFooter({ ... }) { ... }
```

### Generated CSS (`cards.css`)

```css
@layer components {
  [data-slot="card"] {
    @apply flex flex-col gap-6 ...;
  }

  [data-slot="card-header"] {
    @apply grid auto-rows-min ...;
  }

  [data-slot="card-title"] {
    @apply text-lg leading-none ...;
  }

  [data-slot="card-content"] {
    @apply px-4 ...;
  }

  [data-slot="card-footer"] {
    @apply flex items-center ...;
  }
}
```

Note: Sub-component selectors are flat siblings, not nested under the root.

### Generated Ruby (`card.rb`)

```ruby
# typed: true
# frozen_string_literal: true

class Components::Card < Components::Base
  sig { params(size: Symbol, options: T.untyped).void }
  def initialize(size: :default, **options)
    super(**options)
    @size = size
  end

  sig { override.params(block: T.proc.bind(T.self_type).void).void }
  def view_template(&block)
    root_component(
      :div,
      class: "group/card",
      data: { slot: "card", size: @size },
      &block
    )
  end

  sig { params(options: T.untyped, block: T.proc.bind(T.self_type).void).void }
  def header(**options, &block)
    class_option = options.delete(:class)
    div_with_slot(
      "card-header",
      class: class_names("group/card-header", class_option),
      **options,
      &block
    )
  end

  sig { params(options: T.untyped, block: T.proc.bind(T.self_type).void).void }
  def title(**options, &block)
    div_with_slot("card-title", **options, &block)
  end

  sig { params(options: T.untyped, block: T.proc.bind(T.self_type).void).void }
  def content(**options, &block)
    div_with_slot("card-content", **options, &block)
  end

  sig { params(options: T.untyped, block: T.proc.bind(T.self_type).void).void }
  def footer(**options, &block)
    div_with_slot("card-footer", **options, &block)
  end

  private

  def div_with_slot(slot, **options, &block)
    data = options.delete(:data) || {}
    data[:slot] = slot
    div(data:, **options, &block)
  end
end
```

## Non-div Sub-components and Composition

### Different HTML elements

When a TSX sub-component uses a non-div element, use the matching Phlex element method:

```ruby
# <p> element
def description(**options, &block)
  data = options.delete(:data) || {}
  data[:slot] = "field-description"
  p(data:, **options, &block)
end

# <fieldset> element
def field_set(**options, &block)
  data = options.delete(:data) || {}
  data[:slot] = "field-set"
  fieldset(data:, **options, &block)
end

# <legend> element
def legend(variant: :legend, **options, &block)
  data = options.delete(:data) || {}
  data[:slot] = "field-legend"
  data[:variant] = variant
  send(:legend, data:, **options, &block)  # use send if method name conflicts
end
```

### Wrapping other Phlex components

When a TSX sub-component renders another component (e.g. `FieldLabel` renders `<Label>`), use `render`:

```ruby
def label(**options, &block)
  class_option = options.delete(:class)
  render Components::Label.new(
    data: { slot: "field-label" },
    class: class_names("group/field-label peer/field-label", class_option),
    **options,
    &block
  )
end
```

## Translating React Logic

TSX may contain React-specific patterns. Simplify to Ruby idioms:

| React Pattern | Ruby Equivalent |
|---|---|
| Conditional `null` return | Guard clause: `return if condition` |
| `useMemo` with derived data | Compute inline in the method |
| `children` prop with fallback | Block parameter: `&block` with `yield_content(&block)` |
| Array of error objects `{ message }` | Splat string args or simple array of strings |
| `{...new Map(arr).values()}` dedup | `array.compact.uniq` |
| Conditional JSX (`{cond && <El/>}`) | Ruby `if`/`unless` in the method body |

Example — FieldError with React logic simplified:

```ruby
# TSX uses useMemo, error deduplication, conditional null return, children fallback
# Ruby simplifies to:
def error(*errors, **options, &block)
  return if errors.compact.empty? && block.nil?

  div(role: "alert", data: { slot: "field-error" }, **options) do
    if block
      yield_content(&block)
    elsif errors.compact.length == 1
      plain errors.compact.first
    else
      ul { errors.compact.each { |msg| li { plain msg } } }
    end
  end
end
```

## Translation Table

| TSX Concept | CSS Equivalent | Ruby Equivalent |
|---|---|---|
| `cva()` base string | `[data-slot="X"] { @apply ...; }` | (none — styles in CSS only) |
| `cva()` variant entry | `&[data-variant="value"] { @apply ...; }` | `data: { variant: @variant }` |
| `cva()` size entry | `&[data-size="value"] { @apply ...; }` | `data: { size: @size }` |
| `defaultVariants` | (none) | `initialize` default param values |
| `data-slot="X"` | `[data-slot="X"]` | `data: { slot: "X" }` |
| `data-variant`, `data-size`, etc. | `&[data-variant="..."]`, `&[data-size="..."]` | `data: { variant:, size: }` |
| `cn(base, className)` | (none) | `class:` passed to `root_component`, which merges with caller's class |
| `className` prop | (none) | Caller passes `class:` option, merged by `root_component` |
| Sub-function `CardHeader` | `[data-slot="card-header"]` | Instance method `def header(...)` |
| Sub-function rendering `<Label>` | styles on `[data-slot="field-label"]` | `render Components::Label.new(data: { slot: ... })` |
| `{...props}` spread | (none) | `**options` |
| `asChild` / `Slot.Root` | (none — dropped) | (none — dropped) |
| `useMemo`, conditional returns | (none) | Guard clauses, inline computation |

## Naming Conventions

| Item | Convention | Example |
|---|---|---|
| CSS file | Pluralized component name | `buttons.css`, `cards.css`, `fields.css` |
| CSS root selector | `[data-slot="<name>"]` | `[data-slot="button"]`, `[data-slot="field"]` |
| CSS variant selector | `&[data-<prop>="<value>"]` | `&[data-variant="default"]`, `&[data-orientation="vertical"]` |
| Ruby class | `Components::<PascalCase>` | `Components::Button`, `Components::Card` |
| Ruby file | `app/components/<snake_case>.rb` | `app/components/button.rb` |
| Sub-method | Prefix-stripped, snake_case | `CardHeader` -> `header`, `FieldDescription` -> `description` |
| data-slot | Kebab-case, prefixed for sub-parts | `"card"`, `"card-header"`, `"field-description"` |
