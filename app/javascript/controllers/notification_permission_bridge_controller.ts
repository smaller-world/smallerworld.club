import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

import { type NotificationPermission } from "#helpers/notification_helpers";

export default class NotificationPermissionBridgeController extends BridgeComponent<HTMLElement> {
  static component = "notification-permission";

  // == Actions ==

  get(): void {
    this.send<{ permission: NotificationPermission }>("get", {}, ({ data }) => {
      const { permission } = data;
      this.element.dataset.notificationPermission = permission;
      this.dispatch("retrieved", { detail: { permission } });
      if (permission === "indeterminate") {
        this.dispatch("pending-authorization");
      } else if (permission === "authorized") {
        this.dispatch("authorized");
      }
    });
  }
}
