import { Controller } from "@hotwired/stimulus";

export default class SelectAllController extends Controller<HTMLInputElement> {
  // == Actions ==

  select(): void {
    this.element.select();
  }
}
