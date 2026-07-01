import { Controller } from "@hotwired/stimulus";

export default class MessagingPlatformDropdownController extends Controller<HTMLFormElement> {
  // == Targets ==

  static targets = ["input"];
  declare readonly inputTarget: HTMLInputElement;
  declare readonly hasInputTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTarget) {
      throw new Error("Missing input target");
    }
  }

  // == Actions ==

  setInputValue(event: PointerEvent): void {
    const { currentTarget } = event;
    if (currentTarget instanceof HTMLButtonElement) {
      const { platform } = currentTarget.dataset;
      if (platform) {
        this.inputTarget.value = platform;
        this.element.requestSubmit();
      }
    }
  }
}
