# Test Suite Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the app's first real test suite — builder helpers, fixtures, and model/integration/system tests covering all core user flows.

**Architecture:** Integration-first (server-rendered Phlex + Turbo means `IntegrationTest` asserts real HTML/redirects), with a thin model layer for key/card logic and a thin Playwright system layer for JS-only behavior. Test data comes from minimal fixtures (`bob`/`sue`) plus dumb builder helpers.

**Tech Stack:** Minitest, Capybara + capybara-playwright-driver, Active Storage fixtures, Cloudflare Turnstile server-side test keys.

**Reference spec:** `docs/superpowers/specs/2026-06-10-test-suite-foundation-design.md`

---

## File Structure

**Config / tooling**
- `Gemfile` — swap `selenium-webdriver` → `capybara-playwright-driver`
- `package.json` — add `playwright` devDependency
- `config/application.rb` — add Turnstile test secret keys
- `config/storage.yml` — add `test_fixtures` service
- `test/application_system_test_case.rb` — Playwright driver (create)

**Test data**
- `test/fixtures/users.yml` — rename to `bob`/`sue`
- `test/fixtures/worlds.yml` — create (bob: 2, sue: 1)
- `test/fixtures/devices.yml` — create (bob: 1, sue: 2)
- `test/fixtures/active_storage/blobs.yml` — create
- `test/fixtures/active_storage/attachments.yml` — create
- `test/fixtures/files/world_icon.png` — copy of the logo
- `test/test_helpers/world_test_helper.rb` — builders (create)
- `test/test_helpers/turnstile_test_helper.rb` — Turnstile stub (create)

**Tests**
- `test/models/world_key_test.rb`, `world_test.rb`, `post_test.rb`, `user_test.rb`
- `test/controllers/*` — sessions (extend), phone verification, accounts, worlds, posts, reactions, reply_initiations, world_key_grants, world_keys
- `test/system/feed_test.rb`, `test/system/reactions_test.rb`

**Docs**
- `docs/testing.md` — full testing guide (create)
- `AGENTS.md` — concise pointer (modify)

---

## Phase 1 — Tooling & Config

### Task 1: Swap Selenium for Playwright

**Files:**
- Modify: `Gemfile`
- Modify: `package.json`

- [ ] **Step 1: Replace the gem**

In `Gemfile`, find `gem "selenium-webdriver"` and replace with:

```ruby
gem "capybara-playwright-driver"
```

- [ ] **Step 2: Install the gem**

Run: `bundle install`
Expected: bundle completes, `capybara-playwright-driver` resolved.

- [ ] **Step 3: Add the Playwright CLI via bun**

Run: `bun add -d playwright && bunx playwright install chromium`
Expected: `playwright` appears under `devDependencies` in `package.json`; Chromium downloads.

- [ ] **Step 4: Commit**

```bash
git add Gemfile Gemfile.lock package.json bun.lock
git commit -m "test: replace selenium-webdriver with capybara-playwright-driver"
```

---

### Task 2: Add Turnstile test secret keys to config

**Files:**
- Modify: `config/application.rb`

- [ ] **Step 1: Add the config block**

In `config/application.rb`, inside `class Application`, under the `# == Custom Configuration ==` section (after the `config.confetti_canvas_id` line), add:

```ruby
# Cloudflare Turnstile server-side test secret keys.
# See: https://developers.cloudflare.com/turnstile/troubleshooting/testing/
config.x.turnstile_test_secret_keys.always_passes_key = "1x0000000000000000000000000000000AA"
config.x.turnstile_test_secret_keys.always_fails_key  = "2x0000000000000000000000000000000AA"
config.x.turnstile_test_secret_keys.already_spent_key = "3x0000000000000000000000000000000AA"
```

- [ ] **Step 2: Verify config loads**

Run: `RAILS_ENV=test bin/rails runner 'puts Rails.configuration.x.turnstile_test_secret_keys.always_passes_key'`
Expected: prints `1x0000000000000000000000000000000AA`

- [ ] **Step 3: Commit**

```bash
git add config/application.rb
git commit -m "test: add cloudflare turnstile test secret keys to config"
```

---

### Task 3: Add the test_fixtures storage service

**Files:**
- Modify: `config/storage.yml`

- [ ] **Step 1: Add the service**

Append to `config/storage.yml`:

```yaml
test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

- [ ] **Step 2: Verify it parses**

Run: `RAILS_ENV=test bin/rails runner 'puts ActiveStorage::Blob.services.fetch(:test_fixtures).class'`
Expected: prints a Disk service class (e.g. `ActiveStorage::Service::DiskService`).

- [ ] **Step 3: Commit**

```bash
git add config/storage.yml
git commit -m "test: add test_fixtures active storage service"
```

---

### Task 4: Create the system test case

**Files:**
- Create: `test/application_system_test_case.rb`

- [ ] **Step 1: Write the file**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"
require "capybara/playwright"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: true,
  )
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :playwright
end
```

- [ ] **Step 2: Commit**

```bash
git add test/application_system_test_case.rb
git commit -m "test: add playwright-driven system test case"
```

---

## Phase 2 — Test Data

### Task 5: Rename fixture users to bob and sue

**Files:**
- Modify: `test/fixtures/users.yml`
- Modify: `test/controllers/sessions_controller_test.rb` (still uses `User.take`, no change needed, but confirm green)

- [ ] **Step 1: Rewrite the fixture body**

Replace the two fixture entries (keep the schema comment header) so the keys are `bob` and `sue`:

```yaml
bob:
  name: Bob
  phone_number: +14165558323
  time_zone_name: America/New_York

sue:
  name: Sue
  phone_number: +19054997382
  time_zone_name: America/New_York
```

- [ ] **Step 2: Verify existing tests still pass**

Run: `mise run test test/controllers/sessions_controller_test.rb`
Expected: PASS (the test uses `User.take`, agnostic to fixture names).

- [ ] **Step 3: Commit**

```bash
git add test/fixtures/users.yml
git commit -m "test: rename fixture users to bob and sue"
```

---

### Task 6: Add the canonical world icon fixture file

**Files:**
- Create: `test/fixtures/files/world_icon.png`

- [ ] **Step 1: Copy the logo**

Run: `cp public/web-app-manifest-512x512.png test/fixtures/files/world_icon.png`
Expected: file exists.

- [ ] **Step 2: Verify**

Run: `file test/fixtures/files/world_icon.png`
Expected: reports a PNG image.

- [ ] **Step 3: Commit**

```bash
git add test/fixtures/files/world_icon.png
git commit -m "test: add canonical world icon fixture file"
```

---

### Task 7: Add Active Storage fixtures for world icons

**Files:**
- Create: `test/fixtures/active_storage/blobs.yml`
- Create: `test/fixtures/active_storage/attachments.yml`

> Note: this task depends on Task 8's `worlds.yml` for the `record:` references. Implement Task 8 first if doing them out of order; the verification step here runs after both exist.

- [ ] **Step 1: Write blobs.yml**

```yaml
world_icon_blob: <%= ActiveStorage::FixtureSet.blob filename: "world_icon.png", service_name: "test_fixtures" %>
```

- [ ] **Step 2: Write attachments.yml**

One attachment per fixture world (record identifiers must match `worlds.yml` keys from Task 8):

```yaml
bobs_world_one_icon:
  name: icon
  record: bobs_world_one (World)
  blob: world_icon_blob

bobs_world_two_icon:
  name: icon
  record: bobs_world_two (World)
  blob: world_icon_blob

sues_world_icon:
  name: icon
  record: sues_world (World)
  blob: world_icon_blob
```

- [ ] **Step 3: Commit** (after Task 8, verified there)

```bash
git add test/fixtures/active_storage/blobs.yml test/fixtures/active_storage/attachments.yml
git commit -m "test: add active storage fixtures for world icons"
```

---

### Task 8: Add world and device fixtures

**Files:**
- Create: `test/fixtures/worlds.yml`
- Create: `test/fixtures/devices.yml`

- [ ] **Step 1: Write worlds.yml**

Names must be distinct per owner (unique index on `[name, owner_id]`):

```yaml
bobs_world_one:
  name: Bob's First World
  owner: bob

bobs_world_two:
  name: Bob's Second World
  owner: bob

sues_world:
  name: Sue's World
  owner: sue
```

- [ ] **Step 2: Write devices.yml**

`identifier` is unique; `platform` is `apple`/`google`:

```yaml
bobs_phone:
  identifier: bob-iphone
  platform: apple
  owner: bob

sues_phone:
  identifier: sue-iphone
  platform: apple
  owner: sue

sues_tablet:
  identifier: sue-ipad
  platform: apple
  owner: sue
```

- [ ] **Step 3: Verify all fixtures load with attached icons**

Run: `mise run test test/controllers/sessions_controller_test.rb`
Expected: PASS — fixtures (including Active Storage attachments from Task 7) load without error.

Run: `RAILS_ENV=test bin/rails runner 'puts World.find_by!(name: "Sue'\''s World").icon.attached?'`
Expected: prints `true`.

- [ ] **Step 4: Commit**

```bash
git add test/fixtures/worlds.yml test/fixtures/devices.yml
git commit -m "test: add world and device fixtures with attached icons"
```

---

### Task 9: Add builder helpers

**Files:**
- Create: `test/test_helpers/world_test_helper.rb`
- Modify: `test/test_helper.rb` (require the helper)

- [ ] **Step 1: Write the helper**

```ruby
# typed: true
# frozen_string_literal: true

# Dumb, composable builders for world-related records. No conditional logic —
# combine them to express scenarios. See docs/testing.md.
module WorldTestHelper
  extend T::Sig

  WORLD_ICON_PATH = Rails.root.join("test/fixtures/files/world_icon.png")

  # Creates a world owned by `owner` with the canonical icon attached
  # (icon is a required attachment).
  sig { params(owner: User, name: T.nilable(String)).returns(World) }
  def create_world(owner:, name: nil)
    world = owner.owned_worlds.build
    world.name = name if name
    world.icon.attach(
      io: File.open(WORLD_ICON_PATH),
      filename: "world_icon.png",
      content_type: "image/png",
    )
    world.save!
    world
  end

  # Grants `recipient` a key to `world`. The "join" primitive.
  # `accepted: false` models the future return-key (pending) invite.
  sig do
    params(world: World, recipient: User, color: Symbol, accepted: T::Boolean)
      .returns(WorldKey)
  end
  def grant_key(world:, recipient:, color: :blue, accepted: true)
    world.keys.create!(
      recipient:,
      color:,
      accepted_at: accepted ? Time.current : nil,
    )
  end

  # Creates an unclaimed world card (invite artifact).
  sig { params(world: World, color: Symbol).returns(WorldCard) }
  def create_card(world:, color: :blue)
    world.cards.create!(granted_key_color: color)
  end

  # Creates a key-scoped post. `key_colors: nil` means visible to all keys.
  sig do
    params(
      world: World,
      key_colors: T.nilable(T::Array[String]),
      body: String,
      attrs: T.untyped,
    ).returns(Post)
  end
  def create_post(world:, key_colors: [ "blue" ], body: "hello world", **attrs)
    world.posts.create!(body:, key_colors:, **attrs)
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include WorldTestHelper
end
```

- [ ] **Step 2: Require it in test_helper.rb**

In `test/test_helper.rb`, after the existing `require_relative "test_helpers/session_test_helper"` line, add:

```ruby
require_relative "test_helpers/world_test_helper"
```

- [ ] **Step 3: Write a smoke test**

Create `test/models/world_test.rb` (expanded further in Task 12):

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldTest < ActiveSupport::TestCase
  test "create_world helper attaches an icon" do
    world = create_world(owner: users(:sue), name: "Helper World")

    assert world.persisted?
    assert world.icon.attached?
  end
end
```

- [ ] **Step 4: Run the smoke test**

Run: `mise run test test/models/world_test.rb`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add test/test_helpers/world_test_helper.rb test/test_helper.rb test/models/world_test.rb
git commit -m "test: add world builder helpers"
```

---

### Task 10: Add the Turnstile test helper

**Files:**
- Create: `test/test_helpers/turnstile_test_helper.rb`
- Modify: `test/test_helper.rb` (require + include for integration tests)

- [ ] **Step 1: Write the helper**

```ruby
# typed: true
# frozen_string_literal: true

# Swaps the application's Turnstile client for one using a Cloudflare
# server-side test secret key. Block-scoped via Minitest's `stub`.
# NOTE: the test keys still make a real (deterministic) call to Cloudflare.
module TurnstileTestHelper
  extend T::Sig

  sig do
    type_parameters(:U)
      .params(behavior: Symbol, block: T.proc.returns(T.type_parameter(:U)))
      .returns(T.type_parameter(:U))
  end
  def with_turnstile(behavior = :always_passes, &block)
    key = Rails.configuration.x.turnstile_test_secret_keys
      .public_send("#{behavior}_key")
    client = Turnstile::Client.new(secret_key: key)
    Smallerworld.application.stub(:turnstile_client, client, &block)
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include TurnstileTestHelper
end
```

- [ ] **Step 2: Require it in test_helper.rb**

In `test/test_helper.rb`, after the `world_test_helper` require, add:

```ruby
require_relative "test_helpers/turnstile_test_helper"
```

- [ ] **Step 3: Commit**

```bash
git add test/test_helpers/turnstile_test_helper.rb test/test_helper.rb
git commit -m "test: add turnstile test helper using cloudflare test keys"
```

---

## Phase 3 — Model Tests

> These pin the key/card/visibility logic about to be refactored (the 20%). They run against existing behavior — write the test, run it, and it should pass. A failure means either a real bug or a setup issue; investigate before "fixing" the test.

### Task 11: WorldKey model tests

**Files:**
- Create: `test/models/world_key_test.rb`

- [ ] **Step 1: Write the tests**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeyTest < ActiveSupport::TestCase
  setup do
    @world = create_world(owner: users(:bob), name: "Key Test World")
    @recipient = users(:sue)
  end

  test "color is unique per recipient and world" do
    grant_key(world: @world, recipient: @recipient, color: :blue)
    duplicate = @world.keys.build(recipient: @recipient, color: :blue)

    assert_not duplicate.valid?
    assert_match(/already has a blue key/, duplicate.errors.full_messages.to_sentence)
  end

  test "a recipient may hold multiple keys of different colors" do
    grant_key(world: @world, recipient: @recipient, color: :blue)
    second = @world.keys.build(recipient: @recipient, color: :red)

    assert second.valid?
  end

  test "the world owner cannot be granted a key" do
    key = @world.keys.build(recipient: users(:bob), color: :blue)

    assert_not key.valid?
    assert_includes key.errors[:recipient_id], "cannot be the world owner"
  end

  test "destroying a recipient's last key revokes their cards" do
    key = grant_key(world: @world, recipient: @recipient)
    revoked_for = []
    WorldCard.stub(:revoke_for!, ->(world:, cardholder:) { revoked_for << [ world, cardholder ] }) do
      key.destroy!
    end

    assert_equal [ [ @world, @recipient ] ], revoked_for
  end

  test "destroying one of several keys does not revoke cards" do
    grant_key(world: @world, recipient: @recipient, color: :blue)
    red_key = grant_key(world: @world, recipient: @recipient, color: :red)
    revoked_for = []
    WorldCard.stub(:revoke_for!, ->(world:, cardholder:) { revoked_for << [ world, cardholder ] }) do
      red_key.destroy!
    end

    assert_empty revoked_for
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/models/world_key_test.rb`
Expected: PASS (5 tests).

- [ ] **Step 3: Commit**

```bash
git add test/models/world_key_test.rb
git commit -m "test: cover world key uniqueness and card revocation logic"
```

---

### Task 12: World model tests

**Files:**
- Modify: `test/models/world_test.rb` (replace the smoke test)

- [ ] **Step 1: Replace the file contents**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldTest < ActiveSupport::TestCase
  test "create_world helper attaches an icon" do
    world = create_world(owner: users(:sue), name: "Helper World")

    assert world.persisted?
    assert world.icon.attached?
  end

  test "defaults its name from the owner's first name" do
    world = users(:bob).owned_worlds.build

    assert_equal "Bob's world", world.name
  end

  test "name is unique per owner" do
    create_world(owner: users(:sue), name: "Duplicate World")
    duplicate = users(:sue).owned_worlds.build(name: "Duplicate World")

    assert_not duplicate.valid?
    assert_includes duplicate.errors.full_messages.to_sentence, "Duplicate World"
  end

  test "key_label uses a custom label when present, else humanizes the color" do
    world = create_world(owner: users(:bob), name: "Label World")
    world.update!(blue_key_label: "besties")

    assert_equal "besties key", world.key_label(color: :blue)
    assert_equal "red key", world.key_label(color: :red)
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/models/world_test.rb`
Expected: PASS (4 tests).

- [ ] **Step 3: Commit**

```bash
git add test/models/world_test.rb
git commit -m "test: cover world default name, uniqueness, and key labels"
```

---

### Task 13: Post visibility model tests

**Files:**
- Create: `test/models/post_test.rb`

- [ ] **Step 1: Write the tests**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @owner = users(:bob)
    @friend = users(:sue)
    @world = create_world(owner: @owner, name: "Visibility World")
  end

  test "the owner sees all posts in their world" do
    post = create_post(world: @world, key_colors: [ "red" ])

    assert_includes Post.visible_to(@owner), post
  end

  test "a key holder sees posts scoped to their key color" do
    grant_key(world: @world, recipient: @friend, color: :blue)
    visible = create_post(world: @world, key_colors: [ "blue" ])
    hidden = create_post(world: @world, key_colors: [ "red" ])

    scope = Post.visible_to(@friend)
    assert_includes scope, visible
    assert_not_includes scope, hidden
  end

  test "a key holder sees posts with no color restriction" do
    grant_key(world: @world, recipient: @friend, color: :blue)
    post = create_post(world: @world, key_colors: nil)

    assert_includes Post.visible_to(@friend), post
  end

  test "a non-member sees nothing" do
    post = create_post(world: @world, key_colors: nil)

    assert_not_includes Post.visible_to(@friend), post
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/models/post_test.rb`
Expected: PASS (4 tests).

- [ ] **Step 3: Commit**

```bash
git add test/models/post_test.rb
git commit -m "test: cover post key-scoped visibility"
```

---

### Task 14: User reply-link model tests

**Files:**
- Create: `test/models/user_test.rb`

- [ ] **Step 1: Write the tests**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup { @user = users(:bob) } # phone_number +14165558323

  test "dm_url builds an sms link" do
    url = @user.dm_url(platform: :sms, message: "hi there")

    assert_equal "sms:+14165558323?body=hi%20there", url
  end

  test "dm_url builds a whatsapp link" do
    url = @user.dm_url(platform: :whatsapp, message: "hi there")

    assert_equal "https://wa.me/+14165558323?text=hi%20there", url
  end

  test "dm_url builds a telegram link" do
    url = @user.dm_url(platform: :telegram, message: "hi there")

    assert_equal "https://t.me/+14165558323?text=hi%20there", url
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/models/user_test.rb`
Expected: PASS (3 tests). If a URL assertion mismatches, copy the actual value from the failure into the assertion (encoding of the space may differ) — confirm the structure is correct first.

- [ ] **Step 3: Commit**

```bash
git add test/models/user_test.rb
git commit -m "test: cover user dm_url reply links"
```

---

## Phase 4 — Integration Tests

> One happy path per flow. Assert on status, redirect, and DB state — avoid coupling to view internals. Sign in with the existing `sign_in_as` helper.

### Task 15: Extend sessions controller test

**Files:**
- Modify: `test/controllers/sessions_controller_test.rb`

- [ ] **Step 1: Replace the commented credential tests with the current model**

Replace the whole file with:

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:bob) }

  test "new renders the login page" do
    get new_session_path

    assert_response :success
  end

  test "destroy signs the user out" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/controllers/sessions_controller_test.rb`
Expected: PASS (2 tests).

- [ ] **Step 3: Commit**

```bash
git add test/controllers/sessions_controller_test.rb
git commit -m "test: modernize sessions controller test"
```

---

### Task 16: Phone verification controller test (returning user)

**Files:**
- Create: `test/controllers/phone_number_verification_requests_controller_test.rb`

- [ ] **Step 1: Write the tests**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class PhoneNumberVerificationRequestsControllerTest < ActionDispatch::IntegrationTest
  test "create starts a verification request" do
    assert_difference -> { PhoneNumberVerificationRequest.count }, 1 do
      with_turnstile(:always_passes) do
        post phone_number_verification_requests_path,
          params: {
            phone_number_verification_request: { phone_number: "+14165550000" },
            "cf-turnstile-response": "dummy",
          },
          as: :turbo_stream
      end
    end

    assert_response :success
  end

  test "verifying a returning user's code signs them in" do
    user = users(:bob)
    request = with_turnstile(:always_passes) do
      post phone_number_verification_requests_path,
        params: {
          phone_number_verification_request: { phone_number: user.phone_number },
          "cf-turnstile-response": "dummy",
        },
        as: :turbo_stream
      PhoneNumberVerificationRequest.order(:created_at).last
    end

    post verify_phone_number_verification_request_path(request),
      params: {
        phone_number_verification_request: { verification_code: request.verification_code },
        user: { time_zone_name: "America/New_York" },
      },
      as: :turbo_stream

    assert_redirected_to home_url
    assert cookies[:session_id].present?
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/controllers/phone_number_verification_requests_controller_test.rb`
Expected: PASS (2 tests). Requires network access to Cloudflare (test keys).

- [ ] **Step 3: Commit**

```bash
git add test/controllers/phone_number_verification_requests_controller_test.rb
git commit -m "test: cover phone verification request and returning-user sign in"
```

---

### Task 17: Accounts controller test (new-user onboarding)

**Files:**
- Create: `test/controllers/accounts_controller_test.rb`

- [ ] **Step 1: Write the test**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "a new phone number completes onboarding into a new account" do
    phone_number = "+14165551234"

    # Request + verify a code for a phone with no existing user.
    request = with_turnstile(:always_passes) do
      post phone_number_verification_requests_path,
        params: {
          phone_number_verification_request: { phone_number: },
          "cf-turnstile-response": "dummy",
        },
        as: :turbo_stream
      PhoneNumberVerificationRequest.order(:created_at).last
    end

    post verify_phone_number_verification_request_path(request),
      params: {
        phone_number_verification_request: { verification_code: request.verification_code },
      },
      as: :turbo_stream
    assert_redirected_to new_account_path

    # Create the account.
    assert_difference -> { User.count }, 1 do
      post account_path, params: { user: { name: "Casey", time_zone_name: "America/New_York" } }
    end

    user = User.find_by!(phone_number:)
    assert_equal "Casey", user.name
    assert_redirected_to home_url
    assert cookies[:session_id].present?
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/controllers/accounts_controller_test.rb`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add test/controllers/accounts_controller_test.rb
git commit -m "test: cover new-user onboarding into an account"
```

---

### Task 18: Worlds controller test

**Files:**
- Create: `test/controllers/worlds_controller_test.rb`

- [ ] **Step 1: Write the tests**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldsControllerTest < ActionDispatch::IntegrationTest
  setup { @owner = users(:bob) }

  test "owner creates a world" do
    sign_in_as(@owner)

    assert_difference -> { @owner.owned_worlds.count }, 1 do
      post worlds_path, params: {
        world: {
          name: "Fresh World",
          blurb: "a new place",
          icon: fixture_file_upload("world_icon.png", "image/png"),
        },
      }
    end

    world = @owner.owned_worlds.find_by!(name: "Fresh World")
    assert_redirected_to world_path(world)
  end

  test "owner views their world feed" do
    world = create_world(owner: @owner, name: "Feed World")
    post = create_post(world:, key_colors: nil, body: "first post")
    sign_in_as(@owner)

    get world_path(world)

    assert_response :success
    assert_includes response.body, "first post"
  end

  test "owner updates a world" do
    world = create_world(owner: @owner, name: "Editable World")
    sign_in_as(@owner)

    patch world_path(world), params: { world: { blurb: "updated blurb" } }

    assert_redirected_to world_path(world)
    assert_equal "updated blurb", world.reload.blurb
  end

  test "a member leaves a world" do
    world = create_world(owner: @owner, name: "Leavable World")
    member = users(:sue)
    grant_key(world:, recipient: member)
    sign_in_as(member)

    assert_difference -> { world.keys.where(recipient: member).count }, -1 do
      post leave_world_path(world)
    end

    assert_redirected_to home_path
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/controllers/worlds_controller_test.rb`
Expected: PASS (4 tests).

- [ ] **Step 3: Commit**

```bash
git add test/controllers/worlds_controller_test.rb
git commit -m "test: cover world create, view, update, and leave flows"
```

---

### Task 19: Posts controller test

**Files:**
- Create: `test/controllers/posts_controller_test.rb`

- [ ] **Step 1: Write the tests**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:bob)
    @world = create_world(owner: @owner, name: "Posting World")
  end

  test "owner creates a key-scoped post" do
    sign_in_as(@owner)

    assert_difference -> { @world.posts.count }, 1 do
      post world_posts_path(@world), params: {
        post: { title: "Hello", body: "body text", key_colors: [ "blue" ] },
      }
    end

    created = @world.posts.order(:created_at).last
    assert_equal [ "blue" ], created.key_colors
    assert_redirected_to world_path(@world)
  end

  test "owner edits a post" do
    post = create_post(world: @world, key_colors: nil, body: "original")
    sign_in_as(@owner)

    patch post_path(post), params: { post: { title: "Edited", body: "original" } }

    assert_redirected_to world_path(@world)
    assert_equal "Edited", post.reload.title
  end

  test "owner deletes a post" do
    post = create_post(world: @world, key_colors: nil)
    sign_in_as(@owner)

    assert_difference -> { @world.posts.count }, -1 do
      delete post_path(post)
    end

    assert_redirected_to world_path(@world)
  end

  test "owner views the world feed via turbo frame" do
    create_post(world: @world, key_colors: nil, body: "visible post")
    sign_in_as(@owner)

    get world_posts_path(@world), headers: { "Turbo-Frame" => "posts" }

    assert_response :success
    assert_includes response.body, "visible post"
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/controllers/posts_controller_test.rb`
Expected: PASS (4 tests). If the turbo-frame test fails on the header, confirm the frame id with `grep -rn "turbo_frame" app/views app/components | head` and adjust the `Turbo-Frame` value.

- [ ] **Step 3: Commit**

```bash
git add test/controllers/posts_controller_test.rb
git commit -m "test: cover post create, edit, delete, and feed flows"
```

---

### Task 20: Reactions controller test

**Files:**
- Create: `test/controllers/reactions_controller_test.rb`

- [ ] **Step 1: Write the tests**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class ReactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:bob)
    @friend = users(:sue)
    @world = create_world(owner: @owner, name: "Reacting World")
    grant_key(world: @world, recipient: @friend, color: :blue)
    @post = create_post(world: @world, key_colors: nil)
  end

  test "a member adds a reaction" do
    sign_in_as(@friend)

    assert_difference -> { @post.reactions.count }, 1 do
      post post_reactions_path(@post), params: { reaction: { emoji: "🔥" } }
    end

    assert_redirected_to [ @post, :reactions ]
  end

  test "a member removes their reaction" do
    reaction = @post.reactions.create!(reactor: @friend, emoji: "🔥")
    sign_in_as(@friend)

    assert_difference -> { @post.reactions.count }, -1 do
      delete reaction_path(reaction)
    end

    assert_redirected_to [ @post, :reactions ]
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/controllers/reactions_controller_test.rb`
Expected: PASS (2 tests).

- [ ] **Step 3: Commit**

```bash
git add test/controllers/reactions_controller_test.rb
git commit -m "test: cover reaction add and remove flows"
```

---

### Task 21: Reply initiations controller test

**Files:**
- Create: `test/controllers/reply_initiations_controller_test.rb`

- [ ] **Step 1: Write the test**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class ReplyInitiationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:bob)
    @friend = users(:sue)
    @world = create_world(owner: @owner, name: "Replying World")
    grant_key(world: @world, recipient: @friend, color: :blue)
    @post = create_post(world: @world, key_colors: nil)
  end

  test "a member initiates a reply and gets a dm link" do
    sign_in_as(@friend)

    assert_difference -> { @post.reply_initiations.count }, 1 do
      post post_reply_initiations_path(@post),
        params: { reply_initiation: { platform: "sms" } },
        as: :turbo_stream
    end

    assert_response :success
    # The owner's phone number drives the sms reply link.
    assert_includes response.body, "sms:#{@owner.phone_number}"
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/controllers/reply_initiations_controller_test.rb`
Expected: PASS. If the `sms:` link is not present in the turbo_stream body, inspect the rendered `Components::ReplyInitiationForm` and assert on a stable element it actually renders.

- [ ] **Step 3: Commit**

```bash
git add test/controllers/reply_initiations_controller_test.rb
git commit -m "test: cover reply initiation flow"
```

---

### Task 22: World key grant accept test (the join flow)

**Files:**
- Create: `test/controllers/world_key_grants_controller_test.rb`

- [ ] **Step 1: Write the test**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeyGrantsControllerTest < ActionDispatch::IntegrationTest
  test "accepting a grant adds the recipient to the world" do
    owner = users(:bob)
    friend = users(:sue)
    world = create_world(owner:, name: "Joinable World")
    grant = world.key_grant(color: :blue)
    sign_in_as(friend)

    assert_difference -> { friend.world_keys.count }, 1 do
      post accept_world_key_grant_path(grant)
    end

    key = friend.world_keys.find_by!(world:)
    assert_equal "blue", key.color
    assert key.accepted_at.present?
    assert_redirected_to world_path(world, celebrate: true)
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test test/controllers/world_key_grants_controller_test.rb`
Expected: PASS. If the redirect assertion fails, print `response.location` to confirm the celebrate param format and adjust.

- [ ] **Step 3: Commit**

```bash
git add test/controllers/world_key_grants_controller_test.rb
git commit -m "test: cover joining a world by accepting a key grant"
```

---

### Task 23: World keys destroy test (owner revokes)

**Files:**
- Create: `test/controllers/world_keys_controller_test.rb`

- [ ] **Step 1: Confirm the policy**

Run: `cat app/policies/world_key_policy.rb`
Confirm `manage?`/`destroy?` allows the world owner. The test below assumes the owner may destroy a key; if the policy differs, sign in as the permitted user instead.

- [ ] **Step 2: Write the test**

```ruby
# typed: true
# frozen_string_literal: true

require "test_helper"

class WorldKeysControllerTest < ActionDispatch::IntegrationTest
  test "owner revokes a member's key" do
    owner = users(:bob)
    friend = users(:sue)
    world = create_world(owner:, name: "Revoking World")
    key = grant_key(world:, recipient: friend, color: :blue)
    sign_in_as(owner)

    assert_difference -> { world.keys.count }, -1 do
      delete world_key_path(key)
    end

    assert_redirected_to world_keys_path(world)
  end
end
```

- [ ] **Step 3: Run**

Run: `mise run test test/controllers/world_keys_controller_test.rb`
Expected: PASS. The destroy redirects to `[key.world!, :keys]` → `world_keys_path(world)` (route helper for the `:keys` resource; if the helper name differs, run `bin/rails routes -g keys` to find it).

- [ ] **Step 4: Commit**

```bash
git add test/controllers/world_keys_controller_test.rb
git commit -m "test: cover owner revoking a world key"
```

---

## Phase 5 — System Tests (Playwright)

> Only for behavior that JavaScript/Turbo Streams change. These boot a real browser and server. Keep them minimal.

### Task 24: Feed infinite-scroll system test

**Files:**
- Create: `test/system/feed_test.rb`

- [ ] **Step 1: Write the test**

```ruby
# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class FeedTest < ApplicationSystemTestCase
  test "scrolling the feed loads more posts via turbo stream" do
    owner = users(:bob)
    world = create_world(owner:, name: "Scroll World")
    7.times { |i| create_post(world:, key_colors: nil, body: "post number #{i}") }
    sign_in_as(owner)

    visit world_path(world)
    assert_text "post number 0"

    # The feed paginates at 5; later posts load on scroll.
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")

    assert_text "post number 6"
  end
end
```

- [ ] **Step 2: Run**

Run: `mise run test:system test/system/feed_test.rb`
Expected: PASS. System tests need `sign_in_as` to work over the browser session — if the cookie isn't honored, sign in through the UI instead (visit `new_session_path` and complete the flow) or set the session cookie via the driver. Adjust before continuing.

- [ ] **Step 3: Commit**

```bash
git add test/system/feed_test.rb
git commit -m "test: add infinite-scroll feed system test"
```

---

### Task 25: Live reaction system test

**Files:**
- Create: `test/system/reactions_test.rb`

- [ ] **Step 1: Write the test**

```ruby
# typed: true
# frozen_string_literal: true

require "application_system_test_case"

class ReactionsTest < ApplicationSystemTestCase
  test "adding a reaction updates the post without a full reload" do
    owner = users(:bob)
    friend = users(:sue)
    world = create_world(owner:, name: "Live React World")
    grant_key(world:, recipient: friend, color: :blue)
    create_post(world:, key_colors: nil, body: "react to me")
    sign_in_as(friend)

    visit world_path(world)
    assert_text "react to me"

    # Open the reaction control and pick an emoji. Selectors below are
    # placeholders — confirm against the rendered feed UI on first run.
    find("[data-reaction-add]", match: :first).click
    find("[data-emoji='🔥']").click

    assert_selector "[data-reaction='🔥']"
  end
end
```

- [ ] **Step 2: Run and fix selectors**

Run: `mise run test:system test/system/reactions_test.rb`
Expected: Likely FAIL first run on selectors. Inspect the feed's reaction component (`grep -rn "reaction" app/components | head`) and replace the placeholder selectors with real ones until PASS. This is the one task expected to need selector iteration.

- [ ] **Step 3: Commit**

```bash
git add test/system/reactions_test.rb
git commit -m "test: add live reaction system test"
```

---

## Phase 6 — Documentation

### Task 26: Write docs/testing.md

**Files:**
- Create: `docs/testing.md`

- [ ] **Step 1: Write the guide**

```markdown
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
- `create_card(world:, color: :blue)` — an unclaimed world card.
- `create_post(world:, key_colors: ["blue"], body:, **attrs)` — key-scoped post;
  `key_colors: nil` is visible to all keys.

## External dependencies

- **Cloudflare Turnstile** — `PhoneNumberVerificationRequestsController#create`
  verifies a Turnstile token in every environment. Tests wrap that request in
  `with_turnstile(:always_passes) { ... }` (see
  `test/test_helpers/turnstile_test_helper.rb`), which swaps in a client using
  Cloudflare's server-side test secret key (stored in `config/application.rb`).
  These keys make a real, deterministic call to Cloudflare, so those tests need
  network access.
- **SMS (Telnyx)** — not sent in test; `perform_deliveries` is production-only.
  Read `verification_code` straight off the request record.

## Next effort (not yet covered)

Passkit / Apple Wallet pass generation and push notification delivery are
intentionally untested for now — they need careful mocking of the Passkit and
APNs layers. Pick this up as a dedicated follow-up.
```

- [ ] **Step 2: Commit**

```bash
git add docs/testing.md
git commit -m "docs: add testing guide"
```

---

### Task 27: Reference the testing guide from AGENTS.md

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: Add a Testing section**

In `AGENTS.md`, after the `### Mise tasks` table (which already lists `test` and `test:system`), add a concise pointer section:

```markdown
### Testing

See `docs/testing.md` for the testing guide: the three test types and when to
use each, the `bob`/`sue` fixtures, the builder helpers
(`create_world` / `grant_key` / `create_card` / `create_post`), Active Storage
icon fixtures, and the Turnstile test-key setup. Passkit/push tests are
deferred — documented there as the next effort.
```

- [ ] **Step 2: Commit**

```bash
git add AGENTS.md
git commit -m "docs: reference testing guide from AGENTS.md"
```

---

### Task 28: Full suite green

- [ ] **Step 1: Run everything**

Run: `mise run test && mise run test:system`
Expected: all tests PASS.

- [ ] **Step 2: Run the linter**

Run: `mise run check`
Expected: no new offenses. Run `mise run fix` if needed, then re-run.

- [ ] **Step 3: Final commit (if fix made changes)**

```bash
git add -A
git commit -m "test: satisfy linter for new test suite"
```

---

## Self-Review Notes

- **Spec coverage:** tooling swap (T1), Turnstile config (T2), storage service (T3), system case (T4), fixtures rename + worlds + devices + AS (T5–T8), builders (T9), Turnstile helper (T10), model tests (T11–T14), integration flows (T15–T23), system tests (T24–T25), docs (T26–T27). The spec's "claim card → key granted" Passkit path is intentionally represented by the non-Passkit grant-accept join (T22), consistent with the deferred-Passkit decision.
- **Known iteration points (flagged inline):** turbo-frame id (T19), reply form rendering (T21), celebrate redirect format (T22), key route helper (T23), system-test auth + selectors (T24–T25). These are honestly marked because they depend on view/route details best confirmed by running.
- **Type consistency:** builder signatures in T9 match every call site in T11–T25 (`create_world(owner:, name:)`, `grant_key(world:, recipient:, color:, accepted:)`, `create_post(world:, key_colors:, body:)`).
