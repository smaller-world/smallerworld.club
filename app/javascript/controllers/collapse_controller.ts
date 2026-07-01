import { Controller } from "@hotwired/stimulus";

export default class CollapseController extends Controller<HTMLElement> {
  static targets = ["control", "content"];
  declare readonly controlTarget: HTMLElement;
  declare readonly contentTarget: HTMLElement;
  declare readonly hasControlTarget: boolean;
  declare readonly hasContentTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasControlTarget) {
      throw new Error("Missing control target");
    }
    if (!this.hasContentTarget) {
      throw new Error("Missing content target");
    }
    this.#updateAttributes();
  }

  // == Actions ==

  trigger(): void {
    this.element.dataset.collapsed = "false";
    this.controlTarget.ariaExpanded = "true";
  }

  // == Helpers ==

  #updateAttributes(): void {
    const { scrollHeight } = this.contentTarget;
    this.contentTarget.style.setProperty(
      "--content-height",
      `${scrollHeight}px`,
    );
    if (scrollHeight > this.contentTarget.clientHeight) {
      this.element.dataset.collapsed = "true";
      this.controlTarget.ariaExpanded = "false";
    } else {
      delete this.element.dataset.collapsed;
      this.controlTarget.ariaExpanded = null;
    }
  }
}
