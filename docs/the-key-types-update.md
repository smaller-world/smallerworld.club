# The key types update

**Status** — The `codex/key-types-update` branch has key type storage, core
audience reads, the historical backfill, and legacy grant retirement. Owners can
share a signed key link, change a friend's key type, and select key types in the
post composer. The remaining work and production cutover are tracked below.

Giving a friend a key lets them into a world. The owner chooses which key types
can see each post, so they can welcome someone new and keep a journal entry for
close friends. Post types continue to describe the kind of update being shared.

## Target model

- `WorldKeyType` has `id`, `world_id`, `name`, and `color`. The `color` uses
  Enumerize with `green`, `orange`, `pink`, and `blue`.
- New worlds start with `chosen family` (pink), `new friends` (green), and
  `acquaintances` (blue). The cutover also adds `existing friends` (orange) to
  worlds that already exist.
- `WorldKey` belongs to `:type`, a `WorldKeyType`, and keeps its direct world
  association. Keep the unique index on `(world_id, recipient_id)`. Enforce that
  key and invitation types belong to their world with composite foreign keys.
  Mirror `Post`'s type inclusion validation for a model-level error. Require
  `world_keys.type_id` and `world_invitations.key_type_id` in the database after
  the cutover backfill.
- `PostType#name` replaces `label`. Post types still describe the content and
  appear in filters. The post-type form and controller no longer edit access.
- A post lists the key types that can see it in `visible_to_key_type_ids` and
  individual friends who can see it in `visible_to_user_ids`. The renamed
  `hidden_from_user_ids` column keeps individual exclusions. Among current key
  holders, the audience is the union of friends with a matching key type and
  directly included friends, minus excluded friends. An exclusion takes
  precedence over either inclusion.
- `WorldInvitation` and `WorldKeyGrant` take a single `key_type_id` in place of
  `granted_post_type_ids`. Newly signed key links carry the selected key type.
  Retain the old invitation column as `deprecated_granted_post_type_ids` and add
  it to `WorldInvitation.ignored_columns` when the last caller is gone.
- Put retired models under `Deprecated`, with `deprecated_` as the module's
  table name prefix. Retain old grants as `Deprecated::PostTypeGrant`. Put
  retired components under `Components::Deprecated`. Add retained legacy columns
  to each active model's `ignored_columns` once the last caller is gone.

Before release, update [the glossary](../CONTEXT.md) to reflect the new meanings
of key, key type, post type, and recipient. The feature branch already describes
the new rules in [post access](post-access.md).

## Agreed access rules

- Existing keys move to `existing friends`. Historical posts start with an empty
  `visible_to_key_type_ids` array. Populate `visible_to_user_ids` with the
  world’s current key holders who have the matching legacy post-type grant. Keep
  `hidden_from_user_ids` as saved. This preserves each current holder’s access
  at cutover. A friend who first gets a key after cutover gains historical
  access when the owner adds them individually or selects their key type.
- A key can see past and future posts whose audience includes its key type,
  subject to individual exceptions and moderation. `existing friends` is an
  ordinary key type. Owners can select it when issuing a key or sharing a post.
- The composer starts with no key types selected on a new post. A post can be
  saved with an empty audience, which keeps it out of friends' feeds. The
  automatic welcome post selects the three starter types. Owners can edit both
  kinds of individual exception in an advanced panel. Changing the selected key
  types keeps exceptions for friends with current keys. Review the panel design
  with Kai during implementation.
- The migration applies on deploy. On the owner's first visit to each affected
  world after cutover, show a required, one-time walkthrough. Ask the owner to
  keep past audiences or add every key type the world has when the owner
  confirms to every historical post. Keep individual inclusions and exclusions.
  Future holders of the selected types can see those posts subject to the
  exceptions. Types created later need to be added separately. Gate publishing
  and audience edits on the server until the owner chooses. Owners can edit
  individual posts afterward. See the
  [historical access decision](adr/0003-preserve-historical-post-audiences.md).
- When changing a friend's key type, ask the owner whether the friend should
  keep access to posts shared with their old key type. The option starts
  checked. If checked, add the friend to `visible_to_user_ids` on every post
  already published in that world that selects the old key type, including posts
  also shared with the new type. Skip posts that explicitly exclude the friend
  in `hidden_from_user_ids`. Apply these updates in the same transaction as the
  key change. Calculate eligibility before report suppression and add the friend
  at most once, including on retries. If unchecked, leave the posts' individual
  audiences as saved.
- Revoking a key or leaving a world leaves individual inclusions and exclusions
  on the post. The next saved edit removes exceptions for anyone without a
  current key. If a friend rejoins before that edit, their saved exceptions take
  effect again. Account deletion removes the user's ID from both arrays.
- Owners can create, rename, recolor, and delete key types. In `before_destroy`,
  add a base error if any active key uses the type and a separate base error if
  any pending invitation uses it. Add both errors when both conditions apply,
  then `throw :abort` if either applies. On successful deletion, remove the
  type's ID from post audiences in that world and delete its accepted
  invitations. Deleting an invitation clears the linked key's `invitation_id`
  and leaves the key active. Revoke access by deleting the key itself.
- Old signed key links stop working at cutover. Pending and accepted invitation
  records keep their IDs and receive their world’s `existing friends` type.
  Pending invitations remain redeemable via their invitation page. Accepted
  invitations keep their existing keys. Future invitations specify a key type.
- Anyone with a copied secret post link can still read the unsuppressed post,
  including a signed-out visitor or a friend outside its feed audience. Keep
  author access and the
  [report suppression rule](adr/0001-pending-reports-suppress-their-reportable.md).

## Remaining implementation order

1. Finish individual audience editing and the walkthrough (checkpoints 5 and 6).
   The composer already handles key type selections. Add the pending-world gate,
   then verify publishing and editing through both walkthrough choices.
2. Finish key management and its UI in parallel (checkpoint 4). Signed links and
   phone redemption work. Direct invitation forms, key-type settings, and
   preserving past access when changing a key type still need implementation.
3. Finish the remaining audience read and notification work (checkpoint 2).
   Decide whether explicit post-type subscriptions ship with key types or in a
   follow-up.
4. Rehearse the complete candidate and cut over (checkpoint 7). The local
   database rehearsal in checkpoint 3 establishes the migration order and
   rollback behavior. The release rehearsal also covers the operational pause
   and the finished user flows.

## Checkpoints

These checkpoints are for implementation and review on the feature branch. Key
issuance, publishing, and audience reads activate together. GitHub deploys from
`main` after CI passes, so review and rehearse the rollout before merging a
change that activates the new rules.

Kai owns the remaining UI. The direct invitation form still has a placeholder
for key type selection. Replace it before cutover.

### 1. Agree on storage and the cutover approach

Storage, composite foreign keys, and model-level key and invitation type
validation are in place. `WorldKeyType.default_types` supplies the three new
world defaults. New worlds have no pending review. The backfill in checkpoint 3
marks existing worlds pending, and checkpoint 6 adds the publishing and audience
edit gates. V1 imports were disabled on `main`.

### 2. Implement the audience rule and wire up reads

Review where the shared rule should live before changing callers. Cover
individual inclusions and exclusions, current keys, owner access, copied links,
and moderation. Wire up feed queries, direct post policy checks, reactions and
replies, unread badges, ordering, and notification audiences. Review post-type
navigation and broadcasts against that rule.

Done when the read paths agree on who can see a post and test against the
approved exceptions. Keep the new reads on the feature branch until cutover.

**Implemented read work**

- `Post.with_recipient_keys` matches type and individual selections through the
  world keys association. `Post.visible_to` composes it with `Post.unreported`
  and author access. The feed and post card use that rule. Copied links keep
  their separate access path.
- `Post#recipients` shares the key scope before moderation. `Post#subscribers`
  adds moderation and reads the legacy mute column. Post reporting, reaction
  reads and creation, and reply initiation already check post visibility.
  Replies use the same eligibility rule as reaction creation.
- The old recipient picker and route are gone. The composer submits
  `visible_to_key_type_ids` on create and edit and restores selections from a
  saved draft. Omitting the field on update preserves the selection subject to
  filtering. Clearing the selection removes key type access. An empty audience
  keeps the post in the author's feed.
- Post saves filter and validate all three recipient arrays against the world.
  Changes to either inclusion array trigger post-card replacement broadcasts.
  Favoriting preserves saved recipient exceptions.
- Home computes the latest visible post and unread count per key in one grouped
  query using `Post.with_recipient_keys.unreported`. The last visit limits the
  unread count. Worlds with zero visible posts appear last.
- Owners and friends with a key can use post-type filters. The feed still
  applies the audience rule to the posts returned by a filter.

**Remaining read work**

- Show friends only post types with a visible post. Authors keep all their post
  types. Require post visibility and ownership to delete a reaction.
- Broadcast placeholders already use the authorized card endpoint. Remove the
  placeholder on `403` as well as `401`. Newly eligible friends see the post on
  their next feed load.
- Update the post-type edit links and direct invitation links that still
  reference the retired `redirect-back-to-self` controller so they return to the
  originating page.
- Recheck visibility before rendering or sending a queued post notification. The
  release timing of [post-type subscriptions](#post-type-subscriptions) is open.

Request tests cover publishing to a selected key type, filtering out types from
another world, and preserving or clearing a selection on update. Browser
coverage includes publishing a restored draft to the selected audience. On
November 27, the full local Rails and browser suite passed all 119 tests.

### 3. Build and rehearse the backfill

`20261123000003` creates the missing key types, preserves key and invitation
IDs, and assigns types to keys and to both pending and accepted invitations. It
uses `post_type_grants` to backfill historical audiences before `20261123000004`
renames the table to `deprecated_post_type_grants`. `Deprecated::PostTypeGrant`
retains the historical records. Keys and post types still clean up their grants
on deletion. The post-type form and controller dropped the grant field.

#### Rehearsal and write boundary (2026-11-23)

The migration runs the backfill, rollback snapshots, and both constraints in one
PostgreSQL transaction. A matching starter name keeps its UUID. The migration
records inserted type IDs and prior colors for recolored rows. It also records
each key and invitation assignment, both post inclusion arrays, and the worlds
whose review flag it sets. Keep the five `cutover_*` tables through the rollback
window. Historical exclusions and legacy grant rows remain in place.

For the release, record the old image and migration version, close ingress, stop
every old web and job process (including schedulers), drain in-flight writes,
and keep queued jobs held. Capture a restorable database backup and the old
cohort and audience comparisons at that boundary. Run `bin/prepare-deployment`
with writers stopped. Verify assignments, exclusions, constraints, legacy grant
counts, and both directions of audience comparison before switching releases.
Exercise mutating checks on a copy. Keep writers stopped through the switch.
Identify any queued legacy jobs incompatible with the new release before
reopening web and job writes.

Before reopening writes, roll back using the candidate migration code. Revert
`20261123000004` first to restore `post_type_grants`, then revert
`20261123000003` to restore the pre-backfill data and constraints. To restart
the old image, continue down to the recorded old version, including the column
renames. Compare schema and rows and exercise legacy reads before restarting it.
After new writes, freeze writes and capture the current database before choosing
a forward fix or a reconciled restore. A bare downgrade or restoring the old
backup can lose newly issued keys, redemptions, and audience edits. Some new
audiences cannot be represented by legacy grants.

Two disposable local databases exercised PostgreSQL 17.6. The committed scale
run started with local `main` at `f8a594d4`, schema version `20261122000000`.
Synthetic data covered 20 worlds, 10,000 posts, 500 keys, 620 invitations (500
accepted), 1,340 grants, and 1,000 reports. Across 250,000 in-world post/holder
combinations, all 132,500 pre-moderation pairs and 123,521 moderated pairs
matched after each forward migration. The old release read the same audiences
after full rollback. All columns of the eight seeded tables matched their old
row digests. The restored Rails schema dump matched the old release byte for
byte.

| Local operation                                                     | Elapsed |
| ------------------------------------------------------------------- | ------: |
| Preceding storage migrations                                        | 0.048 s |
| Cutover, including commit                                           | 0.114 s |
| Audience verification                                               | 0.876 s |
| Downtime portion measured (storage + cutover + audience comparison) | 1.038 s |
| Cutover rollback, including commit                                  | 0.155 s |
| Second cutover, including commit                                    | 0.131 s |

The six opt-in checks cover prefilled arrays, mixed review flags, reused types,
association identity, both PostgreSQL constraints, report dismissal, redemption
through the original invitation URL, exact rollback, and replay. Run
`bin/rails test checks/migrations/key_types_cutover_test.rb` with
`RAILS_ENV=test`, `PARALLEL_WORKERS=1`, and `DATABASE_URL` pointing to a
disposable local database named `smallerworld_cutover_rehearsal_*` initialized
from the candidate schema. A separate check signed a link with the old release
and confirmed that the candidate rejected it using the same rehearsal secret.

On November 24, all six opt-in checks passed with the grant rename included in
forward migration, rollback, and replay. The generated schema retained both
composite foreign keys and all three indexes. Account reporting and post-type
deletion both cleaned up historical grants on disposable data. The scale timings
above predate the rename.

The six checks also passed on November 27 against a fresh disposable local
database. That day's manual check opened an old-format signed link in Chrome and
received the invalid-link page with HTTP `400`. The automated link tests cover
malformed links. The migrated invitation test exercises the original invitation
URL.

Checkpoint 7 still needs to measure the full operational pause, including the
backup, process stop/start, release command, queued jobs, and traffic switch
with the complete release candidate.

### 4. Implement key issuance and management

The share screen lets an owner select a key type and shows a QR code and a
copyable link. A signed-in friend can redeem the link immediately. A signed-out
friend can save it with their phone number, then redeem it from Home after
signing in. Browser tests cover both paths using the test sign-in helper. Direct
invitation create and update accept `key_type_id`, and the forms still need the
picker and submit control.

The friends list shows each friend's type, and owners can change it in the key
editor. Changing the type currently applies the new type's audience immediately
and keeps any existing individual exceptions. Request tests cover that feed
change, denial of a friend's attempt to change their own key, and revocation.

Key-type settings have route and dialog scaffolding and still need a controller.
The model blocks deletion for active keys and pending invitations. If a key has
changed type, removing the old type deletes the accepted invitation and leaves
the key in place. Tests also cover removal of the old type from post audiences.
The checked-by-default option to keep past access and its transactional audience
updates are both pending. Verify both choices, revocation and rejoining, and the
settings flows on the candidate.

### 5. Implement publishing and audience editing

The composer lets owners publish and edit a post with zero or more key types.
New drafts start with no selected types and resume with the saved selection.
Development seeds use the current audience fields, including a post-cutover
example in Blair's world.

Build the advanced panel and wire create and update to accept individual
inclusions and exclusions. Give the welcome post the three starter types and
remove user IDs from saved exceptions on account deletion. Verify that audience
edits refresh post items safely. Exercise publishing and audience edits with the
walkthrough gate in place.

### 6. Add the required walkthrough

The backfill sets `key_types_review_pending` for existing worlds. The
walkthrough and server gate are pending.

Agree with Kai on what the walkthrough needs to explain about who would gain
access. Kai will build the walkthrough UI. Show it when the owner enters a
pending world and keep showing it on subsequent visits until the owner chooses.
For the broaden-audience choice, select the world’s key types at the time of
confirmation. Apply the choice and clear the world’s pending state in one
transaction. Verify that direct requests cannot publish or change audiences
before the choice and that friends can still read according to their keys. Ship
the walkthrough with the update.

### 7. Rehearse and cut over

Rehearse with the full release candidate and production-like data. Verify how to
stop the old web and job processes, handle queued work, and keep legacy writers
stopped through the switch. Verify the final backfill before activating the new
read and write paths together. Check signed-in and phone-based key acceptance,
old links, publishing, audience edits, and revocation on the candidate release.

Plan rollback separately before and after owners can write using the new model.
Before that point, rehearse restoring the pre-cutover state and verify the old
release can use it. After that point, an old image cannot interpret newly issued
keys and new audience edits. Agree on a recovery procedure that preserves those
writes. Run the legacy renames with old processes stopped. Recheck retained
grant counts, key revocation, and post-type deletion on the full candidate. Done
when the rollout and recovery procedures are verified and the new access model
is live.

## Deprecations already on main

- V1 post imports were disabled in `f193d832`. The import route and world page
  entry point were removed, and the job and component moved under `Deprecated`.
  An After Party task discards unfinished imports under both job names and
  aborts if any are still claimed. See the
  [import retirement runbook](v1-migration.md#retiring-post-imports). Keep
  existing imported posts and their V1 metadata. Any future importer needs its
  own audience selection.
- World Cards were retired in `aaa041d1`. The model is `Deprecated::WorldCard`
  and the table is `deprecated_world_cards`.

## Post-type subscriptions

The current schema stores `muted_post_type_ids`. Subscriber selection uses the
post's audience and excludes keys that mute its post type. The subscription
accessors on `WorldKey` still use the mute array. The conversion below remains
planned work.

Add `subscribed_post_type_ids`, backfill it in SQL with each key's current world
post types minus its muted types, and drop `muted_post_type_ids` in the same
transaction. Switch subscriber selection to explicit membership and remove the
old model accessors and associations. Update development seeds and checks. New
post types require opt-in for existing keys. Choose the initial subscriptions
for newly issued keys before adding subscription defaults to the existing key
issuance path.

## How to hand off a checkpoint

Kai starts each checkpoint with a separate agent. The agent should read this
plan, `AGENTS.md`, and the docs named there, then return with the exact behavior
and files it proposes to change. Pause for Kai’s feedback before the first edit
and again before expanding the agreed scope or making a new schema, access, or
UI choice. Keep the diff focused on the agreed checkpoint. Follow the repo's
approval process for each proposed test and regenerate affected Sorbet RBIs.
Close the checkpoint with the diff, verification results, and the decisions the
next agent needs.
