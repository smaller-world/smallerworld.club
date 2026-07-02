import { Controller } from "@hotwired/stimulus";

export default class DevicePushTokenInputController extends Controller<HTMLInputElement> {
  // == Actions ==

  setValue({ detail }: CustomEvent<{ token: string }>): void {
    const { value: initialValue } = this.element;
    const { token } = detail;
    this.element.value = token;
    if (initialValue !== token) {
      this.dispatch("changed");
    }
  }
}
