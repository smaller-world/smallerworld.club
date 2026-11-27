import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const values = {
  editUrlTemplate: String,
};

const targets = {
  select: HTMLSelectElement,
  editAnchor: HTMLAnchorElement,
};

export default class PostTypeSelectController extends Typed(
  Controller<HTMLSelectElement>,
  { values, targets },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.selectTarget) {
      throw new Error("Missing select target");
    }
    if (!this.editAnchorTarget) {
      throw new Error("Missing editAnchor target");
    }
    if (!this.editUrlTemplateValue) {
      throw new Error("Missing editUrlTemplate value");
    }
  }

  // == Actions ==

  update(): void {
    const postTypeId = this.#selectedPostTypeId();
    if (postTypeId) {
      this.#updateEditAnchor(postTypeId);
      this.#updateSearchParams(postTypeId);
    }
  }

  // == Helpers ==

  #selectedPostTypeId(): string | null {
    const { value } = this.selectTarget;
    return value;
  }

  #updateSearchParams(postTypeId: string): void {
    const url = new URL(location.href);
    url.searchParams.set("type_id", postTypeId);
    history.replaceState(null, "", url.toString());
  }

  #updateEditAnchor(postTypeId: string): void {
    this.editAnchorTarget.href = this.editUrlTemplateValue.replaceAll(
      ":post_type_id",
      postTypeId,
    );
  }
}
