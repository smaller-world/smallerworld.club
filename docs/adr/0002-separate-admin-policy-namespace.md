# 2. A separate `Admin::` policy namespace

Date: 2026-08-06

## Status

Accepted

## Context

`/reports` is reserved for a reporter-facing view of one's own submitted
reports. Admin moderation therefore lives at `/admin/reports`, and the two
controllers act on the same model class from opposite directions:

- `ReportsController` (future) — "is this report **yours**?"
- `Admin::ReportsController` — "are you an **admin**?"

Action Policy resolves a policy from the _record's_ class, not the controller's
namespace. Both controllers reach for `ReportPolicy` by default, so `index?` and
`show?` would have to answer for two different audiences at once — the classic
`show? = own? || admin?` blur, where it stops being obvious which callers rely
on which half.

`ReportPolicy#manage?` already existed, meaning "you are the reporter", with
zero callers.

## Decision

Admin authorization lives in its own namespace: `Admin::AdminPolicy` as the base
(`index?`, `show?` = `user.admin?`), with `Admin::ReportPolicy` adding
`resolve?`. Admin controllers pass the policy explicitly:

```ruby
authorize!(report, with: Admin::ReportPolicy)
```

Access to the admin area as a whole is additionally gated by
`Admin::AdminController#verify_admin!`, which raises `RecordNotFound` rather
than denying — `/admin/*` is indistinguishable from a mistyped URL, and nothing
in the app links to it.

Admin-ness itself is derived from `credentials.admin_phone_numbers` via
`User#admin?`, so it is a property of a person and cannot be granted in-app.

## Consequences

- Every admin authorization call must pass `with:`. Forgetting it silently
  resolves to the reporter-facing `ReportPolicy` — which is why the
  `verify_admin!` filter exists as a second, independent gate rather than
  relying on policies alone.
- The two policies can evolve without regression risk to each other. The
  reporter-facing `ReportPolicy` was left completely untouched by this work.
- Engines mounted in the admin area can't call `authorize!`, so they inherit
  `Admin::EngineController`, which is gated by the same filter but opts out of
  Action Policy verification. Mission Control is wired to it via
  `config.mission_control.jobs.base_controller_class`. This is what actually
  authenticates `/admin/jobs` — `http_basic_auth_enabled` is `false`, so
  mounting the engine without this would have exposed it publicly.
- Adding a second admin resource means one more policy class, not a branch in an
  existing one.
