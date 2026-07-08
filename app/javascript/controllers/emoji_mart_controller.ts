import { Controller } from "@hotwired/stimulus";
import { Picker } from "emoji-mart";
import invariant from "tiny-invariant";

import { addBeforeCacheAction } from "#helpers/stimulus_helpers";

export default class EmojiMartController extends Controller<HTMLElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const picker = new Picker({
      onEmojiSelect: (data: { native: string }) => {
        const emoji = data.native;
        this.dispatch("select", { detail: { emoji } });
      },
    });
    invariant(picker instanceof HTMLElement);
    this.element.appendChild(picker);
    addBeforeCacheAction(this, "destroy");
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
