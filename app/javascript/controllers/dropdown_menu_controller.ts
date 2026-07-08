import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

import { addBeforeCacheAction } from "#helpers/stimulus_helpers";

const targets = {
  menu: HTMLElement,
};

export default class DropdownMenuController extends Typed(
  Controller<HTMLElement>,
  { targets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasMenuTarget) {
      throw new Error("Missing menu target");
    }
    addBeforeCacheAction(this, "close");
  }

  // == Actions ==

  preventAutoClose(event: Event): void {
    event.stopImmediatePropagation();
  }

  close(): void {
    this.menuTarget.removeAttribute("open");
  }
}
