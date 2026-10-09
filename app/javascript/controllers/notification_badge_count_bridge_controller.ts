import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

export default class NotificationBadgeCountBridgeController extends BridgeComponent {
  static component = "notification-badge-count";

  // == Actions ==

  clear(): void {
    this.send<{ error: string | null }>("clear", {}, ({ data: { error } }) => {
      if (error) {
        console.error("Failed to clear notification badge count:", error);
        return;
      }
      this.dispatch("cleared");
    });
  }
}
