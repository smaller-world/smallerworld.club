import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

export default class CheckboxController extends Controller<HTMLSpanElement> {
  // == Lifecycle ==

  #changeListener = this.handleInputChange.bind(this);

  connect(): void {
    super.connect();
    const input = this.#locateInput();
    input.addEventListener("change", this.#changeListener);
  }

  disconnect(): void {
    super.disconnect();
    const input = this.#locateInput();
    input.removeEventListener("change", this.#changeListener);
  }

  // == Actions ==

  forwardItemClick(event: PointerEvent): void {
    const input = this.#locateInput();
    const { shiftKey, ctrlKey, altKey, metaKey } = event;
    input.dispatchEvent(
      new PointerEvent("click", {
        bubbles: true,
        shiftKey,
        ctrlKey,
        altKey,
        metaKey,
      }),
    );
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
    invariant(nextElementSibling.type === "checkbox", "Invalid input");
    return nextElementSibling;
  }

  handleInputChange(event: Event) {
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
