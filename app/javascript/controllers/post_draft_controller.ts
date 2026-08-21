import { Controller } from "@hotwired/stimulus";
import type { TurboSubmitEndEvent } from "@hotwired/turbo";
import { Typed } from "stimulus-typescript";
import { useDebounce } from "stimulus-use";

const targets = {
  savedTimestampLabel: HTMLElement,
};

const values = {
  worldId: String,
  restoring: Boolean,
};

export default class PostDraftController extends Typed(
  Controller<HTMLFormElement>,
  { targets, values },
) {
  #savedTimestampFlashTimeout?: number | null;

  // == Configuration ==

  static debounces = ["save"];

  // == Lifecycle ==

  initialize(): void {
    super.initialize();
    useDebounce(this);
  }

  connect(): void {
    super.connect();
    if (!this.hasSavedTimestampLabelTarget) {
      throw new Error("Missing savedTimestampLabel target");
    }
    if (!this.worldIdValue) {
      throw new Error("Missing worldId value");
    }
  }

  disconnect(): void {
    super.disconnect();
    if (this.#savedTimestampFlashTimeout) {
      clearTimeout(this.#savedTimestampFlashTimeout);
      this.#savedTimestampFlashTimeout = null;
    }
  }

  // == Actions ==

  save(): void {
    requestIdleCallback(() => {
      const value = this.#serializeFormData();
      localStorage.setItem(this.#localStorageKey, value);
      this.#flashSavedTimestamp();
    });
  }

  restore(): void {
    const formData = this.#reconstructFormData();
    formData.forEach((value, key) => {
      if (value instanceof File) {
        return;
      }
      const input = this.element.elements.namedItem(key);
      if (!key.endsWith("[]") && input) {
        if (
          input instanceof HTMLInputElement ||
          input instanceof RadioNodeList
        ) {
          input.value = value;
        } else if (input.tagName === "LEXXY-EDITOR") {
          // @ts-expect-error Untyped property
          input.value = value;
        }
      } else {
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = key;
        input.value = value;
        this.element.appendChild(input);
      }
    });
    requestAnimationFrame(() => {
      this.element.requestSubmit();
    });
  }

  // Clear the draft from local storage IF:
  // - Draft was not restored successfully
  // - Post was submitted successfully
  clear(event: TurboSubmitEndEvent): void {
    if (
      (this.restoringValue && !event.detail.success) ||
      (!this.restoringValue && event.detail.success)
    ) {
      localStorage.removeItem(this.#localStorageKey);
    }
  }

  // == Helpers ==

  get #localStorageKey(): string {
    return `post_draft:${this.worldIdValue}`;
  }

  #serializeFormData(): string {
    const formData = new FormData(this.element);
    const searchParams = new URLSearchParams();
    formData.forEach((value, key) => {
      if (!key.startsWith("post")) {
        return;
      }
      if (typeof value === "string") {
        searchParams.append(key, value);
      }
    });
    return searchParams.toString();
  }

  #reconstructFormData(): FormData {
    const formData = new FormData();
    const value = localStorage.getItem(this.#localStorageKey);
    if (value) {
      const searchParams = new URLSearchParams(value);
      searchParams.forEach((value, key) => {
        formData.append(key, value);
      });
    }
    return formData;
  }

  #flashSavedTimestamp(): void {
    delete this.savedTimestampLabelTarget.dataset.fade;
    this.savedTimestampLabelTarget.textContent =
      this.#formatSavedTimestampLabel();
    if (this.#savedTimestampFlashTimeout) {
      clearTimeout(this.#savedTimestampFlashTimeout);
    }
    this.#savedTimestampFlashTimeout = setTimeout(() => {
      this.savedTimestampLabelTarget.dataset.fade = "true";
    }, 2000);
  }

  #formatSavedTimestampLabel(): string {
    const time = new Date().toLocaleTimeString([], {
      hour: "numeric",
      minute: "2-digit",
    });
    return `draft saved at ${time}`;
  }
}
