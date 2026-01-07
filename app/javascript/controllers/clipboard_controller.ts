import { Controller } from "@hotwired/stimulus";

export default class ClipboardController extends Controller {
  static values = {
    copy: String,
  };
  declare readonly copyValue: string;

  // == Actions ==

  copy() {
    void navigator.clipboard.writeText(this.copyValue).then(() => {
      this.dispatch("copied");
    });
  }
}
