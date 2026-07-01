import { Controller } from "@hotwired/stimulus";

export default class WorldPostTypeInputController extends Controller<HTMLInputElement> {
  // == Actions ==

  updateSearchParams(): void {
    const { value, checked } = this.element;
    const url = new URL(location.href);
    if (value && checked) {
      url.searchParams.set("post_type_id", value);
    } else {
      url.searchParams.delete("post_type_id");
    }
    history.pushState(null, "", url.toString());
  }
}
