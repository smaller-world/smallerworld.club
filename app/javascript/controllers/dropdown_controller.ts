import { Controller } from "@hotwired/stimulus";

import {
  addAction,
  addCleanupAction,
  removeAction,
} from "#helpers/stimulus_helpers";

export default class DropdownController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["menu", "trigger"];
  declare readonly menuTarget: HTMLElement;
  declare readonly triggerTarget: HTMLElement;
  declare readonly hasTriggerTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.element.ariaHasPopup ??= "true";
    addCleanupAction(this, "hide");
  }

  disconnect(): void {
    super.disconnect();
    this.#collapse();
  }

  triggerTargetConnected(target: Element): void {
    target.ariaExpanded = String(this.#isExpanded);
  }

  // == Actions ==

  toggle(): void {
    if (this.#isExpanded) {
      this.#collapse();
    } else {
      this.#expand();
    }
  }

  hide(event: Event): void {
    if (event.target instanceof Node && this.element.contains(event.target)) {
      return;
    }
    this.#collapse();
  }

  // == Helpers ==

  get #isExpanded(): boolean {
    return !this.menuTarget.classList.contains("hidden");
  }

  #expand(): void {
    this.menuTarget.classList.remove("hidden");
    this.triggerTarget.ariaExpanded = "true";
    this.#addHideAction();
  }

  #collapse(): void {
    this.#removeHideAction();
    this.menuTarget.classList.add("hidden");
    this.triggerTarget.ariaExpanded = null;
  }

  #addHideAction(): void {
    addAction(this, "click@window", "hide");
  }

  #removeHideAction(): void {
    removeAction(this, "click@window", "hide");
  }
}
