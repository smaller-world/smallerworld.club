import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

export default class RadioGroupController extends Controller {
  static targets = ["itemInput"];
  declare readonly itemInputTargets: HTMLCollectionOf<HTMLInputElement>;

  // == Actions ==

  select(event: Event) {
    const { target } = event;
    invariant(target instanceof HTMLInputElement, "Invalid target");

    target.checked = true;
    for (const input of this.itemInputTargets) {
      if (input !== target) {
        input.checked = false;
      }
      this.#updateItem(input);
    }
  }

  forwardItemClick(event: PointerEvent): void {
    const { target } = event;
    invariant(target instanceof HTMLElement, "Invalid target");
    const { nextElementSibling } = target;
    invariant(
      nextElementSibling instanceof HTMLInputElement,
      "Couldn't locate associated input",
    );
    const { shiftKey, ctrlKey, altKey, metaKey } = event;
    nextElementSibling.dispatchEvent(
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

  #updateItem(input: HTMLInputElement) {
    const { previousElementSibling } = input;
    invariant(
      previousElementSibling instanceof HTMLElement,
      "Couldn't locate associated item",
    );
    if (input.checked) {
      delete previousElementSibling.dataset.unchecked;
      previousElementSibling.dataset.checked = "";
    } else {
      delete previousElementSibling.dataset.checked;
      previousElementSibling.dataset.unchecked = "";
    }
  }
}
