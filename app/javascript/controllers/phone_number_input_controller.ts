import { Controller } from "@hotwired/stimulus";
import intlTelInput, { type Iso2 } from "intl-tel-input";
import { Typed } from "stimulus-typescript";

import "intl-tel-input/styles";

const targets = {
  input: HTMLInputElement,
  hiddenInput: HTMLInputElement,
};

export default class PhoneNumberInputController extends Typed(
  Controller<HTMLInputElement>,
  { targets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTarget) {
      throw new Error("Missing input target");
    }
    if (!this.hasHiddenInputTarget) {
      throw new Error("Missing hiddenInput target");
    }
    intlTelInput(this.inputTarget, {
      loadUtils: () => import("intl-tel-input/utils"),
      countrySelectorMode: "DROPDOWN",
      separateDialCode: true,
      initialCountry: this.#initialCountry(),
    });
  }

  // == Actions ==

  updateHiddenInput(): void {
    const iti = intlTelInput.getInstance(this.inputTarget);
    if (iti) {
      this.hiddenInputTarget.value = iti.getNumber("E164");
    }
  }

  // == Helpers ==

  #initialCountry(): Iso2 {
    const { locale } = Intl.DateTimeFormat().resolvedOptions();
    const { region } = new Intl.Locale(locale);
    if (region) {
      return region.toLocaleLowerCase() as Iso2;
    }
    return "ca";
  }
}
