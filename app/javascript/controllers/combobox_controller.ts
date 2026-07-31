import { Controller } from "@hotwired/stimulus";
import {} from "@tailwindplus/elements";
import { Typed } from "stimulus-typescript";

const targets = {
  input: HTMLInputElement,
  inlineStartAddon: HTMLElement,
};

const values = {
  clearOnExpand: {
    type: Boolean,
    default: true,
  },
};

export default class ComboboxController extends Typed(Controller<HTMLElement>, {
  targets,
  values,
}) {
  #validValues = new Set<string>();
  #lastSelectedValue = "";
  #inputMutationObserver = new MutationObserver(() => {
    if (this.inputTarget.ariaExpanded === "true") {
      this.#clearInputToRevealOptions();
      this.dispatch("expanded");
    }
  });

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTarget) {
      throw new Error("Missing input target");
    }
    this.#lastSelectedValue = this.inputTarget.defaultValue;
    this.#setValidValues();
    this.#setAnchorOffset();
    if (this.clearOnExpandValue) {
      this.#inputMutationObserver.observe(this.inputTarget, {
        attributes: true,
        attributeFilter: ["aria-expanded"],
      });
    }
  }

  inlineStartAddonConnected(): void {
    this.#setAnchorOffset();
  }

  inlineStartAddonDisconnected(): void {
    this.#setAnchorOffset();
  }

  disconnect(): void {
    super.disconnect();
    this.#inputMutationObserver.disconnect();
    this.#clearAnchorOffset();
  }

  // == Actions ==

  normalizeSelection(): void {
    if (this.#validValues.has(this.inputTarget.value)) {
      this.#lastSelectedValue = this.inputTarget.value;
    } else {
      this.inputTarget.value = this.#lastSelectedValue;
    }
  }

  blur(): void {
    this.inputTarget.blur();
  }

  // == Helpers ==

  #setValidValues(): void {
    this.#validValues.clear();
    const options = this.element.getElementsByTagName("el-option");
    for (const option of options) {
      if (option instanceof HTMLElement) {
        const value = option.getAttribute("value");
        if (typeof value === "string") {
          this.#validValues.add(value);
        }
      }
    }
  }

  #setAnchorOffset(): void {
    const containerOffset = this.element.getBoundingClientRect().left;
    const inputOffset = this.inputTarget.getBoundingClientRect().left;
    const anchorOffset = inputOffset - containerOffset;
    this.element.style.setProperty("--anchor-offset", `-${anchorOffset}px`);
  }

  #clearAnchorOffset(): void {
    this.element.style.removeProperty("--anchor-offset");
  }

  #clearInputToRevealOptions(): void {
    this.inputTarget.placeholder = this.#lastSelectedValue;
    this.inputTarget.value = "";
  }
}
