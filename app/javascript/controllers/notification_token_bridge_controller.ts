import { BridgeComponent } from "@hotwired/hotwire-native-bridge";
import { Typed } from "stimulus-typescript";

import { type NotificationPermission } from "#helpers/notification_helpers";

const values = {
  provisional: Boolean,
};

// eslint-disable-next-line @typescript-eslint/consistent-type-definitions
type RequestReply = {
  token: string | null;
  permission: NotificationPermission;
  error: string | null;
};

export default class NotificationTokenBridgeController extends Typed(
  BridgeComponent,
  { values },
) {
  static component = "notification-token";

  // == Lifecycle ==

  connect() {
    super.connect();
    this.send("connect");
  }

  // == Actions ==

  request(event?: Event) {
    if (event) {
      event.stopImmediatePropagation();
      event.preventDefault();
    }
    this.send<RequestReply>(
      "request",
      { provisional: this.provisionalValue },
      ({ data }) => {
        const { token, permission, error } = data;
        if (token) {
          this.dispatch("retrieved", { detail: { token, permission } });
          return;
        }

        // No token: either the user denied the prompt, or authorization was
        // granted but registering with APNs failed. Branch on `permission`
        // (not `error`) — denial is not an error on iOS.
        if (permission === "denied") {
          this.dispatch("denied");
          this.toast(
            "error",
            "couldn't enable notifications :(",
            "you'll have to go to settings > smaller world to enable notifications! tysmm",
          );
        } else {
          console.error("Failed to enable notifications", data);
          this.dispatch("failed", { detail: { error } });
          this.toast(
            "error",
            "failed to enable notifications",
            error ?? "something went wrong setting up notifications :(",
          );
        }
      },
    );
  }

  // == Helpers ==

  private toast(type: string, message: string, description: string | null) {
    this.dispatch("toast", {
      prefix: "",
      detail: { message, type, description },
    });
  }
}
