import { Controller } from "@hotwired/stimulus";

export default class ClickController extends Controller<HTMLElement> {
  // == Actions ==

  click(): void {
    this.element.click();
  }
}
