import { Controller } from "@hotwired/stimulus";
import Toastify from "toastify-js";

export default class ToastController extends Controller<HTMLTemplateElement> {
  // == Values ==
  static values = {
    duration: {
      type: Number,
      default: 2000,
    },
  };
  declare readonly durationValue: number;

  // == Lifecycle ==

  connect(): void {
    super.connect();

    requestIdleCallback(() => {
      const toastify = Toastify({
        className: this.element.className,
        text: this.element.content.textContent,
        duration: this.durationValue,
        gravity: "top",
        position: "center",
        onClick: () => {
          this.dispatch("click");
        },
      });
      toastify.showToast();
    });
  }
}
