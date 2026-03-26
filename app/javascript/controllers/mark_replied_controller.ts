import { Controller } from "@hotwired/stimulus";

export default class MarkRepliedController extends Controller<HTMLElement> {
  static values = { url: String };
  declare readonly urlValue: string;

  mark(): void {
    const token =
      document.querySelector<HTMLMetaElement>("meta[name=csrf-token]")
        ?.content ?? "";
    void fetch(this.urlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        Accept: "application/json",
      },
    });
  }
}
