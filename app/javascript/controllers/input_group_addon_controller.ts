import { Controller } from "@hotwired/stimulus";

export default class InputGroupAddonController extends Controller {
  // == Actions ==

  focus(event: MouseEvent): void {
    if ((event.target as HTMLElement).closest("button")) return;
    const control = this.element.parentElement?.querySelector<
      HTMLInputElement | HTMLTextAreaElement
    >("input, textarea");
    control?.focus();
  }
}
