import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";
import invariant from "tiny-invariant";

const targets = {
  categoryInput: HTMLInputElement,
  noteField: HTMLElement,
};

const values = {
  reportableLabel: String,
};

export default class ReportFormController extends Typed(Controller, {
  targets,
  values,
}) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasCategoryInputTarget) {
      throw new Error("Missing categoryInput target");
    }
    if (!this.hasNoteFieldTarget) {
      throw new Error("Missing noteField target");
    }
    if (!this.hasReportableLabelValue) {
      throw new Error("Missing reportableLabel value");
    }
    this.updateNoteField();
  }

  // == Actions ==

  updateNoteField(): void {
    if (this.categoryInputTarget.value) {
      this.dispatch("expand");
    }

    if (this.categoryInputTarget.value === "other") {
      this.#noteTextarea.required = true;
      this.#noteLabel.textContent = "note";
      this.#noteDescription.textContent =
        "please describe the issue you are having with this " +
        `${this.reportableLabelValue}.`;
    } else {
      this.#noteTextarea.required = false;
      this.#noteLabel.textContent = "note (optional)";
      this.#noteDescription.textContent =
        "additional details that could help our team better " +
        "understand the issue you are reporting.";
    }
  }

  // == Helpers ==

  get #noteTextarea(): HTMLTextAreaElement {
    const textarea = this.noteFieldTarget.querySelector("textarea");
    invariant(textarea instanceof HTMLTextAreaElement);
    return textarea;
  }

  get #noteLabel(): HTMLLabelElement {
    const label = this.noteFieldTarget.querySelector("label");
    invariant(label instanceof HTMLLabelElement);
    return label;
  }

  get #noteDescription(): HTMLParagraphElement {
    const description = this.noteFieldTarget.querySelector(
      "p[data-slot=field-description]",
    );
    invariant(description instanceof HTMLParagraphElement);
    return description;
  }
}
