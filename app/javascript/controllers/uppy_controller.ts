// @ts-expect-error Untyped package
import ActiveStorageUpload from "@gothassos/uppy-activestorage-upload";
import Uppy, {
  type Meta,
  type MinimalRequiredUppyFile,
  type UppyFile,
} from "@uppy/core";
import DragDrop from "@uppy/drag-drop";
import ImageEditor from "@uppy/image-editor";
import { isEmpty, map } from "lodash-es";
import { Typed } from "stimulus-typescript";

import { isDevelopment } from "#helpers/env_helpers";
import { addBeforeCacheAction } from "#helpers/stimulus_helpers";

import ApplicationController from "./application_controller";

const targets = {
  dropzone: HTMLElement,
  cropper: HTMLElement,
  hiddenInput: HTMLInputElement,
};

const values = {
  directUploadUrl: String,
  previewUrlTemplate: String,
  previewSignedId: String,
  inputId: String,
  multiple: Boolean,
  allowedFileTypes: String,
  cropToAspectRatio: Number,
};

export default class UppyController extends Typed(
  ApplicationController<HTMLElement>,
  {
    targets,
    values,
  },
) {
  #uppy?: Uppy<Meta, { signed_id: string }> | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasDropzoneTarget) {
      throw new Error("Missing dropzone target");
    }
    if (!this.hasHiddenInputTarget) {
      throw new Error("Missing hiddenInput target");
    }
    if (this.cropToAspectRatioValue && !this.cropperTarget) {
      throw new Error("Missing cropper target");
    }

    let uppy = new Uppy<Meta, { signed_id: string }>({
      debug: isDevelopment(),
      restrictions: {
        maxNumberOfFiles: this.multipleValue ? null : 1,
        allowedFileTypes: this.allowedFileTypesValue
          .split(",")
          .map((type) => type.trim()),
      },
      onBeforeFileAdded: (file, files) => {
        if (!isEmpty(files)) {
          uppy.removeFiles(Object.keys(files));
        }
        return file;
      },
    })
      .use(DragDrop, {
        target: this.dropzoneTarget,
        inputName: "",
        allowMultipleFiles: this.multipleValue,
      })
      .use(ActiveStorageUpload, {
        directUploadUrl: this.directUploadUrlValue,
      })
      .on("files-added", (files) => {
        const [file, ...otherFiles] = files;
        if (!isEmpty(otherFiles)) {
          uppy.removeFiles(map(otherFiles, "id"));
          this.dispatch("multiple-upload", {
            detail: {
              files: otherFiles,
            },
          });
        }
        if (!file) {
          return;
        }
        const imageEditor = uppy.getPlugin("ImageEditor");
        if (
          !this.multipleValue &&
          imageEditor?.canEditFile(file) &&
          file.type !== "image/gif"
        ) {
          this.dispatch("request-open-cropper", { target: this.cropperTarget });
          if (imageEditor && file) {
            imageEditor.selectFile(file);
          }
        } else {
          void uppy.upload();
        }
      })
      .on("restriction-failed", (_file, error) => {
        this.dispatch("error", {
          detail: { message: error.message },
        });
      })
      .on("upload", () => {
        this.element.ariaBusy = "true";
      })
      .on("upload-error", (_file, { message, details }) => {
        console.error(`Failed to upload file:`, { message, details });
        this.dispatch("error", {
          detail: {
            message: message
              ? `failed to upload file: ${message}`
              : "failed to upload file",
          },
        });
      })
      .on("complete", ({ successful, failed }) => {
        this.element.ariaBusy = null;
        const fileIDs: string[] = [];
        if (successful) {
          for (const file of successful) {
            this.#addCompletedFile(file);
          }
          fileIDs.push(...map(successful, "id"));
        }
        if (failed) {
          fileIDs.push(...map(failed, "id"));
        }
        uppy.removeFiles(fileIDs);
        this.dispatch("uploaded");
      });
    if (this.hasCropToAspectRatioValue) {
      uppy = uppy
        .use(ImageEditor, {
          target: this.cropperTarget,
          quality: 1,
          cropperOptions: {
            aspectRatio: this.cropToAspectRatioValue,
            responsive: true,
            // Cap the output canvas size. iOS Safari silently returns a blank
            // canvas (or a null blob from toBlob) once a canvas exceeds ~16.7M
            // px, which aborts the crop-complete flow with no error. Large
            // iPhone photos (e.g. 48MP → 6048×6048 square) blow past that.
            croppedCanvasOptions: {
              maxWidth: 2048,
              maxHeight: 2048,
            },
          },
          actions: {
            revert: false,
            rotate: false,
            granularRotate: false,
            flip: false,
            zoomIn: false,
            zoomOut: false,
            cropSquare: false,
            cropWidescreen: false,
            cropWidescreenVertical: false,
          },
        })
        .on("file-editor:complete", () => {
          const imageEditor = uppy.getPlugin("ImageEditor");
          imageEditor?.stop();
          void uppy.upload();
        })
        .on("file-editor:cancel", (file) => {
          const imageEditor = uppy.getPlugin("ImageEditor");
          imageEditor?.stop();
          uppy.removeFile(file.id);
        });
    }
    this.#uppy = uppy;
    this.#customizeUI();
    addBeforeCacheAction(this, "destroy");
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
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

  uploadExternalFile({
    detail,
  }: CustomEvent<{
    file: MinimalRequiredUppyFile<Meta, { signed_id: string }>;
  }>): void {
    if (!this.#uppy) {
      throw new Error("Uppy is not initialized");
    }
    this.#uppy.addFile(detail.file);
  }

  clear(): void {
    this.previewSignedIdValue = "";
    this.hiddenInputTarget.value = "";
  }

  saveCrop(): void {
    const imageEditor = this.#uppy?.getPlugin("ImageEditor");
    imageEditor?.save();
  }

  cancelCrop(): void {
    if (!this.#uppy) {
      return;
    }
    const [file] = this.#uppy.getFiles();
    if (file) {
      this.#uppy.emit("file-editor:cancel", file);
    }
  }

  destroy(): void {
    if (this.#uppy) {
      this.#uppy.destroy();
      this.#uppy = null;
    }
  }

  // == Uppy Group ==

  allowMultipleUploads(): void {
    this.multipleValue = true;
  }

  disallowMultipleUploads(): void {
    this.multipleValue = false;
  }

  // == Helpers ==

  get isEmpty(): boolean {
    return !this.previewSignedIdValue && this.element.ariaBusy !== "true";
  }

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
}
