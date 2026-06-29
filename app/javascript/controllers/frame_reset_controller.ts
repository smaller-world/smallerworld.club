import { Controller } from "@hotwired/stimulus";
import type { FrameElement } from "@hotwired/turbo";

export default class FrameResetController extends Controller<FrameElement> {
  // == Actions ==

  reset(): void {
    const { src } = this.element;
    const url = new URL(src);
    url.search = "";
    this.element.src = url.toString();
  }
}
