# Development data

Planning notes for the development dataset. Implementation is pending agreement
on seed isolation and the final scenario matrix.

## Agreed behavior

- `mise setup` supplies five fixed users with predictable names and phone
  numbers.
- Repeating setup fills missing seed data without overwriting local edits. Setup
  with `--reset` rebuilds the dataset.
- Download five deterministic DiceBear Clay images once and commit them so setup
  needs no avatar service. Use Faker for generated post content.
- Use confirmed fictional email addresses ending in `@example.com`.
- Keep every world's automatically created intro post. The sparsest world has
  only its intro, rather than being truly empty.
- Cover no friends, all four other users as friends, one-way and reciprocal
  keys, selective post-type grants, pending invitations, reactions, and
  read/unread activity.
- Include a second world owned by one user, a custom post type, a post hidden
  from an otherwise eligible friend, muted post types, and favorited posts.
  Worlds cannot be favorited.
- Exclude moderation scenarios from this first dataset.
- Development-only account switching supports any local user, including from a
  signed-out entry point. Switching uses POST and creates a normal session. Both
  routing and controller behavior must enforce development-only access.
- Link the users page from the admin dashboard's quick links only in
  development.
- Show scenario labels and a static social graph diagram on the users page. The
  diagram describes the seed baseline and may become stale after local edits.
- Prefer precise additions over changes to normal application behavior.

## Decisions still open

- The final identity/access matrix and post counts (the sparse world keeps its
  intro; the other proposed primary-world totals are 3, 8, 15, and 60).

## Seed isolation strategy

Gate the legacy lookup callback with `unless: -> { User.v1_checks_disabled? }`.
Define `v1_checks_disabled?` as a class method. Disable checks in tests and the
development seed process; preserve existing behavior in ordinary development and
production. New seed users retain the existing `has_v1_account: false` default.
Preserve validation and all other callbacks; do not replace instance methods or
temporarily remove callbacks.

Use `config.x.v1_checks_disabled`, defaulting to false and set to true in tests.
The development seed process will temporarily enable it and restore its previous
value afterwards. All custom application settings live under `config.x`.

Application-level isolation is sufficient. Keep V1 database configuration and
connections unchanged; direct V1 access is not blocked by this flag.

Wrap seed creation and its transaction commit in `Notification.suppress`.
Afterwards, create representative notification records with `delivered_at`
populated so the existing delivery callback skips enqueueing. Use `received_at`
to represent received/unreceived examples independently.

Suppress seed Turbo broadcasts with the existing model APIs. Keep legitimate
local attachment-analysis jobs enabled. Use confirmed example.com addresses, and
do not create devices or phone verification requests during seeding.

Commit a static SVG diagram of the seed graph, including directed keys, pending
invitations, and a legend for edge cases. Label it as the seed baseline; provide
readable scenario descriptions alongside it.

## Implementation verification

Verify repeat setup preserves edits, fresh setup creates the documented graph,
and seeding performs no legacy lookup or outbound delivery. Verify switching
works when signed out and is unavailable outside development.

Verify both the disabled and enabled callback conditions, including development
seeding. Direct V1 access remains available when checks are disabled.
