import { Controller } from "@hotwired/stimulus";

export default class StreamedToastController extends Controller<HTMLTemplateElement> {
  // == Values ==

  static values = {
    type: String,
  };
  declare readonly typeValue: string;

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
