import { Controller } from "@hotwired/stimulus";

export default class HelloController extends Controller {
  connect() {
    this.element.textContent = "Hello World!";
  }
}
