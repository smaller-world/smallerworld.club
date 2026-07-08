import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

import { addBeforeCacheAction } from "#helpers/stimulus_helpers";

const targets = {
  message: HTMLElement,
};

const values = {
  enableAfter: Number,
  message: String,
};

export default class DisabledController extends Typed(Controller<HTMLElement>, {
  targets,
  values,
}) {
  // == Properties ==

  #timeout?: number | null;
  #originalMessageHTML?: string | null;

  // == Actions ==

  connect(): void {
    super.connect();
    if (this.enableAfterValue) {
      this.#timeout = setTimeout(() => {
        this.enable();
      }, this.enableAfterValue);
    }
    addBeforeCacheAction(this, "restore");
  }

  disconnect(): void {
    super.disconnect();
    this.enable();
    if (this.#timeout) {
      clearTimeout(this.#timeout);
      this.#timeout = null;
    }
  }

  // == Actions ==

  disable(): void {
    if ("disabled" in this.element) {
      this.element.disabled = true;
    } else {
      this.element.dataset.disabled = "true";
    }
    if (this.messageValue) {
      this.#originalMessageHTML = this.#messageElement.innerHTML;
      this.#messageElement.innerText = this.messageValue;
    }
  }

  enable(): void {
    if ("disabled" in this.element) {
      this.element.disabled = false;
    } else {
      delete this.element.dataset.disabled;
    }
    if (this.#originalMessageHTML) {
      this.#messageElement.innerHTML = this.#originalMessageHTML;
      this.#originalMessageHTML = null;
    }
  }

  // == Helpers ==

  get #messageElement(): HTMLElement {
    return this.hasMessageTarget ? this.messageTarget : this.element;
  }
}
