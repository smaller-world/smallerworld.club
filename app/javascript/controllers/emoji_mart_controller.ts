import { Controller } from "@hotwired/stimulus";
import { Picker } from "emoji-mart";
import invariant from "tiny-invariant";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class EmojiMartController extends Controller<HTMLElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const picker = new Picker({
      onEmojiSelect: (data: any) => {
        this.dispatch("select", { detail: data });
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
