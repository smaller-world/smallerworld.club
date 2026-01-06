import { Controller } from "@hotwired/stimulus";
import tippy, { type Instance } from "tippy.js";

import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class TooltipController extends Controller<HTMLElement> {
  // == Values ==
  static values = {
    content: String,
    permanent: Boolean,
  };
  declare readonly contentValue: string;
  declare readonly permanentValue: boolean;

  // == State ==

  #tooltip?: Instance;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.#tooltip = tippy(this.element, {
      content: this.contentValue,
      inertia: true,
    });
    if (this.permanentValue) {
      this.#tooltip.setProps({ trigger: "manual" });
      this.#tooltip.show();
    }
    addCleanupAction(this, "destroy");
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
  }

  // == Actions ==

  destroy(): void {
    this.#tooltip?.destroy();
  }
}
