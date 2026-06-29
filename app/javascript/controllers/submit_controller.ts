import { Controller } from "@hotwired/stimulus";

export default class SubmitController extends Controller<HTMLFormElement> {
  // == Actions ==

  request(): void {
    this.element.requestSubmit();
  }
}
