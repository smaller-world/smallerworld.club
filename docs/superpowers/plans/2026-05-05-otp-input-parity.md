# OTP Input Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bring `Components::OTPInput` to strict behavioral parity with the upstream `input-otp` library for the app's user-visible flows, integrate it into phone verification, and verify the result with a hybrid browser + human checklist.

**Architecture:** Keep the existing Phlex + Stimulus component boundary. Move form semantics and caller attributes onto the real hidden input, make the Stimulus controller selection-aware so slots reflect native input state, and wire the component into the real sign-in verification form via `Field#otp_input`.

**Tech Stack:** Rails, Phlex, Stimulus, Tailwind CSS, Minitest, local browser verification

---

### Task 1: Rework the Ruby component API and form-control attribute plumbing

**Files:**
- Modify: `app/components/otp_input.rb`
- Reference: `app/components/input.rb`
- Reference: `app/components/field.rb`
- Test: `test/controllers/sessions_controller_test.rb`

- [ ] **Step 1: Add a rendering expectation to the session page test**

Extend the existing `new` session page test so it proves the challenge screen will eventually render an OTP form control instead of only checking for `200 OK`.

```ruby
test "new" do
  get new_session_path

  assert_response :success
  assert_includes @response.body, "phone_number_verification_request_phone_number"
end
```

Run: `mise run test test/controllers/sessions_controller_test.rb -v`

Expected: PASS. This is a safety check that the existing flow still renders before OTP work starts.

- [ ] **Step 2: Change `Components::OTPInput` to follow input-like component conventions**

Refactor `app/components/otp_input.rb` so it separates:

- wrapper attributes used by the outer `<div>`
- real input attributes used by the hidden `<input>`
- Rails form-derived `name`, `id`, `value`, and invalid state

Use `Components::Input` as the pattern for invalid-state propagation, but keep `OTPInput` as its own component rather than subclassing `Input`.

Implementation shape:

```ruby
class Components::OTPInput < Components::Base
  sig do
    params(
      max_length: Integer,
      pattern: Symbol,
      name: T.nilable(String),
      form: T.nilable(PhlexFormBuilder),
      field: T.nilable(Symbol),
      attributes: T.untyped,
    ).void
  end
  def initialize(max_length: 6, pattern: :digits, name: nil, form: nil, field: nil, **attributes)
    @max_length = max_length
    @pattern_key = pattern
    @pattern = PATTERNS.fetch(pattern) { raise InvalidParameter.new(parameter: :pattern, value: pattern) }
    @name = name
    @form = form
    @field = field
    @input_attributes = attributes
    super()
  end
end
```

- [ ] **Step 3: Route caller attributes to the real input instead of the wrapper**

Update `view_template` and `hidden_input` so the outer wrapper gets only component-level attrs:

```ruby
root_element(
  :div,
  class: "otp-input group/otp-input",
  data: {
    slot: "otp-input",
    controller: "otp-input",
    otp_input_max_length_value: @max_length,
    otp_input_pattern_value: @pattern,
    otp_input_pattern_key_value: @pattern_key,
  },
) do
  hidden_input
  group { slots }
end
```

Build the input options via a helper:

```ruby
def input_options
  mix(
    {
      type: :text,
      class: "otp-input-hidden-input",
      autocomplete: "one-time-code",
      spellcheck: false,
      maxlength: @max_length,
      inputmode: inputmode,
      pattern: html_pattern,
      data: {
        otp_input_target: "input",
        action: [
          "focus->otp-input#handleFocus",
          "blur->otp-input#handleBlur",
          "input->otp-input#handleInput",
          "keydown->otp-input#handleKeydown",
          "click->otp-input#handleSelectionChange",
          "keyup->otp-input#handleSelectionChange",
          "paste->otp-input#handlePaste",
        ].join(" "),
      },
      aria: invalid? ? { invalid: "true" } : {},
    },
    resolved_input_attributes,
  )
end
```

- [ ] **Step 4: Add helpers for form-derived `name`, `id`, `value`, and invalid state**

Implement small private helpers so the real input can be generated from either plain attributes or a Rails form builder.

```ruby
def resolved_input_attributes
  attrs = @input_attributes.dup
  attrs[:name] ||= input_name
  attrs[:id] ||= input_id
  attrs[:value] = input_value if attrs[:value].nil? && !input_value.nil?
  attrs
end

def input_id
  @form&.field_id(@field) if @form && @field
end

def input_value
  return unless @form && @field

  @form.object.public_send(@field)
end

def invalid?
  (object = @form&.object) &&
    @field &&
    object.respond_to?(:errors) &&
    object.errors[@field].present?
end
```

- [ ] **Step 5: Add slot metadata needed for click-to-position**

Annotate each slot with an index:

```ruby
def slot(index)
  div(
    class: "otp-input-slot",
    data: {
      slot: "otp-input-slot",
      otp_input_target: "slot",
      otp_input_index: index,
      action: "click->otp-input#handleSlotClick",
    },
  ) do
    span(data: { char: true })
    div(class: "otp-input-caret", data: { caret: true }, hidden: true) { div }
  end
end
```

Update `slots` accordingly:

```ruby
@max_length.times do |index|
  slot(index)
end
```

- [ ] **Step 6: Re-run the session controller test**

Run: `mise run test test/controllers/sessions_controller_test.rb -v`

Expected: PASS. No behavior change yet, but the page should still render with the refactored component.

- [ ] **Step 7: Commit the API-plumbing change**

```bash
git add app/components/otp_input.rb test/controllers/sessions_controller_test.rb
git commit -m "Refactor OTP input attribute plumbing"
```

### Task 2: Implement selection-aware Stimulus parity for typing, caret state, and paste

**Files:**
- Modify: `app/javascript/controllers/otp_input_controller.ts`
- Reference: `node_modules/input-otp/dist/index.js`

- [ ] **Step 1: Replace length-based active-slot logic with selection-aware state**

Add controller values and state needed to track native selection:

```ts
static values = {
  maxLength: { type: Number, default: 6 },
  pattern: { type: String, default: "\\d" },
  patternKey: { type: String, default: "digits" },
};

declare patternKeyValue: string;

#focused = false;
#selectionStart: number | null = null;
#selectionEnd: number | null = null;
```

Create a shared updater:

```ts
#syncSelection(): void {
  this.#selectionStart = this.inputTarget.selectionStart;
  this.#selectionEnd = this.inputTarget.selectionEnd;
}
```

- [ ] **Step 2: Update lifecycle and focus handlers to keep selection state current**

Wire `connect`, `handleFocus`, `handleBlur`, and a new `handleSelectionChange` action so slot state follows the real input:

```ts
connect(): void {
  this.#sanitizeValue();
  this.#syncSelection();
  this.#updateSlots();
}

handleFocus(): void {
  this.#focused = true;
  this.#moveCaretToEditablePosition();
  this.#syncSelection();
  this.#updateSlots();
}

handleSelectionChange(): void {
  this.#syncSelection();
  this.#updateSlots();
}
```

- [ ] **Step 3: Implement selection-aware slot derivation**

Replace `#updateSlots` with logic based on selection start/end rather than `value.length`:

```ts
#updateSlots(): void {
  const value = this.inputTarget.value;
  const start = this.#selectionStart ?? value.length;
  const end = this.#selectionEnd ?? start;

  this.slotTargets.forEach((slot, index) => {
    const char = value[index] ?? "";
    const isActive =
      this.#focused &&
      (start === end ? index === Math.min(start, this.maxLengthValue - 1) : index >= start && index < end);
    const hasFakeCaret = this.#focused && start === end && index === start && !char;

    slot.dataset.active = String(isActive);
    slot.dataset.filled = String(char.length > 0);

    const charElement = slot.querySelector("[data-char]");
    if (charElement) charElement.textContent = char;

    const caretElement = slot.querySelector("[data-caret]");
    if (caretElement instanceof HTMLElement) {
      caretElement.hidden = !hasFakeCaret;
    }
  });
}
```

- [ ] **Step 4: Add click-to-position and post-input selection normalization**

Implement slot click behavior and normalize the caret after edits:

```ts
handleSlotClick(event: MouseEvent): void {
  const slot = event.currentTarget as HTMLElement;
  const index = Number(slot.dataset.otpInputIndex ?? "0");

  this.inputTarget.focus();
  this.inputTarget.setSelectionRange(index, index);
  this.#syncSelection();
  this.#updateSlots();
}

#moveCaretToEditablePosition(): void {
  const end = this.inputTarget.value.length;
  const position = Math.min(end, this.maxLengthValue - 1);
  this.inputTarget.setSelectionRange(position, end);
}
```

- [ ] **Step 5: Rework sanitization and paste to match upstream behavior more closely**

Keep one sanitization path and reuse it for input and paste:

```ts
#sanitizeValue(rawValue = this.inputTarget.value): string {
  const charPattern = new RegExp(this.patternValue);
  return rawValue
    .split("")
    .filter((char) => charPattern.test(char))
    .join("")
    .slice(0, this.maxLengthValue);
}

handleInput(): void {
  const sanitized = this.#sanitizeValue();
  if (sanitized !== this.inputTarget.value) this.inputTarget.value = sanitized;

  this.#syncSelection();
  this.#updateSlots();
  this.dispatch("change", { detail: { value: sanitized, complete: this.#isComplete } });
  if (this.#isComplete) this.dispatch("complete", { detail: { value: sanitized } });
}

handlePaste(event: ClipboardEvent): void {
  event.preventDefault();

  const pastedText = event.clipboardData?.getData("text/plain") ?? "";
  const inserted = this.#sanitizeValue(pastedText);
  const start = this.inputTarget.selectionStart ?? this.inputTarget.value.length;
  const end = this.inputTarget.selectionEnd ?? start;
  const nextValue = this.#sanitizeValue(
    `${this.inputTarget.value.slice(0, start)}${inserted}${this.inputTarget.value.slice(end)}`,
  );

  this.inputTarget.value = nextValue;
  const caret = Math.min(start + inserted.length, nextValue.length);
  this.inputTarget.setSelectionRange(caret, caret);
  this.#syncSelection();
  this.#updateSlots();
  this.dispatch("change", { detail: { value: nextValue, complete: this.#isComplete } });
  if (this.#isComplete) this.dispatch("complete", { detail: { value: nextValue } });
}
```

- [ ] **Step 6: Tighten key handling without blocking native editing**

Keep native navigation/editing keys and modifier shortcuts intact:

```ts
handleKeydown(event: KeyboardEvent): void {
  if (event.metaKey || event.ctrlKey || event.altKey) return;

  if (
    [
      "Backspace",
      "Delete",
      "ArrowLeft",
      "ArrowRight",
      "ArrowUp",
      "ArrowDown",
      "Home",
      "End",
      "Tab",
    ].includes(event.key)
  ) {
    return;
  }

  const pattern = new RegExp(this.patternValue);
  if (event.key.length === 1 && !pattern.test(event.key)) {
    event.preventDefault();
  }
}
```

- [ ] **Step 7: Typecheck/lint the controller through the project check task**

Run: `mise run check`

Expected: PASS or controller-specific formatting/type diagnostics only. Fix any issues in `otp_input_controller.ts` before continuing.

- [ ] **Step 8: Commit the controller parity work**

```bash
git add app/javascript/controllers/otp_input_controller.ts
git commit -m "Implement OTP input selection parity"
```

### Task 3: Fix CSS overlay, active-slot presentation, and invalid-state hooks

**Files:**
- Modify: `app/assets/stylesheets/otp_inputs.css`
- Reference: `app/components/shadcn/input-otp.tsx`
- Reference: `app/assets/stylesheets/theme.css`

- [ ] **Step 1: Make the OTP container a positioning context for the hidden input**

Update the root and group selectors so the hidden input overlay is constrained correctly:

```css
@layer components {
  .otp-input {
    @apply relative flex items-center has-disabled:opacity-50;
  }

  .otp-input-group {
    @apply relative flex items-center rounded-md has-aria-invalid:border-destructive has-aria-invalid:ring-3 has-aria-invalid:ring-destructive/20 dark:has-aria-invalid:ring-destructive/40;
  }
}
```

- [ ] **Step 2: Ensure slot invalid state can follow the real input**

Keep the shadcn slot visuals, but add selectors that work when the hidden input carries `aria-invalid`:

```css
.otp-input-group:has(.otp-input-hidden-input[aria-invalid="true"]) .otp-input-slot {
  @apply border-destructive;
}

.otp-input-group:has(.otp-input-hidden-input[aria-invalid="true"]) .otp-input-slot[data-active="true"] {
  @apply ring-destructive/20 dark:ring-destructive/40;
}
```

- [ ] **Step 3: Switch fake caret visibility from inline `display` toggles to semantic hiding**

Keep the existing caret styles and rely on `[hidden]` from the controller:

```css
.otp-input-caret[hidden] {
  display: none;
}

.otp-input-caret > div {
  @apply h-4 w-px animate-caret-blink bg-foreground;
}
```

- [ ] **Step 4: Preserve visual parity with the shadcn source**

Verify the slot classes still match the wrapper component:

```tsx
"relative flex size-9 items-center justify-center border-y border-r border-input text-sm shadow-xs transition-all outline-none first:rounded-l-md first:border-l last:rounded-r-md ..."
```

Keep `theme.css` unchanged except to confirm the `caret-blink` token remains:

```css
--animate-caret-blink: caret-blink 1s ease-out infinite;
```

- [ ] **Step 5: Run the style/lint checks**

Run: `mise run check`

Expected: PASS. If Tailwind nesting or selector issues surface, fix them before moving on.

- [ ] **Step 6: Commit the CSS fix**

```bash
git add app/assets/stylesheets/otp_inputs.css app/assets/stylesheets/theme.css
git commit -m "Fix OTP input overlay and state styling"
```

### Task 4: Integrate OTP input into the verification flow and add minimal server-side coverage

**Files:**
- Modify: `app/components/field.rb`
- Modify: `app/components/phone_number_verification_request_form.rb`
- Modify: `test/controllers/sessions_controller_test.rb`
- Create: `test/controllers/phone_number_verification_requests_controller_test.rb`
- Reference: `app/controllers/phone_number_verification_requests_controller.rb`

- [ ] **Step 1: Add a `Field#otp_input` helper**

Add a small wrapper in `app/components/field.rb`:

```ruby
sig { params(options: T.untyped).void }
def otp_input(**options)
  Components::OTPInput(form: @form, field: @field, **options)
end
```

- [ ] **Step 2: Replace the verification code text field with the OTP component**

Update `app/components/phone_number_verification_request_form.rb`:

```ruby
field_for(form, :verification_code) do |f|
  f.otp_input(
    max_length: 6,
    pattern: :digits,
    autocomplete: "one-time-code",
    value: Rails.env.development? ? @verification_request.verification_code : nil,
  )

  if Rails.env.development?
    f.description(class: "text-xs text-center") do
      "code auto-filled for development"
    end
  end

  f.error
end
```

Leave the phone number field and button flow unchanged.

- [ ] **Step 3: Add a controller test for the challenge screen rendering the OTP field**

Create `test/controllers/phone_number_verification_requests_controller_test.rb`:

```ruby
require "test_helper"

class PhoneNumberVerificationRequestsControllerTest < ActionDispatch::IntegrationTest
  test "challenge renders otp input for verification code" do
    verification_request = PhoneNumberVerificationRequest.create!(
      phone_number: "+15555550123",
      ip_address: "127.0.0.1",
      user_agent: "Rails Test",
    )

    get challenge_phone_number_verification_request_path(verification_request)

    assert_response :success
    assert_includes @response.body, 'data-controller="otp-input"'
    assert_includes @response.body, 'name="phone_number_verification_request[verification_code]"'
  end
end
```

- [ ] **Step 4: Run the targeted controller tests**

Run: `mise run test test/controllers/sessions_controller_test.rb test/controllers/phone_number_verification_requests_controller_test.rb -v`

Expected: PASS. The tests should prove the challenge page renders the OTP component in the real flow.

- [ ] **Step 5: Commit the form integration**

```bash
git add app/components/field.rb app/components/phone_number_verification_request_form.rb test/controllers/sessions_controller_test.rb test/controllers/phone_number_verification_requests_controller_test.rb
git commit -m "Integrate OTP input into verification form"
```

### Task 5: Update skill guidance and complete hybrid verification

**Files:**
- Modify: `.claude/skills/import-shadcn-component/skill.md`
- Reference: `docs/superpowers/specs/2026-05-05-otp-input-parity-design.md`

- [ ] **Step 1: Add explicit parity guidance for custom Stimulus ports**

Extend the skill doc's Stimulus section with two concrete rules:

```md
- For custom input-like Stimulus ports, compare behavior against the upstream primitive, not only the shadcn wrapper.
- Verify selection, paste, autofill, mobile keyboard semantics, invalid-state propagation, and caller attribute routing to the real form control.
```

- [ ] **Step 2: Start the app and open the live verification flow**

Run: `mise run dev`

Expected: the local app boots under Overmind. Note the local URL actually served by the web process and use it for browser verification.

- [ ] **Step 3: Perform browser-assisted verification with DevTools**

Verify these behaviors in a local browser on the live verification form:

1. submit a phone number to reach the challenge step
2. confirm the verification code field renders the OTP component
3. inspect the DOM and confirm:
   - the focused element is the hidden input
   - the hidden input is inside the OTP component bounds
   - `name`, `id`, `maxlength`, `autocomplete`, `inputmode`, and `aria-invalid` are on the real input
4. type digits and confirm slot text updates
5. use arrow keys and click different slots to confirm active slot state follows the caret
6. paste a full code into the empty field and confirm it fills all slots
7. select a middle range and paste a partial code to confirm replacement-in-place
8. listen for `otp-input:change` and `otp-input:complete` in DevTools and confirm payloads

- [ ] **Step 4: Run the full project checks before completion**

Run: `mise run test`

Expected: PASS. If unrelated pre-existing failures exist, capture them explicitly and rerun the relevant OTP-targeted test files to confirm the new work is clean.

Run: `mise run check`

Expected: PASS.

- [ ] **Step 5: Hand the user a concise manual verification checklist**

Provide this checklist in the final handoff:

```md
- On iPhone and Android, verify the keyboard type feels right for the verification field.
- On a real device, verify the OS one-time-code suggestion appears and inserts cleanly.
- Try correcting the third or fourth digit in an existing code and make sure the caret behavior feels natural.
- If you use VoiceOver or another screen reader, confirm the field announces as one editable verification-code input rather than six unrelated fields.
```

- [ ] **Step 6: Commit the documentation change**

```bash
git add .claude/skills/import-shadcn-component/skill.md
git commit -m "Document OTP parity checks for Stimulus ports"
```
