# Stytch SMS OTP migration assessment

Assessed November 6, 2026. Repository inspection and official documentation; no production calls or implementation changes.

## Recommendation and effort

**Moderate, contained change: replace the OTP backend and keep Rails accounts, registrations, and sessions.** Budget roughly **2–4 engineering days** for implementation, security regression tests, and deployment preparation, plus provider onboarding time. This is a judgment from the code, not a measured implementation estimate. A happy-path spike could take half a day, but would not settle failure recovery or rollout safety.

Moving sessions and account ownership into Stytch would be a larger project (roughly 1–2 weeks as an initial planning allowance) with little benefit for the immediate SMS delivery problem. It would reach authentication on every request, cookies, logout, account deletion, and the native app. It is unnecessary for this integration.

The commercial/onboarding question is a separate gate from engineering. Confirm live SMS eligibility and actual delivery before committing to the migration; see the provider findings below.

## Current flow and the natural boundary

1. `PhoneNumberVerificationRequestsController#create` checks Turnstile, builds a local verification request, and saves it. Production limits this endpoint to three requests in three minutes.
2. `PhoneNumberVerificationRequest` creates a six-digit code, stores it in plaintext, and sends it through Telnyx in `after_create_commit`. Codes expire after five minutes. Credentials can override codes for particular phone numbers.
3. `#verify` compares the code under a row lock and marks the record verified. The controller wraps verification and subsequent account/session work in a database transaction.
4. An existing local phone-number owner receives a Rails `Session` and signed cookie. A new phone number gets a signed registration token; completing profile details creates the local user and session.
5. Sessions and registrations require a verified request. Sentry also obtains the login IP from that record.

Sources: [`PhoneNumberVerificationRequest`](../app/models/phone_number_verification_request.rb), [`verification controller`](../app/controllers/phone_number_verification_requests_controller.rb), [`Authentication`](../app/controllers/concerns/authentication.rb), [`Registration`](../app/models/registration.rb), [`Session`](../app/models/session.rb), [`SentryIdentification`](../app/controllers/concerns/sentry_identification.rb).

This makes the local verification request worth retaining: it is the proof/audit boundary, not merely a container for an SMS code.

## Proposed integration

- Send through Ruby `stytch_client.otps.sms.login_or_create`, using the normalized phone number, explicit five-minute expiration, and `create_user_as_pending: true`.
- Store returned Stytch `phone_id` and `user_id` on the local verification request. These are server-owned values, never trusted form inputs. `phone_id` identifies the phone method, not a unique send attempt.
- Submit the entered code to `stytch_client.otps.authenticate`, using the stored phone ID as `method_id`. Omit session parameters: Stytch supports authentication without creating a Stytch session.
- Validate the successful response against the expected provider identity and verified phone method/number before setting local `verified_at`. Preserve local expiration and single-use checks.
- Continue the existing local phone-number lookup and registration/session flow. Stytch's `user_created` describes its own directory, so it must never decide whether a smaller world account exists.

API sources: [SMS login or create](https://stytch.com/docs/api-reference/consumer/api/otp/via-sms/login-or-create-user), [OTP authenticate](https://stytch.com/docs/api-reference/consumer/api/otp/authenticate). These APIs and keyword arguments also exist in the working tree's generated `stytch@11.1.1` RBI.

Existing users can acquire Stytch records on their next login; no bulk import or local user-ID rewrite is necessary for this approach. Existing Rails sessions remain valid. A Stytch record may exist even if someone never completes our registration; verification is not the same as completing a smaller world account.

## Change surface

| Area | Necessary work | Size |
| --- | --- | --- |
| Verification model | Replace local generation/comparison and Telnyx sending; persist provider IDs; retain proof metadata and locking | Medium |
| Database | Add provider identifiers; make stored code nullable, ultimately remove it after compatibility window | Small |
| Verification controller | Replace Telnyx rescue; handle send/verify failures, rate limits, timeouts; remove code logging | Medium |
| Form | Keep six-digit form/Turbo flow; replace development autofill; review consent, STOP/START/HELP copy against actual sender behavior | Small |
| Configuration | Review existing Stytch initializer, environment selection, credentials, timeouts, delivery switch; retire unused Telnyx dependency/config | Small |
| Tests/helpers | Stop reading generated real codes from records; stub provider calls; preserve flow/security assertions | Medium |
| Sorbet/docs | Regenerate schema DSL RBIs, check SDK types, update testing instructions | Small |
| Account lifecycle | Define deletion of Stytch identities and cleanup of abandoned registrations | Small–medium |

Existing preparatory changes are present: Stytch gem/lockfile, initializer, generated gem RBIs, and encrypted credential edits. They were left untouched. Credentials were not decrypted or verified; an initializer is not evidence that live messaging is enabled.

Callers inspected include `SessionsController`, `AccountsController`, `Authentication`, `Registration`, `Session`, Sentry identification, the verification form and Stimulus controller, test sign-in backdoors, and integration/system helpers. The Stimulus controller only enables submission after Turnstile and likely needs no change. No new browser SDK, frontend framework, routes, or iOS authentication SDK is required by the proposed server-side flow; native cookie/autofill behavior still needs a smoke check.

## Complexity that the two API calls hide

**Remote success cannot roll back with PostgreSQL.** Today an account/session failure rolls back local verification. With Stytch, successful authentication can consume the OTP before the local transaction fails. A retry may then fail remotely. Explicitly design this behavior: either keep a durable, narrowly scoped local verified proof for retrying local completion, or fail safely and ask for a fresh code. The latter is smaller but less forgiving. A process crash between remote success and persistence has the same problem. Do not silently create a reusable login bypass to solve it.

**Preserve concurrency and replay protection.** Existing tests prove that simultaneous verification creates one session and a consumed request cannot authenticate again. Keep these properties. A bounded provider call under the current row lock is a simple starting point, but holds a database connection/lock during network work. Do not retry a consumed authentication automatically without understanding the result.

**Failed sends already occur after commit.** The current callback persists a request before Telnyx responds. With Stytch, a request must not be presented as ready for verification unless provider identifiers were successfully saved. Timeouts can leave an SMS delivered but the local outcome unknown; provide a clean restart rather than pretending the send failed definitively.

**Testing changes are broader than production routing.** Existing helpers and onboarding tests read `request.verification_code`, while development auto-fills it. Stytch will own real codes. Use deterministic stubbed send/authenticate responses in automated tests; use Stytch test facilities for manual integration checks. Keep unrelated tests using `create_test_mock_for!` local and network-free.

**Overrides are a policy choice.** Inventory credentials-based special logins before replacing them. Move review/demo access to provider-supported test facilities if suitable, or deliberately retain a tightly scoped override path. Removing them blindly can break app review; retaining them means OTP authentication is not entirely delegated.

**Keep abuse controls.** Preserve Turnstile and send throttling. The daily model-level IP validation is commented out; a verify-rate-limit handler exists without an attached verify limit. Do not assume those currently protect the flow. Map provider lockout/rate-limit errors safely, and bound verification attempts. Remove explicit plaintext code logging and audit request parameter filtering as part of replacing the code lifecycle.

**Account deletion now spans two systems.** Local deletion currently destroys local sessions. A Stytch identity will otherwise remain. Decide and document deletion/retention, with retryable cleanup if remote deletion fails. A leftover Stytch identity must never recreate or authenticate a deleted local account without the normal new registration flow. Stytch dashboard revocation will not automatically terminate Rails sessions in this architecture.

## Rollout and validation

1. Prove live delivery to representative US/Canadian destinations and confirm branding, approval requirements, limits, and costs.
2. Implement the provider call boundary and schema additions. Retain historical verified request rows because sessions/registrations reference them.
3. Update integration coverage for existing-user login, new registration, invalid/expired/used codes, provider failures, identity mismatch, simultaneous verification, and remote-success/local-failure behavior. Preserve registration replay, deletion, and concurrent-completion regressions.
4. Run relevant integration tests, onboarding system test, `bin/tapioca dsl`, `bundle exec srb tc`, and relevant lint checks. Manually smoke-test SMS autofill and Hotwire Native login/logout.
5. Deploy without invalidating existing sessions. For a simple single cutover, require pending old OTP requests to restart; there is no need for permanent provider routing. Retain schema compatibility long enough to permit rollback, but do not accept Stytch codes using the old local comparison path.
6. Monitor send/authenticate errors and successful local login completion separately, using provider request IDs without codes or secrets. Remove obsolete code storage and Telnyx configuration after the rollback window.

No full test run was performed for this report: no application behavior changed. The estimates exclude production approval lead time, account-specific support negotiation, and device testing.

## Provider findings: does this solve the Telnyx blocker?

**Likely yes for the dependency on that particular Telnyx number, but not yet proven for this project.** Stytch documents built-in delivery through its own providers, with US and Canada enabled by default and the Live Project name included in messages. Its documented setup does not ask you to bring an approved Telnyx toll-free number. The inference is that Stytch-managed delivery removes that number from the critical path. This is not evidence of a carrier-registration exemption or guaranteed Live activation. [Stytch messaging policy](https://stytch.com/docs/resources/policies/messaging/overview)

Before investing in the migration, confirm with Stytch that this Consumer project can send Live US/Canadian login OTPs using managed senders, what activation/brand/use-case review is required, and whether any approval lead time applies. Then verify receipt on actual destination networks. No account dashboard or live delivery was checked for this report.

**Resending changes behavior.** Stytch says a new OTP invalidates prior OTPs for the same user. Multiple tabs/devices may therefore interfere with each other's codes, unlike the current independently generated local requests. Keep local proof consumption and expiry, explain which code to use, and test parallel sends. Do not treat the phone method ID as a per-request challenge ID. [Send SMS OTP](https://stytch.com/docs/api-reference/consumer/api/otp/via-sms/send)

**Provider limits complement local controls.** Stytch documents send/authentication rate limits; test projects have a 60-SMS/hour limit. Build automated tests with stubs instead of real sends and handle provider throttling explicitly. [Rate-limit policy](https://stytch.com/docs/resources/policies/platform/rate-limits)

**Budget needs an account-specific quote.** Do not rely on older statements that US/Canada SMS is included. The currently accessible pricing page does not establish a complete Consumer SMS rate table. Confirm Consumer monthly-active-user pricing, included US/Canada delivery, send/fair-use limits, international charges, and fraud-related spend controls. Frequent login sends matter because this app retains long-lived Rails sessions: MAUs and message volume are different inputs. [Stytch pricing](https://stytch.com/pricing)

**Message copy may change.** The current custom lowercase message should not be assumed portable. Validate the actual Stytch template, sender branding, and opt-out/help behavior; update the form and policies accordingly. Official staff responses say arbitrary SMS-body customization is unsupported. [Stytch staff responses](https://forum.stytch.com/t/custom-sms/355)

## Decision

Proceed with an OTP-only implementation once managed Live SMS is confirmed. This is a reasonable small migration for this repository, with most effort in error handling and security regression coverage. It removes ownership of real OTP generation/storage/comparison while preserving the application's established registration and session model. A full authentication/session replacement is a separate decision that the Telnyx approval problem does not require.
