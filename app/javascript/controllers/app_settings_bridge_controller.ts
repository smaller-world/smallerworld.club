import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

export default class AppSettingsBridgeController extends BridgeComponent<HTMLElement> {
  static component = "app-settings";

  // == Actions ==

  open(): void {
    this.send("open");
  }
}
