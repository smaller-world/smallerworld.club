import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";
import invariant from "tiny-invariant";

import { addCleanupAction } from "#helpers/stimulus_helpers";

const targets = {
  container: HTMLElement,
};

const values = {
  content: String,
  duration: {
    type: Number,
    default: 2000,
  },
};

export default class FlashTextController extends Typed(
  Controller<HTMLElement>,
  { targets, values },
) {
  originalText?: string | null;
  timeout?: number | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    invariant(this.contentValue, "Missing contentValue");
    addCleanupAction(this, "restore");
  }

  disconnect(): void {
    super.disconnect();
    this.restore();
  }

  // == Actions ==

  show(): void {
    if (this.timeout) {
      return;
    }
    this.originalText = this.#textContainer.textContent;
    this.#textContainer.textContent = this.contentValue;
    this.timeout = setTimeout(() => {
      this.restore();
    }, this.durationValue);
  }

  restore(): void {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }
    if (this.originalText) {
      this.#textContainer.textContent = this.originalText;
      this.originalText = null;
    }
  }

  // == Helpers ==

  get #textContainer(): HTMLElement {
    return this.hasContainerTarget ? this.containerTarget : this.element;
  }
}
