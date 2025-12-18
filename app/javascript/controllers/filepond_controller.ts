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
  // == Targets ==

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

  // == Values ==

  static values = {
    directUploadUrl: String,
    aspectRatio: {
      type: String,
    },
  };
  declare readonly directUploadUrlValue: string;
  declare readonly aspectRatioValue: string;

  // == Editor ==

  readonly #editor = {
    instructions: null as EditInstructions | null,
    open: (file: File, instructions: EditInstructions) => {
      this.#editor.instructions = instructions;
      this.editorModalImageTarget.src = URL.createObjectURL(file);
      this.#openEditorModal();
    },
    onconfirm: (_output: { data: EditInstructions }) => {},
    oncancel: () => {},
    onclose: () => {},
  };

  #currentEditInstructions(): EditInstructions {
    invariant(this.#editor.instructions, "Missing edit instructions");
    return this.#editor.instructions;
  }

  #openEditorModal(): void {
    this.dispatch("open-editor-modal", { target: this.editorModalTarget });
  }

  #closeEditorModal(): void {
    this.dispatch("close-editor-modal", { target: this.editorModalTarget });
  }

  #resetEditor(): void {
    this.#editor.instructions = null;
    this.#editor.onconfirm = () => {};
    this.#editor.oncancel = () => {};
    this.#editor.onclose = () => {};
  }

  // == Cropper ==

  #truecropper: TrueCropper | null = null;

  #initializedCropper(): TrueCropper {
    invariant(this.#truecropper, "Uninitialized truecropper");
    return this.#truecropper;
  }

  #destroyCropper(): void {
    if (this.#truecropper) {
      this.#truecropper.destroy();
      this.#truecropper = null;
      this.#resetEditorModalImageAfterCrop();
    }
  }

  #resetEditorModalImageAfterCrop(): void {
    const currentImage = this.editorModalImageTarget;
    invariant(
      currentImage.parentNode,
      "Missing parent node for editorModalImageTarget",
    );
    const newImage = document.createElement("img");
    newImage.dataset.filepondTarget = "editorModalImage";
    currentImage.parentNode.replaceChild(newImage, currentImage);
  }

  // == Pond ==

  #pond: FilePond | null = null;

  #destroyPond(): void {
    if (this.#pond) {
      this.#pond.destroy();
      this.#pond = null;
      this.#resetEditor();
    }
  }

  // == Lifecycle ==

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

  connect(): void {
    super.connect();
    const pond = create(this.inputTarget, {
      labelIdle: this.idleLabelTemplateTarget.innerHTML,
      imageCropAspectRatio: this.aspectRatioValue || undefined,
      imageEditEditor: this.#editor,
      imageEditAllowEdit: !!this.aspectRatioValue,
      imageEditInstantEdit: !!this.aspectRatioValue,
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
    super.disconnect();
    this.#closeEditorModal();
    this.#destroyCropper();
    this.#destroyPond();
  }

  // == Actions ==

  initializeCropper(): void {
    const instructions = this.#currentEditInstructions();
    this.#truecropper = new TrueCropper(this.editorModalImageTarget, {
      aspectRatio: instructions.crop.aspectRatio,
      startSize: {
        ...this.#editInstructionsToCrop(instructions),
        unit: "real",
      },
    });
  }

  confirmEdit(): void {
    const crop = this.#initializedCropper().getValue("real");
    const data = this.#currentEditInstructions();
    if (crop) {
      this.#addCropToEditInstructions(data, crop);
    }
    this.#editor.onconfirm({ data });
  }

  cancelEdit(): void {
    this.#editor.oncancel();
  }

  finalizeEdit(): void {
    this.#editor.onclose();
    this.#resetEditor();
    this.#destroyCropper();
  }

  // == Status helpers ==

  #markBusy(): void {
    this.element.setAttribute("aria-busy", "true");
  }

  #clearBusy(): void {
    this.element.removeAttribute("aria-busy");
  }

  // == Conversion helpers ==

  /**
   * Inverse of #addCropToEditInstructions.
   * Converts FilePond's EditInstructions (center, zoom, aspectRatio) into a
   * crop rectangle {x, y, width, height} for TrueCropper.
   *
   * FilePond's zoom is defined as the ratio between the "maximum possible
   * rectangle at this center" and the "actual chosen rectangle".
   */
  #editInstructionsToCrop(instructions: EditInstructions): {
    x: number;
    y: number;
    width: number;
    height: number;
  } {
    const { naturalWidth, naturalHeight } = this.editorModalImageTarget;
    const { center, zoom, aspectRatio: cropAspect } = instructions.crop;
    const { x: centerX, y: centerY } = center;

    const cx = centerX > 0.5 ? 1 - centerX : centerX;
    const cy = centerY > 0.5 ? 1 - centerY : centerY;

    const imgAspect = naturalWidth / naturalHeight;
    const imgW = imgAspect >= 1 ? 1 : imgAspect;
    const imgH = imgAspect >= 1 ? 1 / imgAspect : 1;

    const availW = cx * 2 * imgW;
    const availH = cy * 2 * imgH;

    let rectWidth = availW;
    let rectHeight = rectWidth * cropAspect;
    if (rectHeight > availH) {
      rectHeight = availH;
      rectWidth = rectHeight / cropAspect;
    }

    const widthFraction = (1 / zoom) * rectWidth;

    const naturalSide = Math.max(naturalWidth, naturalHeight);
    const width = widthFraction * naturalSide;
    const height = width * cropAspect;

    return {
      x: centerX * naturalWidth - width / 2,
      y: centerY * naturalHeight - height / 2,
      width,
      height,
    };
  }

  /**
   * Converts a percentage-based crop rectangle from TrueCropper into
   * FilePond's EditInstructions (center, zoom).
   *
   * Transformation Process:
   * 1. Calculate the center point of the crop in normalized [0, 1] coordinates.
   * 2. Determine the "maximum theoretical rectangle" that can exist at this
   *    center point:
   *    - First, normalize the image into a unit box based on its aspect ratio.
   *    - Then, find the largest rectangle with the target aspect ratio that
   *      fits within the image bounds when centered at (0.5, 0.5).
   *    - Finally, scale this rectangle by the distance from the center to the
   *      nearest image edges (cx, cy) to find the largest possible rectangle
   *    - centered at the *actual* chosen point.
   * 3. The "zoom" level is calculated as the ratio between the width (or height)
   *    of this "maximum theoretical rectangle" and the "actual chosen rectangle".
   */
  #addCropToEditInstructions(
    instructions: EditInstructions,
    crop: { x: number; y: number; width: number; height: number },
  ): void {
    const { naturalWidth, naturalHeight } = this.editorModalImageTarget;
    const x = (crop.x + crop.width / 2) / naturalWidth;
    const y = (crop.y + crop.height / 2) / naturalHeight;
    const cx = x > 0.5 ? 1 - x : x;
    const cy = y > 0.5 ? 1 - y : y;

    const imgAspect = naturalWidth / naturalHeight;
    const imgW = imgAspect >= 1 ? 1 : imgAspect;
    const imgH = imgAspect >= 1 ? 1 / imgAspect : 1;

    const cropAspect = crop.height / crop.width;
    const availW = cx * 2 * imgW;
    const availH = cy * 2 * imgH;

    let rectWidth = availW;
    let rectHeight = rectWidth * cropAspect;
    if (rectHeight > availH) {
      rectHeight = availH;
      rectWidth = rectHeight / cropAspect;
    }

    const naturalSide = Math.max(naturalWidth, naturalHeight);
    const zoom = rectWidth / (crop.width / naturalSide);
    instructions.crop.center = { x, y };
    instructions.crop.zoom = zoom;
  }
}

export default FilepondController;
