import { Controller } from "@hotwired/stimulus";
import { useIntersection } from "stimulus-use";

export default class IntersectionController extends Controller<HTMLElement> {
  // == Lifecycle ==

  initialize(): void {
    super.initialize();
    useIntersection(this);
  }
}
