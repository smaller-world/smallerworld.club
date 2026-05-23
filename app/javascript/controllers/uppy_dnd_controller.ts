// @ts-expect-error Untyped package
import ActiveStorageUpload from "@gothassos/uppy-activestorage-upload";
import { Controller } from "@hotwired/stimulus";
import Uppy, {
  type Meta,
  type MinimalRequiredUppyFile,
  type UppyFile,
} from "@uppy/core";
import DragDrop from "@uppy/drag-drop";
import { isEmpty, map } from "lodash-es";

export default class UppyDndController extends Controller<HTMLElement> {
  // == Values ==
  static values = {
    directUploadUrl: String,
    previewUrlTemplate: String,
    previewSignedId: String,
    inputId: String,
    multiple: Boolean,
    required: Boolean,
    allowedFileTypes: String,
  };
  declare readonly directUploadUrlValue: string;
  declare readonly previewUrlTemplateValue: string;
  declare previewSignedIdValue: string | undefined;
  declare readonly inputIdValue: string;
  declare readonly multipleValue: boolean;
  declare readonly requiredValue: boolean;
  declare readonly allowedFileTypesValue: string;

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
      // debug: isDevelopment(),
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
        const [_, ...otherFiles] = files;
        if (!isEmpty(otherFiles)) {
          uppy.removeFiles(map(otherFiles, "id"));
          this.dispatch("multiple-upload", {
            detail: {
              files: otherFiles,
            },
          });
        }
        void uppy.upload();
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
          fileIDs.concat(map(successful, "id"));
        }
        if (failed) {
          fileIDs.concat(map(failed, "id"));
        }
        uppy.removeFiles(fileIDs);
        this.dispatch("uploaded");
      });
    this.#uppy = uppy;
    this.#customizeUI();
    setTimeout(() => {
      this.dispatch("ready");
    });
    super.connect();
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
