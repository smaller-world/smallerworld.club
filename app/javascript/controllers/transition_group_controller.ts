import { Controller } from "@hotwired/stimulus";

export default class TransitionGroupController extends Controller {
  static targets = ["item"];
  declare readonly itemTargets: HTMLCollectionOf<HTMLElement>;

  // == Actions ==

  startNext(event: Event): void {
    if (!(event.target instanceof HTMLElement)) {
      return;
    }
    const nextItem = this.#nextItemTargetAfter(event.target);
    if (nextItem) {
      this.dispatch("start", { target: nextItem });
    }
  }

  // == Helpers ==

  #nextItemTargetAfter(item: HTMLElement): HTMLElement | undefined {
    for (let i = 0; i < this.itemTargets.length; i++) {
      if (this.itemTargets[i] === item) {
        return this.itemTargets[i + 1];
      }
    }
  }
}
