import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const values = {
  requirePageVisible: Boolean,
};

export default class SubmitController extends Typed(
  Controller<HTMLFormElement>,
  { values },
) {
  // == Actions ==

  request(): void {
    if (this.requirePageVisibleValue && document.visibilityState === "hidden") {
      console.info("Page is hidden; skipping submission");
      return;
    }
    this.element.requestSubmit();
  }
}
