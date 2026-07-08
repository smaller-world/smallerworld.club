import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  control: HTMLInputElement,
};

export default class InputGroupAddonController extends Typed(Controller, {
  targets,
}) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasControlTarget) {
      throw new Error("Missing control target");
    }
  }

  // == Actions ==

  focusInput(): void {
    this.controlTarget.focus();
  }

  clearInput(): void {
    this.controlTarget.value = "";
  }
}
