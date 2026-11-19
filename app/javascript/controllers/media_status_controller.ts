import { Controller } from "@hotwired/stimulus";

export default class MediaStatusController extends Controller<HTMLMediaElement> {
  // == Lifecycle ==

  connect(): void {
    if (this.#loadingRequired) {
      this.dispatch("loading-required");
    }
  }

  // == Helpers ==

  get #loadingRequired(): boolean {
    const { readyState, HAVE_FUTURE_DATA } = this.element;
    return readyState < HAVE_FUTURE_DATA;
  }
}
