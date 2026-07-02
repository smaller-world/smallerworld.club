import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  image: HTMLImageElement,
};

export default class LightboxController extends Typed(Controller<HTMLElement>, {
  targets,
}) {
  // == Actions ==

  open(event: PointerEvent): void {
    const { target } = event;
    if (!(target instanceof HTMLImageElement)) {
      return;
    }
    const sources: string[] = [];
    let targetIndex = 0;
    [...this.imageTargets].forEach((image, index) => {
      const source = image.dataset.lightboxSrc ?? image.src;
      sources.push(source);
      if (image == target) {
        targetIndex = index;
      }
    });
    const lightbox = new FsLightbox();
    lightbox.props.sources = sources;
    lightbox.open(targetIndex);
  }
}
