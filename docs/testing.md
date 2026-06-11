# Testing

The suite uses Minitest with fixtures and builder helpers. Run it with
`mise run test` (unit/integration) and `mise run test:system` (browser).

## Test types and when to use each

- **Model tests** (`test/models/`, `ActiveSupport::TestCase`) — isolated model
  logic: validations, scopes, callbacks. Fast. Use for business rules
  (key/card/visibility logic).
- **Integration tests** (`test/controllers/`, `ActionDispatch::IntegrationTest`)
  — a real request through routing → controller → policy → rendered Phlex HTML.
  Because the app is server-rendered, these carry most flow coverage. Default
  choice for "does this flow work."
- **System tests** (`test/system/`, `ApplicationSystemTestCase`) — a real
  browser via Capybara + Playwright. Reserve for behavior that JavaScript /
  Turbo Streams change (infinite scroll, live reactions).

## Fixtures

`test/fixtures/users.yml` defines two users: `bob` (2 worlds, 1 device) and
`sue` (1 world, 2 devices). Reference them with `users(:bob)` / `users(:sue)`.
Fixture worlds have real attached icons via Active Storage fixtures
(`test/fixtures/active_storage/`), backed by the `test_fixtures` storage service
and the file `test/fixtures/files/world_icon.png`. When adding a fixture world,
add a matching attachment entry whose `record:` matches the world's fixture key.

## Builder helpers

Defined in `test/test_helpers/world_test_helper.rb`. Dumb and composable —
combine them to express a scenario; they contain no conditional logic.

- `create_world(owner:, name: nil)` — world with the canonical icon attached.
- `grant_key(world:, recipient:, color: :blue, accepted: true)` — the "join"
  primitive. `accepted: false` models the future return-key (pending) invite.
- `create_card(world:, granted_key_color: :blue, device: nil)` — a world card.
  Pass `device:` to claim it for that device's owner (`cardholder_id` is derived
  from `device.owner_id` via a model callback).
- `create_post(world:, key_colors: ["blue"], body:, **attrs)` — key-scoped post;
  `key_colors: nil` is visible to all keys.

### Sign-in

- **Integration tests** — `sign_in_as(user)` from `SessionTestHelper`. Creates a
  `Session` directly (with a verified `PhoneNumberVerificationRequest` from
  `PhoneNumberVerificationRequest.create_test_mock_for!`) and sets the signed
  `session_id` cookie.
- **System tests** — `sign_in_as(user)` from `SystemSessionTestHelper`. Visits
  `GET /test/sign_in/:user_id`, a test-env-only backdoor mounted in
  `config/routes.rb` and served by `TestsController`. The browser gets a real
  `Set-Cookie` via the regular `Authentication` concern — no driver-level cookie
  injection.
  - **Exception:** for tests that exercise onboarding itself (sign in → verify
    code → create account), drive the real forms via Capybara instead of using
    the backdoor.

### Phone-number verification

- `PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)`
  — a low-level model factory for setting up a pending (or verified) request
  without touching the controller. Use when the verify endpoint is the subject
  under test and you want to skip past create.
- `complete_phone_verification_for(phone_number:)` from
  `PhoneNumberVerificationRequestTestHelper` — drives the full create + verify
  HTTP flow (wrapping Turnstile in the always-passes client) and returns the
  verified request. Use when verification is incidental setup (e.g.
  `accounts_controller_test.rb`).

## External dependencies

- **Cloudflare Turnstile** — `PhoneNumberVerificationRequestsController#create`
  verifies a Turnstile token in every environment. Tests wrap that request in
  `with_turnstile { ... }` (see `test/test_helpers/turnstile_test_helper.rb`),
  which swaps in a client using Cloudflare's server-side test secret key (stored
  in `config/application.rb`). These keys make a real, deterministic call to
  Cloudflare, so those tests need network access.
- **SMS (Telnyx)** — not sent in test; `perform_deliveries` is production-only.
  Read `verification_code` straight off the request record.

## Sorbet conventions

Test helpers are mixed into Rails' test classes via `ActiveSupport.on_load(...)`
hooks at the bottom of each helper file (the Rails 8 generator idiom — see
`test/test_helpers/session_test_helper.rb`). These hooks don't fire during
Sorbet typecheck, so the inclusions are invisible unless mirrored in an RBI
shim. We mirror them in `sorbet/rbi/shims/application.rbi` under a "Test
Helpers" section.

- **Method sigs** live on the helper module in `test/test_helpers/*.rb` (the
  `# typed: true` source file).
- **Inclusions** (`include FooTestHelper`) live in the shim, inside the test
  class re-open the runtime hook targets.

**Adding a new helper:**

1. Create `test/test_helpers/foo_test_helper.rb` with `extend T::Sig` and
   `sig`'d methods.
2. End the file with the matching load hook:
   ```ruby
   ActiveSupport.on_load(:action_dispatch_integration_test) do
     include FooTestHelper
   end
   ```
3. Add `include FooTestHelper` to the corresponding class re-open in
   `sorbet/rbi/shims/application.rbi`.

URL helpers (`*_path`/`*_url`) inside `ActionDispatch::IntegrationTest` are
provided by Tapioca's DSL RBI generation (`bin/tapioca dsl`) — don't shim them
manually. System tests are a different case; see the shim file for the specific
include needed.

`SessionTestHelper` uses `requires_ancestor { ActionDispatch::IntegrationTest }`
so `cookies` and other integration-test methods resolve inside the helper body.
Sorbet's view of `ActionDispatch::SystemTestCase` doesn't inherit from
`IntegrationTest`, so this constraint produces a small known set of `5064`
errors in system tests — accepted trade-off, since relaxing the constraint
breaks `cookies` resolution inside the helper.

## Next effort (not yet covered)

Passkit / Apple Wallet pass generation and push notification delivery are
intentionally untested for now — they need careful mocking of the Passkit and
APNs layers. Pick this up as a dedicated follow-up.
