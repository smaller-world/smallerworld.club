import { Controller } from "@hotwired/stimulus";

export default class ConnectionController extends Controller {
  // == Values ==

  static values = {
    delay: { type: Number, default: 0 },
  };
  declare readonly delayValue: number;

  // == Lifecycle ==

  connect(): void {
    setTimeout(() => {
      this.dispatch("connect", { bubbles: false });
    }, this.delayValue);
  }

  disconnect(): void {
    this.dispatch("disconnect", { bubbles: false });
  }
}
