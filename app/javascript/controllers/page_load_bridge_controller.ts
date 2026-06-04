import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

export default class PageLoadBridgeController extends BridgeComponent {
  static component = "page-load";

  connect() {
    super.connect();
    this.send("connect");
  }
}
