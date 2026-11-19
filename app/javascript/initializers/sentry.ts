import { init } from "@sentry/browser";

import { getMeta } from "#helpers/meta";

init({
  dsn: getMeta("sentry-dsn") ?? undefined,
});
