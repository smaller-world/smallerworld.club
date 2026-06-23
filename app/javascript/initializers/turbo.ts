// import { isDevelopment } from "#helpers/env_helpers";

import { FrameElement, StreamActions } from "@hotwired/turbo";

import { isDevelopment } from "#helpers/env_helpers";

import "@hotwired/turbo-rails";

StreamActions.reload = function () {
  const frame = document.getElementById(this.target);
  if (frame instanceof FrameElement) {
    void frame.reload();
  } else {
    throw new Error(
      `Expected target to be FrameElement, instead got: ${this.target}`,
    );
  }
};

if (isDevelopment()) {
  [
    "turbo:before-cache",
    "turbo:before-render",
    "turbo:before-visit",
    "turbo:click",
    "turbo:load",
    "turbo:render",
    "turbo:submit-end",
    "turbo:submit-start",
  ].forEach((turboEvent) => {
    document.addEventListener(turboEvent, () => {
      console.debug("⚡️ " + turboEvent);
    });
  });
}
