import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";
import { create, type FilePond, registerPlugin } from "filepond";
/* eslint-disable import-x/default */
import FileValidateTypePlugin from "filepond-plugin-file-validate-type";
import ImageCropPlugin from "filepond-plugin-image-crop";
import ImageEditPlugin from "filepond-plugin-image-edit";
import ImageExifOrientationPlugin from "filepond-plugin-image-exif-orientation";
import ImagePreviewPlugin from "filepond-plugin-image-preview";
import ImageTransformPlugin from "filepond-plugin-image-transform";
/* eslint-enable import-x/default */
import invariant from "tiny-invariant";
import TrueCropper from "truecropper";

interface EditInstructions {
  crop: {
    aspectRatio: number;
    center: {
      x: number;
      y: number;
    };
    zoom: number;
  };
}

class FilepondController extends Controller<HTMLElement> {
  static targets = [
    "input",
    "idleLabelTemplate",
    "editorModal",
    "editorModalImage",
  ];

  declare readonly inputTarget: HTMLInputElement;
  declare readonly idleLabelTemplateTarget: HTMLTemplateElement;
  declare readonly editorModalImageTarget: HTMLImageElement;
  declare readonly editorModalTarget: HTMLDialogElement;

  static values = {
    directUploadUrl: String,
    aspectRatio: {
      type: String,
      default: undefined,
    },
  };

  declare readonly directUploadUrlValue: string;
  declare readonly aspectRatioValue?: string;

  initialize(): void {
    registerPlugin(
      FileValidateTypePlugin,
      ImagePreviewPlugin,
      ImageExifOrientationPlugin,
      ImageCropPlugin,
      ImageEditPlugin,
      ImageTransformPlugin,
    );
  }

  #pond: FilePond | null = null;
  #editInstructions: EditInstructions | null = null;
  #editor = {
    open: (file: File, instructions: EditInstructions) => {
      this.#editInstructions = instructions;
      this.editorModalImageTarget.src = URL.createObjectURL(file);
      this.dispatch("open-editor-modal", { target: this.editorModalTarget });
    },
    onconfirm: (_output: { data: EditInstructions }) => {},
    oncancel: () => {},
    onclose: () => {},
  };
  #truecropper: TrueCropper | null = null;

  connect(): void {
    const hasAspectRatio = this.aspectRatioValue !== null;
    const pond = create(this.inputTarget, {
      labelIdle: this.idleLabelTemplateTarget.innerHTML,
      imageCropAspectRatio: this.aspectRatioValue,
      imageEditEditor: this.#editor,
      imageEditAllowEdit: hasAspectRatio,
      imageEditInstantEdit: hasAspectRatio,
      stylePanelLayout: "compact circle",
      styleLoadIndicatorPosition: "center bottom",
      styleProgressIndicatorPosition: "right bottom",
      styleButtonRemoveItemPosition: "left bottom",
      styleButtonProcessItemPosition: "right bottom",
      server: {
        process: (fieldName, file, metadata, load, error, progress) => {
          const uploader = new DirectUpload(
            file as File,
            this.directUploadUrlValue,
            {
              directUploadWillStoreFileWithXHR: (request) => {
                request.upload.addEventListener("progress", (event) => {
                  progress(event.lengthComputable, event.loaded, event.total);
                });
              },
            },
          );
          uploader.create((responseError, blob) => {
            if (responseError) {
              error(responseError.message);
            } else {
              load(blob.signed_id);
            }
          });
        },
        revert: (signedId, load, error) => {
          fetch(`/filepond/files/${signedId}`, {
            method: "DELETE",
          }).then(load, error);
        },
        restore: null,
        load: null,
      },
    });
    pond.on("processfilestart", () => {
      this.#markBusy();
    });
    pond.on("processfiles", () => {
      this.#clearBusy();
    });
    this.#pond = pond;
  }

  disconnect(): void {
    if (this.#pond) {
      this.#pond.destroy();
      this.#pond = null;
    }
  }

  initializeCropper(): void {
    invariant(this.#editInstructions, "Missing edit instructions");
    this.#truecropper = new TrueCropper(this.editorModalImageTarget, {
      aspectRatio: this.#editInstructions.crop.aspectRatio,
    });
  }

  confirmEdit(): void {
    invariant(this.#editInstructions, "Missing edit instructions");
    invariant(this.#truecropper, "Uninitialized truecropper");
    const crop = this.#truecropper.getValue("percent");
    let data = this.#editInstructions;
    if (crop) {
      data = this.#addCropToEditInstructions(
        this.#editInstructions,
        crop,
        this.editorModalImageTarget,
      );
    }
    this.#editor.onconfirm({ data });
  }

  cancelEdit(): void {
    this.#editor.oncancel();
  }

  finalizeEdit(): void {
    this.#editor.onclose();
    this.#destroyCropper();
    this.#resetEditorModalImage();
  }

  #destroyCropper(): void {
    if (this.#truecropper) {
      this.#truecropper.destroy();
      this.#truecropper = null;
    }
  }

  #resetEditorModalImage(): void {
    const currentImage = this.editorModalImageTarget;
    invariant(
      currentImage.parentNode,
      "Missing parent node for editorModalImageTarget",
    );
    const newImage = document.createElement("img");
    newImage.dataset.filepondTarget = "editorModalImage";
    currentImage.parentNode.replaceChild(newImage, currentImage);
  }

  #markBusy(): void {
    this.element.setAttribute("aria-busy", "true");
  }

  #clearBusy(): void {
    this.element.removeAttribute("aria-busy");
  }

  #addCropToEditInstructions(
    instructions: EditInstructions,
    crop: { x: number; y: number; width: number; height: number },
    image: HTMLImageElement,
  ): EditInstructions {
    const x = (crop.x + crop.width / 2) / 100;
    const y = (crop.y + crop.height / 2) / 100;
    const cx = x > 0.5 ? 1 - x : x;
    const cy = y > 0.5 ? 1 - y : y;

    const imageAspect = image.width / image.height;
    const imgW = imageAspect >= 1 ? 1 : imageAspect;
    const imgH = imageAspect >= 1 ? 1 / imageAspect : 1;

    const cropAspect = crop.height / crop.width;
    let maxW = imgW;
    let maxH = maxW * cropAspect;
    if (maxH > imgH) {
      maxH = imgH;
      maxW = maxH / cropAspect;
    }
    const rectWidth = cx * 2 * maxW;
    const rectHeight = cy * 2 * maxH;
    const zoom = Math.max(
      rectWidth / ((crop.width / 100) * imgW),
      rectHeight / ((crop.height / 100) * imgH),
    );
    return {
      ...instructions,
      crop: {
        ...instructions.crop,
        center: {
          x: x,
          y: y,
        },
        zoom,
      },
    };
  }
}

export default FilepondController;
