import { Controller } from "@hotwired/stimulus";

export default class FormController extends Controller<HTMLFormElement> {
  // == Actions ==

  submit(): void {
    void this.element.requestSubmit(this.#submitButton);
  }

  enable(): void {
    if (this.#submitButton) {
      this.#submitButton.disabled = false;
    }
  }

  disable(): void {
    if (this.#submitButton) {
      this.#submitButton.disabled = true;
    }
  }

  // == Helpers ==

  get #submitButton(): HTMLButtonElement | null {
    return this.element.querySelector('button[type="submit"]');
  }
}
