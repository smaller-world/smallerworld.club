import { Controller } from "@hotwired/stimulus";

export default class DialogController extends Controller<HTMLDialogElement> {
  // == Actions ==

  open(): void {
    this.element.showModal();
  }

  close(): void {
    this.element.close();
  }
}
