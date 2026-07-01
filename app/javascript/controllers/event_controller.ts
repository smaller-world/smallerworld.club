import { Controller } from "@hotwired/stimulus";

export default class EventController extends Controller {
  // == Actions ==

  preventDefault(event: Event): void {
    event.preventDefault();
  }

  stopPropagation(event: Event): void {
    event.stopPropagation();
  }
}
