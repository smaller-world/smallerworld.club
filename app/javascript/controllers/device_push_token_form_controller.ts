import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  input: HTMLInputElement,
};

export default class DevicePushTokenFormController extends Typed(
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

  setInputValueAndSubmit({ detail }: CustomEvent<{ token: string }>): void {
    const { token } = detail;
    const previousValue = this.inputTarget.value;
    this.inputTarget.value = token;
    if (token !== previousValue) {
      this.element.requestSubmit();
    }
  }
}
