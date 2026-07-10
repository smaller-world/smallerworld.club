import { Controller } from "@hotwired/stimulus";
import { visit } from "@hotwired/turbo";

import { urlPathWithQuery } from "#helpers/url_helpers";

export default class RedirectBackToSelfController extends Controller<HTMLAnchorElement> {
  // == Helpers ==

  visit(): void {
    const url = new URL(this.element.href, location.href);
    url.searchParams.set("redirect_back_to", urlPathWithQuery(location.href));
    visit(url.toString());
  }
}
