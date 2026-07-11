import { Controller } from "@hotwired/stimulus";

import { addAction } from "#helpers/stimulus_helpers";

export default class AsyncSubmissionController extends Controller<HTMLFormElement> {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    addAction(this, "submit", "submit");
  }

  // == Actions ==

  submit(event: SubmitEvent): void {
    event.preventDefault();
    const data = new FormData(this.element);
    const { action, method } = this.element;
    this.context.logDebugActivity("submit", { action });
    console.debug(`Started submission to ${action}`);
    void fetch(action, { method, body: data })
      .then((response) => response.json())
      .then(
        ({ error, ...payload }) => {
          if (typeof error === "string") {
            console.error(`Submission to ${action} failed:`, error);
          } else {
            console.debug(`Submission to ${action} completed with:`, payload);
          }
        },
        (error) => {
          console.error("Error during submission:", error);
        },
      );
  }
}
