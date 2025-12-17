import { Controller } from "@hotwired/stimulus";

/** @extends {Controller<HTMLFormElement>} */
export default class extends Controller {
  static targets = ["busyable", "submit"];

  declare readonly busyableTargets: readonly HTMLElement[];
  declare readonly submitTarget: HTMLButtonElement;

  #observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (!(mutation.target instanceof HTMLElement)) {
        return;
      }
      const isBusy = this.#isBusy(mutation.target);
      this.submitTarget.disabled = isBusy;
    });
  });

  busyableTargetConnected(target: HTMLElement): void {
    this.#observer.observe(target, {
      attributes: true,
      attributeFilter: ["aria-busy"],
    });
  }

  busyableTargetDisconnected() {
    this.#observer.disconnect();
  }

  #isBusy(target: HTMLElement): boolean {
    return target.getAttribute("aria-busy") === "true";
  }
}
