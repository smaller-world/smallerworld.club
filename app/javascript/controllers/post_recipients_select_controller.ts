import { Typed } from "stimulus-typescript";

import ApplicationController from "./application_controller";

const targets = {
  badge: HTMLElement,
  input: HTMLInputElement,
};

export default class PostRecipientsSelectcontroller extends Typed(
  ApplicationController<HTMLElement>,
  { targets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasBadgeTarget) {
      throw new Error("Missing badge target");
    }
  }

  // == Actions ==

  updateBadgeCount() {
    this.badgeTarget.innerText = this.#checkedInputCount().toString();
  }

  // == Helpers ==

  #checkedInputCount(): number {
    let count = 0;
    this.inputTargets.forEach((input) => {
      if (input.checked) {
        count += 1;
      }
    });
    return count;
  }
}
