import { Controller } from "@hotwired/stimulus";

export default class SelectController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["trigger"];
  declare readonly triggerTarget: HTMLElement;
  declare readonly hasTriggerTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasTriggerTarget) {
      throw new Error("Missing trigger target");
    }
  }

  // == Actions ==

  updatePlaceholder() {
    const selected = this.element.querySelector<HTMLElement>(
      "el-option[aria-selected=true]",
    );
    if (selected) {
      delete this.triggerTarget.dataset.placeholder;
    } else {
      this.triggerTarget.dataset.placeholder = "true";
    }
  }
}
