import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const values = {
  once: Boolean,
};

export default class AutoclickController extends Typed(
  Controller<HTMLElement>,
  { values },
) {
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
