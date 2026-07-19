import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  submitButton: HTMLButtonElement,
};

export default class PhoneNumberVerificationFormController extends Typed(
  Controller,
  {
    targets,
  },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasSubmitButtonTarget) {
      throw new Error("Missing submitButton target");
    }
  }

  // == Actions ==

  enableSubmitButton(): void {
    this.submitButtonTarget.disabled = false;
  }
}
