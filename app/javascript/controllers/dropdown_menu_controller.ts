import { Controller } from "@hotwired/stimulus";
import type { TurboClickEvent } from "@hotwired/turbo";
import { Typed } from "stimulus-typescript";

import {
  addAction,
  addBeforeCacheAction,
  waitForTransitionAnimations,
} from "#helpers/stimulus_helpers";
import type { ElDropdownMenu } from "#helpers/tailwind_plus_helpers";

const targets = {
  menu: HTMLElement,
};

export default class DropdownMenuController extends Typed(
  Controller<HTMLElement>,
  { targets },
) {
  declare readonly menuTarget: ElDropdownMenu;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasMenuTarget) {
      throw new Error("Missing menu target");
    }
    addAction(this, "turbo:click", "delayVisitUntilClosed");
    addBeforeCacheAction(this, "closeImmediately");
  }

  // == Actions ==

  preventAutoClose(event: Event): void {
    event.stopImmediatePropagation();
  }

  close(): void {
    if (this.menuTarget.open) {
      this.menuTarget.hidePopover();
    }
  }

  closeImmediately(): void {
    this.close();
    for (const animation of this.menuTarget.getAnimations()) {
      animation.finish();
    }
  }

  delayVisitUntilClosed(event: TurboClickEvent): void {
    event.preventDefault();
    event.detail.originalEvent.preventDefault();
    this.close();
    void waitForTransitionAnimations(this.menuTarget).then(() => {
      requestAnimationFrame(() => {
        Turbo.visit(event.detail.url);
      });
    });
  }
}
