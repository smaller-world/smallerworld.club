import { Controller } from "@hotwired/stimulus";

export default class EmojiInputController extends Controller<HTMLElement> {
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

  setEmoji(event: CustomEvent<{ native: string }>): void {
    this.inputTarget.value = event.detail.native;
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }));
  }

  clearOrOpenDialog(): void {
    if (this.inputTarget.value) {
      this.inputTarget.value = "";
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }));
    } else {
      this.dispatch("open-dialog");
    }
  }
}
