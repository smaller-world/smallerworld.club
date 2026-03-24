import { Controller } from "@hotwired/stimulus";
import tippy, { type Instance, type Placement, roundArrow } from "tippy.js";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class TooltipController extends Controller<HTMLElement> {
  // == Values ==
  static values = {
    content: String,
    trigger: String,
    placement: { type: String, default: "top" },
    hideOnClick: { type: Boolean, default: true },
    flashImmediately: Boolean,
    flashDuration: { type: Number, default: 2000 },
    flashDelay: Number,
  };
  declare readonly contentValue: string;
  declare readonly triggerValue: string;
  declare readonly placementValue: Placement;
  declare readonly hideOnClickValue: boolean;
  declare readonly flashImmediatelyValue: boolean;
  declare readonly flashDurationValue: number;
  declare readonly flashDelayValue: number;

  // == State ==

  #tooltip?: Instance | null;
  #showFlashTimeout?: number | null;
  #hideFlashTimeout?: number | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.#tooltip = tippy(this.element, {
      content: this.contentValue,
      inertia: true,
      arrow: roundArrow,
      animation: "scale",
      placement: this.placementValue,
      hideOnClick: this.hideOnClickValue,
    });
    if (this.triggerValue) {
      this.#tooltip.setProps({
        trigger: this.triggerValue,
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
      if (!this.element.checkVisibility() || !this.#tooltip) {
        return;
      }
      this.#tooltip.show();
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
