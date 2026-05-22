// @ts-expect-error Untyped package
import ActiveStorageUpload from "@gothassos/uppy-activestorage-upload";
import { Controller } from "@hotwired/stimulus";
import Uppy, { type Meta, type UppyFile } from "@uppy/core";
import DragDrop from "@uppy/drag-drop";
import { map } from "lodash-es";

import { isDevelopment } from "#helpers/env_helpers";

export default class UppyDndController extends Controller<HTMLElement> {
  // == Values ==
  static values = {
    directUploadUrl: String,
    previewUrlTemplate: String,
    previewSignedId: String,
    inputId: String,
  };
  declare readonly directUploadUrlValue: string;
  declare readonly previewUrlTemplateValue: string;
  declare previewSignedIdValue: string | undefined;
  declare readonly inputIdValue: string;

  // == Targets ==
  static targets = ["dropzone", "hiddenInput"];
  declare readonly dropzoneTarget: HTMLDivElement;
  declare readonly hasDropzoneTarget: boolean;
  declare readonly hiddenInputTarget: HTMLInputElement;
  declare readonly hasHiddenInputTarget: boolean;

  // == Properties ==

  #uppy?: Uppy<Meta, { signed_id: string }> | null;

  // == Lifecycle ==

  connect(): void {
    if (!this.hasDropzoneTarget) {
      throw new Error("Missing dropzone target");
    }
    if (!this.hasHiddenInputTarget) {
      throw new Error("Missing hiddenInput target");
    }

    this.#uppy?.destroy();
    const uppy = new Uppy<Meta, { signed_id: string }>({
      debug: isDevelopment(),
    })
      .use(DragDrop, {
        target: this.dropzoneTarget,
        inputName: "",
      })
      .use(ActiveStorageUpload, {
        directUploadUrl: this.directUploadUrlValue,
      })
      .on("file-added", () => {
        void uppy.upload();
      })
      .on("complete", ({ successful, failed }) => {
        const fileIDs: string[] = [];
        if (successful) {
          for (const file of successful) {
            this.#addCompletedFile(file);
          }
          fileIDs.concat(map(successful, "id"));
        }
        if (failed) {
          fileIDs.concat(map(failed, "id"));
        }
        uppy.removeFiles(fileIDs);
      })
      .on("upload-error", (file, { message }) => {
        console.error(`Failed to upload file: ${message}`);
        this.dispatch("error", {
          detail: {
            message: `failed to upload file: ${message}`,
          },
        });
      });
    this.#uppy = uppy;
    this.#customizeUI();
  }

  disconnect(): void {
    if (this.#uppy) {
      this.#uppy.destroy();
      this.#uppy = null;
    }
  }

  previewSignedIdValueChanged(signedId: string) {
    if (signedId) {
      const previewUrl = this.previewUrlTemplateValue.replace(
        ":signed_id",
        signedId,
      );
      this.dropzoneTarget.style.setProperty(
        "--preview-image",
        `url("${previewUrl}")`,
      );
    } else {
      this.dropzoneTarget.style.removeProperty("--preview-image");
    }
  }

  // == Actions ==

  clear(): void {
    this.previewSignedIdValue = undefined;
    this.hiddenInputTarget.value = "";
  }

  // == Helpers ==

  #customizeUI(): void {
    const input = this.dropzoneTarget.querySelector<HTMLInputElement>(
      "input.uppy-DragDrop-input",
    );
    if (input && this.inputIdValue) {
      input.id = this.inputIdValue;
    }
  }

  #addCompletedFile(file: UppyFile<Meta, { signed_id: string }>): void {
    // @ts-expect-error Bad typing
    const signedId = file.response?.signed_id as string;
    this.hiddenInputTarget.value = signedId;
    this.previewSignedIdValue = signedId;
  }

  // #upload(file: File) {
  //   console.log("SHOULD UPLOAD", file);
  //   const directUpload = new DirectUpload(file, this.directUploadUrlValue);
  //   directUpload.create((error, blob) => {
  //     if (error) {
  //       console.error(`Failed to upload file: ${error}`);
  //       this.dispatch("error", {
  //         detail: {
  //           error,
  //           message: `failed to upload file: ${error}`,
  //         },
  //       });
  //     } else if (blob) {
  //       const input = document.createElement("input");
  //       input.type = "hidden";
  //       input.name = this.inputNameValue;
  //       this.element.appendChild(input);
  //     }
  //   });
  // }
}
