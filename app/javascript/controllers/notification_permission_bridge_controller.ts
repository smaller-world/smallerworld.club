import { BridgeComponent } from "@hotwired/hotwire-native-bridge";
import { create, enums, object } from "superstruct";

const ConnectMessageData = object({
  permission: enums(["granted", "denied", "indeterminate"]),
});

export default class NotificationPermissionBridgeController extends BridgeComponent {
  // == Configuration ==

  static component = "notification-permission";

  // == Lifecycle ==

  connect() {
    super.connect();
    this.send("connect", {}, ({ data }) => {
      const { permission } = create(data, ConnectMessageData);
      this.bridgeElement.setBridgeAttribute("permission", permission);
    });
  }
}
