import { Controller } from "@hotwired/stimulus";

export default class ReplyInitiationFormController extends Controller<HTMLFormElement> {
  // == Targets ==

  static targets = ["platformInput"];
  declare readonly platformInputTarget: HTMLInputElement;
  declare readonly hasPlatformInputTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasPlatformInputTarget) {
      throw new Error("Missing platformInput target");
    }
  }

  // == Actions ==

  setPlatformValue(event: PointerEvent): void {
    const { currentTarget } = event;
    if (currentTarget instanceof HTMLButtonElement) {
      const { platform } = currentTarget.dataset;
      if (platform) {
        this.platformInputTarget.value = platform;
        this.element.requestSubmit();
      }
    }
  }
}
