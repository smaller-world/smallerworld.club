import { Controller } from "@hotwired/stimulus";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class ScrollToBottomController extends Controller<HTMLElement> {
  // == State ==

  #hasScrolledOnce = false;
  #observer?: ResizeObserver | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.#observer = new ResizeObserver(() => {
      if (!this.#hasScrolledOnce) {
        this.#hasScrolledOnce = true;
        this.#scrollToBottom();
      }
    });
    this.#observer.observe(this.element);
    addCleanupAction(this, "stop");
  }

  disconnect(): void {
    super.disconnect();
    this.stop();
  }

  // == Actions ==

  stop(): void {
    if (this.#observer) {
      this.#observer.disconnect();
      this.#observer = null;
    }
  }

  // == Helpers ==

  #scrollToBottom(): void {
    this.element.scrollTop = this.element.scrollHeight;
  }
}
