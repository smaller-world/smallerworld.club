import { Controller } from "@hotwired/stimulus";
import type { TurboClickEvent } from "@hotwired/turbo";
import { Typed } from "stimulus-typescript";

import { addBeforeCacheAction } from "#helpers/stimulus_helpers";

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
    addBeforeCacheAction(this, "closeImmediately");
  }

  // == Actions ==

  open(): void {
    this.contentTarget.showModal();
    requestAnimationFrame(() => {
      this.dispatch("opened");
    });
  }

  close(): void {
    this.contentTarget.close();
  }

  closeImmediately(): void {
    this.contentTarget.requestClose();
  }

  closeAndClick(event: MouseEvent): void {
    if (!this.contentTarget.open) {
      return;
    }
    const { currentTarget } = event;
    if (!(currentTarget instanceof HTMLElement)) {
      return;
    }

    event.preventDefault();
    this.contentTarget.addEventListener(
      "transitionend",
      () => {
        currentTarget.click();
      },
      { once: true },
    );
    this.contentTarget.close();
  }
}
