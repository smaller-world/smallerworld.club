import { Controller } from "@hotwired/stimulus";

export default class CurrentTimeZoneInputController extends Controller<HTMLInputElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.element.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
  }
}
