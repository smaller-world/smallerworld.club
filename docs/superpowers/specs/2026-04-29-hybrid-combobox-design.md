# Hybrid Combobox Design

## Context

`Components::Combobox` currently ports the shadcn combobox slot markup and
`app/assets/stylesheets/comboboxes.css` ports its visual styling, but the
component is not interactive. The app already uses a hybrid pattern in
`Components::Dialog`: Tailwind Elements custom elements provide behavior while
Rails/Phlex markup preserves local `data-slot` styling hooks.

The combobox should follow the same pattern. Tailwind Elements
`<el-autocomplete>` owns filtering, listbox keyboard navigation, popover
toggling, ARIA state, and option selection. The shadcn combobox slot names and
CSS remain the source of truth for aesthetics.

## Scope

This design covers single-select comboboxes only.

The first implementation will not support chips, multi-select values, async
loading, grouped filtering behavior beyond what static markup allows, or
automated tests. Manual testing will validate behavior.

## Architecture

`Components::Combobox` will render a Tailwind Elements autocomplete shell:

- Root: `el-autocomplete` with `data-slot="combobox"` and a Stimulus controller.
- Input: native `input` inside the existing input-group wrapper.
- Trigger: native `button type="button"` used by Tailwind Elements to toggle
  the options popover.
- Content: `el-options popover anchor="bottom start"` with
  `data-slot="combobox-content"`.
- Item: `el-option value="..."` with `data-slot="combobox-item"`.
- Empty, label, separator, and collection helpers remain slot-based wrappers
  for styling and composition.

The root component will register the required custom elements with Phlex,
matching the `Components::Dialog` pattern.

## Strict Picker Behavior

Tailwind Elements autocomplete allows arbitrary typed values by default. This
combobox must be strict: the input's submitted value must match one rendered
`el-option[value]`.

A small Stimulus controller will enforce this without replacing Tailwind
Elements behavior:

- Track the last valid selected value.
- Update that value when the input fires `change` and matches an enabled option.
- On blur, if the typed value does not match an enabled option, restore the last
  valid value.
- If there is no last valid value, clear the input.
- Dispatch normal input/change events only when the controller changes the value
  programmatically so Rails form integrations see the corrected value.

The controller should not implement filtering, active descendant management, or
keyboard navigation. Those remain Tailwind Elements responsibilities.

## Styling

`app/assets/stylesheets/comboboxes.css` remains the aesthetic source of truth.
It should be adapted to Tailwind Elements' DOM and attributes:

- Use Tailwind Elements CSS variables such as `--input-width` instead of Base UI
  positioner variables like `--anchor-width`.
- Style `el-options[data-slot="combobox-content"]` as the floating panel.
- Preserve existing shadcn slot selectors unless Tailwind Elements requires a
  custom-element selector for correct behavior.
- Treat `el-option[hidden]` as filtered out.
- Use `aria-selected="true"` as the selected/active styling hook.
- Use Tailwind Elements transition attributes: `data-closed`, `data-enter`,
  `data-leave`, and `data-transition`.

Empty-state visibility will be based on a lightweight app-controlled state.
Tailwind Elements hides filtered options but does not expose a documented
empty-state slot, so the Stimulus controller will set `data-empty="true"` on the
content element when all enabled options are hidden.

## Public Component API

Keep the existing helper names for the single-select API:

- `input_field(...)` renders the styled searchable input and optional trigger.
- `content(...)` renders `el-options`.
- `list(...)` renders the scroll container.
- `item(value:, selected: false, disabled: false, ...)` renders `el-option`.
- `empty`, `group`, `label`, `collection`, and `separator` remain composition
  helpers.

For strict selection, `item` will require a `value:` argument because
Tailwind Elements depends on `el-option[value]` for selection.

The existing chips helpers can remain in the file as visual helpers, but they
are out of scope for functional integration in this pass.

## Manual Verification

Manual testing should cover:

- Clicking the trigger opens and closes the popover.
- Typing filters options.
- Arrow keys move through visible options.
- Enter selects the active option.
- Clicking an option selects it and closes the popover.
- Blurring after arbitrary unmatched text restores the previous valid value or
  clears the input.
- Disabled options cannot be selected.
- The popover width, selected styling, empty state, and transitions match the
  shadcn-derived combobox aesthetic.

Automated tests are intentionally excluded from this implementation per the
project direction for this task.
