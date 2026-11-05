import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";
import invariant from "tiny-invariant";

import { addAction } from "#helpers/stimulus_helpers";

const values = {
  interceptEnter: { type: Boolean, default: true },
};

export default class CheckableProxyController extends Typed(
  Controller<HTMLSpanElement>,
  { values },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const input = this.#locateInput();
    input.addEventListener("click", this.#handleInputClick);
    input.addEventListener("change", this.#handleInputChange);
    input.addEventListener("focus", this.#handleInputFocus);
    addAction(this, "keydown.space", "preventScroll");
    addAction(this, "keyup.space", "activate");
    addAction(this, "keydown.enter", "submitOrActivate");
    input.form?.addEventListener("reset", this.#handleFormReset);
    this.#associateLabel(input);
    // Pick up native checked state, including values restored by the browser.
    this.update();
  }

  disconnect(): void {
    super.disconnect();
    const input = this.#locateInput();
    input.removeEventListener("click", this.#handleInputClick);
    input.removeEventListener("change", this.#handleInputChange);
    input.removeEventListener("focus", this.#handleInputFocus);
    input.form?.removeEventListener("reset", this.#handleFormReset);
  }

  // == Actions ==

  preventScroll(event: KeyboardEvent): void {
    if (event.target !== this.element || event.defaultPrevented) return;
    // Space activates on keyup, but scrolling must be prevented on keydown.
    event.preventDefault();
  }

  activate(event: KeyboardEvent): void {
    if (event.target !== this.element || event.defaultPrevented) {
      return;
    }
    const input = this.#locateInput();
    if (input.disabled) {
      return;
    }
    event.preventDefault();

    // Reuse click actions so keyboard activation also honors toggleable radios.
    this.element.click();
  }

  submitOrActivate(event: KeyboardEvent): void {
    if (event.target !== this.element || event.defaultPrevented) {
      return;
    }
    event.preventDefault();

    const input = this.#locateInput();
    if (input.disabled || event.repeat) {
      return;
    }

    if (this.interceptEnterValue) {
      // Clicking the default submitter preserves its handlers, name/value and form overrides.
      const submitter = Array.from(input.form?.elements ?? []).find(
        (element) =>
          (element instanceof HTMLButtonElement ||
            element instanceof HTMLInputElement) &&
          element.type === "submit",
      );
      if (submitter instanceof HTMLElement) submitter.click();
    } else {
      this.element.click();
    }
  }

  forwardClick(event: PointerEvent): void {
    const input = this.#locateInput();
    if (input.disabled || input.readOnly) return;
    const { shiftKey, ctrlKey, altKey, metaKey } = event;
    // Native activation toggles the input and emits its usual input/change events.
    input.dispatchEvent(
      new PointerEvent("click", {
        bubbles: false,
        shiftKey,
        ctrlKey,
        altKey,
        metaKey,
      }),
    );
  }

  update(): void {
    const input = this.#locateInput();
    this.element.setAttribute("aria-checked", String(input.checked));
    // The visible span needs explicit disabled styling, semantics and tab order.
    this.element.toggleAttribute("data-disabled", input.disabled);
    if (input.disabled) {
      this.element.setAttribute("aria-disabled", "true");
    } else {
      this.element.removeAttribute("aria-disabled");
    }
    this.element.tabIndex = input.disabled ? -1 : 0;
    this.element.toggleAttribute("data-readonly", input.readOnly);
    if (input.readOnly) {
      this.element.setAttribute("aria-readonly", "true");
    } else {
      this.element.removeAttribute("aria-readonly");
    }
    if (input.required) {
      this.element.setAttribute("aria-required", "true");
    } else {
      this.element.removeAttribute("aria-required");
    }
    if (input.checked) {
      delete this.element.dataset.unchecked;
      this.element.dataset.checked = "";
    } else {
      delete this.element.dataset.checked;
      this.element.dataset.unchecked = "";
    }
  }

  // == Helpers ==

  #associateLabel(input: HTMLInputElement): void {
    // Native labels name the hidden input; link them to the proxy unless explicitly named.
    if (
      this.element.hasAttribute("aria-label") ||
      this.element.hasAttribute("aria-labelledby")
    ) {
      return;
    }

    const [label] = input.labels ?? [];
    if (label) {
      label.id ||= `${input.id || crypto.randomUUID()}_label`;
      this.element.setAttribute("aria-labelledby", label.id);
    }
  }

  #locateInput(): HTMLInputElement {
    let { nextElementSibling } = this.element;
    invariant(nextElementSibling instanceof HTMLInputElement, "Missing input");
    if (nextElementSibling.type === "hidden") {
      nextElementSibling = nextElementSibling.nextElementSibling;
      invariant(
        nextElementSibling instanceof HTMLInputElement,
        "Missing input",
      );
    }
    return nextElementSibling;
  }

  #handleInputFocus = (): void => {
    // The native input is `aria-hidden` and only exists for form
    // participation; redirect focus to the visible `[role]` element so that
    // focus never lands on (and is retained by) an aria-hidden element.
    // Mirrors Base UI's RadioRoot input `onFocus` behavior.
    this.element.focus();
  };

  #handleInputClick = (event: MouseEvent): void => {
    // Checkbox/radio readonly is not enforced by HTML; cancel native activation, including labels.
    const input = this.#locateInput();
    if (input.readOnly) {
      event.preventDefault();
    }
  };

  #handleInputChange = (): void => {
    this.update();
  };

  #handleFormReset = (): void => {
    // Reset restores checked after the reset event's handlers run.
    queueMicrotask(() => {
      this.update();
    });
  };
}
