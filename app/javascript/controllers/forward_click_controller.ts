import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

import { addAction } from "#helpers/stimulus_helpers";

const targets = {
  clickable: HTMLElement,
};

export default class ForwardClickController extends Typed(
  Controller<HTMLElement>,
  {
    targets,
  },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    addAction(this, "click", "forward");
  }

  // == Actions ==

  forward(event: PointerEvent) {
    event.preventDefault();
    event.stopPropagation();
    this.clickableTarget.dispatchEvent(new Event("click", { bubbles: false }));
  }
}
