import { Controller } from "@hotwired/stimulus";

export default class CurrentTimeZoneInputController extends Controller<HTMLInputElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const { timeZone } = Intl.DateTimeFormat().resolvedOptions();
    if (this.element.value !== timeZone) {
      this.element.value = timeZone;
      this.dispatch("changed", { detail: { timeZone } });
    }
  }
}
