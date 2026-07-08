import { Typed } from "stimulus-typescript";

import ApplicationController from "./application_controller";

const targets = {
  input: HTMLInputElement,
};

export default class EmojiSelectController extends Typed(
  ApplicationController<HTMLElement>,
  { targets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTarget) {
      throw new Error("Missing input target");
    }
  }

  // == Actions ==

  receiveSelection({ detail }: CustomEvent<{ emoji: string }>): void {
    this.inputTarget.value = detail.emoji;
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }));
  }

  clearOrRequestOpenPicker(): void {
    if (this.inputTarget.value) {
      this.inputTarget.value = "";
      this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }));
    } else {
      this.dispatch("request-open-picker");
    }
  }

  requestInputTooltipUpdate(): void {
    const { inputTarget } = this;
    if (inputTarget.value) {
      this.dispatch("request-enable-tooltip", { target: inputTarget });
    } else {
      this.dispatch("request-disable-tooltip", { target: inputTarget });
    }
  }
}
