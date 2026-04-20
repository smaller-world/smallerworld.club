# Sign in with Google Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add "Sign in with Google" as a second OAuth provider, generalizing the existing Apple-only auth to support multiple providers.

**Architecture:** Server-side OpenID Connect flow using `openid_connect` gem (already bundled). Thin wrapper at `lib/google_sign_in.rb`. User model generalized from `apple_*` columns to `oauth_*` columns with `enumerize` for provider type. Google "G" button per branding guidelines.

**Tech Stack:** Rails 8.1, OpenIDConnect gem (2.3.1, already bundled), Enumerize, Phlex components, Minitest, ActiveStorage

---

## File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `db/migrate/*_generalize_oauth_columns.rb` | Rename apple_* to oauth_*, add oauth_provider |
| Modify | `app/models/user.rb` | Add enumerize, oauth_picture, `from_oauth_provider` |
| Modify | `test/fixtures/users.yml` | Update fixture columns |
| Modify | `test/models/user_test.rb` | Tests for `from_oauth_provider` |
| Create | `lib/google_sign_in.rb` | Thin wrapper over OpenIDConnect::Client |
| Create | `config/initializers/google_sign_in.rb` | JWKS cache config |
| Create | `app/controllers/google_oauth_sessions_controller.rb` | Google OAuth flow |
| Modify | `config/routes.rb` | Add google_oauth_session route |
| Modify | `app/controllers/apple_oauth_sessions_controller.rb` | Refactor to use `from_oauth_provider` |
| Create | `app/assets/images/sign_in_with_google/button_logo.svg` | Google "G" icon |
| Create | `app/components/sign_in_with_google_button.rb` | Google button component |
| Create | `app/assets/stylesheets/sign_in_with_google.css` | Button styles per branding guidelines |
| Modify | `app/assets/stylesheets/application.css` | Import sign_in_with_google.css |
| Modify | `app/views/sessions/new.rb` | Add Google button + Roboto font |
| Modify | `test/controllers/sessions_controller_test.rb` | Test both buttons render |

---

### Task 1: Database Migration — Generalize OAuth Columns

**Files:**
- Create: `db/migrate/TIMESTAMP_generalize_oauth_columns.rb`
- Modify: `test/fixtures/users.yml`

- [ ] **Step 1: Generate the migration**

Run:
```bash
bin/rails generate migration GeneralizeOauthColumns
```

- [ ] **Step 2: Write the migration**

Edit the generated file:

```ruby
# typed: true
# frozen_string_literal: true

class GeneralizeOauthColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :apple_uid, :oauth_uid
    rename_column :users, :apple_first_name, :oauth_first_name
    rename_column :users, :apple_last_name, :oauth_last_name
    add_column :users, :oauth_provider, :string, null: false, default: "apple"
    change_column_default :users, :oauth_provider, from: "apple", to: nil

    remove_index :users, :oauth_uid
    add_index :users, [ :oauth_provider, :oauth_uid ], unique: true
  end
end
```

- [ ] **Step 3: Run the migration**

Run:
```bash
bin/rails db:migrate
```
Expected: Migration completes successfully.

- [ ] **Step 4: Update fixtures**

Replace `test/fixtures/users.yml` with:

```yaml
one:
  oauth_provider: apple
  oauth_uid: apple_uid_one
  oauth_first_name: Test
  oauth_last_name: One
  name: Test
  email_address: one@example.com
  time_zone_name: America/New_York

two:
  oauth_provider: apple
  oauth_uid: apple_uid_two
  oauth_first_name: Test
  oauth_last_name: Two
  name: Test
  email_address: two@example.com
  time_zone_name: America/New_York
```

- [ ] **Step 5: Verify tests still pass**

Run:
```bash
bin/rails test
```
Expected: All tests pass (some may need minor fixes due to column renames — fix inline).

- [ ] **Step 6: Commit**

```bash
git add db/migrate/*_generalize_oauth_columns.rb db/schema.rb test/fixtures/users.yml
git commit -m "Generalize Apple-specific OAuth columns to multi-provider"
```

---

### Task 2: User Model — Enumerize + `from_oauth_provider`

**Files:**
- Modify: `app/models/user.rb`
- Modify: `test/models/user_test.rb`

- [ ] **Step 1: Write failing tests for `from_oauth_provider`**

Add to `test/models/user_test.rb`:

```ruby
test "from_oauth_provider creates new user" do
  user = User.from_oauth_provider(
    :google,
    uid: "google_123",
    first_name: "Jane",
    last_name: "Doe",
    picture_url: nil,
    email_address: "jane@example.com",
    time_zone_name: "America/New_York",
  )

  assert user.new_record?
  assert_equal "google", user.oauth_provider
  assert_equal "google_123", user.oauth_uid
  assert_equal "Jane", user.oauth_first_name
  assert_equal "Doe", user.oauth_last_name
  assert_equal "Jane", user.name
  assert_equal "jane@example.com", user.email_address
end

test "from_oauth_provider finds existing user by provider and uid" do
  existing = users(:one)

  user = User.from_oauth_provider(
    :apple,
    uid: existing.oauth_uid,
    first_name: "Updated",
    last_name: "Name",
    picture_url: nil,
  )

  assert_equal existing.id, user.id
  assert_equal "Updated", user.oauth_first_name
end

test "from_oauth_provider truncates name to 30 characters for new users" do
  user = User.from_oauth_provider(
    :google,
    uid: "google_456",
    first_name: "A" * 50,
    last_name: "Doe",
    picture_url: nil,
    email_address: "long@example.com",
    time_zone_name: "America/New_York",
  )

  assert_equal 30, user.name.length
end

test "from_oauth_provider does not overwrite name for existing users" do
  existing = users(:one)
  original_name = existing.name

  user = User.from_oauth_provider(
    :apple,
    uid: existing.oauth_uid,
    first_name: "Different",
    last_name: "Name",
    picture_url: nil,
  )

  assert_equal original_name, user.name
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```bash
bin/rails test test/models/user_test.rb
```
Expected: FAIL — `from_oauth_provider` is not defined.

- [ ] **Step 3: Update the User model**

Replace the model code in `app/models/user.rb`:

```ruby
# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id               :uuid             not null, primary key
#  email_address    :string           not null
#  name             :string           not null
#  oauth_first_name :string           not null
#  oauth_last_name  :string           not null
#  oauth_provider   :string           not null
#  oauth_uid        :string           not null
#  phone_number     :string
#  time_zone_name   :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email_address              (email_address) UNIQUE
#  index_users_on_oauth_provider_and_oauth_uid  (oauth_provider,oauth_uid) UNIQUE
#  index_users_on_phone_number               (phone_number)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class User < ApplicationRecord
  extend Enumerize
  include NormalizesPhoneNumber
  include HasTimeZone

  # == Enumerations ==

  enumerize :oauth_provider, in: %i[apple google]

  # == Attachments ==

  has_one_attached :oauth_picture

  # == Normalizations ==

  normalizes :email_address, with: ->(address) { address.strip.downcase }
  normalizes_phone_number :phone_number

  # == Validations ==

  validates :oauth_provider, :oauth_uid, presence: true
  validates :oauth_first_name, :oauth_last_name, presence: true
  validates :name, presence: true, length: { maximum: 30 }
  validates :email_address, presence: true, email: true
  validates :phone_number,
            phone: { possible: true, types: :mobile, extensions: false },
            allow_nil: true
  validates_time_zone_name

  # == Associations ==

  has_many :sessions, dependent: :destroy

  # == Class methods ==

  sig do
    params(
      provider: Symbol,
      uid: String,
      first_name: String,
      last_name: String,
      picture_url: T.nilable(String),
      attributes: T.untyped,
    ).returns(User)
  end
  def self.from_oauth_provider(provider, uid:, first_name:, last_name:, picture_url:, **attributes)
    user = find_or_initialize_by(oauth_provider: provider, oauth_uid: uid)
    user.oauth_first_name = first_name
    user.oauth_last_name = last_name
    user.name = first_name.truncate(30) if user.new_record?
    user.assign_attributes(attributes)
    if picture_url.present?
      response = URI.parse(picture_url).open
      user.oauth_picture.attach(
        io: response,
        filename: "oauth_picture.jpg",
        content_type: response.content_type,
      )
    end
    user
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
bin/rails test test/models/user_test.rb
```
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add app/models/user.rb test/models/user_test.rb
git commit -m "Add User.from_oauth_provider with enumerize and oauth_picture"
```

---

### Task 3: Refactor Apple Controller to Use `from_oauth_provider`

**Files:**
- Modify: `app/controllers/apple_oauth_sessions_controller.rb`

- [ ] **Step 1: Update the callback action**

In `app/controllers/apple_oauth_sessions_controller.rb`, replace the user-creation block in the `callback` action (lines 68-84) with:

```ruby
    session_time_zone = cookies.delete(:session_time_zone) or
      raise "Missing session time zone"

    first_name, last_name = if (user_data_json = params[:user])
      user_data = JSON.parse(user_data_json)
      name = user_data["name"] or raise "Missing name data"
      first = name["firstName"] or raise "Missing first name"
      last = name["lastName"] or raise "Missing last name"
      [ first, last ]
    else
      existing = User.find_by!(oauth_provider: :apple, oauth_uid: id_token.sub)
      [ existing.oauth_first_name, existing.oauth_last_name ]
    end

    user = User.from_oauth_provider(
      :apple,
      uid: id_token.sub,
      first_name:,
      last_name:,
      picture_url: nil,
      email_address: id_token.email,
      time_zone_name: session_time_zone,
    )
    user.save!
```

- [ ] **Step 2: Run all tests**

Run:
```bash
bin/rails test
```
Expected: All tests pass.

- [ ] **Step 3: Commit**

```bash
git add app/controllers/apple_oauth_sessions_controller.rb
git commit -m "Refactor Apple OAuth callback to use User.from_oauth_provider"
```

---

### Task 4: GoogleSignIn Library Wrapper

**Files:**
- Create: `lib/google_sign_in.rb`
- Create: `config/initializers/google_sign_in.rb`

- [ ] **Step 1: Create `lib/google_sign_in.rb`**

```ruby
# typed: true
# frozen_string_literal: true

require "openid_connect"

module GoogleSignIn
  class Client
    extend T::Sig

    AUTHORIZATION_ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth"
    TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token"
    JWKS_URI = "https://www.googleapis.com/oauth2/v3/certs"

    sig do
      params(
        identifier: String,
        secret: String,
        redirect_uri: String,
      ).void
    end
    def initialize(identifier:, secret:, redirect_uri:)
      @client = T.let(
        OpenIDConnect::Client.new(
          identifier:,
          secret:,
          redirect_uri:,
          authorization_endpoint: AUTHORIZATION_ENDPOINT,
          token_endpoint: TOKEN_ENDPOINT,
        ),
        OpenIDConnect::Client,
      )
    end

    sig do
      params(
        scope: T::Array[Symbol],
        state: String,
        nonce: String,
      ).returns(String)
    end
    def authorization_uri(scope:, state:, nonce:)
      @client.authorization_uri(scope:, state:, nonce:)
    end

    sig { params(code: String).void }
    def authorization_code=(code)
      @client.authorization_code = code
    end

    sig { returns(OpenIDConnect::AccessToken) }
    def access_token!
      @client.access_token!
    end

    sig { returns(OpenIDConnect::Discovery::Provider::Config::Response) }
    def self.discover!
      OpenIDConnect::Discovery::Provider::Config.discover!("https://accounts.google.com")
    end
  end
end
```

- [ ] **Step 2: Create `config/initializers/google_sign_in.rb`**

```ruby
# typed: true
# frozen_string_literal: true

OpenIDConnect::Discovery::Provider::Config.http_config do |config|
  config.response :json
end
```

Note: The `openid_connect` gem handles JWKS caching internally for Google (unlike Apple's `AppleID::JWKS.cache`). No additional caching config is needed.

- [ ] **Step 3: Verify the app boots**

Run:
```bash
bin/rails runner "puts GoogleSignIn::Client::AUTHORIZATION_ENDPOINT"
```
Expected: `https://accounts.google.com/o/oauth2/v2/auth`

- [ ] **Step 4: Commit**

```bash
git add lib/google_sign_in.rb config/initializers/google_sign_in.rb
git commit -m "Add GoogleSignIn::Client wrapper over OpenIDConnect"
```

---

### Task 5: Google OAuth Controller + Routes

**Files:**
- Create: `app/controllers/google_oauth_sessions_controller.rb`
- Modify: `config/routes.rb`

- [ ] **Step 1: Add the route**

In `config/routes.rb`, add after the `apple_oauth_session` resource:

```ruby
  resource :google_oauth_session, path: "/session/google_oauth", only: :create do
    get :callback
  end
```

- [ ] **Step 2: Create the controller**

Create `app/controllers/google_oauth_sessions_controller.rb`:

```ruby
# typed: true
# frozen_string_literal: true

class GoogleOauthSessionsController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access
  before_action :oauth_client!

  # == Actions ==

  # POST /session/google_oauth
  def create
    client = oauth_client!

    time_zone = params.expect(:time_zone)
    cookies[:session_time_zone] = {
      same_site: :none,
      secure: true,
      value: time_zone,
    }

    state = SecureRandom.hex(16)
    nonce = SecureRandom.hex(16)
    security_cookie_options = {
      same_site: :none,
      expires: 1.hour.from_now,
      secure: true,
    }
    cookies.encrypted[:google_oauth_state] = {
      **security_cookie_options,
      value: state,
    }
    cookies.encrypted[:google_oauth_nonce] = {
      **security_cookie_options,
      value: nonce,
    }

    authorization_url = client.authorization_uri(
      scope: [ :openid, :email, :profile ],
      state:,
      nonce:,
    )
    redirect_to(authorization_url, allow_other_host: true)
  end

  # GET /session/google_oauth/callback
  def callback
    expected_state = delete_encrypted_cookie(:google_oauth_state) or
      raise ActionController::InvalidAuthenticityToken, "Missing state"
    received_state = params.expect(:state)
    unless ActiveSupport::SecurityUtils.secure_compare(expected_state, received_state.to_s)
      raise ActionController::InvalidAuthenticityToken, "State mismatch"
    end

    nonce = delete_encrypted_cookie(:google_oauth_nonce) or
      raise ActionController::InvalidAuthenticityToken, "Missing nonce"

    client = oauth_client!
    client.authorization_code = params.expect(:code)
    token_response = client.access_token!
    id_token = token_response.id_token
    unless ActiveSupport::SecurityUtils.secure_compare(nonce, id_token.nonce)
      raise ActionController::InvalidAuthenticityToken, "Invalid nonce"
    end

    session_time_zone = cookies.delete(:session_time_zone) or
      raise "Missing session time zone"

    raw = id_token.raw_attributes
    email = raw["email"] || id_token.email
    given_name = raw["given_name"] or raise "Missing given_name in ID token"
    family_name = raw["family_name"] or raise "Missing family_name in ID token"
    picture_url = raw["picture"]

    if (existing = User.find_by(email_address: email)) && existing.oauth_provider != "google"
      raise "An account with this email already exists. Please sign in with #{existing.oauth_provider.capitalize}."
    end

    user = User.from_oauth_provider(
      :google,
      uid: id_token.sub,
      first_name: given_name,
      last_name: family_name,
      picture_url:,
      email_address: email,
      time_zone_name: session_time_zone,
    )
    user.save!

    start_new_session_for(user)
    redirect_to(after_authentication_url)
  rescue => error
    Rails.error.report(error)
    tag_logger do
      logger.error("Failed to sign in with Google: #{error}")
    end
    redirect_to(new_session_path, alert: error.message)
  end

  private

  # == Helpers ==

  sig { params(name: Symbol).returns(T.nilable(String)) }
  def delete_encrypted_cookie(name)
    value = cookies.encrypted[name]
    cookies.delete(name)
    value
  end

  sig { returns(GoogleSignIn::Client) }
  def oauth_client!
    credentials = Rails.application.credentials.google_sign_in!
    @oauth_client ||= GoogleSignIn::Client.new(
      identifier: credentials.client_id!,
      secret: credentials.client_secret!,
      redirect_uri: callback_google_oauth_session_url,
    )
  rescue => error
    raise "Failed to initialize Google OAuth client: #{error}"
  end
end
```

- [ ] **Step 3: Verify routes**

Run:
```bash
bin/rails routes | grep google
```
Expected output includes:
```
    google_oauth_session POST   /session/google_oauth(.:format)           google_oauth_sessions#create
callback_google_oauth_session GET    /session/google_oauth/callback(.:format) google_oauth_sessions#callback
```

- [ ] **Step 4: Commit**

```bash
git add app/controllers/google_oauth_sessions_controller.rb config/routes.rb
git commit -m "Add GoogleOauthSessionsController with server-side OIDC flow"
```

---

### Task 6: Google "G" Logo Asset

**Files:**
- Create: `app/assets/images/sign_in_with_google/button_logo.svg`

- [ ] **Step 1: Create the Google "G" SVG**

Create directory and file `app/assets/images/sign_in_with_google/button_logo.svg`:

```svg
<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
  <g clip-path="url(#clip0)">
    <path d="M19.6 10.2273C19.6 9.51818 19.5364 8.83636 19.4182 8.18182H10V12.05H15.3818C15.15 13.3 14.4455 14.3591 13.3864 15.0682V17.5773H16.6182C18.5091 15.8364 19.6 13.2727 19.6 10.2273Z" fill="#4285F4"/>
    <path d="M10 20C12.7 20 14.9636 19.1045 16.6181 17.5773L13.3863 15.0682C12.4909 15.6682 11.3454 16.0227 10 16.0227C7.39545 16.0227 5.19091 14.2636 4.40455 11.9H1.06364V14.4909C2.70909 17.7591 6.09091 20 10 20Z" fill="#34A853"/>
    <path d="M4.40455 11.9C4.20455 11.3 4.09091 10.6591 4.09091 10C4.09091 9.34091 4.20455 8.7 4.40455 8.1V5.50909H1.06364C0.386364 6.85909 0 8.38636 0 10C0 11.6136 0.386364 13.1409 1.06364 14.4909L4.40455 11.9Z" fill="#FBBC04"/>
    <path d="M10 3.97727C11.4681 3.97727 12.7863 4.48182 13.8227 5.47273L16.6909 2.60455C14.9591 0.990909 12.6954 0 10 0C6.09091 0 2.70909 2.24091 1.06364 5.50909L4.40455 8.1C5.19091 5.73636 7.39545 3.97727 10 3.97727Z" fill="#E94235"/>
  </g>
  <defs>
    <clipPath id="clip0">
      <rect width="20" height="20" fill="white"/>
    </clipPath>
  </defs>
</svg>
```

This is the standard-color Google "G" extracted from Google's official assets, with the viewBox shifted to 0,0 origin (the official download uses a 40x40 container with the 20x20 icon centered at offset 10,10 — we strip the container and white background since our button CSS handles that).

- [ ] **Step 2: Verify the SVG renders**

Run:
```bash
open app/assets/images/sign_in_with_google/button_logo.svg
```
Expected: Shows the multicolored Google "G" in the browser/viewer.

- [ ] **Step 3: Commit**

```bash
git add app/assets/images/sign_in_with_google/button_logo.svg
git commit -m "Add Google G logo SVG asset for sign-in button"
```

---

### Task 7: Sign In with Google Button Component + CSS

**Files:**
- Create: `app/components/sign_in_with_google_button.rb`
- Create: `app/assets/stylesheets/sign_in_with_google.css`
- Modify: `app/assets/stylesheets/application.css`

- [ ] **Step 1: Create the button component**

Create `app/components/sign_in_with_google_button.rb`:

```ruby
# typed: true
# frozen_string_literal: true

class Components::SignInWithGoogleButton < Components::Base
  include Phlex::Rails::Helpers::ButtonTo

  # == Configuration ==

  sig { params(form: T::Hash[Symbol, T.untyped], attributes: T.untyped).void }
  def initialize(form: {}, **attributes)
    @form_options = form
    super(**attributes)
  end

  # == Component ==

  def view_template
    form_with(
      url: google_oauth_session_path,
      method: :post,
      **mix(
        {
          data: {
            turbo: false,
          },
        },
        **@form_options,
      ),
    ) do |f|
      f.hidden_field(
        :time_zone,
        data: {
          controller: "current-time-zone-input",
        },
      )
      f.button(**mix({ class: "sign_in_with_google_button" }, **@attributes)) do
        span(class: "sign_in_with_google_button_icon") do
          inline_svg_tag(
            "sign_in_with_google/button_logo.svg",
            aria_hidden: true,
          )
        end
        span do
          "Sign in with Google"
        end
      end
    end
  end
end
```

- [ ] **Step 2: Create the CSS**

Create `app/assets/stylesheets/sign_in_with_google.css`:

```css
@layer components {
  .sign_in_with_google_button {
    @apply inline-flex items-center justify-center rounded-sm px-3;
    @apply bg-white hover:bg-neutral-50 dark:bg-[#131314] dark:hover:bg-[#1f1f20];
    @apply border border-[#747775] dark:border-[#8E918F];
    @apply text-sm font-medium text-[#1F1F1F] dark:text-[#E3E3E3];
    @apply cursor-pointer transition-colors;

    min-width: 130px;
    min-height: 44px;
    font-family: "Roboto", sans-serif;
    letter-spacing: 0.25px;
    gap: 10px;
    padding-left: 12px;
    padding-right: 12px;
  }

  .sign_in_with_google_button_icon {
    @apply flex items-center justify-center rounded-sm bg-white;
    width: 20px;
    height: 20px;
    flex-shrink: 0;

    svg {
      @apply h-5 w-5;
    }
  }
}
```

- [ ] **Step 3: Add CSS import to application.css**

Add this line at the end of `app/assets/stylesheets/application.css`:

```css
@import "./sign_in_with_google.css";
```

- [ ] **Step 4: Commit**

```bash
git add app/components/sign_in_with_google_button.rb app/assets/stylesheets/sign_in_with_google.css app/assets/stylesheets/application.css
git commit -m "Add SignInWithGoogleButton component with branded CSS"
```

---

### Task 8: Update Sign-In Page

**Files:**
- Modify: `app/views/sessions/new.rb`

- [ ] **Step 1: Add Google button and Roboto font to the sign-in page**

Update `app/views/sessions/new.rb`:

```ruby
# typed: true
# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(
      title: "sign in to smaller world",
      body_class: "bg-muted",
    ) do |layout|
      layout.with_head do
        link(
          rel: "preconnect",
          href: "https://fonts.googleapis.com",
        )
        link(
          rel: "preconnect",
          href: "https://fonts.gstatic.com",
          crossorigin: true,
        )
        link(
          rel: "stylesheet",
          href: "https://fonts.googleapis.com/css2?family=Roboto:wght@500&display=swap",
        )
      end
      main(class: "flex-1 flex flex-col justify-center pb-20") do
        layout.page_container(
          class: "flex flex-col items-center justify-center",
        ) do
          render_card
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def render_card
    Components::Card(class: "w-full max-w-xs") do |card|
      card.header(class: "flex flex-col items-center gap-y-3") do
        image_tag("logo.png", class: "size-10")
        card.title(class: "text-lg text-center") do
          if (site_name = Rails.configuration.x.site.name)
            plain("sign in to ")
            span(class: "font-semibold") { site_name }
          else
            plain("sign in")
          end
        end
      end
      card.content(class: "flex flex-col gap-3") do
        Components::SignInWithGoogleButton(class: "w-full")
        Components::SignInWithAppleButton(class: "w-full")
      end
    end
  end
end
```

- [ ] **Step 2: Run the session controller test to verify rendering**

Run:
```bash
bin/rails test test/controllers/sessions_controller_test.rb
```
Expected: The `test "new"` test passes (asserts 200 response, which means both buttons render without error).

- [ ] **Step 3: Commit**

```bash
git add app/views/sessions/new.rb
git commit -m "Add Google sign-in button to sign-in page with Roboto font"
```

---

### Task 9: Add Google Credentials Placeholder

**Files:**
- Modify: Rails credentials (via `bin/rails credentials:edit`)

- [ ] **Step 1: Add placeholder credentials**

Run `bin/rails credentials:edit` and add:

```yaml
google_sign_in:
  client_id: REPLACE_ME
  client_secret: REPLACE_ME
```

Note: Real credentials come from Google Cloud Console > APIs & Services > Credentials > OAuth 2.0 Client IDs > Web application. Set authorized redirect URI to `http://localhost:3000/session/google_oauth/callback` for dev.

- [ ] **Step 2: Commit**

```bash
git add config/credentials.yml.enc
git commit -m "Add google_sign_in credentials placeholder"
```

---

### Task 10: Update Schema Annotations

**Files:**
- Modify: `app/models/user.rb` (annotations already updated in Task 2)
- Modify: `test/models/user_test.rb` (annotations already updated in Task 2)

- [ ] **Step 1: Regenerate annotations if using annotate gem**

Run:
```bash
bin/rails annotate_models 2>/dev/null || echo "annotate not configured, skip"
```

If the annotate gem is present, verify the schema comments in `user.rb` and `user_test.rb` match the new column names. If not present, the manual annotations from Task 2 are sufficient.

- [ ] **Step 2: Run the full test suite**

Run:
```bash
bin/rails test
```
Expected: All tests pass.

- [ ] **Step 3: Final commit if any annotation changes**

```bash
git add -A && git diff --cached --quiet || git commit -m "Update schema annotations for OAuth columns"
```
