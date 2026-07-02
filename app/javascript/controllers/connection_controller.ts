import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const values = {
  delay: { type: Number, default: 0 },
};

export default class ConnectionController extends Typed(Controller, {
  values,
}) {
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
