# Verification consumption rollout

Issue #90 adds `phone_number_verification_requests.consumed_at`. The migration
leaves sessions intact and marks existing verified requests consumed, except
requests created in the last hour with no matching account. It captures one
cutoff for the backfill. Recent registration tokens keep their existing signing
format and remain usable once; older registrations must restart verification.

## Required cutover

The current Fly configuration uses `bluegreen` deployment and runs
`bin/prepare-deployment` (including `db:prepare`) in its release command while
old application processes can still serve traffic. A routine blue-green deploy
alone is insufficient for this migration: old code can verify a request or issue
a session after the backfill without recording consumption.

Before running this migration, stop routing writes to old application processes
and drain in-flight verification and registration requests. Keep these endpoints
unavailable until the migration commits and all serving application processes
run the new code. A short maintenance window covering the whole application is
also sufficient. Resume traffic only after confirming no old process can serve
these writes. Do not roll back to code that issues sessions without recording
consumption; use a forward fix or keep authentication writes unavailable.

The new column is nullable and has no index build. PostgreSQL performs the
column addition and backfill in the migration transaction; the table lock lasts
through the backfill. Allow for that duration when scheduling maintenance. This
implementation does not deploy or change Fly's rollout strategy.

## Compatibility

Recent no-account requests include requests whose former account was deleted. A
retained registration token for such a request can therefore be used once, as
agreed in the issue. All newly issued requests have durable consumption, which
survives sign-out and account deletion. Registration permission obtained by
timely code verification does not expire when the five-minute SMS window ends.
Existing sessions continue to resume and update normally.
