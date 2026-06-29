import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

export default class CheckboxController extends Controller<HTMLSpanElement> {
  // == Listeners ==

  #changeListener = this._handleInputChange.bind(this);
  #focusListener = this._handleInputFocus.bind(this);

  // == Lifecycle ==

  connect(): void {
    super.connect();
    const input = this._locateInput();
    input.addEventListener("change", this.#changeListener);
    input.addEventListener("focus", this.#focusListener);
  }

  disconnect(): void {
    super.disconnect();
    const input = this._locateInput();
    input.removeEventListener("change", this.#changeListener);
    input.removeEventListener("focus", this.#focusListener);
  }

  // == Actions ==

  forwardItemClick(event: PointerEvent): void {
    const input = this._locateInput();
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

  // == Helpers ==

  _locateInput(): HTMLInputElement {
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

  _handleInputFocus() {
    // The native input is `aria-hidden` and only exists for form
    // participation; redirect focus to the visible `[role]` element so that
    // focus never lands on (and is retained by) an aria-hidden element.
    // Mirrors Base UI's RadioRoot input `onFocus` behavior.
    this.element.focus();
  }

  _handleInputChange(event: Event) {
    const { target } = event;
    invariant(target instanceof HTMLInputElement, "Invalid target");

    if (target.checked) {
      delete this.element.dataset.unchecked;
      this.element.dataset.checked = "";
    } else {
      delete this.element.dataset.checked;
      this.element.dataset.unchecked = "";
    }
  }
}
