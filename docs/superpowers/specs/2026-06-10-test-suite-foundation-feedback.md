# Test Suite Foundation — Review Feedback (round 1)

**Date:** 2026-06-10 (last updated 2026-06-11)
**Status:** Architecturally-loaded items done in-session by the human + reviewer.
The dumb agent picks up the remaining mechanical items in a fresh session.
**Spec:** `docs/superpowers/specs/2026-06-10-test-suite-foundation-design.md`

Reference for the Rails 8 authentication generator's idiomatic shape:
`https://github.com/rails/rails/tree/main/railties/lib/rails/generators/test_unit/authentication/templates`

## Status snapshot

**Already done in-session (2026-06-11):**

- §1 — Helper inclusion standardized on the `on_load` pattern. Every helper
  file in `test/test_helpers/` ends with its own `ActiveSupport.on_load(...)`
  block (`:active_support_test_case` for `WorldTestHelper`,
  `:action_dispatch_integration_test` for `SessionTestHelper`,
  `TurnstileTestHelper`, `PhoneNumberVerificationRequestTestHelper`, and
  `:action_dispatch_system_test_case` for `SystemSessionTestHelper`).
  `test/test_helper.rb` only `require_relative`s them — no class re-opens.
  **Do not reintroduce the reopen pattern.**
- §2 — Verification builder extracted as
  `PhoneNumberVerificationRequest.create_test_mock_for!(user, verified:)` on
  the model. Used by `SessionTestHelper#sign_in_as` and `TestsController#sign_in`.
- §3 — Model test for card discard/keep now observes
  `WorldCard#discarded?` / `#kept?` directly (no stub). Context: the
  `WorldCard` rename to the Discard gem happened during this session
  (`revoked_at` → `discarded_at`, `revoke!` → `discard!`, `revoke_for!` → call
  to `discard_all!` at the WorldKey callback site, scope `unrevoked` → `kept`)
  and the rule expanded from "active cards (Passkit-registered)" to "kept
  cards" — cards without Passkit registrations now get discarded too.
- §7 — `with_turnstile` block no longer leaks state.
  `PhoneNumberVerificationRequestTestHelper#complete_phone_verification_for(phone_number:)`
  wraps the full request+verify dance and returns the verified request via
  `last!` (non-nilable).
  `phone_number_verification_requests_controller_test.rb#verify` now uses
  `PhoneNumberVerificationRequest.create_test_mock_for!(user, verified: false)`
  to skip past the create endpoint when verify is the subject under test.
- §9 — Sorbet shim consolidation. Per-helper RBI shims folded into
  `sorbet/rbi/shims/application.rbi` under a "Test Helpers" section.
- §10 — System-test sign-in backdoor: `TestsController#sign_in` (test-env
  guarded), `SystemSessionTestHelper` (driver-agnostic), `SessionTestHelper`
  stripped of its system-test branch. `bin/srb tc` is clean.

**Remaining for the dumb agent (mechanical):**

- §4 — Drive the invite-claim flow through the real controller endpoint
  instead of `world.key_grant(...)`. Discover the actual claim route + action
  (probably `WorldCardsController#claim` or similar); rewrite
  `world_key_grants_controller_test.rb` as the full flow test (and trim
  `world_keys_controller_test.rb` to just the owner-revokes-key case).
- §5 — Drop the duplicated Turbo-Frame assertion from
  `worlds_controller_test.rb#"owner views their world feed"`.
- §6 — Replace `assert_redirected_to [@post, :reactions]` with
  `post_reactions_path(@post)` in `reactions_controller_test.rb`.
- §8 — Decide on the fixtures (`worlds.yml`, `devices.yml`,
  `active_storage/*.yml`): either use them in read-only tests or delete.
- §9 follow-up — Add the Playwright `Driver.new` constructor sig to
  `sorbet/rbi/shims/capybara-playwright-driver.rbi` (see §9 for the exact
  block).
- New: write `test/system/onboarding_test.rb` — the one UI-walk system test
  that exercises the real OTP flow (sign in → verify code → create account →
  land on home). Every other system test signs in via `sign_in_as(users(:bob))`
  (the backdoor). Note: needs Cloudflare's always-passes *site* key wired
  through the view so the browser-side Turnstile widget passes in test env.

## Keep as-is

- `SessionTestHelper#sign_in_as` matches the Rails 8 generator shape
  (`Current.session = user.sessions.create!`, then
  `ActionDispatch::TestRequest.create.cookie_jar.signed[:session_id]`).
- Using `ActiveSupport.on_load(:action_dispatch_integration_test)` and
  `:action_dispatch_system_test_case` to include the helper — this is the
  idiomatic Rails 8 hook.
- Playwright cookie injection in the system-test branch of `sign_in_as` — given
  SMS-based auth, walking the OTP UI in every system test would be intolerable.
- Controller test style overall: `setup { @user = users(:bob) }`,
  `assert_difference`, `assert_redirected_to`, `assert_empty cookies[:session_id]`.

## Changes

### 1. Standardize helper inclusion on the `on_load` pattern

Three helpers currently use three different inclusion strategies. Pick one —
the Rails 8 idiom is `ActiveSupport.on_load(...)` at the bottom of each helper
file. Apply to all three:

- `test/test_helpers/world_test_helper.rb` — append:
  ```ruby
  ActiveSupport.on_load(:active_support_test_case) do
    include WorldTestHelper
  end
  ```
- `test/test_helpers/turnstile_test_helper.rb` — append:
  ```ruby
  ActiveSupport.on_load(:action_dispatch_integration_test) do
    include TurnstileTestHelper
  end
  ```
- `test/test_helper.rb` — remove the `include WorldTestHelper` line inside
  `ActiveSupport::TestCase` and the `module ActionDispatch; class
  IntegrationTest; include TurnstileTestHelper; end; end` block. Leave only the
  `require_relative "test_helpers/..."` lines.

### 2. Extract a verification-request builder; remove the throwaway in `sign_in_as`

`SessionTestHelper#sign_in_as` currently inlines a `PhoneNumberVerificationRequest.new(...)`
with throwaway attributes. That detail leaks model internals into the test
suite's auth front door, and we'll need the same construction in any other test
that touches sessions.

Extract a builder into `WorldTestHelper` (or a new
`test/test_helpers/verification_test_helper.rb` if you'd rather keep concerns
separated):

```ruby
sig { params(user: User).returns(PhoneNumberVerificationRequest) }
def create_verified_phone_number_verification_request(user:)
  PhoneNumberVerificationRequest.create!(
    phone_number: user.phone_number,
    verified_at: Time.current,
    user_agent: "test",
    ip_address: IPAddr.new("127.0.0.1"),
  )
end
```

Then `sign_in_as` becomes:

```ruby
def sign_in_as(user)
  request = create_verified_phone_number_verification_request(user:)
  Current.session = user.sessions.create!(phone_number_verification_request: request)
  # ... cookie setup unchanged ...
end
```

### 3. Don't stub `WorldCard.revoke_for!` in the model test — assert the outcome

`test/models/world_key_test.rb` currently does:

```ruby
WorldCard.stub(:revoke_for!, ->(world:, cardholder:) { revoked_for << [world, cardholder] }) do
  key.destroy!
end
assert_equal [[@world, @recipient]], revoked_for
```

This pins the *call*, not the *rule*. The rule is the load-bearing one the
spec specifically wants locked before the refactor. Rewrite:

```ruby
test "destroying a recipient's last key revokes their card" do
  key = grant_key(world: @world, recipient: @recipient)
  card = create_card(world: @world)         # cardholder = @recipient via grant
  key.destroy!
  assert_nil WorldCard.find_by(id: card.id) # or whatever "revoked" means
end

test "destroying one of several keys leaves the card in place" do
  grant_key(world: @world, recipient: @recipient, color: :blue)
  red_key = grant_key(world: @world, recipient: @recipient, color: :red)
  card = create_card(world: @world)
  red_key.destroy!
  assert WorldCard.exists?(card.id)
end
```

Adjust `create_card` if it doesn't already associate to a recipient — the
builder should accept `recipient:` so the rule's input is explicit. Look at
`WorldCard.revoke_for!` to see what "revoked" actually means in the model
(deleted vs. nullified) and assert that, not the method invocation.

### 4. Exercise the invite-claim controller, not the model API

Currently `world_key_grants_controller_test.rb` calls `world.key_grant(color: :blue)`
to fabricate the grant, then `post accept_world_key_grant_path(grant)`. The
spec asked for the full **claim card → key granted → friend joins** flow as a
single happy path. Drive the first step through the user-visible controller
(whatever creates the grant from a card token — probably
`WorldCardsController#claim` or `WorldKeyGrantsController#create`). One flow,
one file:

- Merge `test/controllers/world_key_grants_controller_test.rb` and the
  user-facing parts of `test/controllers/world_keys_controller_test.rb` into a
  single flow test (probably keep it in `world_key_grants_controller_test.rb`).
- Keep "owner revokes a member's key" in `world_keys_controller_test.rb` as a
  separate, minimal test (it's a distinct controller action).

### 5. Drop the duplicated Turbo-Frame assertion in `worlds_controller_test.rb`

`test "owner views their world feed"` does both a `get world_path(world)` and
a `get world_posts_path(world), headers: { "Turbo-Frame" => "posts" }`. The
Turbo-Frame request is already covered by
`posts_controller_test.rb#"owner views the world feed via turbo frame"`. Drop
the second request from the worlds test — keep only the show-page check.

### 6. Replace `assert_redirected_to [@post, :reactions]` with the explicit path

In `reactions_controller_test.rb`, use `post_reactions_path(@post)` instead of
the array form. Same behavior, easier to grep, easier to read.

### 7. Don't return state via side-effect from `with_turnstile` blocks

In `phone_number_verification_requests_controller_test.rb` and
`accounts_controller_test.rb`, the `with_turnstile { … }` block exists only to
swap the Turnstile client for the duration of one request — but it's currently
also where state escapes ("PhoneNumberVerificationRequest.order(:created_at).last"
inside the block). Either:

- **Minimum:** move the lookup out:
  ```ruby
  with_turnstile { post phone_number_verification_requests_path, params: ... }
  request = PhoneNumberVerificationRequest.order(:created_at).last
  ```
- **Better (recommended):** extract `complete_phone_verification_for(phone_number:)`
  into `test_helpers/verification_test_helper.rb` (or `WorldTestHelper`) that
  bundles request + verify and returns the verified request:
  ```ruby
  def complete_phone_verification_for(phone_number:, user_attrs: {})
    with_turnstile do
      post phone_number_verification_requests_path,
        params: { phone_number_verification_request: { phone_number: },
                  "cf-turnstile-response": "dummy" },
        headers: { "User-Agent" => "test" },
        as: :turbo_stream
    end
    request = PhoneNumberVerificationRequest.order(:created_at).last
    post verify_phone_number_verification_request_path(request),
      params: { phone_number_verification_request: { verification_code: request.verification_code },
                user: user_attrs.presence }.compact,
      as: :turbo_stream
    request
  end
  ```
  Then `accounts_controller_test.rb` shrinks to its actual subject (account
  creation), and the `# rubocop:disable Minitest/MultipleAssertions` comes out.

### 8. Cash in the fixtures or remove them

`worlds.yml`, `devices.yml`, and `test/fixtures/active_storage/*.yml` are seeded
but unused — every integration test calls `create_world` instead. The spec said
they should be usable in render-level tests (real icon attached). Either:

- Use them where you don't need freshness — e.g. read-only tests like
  `worlds_controller_test.rb#"owner views their world feed"` could be
  `world = worlds(:bobs_world_one)` instead of `create_world(...)`.
- Or delete them until a test needs them.

Don't leave them as dead weight.

### 9. Sorbet visibility for test helpers — applied during review

This section captures what we landed on during the round-1 review (already
applied; no action needed from the implementing agent unless you add new
helpers).

**Convention:** Test helpers stay wired into Rails' test classes via
`ActiveSupport.on_load(...)` hooks (the Rails 8 generator idiom). These hooks
are invisible to Sorbet because they don't execute during typecheck, so we
mirror every runtime inclusion in `sorbet/rbi/shims/application.rbi` under a
"Test Helpers" section. Method sigs themselves live on the helper modules in
`test/test_helpers/*.rb` — only the `include` belongs in the shim.

**What changed:**

- Deleted `sorbet/rbi/shims/world_test_helper.rbi` and
  `sorbet/rbi/shims/turnstile_test_helper.rbi`. Their `include` declarations
  moved into `application.rbi`. `capybara-playwright-driver.rbi` stayed (it's a
  gem shim, different category).
- `test/test_helper.rb` no longer reopens `ActiveSupport::TestCase` or
  `ActionDispatch::IntegrationTest` to `include` helpers — every helper file
  ends with its own `ActiveSupport.on_load(...)` block.
- URL helpers (`*_path`/`*_url`) for `IntegrationTest` come from Tapioca's DSL
  RBI generation (`bin/tapioca dsl`), not from a manual shim.

**Adding a new helper:** create `test/test_helpers/foo_test_helper.rb` with the
sigs, end the file with the appropriate `ActiveSupport.on_load(...)` block, and
add a matching `include FooTestHelper` inside the relevant class re-open in
`application.rbi`'s "Test Helpers" section.

**Known residual errors (not fixed in round 1):**

1. **`SessionTestHelper`'s `requires_ancestor { ActionDispatch::IntegrationTest }`
   trips for every `SystemTestCase` descendant** (5 srb errors). Sorbet's
   actionpack RBI declares `SystemTestCase < ActiveSupport::TestCase`, not
   `< IntegrationTest`, so the contract is violated even though Ruby has it
   right. The constraint is kept because it's how `cookies`/`Current.session`
   resolve inside the helper body — relaxing it cascades into more errors.
   **Resolved by §10** — once the system-test branch is removed from
   `SessionTestHelper` and the runtime hook stops including it into
   `:action_dispatch_system_test_case`, no `SystemTestCase` descendant claims
   the helper and these errors disappear.

2. **`request.verification_code` on `T.nilable(PhoneNumberVerificationRequest)`**
   in `accounts_controller_test.rb:24` and
   `phone_number_verification_requests_controller_test.rb:38` (2 srb errors).
   These go away when §7 lands — the extracted
   `complete_phone_verification_for(phone_number:)` helper can return a
   non-nilable record by fetching with `find_by!` or doing a single
   `T.must` internally. Don't paper over with `T.must(request)` at the call
   site; the helper extraction is the real fix.

3. **Playwright `Driver.new` constructor sig** — `capybara-playwright-driver.rbi`
   currently declares only `include DriverExtension`, not the constructor.
   Add to that shim:
   ```ruby
   class Driver < ::Capybara::Driver::Base
     include DriverExtension

     sig do
       params(
         app: T.untyped,
         browser_type: Symbol,
         headless: T::Boolean,
       ).void
     end
     def initialize(app, browser_type:, headless:); end
   end
   ```

## After applying

Run the full suite (`bin/rails test` and `bin/rails test:system`) and confirm
green before re-review. Note any tests where applying #4 (real claim
controller) surfaced a missing route or action — that's a finding worth
flagging in the PR description, not patching over silently.
