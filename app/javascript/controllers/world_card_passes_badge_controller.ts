import { Controller } from "@hotwired/stimulus";
import { inflect } from "inflection";
import { isEmpty } from "lodash-es";

import type { PassData } from "./passes_bridge_controller";

export default class WorldCardPassesBadgeController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["label"];
  declare readonly labelTarget: HTMLSpanElement;
  declare readonly hasLabelTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.hasLabelTarget) {
      throw new Error("Missing label target");
    }
  }

  // == Actions ==

  setLabel(event: CustomEvent<{ passes: PassData[] }>): void {
    const { passes } = event.detail;
    if (!isEmpty(passes)) {
      this.labelTarget.textContent = `${passes.length} world ${inflect("passes", passes.length)} found`;
      this.dispatch("label-set");
    }
  }
}
