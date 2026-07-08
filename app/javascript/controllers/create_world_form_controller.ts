import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  nameInput: HTMLInputElement,
  submitLabel: HTMLSpanElement,
};

export default class CreateWorldFormController extends Typed(Controller, {
  targets,
}) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasNameInputTarget) {
      throw new Error("Missing nameInput target");
    }
    this.updateSubmitLabel();
  }

  // == Actions ==

  updateSubmitLabel(): void {
    if (this.hasSubmitLabelTarget) {
      const { value } = this.nameInputTarget;
      this.submitLabelTarget.textContent = value
        ? `create ${value}`
        : `create world`;
    }
  }
}
