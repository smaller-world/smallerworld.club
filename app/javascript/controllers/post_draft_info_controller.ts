import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const targets = {
  typeIdInput: HTMLInputElement,
  descriptionLabel: HTMLElement,
};

const values = {
  worldId: String,
};

export default class PostDraftInfoController extends Typed(
  Controller<HTMLFormElement>,
  { targets, values },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.worldIdValue) {
      throw new Error("Missing worldId value");
    }
    requestIdleCallback(() => {
      this.update();
    });
  }

  // == Actions ==
  update(): void {
    const formData = this.#reconstructFormData();
    const typeId = formData.get("post[type_id]");
    if (this.hasTypeIdInputTarget && typeof typeId === "string") {
      this.typeIdInputTarget.value = typeId;
    }
    const title = formData.get("post[title]");
    const titleText = typeof title === "string" ? title.trim() : undefined;
    const body = formData.get("post[body]");
    const bodyText =
      typeof body === "string" ? this.#htmlTextContent(body) : undefined;
    if (titleText?.trim() || bodyText?.trim()) {
      this.element.dataset.draftAvailable = "";
    } else {
      delete this.element.dataset.draftAvailable;
    }
    if (this.hasDescriptionLabelTarget) {
      if (titleText?.trim()) {
        this.descriptionLabelTarget.textContent = titleText;
      } else if (bodyText?.trim()) {
        this.descriptionLabelTarget.textContent = bodyText;
      }
    }
  }

  // == Helpers ==

  get #localStorageKey(): string {
    return `post_draft:${this.worldIdValue}`;
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

  #htmlTextContent(html: string): string {
    const fragment = document.createRange().createContextualFragment(html);
    return fragment.textContent ?? "";
  }
}
