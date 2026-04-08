# Sign in with Google — Design Spec

## Summary

Add "Sign in with Google" as a second OAuth provider alongside the existing "Sign in with Apple" flow. This involves:

1. Generalizing the User model from Apple-specific to multi-provider OAuth
2. Implementing a server-side OpenID Connect flow for Google
3. Adding a branded Google sign-in button per Google's branding guidelines
4. Downloading and storing the user's Google profile picture via ActiveStorage

## Gem Choice: `openid_connect` (already bundled)

No new gem dependency. The `apple_id` gem already depends on `openid_connect ~> 2.2` (v2.3.1 in lockfile). We use `OpenIDConnect::Client` directly for Google — the same client class that `AppleID::Client` wraps internally.

**Why not a dedicated wrapper?** Research found no actively maintained Google-specific OIDC wrapper gem (equivalent to `apple_id` for Apple). The closest options are OmniAuth strategies, which don't fit this codebase's hand-rolled approach. Using `openid_connect` directly keeps architectural symmetry with the Apple flow.

**Lib wrapper**: Create `lib/google_sign_in.rb` with a `GoogleSignIn::Client` class that wraps `OpenIDConnect::Client` with Google-specific configuration (endpoints, scopes). This mirrors the pattern of `AppleID::Client` wrapping `OpenIDConnect::Client`.

Google officially brands their product "Sign in with Google" (not "Google ID" or "Google Sign-In"). The lib name `google_sign_in` reflects this.

## Database Migration

Rename Apple-specific columns to generic OAuth columns. Single migration since this is early-stage:

```ruby
class GeneralizeOauthColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :apple_uid, :oauth_uid
    rename_column :users, :apple_first_name, :oauth_first_name
    rename_column :users, :apple_last_name, :oauth_last_name
    add_column :users, :oauth_provider, :string, null: false, default: "apple"

    # Remove the default after backfill
    change_column_default :users, :oauth_provider, from: "apple", to: nil
  end
end
```

All existing users get `oauth_provider: "apple"` via the default. The unique index on `apple_uid` (now `oauth_uid`) should become a composite unique index on `[oauth_provider, oauth_uid]` since UIDs are only unique within a provider.

```ruby
# In the same or follow-up migration:
remove_index :users, :oauth_uid  # was apple_uid
add_index :users, [:oauth_provider, :oauth_uid], unique: true
```

## User Model Changes

```ruby
class User < ApplicationRecord
  extend Enumerize

  enumerize :oauth_provider, in: %i[apple google]

  has_one_attached :oauth_picture

  def self.from_oauth_provider(provider, uid:, first_name:, last_name:, picture_url:, **attributes)
    # Find existing user by provider+uid, or initialize new one
    # Set oauth fields, download picture if URL provided
    # Caller is responsible for saving
  end
end
```

The `from_oauth_provider` method:
- Finds by `oauth_provider + oauth_uid`, or initializes a new record
- Sets `oauth_first_name`, `oauth_last_name`, `name` (from `first_name.truncate(30)` for new users)
- Downloads and attaches `oauth_picture` from `picture_url` (synchronous, images are ~96x96)
- Merges any additional `**attributes` (e.g., `email_address`, `time_zone_name`)
- Returns the user (unsaved) — caller saves and handles errors

### Account Collision

If a user tries to sign in with Google but an account with that email already exists via Apple (or vice versa), raise an error recommending the original provider. No auto-linking.

## Credentials Structure

```yaml
google_sign_in:
  client_id: "xxx.apps.googleusercontent.com"
  client_secret: "GOCSPX-xxx"
```

Obtained from Google Cloud Console > APIs & Services > Credentials > OAuth 2.0 Client IDs > Web application. Authorized redirect URI: `https://smallerworld.club/session/google_oauth/callback` (and localhost equivalent for dev).

## Routes

```ruby
resource :google_oauth_session, path: "/session/google_oauth", only: :create do
  get :callback  # Google uses GET redirect (not POST form_post like Apple)
end
```

## Controller: `GoogleOauthSessionsController`

Mirrors `AppleOauthSessionsController` structure:

### `create` action (POST /session/google_oauth)
1. Store `time_zone` from params in cookie
2. Generate and store `state` and `nonce` in encrypted cookies
3. Build `GoogleSignIn::Client` with credentials
4. Redirect to Google's authorization URL with `scope: "openid email profile"`

### `callback` action (GET /session/google_oauth/callback)
1. Verify `state` from encrypted cookie matches `params[:state]`
2. Delete `nonce` from encrypted cookie
3. Exchange `params[:code]` for tokens via `GoogleSignIn::Client`
4. Verify ID token nonce
5. Extract `sub`, `email`, `given_name`, `family_name`, `picture` from ID token
6. Check for email collision with different provider — raise error if found
7. Call `User.from_oauth_provider(:google, uid:, first_name:, last_name:, picture_url:, email_address:, time_zone_name:)`
8. Save user, start session, redirect

Key differences from Apple:
- Google uses `client_secret` (symmetric) instead of Apple's private key (asymmetric)
- Google returns user info in the ID token on every callback (Apple only on first sign-in)
- Callback is GET (not POST), so no `skip_forgery_protection` needed
- No need for `protect_against_forgery_with_state!` as a before_action on POST — state is verified manually in the GET callback

### Shared code with Apple controller

Both controllers share the same encrypted cookie pattern for state/nonce. Consider extracting to a concern (`OauthSessionCookies`) or leaving duplicated (only ~15 lines). The `AppleOauthSessionsController` should also be updated to use `User.from_oauth_provider(:apple, ...)` instead of inline user creation.

## `lib/google_sign_in.rb`

```ruby
module GoogleSignIn
  class Client
    AUTHORIZATION_ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth"
    TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token"

    def initialize(identifier:, secret:, redirect_uri:)
      @client = OpenIDConnect::Client.new(
        identifier:,
        secret:,
        redirect_uri:,
        authorization_endpoint: AUTHORIZATION_ENDPOINT,
        token_endpoint: TOKEN_ENDPOINT,
      )
    end

    def authorization_uri(scope:, state:, nonce:)
      @client.authorization_uri(scope:, state:, nonce:)
    end

    def authorization_code=(code)
      @client.authorization_code = code
    end

    def access_token!
      @client.access_token!
    end
  end
end
```

This is intentionally thin — just Google-specific endpoint configuration over `OpenIDConnect::Client`.

## UI: `SignInWithGoogleButton` Component

### Button styling (per Google branding guidelines)

**Light theme** (default):
- Fill: `#FFFFFF`, Stroke: `#747775` 1px, Font: `#1F1F1F`, Roboto Medium 14/20
- Hover: light gray background

**Dark theme** (via `dark:` prefix):
- Fill: `#131314`, Stroke: `#8E918F` 1px, Font: `#E3E3E3`

**Padding** (web spec):
- 12px left before logo, 10px gap after logo, 12px right after text

**Logo**: Google "G" in standard brand colors (blue #4285F4, green #34A853, yellow #FBBC04, red #E94235) on white background. The logo must always be the standard color version — no monochrome.

### Asset organization

```
app/assets/images/
  sign_in_with_apple/
    button_logo.svg        # (existing)
  sign_in_with_google/
    button_logo.svg        # Google "G" — just the icon paths, no button container
```

The `button_logo.svg` will contain just the Google "G" icon paths with brand colors — matching how the Apple SVG is just the Apple logo paths.

### Component structure

```ruby
class Components::SignInWithGoogleButton < Components::Base
  # Same pattern as SignInWithAppleButton:
  # form_with -> hidden time_zone field -> button with logo + text
end
```

### CSS: `sign_in_with_google.css`

```css
@layer components {
  .sign_in_with_google_button {
    /* Light theme per Google guidelines */
    /* Dark theme via dark: prefix */
    /* Roboto font */
    /* Same min-height (44px) as Apple button */
  }
}
```

### Sign-in page layout

Both buttons shown in the card content area, stacked vertically:

```ruby
card.content do
  Components::SignInWithGoogleButton(class: "w-full")
  Components::SignInWithAppleButton(class: "w-full")
end
```

## OAuth Picture Storage

When a user signs in with Google, the ID token includes a `picture` URL (typically `https://lh3.googleusercontent.com/...`, ~96x96px). We download it synchronously during the callback and attach via ActiveStorage:

```ruby
has_one_attached :oauth_picture

# In User.from_oauth_provider:
if picture_url.present?
  response = URI.open(picture_url) # small image, sync is fine
  user.oauth_picture.attach(
    io: response,
    filename: "oauth_picture.jpg",
    content_type: response.content_type,
  )
end
```

For Apple users, `oauth_picture` will remain unattached (Apple doesn't provide profile pictures).

## Refactoring the Apple Controller

Update `AppleOauthSessionsController#callback` to use `User.from_oauth_provider(:apple, ...)` instead of inline `User.new(apple_uid: ...)` / `User.find_by!(apple_uid: ...)`. This keeps both providers going through the same path.

## Testing

- Model tests for `User.from_oauth_provider` (both providers, new user, existing user, email collision)
- Controller tests for `GoogleOauthSessionsController` (redirect, callback success, state mismatch, nonce mismatch)
- System test for the button rendering
