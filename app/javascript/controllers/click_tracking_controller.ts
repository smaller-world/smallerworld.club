import { Controller } from "@hotwired/stimulus";

export default class ClickTrackingController extends Controller<HTMLElement> {
  // == Actions ==

  track(): void {
    this.element.dataset.clicked = "";
  }
}
