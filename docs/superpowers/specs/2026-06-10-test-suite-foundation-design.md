# Test Suite Foundation — Design

**Date:** 2026-06-10
**Status:** Approved (pending spec review)

## Goal

Establish the app's first real test suite. Motivation is **80% pre-launch QA**
(prove the core happy paths work end-to-end before more people use it) and
**20% refactor confidence** (lock down the key/card logic before building the
near-future multi-key, multi-world, and return-key features).

Guiding constraints (from the project owner):

- Cover **all core user flows**, but stay **light on edge cases**.
- Keep examples and mocks **tight** — no two examples of the same edge case.
- Optimize for **readability and low maintenance** above all.

## Scope

**In scope:** auth/onboarding, world creation, invite→claim→join, posting
(key-scoped), reactions, reply initiations, leaving a world — plus model-level
tests for the key/card business logic about to be refactored.

**Out of scope (this effort):** Passkit / Apple Wallet pass generation and push
notification delivery. These need careful mocking and are deferred to a
follow-up effort (flagged in `docs/testing.md`).

## Approach

**Approach A — integration-first, thin system layer.** Because the app is
server-rendered (Phlex + Turbo), `ActionDispatch::IntegrationTest` asserts
against real rendered HTML and real redirects, carrying most of the
"does the flow work" weight at a fraction of the cost of browser tests. We add:

- **Integration tests** — one happy path per core flow (the 80%).
- **Model tests** — the key/card/post-visibility logic about to change (the 20%).
- **System tests (Playwright)** — only where JavaScript/Turbo Streams change the
  outcome (infinite scroll, live reaction toggle).

## Tooling changes

- Remove `selenium-webdriver`; add `capybara-playwright-driver` (gem) +
  `playwright` (bun devDependency). The driver shells out to the bun-installed
  Playwright CLI.
- New `test/application_system_test_case.rb` — registers the Playwright driver
  (headless Chromium), `driven_by :playwright`.
- Keep Minitest, parallelization, and `fixtures :all` as-is.

## Test data strategy

**Minimal fixtures + explicit builder helpers** (not expanded relational
fixtures). Builders make each flow test read top-to-bottom as the scenario it
tests; fixtures stay for static, shared records.

### Builder helpers

New `test/test_helpers/world_test_helper.rb`, mixed into
`ActiveSupport::TestCase` and `ActionDispatch::IntegrationTest` (same pattern as
the existing `SessionTestHelper`). Builders are **dumb** — no conditional logic,
no "smart" factories. Each returns the created record; defaults keep simple
tests to one-liners.

```ruby
create_world(owner:, name: nil)                              # attaches the canonical icon (icon is required)
grant_key(world:, recipient:, color: :blue, accepted: true) # the "join" primitive
create_card(world:, color: :blue)                            # WorldCard (invite artifact)
create_post(world:, key_colors: [:blue], **attrs)           # key-scoped feed content
```

Design notes:

- `grant_key` is the **join primitive**. A joined friend =
  `grant_key(world:, recipient: user)`. The `accepted:` flag toggles
  `accepted_at` — directly expressing the future **return-key (unaccepted)**
  flow with `accepted: false`. Multi-key/multi-world scenarios are just
  different combinations of these same primitives, so the helpers won't need
  redesigning when those features land.
- `create_world` attaches the canonical world icon (a copy of
  `public/web-app-manifest-512x512.png`) because `World` requires an attached
  icon.
- Defaults pick `:blue` everywhere; explicit colors drive multi-key tests.

### Static fixtures

Rename the existing fixture users and expand to model the relational setups that
matter for multi-world/multi-device logic:

- `users.yml` — `bob` and `sue` (renamed from `one`/`two`).
- `worlds.yml` — `bob` owns **2 worlds**, `sue` owns **1 world**.
- `devices.yml` — `bob` has **1 device**, `sue` has **2 devices**.

Fixture worlds get **real attached icons** via Active Storage fixtures (below),
so they are usable in render-level tests, not just association/query tests.

### Active Storage fixtures (world icons)

Per the official `ActiveStorage::FixtureSet` recipe:

1. `config/storage.yml` — add a `test_fixtures` service (Disk, root
   `tmp/storage_fixtures`) to keep fixture blobs separate from blobs created
   during tests.
2. `test/fixtures/files/world_icon.png` — a copy of
   `public/web-app-manifest-512x512.png`.
3. `test/fixtures/active_storage/blobs.yml`:
   ```yaml
   world_icon_blob: <%= ActiveStorage::FixtureSet.blob filename: "world_icon.png", service_name: "test_fixtures" %>
   ```
4. `test/fixtures/active_storage/attachments.yml` — one attachment per fixture
   world, e.g.:
   ```yaml
   bobs_world_one_icon:
     name: icon
     record: bobs_world_one (World)
     blob: world_icon_blob
   ```

Gotcha: the `record:` identifier must exactly match the world's fixture key
name.

## External dependencies

### Cloudflare Turnstile (the only mock)

`PhoneNumberVerificationRequestsController#create` runs `verify_turnstile_request`
in every environment. Rather than mock the verify call, use Cloudflare's
official **server-side test secret keys**, stored in `config/application.rb`:

```ruby
config.x.turnstile_test_secret_keys.always_passes_key  = "1x0000000000000000000000000000000AA"
config.x.turnstile_test_secret_keys.always_fails_key   = "2x0000000000000000000000000000000AA"
config.x.turnstile_test_secret_keys.already_spent_key  = "3x0000000000000000000000000000000AA"
```

`Turnstile::Client#initialize` accepts `secret_key:` (defaulting to
credentials), and `Smallerworld.application#turnstile_client` is the single
construction point. A `TurnstileTestHelper` injects a client built with the
chosen test key using Minitest's block-scoped `stub`:

```ruby
def with_turnstile(behavior = :always_passes, &block)
  key = Rails.configuration.x.turnstile_test_secret_keys.public_send("#{behavior}_key")
  client = Turnstile::Client.new(secret_key: key)
  Smallerworld.application.stub(:turnstile_client, client, &block)
end
```

Tests pass a dummy `cf-turnstile-response` token inside the block.

Tradeoff: the test keys still make a **real (deterministic) HTTP call** to
Cloudflare's `siteverify`. This adds a small network dependency to the
verification tests but exercises the actual integration path — acceptable given
the pre-launch-QA goal.

### SMS (no mock needed)

`deliver_verification_code` (Telnyx) only fires when
`config.x.phone_number_verification_requests.perform_deliveries` is true, which
is **production-only**. In test no SMS is sent. The `verification_code` is stored
on the record, so tests read it back directly to complete verification.

## Test inventory

### Model tests (the 20% — lock key/card logic before refactor)

- `world_key_test.rb` — color uniqueness per recipient+world; cannot key the
  world owner; **card revoked when a recipient's last key is destroyed,
  retained when another key remains** (the multi-key rule).
- `world_test.rb` — default name; name uniqueness per owner; key-color labels.
- `post_test.rb` — key-color visibility scope (which keys can see a post).
- `user_test.rb` — `dm_url` for sms/whatsapp/telegram (the reply mechanism).

### Integration tests (the 80% — one happy path per flow)

- `sessions` — extend existing (sign in via verified request; destroy).
- `phone_number_verification` — request + verify OTP (Turnstile test key; read
  code from record).
- `accounts` — create account (new user → name/timezone → session).
- `worlds` — create, edit, show (key-scoped feed), leave.
- `posts` — create (key-scoped), edit, destroy, index pagination.
- `reactions` — create + destroy.
- `reply_initiations` — create (asserts the DM link).
- `world_cards` / `world_keys` — claim card → key granted → friend joins.

### System tests (Playwright — only where JS changes the outcome)

- Infinite-scroll feed (`PostsController#index` Turbo Stream append).
- Live reaction toggle.

Total: ~4 model + ~10 integration + ~2 system test files. One example per
behavior; no duplicate edge cases.

## Documentation

- **`docs/testing.md`** — the detailed testing guide: the four test types & when
  to use each, the builder helpers, the Active Storage fixture setup, the
  Turnstile test-key approach, the fixture roster (`bob`/`sue`), and a flagged
  **"Next effort: Passkit/Apple Wallet pass generation + push notification tests
  (need mocking)."**
- **`AGENTS.md`** — a concise pointer to `docs/testing.md` describing its scope,
  not a copy of its contents.

## Out of scope / non-goals

- Passkit / Apple Wallet pass generation tests.
- Push notification delivery tests.
- Exhaustive edge-case coverage — one example per behavior only.
- Replacing fixtures wholesale with a factory library.
