import { Controller } from "@hotwired/stimulus";

export default class DropdownController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["menu", "trigger"];
  declare readonly menuTarget: HTMLElement;
  declare readonly triggerTarget: HTMLElement;
  declare readonly hasTriggerTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.#removeHideListener();
    // useTransition(this, {
    //   element: this.menuTarget,
    //   enterFrom: "opacity-0 scale-95",
    //   enterTo: "opacity-100 scale-100",
    //   leaveFrom: "opacity-100 scale-100",
    //   leaveTo: "opacity-0 scale-95",
    // });
  }

  disconnect(): void {
    super.disconnect();
    this.#removeHideListener();
  }

  triggerTargetConnected(target: Element): void {
    target.ariaExpanded = String(this.#isExpanded);
  }

  // == Methods ==

  expand(): void {
    this.menuTarget.classList.remove("hidden");
    this.triggerTarget.ariaExpanded = "true";
    this.#addHideListener();
  }

  collapse(): void {
    this.#removeHideListener();
    this.menuTarget.classList.add("hidden");
    this.triggerTarget.ariaExpanded = null;
  }

  toggle(): void {
    if (this.#isExpanded) {
      this.collapse();
    } else {
      this.expand();
    }
  }

  hide(event: Event): void {
    if (event.target instanceof Node && this.element.contains(event.target)) {
      return;
    }
    this.collapse();
  }

  // == Expansion helpers ==

  get #isExpanded(): boolean {
    return !this.menuTarget.classList.contains("hidden");
  }

  // == Action helpers ==

  #addHideListener(): void {
    this.#updateActions((actions) => {
      actions.add("click@window->dropdown#hide");
    });
  }

  #removeHideListener(): void {
    this.#updateActions((actions) => {
      actions.remove("click@window->dropdown#hide");
    });
  }

  #updateActions(update: (actions: DOMTokenList) => void): void {
    const parser = document.createElement("div");
    if (this.element.dataset.action) {
      parser.className = this.element.dataset.action;
    }
    update(parser.classList);
    this.element.dataset.action = parser.className;
  }
}
