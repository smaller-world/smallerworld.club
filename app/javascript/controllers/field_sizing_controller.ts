import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

export default class FieldSizingController extends Controller<HTMLElement> {
  // == Configuration ==
  static get shouldLoad(): boolean {
    return !CSS.supports("field-sizing: content");
  }

  // == Targets ==

  static targets = ["sizer"];
  declare readonly sizerTarget: HTMLElement;
  declare readonly hasSizerTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    invariant(this.hasSizerTarget, "Missing sizer target");
  }

  disconnect(): void {
    super.disconnect();
  }

  // == Actions ==

  resize({ target }: InputEvent): void {
    if (!(target instanceof HTMLInputElement)) {
      return;
    }
    // this.sizerTarget.style.width = target.get
  }
}
