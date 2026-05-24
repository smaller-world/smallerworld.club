import { Controller } from "@hotwired/stimulus";

export default class AccountFormController extends Controller {
  // == Targets ==

  static targets = ["nameInput", "submitButtonLabel"];
  declare readonly nameInputTarget: HTMLInputElement;
  declare readonly submitButtonLabelTarget: HTMLSpanElement;
  declare readonly hasNameInputTarget: boolean;
  declare readonly hasSubmitButtonLabelTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasNameInputTarget) {
      throw new Error("Missing nameInput target");
    }
    if (!this.hasSubmitButtonLabelTarget) {
      throw new Error("Missing submitButtonLabel target");
    }
  }

  // == Actions ==

  updateSubmitButtonLabel(): void {
    const { value } = this.nameInputTarget;
    this.submitButtonLabelTarget.textContent = value
      ? `create ${value}'s world`
      : `create your world`;
  }
}
