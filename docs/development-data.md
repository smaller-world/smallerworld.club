# Development data

The development baseline is implemented in `db/seeds/development.rb`. The
account-switching page and static graph are the next milestone.

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

## Seed baseline

Run `mise setup` to prepare the database and fill missing baseline records.
`mise setup --reset` rebuilds the development database, deleting local data.
`bin/rails db:seed` fills the baseline without running the other setup steps.
The normal seeds entry point does nothing outside development.

| Account | Phone        | World                | Posts including intro | Key recipients           |
| ------- | ------------ | -------------------- | --------------------: | ------------------------ |
| Alex    | +14165550101 | alex's world         |                     1 | nobody                   |
| Blair   | +14165550102 | blair's world        |                    60 | Alex, Casey, Drew, Ellis |
| Casey   | +14165550103 | casey's world        |                     8 | Alex, Blair              |
| Casey   | same account | casey's quiet corner |                     1 | nobody                   |
| Drew    | +14165550104 | drew's world         |                     3 | Casey                    |
| Ellis   | +14165550105 | ellis's world        |                    15 | Blair, Drew              |

Emails are the lowercase first name at `example.com`, already confirmed. The
phone numbers use the fictional North American 555-0100–0199 range. Alex has
nobody in their own world, but can enter Blair's and Casey's worlds. Blair/Casey
and Blair/Ellis share reciprocally; the other keys are directed.

- Alex's key to Blair's world grants journal entries only. Other baseline keys
  grant all four default post types.
- Casey's custom `field note` type is granted only to Blair.
- Blair's first generated journal entry excludes Drew. Ellis mutes Blair's
  poems.
- Blair and Ellis each have a favorited post, with a reaction from Casey and
  Drew respectively.
- Casey invites Ellis; Drew invites Blair. These remain pending at baseline.
- Keys held by Blair have a current visit timestamp; other keys were visited a
  week ago. Posts span recent days to provide read and unread activity.
- Four notification examples cover a post, reaction, accepted key, and pending
  invitation. All are marked delivered; only the reaction is marked received.

The images in `db/seeds/images` are bundled DiceBear Clay PNGs. Casey's two
worlds share one image. Setup never downloads images.

## Preserving local edits

Seed users, worlds, custom/default post types, generated posts, invitations, and
notification examples use deterministic UUIDs. Existing records are left alone;
missing records are created. Keys, grants, and reactions use their natural
association keys. Setup does not reset content, names, read state, or favorites.
Accepting a pending invitation locally does not make setup offer it again. World
creation uses the normal callback to create its intro post.

Faker uses a fixed random source per generated post, restoring the previous
source afterwards. Existing content is never regenerated on repeat setup.

Account deletion nullifies invitations' `recipient_id`, preserving their phone
number and granted types. A later account with that phone number can discover
them through `User#world_invitations`.

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

`bin/rails test test/seeds/development_data_test.rb` exercises real commits and
checks the graph, post counts, visibility, repeat seeding, preserved local
edits, missing-post restoration, notification examples, no delivery/broadcast
jobs, allowed attachment analysis, and restoration after failures. The account
page and its environment checks remain pending.

Verify repeat setup preserves edits, fresh setup creates the documented graph,
and seeding performs no legacy lookup or outbound delivery. Verify switching
works when signed out and is unavailable outside development.

Verify both the disabled and enabled callback conditions, including development
seeding. Direct V1 access remains available when checks are disabled.
