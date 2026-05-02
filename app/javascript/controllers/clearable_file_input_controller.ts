import { Controller } from "@hotwired/stimulus";

import { addAction } from "#helpers/stimulus_helpers";

export default class ClearableFileInputController extends Controller<HTMLElement> {
  static targets = ["inputTemplate", "spinner"];
  declare readonly inputTemplateTarget: HTMLTemplateElement;
  declare readonly spinnerTarget: HTMLElement;
  declare readonly hasInputTemplateTarget: boolean;
  declare readonly hasSpinnerTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    if (!this.hasInputTemplateTarget) {
      throw new Error("Missing target: inputTemplate");
    }
    addAction(this, "direct-upload:start", "showSpinner");
    addAction(this, "direct-upload:end", "hideSpinner");
    super.connect();
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
