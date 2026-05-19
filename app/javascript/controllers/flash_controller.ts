import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class FlashController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["textContainer"];
  declare readonly textContainerTarget: HTMLElement;
  declare readonly hasTextContainerTarget: boolean;

  // == Values ==
  static values = {
    text: String,
    duration: {
      type: Number,
      default: 2000,
    },
  };
  declare readonly textValue: string;
  declare readonly durationValue: number;

  originalText?: string | null;
  timeout?: number | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    invariant(this.textValue, "Missing textValue");
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
    this.#textContainer.textContent = this.textValue;
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
    return this.hasTextContainerTarget
      ? this.textContainerTarget
      : this.element;
  }
}
