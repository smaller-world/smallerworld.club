import { Controller } from "@hotwired/stimulus";

export default class ModalController extends Controller<HTMLDialogElement> {
  // == Targets ==

  static targets = ["panel", "backdrop"];
  declare readonly panelTarget: HTMLElement;
  declare readonly backdropTarget: HTMLElement;

  // == Focus previous active element ==

  #previousActiveElement?: HTMLElement | null;

  #storePreviousActiveElement(): void {
    if (document.activeElement instanceof HTMLElement) {
      this.#previousActiveElement = document.activeElement;
    }
  }

  #focusPreviousActiveElement(): void {
    if (this.#previousActiveElement?.isConnected) {
      this.#previousActiveElement.focus({ preventScroll: true });
      this.#previousActiveElement = null;
    }
  }

  // == Backdrop click detection ==

  #pointerDownTarget?: EventTarget | null;

  // == Lifecycle ==

  disconnect(): void {
    super.disconnect();
    this.#previousActiveElement = undefined;
    this.#pointerDownTarget = undefined;
  }

  // == Actions ==

  onDocumentPointerDown(event: PointerEvent): void {
    this.#pointerDownTarget = event.target;
  }

  onDocumentClick(event: PointerEvent): void {
    if (!this.element.open) {
      return;
    }
    if (!(event.target instanceof Node)) {
      return;
    }
    if (event.target !== this.#pointerDownTarget) {
      return;
    }
    if (event.target === this.backdropTarget) {
      void this.#requestClose(true);
    }
    if (!this.panelTarget.contains(event.target)) {
      void this.#requestClose(true);
    }
  }

  onDialogCancel(event: Event): void {
    event.preventDefault();
    void this.#requestClose(true);
  }

  open(event?: Event): void {
    if (event) {
      event.preventDefault();
    }
    if (this.element.open) {
      return;
    }
    this.#storePreviousActiveElement();
    this.element.showModal();
    this.#addBackdropListeners();
    void this.#afterAnimate().then(() => {
      this.dispatch("opened");
    });
    requestAnimationFrame(() => {
      this.panelTarget.focus({ preventScroll: true });
    });
  }

  close(event?: Event): void {
    if (event) {
      event.preventDefault();
    }
    void this.#requestClose();
  }

  // == Action helpers ==

  #addBackdropListeners(): void {
    this.#updateActions((actions) => {
      actions.add("pointerdown@document->modal#onDocumentPointerDown");
      actions.add("click@document->modal#onDocumentClick");
    });
  }

  #removeBackdropListeners(): void {
    this.#updateActions((actions) => {
      actions.remove("pointerdown@document->modal#onDocumentPointerDown");
      actions.remove("click@document->modal#onDocumentClick");
    });
  }

  #updateActions(update: (actions: DOMTokenList) => void): void {
    const parser = document.createElement("div");
    if (this.element.dataset.action) {
      parser.className = this.element.dataset.action;
    }
    update(parser.classList);
    this.element.dataset.action = parser.className;
  }

  // == Closing helpers ==

  async #requestClose(cancelled = false): Promise<void> {
    if (!this.element.open || this.#isClosing) {
      return;
    }
    this.#markClosing();
    this.dispatch("closing");
    this.#removeBackdropListeners();
    await this.#afterAnimate();
    this.element.close();
    this.#clearClosing();
    this.#focusPreviousActiveElement();
    if (cancelled) {
      this.dispatch("cancelled");
    }
    this.dispatch("closed");
  }

  get #isClosing(): boolean {
    return this.element.dataset.closing === "true";
  }

  #markClosing(): void {
    this.element.dataset.closing = "true";
  }

  #clearClosing(): void {
    delete this.element.dataset.closing;
  }

  // == Transition helpers ==

  async #afterAnimate(): Promise<void> {
    const targets = [this.backdropTarget, this.panelTarget];
    const transitions = targets
      .flatMap((el) => el.getAnimations())
      .filter((animation) => animation instanceof CSSTransition);
    await Promise.allSettled(transitions.map(({ finished }) => finished));
  }
}
