import { Controller } from "@hotwired/stimulus";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class DialogController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["content"];
  declare readonly contentTarget: HTMLDialogElement;
  declare readonly hasContentTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasContentTarget) {
      throw new Error("Missing content target");
    }

    addCleanupAction(this, "close");
  }
  // == Actions ==

  open(): void {
    this.contentTarget.showModal();
  }

  close(): void {
    this.contentTarget.requestClose();
  }
}
