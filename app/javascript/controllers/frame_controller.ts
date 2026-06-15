import { Controller } from "@hotwired/stimulus";
import type {
  FrameElement,
  TurboBeforeFetchResponseEvent,
  TurboLoadEvent,
} from "@hotwired/turbo";
import { isEmpty } from "lodash-es";

export default class FrameController extends Controller<FrameElement> {
  // == Actions ==

  reloadAndPersistScroll(event: Event): void {
    const isBusy = this.element.hasAttribute("busy");
    if (isBusy) {
      console.debug("Skipping reload (busy)");
      return;
    }
    if (this.#isTurboLoadEvent(event) && this.#isFirstLoad(event)) {
      console.debug("Skipping reload (first load)");
      return;
    }
    this.#whilePreservingHeight(() => this.element.reload());
  }

  reloadWhenNotFound(event: TurboBeforeFetchResponseEvent): void {
    const { response } = event.detail.fetchResponse;
    if (response.status === 404) {
      void this.element.reload();
    }
  }

  // == Helpers ==

  #isTurboLoadEvent(event: Event): event is TurboLoadEvent {
    return event instanceof CustomEvent && event.type == "turbo:load";
  }

  #isFirstLoad(event: TurboLoadEvent): boolean {
    return isEmpty(event.detail.timing);
  }

  #whilePreservingHeight(callback: () => Promise<void>): void {
    const { height } = this.element.getBoundingClientRect();
    const { minHeight } = getComputedStyle(this.element);
    const overrideMinHeight = parseFloat(minHeight) < height;
    if (overrideMinHeight) {
      this.element.style.minHeight = `${height}px`;
    }
    void callback().finally(() => {
      if (overrideMinHeight) {
        if (minHeight == null) {
          this.element.style.removeProperty("min-height");
        } else {
          this.element.style.minHeight = minHeight;
        }
      }
    });
  }
}
