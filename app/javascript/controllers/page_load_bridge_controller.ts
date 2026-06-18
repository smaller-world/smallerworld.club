import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

export default class PageLoadBridgeController extends BridgeComponent {
  static component = "page-load";

  // == Lifecycle ==

  connect() {
    super.connect();
    this.send("connect");
  }
}
