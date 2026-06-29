import { Controller } from "@hotwired/stimulus";

export default class PushTokenInputController extends Controller<HTMLInputElement> {
  // == Actions ==

  setToken(event: CustomEvent<{ token: string }>): void {
    this.element.value = event.detail.token;
    this.dispatch("token-set");
  }
}
