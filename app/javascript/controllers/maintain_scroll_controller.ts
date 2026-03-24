import { Controller } from "@hotwired/stimulus";

// Maintains scroll position when content is prepended to a scrollable container.
//
// Disables CSS scroll anchoring (which would double-adjust), then on each
// child-list mutation: scrollTop += (newScrollHeight - oldScrollHeight).
export default class MaintainScrollController extends Controller<HTMLElement> {
  // == State ==

  #previousScrollHeight = 0;
  #observer?: MutationObserver | null;
  #pendingFrame?: number | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    // Disable browser scroll anchoring so we handle it ourselves.
    this.element.style.overflowAnchor = "none";
    this.#previousScrollHeight = this.element.scrollHeight;
    this.#observer = new MutationObserver(() => this.#scheduleRestore());
    this.#observer.observe(this.element, { childList: true, subtree: true });
  }

  disconnect(): void {
    super.disconnect();
    if (this.#pendingFrame) {
      cancelAnimationFrame(this.#pendingFrame);
      this.#pendingFrame = null;
    }
    this.#observer?.disconnect();
    this.#observer = null;
  }

  // == Helpers ==

  // Batch multiple mutations (e.g. pagination replace + message prepend)
  // into a single scroll adjustment per animation frame.
  #scheduleRestore(): void {
    if (!this.#pendingFrame) {
      this.#pendingFrame = requestAnimationFrame(() => {
        this.#pendingFrame = null;
        this.#restoreScroll();
      });
    }
  }

  #restoreScroll(): void {
    const newScrollHeight = this.element.scrollHeight;
    const delta = newScrollHeight - this.#previousScrollHeight;
    if (delta !== 0) {
      this.element.scrollTop += delta;
    }
    this.#previousScrollHeight = newScrollHeight;
  }
}
