import { Controller } from "@hotwired/stimulus";
// @ts-expect-error No types for this package
import autosizeInput from "autosize-input";

export default class FieldSizingController extends Controller<HTMLInputElement> {
  // == Configuration ==
  static get shouldLoad(): boolean {
    return !CSS.supports("field-sizing: content");
  }

  // == State ==

  #cleanupAutosizer?: (() => void) | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    // eslint-disable-next-line @typescript-eslint/no-unsafe-call
    this.#cleanupAutosizer = autosizeInput(this.element);
  }

  disconnect(): void {
    super.disconnect();
    if (this.#cleanupAutosizer) {
      this.#cleanupAutosizer();
      this.#cleanupAutosizer = null;
    }
  }
}
