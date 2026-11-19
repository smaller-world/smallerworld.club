import { Controller } from "@hotwired/stimulus";

import { addAction } from "#helpers/stimulus_helpers";

export default class AutoplayController extends Controller<HTMLVideoElement> {
  // == Lifecycle ==

  connect(): void {
    addAction(this, "turbo:load@document", "play");
    if (this.#videoRequiresLoading) {
      this.dispatch("loading");
    }
  }

  // == Actions ==

  play(): void {
    void this.#play();
  }

  // == Helpers ==

  async #play(): Promise<void> {
    try {
      await this.element.play();
    } catch (error) {
      if (error instanceof Error && error.name === "NotAllowedError") {
        this.dispatch("unplayable");
      } else {
        console.warn("Video play failed", error);
      }
      throw error;
    }
  }

  get #videoRequiresLoading(): boolean {
    const { readyState, networkState, HAVE_FUTURE_DATA, NETWORK_LOADING } =
      this.element;
    return readyState < HAVE_FUTURE_DATA && networkState === NETWORK_LOADING;
  }
}
