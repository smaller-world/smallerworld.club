# 3. Preserve historical post audiences by default

Date: 2026-11-20

## Status

Accepted

## Decision

At cutover, assign existing keys to their world’s `existing friends` type. For
each historical post, add current key holders with the matching legacy post-type
grant to the individual inclusion list. Leave its key type selection empty and
preserve its individual exclusions. This preserves access for current friends.
People who first receive a key after cutover gain historical access when the
owner adds them individually or selects their key type.

Pending and accepted invitations carry over with their world’s
`existing friends` type. Pending invitations remain redeemable through their
invitation page. Accepted invitations keep their existing keys. Old signed key
links expire independently.

On the owner’s first visit to each affected world after cutover, a required,
one-time walkthrough asks them to keep past audiences or share historical posts
with every key type in that world at the time they confirm. Preserve individual
inclusions and exclusions. Future holders of those selected types get access
subject to the exceptions. Key types created later need to be added separately.
Publishing and audience edits in that world wait for the choice.

When reclassifying a friend's key, the owner can retain access to already
published posts via person-specific inclusions. A friend must hold a current key
for individual access to apply. Revoking a key leaves both lists intact. A later
edit that saves the post removes individual exceptions for anyone without a
current key, even if the edit only changes the post body. If a friend rejoins
before the edit, their saved exceptions apply again. Account deletion clears
both lists. Exclusions take precedence over inclusions.
