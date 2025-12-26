import { Controller } from "@hotwired/stimulus";

export default class EmojiToggleInputController extends Controller<HTMLInputElement> {
  // == Actions ==

  clearEmojiOrOpenPicker(): void {
    if (this.element.value) {
      this.element.value = "";
    } else {
      this.dispatch("open-picker");
    }
  }
}
