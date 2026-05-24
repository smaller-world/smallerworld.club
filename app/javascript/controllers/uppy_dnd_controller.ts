// @ts-expect-error Untyped package
import ActiveStorageUpload from "@gothassos/uppy-activestorage-upload";
import { Controller } from "@hotwired/stimulus";
import Uppy, {
  type Meta,
  type MinimalRequiredUppyFile,
  type UppyFile,
} from "@uppy/core";
import DragDrop from "@uppy/drag-drop";
import ImageEditor from "@uppy/image-editor";
import { isEmpty, map } from "lodash-es";

import { isDevelopment } from "#helpers/env_helpers";

export default class UppyDndController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = [
    "dropzone",
    "imageEditorDialog",
    "imageEditor",
    "hiddenInput",
  ];
  declare readonly dropzoneTarget: HTMLElement;
  declare readonly imageEditorDialogTarget: HTMLElement;
  declare readonly imageEditorTarget: HTMLElement;
  declare readonly hiddenInputTarget: HTMLInputElement;
  declare readonly hasDropzoneTarget: boolean;
  declare readonly hasImageEditorDialogTarget: boolean;
  declare readonly hasImageEditorTarget: boolean;
  declare readonly hasHiddenInputTarget: boolean;

  // == Values ==

  static values = {
    directUploadUrl: String,
    previewUrlTemplate: String,
    previewSignedId: String,
    inputId: String,
    imageEditorDialogId: String,
    multiple: Boolean,
    required: Boolean,
    allowedFileTypes: String,
    cropToAspectRatio: Number,
  };
  declare readonly directUploadUrlValue: string;
  declare readonly previewUrlTemplateValue: string;
  declare previewSignedIdValue: string | undefined;
  declare readonly inputIdValue: string;
  declare readonly imageEditorDialogIdValue: string;
  declare readonly multipleValue: boolean;
  declare readonly requiredValue: boolean;
  declare readonly allowedFileTypesValue: string;
  declare readonly cropToAspectRatioValue: number;

  // == Properties ==

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

    this.#uppy?.destroy();
    let uppy = new Uppy<Meta, { signed_id: string }>({
      debug: isDevelopment(),
      restrictions: {
        minNumberOfFiles: this.requiredValue ? 1 : null,
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
          this.dispatch("open-image-editor", {
            target: this.imageEditorDialogTarget,
          });
        } else {
          void uppy.upload();
        }
      })
      .on("upload", () => {
        this.element.ariaBusy = "true";
      })
      .on("upload-error", (file, { message }) => {
        console.error(`Failed to upload file: ${message}`);
        this.dispatch("error", {
          detail: {
            message: `failed to upload file: ${message}`,
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
    if (this.hasImageEditorTarget) {
      uppy = uppy
        .use(ImageEditor, {
          target: this.imageEditorTarget,
          quality: 1,
          cropperOptions: {
            aspectRatio: this.cropToAspectRatioValue,
            responsive: true,
          },
          actions: {
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
    setTimeout(() => {
      this.dispatch("ready");
    });
  }

  disconnect(): void {
    if (this.#uppy) {
      this.#uppy.destroy();
      this.#uppy = null;
    }
    super.disconnect();
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

  multipleValueChanged(value: boolean): void {
    if (this.#uppy) {
      this.#uppy.setOptions({
        restrictions: {
          minNumberOfFiles: this.requiredValue ? 1 : null,
          maxNumberOfFiles: value ? null : 1,
          allowedFileTypes: this.allowedFileTypesValue
            .split(",")
            .map((type) => type.trim()),
        },
      });
      this.#uppy
        .getPlugin("DragDrop")
        ?.setOptions({ allowMultipleFiles: value });
    }
  }

  // == Actions ==

  upload({
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
    this.previewSignedIdValue = undefined;
    this.hiddenInputTarget.value = "";
  }

  saveImageEdit(): void {
    const imageEditor = this.#uppy?.getPlugin("ImageEditor");
    imageEditor?.save();
  }

  selectEditorImage(): void {
    if (!this.#uppy) {
      return;
    }
    const imageEditor = this.#uppy.getPlugin("ImageEditor");
    const [file, ...otherFiles] = this.#uppy.getFiles();
    if (!isEmpty(otherFiles)) {
      throw new Error("Ambiguous editor image");
    }
    if (imageEditor && file) {
      imageEditor.selectFile(file);
    }
  }

  cancelImageEdit(): void {
    if (!this.#uppy) {
      return;
    }
    const [file] = this.#uppy.getFiles();
    if (file) {
      this.#uppy.emit("file-editor:cancel", file);
    }
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
}
