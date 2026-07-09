import ApplicationController from "./application_controller";

export default class WorldNewPostDialogController extends ApplicationController<HTMLElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (this.element.tagName !== "EL-DIALOG") {
      throw new Error(
        "Invalid element: must be connected to an el-dialog element",
      );
    }
  }

  // == Actions ==

  updateSearchParams(): void {
    const url = new URL(location.href);
    if (this.element.hasAttribute("open")) {
      url.searchParams.delete("new_post");
    } else {
      url.searchParams.set("new_post", "1");
    }
    history.replaceState(null, "", url.toString());
  }
}
