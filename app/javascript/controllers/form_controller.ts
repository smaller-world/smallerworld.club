import { Controller } from "@hotwired/stimulus";

import { addAction, addCleanupAction } from "#helpers/stimulus_helpers";

export default class FormController extends Controller<HTMLFormElement> {
  // == Targets ==

  static targets = ["disableWhileSubmitting"];
  declare readonly disableWhileSubmittingTargets: HTMLCollectionOf<
    HTMLInputElement | HTMLButtonElement
  >;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    addAction(this, "turbo:submit-start", "disableTargetsWhileSubmitting");
    addAction(this, "turbo:submit-end", "enableTargetsAfterSubmitting");
    addCleanupAction(this, "enableAfterSubmitting");
  }

  // == Actions ==

  requestSubmit(): void {
    this.element.requestSubmit();
  }

  disableTargetsWhileSubmitting(): void {
    for (const target of this.disableWhileSubmittingTargets) {
      target.disabled = true;
    }
  }

  enableTargetsAfterSubmitting(): void {
    for (const target of this.disableWhileSubmittingTargets) {
      target.disabled = false;
    }
  }
}
