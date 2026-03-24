import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

export default class ClipboardController extends Controller {
  static values = {
    copy: String,
  };
  declare readonly copyValue: string;

  // == Actions ==

  copy() {
    invariant(this.copyValue, "No text to copy");
    void navigator.clipboard.writeText(this.copyValue).then(() => {
      this.dispatch("copied");
    });
  }
}
