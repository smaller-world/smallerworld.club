import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

export default class NotificationPermissionBridgeController extends BridgeComponent {
  static component = "notification-permission";

  // == Lifecycle ==

  connect() {
    super.connect();
    this.send<{
      permission: "authorized" | "denied" | "provisional" | "indeterminate";
    }>("connect", {}, ({ data }) => {
      const { permission } = data;
      this.dispatch("retrieved", { detail: { permission } });
      if (permission === "indeterminate") {
        this.dispatch("pending-authorization");
      }
    });
  }
}
