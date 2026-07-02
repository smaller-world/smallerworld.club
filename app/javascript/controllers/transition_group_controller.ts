import { Controller } from "@hotwired/stimulus";
import { first } from "lodash-es";
import { Typed } from "stimulus-typescript";

const targets = {
  item: HTMLElement,
};

export default class TransitionGroupController extends Typed(Controller, {
  targets,
}) {
  // == Actions ==

  start(): void {
    const item = first(this.itemTargets);
    if (item) {
      this.dispatch("start", { target: item, bubbles: false });
    }
  }

  startNext(event: Event): void {
    if (!(event.target instanceof HTMLElement)) {
      return;
    }
    const nextItem = this.#nextItemTargetAfter(event.target);
    if (nextItem) {
      this.dispatch("start", { target: nextItem, bubbles: false });
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
