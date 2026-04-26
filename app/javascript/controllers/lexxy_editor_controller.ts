import { Controller } from "@hotwired/stimulus";

import { addAction } from "#helpers/stimulus_helpers";

export default class extends Controller<HTMLElement> {
  // == Lifecycle ==

  connect() {
    addAction(this, "lexxy:focus", "addFocusMarker");
    addAction(this, "lexxy:blur", "removeFocusMarker");
  }

  // == Actions ==

  addFocusMarker() {
    this.element.dataset.focused = "true";
  }

  removeFocusMarker() {
    delete this.element.dataset.focused;
  }
}
