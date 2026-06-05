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
      this.#downloadFileAtUrl(fetchResponse.location.toString());
      setTimeout(() => {
        window.location.href = "/";
      }, 1000);
    }
  }

  // == Helpers ==

  #downloadFileAtUrl(url: string): void {
    const link = document.createElement("a");
    link.href = url;
    link.download = "";
    link.hidden = true;
    document.body.appendChild(link);
    link.click();
    link.remove();
  }
}
