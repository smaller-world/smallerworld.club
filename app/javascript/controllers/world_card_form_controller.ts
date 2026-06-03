import type { TurboSubmitEndEvent } from "@hotwired/turbo";

import { addAction } from "#helpers/stimulus_helpers";

import FormController from "./form_controller";

export default class WorldCardFormController extends FormController {
  // == Targets ==

  static targets = ["submitButton"];
  declare readonly submitButtonTarget: HTMLButtonElement;
  declare readonly hasSubmitButtonTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasSubmitButtonTarget) {
      throw new Error("Missing submitButton target");
    }
    addAction(this, "turbo:submit-end", "downloadPass");
  }

  // == Actions ==

  downloadPass(event: TurboSubmitEndEvent): void {
    const { success, fetchResponse } = event.detail;
    if (success && fetchResponse) {
      event.preventDefault();
      this.submitButtonTarget.disabled = true;
      this.submitButtonTarget.innerText = "card is downloading...";
      window.location.href = fetchResponse.location.toString();
    }
  }
}
