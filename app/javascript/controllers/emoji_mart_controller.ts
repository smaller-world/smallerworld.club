import { Controller } from "@hotwired/stimulus";
import { Picker } from "emoji-mart";
import { Typed } from "stimulus-typescript";
import invariant from "tiny-invariant";

import { addCleanupAction } from "#helpers/stimulus_helpers";

import DialogController from "./dialog_controller";
import EmojiInputController from "./emoji_input_controller";

const outlets = {
  dialog: DialogController,
  "emoji-input": EmojiInputController,
};

export default class EmojiMartController extends Typed(
  Controller<HTMLElement>,
  { outlets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const picker = new Picker({
      onEmojiSelect: (data: { native: string }) => {
        const emoji = data.native;
        if (this.hasEmojiInputOutlet) {
          this.emojiInputOutlet.setValue(emoji);
        }
        if (this.hasDialogOutlet) {
          this.dialogOutlet.close();
        }
        this.dispatch("select", { detail: { emoji } });
      },
    });
    invariant(picker instanceof HTMLElement);
    this.element.appendChild(picker);
    addCleanupAction(this, "destroy");
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
  }

  // == Actions ==

  destroy(): void {
    this.element.replaceChildren();
  }
}
