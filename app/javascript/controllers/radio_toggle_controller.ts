import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

export default class RadioToggleController extends Controller<HTMLSpanElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const input = this.#locateInput();
    if (input.labels) {
      for (const label of input.labels) {
        label.addEventListener("click", this.#handleLabelClick);
      }
    }
  }

  disconnect(): void {
    super.disconnect();
    const input = this.#locateInput();
    if (input.labels) {
      for (const label of input.labels) {
        label.removeEventListener("click", this.#handleLabelClick);
      }
    }
  }

  // == Actions ==

  toggle(): void {
    const input = this.#locateInput();
    input.checked = !input.checked;
    input.dispatchEvent(new Event("input"));
    input.dispatchEvent(new Event("change"));
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

  #handleLabelClick = (event: Event): void => {
    event.preventDefault();
    this.toggle();
  };
}
