import { Controller } from "@hotwired/stimulus";
import { Typed } from "stimulus-typescript";

export default class EventController extends Typed(Controller, {}) {
  // == Actions ==

  preventDefault(event: Event): void {
    event.preventDefault();
  }

  stopPropagation(event: Event): void {
    event.stopPropagation();
  }
}
