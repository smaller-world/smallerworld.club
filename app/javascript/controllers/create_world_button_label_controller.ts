import { Controller } from "@hotwired/stimulus";

export default class CreateWorldButtonLabelController extends Controller {
  // == Targets ==

  static targets = ["nameInput", "label"];
  declare readonly nameInputTarget: HTMLInputElement;
  declare readonly labelTarget: HTMLSpanElement;
  declare readonly hasNameInputTarget: boolean;
  declare readonly hasLabelTarget: boolean;

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
