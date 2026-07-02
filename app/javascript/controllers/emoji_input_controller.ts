import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";
import invariant from "tiny-invariant";

import DialogController from "./dialog_controller";
import TippyController from "./tippy_controller";

const outlets = {
  dialog: DialogController,
};

export default class EmojiInputController extends Typed(
  Controller<HTMLInputElement>,
  { outlets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasDialogOutlet) {
      throw new Error("Missing dialog outlet");
    }
  }

  // == Actions ==

  setValue(emoji: string): void {
    this.element.value = emoji;
    this.element.dispatchEvent(new Event("input", { bubbles: true }));
    this.element.dispatchEvent(new Event("change", { bubbles: true }));
  }

  clearOrOpenDialog(): void {
    if (this.element.value) {
      this.element.value = "";
      this.element.dispatchEvent(new Event("change", { bubbles: true }));
    } else {
      this.dialogOutlet.open();
    }
  }

  updateTooltip(): void {
    this.#inputTippy.disabledValue = !this.element.value;
  }

  // == Helpers ==

  get #inputTippy(): TippyController {
    const controller = this.application.getControllerForElementAndIdentifier(
      this.element,
      "tippy",
    );
    invariant(controller instanceof TippyController);
    return controller;
  }
}
