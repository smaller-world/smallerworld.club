import { Controller } from "@hotwired/stimulus";

export default class PushTokenInputController extends Controller<HTMLInputElement> {
  // == Actions ==

  setToken({ detail: { token } }: CustomEvent<{ token: string }>): void {
    const { value } = this.element;
    this.element.value = token;
    if (value !== token) {
      this.dispatch("changed");
    }
  }
}
