import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";
import invariant from "tiny-invariant";

const values = {
  copy: String,
};

export default class ClipboardController extends Typed(Controller, { values }) {
  // == Actions ==

  copy() {
    invariant(this.copyValue, "No text to copy");
    void navigator.clipboard.writeText(this.copyValue).then(() => {
      this.dispatch("copied");
    });
  }
}
