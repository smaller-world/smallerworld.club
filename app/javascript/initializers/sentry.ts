import { init } from "@sentry/browser";

import { getMeta } from "#helpers/meta";

init({
  dsn: getMeta("sentry-dsn") ?? undefined,

  // Adds request headers and IP for users, for more info visit:
  // https://docs.sentry.io/platforms/javascript/configuration/options/#sendDefaultPii
  sendDefaultPii: true,
});
