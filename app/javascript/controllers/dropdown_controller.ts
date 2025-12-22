import { Controller } from "@hotwired/stimulus";
import { useTransition } from "stimulus-use";

export default class DropdownController extends Controller {
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
    if (!this.toggleTransition || typeof this.transitioned !== "boolean") {
      return;
    }
    const previouslyExpanded = this.#isExpanded;
    this.toggleTransition();
    if (this.hasTriggerTarget) {
      this.triggerTarget.ariaExpanded = String(!previouslyExpanded);
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
      void this.leave();
      if (this.hasTriggerTarget) {
        this.triggerTarget.ariaExpanded = "false";
      }
    }
  }

  get #isExpanded(): boolean {
    return !this.menuTarget.classList.contains("hidden");
  }
}
