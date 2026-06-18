import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "el-transition";

export default class TransitionController extends Controller {
  // == Values ==

  static values = {
    delay: Number,
  };

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
