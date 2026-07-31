import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";
import invariant from "tiny-invariant";

const targets = {
  control: HTMLElement,
  content: HTMLElement,
};

export default class CollapseController extends Typed(Controller<HTMLElement>, {
  targets,
}) {
  #resizeObserver = new ResizeObserver(() => {
    this.#updateContentStyle();
  });

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasControlTarget) {
      throw new Error("Missing control target");
    }
    if (!this.hasContentTarget) {
      throw new Error("Missing content target");
    }
    const { firstElementChild } = this.contentTarget;
    invariant(firstElementChild instanceof HTMLElement, `Invalid content`);
    this.#resizeObserver.observe(firstElementChild);
  }

  disconnect(): void {
    super.disconnect();
    this.#resizeObserver.disconnect();
  }

  // == Actions ==

  trigger(): void {
    const markExpanded = () => {
      this.element.dataset.userExpanded = "";
      this.element.removeEventListener("transitionend", markExpanded);
    };
    this.element.addEventListener("transitionend", markExpanded);
    this.element.dataset.collapsed = "false";
    this.controlTarget.ariaExpanded = "true";
  }

  // == Helpers ==

  #updateContentStyle(): void {
    const { scrollHeight } = this.contentTarget;
    this.contentTarget.style.setProperty(
      "--content-height",
      `${scrollHeight}px`,
    );
    if ("userExpanded" in this.element.dataset) {
      return;
    }
    if (scrollHeight > this.contentTarget.clientHeight) {
      this.element.dataset.collapsed = "true";
      this.controlTarget.ariaExpanded = "false";
    } else {
      delete this.element.dataset.collapsed;
      this.controlTarget.ariaExpanded = null;
    }
  }
}
