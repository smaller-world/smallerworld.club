import { Controller } from "@hotwired/stimulus";
import { get } from "lodash-es";

export default class InputFromEventController extends Controller {
  // == Values ==
  static values = {
    detail: String,
  };
  declare readonly detailValue: string;

  // == Targets ==

  static targets = ["input"];
  declare readonly inputTarget: HTMLInputElement;

  // == Actions ==

  set(event: CustomEvent): void {
    this.inputTarget.value = get(event.detail, this.detailValue);
    this.dispatch("set");
  }
}
