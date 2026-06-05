import { Controller } from "@hotwired/stimulus";
import tippy, {
  type Instance,
  type Placement,
  type Props,
  roundArrow,
} from "tippy.js";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class TippyController extends Controller<HTMLElement> {
  // == Values ==

  static values = {
    content: String,
    trigger: String,
    placement: { type: String, default: "top" },
    animation: { type: String, default: "shift-away" },
    hideOnClick: { type: Boolean, default: true },
    showOnCreate: { type: Boolean, default: false },
    flashDuration: { type: Number, default: 2000 },
    flashDelay: Number,
  };
  declare readonly contentValue: string;
  declare readonly triggerValue: string;
  declare readonly placementValue: Placement;
  declare readonly animationValue: string;
  declare readonly hideOnClickValue: boolean;
  declare readonly showOnCreateValue: boolean;
  declare readonly flashDurationValue: number;
  declare readonly flashDelayValue: number;

  // == State ==

  #tippy?: Instance | null;
  #showFlashTimeout?: number | null;
  #hideFlashTimeout?: number | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.contentValue) {
      return;
    }
    const props: Partial<Props> = {
      content: this.contentValue,
      inertia: true,
      arrow: roundArrow,
      animation: this.animationValue,
      placement: this.placementValue,
      hideOnClick: this.hideOnClickValue,
      showOnCreate: this.showOnCreateValue,
    };
    if (this.triggerValue) {
      props.trigger = this.triggerValue;
    }
    this.#tippy = tippy(this.element, props);
    addCleanupAction(this, "destroy");
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
  }

  // == Actions ==

  show(): void {
    this.#tippy?.show();
  }

  flash(): void {
    if (!this.#tippy || !this.element.checkVisibility()) {
      return;
    }
    this.#showFlashTimeout = setTimeout(() => {
      if (!this.element.checkVisibility() || !this.#tippy) {
        return;
      }
      this.#tippy.show();
      if (this.flashDurationValue) {
        this.#hideFlashTimeout = setTimeout(() => {
          this.#tippy?.hide();
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
    if (this.#tippy) {
      this.#tippy.destroy();
      this.#tippy = null;
    }
  }
}
