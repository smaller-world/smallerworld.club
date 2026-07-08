import { Controller } from "@hotwired/stimulus";

import { addBeforeCacheAction } from "#helpers/stimulus_helpers";

export default class PopoverController extends Controller<HTMLElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    addBeforeCacheAction(this, "close");
  }

  // == Actions ==

  preventAutoClose(event: Event): void {
    event.stopImmediatePropagation();
  }

  close(): void {
    this.element.hidePopover();
  }
}
