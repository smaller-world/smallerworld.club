# 1. Pending reports suppress their reportable

Date: 2026-08-06

## Status

Accepted

## Context

A `Report` originally carried a single nullable `resolved_at`. Post visibility
keyed off it directly: a post was hidden from its recipients while any report
against it was unresolved.

That gave `resolved_at` two jobs at once. Because resolving was the only way to
restore a post, **resolving always meant dismissing** — there was no way to
record "this report was valid and we acted on it". Upholding a report could only
be expressed by deleting the post, which destroyed the report along with it
(`has_many :reports, dependent: :destroy`) and left no moderation history. It
also had no answer at all for reported Users, where deletion isn't a plausible
outcome.

Adding an explicit `resolution` (`upheld` / `dismissed`) fixes that, but forces
a second question that the old schema never had to answer: **does a report that
nobody has judged yet hide the content?**

The two options are genuinely in tension:

- If only _upheld_ reports suppress, a post stays visible until an admin acts.
  Moderation is triggered by an email to a shared inbox, so that could be hours.
  Genuinely harmful content stays up for the whole window.
- If _pending_ reports suppress, harmful content disappears immediately — but
  any recipient can unilaterally hide any post, with no recourse for the author
  until an admin dismisses it. That is a griefing vector.

## Decision

Pending reports suppress their reportable. Suppression is the complement of
dismissal: content is hidden unless a report against it has been explicitly
dismissed.

Concretely, visibility is expressed as `Report.not_dismissed`, matching both
`NULL` and `upheld` resolutions, rather than as `unresolved` or `upheld`.

This preserves the behaviour that shipped, and the resolution column changes
only what happens _after_ an admin looks: dismissing restores, upholding makes
the suppression permanent without deleting anything.

## Consequences

- The griefing vector is retained and accepted. A recipient can hide a post by
  reporting it, until an admin dismisses. It is bounded by the fact that keys
  are given out deliberately to real friends, and every report is attributable
  to its reporter.
- Moderation latency now has teeth in the other direction: a wrongly reported
  post stays hidden until someone reads the support inbox. Notification is
  therefore fired unconditionally from the model, not from a controller.
- Upholding is non-destructive, so reports remain a durable record of what was
  moderated and by whom. This is what makes the decision hard to reverse: once
  moderation history exists, going back to a delete-based uphold loses it.
- Anything that asks "is this reported?" must use `not_dismissed`, not
  `unresolved`. `unresolved` still exists and still means "no-one has judged
  this yet" — it is the right scope for a work queue and the wrong one for
  visibility.
- The `not_dismissed` scope has to match `NULL` explicitly.
  `where.not(resolution: "dismissed")` compiles to `resolution != 'dismissed'`,
  which is `NULL` — and therefore false — for pending reports, silently
  un-hiding every one of them.
