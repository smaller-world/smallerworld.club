import { Controller } from "@hotwired/stimulus";
import IMask, { type InputMask } from "imask";
import invariant from "tiny-invariant";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class IMaskController extends Controller<HTMLInputElement> {
  // == Values ==

  static values = {
    mask: String,
    lazy: {
      type: Boolean,
      default: true,
    },
  };

  declare readonly maskValue: string;
  declare readonly lazyValue: boolean;

  // == State ==

  #imask?: InputMask | null;
  #defaultValue = "";

  // == Lifecycle ==

  connect(): void {
    super.connect();
    invariant(this.maskValue, "Missing mask value");
    this.#defaultValue = this.element.value;
    this.#imask = IMask(this.element, {
      mask: this.maskValue,
      lazy: this.lazyValue,
    }).on("complete", () => {
      this.#maybeDispatchComplete();
    });
    this.#maybeDispatchComplete();
    addCleanupAction(this, "destroy");
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
    this.#defaultValue = "";
  }

  // == Actions ==

  destroy(): void {
    if (this.#imask) {
      this.#imask.destroy();
      this.#imask = null;
    }
  }

  setDefaultIfIncomplete(): void {
    if (!this.#imask) {
      return;
    }
    if (!this.#imask.masked.isComplete) {
      this.element.value = this.#defaultValue;
      this.#imask.updateValue();
      if (this.#imask.masked.isComplete) {
        this.#maybeDispatchComplete();
      }
    }
  }

  // == Helpers ==

  #maybeDispatchComplete(): void {
    if (!this.#imask?.masked.isComplete) {
      return;
    }
    this.dispatch("complete", {
      detail: {
        value: this.#imask.value,
      },
    });
  }
}
