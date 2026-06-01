import FormController from "./form_controller";

export default class WorldFormController extends FormController {
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
    this.updateSubmitButtonLabel();
  }

  // == Actions ==

  updateSubmitButtonLabel(): void {
    if (!this.hasSubmitButtonLabelTarget) {
      return;
    }
    const { value } = this.nameInputTarget;
    this.submitButtonLabelTarget.textContent = value
      ? `create ${value}`
      : `create world`;
  }
}
