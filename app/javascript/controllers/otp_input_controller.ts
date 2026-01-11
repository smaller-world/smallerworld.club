import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

import VanillaOTP from "#lib/vanilla-otp";

// TODO: Implement WebOTP API?
//
// See: https://developer.mozilla.org/en-US/docs/Web/API/WebOTP_API
export default class OTPInputController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["container", "input"];

  declare readonly containerTarget: HTMLElement;
  declare readonly hasContainerTarget: boolean;

  declare readonly inputTarget: HTMLInputElement;
  declare readonly hasInputTarget: boolean;

  // == State ==

  #vanillaOTP?: VanillaOTP | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    invariant(this.hasContainerTarget, "Missing container target");
    invariant(this.hasInputTarget, "Missing input target");
    this.#vanillaOTP = new VanillaOTP(this.containerTarget, this.inputTarget);
    this.#vanillaOTP.setValue(this.inputTarget.value);
  }

  disconnect(): void {
    super.disconnect();
    if (this.#vanillaOTP) {
      this.#vanillaOTP.destroy();
      this.#vanillaOTP = null;
    }
  }

  // == Actions ==

  selectInputText({ target }: FocusEvent): void {
    if (target instanceof HTMLInputElement) {
      requestAnimationFrame(() => {
        target.select();
      });
    }
  }
}
