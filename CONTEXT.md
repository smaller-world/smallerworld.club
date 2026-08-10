# Context

The ubiquitous language of smaller world. This is a glossary, not a spec — it
says what words mean, never how they're implemented.

## Worlds and access

**World** — a person's private space, owned by exactly one **User**. Everything
someone shares lives in one of their worlds.

**Key** — a standing grant of access to a world, held by a **recipient**. Giving
someone a key is how a world owner lets a friend in. A key grants access to
specific **post types**, not to the world wholesale.

**Member** — a user who holds a key to a world. Members are described in UI copy
as _friends_, never as members or users.

**Invitation** — an offer of a key, extended to someone who hasn't accepted yet.
Distinct from a key: an invitation confers no access.

**Post type** — a category of post within a world (e.g. _journal entry_). Keys
are granted per post type, so two members of the same world can see different
posts.

**Recipient** — a user who can see a particular post, by virtue of a key that
grants its post type. Contrast with **author**, who is always the world owner.

## Reports and moderation

**Report** — one user's testimony that a piece of content is harmful. A report
belongs to its **reporter** and points at a **reportable**. It is never edited
by anyone but its author — an admin resolves a report, but does not rewrite it.

**Reportable** — the thing being reported. Today a **Post** or a **User**.

**Pending** — a report nobody has judged yet. A pending report already
suppresses its reportable; the content is hidden while it waits. Pending is the
absence of a resolution, not a resolution of its own.

**Resolution** — an admin's judgement on a report. Exactly two outcomes:

- **Upheld** — the report was right. The reportable stays suppressed
  indefinitely. Nothing is deleted; the report and the content both survive as a
  record of what happened.
- **Dismissed** — the report was not right. The reportable is restored and
  becomes visible to its recipients again.

**Resolved** — a report that has a resolution, whether upheld or dismissed.

**Suppressed** — hidden from recipients but not from its author, and not
deleted. Pending and upheld reports suppress; dismissed reports do not. See
[[resolving-a-report]] for why the pending state suppresses.

**Moderator** — the admin who resolved a report. A resolution can be revisited,
in which case the moderator is whoever most recently judged it.

**Admin** — a user with privileges over the whole application rather than over
their own world. Admin is a property of a person, not a role held within a
world. There is no in-app path to becoming one, and no UI anywhere links to the
admin area — admins learn about reports by email.
