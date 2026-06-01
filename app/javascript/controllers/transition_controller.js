import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "el-transition";

export default class TransitionController extends Controller {
  // == Actions ==

  enter() {
    enter(this.element).then(() => {
      this.dispatch("entered");
      this.dispatch("transitioned");
    });
  }

  leave() {
    leave(this.element).then(() => {
      this.dispatch("left");
      this.dispatch("transitioned");
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
