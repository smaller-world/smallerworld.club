import { Controller } from "@hotwired/stimulus";

export default class ModalController extends Controller<HTMLDialogElement> {
  // == Targets ==

  static targets = ["panel", "backdrop"];
  declare readonly panelTarget: HTMLElement;
  declare readonly backdropTarget: HTMLElement;

  // == State ==

  #previousActiveElement?: HTMLElement | null;
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
    if (document.activeElement instanceof HTMLElement) {
      this.#previousActiveElement = document.activeElement;
    }
    this.element.showModal();
    this.#addDocumentActions();
    void this.#waitForTransitions().then(() => {
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

  #addDocumentActions(): void {
    this.#updateActions((actions) => {
      actions.add("pointerdown@document->modal#onDocumentPointerDown");
      actions.add("click@document->modal#onDocumentClick");
    });
  }

  #removeDocumentActions(): void {
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

  /** @param {boolean} cancelled */
  async #requestClose(cancelled = false) {
    if (this.#isClosing) {
      return;
    }
    this.#markClosing();
    this.dispatch("closing");
    this.#removeDocumentActions();
    await this.#waitForTransitions();
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

  // == Focus helpers ==

  #focusPreviousActiveElement(): void {
    if (this.#previousActiveElement?.isConnected) {
      this.#previousActiveElement.focus({ preventScroll: true });
    }
  }

  // == Transition helpers ==

  async #waitForTransitions(): Promise<void> {
    /** @type {HTMLElement[]} */
    const targets = [this.backdropTarget, this.panelTarget];
    const animations = targets
      .flatMap((el) => el.getAnimations())
      .filter((animation) => animation instanceof CSSTransition);
    await Promise.allSettled(animations.map((animation) => animation.finished));
  }
}
