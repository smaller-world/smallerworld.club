// import { isDevelopment } from "#helpers/env_helpers";

import "@hotwired/turbo";

// if (isDevelopment()) {
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
// }
