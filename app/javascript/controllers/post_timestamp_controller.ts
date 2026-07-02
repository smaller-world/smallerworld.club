import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

const values = {
  datetime: String,
};

export default class PostTimestampController extends Typed(
  Controller<HTMLTimeElement>,
  { values },
) {
  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.datetimeValue) {
      throw new Error("Missing datetime value");
    }
    this.element.textContent = this.#formatDateTime();
  }

  // == Helpers ==

  #formatDateTime(): string {
    const date = new Date(this.datetimeValue);
    const now = new Date();
    const time = date.toLocaleTimeString("en-US", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
    });
    let formatted: string;
    if (
      date.getFullYear() === now.getFullYear() &&
      date.getMonth() === now.getMonth() &&
      date.getDate() === now.getDate()
    ) {
      formatted = time;
    } else if (date.getFullYear() === now.getFullYear()) {
      const monthDay = date.toLocaleDateString("en-US", {
        month: "long",
        day: "numeric",
      });
      formatted = `${monthDay}, ${time}`;
    } else {
      const monthDayYear = date.toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
        year: "numeric",
      });
      formatted = `${monthDayYear}, ${time}`;
    }
    return formatted;
  }
}
