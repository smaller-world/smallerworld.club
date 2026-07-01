import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

export default class NotificationBadgeCountBridgeController extends BridgeComponent {
  static component = "notification-badge-count";

  // == Lifecycle ==

  connect(): void {
    super.connect();
    this.send<{ badgeCount: number }>("connect", undefined, ({ data }) => {
      const { badgeCount } = data;
      if (badgeCount > 0) {
        this.clear();
      }
    });
  }

  // == Actions ==

  clear(): void {
    this.send<{ error: string | null }>("clear", {}, ({ data }) => {
      const { error } = data;
      if (error) {
        console.error("Failed to clear notification badge count:", error);
        return;
      }
      this.dispatch("cleared");
    });
  }
}
