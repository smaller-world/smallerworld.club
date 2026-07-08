import type { Meta, MinimalRequiredUppyFile } from "@uppy/core";
import { isEmpty } from "lodash-es";
import { Typed } from "stimulus-typescript";

import ApplicationController from "./application_controller";

const targets = {
  itemTemplate: HTMLTemplateElement,
  item: HTMLElement,
};

const values = {
  inputId: String,
  maxNumberOfFiles: Number,
};

export default class UppyGroupController extends Typed(
  ApplicationController<HTMLElement>,
  { targets, values },
) {
  #filesToUpload: MinimalRequiredUppyFile<Meta, { signed_id: string }>[] = [];

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasItemTemplateTarget) {
      throw new Error("Missing itemTemplate target");
    }
  }

  itemTargetConnected(item: HTMLHtmlElement) {
    const [file, ...remainingFiles] = this.#filesToUpload;
    if (itemIsEmpty(item) && file) {
      this.#filesToUpload = remainingFiles;
      this.dispatch("request-upload", {
        detail: { file },
        target: item,
      });
    }
  }

  // == Actions ==

  update(): void {
    this.#removeEmptyItems();
    this.#addItems();
    this.#updateItemAttributes();
    if (this.#countNonEmptyItems() === this.maxNumberOfFilesValue) {
      this.#filesToUpload = [];
    }
  }

  removeItem({ target }: PointerEvent): void {
    if (!(target instanceof HTMLElement)) {
      return;
    }
    for (const item of this.itemTargets) {
      if (item.contains(target)) {
        item.remove();
        this.dispatch("removed");
        break;
      }
    }
    this.update();
  }

  addFilesToUpload({
    detail,
  }: CustomEvent<{
    files: MinimalRequiredUppyFile<Meta, { signed_id: string }>[];
  }>) {
    this.#filesToUpload = detail.files;
  }

  // == Helpers ==

  #addItems(): void {
    if (
      this.maxNumberOfFilesValue &&
      this.itemTargets.length < this.maxNumberOfFilesValue
    ) {
      const item = this.itemTemplateTarget.content.cloneNode(true);
      this.element.appendChild(item);
    }
  }

  #removeEmptyItems(): void {
    for (const item of this.itemTargets) {
      if (itemIsEmpty(item)) {
        item.remove();
      }
    }
  }

  #updateItemAttributes(): void {
    const canUploadMore =
      this.maxNumberOfFilesValue &&
      this.#countNonEmptyItems() < this.maxNumberOfFilesValue;
    for (const item of this.itemTargets) {
      if (canUploadMore) {
        this.dispatch("request-allow-item-multiple-uploads", { target: item });
      } else {
        this.dispatch("request-disallow-item-multiple-uploads", {
          target: item,
        });
      }
    }
  }

  #countNonEmptyItems(): number {
    let count = 0;
    for (const item of this.itemTargets) {
      if (itemIsEmpty(item)) {
        count++;
      }
    }
    return count;
  }
}

const itemIsEmpty = (item: HTMLElement): boolean => {
  const { dataset, ariaBusy } = item;
  const { uppyPreviewSignedIdValue } = dataset;
  return !uppyPreviewSignedIdValue && ariaBusy !== "true";
};
