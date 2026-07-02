import { BridgeComponent } from "@hotwired/hotwire-native-bridge";
import { Typed } from "stimulus-typescript";

const values = {
  passTypeIdentifier: String,
  serialNumber: String,
};

export default class PassBridgeController extends Typed(BridgeComponent, {
  values,
}) {
  static component = "pass";

  // == Actions ==

  open(): void {
    super.connect();
    this.send("open", {
      passTypeIdentifier: this.passTypeIdentifierValue,
      serialNumber: this.serialNumberValue,
    });
  }
}
