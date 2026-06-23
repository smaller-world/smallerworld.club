import { Controller } from "@hotwired/stimulus";

export default class ConnectionController extends Controller {
  // == Values ==

  static values = {
    delay: { type: Number, default: 0 },
  };
  declare readonly delayValue: number;

  // == Properties ==

  #delayTimeout?: number | null;

  // == Lifecycle ==

  connect(): void {
    this.#delayTimeout = setTimeout(() => {
      this.dispatch("connect", { bubbles: false });
    }, this.delayValue);
  }

  disconnect(): void {
    if (this.#delayTimeout) {
      clearTimeout(this.#delayTimeout);
      this.#delayTimeout = null;
    }
    this.dispatch("disconnect", { bubbles: false });
  }
}
