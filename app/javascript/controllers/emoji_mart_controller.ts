import { Controller } from "@hotwired/stimulus";
import { Picker } from "emoji-mart";

export default class EmojiMartController extends Controller<HTMLElement> {
  connect(): void {
    super.connect();
    const picker = new Picker({
      onEmojiSelect: (data: any) => {
        this.dispatch("select", { detail: data });
      },
    });
    this.element.appendChild(picker as any);
  }

  disconnect(): void {
    super.disconnect();
    this.element.replaceChildren();
  }
}
