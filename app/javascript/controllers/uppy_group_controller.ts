import { Controller } from "@hotwired/stimulus";
import type { Meta, MinimalRequiredUppyFile } from "@uppy/core";
import { isEmpty } from "lodash-es";

export default class UppyGroupController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["dndTemplate", "dnd"];
  declare readonly dndTemplateTarget: HTMLTemplateElement;
  declare readonly dndTargets: HTMLCollectionOf<HTMLDivElement>;
  declare readonly hasDndTemplateTarget: boolean;

  // == Values ==

  static values = {
    maxFiles: Number,
  };
  declare readonly maxFilesValue: number;

  // == Properties ==

  #filesToUpload: MinimalRequiredUppyFile<Meta, { signed_id: string }>[] = [];

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasDndTemplateTarget) {
      throw new Error("Missing dndTemplate target");
    }
  }

  // == Actions ==

  update(): void {
    this.#removeEmptyDndTargets();
    this.#addDndTargets();
    this.#updateDndValues();
    if (this.#countNonEmptyDndTargets() === this.maxFilesValue) {
      this.#filesToUpload = [];
    }
  }

  removeDnd({ target }: PointerEvent): void {
    if (this.dndTargets.length <= 1) {
      return;
    }
    if (!(target instanceof HTMLElement)) {
      return;
    }
    for (const dnd of this.dndTargets) {
      if (dnd.contains(target)) {
        dnd.remove();
      }
    }
    this.update();
  }

  addUploads({
    detail,
  }: CustomEvent<{
    files: MinimalRequiredUppyFile<Meta, { signed_id: string }>[];
  }>) {
    this.#filesToUpload = detail.files;
  }

  startNextUpload({ target }: CustomEvent): void {
    const [file, ...remainingFiles] = this.#filesToUpload;
    if (target instanceof HTMLElement && file) {
      this.#filesToUpload = remainingFiles;
      this.dispatch("upload", { target, detail: { file } });
    }
  }

  // == Helpers ==

  #addDndTargets(): void {
    if (this.maxFilesValue && this.dndTargets.length >= this.maxFilesValue) {
      return;
    }
    for (const dnd of this.dndTargets) {
      if (dndIsEmpty(dnd)) {
        return;
      }
    }
    const dndTree = this.dndTemplateTarget.content.cloneNode(true);
    this.element.appendChild(dndTree);
  }

  #removeEmptyDndTargets(): void {
    for (const dnd of this.dndTargets) {
      if (dndIsEmpty(dnd)) {
        dnd.remove();
      }
    }
  }

  #updateDndValues(): void {
    const canUploadMore =
      this.maxFilesValue &&
      this.#countNonEmptyDndTargets() < this.maxFilesValue;
    for (const dnd of this.dndTargets) {
      if (canUploadMore) {
        dnd.dataset.uppyDndMultipleValue = "true";
      } else {
        delete dnd.dataset.uppyDndMultipleValue;
      }
    }
  }

  #countNonEmptyDndTargets(): number {
    let count = 0;
    for (const dnd of this.dndTargets) {
      if (!dndIsEmpty(dnd)) {
        count++;
      }
    }
    return count;
  }
}

const dndIsEmpty = (dnd: HTMLElement): boolean =>
  !dnd.dataset.uppyDndPreviewSignedIdValue && dnd.ariaBusy !== "true";
