# Handoff: Sign in with Google — Implementation

## Session Metadata
- Created: 2026-04-07 22:51:02
- Project: /Users/kai/Projects/smallerworld.club
- Branch: v2
- Session duration: ~1 hour (brainstorming + design + plan writing)

### Recent Commits (for context)
  - 45fd38a2 Add sign in with Apple
  - 7779d8e0 Remove happytown-specific code paths and libraries
  - cb5c2ecb Bootstrap project from happytown.life

## Handoff Chain

- **Continues from**: None (fresh start)
- **Supersedes**: None

## Current State Summary

We completed brainstorming, design spec, and implementation plan for adding "Sign in with Google" as a second OAuth provider alongside the existing "Sign in with Apple" flow. No code has been written yet — the plan is ready for execution. The user wants to execute using **subagent-driven development** with **no tests** for now. The plan has 10 tasks but test-related steps should be skipped.

## Codebase Understanding

### Architecture Overview

Rails 8.1 app using Phlex for views/components, Stimulus for JS, Tailwind CSS. Auth is hand-rolled (no Devise, no OmniAuth). The existing Apple sign-in uses the `apple_id` gem which wraps `OpenIDConnect::Client`. The app uses Sorbet type annotations (`# typed: true`, `sig` blocks) throughout. Components extend `Components::Base` (which extends `Phlex::HTML`). CSS uses `@layer components` with Tailwind `@apply` directives.

### Critical Files

| File | Purpose | Relevance |
|------|---------|-----------|
| `app/controllers/apple_oauth_sessions_controller.rb` | Existing Apple OAuth flow | Template for Google controller; needs refactoring to use `from_oauth_provider` |
| `app/models/user.rb` | User model with `apple_uid`, `apple_first_name`, `apple_last_name` (all NOT NULL) | Must be generalized to `oauth_*` columns |
| `app/components/sign_in_with_apple_button.rb` | Apple sign-in Phlex button component | Template for Google button component |
| `app/assets/stylesheets/sign_in_with_apple.css` | Apple button CSS | Template for Google button CSS (but Google has its own branding spec) |
| `app/views/sessions/new.rb` | Sign-in page | Must add Google button + Roboto font via `layout.with_head` |
| `app/components/layout.rb` | Layout component | Has `with_head` method (line 112-115) for injecting into `<head>` |
| `app/assets/stylesheets/application.css` | CSS manifest | Must add `@import "./sign_in_with_google.css"` |
| `test/fixtures/users.yml` | User fixtures | Must update column names from `apple_*` to `oauth_*` |
| `config/initializers/appleid.rb` | Apple JWKS cache setup | Pattern for Google initializer |

### Key Patterns Discovered

- **OAuth flow pattern**: State + nonce stored in encrypted cookies (`cookies.encrypted[:apple_oauth_state]`), verified in callback. State protects against CSRF, nonce protects against replay.
- **Component pattern**: Phlex components in `app/components/`, CSS in `app/assets/stylesheets/` with `@layer components`. SVG icons in `app/assets/images/<feature>/button_logo.svg` rendered via `inline_svg_tag`.
- **Button component pattern**: `form_with` wrapping a hidden `time_zone` field (populated by Stimulus controller `current-time-zone-input`) and a styled button with logo + text.
- **Credentials pattern**: Stored under namespace in Rails credentials (e.g., `appleid:` with `client_id`, `team_id`, etc.). Accessed via `Rails.application.credentials.appleid!`.
- **Sorbet**: All files use `# typed: true` and `sig` blocks for method signatures.
- **Enumerize**: Gem is in Gemfile (`gem "enumerize", "~> 2.8"`) but not yet used in any model.

## Work Completed

### Tasks Finished

- [x] Brainstorming — explored requirements, asked clarifying questions, got user answers
- [x] Design spec written at `docs/superpowers/specs/2026-04-07-sign-in-with-google-design.md`
- [x] Implementation plan written at `docs/superpowers/plans/2026-04-07-sign-in-with-google.md`
- [x] Downloaded Google sign-in brand assets to `/tmp/signin-assets.zip` (official SVGs)
- [x] Researched Google branding guidelines via Chrome DevTools

### Files Modified

| File | Changes | Rationale |
|------|---------|-----------|
| `docs/superpowers/specs/2026-04-07-sign-in-with-google-design.md` | Created | Design spec |
| `docs/superpowers/plans/2026-04-07-sign-in-with-google.md` | Created | Implementation plan |

### Decisions Made

| Decision | Options Considered | Rationale |
|----------|-------------------|-----------|
| Use `openid_connect` gem directly (no new gem) | `google-id-token` (dead), `googleauth` (overkill), `signet` (no OIDC), `oauth2` (no ID token), `openid_connect` | Already bundled via `apple_id`. Zero new dependencies. Same client class Apple uses internally. |
| Wrapper at `lib/google_sign_in.rb` | Inline in controller, separate gem, lib wrapper | Mirrors `apple_id` pattern. User preferred a name reflecting Google's official "Sign in with Google" branding. |
| Rename columns (A) not add+backfill (B) | In-place rename vs add new + backfill + drop old | Early-stage app, single migration is simpler. User chose (A). |
| GET callback (not POST) | POST like Apple, GET like Google default | Google's default redirect is GET. Avoids needing `skip_forgery_protection`. State param still provides CSRF protection. |
| Roboto font loaded only on sign-in page | Global load, page-specific | User specifically asked for `layout.with_head { ... }` to load only where needed. |
| No account linking | Auto-link by email, raise error | User wants to raise error and recommend original provider if email collision detected. |
| Sync picture download | Async background job, sync during callback | Images are ~96x96, sync is fine. User confirmed. |
| `User.from_oauth_provider(provider, uid:, first_name:, last_name:, picture_url:, **attributes)` | Various signatures discussed | User specified this exact signature. |

## Pending Work

## Immediate Next Steps

1. **Execute the implementation plan using subagent-driven development** — `docs/superpowers/plans/2026-04-07-sign-in-with-google.md`
2. **Skip all test-writing steps** — User explicitly said "let's not add any tests right now"
3. Start with Task 1 (migration), then proceed sequentially through Task 10

### Blockers/Open Questions

- [ ] Google Cloud Console credentials not yet created — Task 9 adds placeholders; real credentials needed before end-to-end testing
- [ ] The `openid_connect` gem's ID token handling for Google has not been tested — the `id_token.raw_attributes` access pattern for `given_name`/`family_name`/`picture` needs verification at runtime

### Deferred Items

- Tests — user wants to skip for now, add later
- Native Android Google Sign-In — user will implement custom Android code separately
- Account linking — deliberately not implemented; error raised instead

## Context for Resuming Agent

## Important Context

1. **Skip all test steps in the plan.** User explicitly said "let's not add any tests right now." Still update fixtures (Task 1 Step 4) since those are needed for existing tests to pass.
2. **The plan has 10 tasks.** Execute sequentially using subagent-driven development.
3. **No new gems needed.** `openid_connect` 2.3.1 is already in the bundle via `apple_id`. `enumerize` 2.8.1 is already in Gemfile but not yet used in any model.
4. **Google branding requirements**: The "G" logo must always be standard color (blue/green/yellow/red), never monochrome. Button uses Roboto Medium font. Light theme: white bg, `#747775` border, `#1F1F1F` text. Dark theme: `#131314` bg, `#8E918F` border, `#E3E3E3` text.
5. **The sign-in page needs Roboto font** loaded via `layout.with_head` block — NOT globally.

### Assumptions Made

- The `openid_connect` gem's `id_token.raw_attributes` hash will contain Google's standard OIDC claims (`given_name`, `family_name`, `picture`)
- Google's OIDC token endpoint will work with the `OpenIDConnect::Client` flow without additional configuration beyond the two endpoints
- The existing `inline_svg` gem will render the multi-colored Google "G" SVG correctly (it uses `fill` attributes on paths, not `currentColor`)

### Potential Gotchas

- **Apple SVG uses `fill="currentColor"`** — Google "G" SVG uses explicit color fills (`#4285F4`, `#34A853`, `#FBBC04`, `#E94235`). The button CSS must NOT override these fill colors.
- **The Apple controller's `callback` is POST** (with `skip_forgery_protection`), **Google's is GET** — different route verb.
- **Fixtures currently have `password_digest`** which doesn't exist in the schema — the fixtures need complete replacement, not just column renames.
- **The `remove_index` in the migration** references the old index name `index_users_on_apple_uid` — after `rename_column`, Rails may have already renamed it to `index_users_on_oauth_uid`. Use column-based removal (`remove_index :users, :oauth_uid`) not name-based.

## Environment State

### Tools/Services Used

- Rails 8.1.2 with Phlex components
- `openid_connect` gem 2.3.1 (via `apple_id` dependency)
- `enumerize` gem 2.8.1
- `inline_svg` gem 1.10.0
- Google Cloud Console needed for OAuth credentials (not yet set up)

### Active Processes

- None running

### Environment Variables

- Rails credentials contain `appleid:` namespace (client_id, team_id, key_id, private_key)
- Need to add `google_sign_in:` namespace (client_id, client_secret)

## Related Resources

- Design spec: `docs/superpowers/specs/2026-04-07-sign-in-with-google-design.md`
- Implementation plan: `docs/superpowers/plans/2026-04-07-sign-in-with-google.md`
- Google branding guidelines: https://developers.google.com/identity/branding-guidelines
- Google OIDC docs: https://developers.google.com/identity/openid-connect/openid-connect
- Downloaded brand assets (temporary): `/tmp/signin-assets.zip`

---

**Security Reminder**: Before finalizing, run `validate_handoff.py` to check for accidental secret exposure.
