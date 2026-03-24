/* eslint-disable @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */

// @ts-expect-error No declaration file found
import LocalTime from "local-time";

LocalTime.start();
document.addEventListener("turbo:morph", () => {
  LocalTime.run();
});
