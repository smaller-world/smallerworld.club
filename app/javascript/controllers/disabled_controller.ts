import { Controller } from "@hotwired/stimulus";

export default class DisabledController extends Controller<
  HTMLButtonElement | HTMLInputElement
> {
  // static targets = ["clickable"];
  // declare readonly clickableTarget: HTMLElement;
  // declare readonly hasClickableTarget: boolean;

  static values = {
    enableAfter: {
      type: Number,
      default: null,
    },
  };
  declare readonly enableAfterValue: number | null;

  // == State ==
  #timeout?: number | null;

  // == Actions ==

  connect(): void {
    super.connect();
    console.log({ enableAfterValue: this.enableAfterValue });
    if (typeof this.enableAfterValue === "number") {
      this.#timeout = setTimeout(() => {
        this.element.disabled = false;
      }, this.enableAfterValue);
    }
  }

  disconnect(): void {
    super.disconnect();
    if (this.#timeout) {
      clearTimeout(this.#timeout);
      this.#timeout = null;
    }
  }
}
