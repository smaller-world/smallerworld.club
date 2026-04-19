import { Controller } from "@hotwired/stimulus";

import { addAction } from "#helpers/stimulus_helpers";

export default class ClearableFileInputController extends Controller<HTMLElement> {
  static targets = ["inputTemplate", "spinner"];
  declare readonly inputTemplateTarget: HTMLTemplateElement;
  declare readonly spinnerTarget: HTMLElement;
  declare readonly hasInputTemplateTarget: boolean;
  declare readonly hasSpinnerTarget: boolean;

  // == Lifecycle ==

  initialize(): void {
    super.initialize();
    if (!this.hasInputTemplateTarget) {
      throw new Error("Missing inputTemplateTarget");
    }
    if (!this.hasSpinnerTarget) {
      throw new Error("Missing spinnerTarget");
    }
  }

  connect(): void {
    super.connect();
    addAction(this, "direct-upload:start", "showSpinner");
    addAction(this, "direct-upload:end", "hideSpinner");
  }

  // == Actions ==

  clearAttachedFile(): void {
    const templateInput = this.inputTemplateTarget.content.cloneNode(true);
    this.element.replaceChildren(templateInput);
  }

  // == Helpers ==

  showSpinner(): void {
    this.spinnerTarget.classList.remove("hidden");
  }

  hideSpinner(): void {
    this.spinnerTarget.classList.add("hidden");
  }
}
