import { BridgeComponent } from "@hotwired/hotwire-native-bridge";
import { Typed } from "stimulus-typescript";

const values = {
  provisional: Boolean,
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
    this.send<{ token: string }>(
      "request",
      { provisional: this.provisionalValue },
      ({ data }) => {
        const { token } = data;
        this.dispatch("retrieved", { detail: { token } });
      },
    );
  }
}
