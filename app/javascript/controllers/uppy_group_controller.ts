import { Controller } from "@hotwired/stimulus";
import type { Meta, MinimalRequiredUppyFile } from "@uppy/core";
import { Typed } from "stimulus-typescript";

import UppyDndController from "./uppy_dnd_controller";

const targets = {
  dndTemplate: HTMLTemplateElement,
};

const outlets = {
  "uppy-dnd": UppyDndController,
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
    if (!(target instanceof HTMLElement)) {
      return;
    }
    for (const uppyDndElement of this.uppyDndOutletElements) {
      if (uppyDndElement.contains(target)) {
        uppyDndElement.remove();
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
    if (
      this.maxFilesValue &&
      this.uppyDndOutlets.length >= this.maxFilesValue
    ) {
      return;
    }
    const dndTree = this.dndTemplateTarget.content.cloneNode(true);
    this.element.appendChild(dndTree);
  }

  #removeEmptyDndTargets(): void {
    for (const uppyDnd of this.uppyDndOutlets) {
      if (uppyDnd.isEmpty) {
        uppyDnd.element.remove();
      }
    }
  }

  #updateDndValues(): void {
    const canUploadMore =
      this.maxFilesValue &&
      this.#countNonEmptyDndTargets() < this.maxFilesValue;
    for (const uppyDnd of this.uppyDndOutlets) {
      if (canUploadMore) {
        uppyDnd.multipleValue = true;
      } else {
        uppyDnd.multipleValue = false;
      }
    }
  }

  #countNonEmptyDndTargets(): number {
    let count = 0;
    for (const uppyDnd of this.uppyDndOutlets) {
      if (!uppyDnd.isEmpty) {
        count++;
      }
    }
    return count;
  }
}
