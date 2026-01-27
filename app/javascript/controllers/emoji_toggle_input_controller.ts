import { Controller } from "@hotwired/stimulus";

export default class EmojiToggleInputController extends Controller<HTMLInputElement> {
  // == Actions ==

  clearEmojiOrOpenPicker(): void {
    if (this.element.value) {
      this.element.value = "";
      this.element.dispatchEvent(new Event("change", { bubbles: true }));
    } else {
      this.dispatch("open-picker");
    }
  }
}
