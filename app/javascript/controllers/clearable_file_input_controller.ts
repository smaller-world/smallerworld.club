import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

import { addAction } from "#helpers/stimulus_helpers";

const targets = {
  inputTemplate: HTMLTemplateElement,
  spinner: HTMLElement,
};

export default class ClearableFileInputController extends Typed(
  Controller<HTMLElement>,
  { targets },
) {
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
