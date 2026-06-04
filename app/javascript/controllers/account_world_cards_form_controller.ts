import { isEmpty } from "lodash-es";
import invariant from "tiny-invariant";

import { addCleanupAction } from "#helpers/stimulus_helpers";

import FormController from "./form_controller";
import type { PassData } from "./passes_bridge_controller";

export default class AccountWorldCardsFormController extends FormController {
  // == Targets ==

  static targets = [
    ...FormController.targets,
    "inputTemplate",
    "existingInput",
    "addedInput",
  ];
  declare readonly inputTemplateTarget: HTMLTemplateElement;
  declare readonly hasInputTemplateTarget: boolean;
  declare readonly existingInputTargets: HTMLCollectionOf<HTMLInputElement>;
  declare readonly addedInputTargets: HTMLCollectionOf<HTMLInputElement>;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTemplateTarget) {
      throw new Error("Missing inputTemplate target");
    }
    addCleanupAction(this, "removeAddedInputs");
  }

  // == Actions ==

  submitPasses(event: CustomEvent<{ passes: PassData[] }>): void {
    const existingSerialNumbers = this.#existingSerialNumbers();
    const newSerialNumbers = new Set<string>();
    const { passes } = event.detail;
    for (const pass of passes) {
      if (existingSerialNumbers.has(pass.serialNumber)) {
        continue;
      }
      newSerialNumbers.add(pass.serialNumber);
      const { firstChild } = this.inputTemplateTarget.content;
      invariant(firstChild instanceof HTMLInputElement);
      const input = firstChild.cloneNode() as HTMLInputElement;
      input.value = pass.serialNumber;
      this.element.appendChild(input);
    }
    if (!isEmpty(newSerialNumbers)) {
      this.requestSubmit();
    }
  }

  removeAddedInputs(): void {
    for (const input of this.addedInputTargets) {
      input.remove();
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
