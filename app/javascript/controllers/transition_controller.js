import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "el-transition";

export default class TransitionController extends Controller {
  // == Actions ==

  enter() {
    console.debug("transition entering", this.element);
    enter(this.element).then(() => {
      this.dispatch("entered", { bubbles: false });
      this.dispatch("transitioned", { bubbles: false });
    });
  }

  leave() {
    console.debug("transition leaving", this.element);
    leave(this.element).then(() => {
      this.dispatch("exited", { bubbles: false });
      this.dispatch("transitioned", { bubbles: false });
    });
  }

  toggle() {
    if (this.element.classList.contains("hidden")) {
      this.enter();
    } else {
      this.leave();
    }
  }
}
