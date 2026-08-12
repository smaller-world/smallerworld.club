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
    this.element.dataset.notifications =
      detail.permission === "authorized" && this.pushTokenSavedValue
        ? "enabled"
        : "disabled";
  }
}
