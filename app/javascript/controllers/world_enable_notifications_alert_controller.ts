import { Controller } from "@hotwired/stimulus";

export default class WorldEnableNotificationsAlertController extends Controller<HTMLElement> {
  // == Actions ==

  update({ detail }: CustomEvent<{ status: "enabled" | "disabled" }>) {
    this.element.hidden = detail.status === "enabled";
  }
}
