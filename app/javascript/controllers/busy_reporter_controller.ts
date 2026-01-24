import { Controller } from "@hotwired/stimulus";

export default class BusyReporterController extends Controller<HTMLElement> {
  static targets = ["busyable"];
  declare readonly busyableTargets: readonly HTMLElement[];

  #observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (!(mutation.target instanceof HTMLElement)) {
        return;
      }
      this.element.ariaBusy = String(this.#isBusy(mutation.target));
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
