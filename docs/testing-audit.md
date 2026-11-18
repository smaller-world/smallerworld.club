# Testing strategy audit

November 18, 2026. The [testing playbook](testing.md) contains the ongoing
workflow. This audit records the evidence and proposed changes for discussion.

## Baseline

| Command                   | Cases | Result                     |               Time inside runner |
| ------------------------- | ----: | -------------------------- | -------------------------------: |
| `mise run test:all -v`    |   102 | 536 assertions, all passed |               12.1 s, 10 workers |
| `mise run test -v`        |    95 | 501 assertions, all passed |  6.8 s, one worker with coverage |
| `mise run test:system -v` |     7 | 35 assertions, all passed  | 14.5 s, one worker with coverage |
| `mise run test:optional`  |    22 | 323 assertions, all passed |                8.9 s, one worker |

The CI suite has 62 request, 32 model, one job, and seven system cases. GitHub
Actions runs both the fast and browser suites on pushes and pull requests. The
22 opt-in cases cover development account switching, the seed baseline, and
checkable components. The browser uses headless Chromium. These are local
measurements of the configured commands.
[CI workflow](../.github/workflows/ci.yml#L165) ·
[Test runner](../test/application_system_test_case.rb#L14) ·
[Tasks](../mise.toml#L87)

The coverage runs used `pg` 1.6.3. After the checkout advanced to a 1.7.0 pin,
the full 102-case suite passed again in 9.7 seconds with the updated gem.

### Coverage experiment

Ruby's built-in Coverage ran from before boot in each suite. I merged hits
across the two single-worker runs. The denominator below includes Ruby files
loaded by either run, with load-time hits included. Ninety of 291 Ruby files
under `app/` were never loaded. This sample excludes optional checks,
JavaScript, and native behavior. The numbers measure execution, including setup,
so use the assertions to decide what a test actually protects.

| Loaded Ruby under            |  Fast lines | Combined lines | Fast branches | Combined branches |
| ---------------------------- | ----------: | -------------: | ------------: | ----------------: |
| `app/` (201 of 291 files)    | 4,348/5,554 |    4,805/5,554 |       410/855 |           491/855 |
| Controllers (34 of 52 files) |     648/952 |        758/952 |        60/149 |            67/149 |
| Models (35 of 42 files)      | 1,039/1,296 |    1,046/1,296 |        51/138 |            55/138 |
| Policies (11 of 14 files)    |      92/112 |         95/112 |          5/12 |              5/12 |
| Jobs (5 of 9 files)          |       28/33 |          28/33 |           0/2 |               0/2 |

Browser runs added 457 line hits and 81 branch hits under `app/`, including the
draft restore endpoint, invitation views, reaction forms, and home. The suite
also exercises the signed-in test backdoor and Rails-side browser plumbing,
which contribute to those totals.

I also ran ten existing reflection and report tests with two temporary,
process-local regressions. Valid time zone inputs were forced to UTC, and report
mail was addressed to a different inbox if delivered. All ten tests still
passed. The reflection fixture only asks for UTC, and the report test asserts
that an email was enqueued without inspecting the delivered message. These
probes used the installed audit-baseline dependencies.

If we want to repeat this, use opt-in SimpleCov line and branch reports that
include unloaded app files. Start before Rails boots, give each suite a distinct
result name, and begin with one Rails worker per report. Collate worker results
if we later want the report from parallel CI. Use uncovered branches to start a
spec discussion and leave percentage gates out of the pilot. Shared execution
can help locate overlapping cases. Assertion review is what determines whether
either test can go.
[SimpleCov documentation](https://github.com/simplecov-ruby/simplecov#configuration-at-a-glance)

## Cases to consolidate

| Candidate                             | What each case buys                                                                                                                                                                                                                                               | Proposed disposition                                                                                                                                                                                                                                                                                                                                                                                               |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Verified code rejection               | Wrong pending code, expired pending code, and valid consumed code isolate three independent rejection rules. Wrong/expired _and_ consumed cases also reject when either rule alone works. Genuine replay protects the complete issuance-to-consumption path.      | Start with the two doubly invalid cases. Keep the single-cause cases and genuine replay. Keep a doubly invalid case if its combination carries a distinct response or regression history. [Verification cases](../test/controllers/phone_number_verification_requests_controller_test.rb#L94)                                                                                                                      |
| Grant visibility                      | Model tests exercise owner, outsider, empty key, and mixed grants. The feed request checks that the route applies the scope and omits actual post content. The empty-key fixture currently checks only an ungranted post, like one half of the mixed case.        | Keep the privacy assertion at the feed. Keep the empty-key case if having a key with zero grants is a supported boundary worth protecting. Document what the model matrix adds. [Model matrix](../test/models/post_test.rb#L47) · [Feed contract](../test/controllers/posts_controller_test.rb#L89)                                                                                                                |
| Registration success                  | The request test repeats verification setup, then checks account creation and a cookie. The browser proves the forms work, and registration retry and race cases already prove account/session creation at HTTP.                                                  | Keep the browser flow. Make the fast success case own a distinct persistence or authentication promise, or fold its one differing assertion about the submitted name into an existing fast case. [Account request](../test/controllers/accounts_controller_test.rb#L7) · [Browser flow](../test/system/users_test.rb#L7) · [Registration retries and races](../test/controllers/registration_security_test.rb#L32) |
| Successful verification               | The request-creation case checks success and a new row, and the account request and browser already need the same endpoint to work. The standalone verification success case additionally checks the existing-user branch, time zone, and session linkage.        | Keep the existing-user case. Give request creation its own contract, such as showing the next step or handling verifier rejection, if it stays separate. [Verification success](../test/controllers/phone_number_verification_requests_controller_test.rb#L64)                                                                                                                                                     |
| Report resolution reversal            | Model and admin request scenarios both go upheld → dismissed. The request case adds the ability to submit a second admin action, but checks the same final resolution and a model predicate. The model name also claims idempotence without repeating a decision. | Give one case ownership of persisted reversal. If both stay, have the request case observe a recipient's actual feed while the model case protects moderation history. Drop the idempotence claim until the spec defines whether a repeat changes moderator or timestamp. [Model reversal](../test/models/report_test.rb#L67) · [Admin reversal](../test/controllers/admin/reports_controller_test.rb#L88)         |
| Literal repeat in optional seed check | The same four Blair recipients are asserted twice in succession.                                                                                                                                                                                                  | Remove the first assertion when editing this suite. Exact topology can still be valuable if developers rely on it as a shared fixture. [Seed checks](../checks/seeds/development_data_test.rb#L49)                                                                                                                                                                                                                 |

Keep cases for distinct contracts that happen to share setup. An owner revoking
a key and a member leaving use the same action with different rights and
destinations. Logout replay and account deletion replay prove different
invalidation events. A stale model instance completing registration and an old
browser cookie being rejected exercise different boundaries. The three messaging
URLs each have an independent platform format. Missing, invalid, and malformed
time zone inputs cover distinct input classes.
[Key actions](../test/controllers/world_keys_controller_test.rb#L14) ·
[Logout](../test/controllers/sessions_controller_test.rb#L20) ·
[Registration model](../test/models/registration_test.rb#L38) ·
[DM URLs](../test/models/user_test.rb#L152) ·
[Time zone inputs](../test/controllers/reflections_controller_test.rb#L19)

## Assertions that could be stronger

| Priority | What can regress while the test stays green                                                                                                                                                                                                                       | Proposed assertion                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| High     | The suppression scope and model predicate can return the correct result while an actual feed still displays a suppressed post. The model cases inspect `Report.not_dismissed`, and the admin cases inspect `post.visible_to?`. The feed uses a separate relation. | At HTTP, observe a distinct post body on both sides of the suppression boundary. Remove the storage assertion on `hidden_from_ids` from the existing recipient-selection case once the two friends' feed outcomes cover the promised behavior. [Report scope checks](../test/models/report_test.rb#L48) · [Admin checks](../test/controllers/admin/reports_controller_test.rb#L58) · [Feed selection](../app/controllers/posts_controller.rb#L18) · [Recipient selection](../test/controllers/posts_controller_test.rb#L106)                                                                                                                                                                                                           |
| High     | A report email can be enqueued for the wrong inbox. The current test checks the number queued.                                                                                                                                                                    | Deliver using the test adapter and check the recipient and a usable link to the report. [Report mail test](../test/models/report_test.rb#L92) · [Mailer](../app/mailers/report_mailer.rb#L8)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| High     | The newest post that the friend cannot see can incorrectly move a world to the top. Every post in the current ordering fixture is granted.                                                                                                                        | Give the older visible world a newer invisible post, then check that the ordering still follows visible posts. Decide whether moderation suppression also counts for this ordering. [Ordering test](../test/models/world_key_test.rb#L56) · [Ordering query](../app/models/world_key.rb#L87)                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| High     | The seven-day reflections view can silently use UTC for every author. The valid case requests UTC at noon, and successful saving and reopening are absent.                                                                                                        | Run the dock example across a local date boundary. Protect a successful save and reopen, with another author's entry for the same date to make the privacy rule observable. [Reflections request cases](../test/controllers/reflections_controller_test.rb#L7) · [Read and write paths](../app/controllers/reflections_controller.rb#L36)                                                                                                                                                                                                                                                                                                                                                                                              |
| Medium   | A pagination regression can load every post on initial render and still reach both assertions, or replace the first page when loading the next one.                                                                                                               | Establish that a known older post is absent at first. After scrolling, assert both the new result and a retained first-page post. Wait for an observable loaded state before checking initial absence. [Scrolling case](../test/system/worlds_test.rb#L49)                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Medium   | A world page can return a blank success, and Apple association JSON can name the wrong app or paths. The world-page fixture post is unused by its assertion.                                                                                                      | Remove the unused setup if the world-page case is a smoke test, or assert the feed entry point. Verify the meaningful Apple association payload fields if the endpoint is a compatibility contract. [World page](../test/controllers/worlds_controller_test.rb#L29) · [Association response](../test/controllers/well_known_controller_test.rb#L7)                                                                                                                                                                                                                                                                                                                                                                                     |
| Medium   | A world name can become globally unique and still pass the current same-owner check. The draft browser case can also fail on harmless changes to a Stimulus fade or restoration marker.                                                                           | Test both owner outcomes if that name rule matters. Synchronize the draft case on saved and restored user-facing state and the submitted post. [World name](../test/models/world_test.rb#L51) · [Draft test](../test/system/worlds_test.rb#L7)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| Medium   | Several checks freeze details that can change safely, including exact verification timestamps or all user attributes, callback registration, and some DOM state markers.                                                                                          | Favor rejection followed by a real protected request, specific side effects that must be absent, and accessibility roles/names. Keep Turbo targets when they are the renderer/client contract. Keep the race barriers for their deterministic interleaving and the rollback fault injection for its partial-write scenario. Review the barriers if the lookup boundary changes. [Verification helper and race](../test/controllers/phone_number_verification_requests_controller_test.rb#L151) · [Registration race](../test/controllers/registration_security_test.rb#L65) · [Rollback](../test/controllers/user_reports_controller_test.rb#L37) · [Optional guard introspection](../checks/development/users_controller_test.rb#L30) |

The optional component checks distinguish initial accessible markup, runtime
ARIA updates, keyboard/pointer behavior, and submitted form data. Those can fail
independently. There is overlap in static disabled and ARIA attributes across
the cases starting at lines 58 and 204. Exact 44 px and 28 px widths are worth
preserving if they are component contracts. Development account switching
likewise earns two environment checks because route absence and controller
defense protect different boundaries. The explicit before-action introspection
adds little alongside the behavioral guard checks.
[Component checks](../checks/ui/checkable_components_test.rb#L58) ·
[Development guards](../checks/development/users_controller_test.rb#L134)

## Coverage gaps by user goal

| Goal                                         | Existing protection                                                                                                                               | Next case worth discussing                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Read only what was shared                    | Model and feed checks for post type and recipient selection.                                                                                      | Define the copied “secret link” contract. The clipboard action copies the post URL, the public action skips authorization, and the view renders the post body. Decide whether a copied link is bearer access and what recipient exclusion or moderation should do to an existing link. Separately protect the authenticated post-card route and a signed-in outsider on the private feed. [Copied link](../app/components/post_card.rb#L209) · [Standalone route](../app/controllers/posts_controller.rb#L84) · [Body](../app/components/post_card.rb#L120) · [Card route](../app/controllers/post_cards_controller.rb#L12) |
| Invite a friend with specific access         | Two browser cases reach the correct signed-out/signed-in landing state. Requests reject invalid links and accept a valid grant by counting a key. | Extend one critical browser journey through accepting a real invite and seeing only the granted post type. Give the fast case responsibility for the invitation-to-key transition or grant boundaries. [Browser cases](../test/system/world_key_grants_test.rb#L12) · [Accept request](../test/controllers/world_key_grants_controller_test.rb#L36) · [Invitation routes](../app/controllers/world_invitations_controller.rb#L8)                                                                                                                                                                                            |
| Change or revoke access                      | Owner/member key removal and account report cleanup, including unrelated key preservation and rollback.                                           | Verify lost access through a subsequent request, including an already-loaded feed/card if instant revocation is a product promise. Protect a non-owner's rejected grant update. [Key requests](../test/controllers/world_keys_controller_test.rb#L14) · [Key updates](../app/controllers/world_keys_controller.rb#L44)                                                                                                                                                                                                                                                                                                      |
| Report unsafe content                        | Account reporting in the browser and over HTTP, model resolution, and admin actions.                                                              | Recipient submits a post report and sees the content disappear. The author can still see it, and dismissal restores it to eligible recipients. Decide how multiple reports interact. The post-report controller was never loaded by this coverage run. [Post reporting](../app/controllers/post_reports_controller.rb#L21) · [Suppression decision](adr/0001-pending-reports-suppress-their-reportable.md)                                                                                                                                                                                                                  |
| Sign in, sign out, and manage an account     | Strong verification, replay, retry, and race coverage. New-user onboarding has a browser check.                                                   | Existing-account sign-in is a candidate browser goal if native handoff or login form behavior warrants it. For the fast suite, examine email confirmation and verifier rejection. Turnstile's always-pass client currently makes real network calls, and the browser injects a test token. [Verification tests](../test/controllers/phone_number_verification_requests_controller_test.rb#L64) · [Browser setup](../test/system/users_test.rb#L11) · [Email confirmation](../app/controllers/account_email_address_confirmations_controller.rb#L21)                                                                         |
| React or reply without granting extra access | Reaction create/delete, one SMS handoff, and a browser reaction update without a page reload.                                                     | Protect a non-recipient's rejected reply or reaction at the request boundary. Verify the generated message only if quoting the post is a promised behavior. A second browser viewer is a separate case only if live updates across viewers are promised. [Reply request](../test/controllers/reply_initiations_controller_test.rb#L15) · [Reaction policy](../app/policies/post_policy.rb#L10) · [Browser reaction](../test/system/reactions_test.rb#L7)                                                                                                                                                                    |
| Save a private reflection                    | Invalid input handling, seven-day dock ordering, and separation of authors on the dock.                                                           | Prioritize the successful write/read and local date rollover cases above. Add a browser flow only if opening and saving via the dock is a critical journey or the browser owns a distinct failure mode. [Reflection cases](../test/controllers/reflections_controller_test.rb#L7)                                                                                                                                                                                                                                                                                                                                           |
| Receive appropriate notifications            | Model cases for device token transfer, rollback, and badge job scheduling. One heartbeat regression guards Sentry/scheduler configuration.        | Before native delivery testing, decide the app-owned contract for granted, muted, quiet, and excluded recipients, then test notification creation with real app records and fake delivery at the provider boundary. Device registration and end-to-end native delivery were outside this measurement. [Device transfer](../test/models/device_test.rb#L37) · [Badge decisions](../test/models/user_test.rb#L117) · [Notification delivery](../app/models/notification.rb#L60) · [Heartbeat](../test/jobs/worker_heartbeat_job_test.rb#L7)                                                                                   |

The handoff resolved two discrepancies. Admin denials now return 403 and render
the Forbidden page across the dashboard, reports, and Mission Control. Home
ordering excludes posts with pending or upheld reports.
[Admin denial test](../test/controllers/admin/dashboard_controller_test.rb#L22)
· [Admin ADR](adr/0002-separate-admin-policy-namespace.md) ·
[Home ordering](../app/models/world_key.rb#L87)

## Handoff task list

- [x] Extend the existing signed-in
      [invite browser test](../test/system/world_key_grants_test.rb#L23). Kai
      approved this case. Given a signed-in friend without a key and a world
      with a post of a type granted by the invite, open the invite and click
      “enter” for that world. Verify the friend reaches the world and can see
      the granted post. This extends the existing browser case through the
      user-visible outcome.
- [x] Make home ordering use the latest post each friend can see. Kai confirmed
      that pending and upheld posts should be excluded. Propose a regression
      case before editing the test. One candidate is a friend with keys to two
      worlds where the older world has the newest post overall, but that post is
      suppressed. The other world should appear first.
- [x] Return 403 and display the Forbidden page to signed-in non-admins on the
      dashboard, reports, and Mission Control. One approved request test covers
      the denial across all three surfaces.

## Suggested order

1. Confirm the test approval rule and the meaning of each privacy boundary.
2. Strengthen one existing privacy test at its public boundary and use it as the
   first worked example in the playbook.
3. Review redundant verification variants, report reversal, and registration
   success assertions. Preserve the critical browser flows.
4. Bring one missing user outcome at a time for approval, starting with invite
   acceptance or post moderation. Use coverage to help find candidate gaps, and
   ask which plausible regression each case would catch.

Test first by choosing a behavior and its interface, seeing the approved case
fail for the right reason, making it pass, and refactoring while green. Approval
happens on the pseudocode. Each red–green cycle still handles one case.
[Kent Beck's Canon TDD](https://newsletter.kentbeck.com/p/canon-tdd)
