import { Controller } from "@hotwired/stimulus";
import { confetti } from "@tsparticles/confetti/lazy";

import { particlePositionFor } from "#helpers/particles_helpers";

export default class ConfettiController extends Controller<HTMLElement> {
  // == Values ==

  static values = {
    emoji: String,
    canvasId: String,
  };
  declare readonly emojiValue: string;
  declare readonly canvasIdValue: string;

  // == Targets ==

  static targets = ["position", "input"];
  declare readonly positionTarget: HTMLElement;
  declare readonly inputTarget: HTMLInputElement;
  declare readonly hasPositionTarget: boolean;
  declare readonly hasInputTarget: boolean;

  // == Lifecycle ==

  connect(): void {
    super.connect();
    if (!this.canvasIdValue) {
      throw new Error("Missing canvasId value");
    }
  }

  // == Actions ==

  launch(event: any): void {
    if (event instanceof CustomEvent && event.type == "turbo:submit-end") {
      const { detail } = event as CustomEvent<{ success: boolean }>;
      if (!detail.success) {
        return;
      }
    }
    void confetti(this.canvasIdValue, {
      position: particlePositionFor(
        this.hasPositionTarget ? this.positionTarget : this.element,
      ),
      angle: 180,
      spread: 200,
      ticks: 60,
      gravity: 1,
      startVelocity: 18,
      count: 12,
      scalar: 2,
      shapes: ["emoji"],
      shapeOptions: {
        emoji: {
          value: this.hasInputTarget ? this.inputTarget.value : this.emojiValue,
        },
      },
    });
  }
}
