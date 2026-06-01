import type { TurboSubmitEndEvent } from "@hotwired/turbo";

import { addAction } from "#helpers/stimulus_helpers";

import FormController from "./form_controller";

interface AccountTimeZoneFormResponse {
  user?: { id: string; time_zone_name: string };
  error?: string;
}

export default class AccountTimeZoneFormController extends FormController {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    addAction(this, "turbo:submit-end", "handleErrorResponse");
  }

  // == Actions ==

  handleErrorResponse(event: TurboSubmitEndEvent): void {
    const { success, fetchResponse } = event.detail;
    if (success || !fetchResponse) {
      return;
    }
    void fetchResponse.response
      .json()
      .then((data: AccountTimeZoneFormResponse) => {
        const { user, error } = data;
        if (user) {
          console.info("User time zone updated", { user });
          this.dispatch("success", { detail: { user } });
        } else if (error) {
          console.error("Failed to update user time zone", error);
          this.dispatch("error", { detail: { message: error } });
        }
      });
  }
}
