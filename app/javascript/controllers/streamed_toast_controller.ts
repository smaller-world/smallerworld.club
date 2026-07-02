import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const values = {
  type: String,
};

export default class StreamedToastController extends Typed(
  Controller<HTMLTemplateElement>,
  { values },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const { textContent } = this.element.content;
    this.dispatch("toast", {
      prefix: "",
      detail: {
        message: textContent,
        type: this.typeValue,
      },
    });
  }
}
