import { Controller } from "@hotwired/stimulus";

import { addAction } from "#helpers/stimulus_helpers";
import { urlPathWithQuery } from "#helpers/url_helpers";

export default class ReturnToSelfController extends Controller<HTMLAnchorElement> {
  // == Lifecycle ==

  initialize(): void {
    addAction(this, "click", "updateHref");
    addAction(this, "auxclick", "updateHref");
  }

  // == Actions ==

  updateHref(): void {
    const { href, dataset } = this.element;
    dataset.originalHref ??= href;
    const url = new URL(href);
    url.searchParams.set("return_to", urlPathWithQuery(location.href));
    this.element.href = url.href;
  }
}
