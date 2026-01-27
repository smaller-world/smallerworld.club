import { Controller } from "@hotwired/stimulus";

export default class EmojiPickerController extends Controller<HTMLElement> {
  static targets = ["input"];
  declare readonly inputTarget: HTMLInputElement;

  // == Actions ==

  setEmoji(event: CustomEvent<{ native: string }>): void {
    this.inputTarget.value = event.detail.native;
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }));
  }
}
