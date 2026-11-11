import { Controller } from "@hotwired/stimulus";

export default class AutoplayController extends Controller<HTMLVideoElement> {
  // == Lifecycle ==

  connect(): void {
    void this.element.play().catch((error: Error) => {
      console.warn("Video autoplay failed", error);
    });
  }
}
