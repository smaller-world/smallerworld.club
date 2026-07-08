import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

export default class CheckboxProxyController extends Controller<HTMLSpanElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const input = this.#locateInput();
    input.addEventListener("change", this.#handleInputChange);
    input.addEventListener("focus", this.#handleInputFocus);
  }

  disconnect(): void {
    super.disconnect();
    const input = this.#locateInput();
    input.removeEventListener("change", this.#handleInputChange);
    input.removeEventListener("focus", this.#handleInputFocus);
  }

  // == Actions ==

  forwardClick(event: PointerEvent): void {
    const input = this.#locateInput();
    const { shiftKey, ctrlKey, altKey, metaKey } = event;
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
    if (input.checked) {
      delete this.element.dataset.unchecked;
      this.element.dataset.checked = "";
    } else {
      delete this.element.dataset.checked;
      this.element.dataset.unchecked = "";
    }
  }

  // == Helpers ==

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

  #handleInputChange = (): void => {
    this.update();
  };
}
