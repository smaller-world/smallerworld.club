# Hybrid Combobox Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `Components::Combobox` a functional single-select strict picker using Tailwind Elements autocomplete behavior and shadcn-derived styling.

**Architecture:** Render Tailwind Elements custom elements from Phlex while preserving the existing `data-slot` styling contract. Add one Stimulus controller for strict value enforcement and empty-state styling state; leave filtering, popover, ARIA, and keyboard behavior to Tailwind Elements.

**Tech Stack:** Rails, Phlex, Sorbet signatures, Tailwind CSS, Tailwind Elements, Stimulus TypeScript.

---

### Task 1: Phlex Custom Element Markup

**Files:**
- Modify: `app/components/combobox.rb`

- [ ] Register `el_autocomplete`, `el_options`, and `el_option`.
- [ ] Render the root as `el-autocomplete` with `data-controller="combobox"`.
- [ ] Add Stimulus targets/actions to the input, content, and item methods.
- [ ] Change `content` to render `el-options popover anchor="bottom start"`.
- [ ] Change `item` to require `value:` and render `el-option`.
- [ ] Preserve existing helper names for the single-select API.

### Task 2: Strict Picker Stimulus Controller

**Files:**
- Create: `app/javascript/controllers/combobox_controller.ts`
- Modify: `app/javascript/controllers/index.ts`

- [ ] Implement targets for `input`, `content`, and `item`.
- [ ] Track the last valid enabled `el-option[value]`.
- [ ] On input/change/blur, set content `data-empty` from currently visible enabled options.
- [ ] On change, accept only exact enabled option values.
- [ ] On blur, restore the last valid value or clear invalid arbitrary text.
- [ ] Register the controller in `controllers/index.ts`.

### Task 3: Tailwind Elements Styling Adaptation

**Files:**
- Modify: `app/assets/stylesheets/comboboxes.css`

- [ ] Keep shadcn slot selectors as the styling source of truth.
- [ ] Replace Base UI positioning assumptions with Tailwind Elements variables.
- [ ] Style `el-options[data-slot="combobox-content"]` as the popover panel.
- [ ] Hide filtered `el-option[hidden]` items.
- [ ] Use Tailwind Elements transition attributes.
- [ ] Keep empty-state visibility tied to `data-empty="true"`.

### Manual Verification

No automated tests for this task. Manually verify trigger toggling, filtering,
keyboard selection, click selection, strict blur restoration/clearing, disabled
options, empty state, width, selected styling, and transitions.
