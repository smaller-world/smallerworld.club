import { Controller } from "@hotwired/stimulus";

export default class WorldPostTypeFormController extends Controller<HTMLFormElement> {
  // == Actions ==

  updateSearchParamsAndSubmit(): void {
    const formData = new FormData(this.element);
    const url = new URL(location.href);
    const typeId = formData.get("type_id");
    if (typeId && typeof typeId === "string") {
      url.searchParams.set("post_type_id", typeId);
    } else {
      url.searchParams.delete("post_type_id");
    }
    const onlyFavorited = formData.get("only_favorited");
    if (onlyFavorited && typeof onlyFavorited === "string") {
      url.searchParams.set("only_favorited", onlyFavorited);
    } else {
      url.searchParams.delete("only_favorited");
    }
    history.pushState(null, "", url.toString());
    this.element.requestSubmit();
  }
}
