import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  trigger: HTMLElement,
};

export default class SelectController extends Typed(Controller<HTMLElement>, {
  targets,
}) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasTriggerTarget) {
      throw new Error("Missing trigger target");
    }
  }

  // == Actions ==

  update() {
    const selected = this.element.querySelector<HTMLElement>(
      "el-option[aria-selected=true]",
    );
    if (selected) {
      const value = selected.getAttribute("value");
      if (value) {
        this.element.setAttribute("value", value);
      }
      delete this.triggerTarget.dataset.placeholder;
    } else {
      this.element.removeAttribute("value");
      this.triggerTarget.dataset.placeholder = "true";
    }
  }
}
