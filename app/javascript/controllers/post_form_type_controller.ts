import { Controller } from "@hotwired/stimulus";
import { FrameElement } from "@hotwired/turbo";
import { Typed } from "stimulus-typescript";

const values = {
  recipientsSelectFrameUrlTemplate: String,
  editUrlTemplate: String,
};

const targets = {
  select: HTMLSelectElement,
  editAnchor: HTMLAnchorElement,
  recipientsSelectFrame: FrameElement,
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
    if (!this.recipientsSelectFrameUrlTemplateValue) {
      throw new Error("Missing recipientsSelectFrameUrlTemplate value");
    }
  }

  // == Actions ==

  update(): void {
    const postTypeId = this.#selectedPostTypeId();
    if (postTypeId) {
      this.#updateEditAnchor(postTypeId);
      this.#updateRecipientsSelectFrame(postTypeId);
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

  #updateRecipientsSelectFrame(postTypeId: string): void {
    if (this.hasRecipientsSelectFrameTarget) {
      const frameUrl = this.recipientsSelectFrameUrlTemplateValue.replaceAll(
        ":post_type_id",
        postTypeId,
      );
      this.recipientsSelectFrameTarget.src = frameUrl;
    }
  }

  #updateEditAnchor(postTypeId: string): void {
    this.editAnchorTarget.href = this.editUrlTemplateValue.replaceAll(
      ":post_type_id",
      postTypeId,
    );
  }
}
