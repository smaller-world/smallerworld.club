import { Controller } from "@hotwired/stimulus";
import { useTransition } from "stimulus-use";

export default class DropdownController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["menu", "trigger"];
  declare readonly menuTarget: HTMLElement;
  declare readonly triggerTarget: HTMLElement;
  declare readonly hasTriggerTarget: boolean;

  // == useTransition ==

  transitioned?: boolean;
  toggleTransition?: (event?: Event) => void;
  leave?: (event?: Event) => Promise<void>;
  enter?: (event?: Event) => Promise<void>;

  // == Lifecycle ==

  initialize(): void {
    useTransition(this, {
      element: this.menuTarget,
      enterFrom: "opacity-0 scale-95",
      enterTo: "opacity-100 scale-100",
      leaveFrom: "opacity-100 scale-100",
      leaveTo: "opacity-0 scale-95",
    });
  }

  disconnect(): void {
    this.enter = undefined;
    this.leave = undefined;
    this.toggleTransition = undefined;
  }

  triggerTargetConnected(target: Element): void {
    target.ariaExpanded = String(this.#isExpanded);
  }

  // == Methods ==

  toggle(): void {
    if (!this.enter || !this.leave || typeof this.transitioned !== "boolean") {
      return;
    }
    if (this.transitioned) {
      void this.leave().then(() => {
        this.#removeHideListener();
        this.triggerTarget.ariaExpanded = "false";
      });
    } else {
      void this.enter().then(() => {
        this.#addHideListener();
        this.triggerTarget.ariaExpanded = "true";
      });
    }
  }

  hide(event: Event): void {
    if (!(event.target instanceof Node)) {
      return;
    }
    if (!this.leave) {
      return;
    }
    if (
      !this.element.contains(event.target) &&
      !this.menuTarget.classList.contains("hidden")
    ) {
      void this.leave().then(() => {
        this.#removeHideListener();
        this.triggerTarget.ariaExpanded = "false";
      });
    }
  }

  // == Expanded helpers ==

  get #isExpanded(): boolean {
    return !this.menuTarget.classList.contains("hidden");
  }

  // == Action helpers ==

  #addHideListener(): void {
    this.updateActions((actions) => {
      actions.add("click@window->dropdown#hide");
    });
  }

  #removeHideListener(): void {
    this.updateActions((actions) => {
      actions.remove("click@window->dropdown#hide");
    });
  }

  updateActions(update: (actions: DOMTokenList) => void): void {
    const parser = document.createElement("div");
    if (this.element.dataset.action) {
      parser.className = this.element.dataset.action;
    }
    update(parser.classList);
    this.element.dataset.action = parser.className;
  }
}
