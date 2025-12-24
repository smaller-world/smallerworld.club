import { Controller } from "@hotwired/stimulus";

export default class EmojiFieldController extends Controller<HTMLElement> {
  static targets = ["input", "pickerDropdown"];
  declare readonly inputTarget: HTMLInputElement;
  declare readonly pickerDropdownTarget: HTMLElement;

  // == Actions ==

  setEmoji(event: CustomEvent<{ native: string }>): void {
    this.inputTarget.value = event.detail.native;
  }

  openPickerOrClearEmoji(): void {
    if (this.inputTarget.value) {
      this.inputTarget.value = "";
    } else {
      this.dispatch("open-picker", {
        target: this.pickerDropdownTarget,
      });
    }
  }
}
