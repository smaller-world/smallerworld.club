import arrayToSentence from "array-to-sentence";
import { isEmpty } from "lodash-es";

import FormController from "./form_controller";

export default class PostFormController extends FormController {
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
    const keyColors = this.#keyColors();
    let audience: string | undefined;
    if (isEmpty(keyColors)) {
      audience = "only you";
    } else if (keyColors.length < this.keyColorsInputTargets.length) {
      const keyColorsDescriptor = arrayToSentence(keyColors);
      audience = `${keyColorsDescriptor} key friends`;
    } else {
      audience = "all friends";
    }
    this.keyColorsDescriptionTarget.textContent = `${audience} can see this post`;
  }

  #keyColors(): string[] {
    return Array.from(this.keyColorsInputTargets).flatMap((input) =>
      input.checked ? [input.value] : [],
    );
  }
}
