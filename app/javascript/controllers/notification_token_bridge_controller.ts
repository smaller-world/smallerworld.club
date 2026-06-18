import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

export default class NotificationTokenBridgeController extends BridgeComponent {
  static component = "notification-token";

  // == Values ==

  static values = {
    provisional: Boolean,
  };
  declare readonly provisionalValue: boolean;

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
        this.dispatch("retrieved", { detail: token });
      },
    );
  }
}
