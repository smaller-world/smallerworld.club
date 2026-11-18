# Testing

The suite uses Minitest with fixtures and builder helpers. Run it with
`mise run test` (unit/integration) and `mise run test:system` (browser). CI runs
both suites with `mise run test:all`.

## Propose and approve tests before writing them

1. Identify the promised behavior and its source, such as a product decision,
   issue, ADR, or reported regression. Ask Kai to decide when the expected
   outcome is ambiguous. Existing code can help identify the boundary and likely
   failure modes.
2. Propose each test in Given/When/Then pseudocode. Name the actor, the
   behavior, the public interface under test, the observable outcome, and a
   plausible regression this test would catch. Point to overlapping tests and
   explain what the proposed case adds. Use a small state or sequence diagram
   when roles, state transitions, or concurrent requests are hard to follow.
3. Wait for Kai's explicit approval before adding a test or changing the
   behavior or public interface an existing test verifies. Routine setup
   refactors, selector repairs that preserve the assertion, and reruns can
   proceed directly.
4. For an approved new behavior or bug fix, write one test and confirm it fails
   for the expected reason. Make the smallest behavior change that passes it,
   then refactor with the test green. For existing behavior, check that the
   assertion can detect the regression you named, for example with a temporary
   local change that you revert.

Before proposing a case, ask what breaks if the test is removed. Two tests
exercise the same case if they establish the same promise and catch the same
failure at the same boundary. Separate cases earn their place through a
different actor, state, outcome, entry point, or plausible failure. Browser
coverage of a critical user flow may intentionally repeat a lower-level case.

Assert outcomes through the selected interface. In a request test, this can be
rendered content, a subsequent request, or a durable state change the action
promises. In a model test, it can be the result of a public domain operation.
Use independently specified expectations. Use stable browser controls and
observable state, and keep CSS classes, callback registration, storage layout,
and intermediate JavaScript state out of assertions unless they are part of the
contract under test. Simulate external services and otherwise unreachable
failures at the narrowest practical boundary.

## Test types and when to use each

- **Model tests** (`test/models/`, `ActiveSupport::TestCase`) — business rules
  exposed by a public model operation, such as which posts a key grants or what
  survives a failed write. These can use the real test database.
- **Integration tests** (`test/controllers/`, `ActionDispatch::IntegrationTest`)
  — a real request through routing → controller → policy → rendered Phlex HTML.
  Because the app is server-rendered, these carry most flow coverage. Default
  choice for "does this flow work."
- **System tests** (`test/system/`, `ApplicationSystemTestCase`) — a real
  browser via Capybara + Playwright. Use for critical user goals end to end and
  for browser behavior a request test cannot observe, such as resuming a draft
  or reacting without a reload. Drive the flow to its user-visible outcome, even
  when a faster test covers some of the same steps.

### Opt-in checks

Keep the regular CI suite in `test/`. Put automated checks that are run manually
in `checks/`, using the usual `_test.rb` suffix. Both use `RAILS_ENV=test` and
the existing test helpers. Rails' normal discovery and `test:all` search under
`test/`, so files in `checks/` are excluded without custom filtering.

| Command                     | Directory             | Purpose                                    |
| --------------------------- | --------------------- | ------------------------------------------ |
| `mise run test:ui`          | `checks/ui/`          | Browser checks for component compatibility |
| `mise run test:seeds`       | `checks/seeds/`       | Development baseline and seed isolation    |
| `mise run test:development` | `checks/development/` | Development account switching and guards   |
| `mise run test:optional`    | `checks/`             | All opt-in checks                          |

Run the relevant checks when changing components or development seeds.
Individual files also work:
`bin/rails test checks/seeds/development_data_test.rb`. Development tooling
checks live in `checks/development/`, outside Rails' normal `test/` discovery.
These include the account-switching route and controller environment guards.

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
- `create_member_key(world:, recipient:)` — grants the recipient a key with
  access to all of the world's current post types.
- `create_post(world:, type_label: "journal entry", body: "hello world", **attributes)`
  — creates a post using the world's post type with the given label, forwarding
  additional attributes to `world.posts.create!`.

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
  HTTP flow and returns the verified request. This exercises Turnstile over the
  network. When verification is incidental to the case, start with the closest
  prerequisite the test needs.

## External dependencies

- **Cloudflare Turnstile** — `PhoneNumberVerificationRequestsController#create`
  verifies a Turnstile token in every environment. The initializer selects
  Cloudflare's always-passes test keys outside production. The client calls
  Cloudflare's verification endpoint, so tests that create a verification
  request over HTTP need network access.
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

Native push notification delivery is intentionally untested for now — it needs
careful mocking of the push services. Pick this up as a dedicated follow-up.
