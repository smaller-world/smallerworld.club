import { Controller } from "@hotwired/stimulus";
import { last } from "lodash-es";
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
    trigger: { type: String, default: "mouseenter focus" },
    placement: { type: String, default: "top" },
    animation: { type: String, default: "shift-away" },
    hideOnClick: { type: Boolean, default: true },
    disabled: Boolean,
    flashDuration: { type: Number, default: 2000 },
    flashDelay: Number,
  };
  declare readonly contentValue: string;
  declare readonly triggerValue: string;
  declare readonly placementValue: Placement;
  declare readonly animationValue: string;
  declare readonly hideOnClickValue: boolean;
  declare readonly flashDurationValue: number;
  declare readonly flashDelayValue: number;
  declare readonly disabledValue: boolean;

  // == State ==

  #tippy?: Instance | null;
  #showFlashTimeout?: number | null;
  #hideFlashTimeout?: number | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (this.contentValue) {
      this.#mountOrUpdate();
    }
    addCleanupAction(this, "destroy");
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
  }

  contentValueChanged(): void {
    this.#mountOrUpdate();
  }

  disabledValueChanged(disabled: boolean): void {
    if (this.#tippy && disabled) {
      this.#tippy.disable();
    } else {
      this.#mountOrUpdate();
    }
  }

  // == Actions ==

  show(): void {
    this.#tippy?.show();
  }

  flash(): void {
    const tippy = this.#tippy;
    if (!tippy?.state.isEnabled) {
      return;
    }
    this.#showFlashTimeout = setTimeout(() => {
      if (!tippy.state.isEnabled) {
        return;
      }
      tippy.setProps({ trigger: "manual" });
      tippy.show();
      this.#hideFlashTimeout = setTimeout(() => {
        tippy.setProps({ trigger: this.triggerValue });
        this.#hideIfTriggerInactive(tippy);
      }, this.flashDurationValue);
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

  // == Helpers ==

  #mountOrUpdate() {
    const props: Partial<Props> = {
      content: this.contentValue,
      animation: this.animationValue,
      placement: this.placementValue,
      trigger: this.triggerValue,
      hideOnClick: this.hideOnClickValue,
    };
    if (this.#tippy) {
      if (!this.contentValue) {
        const tippy = this.#tippy;
        tippy.hide();
        setTimeout(() => {
          tippy.setProps(props);
          tippy.disable();
        }, this.#hideDuration(tippy));
      } else {
        this.#tippy.setProps(props);
        if (!this.disabledValue) {
          this.#tippy.enable();
        }
      }
    } else if (this.contentValue) {
      this.#tippy = tippy(this.element, {
        ...props,
        arrow: roundArrow,
        inertia: true,
      });
      if (this.disabledValue) {
        this.#tippy.disable();
      }
    }
  }

  #hideDuration(tippy: Instance): number {
    const { duration } = tippy.props;
    if (Array.isArray(duration)) {
      return last(duration) ?? 0;
    }
    return duration;
  }

  #hideIfTriggerInactive(tippy: Instance): void {
    const triggers = tippy.props.trigger.split(" ");
    if (triggers.includes("mouseenter") && this.element.matches(":hover")) {
      return;
    }
    if (triggers.includes("focus") && this.element.matches(":focus")) {
      return;
    }
    tippy.hide();
  }
}
