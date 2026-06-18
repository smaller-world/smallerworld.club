import { Controller } from "@hotwired/stimulus";
import { isEmpty } from "lodash-es";
import invariant from "tiny-invariant";

import { addCleanupAction } from "#helpers/stimulus_helpers";

import FormController from "./form_controller";
import type { PassData } from "./passes_bridge_controller";

export default class DevicePassesFormController extends Controller<HTMLFormElement> {
  // == Targets ==

  static targets = [...FormController.targets, "inputTemplate", "input"];
  declare readonly inputTemplateTarget: HTMLTemplateElement;
  declare readonly hasInputTemplateTarget: boolean;
  declare readonly inputTargets: HTMLCollectionOf<HTMLInputElement>;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasInputTemplateTarget) {
      throw new Error("Missing inputTemplate target");
    }
    addCleanupAction(this, "removeInputs");
  }

  // == Actions ==

  submitPasses(event: CustomEvent<{ passes: PassData[] }>): void {
    const { passes } = event.detail;
    if (isEmpty(passes)) {
      return;
    }
    for (const pass of passes) {
      const { firstChild } = this.inputTemplateTarget.content;
      invariant(firstChild instanceof HTMLInputElement);
      const input = firstChild.cloneNode() as HTMLInputElement;
      input.value = pass.serialNumber;
      this.element.appendChild(input);
    }
    this.element.requestSubmit();
  }

  removeInputs(): void {
    for (const input of this.inputTargets) {
      input.remove();
    }
  }
}
