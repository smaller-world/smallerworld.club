import { Controller } from "@hotwired/stimulus";
import { FrameElement } from "@hotwired/turbo";
import { Typed } from "stimulus-typescript";

const values = {
  recipientsSelectFrameUrlTemplate: String,
};

const targets = {
  select: HTMLSelectElement,
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
    if (!this.recipientsSelectFrameUrlTemplateValue) {
      throw new Error("Missing recipientsSelectFrameUrlTemplate value");
    }
    if (!this.hasRecipientsSelectFrameTarget) {
      throw new Error("Missing recipientsSelectFrame target");
    }
  }

  // == Actions ==

  update(): void {
    const postTypeId = this.#selectedPostTypeId();
    if (postTypeId) {
      this.#updateSearchParams(postTypeId);
      this.#updateRecipientsSelectFrame(postTypeId);
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
    const frameUrl = this.recipientsSelectFrameUrlTemplateValue.replace(
      ":post_type_id",
      postTypeId,
    );
    this.recipientsSelectFrameTarget.src = frameUrl;
  }
}
