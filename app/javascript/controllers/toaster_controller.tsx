import { Controller } from "@hotwired/stimulus";
import { type Root } from "react-dom/client";

import { addCleanupAction } from "#helpers/stimulus_helpers";
import type { ToastEvent } from "#helpers/toaster_helpers";

export default class ToasterController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["listener"];
  declare readonly listenerTarget: HTMLElement;
  declare readonly hasListenerTarget: boolean;

  // == Properties ==

  #pendingToastEvents: ToastEvent[] = [];
  #reactRoot?: Root | null;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    void import("../helpers/toaster_helpers").then(({ createToasterRoot }) => {
      this.#reactRoot = createToasterRoot(this.element);
    });
    addCleanupAction(this, "unmount");
  }

  listenerTargetConnected(): void {
    while (this.#pendingToastEvents.length > 0) {
      const event = this.#pendingToastEvents.shift();
      if (event) {
        this.forwardToastEvent(event);
      }
    }
  }

  disconnect(): void {
    this.unmount();
  }

  // == Actions ==

  toast(event: ToastEvent): void {
    if (this.hasListenerTarget) {
      this.forwardToastEvent(event);
    } else {
      this.#pendingToastEvents.push(event);
    }
  }

  unmount(): void {
    if (this.#reactRoot) {
      this.#reactRoot.unmount();
      this.#reactRoot = null;
    }
  }

  // == Helpers ==

  forwardToastEvent({ type, detail }: ToastEvent): void {
    const event = new CustomEvent(type, { detail, bubbles: false });
    this.listenerTarget.dispatchEvent(event);
  }
}
