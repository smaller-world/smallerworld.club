import invariant from "tiny-invariant";

import CheckboxController from "./checkbox_controller";

export default class RadioController extends CheckboxController {
  // == Helpers ==

  handleInputChange(event: Event) {
    super.handleInputChange(event);
    const { target } = event;
    invariant(target instanceof HTMLInputElement, "Invalid target");
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
}
