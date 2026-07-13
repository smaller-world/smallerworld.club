import { Controller } from "@hotwired/stimulus";
import { visit } from "@hotwired/turbo";

export default class PageReloadController extends Controller {
  // == Actions ==

  reload(): void {
    visit(location.href, { action: "replace" });
  }
}
