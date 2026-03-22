import { Controller } from "@hotwired/stimulus";
import invariant from "tiny-invariant";

export default class LocateController extends Controller<HTMLElement> {
  // == Targets ==

  static targets = ["input"];

  declare readonly inputTarget: HTMLInputElement;
  declare readonly hasInputTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    invariant(this.hasInputTarget, "Missing input target");
  }

  // == Actions ==

  locate(): void {
    navigator.geolocation.getCurrentPosition((position) => {
      const { latitude, longitude } = position.coords;
      this.inputTarget.value = `POINT(${longitude} ${latitude})`;
      this.dispatch("located");
    });
  }
}
