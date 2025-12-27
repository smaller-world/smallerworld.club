import { Controller } from "@hotwired/stimulus";

export default class ModalController extends Controller {
  // == Targets ==

  static targets = ["dialog", "panel", "backdrop"];
  declare readonly dialogTarget: HTMLDialogElement;
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
    if (!this.dialogTarget.open) {
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

  open(): void {
    if (this.dialogTarget.open) {
      return;
    }
    this.#storePreviousActiveElement();
    this.dialogTarget.showModal();
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

  teardown(): void {
    if (!this.dialogTarget.open) {
      return;
    }
    this.#removeBackdropListeners();
    this.dialogTarget.close();
    if (this.#isClosing) {
      this.#clearClosing();
    }
    this.dispatch("cancelled");
    this.dispatch("closed");
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
    if (this.dialogTarget.dataset.action) {
      parser.className = this.dialogTarget.dataset.action;
    }
    update(parser.classList);
    this.dialogTarget.dataset.action = parser.className;
  }

  // == Closing helpers ==

  async #requestClose(cancelled = false): Promise<void> {
    if (!this.dialogTarget.open || this.#isClosing) {
      return;
    }
    this.#markClosing();
    this.dispatch("closing");
    this.#removeBackdropListeners();
    await this.#afterAnimate();
    this.dialogTarget.close();
    this.#clearClosing();
    this.#focusPreviousActiveElement();
    if (cancelled) {
      this.dispatch("cancelled");
    }
    this.dispatch("closed");
  }

  get #isClosing(): boolean {
    return this.dialogTarget.dataset.closing === "true";
  }

  #markClosing(): void {
    this.dialogTarget.dataset.closing = "true";
  }

  #clearClosing(): void {
    delete this.dialogTarget.dataset.closing;
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
