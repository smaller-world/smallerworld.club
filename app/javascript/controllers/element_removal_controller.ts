import { Controller } from "@hotwired/stimulus";

export default class ElementRemovalController extends Controller {
  // == Methods ==

  remove(): void {
    this.element.remove();
  }
}
