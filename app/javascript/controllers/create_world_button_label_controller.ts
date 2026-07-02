import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  nameInput: HTMLInputElement,
  label: HTMLSpanElement,
};

export default class CreateWorldButtonLabelController extends Typed(
  Controller,
  { targets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasNameInputTarget) {
      throw new Error("Missing nameInput target");
    }
    this.update();
  }

  // == Actions ==

  update(): void {
    if (!this.hasLabelTarget) {
      return;
    }
    const { value } = this.nameInputTarget;
    this.labelTarget.textContent = value ? `create ${value}` : `create world`;
  }
}
