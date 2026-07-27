import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

import { type NotificationPermission } from "#helpers/notification_helpers";

export default class NotificationPermissionBridgeController extends BridgeComponent {
  static component = "notification-permission";

  // == Lifecycle ==

  connect() {
    super.connect();
    this.send<{ permission: NotificationPermission }>(
      "connect",
      {},
      ({ data }) => {
        const { permission } = data;
        this.dispatch("retrieved", { detail: { permission } });
        if (permission === "indeterminate") {
          this.dispatch("pending-authorization");
        } else if (permission === "authorized") {
          this.dispatch("authorized");
        }
      },
    );
  }
}
