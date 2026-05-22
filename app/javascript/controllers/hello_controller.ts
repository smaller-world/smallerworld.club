import { Controller } from "@hotwired/stimulus";

export default class HelloController extends Controller {
  // == Lifecycle ==

  connect(): void {
    this.element.textContent = "Hello World!";
    super.connect();
  }
}
