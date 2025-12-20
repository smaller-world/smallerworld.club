import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // == Methods ==

  remove(): void {
    this.element.remove();
  }
}
