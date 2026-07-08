import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";
import invariant from "tiny-invariant";

import CheckboxProxyController from "./checkbox_proxy_controller";

const values = {
  toggleable: Boolean,
};

export default class RadioGroupItemController extends Typed(
  Controller<HTMLInputElement>,
  {
    values,
  },
) {
  // == Actions ==

  updateOtherItems = (): void => {
    const { form, checked, name } = this.element;
    if (checked && form && name) {
      const item = form.elements.namedItem(name);
      if (item instanceof RadioNodeList) {
        for (const radio of item) {
          this.#updateOtherRadio(radio);
        }
      }
    }
  };

  // == Helpers ==

  #updateOtherRadio(radio: HTMLInputElement): void {
    if (radio !== this.element) {
      radio.checked = false;
      const proxy = this.#locateRadioProxy(radio);
      const controller = this.application.getControllerForElementAndIdentifier(
        proxy,
        "checkbox-proxy",
      );
      if (controller instanceof CheckboxProxyController) {
        controller.update();
      }
    }
  }

  #locateRadioProxy(radio: HTMLInputElement): HTMLSpanElement {
    const { previousElementSibling } = radio;
    invariant(
      previousElementSibling instanceof HTMLSpanElement,
      "Missing proxy",
    );
    return previousElementSibling;
  }
}
