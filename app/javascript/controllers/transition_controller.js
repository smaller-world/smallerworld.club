import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "el-transition";
import { Typed } from "stimulus-typescript";

const values = {
  delay: Number,
};

export default class TransitionController extends Typed(Controller, {
  values,
}) {
  // == Actions ==

  enter() {
    // console.debug("transition entering", this.element);
    this.#withDelay(() => {
      enter(this.element).then(() => {
        this.dispatch("entered", { bubbles: false });
        this.dispatch("transitioned", { bubbles: false });
      });
    });
  }

  leave() {
    // console.debug("transition leaving", this.element);
    this.#withDelay(() => {
      leave(this.element).then(() => {
        this.dispatch("exited", { bubbles: false });
        this.dispatch("transitioned", { bubbles: false });
      });
    });
  }

  toggle() {
    if (this.element.classList.contains("hidden")) {
      this.enter();
    } else {
      this.leave();
    }
  }

  // == Helpers ==

  #withDelay(fn) {
    if (this.delayValue) {
      setTimeout(fn, this.delayValue);
    } else {
      fn();
    }
  }
}
