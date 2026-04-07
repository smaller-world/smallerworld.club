# Conversion Rules: TSX to Phlex + CSS

## CSS Generation

### Structure

Wrap all styles in `@layer components { ... }`. Use flat `[data-slot="..."]` selectors — never nest them.

### Root element

- Selector: `[data-slot="<name>"]`
- Extract Tailwind utilities from `className={cn(...)}` or `cva()` base into `@apply`

### Variants

Use data-attribute selectors matching the TSX `data-*` attributes:

- `data-variant={variant}` → `&[data-variant="<value>"]`
- `data-size={size}` → `&[data-size="<value>"]`
- `data-orientation={orientation}` → `&[data-orientation="<value>"]`

### Sub-component slots

Each TSX sub-function with `data-slot="X"` → flat `[data-slot="X"] { @apply ...; }` (sibling of root, not nested).

## Ruby Generation

### Base class API

`Components::Base` provides:
- `root_element(default_element, **attributes, &content)` — renders root tag, merges caller's `**attributes` via `mix`
- `mix(defaults, overrides)` — deep-merges attribute hashes
- `@element` — optional tag override from `element:` init param

### Class structure

```ruby
# typed: true
# frozen_string_literal: true

class Components::<Name> < Components::Base
```

### Initialize

- Accept variant/size params with defaults matching TSX `defaultVariants`
- Always include `**attributes` and call `super(**attributes)`
- Use Sorbet `sig` annotations

### view_template

- Call `root_element(:<tag>, class: "group/<name>", data: { slot: ..., ... }, &content)`
- `class:` contains only `group/<name>` — visual styles live in CSS
- `data:` mirrors all `data-*` attributes from TSX

### Sub-component methods (compound)

- Private `slot` helper using `mix` for attribute merging:
  ```ruby
  def slot(slot, element: :div, **attributes, &content)
    send(element, **mix({ data: { slot: } }, **attributes), &content)
  end
  ```
- Public methods drop the component prefix: `CardHeader` → `header`
- Add `group/<name>` class when needed for Tailwind group selectors
- For non-div elements, pass `element:` to the slot helper
- For wrapping another Phlex component: `render Components::X.new(**mix({ data: { slot: ... } }, **attributes), &content)`

### Sorbet signatures

- `initialize`: `sig { params(..., attributes: T.untyped).void }`
- `view_template`: `sig { override.params(content: T.proc.void).void }` or `T.nilable(T.proc.void)`
- Sub-methods: `sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }`

## Example: Simple Component (Button)

### TSX (in `app/components/shadcn/button.tsx`)

```tsx
const buttonVariants = cva("inline-flex items-center ...", {
  variants: {
    variant: { default: "bg-primary ...", outline: "border-border ..." },
    size: { default: "h-9 ...", sm: "h-8 ...", icon: "size-9" },
  },
  defaultVariants: { variant: "default", size: "default" },
})

function Button({ variant = "default", size = "default", ... }) {
  return <ButtonPrimitive data-slot="button" className={cn(buttonVariants({ variant, size, className }))} {...props} />
}
```

### CSS (`app/assets/stylesheets/buttons.css`)

```css
@layer components {
  [data-slot="button"] {
    @apply inline-flex items-center ...;
    &[data-variant="default"] { @apply bg-primary ...; }
    &[data-variant="outline"] { @apply border-border ...; }
    &[data-size="default"] { @apply h-9 ...; }
    &[data-size="sm"] { @apply h-8 ...; }
    &[data-size="icon"] { @apply size-9; }
  }
}
```

### Ruby (`app/components/button.rb`)

```ruby
class Components::Button < Components::Base
  sig { params(variant: Symbol, size: Symbol, options: T.untyped).void }
  def initialize(variant: :default, size: :default, **options)
    super(**options)
    @variant = variant
    @size = size
  end

  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    root_element(:button, class: "group/button", data: { slot: "button", variant: @variant, size: @size }, &content)
  end
end
```

## Example: Compound Component (Card)

### TSX (in `app/components/shadcn/card.tsx`)

```tsx
function Card({ size = "default", ... }) {
  return <div data-slot="card" data-size={size} className={cn("flex flex-col ...", className)} {...props} />
}
function CardHeader({ ... }) {
  return <div data-slot="card-header" className={cn("grid auto-rows-min ...", className)} {...props} />
}
// CardTitle, CardContent, CardFooter, etc.
```

### CSS (`app/assets/stylesheets/cards.css`)

```css
@layer components {
  [data-slot="card"] { @apply flex flex-col gap-6 ...; }
  [data-slot="card-header"] { @apply grid auto-rows-min ...; }
  [data-slot="card-title"] { @apply font-heading text-base ...; }
  [data-slot="card-content"] { @apply px-6 ...; }
  [data-slot="card-footer"] { @apply flex items-center ...; }
}
```

### Ruby (`app/components/card.rb`)

```ruby
class Components::Card < Components::Base
  sig { params(size: Symbol, attributes: T.untyped).void }
  def initialize(size: :default, **attributes)
    super(**attributes)
    @size = size
  end

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(:div, class: "group/card", data: { slot: "card", size: @size }, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def header(**attributes, &content)
    slot("card-header", **attributes, &content)
  end

  sig { params(attributes: T.untyped, content: T.nilable(T.proc.void)).void }
  def title(**attributes, &content)
    slot("card-title", **attributes, &content)
  end

  # ... content, footer, action, description

  private

  sig do
    params(slot: String, element: Symbol, attributes: T.untyped, content: T.nilable(T.proc.void)).void
  end
  def slot(slot, element: :div, **attributes, &content)
    send(element, **mix({ data: { slot: } }, **attributes), &content)
  end
end
```

## Translation Table

| TSX Concept | CSS | Ruby |
|---|---|---|
| `cva()` base string | `[data-slot="X"] { @apply ...; }` | — (styles in CSS) |
| `cva()` variant entry | `&[data-variant="value"] { ... }` | `data: { variant: @variant }` |
| `defaultVariants` | — | `initialize` defaults |
| `data-slot="X"` | `[data-slot="X"]` | `data: { slot: "X" }` |
| `cn(base, className)` | — | Caller passes `class:`, merged by `mix` |
| Sub-function `CardHeader` | `[data-slot="card-header"]` | `def header(...)` |
| Sub-function rendering `<Label>` | `[data-slot="field-label"]` | `render Components::Label.new(...)` |
| `asChild` / `Slot.Root` | — | dropped |

## Naming Conventions

| Item | Convention | Example |
|---|---|---|
| CSS file | Pluralized | `buttons.css`, `cards.css` |
| CSS root selector | `[data-slot="<name>"]` | `[data-slot="button"]` |
| CSS variant selector | `&[data-<prop>="<value>"]` | `&[data-variant="default"]` |
| Ruby class | `Components::<PascalCase>` | `Components::Button` |
| Ruby file | `app/components/<snake_case>.rb` | `app/components/button.rb` |
| Sub-method | Prefix-stripped, snake_case | `CardHeader` → `header` |
| data-slot | Kebab-case, prefixed for sub-parts | `"card"`, `"card-header"` |
