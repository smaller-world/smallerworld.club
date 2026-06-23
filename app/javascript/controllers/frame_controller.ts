import { Controller } from "@hotwired/stimulus";
import type {
  FrameElement,
  TurboBeforeFetchResponseEvent,
} from "@hotwired/turbo";

export default class FrameController extends Controller<FrameElement> {
  // == Actions ==

  reload(): void {
    void this.element.reload();
  }

  reloadWhenNotFound(event: TurboBeforeFetchResponseEvent): void {
    const { response } = event.detail.fetchResponse;
    if (response.status === 404) {
      void this.element.reload();
    }
  }
}
