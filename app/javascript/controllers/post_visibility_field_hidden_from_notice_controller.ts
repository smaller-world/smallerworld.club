import { Controller } from "@hotwired/stimulus";

export default class PostVisibilityFieldHiddenFromNoticeController extends Controller {
  // == Targets ==

  static targets = ["input", "notice"];
  declare readonly inputTarget: HTMLSelectElement;
  declare readonly noticeTarget: HTMLElement;
  declare readonly hasNoticeTarget: boolean;

  // == Lifecycle ==

  connect() {
    this.updateVisibility();
  }

  // == Actions ==

  updateVisibility(): void {
    if (!this.hasNoticeTarget) {
      return;
    }
    if (this.inputTarget.value === "secret") {
      this.#hide();
    } else {
      this.#show();
    }
  }

  // == Helpers ==

  #show() {
    this.noticeTarget.classList.remove("hidden");
  }

  #hide() {
    this.noticeTarget.classList.add("hidden");
  }
}
