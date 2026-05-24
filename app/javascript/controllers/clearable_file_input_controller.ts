import { Controller } from "@hotwired/stimulus";

import { addAction } from "#helpers/stimulus_helpers";

export default class ClearableFileInputController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["inputTemplate", "spinner"];
  declare readonly inputTemplateTarget: HTMLTemplateElement;
  declare readonly spinnerTarget: HTMLElement;
  declare readonly hasInputTemplateTarget: boolean;
  declare readonly hasSpinnerTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTemplateTarget) {
      throw new Error("Missing inputTemplate target");
    }
    addAction(this, "direct-upload:start", "showSpinner");
    addAction(this, "direct-upload:end", "hideSpinner");
  }

  // == Actions ==

  clearAttachedFile(): void {
    const input = this.inputTemplateTarget.content.cloneNode(true);
    this.element.replaceChildren(input);
  }

  // == Helpers ==

  showSpinner(): void {
    this.spinnerTarget.classList.remove("hidden");
  }

  hideSpinner(): void {
    this.spinnerTarget.classList.add("hidden");
  }
}
