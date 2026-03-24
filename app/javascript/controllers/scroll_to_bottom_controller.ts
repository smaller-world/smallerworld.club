import { Controller } from "@hotwired/stimulus";

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
  }

  disconnect(): void {
    super.disconnect();
    this.#observer?.disconnect();
    this.#observer = null;
  }

  // == Helpers ==

  #scrollToBottom(): void {
    this.element.scrollTop = this.element.scrollHeight;
  }
}
