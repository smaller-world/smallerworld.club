# Handoff: Test Suite Foundation

**Created:** 2026-06-10  
**Branch:** `main` (uncommitted work)  
**Spec:** `docs/superpowers/specs/2026-06-10-test-suite-foundation-design.md`  
**Plan:** `docs/superpowers/plans/2026-06-10-test-suite-foundation.md`

## Current State Summary

Implementing the approved test suite foundation is **~90% complete**.

| Area | Status |
|------|--------|
| Tooling (Playwright, Turnstile keys, storage service) | Done |
| Fixtures (`bob`/`sue`, worlds, devices, Active Storage icons) | Done |
| Builder helpers (`WorldTestHelper`, `TurnstileTestHelper`) | Done |
| Model tests (4 files) | Done, passing |
| Integration tests (10 controller test files) | Done, passing |
| System tests (2 files) | Written, **both error on sign-in** |
| `docs/testing.md` + `AGENTS.md` pointer | Done |
| `mise run test` (34 tests) | **PASS** |
| `mise run test:system` (2 tests) | **FAIL** (sign-in helper) |
| `mise run check` | **FAIL** (AGENTS.md prettier) |
| Git commit | Not done (user did not request) |

## Immediate Next Steps (pick up here)

### 1. Fix system-test sign-in (blocker)

Both system tests fail in `SessionTestHelper#sign_in_as`:

```
NoMethodError: private method 'browser' called for Capybara::Playwright::Driver
  test/test_helpers/session_test_helper.rb:29
```

The Playwright driver path uses `page.driver.browser.context.add_cookies(...)`, which doesn't work with `capybara-playwright-driver`. Integration tests work fine (cookie jar path).

**Fix approach:** Research `Capybara::Playwright::Driver` cookie API (likely `page.driver.set_cookie` or Playwright context cookies after `visit`). Consider a separate `sign_in_via_browser(user)` helper used only from `ApplicationSystemTestCase`, keeping integration `sign_in_as` unchanged.

Files: `test/test_helpers/session_test_helper.rb`, `test/system/feed_test.rb`, `test/system/reactions_test.rb`

### 2. Run and iterate system tests

```bash
mise run test:system
```

- **Feed test:** scroll infinite-load; pagy limit is 5 posts; `Components::WorldNextPageControl` auto-clicks via intersection observer on scroll.
- **Reactions test:** selectors are placeholders (`button[aria-haspopup='dialog']`, `em-emoji-picker`). May need tuning after sign-in works. See `app/components/new_reaction_form.rb` (Dialog + emoji-mart).

### 3. Lint / format

```bash
mise run fix    # AGENTS.md prettier at minimum
mise run check
```

### 4. Final verification

```bash
mise run test && mise run test:system && mise run check
```

### 5. Commit (if user wants)

Logical commit split suggestion:
1. `test: foundation — tooling, fixtures, helpers, docs`
2. `test: model and integration coverage for core flows`
3. `fix: bugs found while adding tests` (post notifications, reply form, phone lookup)
4. `test: system tests for scroll and live reactions` (after green)

## What Was Implemented

### Config / tooling
- `Gemfile`: `selenium-webdriver` → `capybara-playwright-driver`
- `package.json` + `bun.lock`: `playwright` devDependency (Chromium installed via `bunx playwright install chromium`)
- `config/application.rb`: Turnstile test secret keys
- `config/storage.yml`: `test_fixtures` Active Storage service
- `test/application_system_test_case.rb`: Playwright driver

### Test data
- `test/fixtures/users.yml`: `bob`, `sue` (quoted E.164 phone numbers)
- `test/fixtures/worlds.yml`, `devices.yml`
- `test/fixtures/active_storage/{blobs,attachments}.yml` + `test/fixtures/files/world_icon.png`
- `test/test_helpers/world_test_helper.rb`, `turnstile_test_helper.rb`
- `test/test_helper.rb`: requires helpers; `SessionTestHelper` extended for system tests (broken for Playwright)

### Tests added
- `test/models/`: `world_test.rb`, `world_key_test.rb`, `post_test.rb`, `user_test.rb`
- `test/controllers/`: sessions (updated), phone verification, accounts, worlds, posts, reactions, reply_initiations, world_key_grants, world_keys
- `test/system/`: `feed_test.rb`, `reactions_test.rb`

### Docs
- `docs/testing.md` (full guide)
- `AGENTS.md` (pointer to testing guide)

### App fixes discovered during testing (review before commit)
These are real bugs/fixes, not test-only hacks:

1. **`app/models/post.rb`** — `create_notifications_for_world_key_recipients!` was calling `.where(color:)` on `User` relation; fixed to filter `world.keys.accepted` by color.
2. **`app/controllers/reply_initiations_controller.rb`** — `ReplyInitiationForm` requires `replied_post_ids:`; controller now passes `Set.new([post.id])`.
3. **`app/models/user.rb`** + **`phone_number_verification_requests_controller.rb`** — added `User.find_by_normalized_phone_number` so fixture users (stored without `+`) match verification requests (stored with `+`).

### Test adjustments made during debugging
- Phone verification tests need `headers: { "User-Agent" => "test" }` (NOT NULL column).
- `UserTest#dm_url` asserts use `@user.phone_number` (normalized format).
- `WorldsControllerTest` feed assertion fetches `world_posts_path` with `Turbo-Frame: posts` (posts load lazily in turbo frame, not in initial HTML).

## Out of Scope / Not Started
- Passkit / push notification tests (deferred per spec)
- Git commits / PR (user has not requested)
- Sorbet RBI regen for `User.find_by_normalized_phone_number` (may want `mise run tapioca:dsl -- User`)

## Unrelated Dirty Files (pre-existing, not part of test suite)

These were already modified before/during the session; likely separate work:
- `app/components/app_layout.rb`
- `app/components/existing_reaction_form.rb`
- `app/components/new_reaction_form.rb`

Change: `confetti_canvas_id_value` now uses `Rails.configuration.x.layout.confetti_canvas_id` instead of `Rails.configuration.confetti_canvas_id`. **Do not mix into test-suite commit without user confirmation.**

## Side Work (separate from test suite)

`.cursor/cli.json` — project-local CLI allowlist (`mise`, specific `bin/rails` commands, deny `mise:run fly*`). Global `~/.cursor/cli-config.json` also updated on user's machine (not in repo). Commit `.cursor/cli.json` if the team should share it.

## Commands Reference

```bash
mise run test                          # 34 integration+model tests — PASSING
mise run test test/system/feed_test.rb # single system test
mise run test:system                   # 2 system tests — FAILING
mise run check                         # prettier issue on AGENTS.md
mise run fix
```

## Success Criteria (definition of done)

- [ ] `mise run test` — all pass (currently **yes**)
- [ ] `mise run test:system` — all pass (currently **no**)
- [ ] `mise run check` — clean (currently **no**)
- [ ] User decides on commit/PR
