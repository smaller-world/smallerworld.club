import { Controller } from "@hotwired/stimulus";
import Uppy from "@uppy/core";
import DragDrop from "@uppy/drag-drop";
import StatusBar from "@uppy/status-bar";

import { isDevelopment } from "~/javascript/helpers/env";
import { ActiveStorageUpload } from "~/javascript/uppy";

export default class extends Controller {
  static targets = ["input", "statusBar"];
  static values = {
    directUploadUrl: String,
  };

  /** @type {Uppy | undefined} */
  #uppy;

  connect() {
    const uppy = new Uppy({
      restrictions: { maxNumberOfFiles: 1, allowedFileTypes: ["image/*"] },
      autoProceed: true,
      debug: isDevelopment(),
    });
    uppy.use(ActiveStorageUpload, {
      directUploadUrl: this.directUploadUrlValue,
    });
    uppy.use(StatusBar, { target: this.statusBarTarget });
    uppy.use(DragDrop, { target: this.element });
    this.#uppy = uppy;
  }

  disconnect() {
    this.#uppy?.destroy();
  }
}
