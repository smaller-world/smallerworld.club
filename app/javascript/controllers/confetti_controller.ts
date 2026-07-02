import { Controller } from "@hotwired/stimulus";
import { confetti } from "@tsparticles/confetti/lazy";
import { Typed } from "stimulus-typescript";

import { particlePositionFor } from "#helpers/particles_helpers";

const targets = {
  position: HTMLElement,
  input: HTMLInputElement,
};

const values = {
  emoji: String,
  canvasId: String,
};

export default class ConfettiController extends Typed(Controller<HTMLElement>, {
  targets,
  values,
}) {
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
      ticks: 400,
      gravity: 1,
      startVelocity: 18,
      count: 40,
      scalar: 2.2,
      shapes: ["emoji"],
      shapeOptions: {
        emoji: {
          value: this.hasInputTarget ? this.inputTarget.value : this.emojiValue,
        },
      },
    });
  }
}
