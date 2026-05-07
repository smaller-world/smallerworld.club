# OTP Input Parity Design

**Date:** 2026-05-05

**Goal**

Bring `Components::OTPInput` to strict behavioral parity with the upstream `input-otp` library where that behavior matters to this Rails app, then wire it into the phone number verification flow so it is exercised in a live browser path.

**Scope**

This design covers:

- `app/javascript/controllers/otp_input_controller.ts`
- `app/components/otp_input.rb`
- `app/assets/stylesheets/otp_inputs.css`
- `app/assets/stylesheets/theme.css`
- `app/components/field.rb`
- `app/components/phone_number_verification_request_form.rb`
- `.claude/skills/import-shadcn-component/skill.md`

This design does not introduce a separate third-party OTP library into the Rails runtime. The existing Phlex + Stimulus approach remains the implementation model.

## Problem Summary

The current OTP input is visually close to shadcn's `InputOTP` wrapper, but it is missing several behaviors from the upstream `input-otp` primitive:

- the hidden input overlay is not anchored to the component container
- active slot state follows `value.length` instead of the real selection/caret
- clicking a slot does not position the caret
- paste replaces the full value instead of inserting/replacing at the selection
- form control attributes are applied to the wrapper instead of the real input
- invalid state, accessibility semantics, and mobile keyboard behavior are incomplete

Because these issues are coupled, the fix should be done as one coherent parity pass rather than as unrelated patches.

## Constraints

- Keep the public component as a Rails Phlex component with a Stimulus controller.
- Keep the visual output aligned with `app/components/shadcn/input-otp.tsx`.
- Follow existing `Components::Field` and form-builder patterns used elsewhere in the repo.
- Make the component usable in `Components::PhoneNumberVerificationRequestForm` so browser verification can happen on a real flow.
- Verification should be hybrid: automated browser inspection where practical, plus a concise manual checklist for the remaining behaviors.

## Recommended Approach

Use the existing hidden-input architecture, but make the controller selection-aware so the visual slots derive from the real input's state rather than a simplified mirror. Move form-control semantics to the real input, keep the wrapper responsible for layout and styling only, and integrate the component into the verification form through `Field#otp_input`.

This keeps the implementation local to the codebase, preserves visual parity with shadcn, and closes the behavior gap with the upstream `input-otp` library without introducing a React dependency or a second rendering model.

## Architecture

### 1. Stimulus controller as the interaction model

`app/javascript/controllers/otp_input_controller.ts` will own:

- current sanitized value
- focus state
- selection start and end
- active slot derivation
- fake caret visibility
- keyboard input filtering
- click-to-position behavior
- paste insertion/replacement behavior
- dispatching `otp-input:change` and `otp-input:complete`

The controller should derive slot state from the real input's `selectionStart` and `selectionEnd`, matching the upstream library's interaction model closely enough that arrow navigation, in-place edits, and partial paste all behave correctly.

### 2. Phlex component as rendering and form integration

`app/components/otp_input.rb` will own:

- Ruby API for `max_length`, `pattern`, `form`, `field`, `name`, and passthrough HTML attributes
- generation of hidden input markup
- generation of slot markup
- Rails form-builder integration
- invalid-state propagation from form errors

Caller-provided input attributes must land on the real `<input>`, not the outer wrapper. The wrapper should keep only container-level attributes that are genuinely about layout or Stimulus attachment.

### 3. CSS as visual parity plus overlay support

`app/assets/stylesheets/otp_inputs.css` will own:

- relative positioning for the correct hidden input overlay
- slot border, focus ring, invalid state, and dark mode styling
- caret container styling
- disabled appearance

`app/assets/stylesheets/theme.css` keeps the `caret-blink` animation token and keyframes only.

## Detailed Design

### A. Input overlay and container positioning

The root OTP container must establish a positioning context for the hidden input overlay. The real input should cover only the OTP component bounds, not the page or a distant ancestor. The wrapper should allow pointer interaction to fall through correctly to the real input and slot click handlers.

Expected outcome:

- clicking anywhere on the OTP control focuses the real input
- the invisible input is constrained to the OTP control
- the component does not interfere with nearby controls

### B. Selection-aware slot state

The controller should track the actual selection range and derive slot state from it.

For each slot:

- `char` is the character at the slot index or empty when absent
- `isActive` is true when the slot corresponds to the current caret or selection range
- `hasFakeCaret` is true when the control is focused, the slot is active, and that slot has no rendered character

Behavioral expectations:

- focusing the input activates the first empty slot, or the last slot edge when filled
- arrow keys move the active slot visually
- backspace/delete update slot content and active state without stale caret placement
- selecting within the input updates the visual state on the next selection change

Strict duplication of every internal quirk from the upstream package is not required, but user-observable editing behavior should match.

### C. Click-to-position

Clicking a rendered slot should place the caret at the corresponding logical position inside the hidden input instead of only calling `.focus()`.

Rules:

- clicking an empty slot places the caret at that slot index
- clicking a filled slot places the caret in a way that allows editing that character naturally
- clicking after the last filled character should place the caret at the end

The controller can implement this with a slot index target or per-slot data attribute and a single click action.

### D. Paste insertion and replacement

Paste behavior must respect the current selection range.

Rules:

- sanitize pasted text to the allowed pattern
- insert into or replace the current selection
- truncate to `maxLength`
- preserve resulting selection in a predictable end position
- dispatch `change`, and `complete` when the sanitized result reaches `maxLength`

Examples:

- pasting a full code into an empty control fills the control
- selecting one middle digit and pasting one digit replaces only that digit
- selecting multiple digits and pasting replaces just that range

### E. Keyboard and input semantics

The real input should support the right keyboard and browser semantics for the selected pattern.

Requirements:

- `autocomplete="one-time-code"` remains on the real input
- `inputmode` should be chosen by pattern, not always numeric
- `pattern` should be set on the real input when useful
- `spellcheck` should be disabled
- invalid characters should be filtered both on key input and on resulting input value

Pattern defaults:

- `:digits` => numeric semantics
- `:chars` => text semantics
- `:alphanumeric` => text semantics with broader sanitization

### F. Accessibility and form integration

The component must behave like a real form control in Rails forms.

Requirements:

- `id`, `name`, `value`, `disabled`, `required`, `autofocus`, `placeholder`, `aria-*`, and caller `data-*` attributes apply to the real input
- form-builder usage should derive `name` and `id` from the form and field
- invalid state should propagate from Rails model errors to the input and slots
- labels rendered by `Components::Field` should still associate with the input

The component should expose a root structure that is friendly to screen readers without duplicating verbal content from the visual slots. The hidden input remains the accessible form control; the slots are presentational.

### G. Phlex API shape

Add `Field#otp_input` to `app/components/field.rb` so form callers can use:

```ruby
field_for(form, :verification_code) do |f|
  f.otp_input(...)
  f.error
end
```

`Components::OTPInput` should follow existing input-like component conventions:

- accept `form:` and `field:`
- surface form errors through invalid state
- keep Ruby defaults conservative
- avoid splitting the component into unnecessary subcomponents

### H. Live integration target

Replace the plain verification code text input in `app/components/phone_number_verification_request_form.rb` with the OTP input component. Keep the development-only auto-filled value and helper description so the live browser path remains easy to exercise.

Expected outcome:

- first step still collects phone number
- persisted verification request state renders the OTP component for `verification_code`
- the dev-only auto-filled code still appears where applicable

## File Responsibilities

- `app/components/otp_input.rb`
  - rework attribute routing, form integration, invalid state, and slot metadata
- `app/javascript/controllers/otp_input_controller.ts`
  - implement parity behavior for focus, selection, click, typing, and paste
- `app/assets/stylesheets/otp_inputs.css`
  - fix overlay positioning and ensure visual parity for slot state
- `app/assets/stylesheets/theme.css`
  - no behavioral changes; retain caret animation token
- `app/components/field.rb`
  - add `otp_input` helper method
- `app/components/phone_number_verification_request_form.rb`
  - replace text input with OTP input
- `.claude/skills/import-shadcn-component/skill.md`
  - document parity checks for custom Stimulus ports

## Verification Strategy

### AI-verifiable checks

Use the app in a local browser flow and verify, where possible:

- the OTP control renders in the verification form
- the hidden input is visually constrained to the component
- slot content updates while typing
- active slot styling tracks the caret
- paste fills or replaces the expected range
- `otp-input:change` and `otp-input:complete` dispatch with expected payloads

Use Chrome DevTools tooling to inspect DOM state, focused element behavior, and emitted events.

### Human verification checklist

Provide the user a short checklist for the parts that are better judged manually:

- mobile keyboard behavior on an actual phone
- SMS autofill / one-time-code suggestions from the OS
- screen reader wording if they have an accessibility setup handy
- general feel of caret movement and correction when editing a middle digit

## Testing Strategy

Add targeted verification at the level this codebase already supports comfortably.

Primary targets:

- rendering/integration coverage for `Components::OTPInput` and `Field#otp_input`
- behavior coverage for the live verification form path
- lightweight controller verification where feasible in the project's JS test setup

If the repo does not already have a practical JS unit-test path for Stimulus controllers, prefer system/integration coverage over inventing a new test harness for this component.

## Risks and Mitigations

### Risk: selection behavior becomes brittle

Mitigation:

- keep the controller logic centered on native input selection APIs
- verify with arrow keys, click-to-position, backspace, delete, and partial paste

### Risk: attribute routing breaks form compatibility

Mitigation:

- mirror established `Components::Input` conventions
- verify generated `id`, `name`, `value`, disabled, required, and invalid state

### Risk: visual parity regresses while fixing behavior

Mitigation:

- keep CSS changes narrow
- compare slot classes and states against the shadcn source

## Alternatives Considered

### 1. Patch the current controller incrementally

Rejected because the current issues share the same root cause: the controller is not selection-aware. Piecemeal fixes would likely leave interaction gaps.

### 2. Use the upstream JS package directly

Rejected because the app is intentionally using a Rails Phlex + Stimulus component model, and bringing in the upstream React-based primitive would complicate integration more than it helps.

### 3. Keep a plain text input and style it to resemble OTP slots

Rejected because it would not achieve strict parity and would preserve the current behavioral gaps.

## Success Criteria

The work is done when:

- `Components::OTPInput` behaves like the upstream `input-otp` control for typing, selection, correction, and paste
- the component is usable through `Field#otp_input`
- the phone verification request form renders and uses the OTP component in the verification step
- invalid state, accessibility hooks, and caller attributes are applied to the real input correctly
- browser verification covers the critical interactive behaviors
- the user receives a concise manual verification checklist for the remaining human checks
- the import skill doc explicitly calls out parity checks for custom Stimulus ports
