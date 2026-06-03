import { BridgeComponent } from "@hotwired/hotwire-native-bridge";
import { isEmpty } from "lodash-es";

export interface PassData {
  passTypeIdentifier: string;
  serialNumber: string;
}

export default class PassesBridgeController extends BridgeComponent {
  static component = "passes";

  connect() {
    super.connect();
    this.send<{ passes: PassData[] }>("connect", {}, (message) => {
      const { passes } = message.data;
      if (!isEmpty(passes)) {
        this.dispatch("received", { detail: { passes } });
      }
    });
  }
}
