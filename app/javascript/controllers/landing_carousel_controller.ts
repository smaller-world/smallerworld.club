import Glide from "@glidejs/glide";
import { Controller } from "@hotwired/stimulus";

export default class LandingCarouselController extends Controller<HTMLElement> {
  #glide?: Glide | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.#glide = new Glide(this.element, {
      type: "carousel",
      perView: 3,
      focusAt: "center",
      gap: 12,
      breakpoints: {
        767: {
          perView: 2,
          focusAt: 0,
        },
        639: {
          perView: 1,
        },
      },
    }).mount();
  }

  disconnect(): void {
    super.disconnect();
    if (this.#glide) {
      this.#glide.destroy();
      this.#glide = null;
    }
  }
}
