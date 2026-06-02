import { Controller } from "@hotwired/stimulus";

export default class AutoclickController extends Controller<HTMLElement> {
  // == Values ==

  static values = {
    once: Boolean,
  };
  declare readonly onceValue: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.element.click();
    if (this.onceValue) {
      this.#removeController();
    }
  }

  // == Helpers ==

  #removeController(): void {
    const parser = document.createElement("div");
    if (this.element.dataset.controller) {
      parser.className = this.element.dataset.controller;
    }
    parser.classList.remove(this.identifier);
    if (parser.className) {
      this.element.dataset.controller = parser.className;
    } else {
      delete this.element.dataset.controller;
    }
  }
}
