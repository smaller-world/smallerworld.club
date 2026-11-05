import { Controller } from "@hotwired/stimulus";
import type { TurboBeforeFetchResponseEvent } from "@hotwired/turbo";

export default class AsyncItemController extends Controller<HTMLElement> {
  // == Actions ==

  show(): void {
    this.element.hidden = false;
  }

  removeWhenUnauthorized(event: TurboBeforeFetchResponseEvent): void {
    const { response } = event.detail.fetchResponse;
    if (response.status === 401) {
      void this.element.remove();
    }
  }
}
