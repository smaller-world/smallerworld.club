import { Controller } from "@hotwired/stimulus";
import Toastify from "toastify-js";

export default class ClipboardController extends Controller {
  static values = {
    copyText: String,
    copiedText: String,
    toastDuration: {
      type: Number,
      default: 2000,
    },
  };
  declare readonly copyTextValue: string;
  declare readonly copiedTextValue: string;
  declare readonly toastDurationValue: number;

  // == Actions ==

  copy() {
    void navigator.clipboard.writeText(this.copyTextValue).then(() => {
      this.dispatch("copied");
      const toastify = Toastify({
        text: this.copiedTextValue,
        duration: this.toastDurationValue,
        gravity: "top",
        position: "center",
        onClick: () => {
          this.dispatch("toast-click");
        },
      });
      toastify.showToast();
    });
  }
}
