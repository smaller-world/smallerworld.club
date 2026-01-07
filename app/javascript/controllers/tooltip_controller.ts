import { Controller } from "@hotwired/stimulus";
import tippy, { type Instance } from "tippy.js";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class TooltipController extends Controller<HTMLElement> {
  // == Values ==
  static values = {
    content: String,
    trigger: String,
    flashImmediately: Boolean,
    flashDuration: Number,
    flashDelay: Number,
  };
  declare readonly contentValue: string;
  declare readonly triggerValue: string;
  declare readonly flashImmediatelyValue: boolean;
  declare readonly flashDurationValue: number;
  declare readonly flashDelayValue: number;

  // == State ==

  #tooltip?: Instance | null;
  #showFlashTimeout?: NodeJS.Timeout | null;
  #hideFlashTimeout?: NodeJS.Timeout | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.#tooltip = tippy(this.element, {
      content: this.contentValue,
      inertia: true,
      animation: "scale",
    });
    if (this.triggerValue) {
      this.#tooltip.setProps({
        trigger: this.triggerValue,
        hideOnClick: this.triggerValue !== "manual",
      });
    }
    if (this.flashImmediatelyValue) {
      this.flash();
    }
    addCleanupAction(this, "destroy");
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
  }

  // == Actions ==

  flash(): void {
    if (!this.#tooltip || !this.element.checkVisibility()) {
      return;
    }
    this.#showFlashTimeout = setTimeout(() => {
      if (!this.element.checkVisibility()) {
        return;
      }
      this.#tooltip?.show();
      if (this.flashDurationValue) {
        this.#hideFlashTimeout = setTimeout(() => {
          this.#tooltip?.hide();
        }, this.flashDurationValue);
      }
    }, this.flashDelayValue);
  }

  destroy(): void {
    if (this.#showFlashTimeout) {
      clearTimeout(this.#showFlashTimeout);
      this.#showFlashTimeout = null;
    }
    if (this.#hideFlashTimeout) {
      clearTimeout(this.#hideFlashTimeout);
      this.#hideFlashTimeout = null;
    }
    if (this.#tooltip) {
      this.#tooltip.destroy();
      this.#tooltip = null;
    }
  }
}
