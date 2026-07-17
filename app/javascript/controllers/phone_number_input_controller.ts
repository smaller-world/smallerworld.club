import { Controller } from "@hotwired/stimulus";
import intlTelInput, { type Iso2, type Iti } from "intl-tel-input";
import { Typed } from "stimulus-typescript";

import { addAction, addBeforeCacheAction } from "#helpers/stimulus_helpers";

const targets = {
  input: HTMLInputElement,
  hiddenInput: HTMLInputElement,
};

export default class PhoneNumberInputController extends Typed(
  Controller<HTMLInputElement>,
  { targets },
) {
  #iti?: Iti | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTarget) {
      throw new Error("Missing input target");
    }
    if (!this.hasHiddenInputTarget) {
      throw new Error("Missing hiddenInput target");
    }
    this.#iti = intlTelInput(this.inputTarget, {
      loadUtils: () => import("intl-tel-input/utils"),
      countrySelectorMode: "DROPDOWN",
      separateDialCode: true,
      initialCountry: this.#initialCountry(),
    });
    addBeforeCacheAction(this, "destroy");
  }

  disconnect(): void {
    this.destroy();
  }

  // == Actions ==

  updateHiddenInput(): void {
    const iti = intlTelInput.getInstance(this.inputTarget);
    if (iti) {
      this.hiddenInputTarget.value = iti.getNumber("E164");
    }
  }

  destroy(): void {
    if (this.#iti) {
      this.#iti.destroy();
      this.#iti = null;
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
