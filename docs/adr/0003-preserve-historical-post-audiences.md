# 3. Preserve historical post audiences by default

Date: 2026-11-20

## Status

Accepted

## Decision

At the key types cutover, assign existing keys to an `existing friends` type and
share historical posts with that type. Preserve individual exclusions and add
exclusions for current key holders missing the old post-type grant. A new key
can see historical posts when its type is selected on those posts, including
when the owner issues an `existing friends` key. The migration takes effect on
deploy. On the owner's first visit to each affected world after cutover, a
required, one-time walkthrough asks them to keep past audiences or share past
posts with all of that world's current key types while keeping individual
exceptions. Publishing and audience edits in that world wait for the choice.

Pending invitations expire at cutover. Owners can send fresh invitations with a
key type. Already-accepted invitations keep their existing keys.

When reclassifying a friend's key, the owner can retain access to already
published posts via person-specific inclusions. A friend must hold a current key
for individual access to apply. Both inclusions and exclusions survive
revocation so they still apply if the friend rejoins. Account deletion clears
both. Exclusions take precedence over inclusions.

Selecting all starter types during backfill would open old posts to later
holders of any starter key. Selecting `existing friends` preserves the current
audience and lets the owner broaden access by choosing which keys to give out or
which types to add to past posts.
