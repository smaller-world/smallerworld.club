import { Controller } from "@hotwired/stimulus";

export default class DisableWhileSubmittingController extends Controller<
  HTMLInputElement | HTMLButtonElement
> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    const { form } = this.element;
    if (form) {
      form.addEventListener(
        "turbo:submit-start",
        this.#disableElementWhileSubmitting,
      );
    }
  }

  // == Helpers ==

  #disableElementWhileSubmitting = (): void => {
    if (!this.element.disabled) {
      this.element.disabled = true;
      const { form } = this.element;
      if (form) {
        form.addEventListener(
          "turbo:submit-end",
          this.#enableElementAfterSubmission,
        );
        document.addEventListener(
          "turbo:before-cache",
          this.#enableElementAfterSubmission,
        );
      }
    }
  };

  #enableElementAfterSubmission = (): void => {
    this.element.disabled = false;
    const { form } = this.element;
    if (form) {
      form.removeEventListener(
        "turbo:submit-end",
        this.#enableElementAfterSubmission,
      );
      document.removeEventListener(
        "turbo:before-cache",
        this.#enableElementAfterSubmission,
      );
    }
  };
}
