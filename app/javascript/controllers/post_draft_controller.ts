import { Controller } from "@hotwired/stimulus";
import { useDebounce } from "stimulus-use";

import { hasValueSetter } from "#helpers/form_helpers";
import { addCleanupAction } from "#helpers/stimulus_helpers";

export default class PostDraftController extends Controller<HTMLFormElement> {
  // == Targets ==

  static targets = ["savedTimestampLabel"];
  declare readonly savedTimestampLabelTarget: HTMLElement;
  declare readonly hasSavedTimestampLabelTarget: boolean;

  // == Configuration ==

  static debounces = ["save"];

  // == Values ==

  static values = {
    worldId: String,
  };
  declare readonly worldIdValue: string;

  // == Properties ==

  #savedTimestampFlashTimeout?: number | null;

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
    addCleanupAction(this, "restoreSavedTimestampLabel");
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
      if (hasValueSetter(input)) {
        input.value = value;
        formData.delete(key);
      }
    });
    formData.forEach((value, key) => {
      if (value instanceof File) {
        return;
      }
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = key;
      input.value = value;
      this.element.appendChild(input);
    });
    this.element.requestSubmit();
  }

  clear(): void {
    localStorage.removeItem(this.#localStorageKey);
  }

  // == Helpers ==

  get #localStorageKey(): string {
    return `post_draft:${this.worldIdValue}`;
  }

  #serializeFormData(): string {
    const formData = new FormData(this.element);
    formData.delete("authenticity_token");
    formData.delete("_method");
    const searchParams = new URLSearchParams();
    formData.forEach((value, key) => {
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
