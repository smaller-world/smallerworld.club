import { Controller } from "@hotwired/stimulus";

export default class PushTokenInputController extends Controller<HTMLInputElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.dispatch("connected");
  }

  // == Actions ==

  setToken(event: CustomEvent<{ token: string }>): void {
    this.element.value = event.detail.token;
    this.dispatch("token-set");
  }
}
