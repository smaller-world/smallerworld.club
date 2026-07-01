import { Controller } from "@hotwired/stimulus";
import {
  animate,
  type AnimationOptions,
  type AnimationPlaybackControls,
} from "motion";
import { useResize } from "stimulus-use";

import { addCleanupAction } from "#helpers/stimulus_helpers";

const ROTATIONS = [-1, 2, -2, 1];
const STACK_OFFSET = 8;
const SCALE_STEP = 0.06;
const ELASTIC = 0.65;
const TILT_RANGE = 60;
const TILT_INPUT_RANGE = 100;
const SPRING: AnimationOptions = {
  type: "spring",
  stiffness: 260,
  damping: 20,
};

interface ImageDimensions {
  width: number;
  height: number;
}

interface DragState {
  img: HTMLImageElement;
  startX: number;
  startY: number;
  dx: number;
  dy: number;
  pointerId: number;
}

export default class ImageStackController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["image"];
  declare readonly imageTargets: HTMLImageElement[];

  // == Values ==

  static values = {
    flipBoundary: { type: Number, default: 100 },
    clickBoundary: { type: Number, default: 2 },
    maxHeight: { type: Number, default: 360 },
  };
  declare readonly flipBoundaryValue: number;
  declare readonly clickBoundaryValue: number;
  declare readonly maxHeightValue: number;

  // == State ==

  #currentIndex = 0;
  #containerWidth = 0;
  #drag: DragState | null = null;
  #dragFrame: number | null = null;
  #animations = new Set<AnimationPlaybackControls>();

  // == Lifecycle ==

  initialize(): void {
    super.initialize();
    useResize(this);
  }

  connect(): void {
    super.connect();
    addCleanupAction(this, "destroy");
  }

  disconnect(): void {
    super.disconnect();
    this.destroy();
  }

  // == Actions ==

  relayout(): void {
    let maxHeight = 0;
    const dimensionsByImage = new Map<HTMLImageElement, ImageDimensions>();
    for (const img of this.imageTargets) {
      const dimensions = this.#clampDimensions(this.#naturalDimensions(img));
      dimensionsByImage.set(img, dimensions);
      if (dimensions.height > maxHeight) {
        maxHeight = dimensions.height;
      }
    }

    this.element.style.height = `${maxHeight + (this.imageTargets.length - 1) * STACK_OFFSET}px`;
    for (const img of this.imageTargets) {
      const dimensions = dimensionsByImage.get(img);
      if (dimensions) {
        const { width, height } = dimensions;
        img.style.width = `${width}px`;
        img.style.height = `${height}px`;
      }
    }
    this.#restack({ animated: false });
  }

  resize(rect: DOMRectReadOnly): void {
    this.#containerWidth = rect.width;
    this.relayout();
  }

  startDrag(event: PointerEvent): void {
    if (this.imageTargets.length <= 1) {
      return;
    }
    if (!event.isPrimary || event.button !== 0) {
      return;
    }
    const { currentTarget } = event;
    if (!(currentTarget instanceof HTMLImageElement)) {
      return;
    }
    if (this.imageTargets.indexOf(currentTarget) !== this.#currentIndex) {
      return;
    }

    this.#finishAnimations();
    currentTarget.setPointerCapture(event.pointerId);
    currentTarget.style.cursor = "grabbing";
    this.#drag = {
      img: currentTarget,
      startX: event.clientX,
      startY: event.clientY,
      dx: 0,
      dy: 0,
      pointerId: event.pointerId,
    };
    currentTarget.addEventListener("pointermove", this.#moveDrag);
  }

  endDrag(event: PointerEvent): void {
    const { currentTarget } = event;
    if (!(currentTarget instanceof HTMLImageElement)) {
      return;
    }
    const drag = this.#drag;
    if (event.pointerId !== drag?.pointerId) {
      return;
    }
    currentTarget.removeEventListener("pointermove", this.#moveDrag);
    this.#stopDrag(drag);
    currentTarget.removeEventListener("pointermove", this.#moveDrag);
    const { flipBoundaryValue, clickBoundaryValue } = this;
    if (
      Math.abs(drag.dx) > flipBoundaryValue ||
      Math.abs(drag.dy) > flipBoundaryValue
    ) {
      this.#currentIndex = (this.#currentIndex + 1) % this.imageTargets.length;
      this.#restack({ animated: true });
    } else {
      if (
        Math.abs(drag.dx) <= clickBoundaryValue &&
        Math.abs(drag.dy) <= clickBoundaryValue
      ) {
        this.dispatch("click", { target: currentTarget });
      }
      const transform = this.#transformFor(this.imageTargets.indexOf(drag.img));
      this.#animate(
        drag.img,
        {
          transform: [drag.img.style.transform, transform],
        },
        SPRING,
      );
    }
  }

  destroy(): void {
    if (this.#drag) {
      this.#stopDrag(this.#drag);
    }
    this.#cancelDragFrame();
    this.#finishAnimations();
  }

  // == Helpers ==

  #moveDrag = (event: PointerEvent): void => {
    const drag = this.#drag;
    if (event.pointerId !== drag?.pointerId) {
      return;
    }
    drag.dx = event.clientX - drag.startX;
    drag.dy = event.clientY - drag.startY;
    this.#scheduleDragRender();
  };

  #naturalDimensions(img: HTMLImageElement): ImageDimensions {
    const w = img.naturalWidth || Number(img.getAttribute("width")) || 0;
    const h = img.naturalHeight || Number(img.getAttribute("height")) || 0;
    return { width: w, height: h };
  }

  #clampDimensions({ width, height }: ImageDimensions): ImageDimensions {
    if (!width || !height) {
      return { width: 0, height: 0 };
    }
    const maxW = this.#containerWidth || width;
    const maxH = this.maxHeightValue || height;
    const scale = Math.min(1, maxW / width, maxH / height);
    return { width: width * scale, height: height * scale };
  }

  #visualIndex(originalIndex: number): number {
    const n = this.imageTargets.length;
    return (originalIndex - this.#currentIndex + n) % n;
  }

  #rotationFor(originalIndex: number): number {
    if (this.imageTargets.length <= 1) {
      return 0;
    }
    return ROTATIONS[originalIndex % ROTATIONS.length] ?? 0;
  }

  #scheduleDragRender(): void {
    if (this.#dragFrame !== null) {
      return;
    }
    this.#dragFrame = requestAnimationFrame(() => {
      this.#dragFrame = null;
      this.#renderDrag();
    });
  }

  #cancelDragFrame(): void {
    if (this.#dragFrame === null) {
      return;
    }
    cancelAnimationFrame(this.#dragFrame);
    this.#dragFrame = null;
  }

  #renderDrag(): void {
    const drag = this.#drag;
    if (!drag) {
      return;
    }
    const originalIndex = this.imageTargets.indexOf(drag.img);
    drag.img.style.transform = this.#transformFor(originalIndex, {
      x: drag.dx * ELASTIC,
      y: drag.dy * ELASTIC,
      rotateX: clamp(
        (-drag.dy / TILT_INPUT_RANGE) * TILT_RANGE,
        -TILT_RANGE,
        TILT_RANGE,
      ),
      rotateY: clamp(
        (drag.dx / TILT_INPUT_RANGE) * TILT_RANGE,
        -TILT_RANGE,
        TILT_RANGE,
      ),
      scale: 1,
    });
  }

  #stopDrag(drag: DragState): void {
    this.#drag = null;
    this.#cancelDragFrame();
    if (drag.img.hasPointerCapture(drag.pointerId)) {
      drag.img.releasePointerCapture(drag.pointerId);
    }
    drag.img.style.cursor = "grab";
  }

  #transformFor(
    originalIndex: number,
    {
      x = 0,
      y = 0,
      rotateX = 0,
      rotateY = 0,
      scale = 1,
    }: Partial<{
      x: number;
      y: number;
      rotateX: number;
      rotateY: number;
      scale: number;
    }> = {},
  ): string {
    return [
      `translate3d(${x}px, ${y}px, 0)`,
      `rotateX(${rotateX}deg)`,
      `rotateY(${rotateY}deg)`,
      `rotateZ(${this.#rotationFor(originalIndex)}deg)`,
      `scale(${scale})`,
    ].join(" ");
  }

  #restack(options: { animated: boolean }): void {
    const n = this.imageTargets.length;
    this.imageTargets.forEach((img, originalIndex) => {
      const visualIndex = this.#visualIndex(originalIndex);
      const top = (n - 1 - visualIndex) * STACK_OFFSET;
      const scale = 1 - visualIndex * SCALE_STEP;
      const isTop = visualIndex === 0;
      img.toggleAttribute("data-blur", !isTop && n > 1);
      img.style.zIndex = String(n - visualIndex);
      img.style.cursor = isTop && n > 1 ? "grab" : "";
      if (options.animated) {
        const transform = this.#transformFor(originalIndex, { scale });
        this.#animate(
          img,
          {
            top: [img.style.top, `${top}px`],
            transform: [img.style.transform, transform],
          },
          SPRING,
        );
      } else {
        img.style.top = `${top}px`;
        img.style.transform = this.#transformFor(originalIndex, { scale });
      }
    });
  }

  #animate(
    img: HTMLImageElement,
    keyframes: Parameters<typeof animate>[1],
    options: Parameters<typeof animate>[2],
  ): void {
    const controls = animate(img, keyframes, options);
    this.#animations.add(controls);
    void controls.then(
      () => this.#animations.delete(controls),
      () => this.#animations.delete(controls),
    );
  }

  #finishAnimations(): void {
    this.#animations.forEach((animation) => animation.complete());
    this.#animations.clear();
  }
}

const clamp = (n: number, min: number, max: number): number =>
  Math.min(max, Math.max(min, n));
