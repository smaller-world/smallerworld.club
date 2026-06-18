import { Controller } from "@hotwired/stimulus";

export default class DropdownMenuController extends Controller<HTMLElement> {
  // == Actions ==

  preventAutoClose(event: Event): void {
    event.stopImmediatePropagation();
  }
}
