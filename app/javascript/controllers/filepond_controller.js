import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";
import { create, registerPlugin } from "filepond";
import FileValidateTypePlugin from "filepond-plugin-file-validate-type";
import ImageCropPlugin from "filepond-plugin-image-crop";
import ImageExifOrientationPlugin from "filepond-plugin-image-exif-orientation";
// import ImageEditPlugin from "filepond-plugin-image-edit";
import ImagePreviewPlugin from "filepond-plugin-image-preview";
import ImageTransformPlugin from "filepond-plugin-image-transform";

// TODO: Implement image editing with plugin.
export default class extends Controller {
  static targets = ["input", "idleLabelTemplate"];
  static values = {
    directUploadUrl: String,
    aspectRatio: {
      type: String,
      default: null,
    },
  };

  initialize() {
    registerPlugin(
      FileValidateTypePlugin,
      ImagePreviewPlugin,
      ImageExifOrientationPlugin,
      ImageCropPlugin,
      ImageTransformPlugin,
    );
  }

  /** @type {import("filepond").FilePond | null} */
  #filepond = null;

  connect() {
    const filepond = create(this.inputTarget, {
      labelIdle: this.idleLabelTemplateTarget.innerHTML,
      imageCropAspectRatio: this.aspectRatioValue,
      stylePanelLayout: "compact circle",
      styleLoadIndicatorPosition: "center bottom",
      styleProgressIndicatorPosition: "right bottom",
      styleButtonRemoveItemPosition: "left bottom",
      styleButtonProcessItemPosition: "right bottom",
      server: {
        process: (fieldName, file, metadata, load, error, progress) => {
          const uploader = new DirectUpload(file, this.directUploadUrlValue, {
            directUploadWillStoreFileWithXHR: request => {
              request.upload.addEventListener("progress", event => {
                progress(event.lengthComputable, event.loaded, event.total);
              });
            },
          });
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
    filepond.on("processfilestart", () => {
      this.#markBusy();
    });
    filepond.on("processfiles", () => {
      this.#clearBusy();
    });
    this.#filepond = filepond;
  }

  disconnect() {
    if (this.#filepond) {
      this.#filepond.destroy();
      this.#filepond = null;
    }
  }

  #markBusy() {
    this.element.setAttribute("aria-busy", "true");
  }

  #clearBusy() {
    this.element.removeAttribute("aria-busy");
  }
}
