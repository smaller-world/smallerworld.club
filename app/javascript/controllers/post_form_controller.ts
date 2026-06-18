import { Controller } from "@hotwired/stimulus";
import arrayToSentence from "array-to-sentence";
import { isEmpty } from "lodash-es";

export default class PostFormController extends Controller<HTMLFormElement> {
  // == Values ==

  static values = {
    worldKeyLabels: Object,
  };
  declare readonly worldKeyLabelsValue: Record<string, string>;

  // == Targets ==

  static targets = ["worldKeyColorsInput", "worldKeyColorsDescription"];
  declare readonly worldKeyColorsInputTargets: HTMLCollectionOf<HTMLInputElement>;
  declare readonly worldKeyColorsDescriptionTarget: HTMLElement;
  declare readonly hasWorldKeyColorsDescriptionTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasWorldKeyColorsDescriptionTarget) {
      throw new Error("Missing worldKeyColorsDescription target");
    }
    this.updateWorldKeyColorsDescription();
  }

  // == Actions ==

  updateWorldKeyColorsDescription(): void {
    const worldKeyLabels = this.#activeWorldKeyLabels();
    let audience: string | undefined;
    if (isEmpty(worldKeyLabels)) {
      audience = "only you";
    } else if (worldKeyLabels.length < this.worldKeyColorsInputTargets.length) {
      audience = `${arrayToSentence(worldKeyLabels)} key friends`;
    } else {
      audience = '<span class="text-foreground">all friends</span>';
    }
    this.worldKeyColorsDescriptionTarget.innerHTML = `${audience} can see this post`;
  }

  // == Helpers ==

  #activeWorldKeyColors(): string[] {
    return Array.from(this.worldKeyColorsInputTargets).flatMap((input) =>
      input.checked ? [input.value] : [],
    );
  }

  #activeWorldKeyLabels(): string[] {
    return this.#activeWorldKeyColors().map((color) => {
      const label = this.worldKeyLabelsValue[color] ?? color;
      return `<span class="text-foreground">${label}</span>`;
    });
  }
}
