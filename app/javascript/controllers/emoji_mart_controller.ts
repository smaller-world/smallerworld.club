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

  focusSearch(): void {
    const { firstElementChild } = this.element;
    if (firstElementChild instanceof HTMLElement) {
      const { shadowRoot } = firstElementChild;
      if (shadowRoot) {
        const searchInput = shadowRoot.querySelector("input[type=search]");
        if (searchInput instanceof HTMLInputElement) {
          searchInput.focus();
        }
      }
    }
  }

  destroy(): void {
    this.element.replaceChildren();
  }
}
