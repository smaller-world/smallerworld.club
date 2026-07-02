import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

export default class ClickController extends Controller<HTMLElement> {
  // == Actions ==

  click(): void {
    this.element.click();
  }
}
