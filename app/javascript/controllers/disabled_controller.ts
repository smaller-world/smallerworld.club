import { Controller } from "@hotwired/stimulus";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class DisabledController extends Controller<HTMLElement> {
  // == Values ==

  static values = {
    enableAfter: {
      type: Number,
      default: null,
    },
    message: String,
  };
  declare readonly enableAfterValue: number | null;
  declare readonly messageValue: string;

  // == Targets ==

  static targets = ["message"];
  declare readonly messageTarget: HTMLElement;
  declare readonly hasMessageTarget: boolean;

  // == Properties ==

  #timeout?: number | null;
  #originalMessageHTML?: string | null;

  // == Actions ==

  connect(): void {
    super.connect();
    if (typeof this.enableAfterValue === "number") {
      this.#timeout = setTimeout(() => {
        this.enable();
      }, this.enableAfterValue);
    }
    addCleanupAction(this, "restore");
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
