import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  input: HTMLInputElement,
};

export default class MessagingPlatformDropdownController extends Typed(
  Controller<HTMLFormElement>,
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

  setInputValue(event: PointerEvent): void {
    const { currentTarget } = event;
    if (currentTarget instanceof HTMLButtonElement) {
      const { platform } = currentTarget.dataset;
      if (platform) {
        this.inputTarget.value = platform;
        this.element.requestSubmit();
      }
    }
  }
}
