import { Controller } from "@hotwired/stimulus";

import {
  addAction,
  addCleanupAction,
  removeAction,
  waitForTransitionAnimations,
} from "#helpers/stimulus_helpers";

export default class ModalController extends Controller<HTMLElement> {
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

  connect(): void {
    super.connect();
    addCleanupAction(this, "destroy");
  }

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
    this.#addBackdropActions();
    void this.#waitForTransitionAnimations().then(() => {
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

  destroy(): void {
    if (!this.dialogTarget.open) {
      return;
    }
    this.#removeBackdropActions();
    this.dialogTarget.close();
    if (this.#isClosing) {
      this.#clearClosing();
    }
    this.dispatch("cancelled");
    this.dispatch("closed");
  }

  // == Backdrop helpers ==

  #addBackdropActions(): void {
    addAction(this, "pointerdown@document", "onDocumentPointerDown");
    addAction(this, "click@document", "onDocumentClick");
  }

  #removeBackdropActions(): void {
    removeAction(this, "pointerdown@document", "onDocumentPointerDown");
    removeAction(this, "click@document", "onDocumentClick");
  }

  // == Closing helpers ==

  async #requestClose(cancelled = false): Promise<void> {
    if (!this.dialogTarget.open || this.#isClosing) {
      return;
    }
    this.#markClosing();
    this.dispatch("closing");
    this.#removeBackdropActions();
    await this.#waitForTransitionAnimations();
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

  #waitForTransitionAnimations(): Promise<void> {
    return waitForTransitionAnimations(this.backdropTarget, this.panelTarget);
  }
}
