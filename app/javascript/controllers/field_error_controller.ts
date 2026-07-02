import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  error: HTMLElement,
};

export default class FieldErrorController extends Typed(
  Controller<HTMLElement>,
  { targets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasErrorTarget) {
      throw new Error("Missing error target");
    }
  }

  // == Actions ==

  show(event: CustomEvent<{ message?: string }>): void {
    const { message } = event.detail;
    if (message) {
      this.errorTarget.textContent = message;
    }
  }
}
