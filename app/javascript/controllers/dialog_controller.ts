import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

import { addCleanupAction } from "#helpers/stimulus_helpers";

const targets = {
  content: HTMLDialogElement,
};

export default class DialogController extends Typed(Controller<HTMLElement>, {
  targets,
}) {
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
