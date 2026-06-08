import { Controller } from "@hotwired/stimulus";
import type {
  FrameElement,
  TurboBeforeFetchResponseEvent,
} from "@hotwired/turbo";

export default class FrameController extends Controller<FrameElement> {
  // == Actions ==

  reloadAndPreserveScroll(): void {
    const { scrollX, scrollY } = window;
    void this.element.reload().then(() => {
      scrollTo(scrollX, scrollY);
    });
  }

  reloadWhenNotFound(event: TurboBeforeFetchResponseEvent): void {
    const { response } = event.detail.fetchResponse;
    if (response.status === 404) {
      void this.element.reload();
    }
  }
}
