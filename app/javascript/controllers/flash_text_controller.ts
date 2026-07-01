import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class FlashTextController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["container"];
  declare readonly containerTarget: HTMLElement;
  declare readonly hasContainerTarget: boolean;

  // == Values ==
  static values = {
    content: String,
    duration: {
      type: Number,
      default: 2000,
    },
  };
  declare readonly contentValue: string;
  declare readonly durationValue: number;

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
