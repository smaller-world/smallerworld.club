import { Controller } from "@hotwired/stimulus";
import { useIntersection } from "stimulus-use";

export default class ClickOnAppearController extends Controller<HTMLElement> {
  initialize(): void {
    super.initialize();
    useIntersection(this);
  }

  // == Actions ==

  click(): void {
    this.element.click();
  }
}
