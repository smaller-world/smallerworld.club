import { Controller } from "@hotwired/stimulus";

export default class PostTypeSelectController extends Controller<HTMLElement> {
  // == Actions ==

  updateSearchParams(): void {
    const value = this.element.getAttribute("value");
    const url = new URL(location.href);
    if (value) {
      url.searchParams.set("type_id", value);
    } else {
      url.searchParams.delete("type_id");
    }
    history.replaceState(null, "", url.toString());
  }
}
