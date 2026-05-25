import { Controller } from "@hotwired/stimulus";

import { addAction, addCleanupAction } from "#helpers/stimulus_helpers";

export default class FormController extends Controller<HTMLFormElement> {
  // == Targets ==

  static targets = ["disableWhileSubmitting"];
  declare readonly disableWhileSubmittingTargets: HTMLCollectionOf<
    HTMLInputElement | HTMLButtonElement
  >;

  // == Lifecycle ==

  connected(): void {
    addAction(this, "turbo:submit-start", "disableWhileSubmitting");
    addAction(this, "turbo:submit-end", "enableAfterSubmitting");
    addCleanupAction(this, "enableAfterSubmitting");
  }

  // == Actions ==

  submit(): void {
    this.element.requestSubmit();
  }

  disableWhileSubmitting(): void {
    for (const target of this.disableWhileSubmittingTargets) {
      target.disabled = true;
    }
  }

  enableAfterSubmitting(): void {
    for (const target of this.disableWhileSubmittingTargets) {
      target.disabled = false;
    }
  }
}
