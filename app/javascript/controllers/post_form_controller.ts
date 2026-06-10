import arrayToSentence from "array-to-sentence";
import { isEmpty } from "lodash-es";

import FormController from "./form_controller";

export default class PostFormController extends FormController {
  // == Values ==

  static values = {
    keyLabels: Object,
  };
  declare readonly keyLabelsValue: Record<string, string>;

  // == Targets ==

  static targets = ["keyColorsInput", "keyColorsDescription"];
  declare readonly keyColorsInputTargets: HTMLCollectionOf<HTMLInputElement>;
  declare readonly keyColorsDescriptionTarget: HTMLElement;
  declare readonly hasKeyColorsDescriptionTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasKeyColorsDescriptionTarget) {
      throw new Error("Missing keyColorsDescription target");
    }
    this.updateKeyColorsDescription();
  }

  // == Actions ==

  updateKeyColorsDescription(): void {
    const keyLabels = this.#activeKeyLabels();
    let audience: string | undefined;
    if (isEmpty(keyLabels)) {
      audience = "only you";
    } else if (keyLabels.length < this.keyColorsInputTargets.length) {
      audience = `${arrayToSentence(keyLabels)} key friends`;
    } else {
      audience = '<span class="text-foreground">all friends</span>';
    }
    this.keyColorsDescriptionTarget.innerHTML = `${audience} can see this post`;
  }

  #activeKeyColors(): string[] {
    return Array.from(this.keyColorsInputTargets).flatMap((input) =>
      input.checked ? [input.value] : [],
    );
  }

  #activeKeyLabels(): string[] {
    return this.#activeKeyColors().map((color) => {
      const label = this.keyLabelsValue[color] ?? color;
      return `<span class="text-foreground">${label}</span>`;
    });
  }
}
