import FormController from "./form_controller";

export default class ReplyInitiationFormController extends FormController {
  // == Targets ==

  static targets = ["platformInput"];
  declare readonly platformInputTarget: HTMLInputElement;
  declare readonly hasPlatformInputTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
  }

  // == Actions ==

  setPlatformValue(event: MouseEvent): void {
    const { currentTarget } = event;
    if (currentTarget instanceof HTMLButtonElement) {
      const { platform } = currentTarget.dataset;
      if (platform) {
        this.platformInputTarget.value = platform;
        this.requestSubmit();
      }
    }
  }
}
