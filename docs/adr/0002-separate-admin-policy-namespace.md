# 2. A separate policy for admin access

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

The dashboard, reports, and Mission Control inherit the top-level
`AdminController`. Its `verify_admin!` before-action authorizes
`AdminPolicy#manage?` explicitly. Denied requests from signed-in non-admins
render the Forbidden page with status 403.

Admin-ness itself is derived from `credentials.admin_phone_numbers` via
`User#admin?`, so it is a property of a person and cannot be granted in-app.

## Consequences

- Admin access is decided once per request. The reporter-facing `ReportPolicy`
  continues to check report ownership.
- Mission Control uses `::AdminController` via
  `config.mission_control.jobs.base_controller_class`. The inherited callback
  satisfies Action Policy's authorization verification. The engine uses the
  app's session authentication with HTTP Basic authentication disabled.
