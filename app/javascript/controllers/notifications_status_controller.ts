import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

import { type NotificationPermission } from "#helpers/notification_helpers";

const values = {
  pushTokenSaved: Boolean,
};

export default class NotificationsStatusController extends Typed(
  Controller<HTMLElement>,
  {
    values,
  },
) {
  // == Actions ==

  update({ detail }: CustomEvent<{ permission: NotificationPermission }>) {
    const status =
      detail.permission === "authorized" && this.pushTokenSavedValue
        ? "enabled"
        : "disabled";
    this.element.dataset.notifications = status;
    this.dispatch("change", { detail: { status } });
  }
}
