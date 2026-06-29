import { Controller } from "@hotwired/stimulus";

import { addAction } from "#helpers/stimulus_helpers";

export default class PreventEnterSubmitController extends Controller<HTMLInputElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    addAction(this, "keydown.enter", "preventSubmit");
  }

  // == Actions ==

  preventSubmit(event: KeyboardEvent): void {
    event.preventDefault();
  }
}
