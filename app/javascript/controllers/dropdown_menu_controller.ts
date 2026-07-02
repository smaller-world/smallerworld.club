import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

export default class DropdownMenuController extends Typed(
  Controller<HTMLElement>,
  {},
) {
  // == Actions ==

  preventAutoClose(event: Event): void {
    event.stopImmediatePropagation();
  }
}
