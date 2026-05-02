import { Controller } from "@hotwired/stimulus";
import { Maskito } from "@maskito/core";
import { maskitoPhoneOptionsGenerator } from "@maskito/phone";
import type { CountryCode } from "libphonenumber-js/core";
import { parsePhoneNumber } from "libphonenumber-js/core";

export default class PhoneNumberInputController extends Controller {
  static targets = [
    "countryCodeInput",
    "countryCodeOption",
    "countryFlagAddon",
    "nationalNumberInput",
    "hiddenInput",
  ];
  declare readonly countryCodeInputTarget: HTMLInputElement;
  declare readonly nationalNumberInputTarget: HTMLInputElement;
  declare readonly countryFlagAddonTarget: HTMLElement;
  declare readonly hiddenInputTarget: HTMLInputElement;

  declare readonly hasCountryCodeInputTarget: boolean;
  declare readonly hasNationalNumberInputTarget: boolean;
  declare readonly hasCountryFlagAddonTarget: boolean;
  declare readonly hasHiddenInputTarget: boolean;

  #countryCodeOptions = new Map<
    string,
    { value: string; flagTemplate: HTMLTemplateElement }
  >();
  #inputCountryCodeObserver = new MutationObserver(() => {
    const { countryCode } = this.countryCodeInputTarget.dataset;
    if (typeof countryCode === "string") {
      this.#updateCountryFlagAddon(countryCode);
      void this.#initializeNationalNumberMaskito(countryCode);
    }
  });
  #nationalNumberMaskito: Maskito | null = null;

  // == Lifecycle ==

  connect(): void {
    if (!this.hasCountryCodeInputTarget) {
      throw new Error("Missing target: countryCodeInput");
    }
    if (!this.hasNationalNumberInputTarget) {
      throw new Error("Missing target: nationalNumberInput");
    }
    if (!this.hasCountryFlagAddonTarget) {
      throw new Error("Missing target: countryFlagAddon");
    }
    if (!this.hasHiddenInputTarget) {
      throw new Error("Missing target: hiddenInput");
    }

    this.#inputCountryCodeObserver.observe(this.countryCodeInputTarget, {
      attributes: true,
    });
    const initialCountryCode = this.#inputCountryCode;
    if (initialCountryCode) {
      void this.#initializeNationalNumberMaskito(initialCountryCode);
    }
    super.connect();
  }

  disconnect(): void {
    if (this.#nationalNumberMaskito) {
      this.#nationalNumberMaskito.destroy();
      this.#nationalNumberMaskito = null;
    }
    this.#inputCountryCodeObserver.disconnect();
    super.disconnect();
  }

  countryCodeOptionTargetConnected(option: HTMLElement): void {
    const { countryCode } = option.dataset;
    const value = option.getAttribute("value");
    const flagTemplate = option.querySelector('template[data-template="flag"]');
    if (
      typeof value === "string" &&
      typeof countryCode === "string" &&
      flagTemplate instanceof HTMLTemplateElement
    ) {
      this.#countryCodeOptions.set(countryCode, { value, flagTemplate });
    } else {
      throw new Error("Malformed country code option");
    }
  }

  // == Actions ==

  normalizeCountryCode(): void {
    if (!this.countryCodeInputTarget.value.startsWith("+")) {
      this.countryCodeInputTarget.value = `+${this.countryCodeInputTarget.value}`;
    }
  }

  setCountryCode(event: PointerEvent): void {
    const option = this.#locateOptionElement(event.target);
    if (option) {
      const { countryCode } = option.dataset;
      if (typeof countryCode === "string") {
        this.countryCodeInputTarget.dataset.countryCode = countryCode;
      }
    }
  }

  guessCountryCodeIfNeeded(): void {
    const { value, dataset } = this.countryCodeInputTarget;
    const { countryCode } = dataset;
    if (typeof countryCode === "string") {
      const option = this.#countryCodeOptions.get(countryCode);
      if (option?.value === value) {
        return;
      }
    }

    const guessedCountryCode = this.#guessCountryCodeFromValue(value);
    if (guessedCountryCode) {
      dataset.countryCode = guessedCountryCode;
    }
  }

  async updateHiddenInput(): Promise<void> {
    const { default: metadata } =
      await import("libphonenumber-js/min/metadata");
    const phoneNumber = [
      this.countryCodeInputTarget.value,
      this.nationalNumberInputTarget.value,
    ].join(" ");
    const parsedNumber = parsePhoneNumber(phoneNumber, metadata);
    console.log({ parsedNumber, isValid: parsedNumber.isValid() });
    this.hiddenInputTarget.value = parsedNumber.format("E.164");
  }

  // == Helpers ==

  async #initializeNationalNumberMaskito(countryCode: string): Promise<void> {
    if (this.#nationalNumberMaskito) {
      this.#nationalNumberMaskito.destroy();
    }
    const { default: metadata } =
      await import("libphonenumber-js/min/metadata");
    const options = maskitoPhoneOptionsGenerator({
      countryIsoCode: countryCode as CountryCode,
      metadata,
      format: "NATIONAL",
      strict: true,
    });
    this.#nationalNumberMaskito = new Maskito(
      this.nationalNumberInputTarget,
      options,
    );
  }

  #updateCountryFlagAddon(countryCode: string): void {
    const option = this.#countryCodeOptions.get(countryCode);
    if (option) {
      const flagElement = option.flagTemplate.content.cloneNode(true);
      this.countryFlagAddonTarget.replaceChildren(flagElement);
    }
  }

  #locateOptionElement(target: EventTarget | null): HTMLElement | null {
    if (target instanceof HTMLElement) {
      if (target.tagName === "el-option") {
        return target;
      }
      return target.closest("el-option");
    }
    return null;
  }

  #guessCountryCodeFromValue(value: string): string | null {
    switch (value) {
      case "+1":
        return "US";
      case "+7":
        return "RU";
      default:
        for (const [
          countryCode,
          option,
        ] of this.#countryCodeOptions.entries()) {
          if (option.value === value) {
            return countryCode;
          }
        }
    }
    return null;
  }

  get #inputCountryCode(): string | undefined {
    return this.countryCodeInputTarget.dataset.countryCode;
  }
}
