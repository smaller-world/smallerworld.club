import invariant from "tiny-invariant";

import CheckboxController from "./checkbox_controller";

export default class RadioController extends CheckboxController {
  // == Values ==

  static values = {
    toggleable: Boolean,
  };
  declare readonly toggleableValue: boolean;

  // == Listeners ==

  #labelClickListener = this._handleLabelClick.bind(this);

  // == Lifecycle ==

  connect(): void {
    super.connect();
    const labels = this._locateLabels();
    if (labels) {
      for (const label of labels) {
        label.addEventListener("click", this.#labelClickListener);
      }
    }
  }

  disconnect(): void {
    super.disconnect();
    const labels = this._locateLabels();
    if (labels) {
      for (const label of labels) {
        label.removeEventListener("click", this.#labelClickListener);
      }
    }
  }

  // == Helpers ==

  _locateLabels(): NodeListOf<HTMLLabelElement> | null {
    const input = this._locateInput();
    return input.labels;
  }

  _handleInputChange(event: Event) {
    const { target } = event;
    invariant(target instanceof HTMLInputElement, "Invalid target");
    super._handleInputChange(event);
    const { form, checked, name } = target;
    if (checked && form && name) {
      if (form) {
        const otherRadios = form.querySelectorAll<HTMLInputElement>(
          `input[type=radio][name="${name}"]`,
        );
        for (const otherRadio of otherRadios) {
          if (otherRadio == target) {
            continue;
          }
          otherRadio.dispatchEvent(new Event("change", { bubbles: true }));
        }
      }
    }
  }

  _handleLabelClick(event: PointerEvent) {
    const input = this._locateInput();
    if (event.target === input) {
      return;
    }
    if (this.toggleableValue && input.checked) {
      event.preventDefault();
      input.checked = false;
      input.dispatchEvent(new Event("change"));
      input.dispatchEvent(new Event("input"));
    }
  }
}
