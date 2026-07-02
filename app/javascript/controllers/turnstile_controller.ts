import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

import { addAction, addCleanupAction } from "#helpers/stimulus_helpers";

const values = {
  sitekey: String,
  action: String,
};

export default class TurnstileController extends Typed(
  Controller<HTMLElement>,
  { values },
) {
  #widgetId?: string | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if ("turnstile" in window) {
      this.render();
    } else {
      addAction(this, "turnstile:load@document", "render");
    }
  }

  disconnect(): void {
    this.reset();
  }

  // == Actions ==

  render(): void {
    this.#widgetId = window.turnstile.render(this.element, {
      sitekey: this.sitekeyValue,
      action: this.actionValue,
    });
    addCleanupAction(this, "reset");
  }

  reset(): void {
    if (this.#widgetId) {
      window.turnstile.reset(this.#widgetId);
      this.#widgetId = null;
    }
  }
}
