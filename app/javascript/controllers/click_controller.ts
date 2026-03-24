import { Controller } from "@hotwired/stimulus";

export default class ClickController extends Controller<HTMLElement> {
  // static targets = ["clickable"];
  // declare readonly clickableTarget: HTMLElement;
  // declare readonly hasClickableTarget: boolean;

  // == Actions ==

  click(): void {
    // if (this.hasClickableTarget) {
    //   this.clickableTarget.click();
    // } else {
    this.element.click();
    // }
  }
}
