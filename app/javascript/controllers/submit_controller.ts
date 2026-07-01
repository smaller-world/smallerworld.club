import { Controller } from "@hotwired/stimulus";

export default class SubmitController extends Controller<HTMLFormElement> {
  // == Values ==

  static values = {
    requirePageVisible: Boolean,
  };
  declare requirePageVisibleValue: boolean;

  // == Actions ==

  request(): void {
    if (this.requirePageVisibleValue && document.visibilityState === "hidden") {
      console.info("Page is hidden; skipping submission");
      return;
    }
    this.element.requestSubmit();
  }
}
