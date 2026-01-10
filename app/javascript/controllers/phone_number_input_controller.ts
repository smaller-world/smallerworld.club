import { Controller } from "@hotwired/stimulus";
import parsePhone from "phone";
import invariant from "tiny-invariant";

export default class PhoneNumberInputController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["input", "countryCodeInput", "nationalNumberInput"];

  declare readonly inputTarget: HTMLInputElement;
  declare readonly hasInputTarget: boolean;

  declare readonly countryCodeInputTarget: HTMLInputElement;
  declare readonly hasCountryCodeInputTarget: boolean;

  declare readonly nationalNumberInputTarget: HTMLInputElement;
  declare readonly hasNationalNumberInputTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    invariant(this.hasInputTarget, "Missing input target");
    invariant(
      this.hasCountryCodeInputTarget,
      "Missing countryCodeInput target",
    );
    invariant(
      this.hasNationalNumberInputTarget,
      "Missing nationalNumberInput target",
    );
  }

  // == Actions ==

  update(): void {
    const countryCode = this.countryCodeInputTarget.value;
    const nationalNumber = this.nationalNumberInputTarget.value;
    if (!countryCode || !nationalNumber) {
      this.inputTarget.value = "";
      return;
    }

    const phoneNumber = [countryCode, nationalNumber].join(" ");
    const phone = parsePhone(phoneNumber);
    if (phone.isValid) {
      this.inputTarget.value = phone.phoneNumber;
    } else {
      this.inputTarget.value = "";
    }
  }
}
