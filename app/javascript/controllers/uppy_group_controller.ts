import { Controller } from "@hotwired/stimulus";
import type { Meta, MinimalRequiredUppyFile } from "@uppy/core";
import { Typed } from "stimulus-typescript";

import UppyDndController from "./uppy_dnd_controller";

const targets = {
  dndTemplate: HTMLTemplateElement,
};

const outlets = {
  dnd: UppyDndController,
};

const values = {
  maxFiles: Number,
};

export default class UppyGroupController extends Typed(
  Controller<HTMLElement>,
  { targets, outlets, values },
) {
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
    if (this.dndOutlets.length <= 1) {
      return;
    }
    if (!(target instanceof HTMLElement)) {
      return;
    }
    for (const dndElement of this.dndOutletElements) {
      if (dndElement.contains(target)) {
        dndElement.remove();
        this.dispatch("removed");
        break;
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
    if (this.maxFilesValue && this.dndOutlets.length >= this.maxFilesValue) {
      return;
    }
    const dndTree = this.dndTemplateTarget.content.cloneNode(true);
    this.element.appendChild(dndTree);
  }

  #removeEmptyDndTargets(): void {
    for (const dnd of this.dndOutlets) {
      if (dnd.isEmpty) {
        dnd.element.remove();
      }
    }
  }

  #updateDndValues(): void {
    const canUploadMore =
      this.maxFilesValue &&
      this.#countNonEmptyDndTargets() < this.maxFilesValue;
    for (const dnd of this.dndOutlets) {
      if (canUploadMore) {
        dnd.multipleValue = true;
      } else {
        dnd.multipleValue = false;
      }
    }
  }

  #countNonEmptyDndTargets(): number {
    let count = 0;
    for (const dnd of this.dndOutlets) {
      if (!dnd.isEmpty) {
        count++;
      }
    }
    return count;
  }
}
