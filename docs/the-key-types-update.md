# The key types update

**Status** — Implementation plan on `codex/key-types-update`.

Giving a friend a key lets them into a world. The owner chooses which key types
can see each post, so they can welcome someone new and keep a journal entry for
close friends. Post types continue to describe the kind of update being shared.

## Target model

- `WorldKeyType` has `id`, `world_id`, `name`, and `color`. The `color` uses
  Enumerize with `green`, `orange`, `pink`, `blue`, and `red`.
- A world starts with `chosen family` (pink), `new friends` (green),
  `acquaintances` (blue), and `existing friends` (orange).
- `WorldKey` belongs to `:type`, a `WorldKeyType`, and keeps its direct world
  association. Keep the unique index on `(world_id, recipient_id)`. Enforce that
  key and invitation types belong to their world with composite foreign keys.
  Mirror `Post`'s type inclusion validation for a model-level error and allow
  legacy keys to have no type until cutover.
- A post lists the key types that can see it in `visible_to_key_type_ids` and
  individual friends who can see it in `visible_to_user_ids`. Rename
  `hidden_from_ids` to `hidden_from_user_ids` to keep person-specific
  exclusions. Among current key holders, the audience is the union of friends
  with a matching key type and directly included friends, minus excluded
  friends. An exclusion takes precedence over either inclusion.
- `WorldInvitation` and `WorldKeyGrant` take a single `key_type_id` in place of
  `granted_post_type_ids`. Newly signed key links carry the selected key type.
  Retain the old invitation column as `deprecated_granted_post_type_ids` and add
  it to `WorldInvitation.ignored_columns` when the last caller is gone.
- Put retired models under `Deprecated`, with `deprecated_` as the module's
  table name prefix. Retain old grants as `Deprecated::PostTypeGrant`. Put
  retired components under `Components::Deprecated`. Add retained legacy columns
  to each active model's `ignored_columns` once the last caller is gone.

At cutover, update [the glossary](../CONTEXT.md) to reflect the new meanings of
key, key type, post type, and recipient. Make the feature-branch rules in
[post access](post-access.md) the live rules.

## Agreed access rules

- Existing keys move to `existing friends`. Posts present at cutover initially
  select that type. The backfill keeps existing individual exclusions and adds
  current key holders who lack the corresponding old post-type grant. This
  preserves each current holder's access at cutover.
- A key can see past and future posts whose audience includes its key type,
  subject to individual exceptions and moderation. `existing friends` is an
  ordinary key type. Owners can select it when issuing a key or sharing a post.
- The composer starts with no key types selected on a new post. A post can be
  saved with an empty audience, which keeps it out of friends' feeds. The
  automatic welcome post selects all four starter types. Owners can edit both
  kinds of individual exception in an advanced panel. Changing the selected key
  types keeps exceptions for friends with current keys. Review the panel design
  with Kai during implementation.
- The migration applies on deploy. On the owner's first visit to each affected
  world after cutover, show a required, one-time walkthrough. Ask the owner to
  keep past audiences or share past posts with all of that world's key types
  while keeping individual exceptions. Gate publishing and audience edits on the
  server until the owner chooses. Owners can edit individual posts afterward.
  See the
  [historical access decision](adr/0003-preserve-historical-post-audiences.md).
- Every key type change offers a checked-by-default option to preserve the
  friend's access to posts already published when the type changes, including
  posts published after cutover. Add the friend to `visible_to_user_ids` on
  eligible posts the old type covered and the new type would omit. Keep
  exclusions in force, calculate access before report suppression, and add a
  user ID at most once even if the operation is retried.
- Revoking a key or leaving a world leaves individual inclusions and exclusions
  on the post. The next saved edit removes exceptions for anyone without a
  current key. If a friend rejoins before that edit, their saved exceptions take
  effect again. Account deletion removes the user's ID from both arrays.
- Owners can create, rename, recolor, and delete key types. Block deletion while
  any key or pending invitation uses the type. Enforce the restriction in the
  model, for example with an error and `throw :abort` in `before_destroy`. On
  successful deletion, remove the type's ID from post audiences in that world.
- Old signed key links stop working and pending invitations expire at cutover.
  Owners can issue fresh invitations with a key type. Accepted invitations keep
  their existing keys, which move to `existing friends` with the other keys.
- Anyone with a copied secret post link can still read the unsuppressed post,
  including a signed-out visitor or a friend outside its feed audience. Keep
  author access and the
  [report suppression rule](adr/0001-pending-reports-suppress-their-reportable.md).

## Checkpoints

These checkpoints are for implementation and review on the feature branch. Key
issuance, publishing, and audience reads activate together. GitHub deploys from
`main` after CI passes, so review and rehearse the rollout before merging a
change that activates the new rules.

### 1. Agree on storage and the cutover approach

Review the key type table, key and invitation references, and post audience
fields in small migration diffs. The storage migration marks existing worlds as
pending a walkthrough choice. New worlds default to no pending review. Gate post
creation and audience edits until the choice. V1 imports were disabled on
`main`.

Kai accepts brief downtime and request errors during deploy. Fly runs migrations
and After Party tasks before switching traffic, while the previous release can
still be running. Rehearse which legacy writes can overlap the backfill and how
the database work prevents those writes from being missed. Measure the downtime
in rehearsal.

After Kai approves the proposal, add the key type model, four defaults, and
compatible storage. Done when the agreed rollout can use the new schema and the
current release still serves the same post audiences.

Storage, composite foreign keys, and the world-to-key-types association exist.
The named `WorldKeyType` builders, `default_types`, automatic defaults on world
creation, color enumeration, and model-level key and invitation type validation
are pending. Review and test new-world defaults before adding the After Party
backfill for existing worlds.

### 2. Implement the audience rule and wire up reads

Review where the shared rule should live before changing callers. Cover
individual inclusions and exclusions, current keys, owner access, copied links,
and moderation. Wire up feed queries, direct post policy checks, reactions and
replies, unread badges, ordering, and notification audiences. Review post-type
navigation and broadcasts against that rule. The current grouped badge count
omits report suppression, so confirm its intended behavior here.

Done when the read paths agree on who can see a post and test against the
approved exceptions. Keep the new reads on the feature branch until cutover.

**Implemented in the first read slice**

- `Post.with_recipient_keys` matches type and individual selections through the
  world keys association. `Post.visible_to` composes it with `Post.unreported`
  and author access. The feed and post card use that rule. Copied links keep
  their separate access path.
- `Post#recipients` shares the key scope before moderation. `Post#subscribers`
  adds moderation and reads the legacy mute column. Post reporting, reaction
  reads and creation, and reply initiation already check post visibility.
- The exclusion column is now `hidden_from_user_ids`. The old recipient picker
  and route are gone. Create and update accept `visible_to_key_type_ids`.
  Omitting it on edit preserves the selection subject to filtering. An empty
  array clears it. The composer can save an author-only post while the
  replacement picker is pending.
- Post saves filter and validate all three recipient arrays against the world.
  Changes to either inclusion array trigger post-card replacement broadcasts.
  Favoriting preserves saved recipient exceptions.

**Remaining read work**

- Compute latest visible post and unread count in one grouped home query based
  on `Post.visible_to(current_user)`. Exclude suppressed posts from both. Apply
  each key's last-visit cutoff only to unread. Keep worlds with zero visible
  posts and sort them last.
- Show friends only post types with a visible post. Authors keep all their post
  types. Require post visibility and ownership to delete a reaction. Keep
  replies on the same eligibility rule as reaction creation.
- Keep placeholders behind the authorized card endpoint and remove them on a
  denied card fetch (`403`). Newly eligible friends see the post on their next
  feed load.
- Add [post-type subscriptions](#post-type-subscriptions) and recheck visibility
  before rendering or sending a queued post notification.

The focused recipient, composer, world, and ordering tests passed after the
filters changed. The last full unit and integration run had seven failures and
one error in legacy-grant fixtures and write paths. Update card, reaction,
reply, and report setup to use typed keys and post recipient selections. Update
key issuance and key edit flow tests alongside those write paths. The reply
denial exposed a response-format error. Get approval before changing what a test
verifies.

### 3. Build and rehearse the backfill

Preserve key IDs and capture the original exclusion arrays for recovery. Derive
the new exclusions from historical grants and assign existing keys to
`existing friends`. Expire pending invitations. Compare the old and new
audiences for current key holders against the rule from checkpoint 2. Compare
the underlying audience with moderation accounted for separately, so a currently
suppressed post can reappear for the right people when a report is dismissed.

Add the four starter types to existing worlds in the After Party backfill. Use
`hidden_from_user_ids` for the original and derived exclusions. Keep the legacy
grants available for the audience comparison and rollback.

Review the backfill and its write boundary before implementation. Done when it
can be repeated without publishing side effects, the comparison accounts for
every audience difference, and the rehearsal measures the time needed for the
final cutover. Repeat the rehearsal with the full release candidate at
checkpoint 7.

### 4. Implement key issuance and management

Prepare changes to signed key links, pending invitations, the owner’s list of
keys, key edits, and key-type settings. Review those flows with Kai before
wiring up the forms. The grant form shows the key type being shared. Explain
access to past and future posts in the update walkthrough. Review how accepted
invitation records are retained. Cover signed-in acceptance and phone-based
onboarding, an existing friend's key change with or without preserving past
access, revocation and rejoining, and key-type deletion. Save access-preserving
audience adjustments together with the key change. Validate that a selected type
belongs to the relevant world. Done when old signed links and expired
invitations are rejected, fresh invitations can be accepted, and owners can
assign and change key types.

### 5. Implement publishing and audience editing

Review the composer and its advanced panel before editing the view. Wire up post
creation and editing, welcome posts, and seed data. Check that audience edits
refresh post items safely and that account deletion clears user IDs from the
exception arrays. Done when owners can share or edit a post with the intended
audience, including saving it with nobody selected. Checkpoints 4 and 5 can be
reviewed independently once the audience contract is in place.

### 6. Add the required walkthrough

Review the walkthrough with Kai before building it, including how it explains
who would gain access. Show it when the owner enters a pending world and keep
showing it on subsequent visits until the owner chooses. Apply the choice and
clear that world's pending state in one transaction. Verify that direct requests
cannot publish or change audiences before the choice and that friends can still
read according to their keys. Ship the walkthrough with the update.

### 7. Rehearse and cut over

Rehearse with the full release candidate and production-like data. Check how the
automatic deploy handles brief downtime, overlapping legacy writes, and queued
work. The exclusion rename and mute-column removal can cause errors in an old
process while the deploy is in progress. Verify the final backfill before
activating the new read and write paths together. Check signed-in and
phone-based key acceptance, old links, publishing, audience edits, and
revocation on the candidate release.

Plan rollback separately before and after owners can write using the new model.
Before that point, the old grant data and captured exclusions can support a
reversal. After that point, an old image cannot interpret newly issued keys and
new audience edits. Agree on a recovery procedure that preserves those writes.
Rename the legacy columns and grants table when every running process can
tolerate it. Retained grant rows still have foreign keys, so verify ordinary key
revocation and post-type deletion after the rename. Done when the rollout and
recovery procedures are verified and the new access model is live.

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

Add `subscribed_post_type_ids`, backfill it in SQL with each key's current world
post types minus its muted types, and drop `muted_post_type_ids` in the same
transaction. Switch subscriber selection to explicit membership and remove the
old model accessors and associations. Update development seeds and checks. New
post types require opt-in for existing keys. Settle the initial subscriptions
for newly issued keys before wiring key creation.

## How to hand off a checkpoint

Kai starts each checkpoint with a separate agent. The agent should read this
plan, `AGENTS.md`, and the docs named there, then return with the exact behavior
and files it proposes to change. Pause for Kai’s feedback before the first edit
and again before expanding the agreed scope or making a new schema, access, or
UI choice. Keep the diff focused on the agreed checkpoint. Follow the repo's
approval process for each proposed test and regenerate affected Sorbet RBIs.
Close the checkpoint with the diff, verification results, and the decisions the
next agent needs.
