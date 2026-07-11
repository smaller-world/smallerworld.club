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
    const { dataset, content } = this.element;
    const { title } = dataset;
    this.dispatch("toast", {
      prefix: "",
      detail: {
        message: content.textContent,
        type: this.typeValue,
        title,
      },
    });
  }
}
