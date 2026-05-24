import { Controller } from "@hotwired/stimulus";

export default class FieldController extends Controller<HTMLElement> {
  static targets = ["error"];
  declare readonly errorTarget: HTMLElement;
  declare readonly hasErrorTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasErrorTarget) {
      throw new Error("Missing error target");
    }
  }

  // == Actions ==

  showError(event: CustomEvent<{ message?: string }>): void {
    const { message } = event.detail;
    if (message) {
      this.errorTarget.textContent = message;
    }
  }
}
