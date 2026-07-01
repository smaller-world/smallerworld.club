import { Controller } from "@hotwired/stimulus";

export default class LightboxController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["image"];
  declare readonly imageTargets: HTMLCollectionOf<HTMLImageElement>;

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
