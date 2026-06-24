import { BridgeComponent } from "@hotwired/hotwire-native-bridge";

export default class PassBridgeController extends BridgeComponent {
  static component = "pass";

  // == Values ==

  static values = {
    passTypeIdentifier: String,
    serialNumber: String,
  };
  declare readonly passTypeIdentifierValue: string;
  declare readonly serialNumberValue: string;

  // == Actions ==

  open(): void {
    super.connect();
    this.send("open", {
      passTypeIdentifier: this.passTypeIdentifierValue,
      serialNumber: this.serialNumberValue,
    });
  }
}
