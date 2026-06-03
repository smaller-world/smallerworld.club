import invariant from "tiny-invariant";

import FormController from "./form_controller";
import type { PassData } from "./passes_bridge_controller";

export default class AccountWorldCardsFormController extends FormController {
  // == Targets ==

  static targets = [
    ...FormController.targets,
    "inputTemplate",
    "existingInput",
  ];
  declare readonly inputTemplateTarget: HTMLTemplateElement;
  declare readonly hasInputTemplateTarget: boolean;
  declare readonly existingInputTargets: HTMLCollectionOf<HTMLInputElement>;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTemplateTarget) {
      throw new Error("Missing inputTemplate target");
    }
  }

  // == Actions ==

  submitPasses(event: CustomEvent<{ passes: PassData[] }>): void {
    const existingSerialNumbers = this.#existingSerialNumbers();
    const newSerialNumbers = new Set<string>();
    const { passes } = event.detail;
    for (const pass of passes) {
      if (pass.serialNumber in existingSerialNumbers) {
        continue;
      }
      newSerialNumbers.add(pass.serialNumber);
      const { firstChild } = this.inputTemplateTarget.content;
      invariant(firstChild instanceof HTMLInputElement);
      const input = firstChild.cloneNode() as HTMLInputElement;
      input.value = pass.serialNumber;
      this.element.appendChild(input);
    }
    if (newSerialNumbers.size > 0) {
      this.requestSubmit();
    }
  }

  // == Helpers ==

  #existingSerialNumbers(): Set<string> {
    const serialNumbers = new Set<string>();
    for (const input of this.existingInputTargets) {
      serialNumbers.add(input.value);
    }
    return serialNumbers;
  }
}
