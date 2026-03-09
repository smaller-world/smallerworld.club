# Turnstile Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Protect `POST /login_requests` with Cloudflare Turnstile in both
existing login UIs so automated SMS code requests are rejected before Twilio
sends are attempted.

**Architecture:** Keep Turnstile verification inside
`LoginRequestsController#create` rather than introducing a shared service. The
React login form will use `react-turnstile`, the server-rendered login form will
use Cloudflare's standard widget script, and both will submit a Turnstile token
to the same controller action. The public site key will be exposed via a meta
tag, while the secret key remains server-only in
`Rails.application.credentials.turnstile.secret_key`.

**Tech Stack:** Rails, existing login/session flow, Cloudflare Turnstile,
`react-turnstile`, Vite, server-rendered ERB, current Playwright-backed system
test setup.

---

## Preconditions

- Work in a dedicated worktree before editing.
- Read these files first for local context:
  - `AGENTS.md`
  - `app/AGENTS.md`
  - `app/javascript/AGENTS.md`
  - `app/controllers/login_requests_controller.rb`
  - `app/components/LoginForm.tsx`
  - `app/views/sessions/new.html.erb`
  - `app/views/layouts/application.html.erb`
  - `app/views/layouts/inertia.html.erb`
  - `app/helpers/meta.ts`
- Use these credentials exactly:
  - `Rails.application.credentials.turnstile.site_key`
  - `Rails.application.credentials.turnstile.secret_key`
- This plan intentionally defers automated tests for now. Do not silently add
  them unless scope changes.

## Current-State Notes

- The expensive action is `LoginRequestsController#create` at
  `POST /login_requests`.
- The current rate limit is still valuable and should remain in place. Turnstile
  is an additional gate, not a replacement.
- There are two login UIs that can reach `POST /login_requests`:
  - React form: `app/components/LoginForm.tsx`
  - Server-rendered HTML form: `app/views/sessions/new.html.erb`
- `LoginRequest` sends SMS in a `before_create` callback, so Turnstile
  validation must happen before `LoginRequest.create(...)`.
- The site key should be exposed by meta tag rather than a new JSON endpoint.

## Latest Cloudflare Guidance To Follow

- Always perform server-side token validation through Siteverify. Client-side
  widget success is not sufficient.
- Treat Turnstile tokens as single-use and short-lived. Cloudflare currently
  documents them as expiring after 5 minutes and returning
  `timeout-or-duplicate` once consumed or reused.
- Send `remoteip` to Siteverify.
- Use a POST request to
  `https://challenges.cloudflare.com/turnstile/v0/siteverify`.
- Prefer the default managed widget mode unless there is a product reason to
  switch to invisible or non-interactive behavior.
- Reset the widget after any submission that consumes a token but does not
  complete the user flow.
- Keep the secret key server-only. Only the site key belongs in HTML/JS.

## Parameter Contract

- React submission:
  - Add `turnstile_response` inside the existing `login_request` payload.
- Server-rendered HTML submission:
  - Accept Cloudflare's default hidden field name, `cf-turnstile-response`.
- Controller behavior:
  - Normalize the token by reading
    `params.dig(:login_request, :turnstile_response)` first, then fall back to
    `params["cf-turnstile-response"]`.

## Error-Handling Contract

- Production:
  - Missing token, invalid token, expired token, duplicate token, hostname
    mismatch, wrong action, or Cloudflare verification failure must block
    request creation and therefore block Twilio send.
- JSON failure response:
  - Return `422 Unprocessable Content` with a clear retry message in
    `{ error: ... }` format so the existing `fetchRoute` error handling shows a
    toast.
- HTML failure response:
  - Re-render `sessions/new` with an alert or model error and preserve the
    entered phone number if practical.
- Non-production:
  - Use Cloudflare test keys or a narrow environment guard so local/manual work
    remains possible without production secrets.

## Recommended Manual Verification

- Verify the React login form blocks submit until the Turnstile widget is
  solved.
- Verify the server-rendered login form refuses requests with no token.
- Verify a successful token allows `LoginRequest.create` to proceed.
- Verify a second submit with the same token fails and requires widget reset.
- Verify the user sees a retryable error instead of a 500 when Cloudflare
  rejects the token.

### Task 1: Add the frontend dependency and document the no-test scope

**Files:**

- Modify: `package.json`
- Modify: `package-lock.json` or equivalent lockfile
- Modify: `docs/turnstile_integration_plan.md`

**Step 1: Add the dependency**

Add `react-turnstile` to the frontend dependencies using npm so the lockfile
updates consistently with the repo's package manager.

**Step 2: Reconcile local tooling**

Run:

```bash
npm install react-turnstile
npm ci
mise install
```

Expected:

- `react-turnstile` is present in `package.json`
- lockfile is updated
- local Node/runtime tooling matches the committed dependency graph

**Step 3: Confirm no automated tests are part of this pass**

Do not add request, controller, or system tests in this implementation. If
anything in the code naturally requires test-only toggles or helpers, keep them
minimal and clearly tied to future follow-up work.

**Step 4: Commit**

```bash
git add package.json package-lock.json docs/turnstile_integration_plan.md
git commit -m "Add Turnstile frontend dependency"
```

### Task 2: Expose the Turnstile site key through meta tags

**Files:**

- Modify: `app/views/layouts/application.html.erb`
- Modify: `app/views/layouts/inertia.html.erb`
- Reuse: `app/helpers/meta.ts`

**Step 1: Add meta tags to both layouts**

Render a meta tag in each layout, for example:

```erb
<% if Rails.application.credentials.turnstile&.site_key.present? %>
  <meta
    name="turnstile-site-key"
    content="<%= Rails.application.credentials.turnstile.site_key! %>"
  >
<% end %>
```

Use the exact same meta name in both layouts so the React and ERB flows read a
single public key source.

**Step 2: Keep failures obvious**

For production behavior, prefer failing loudly if the site key is required but
absent. The implementing agent can either:

- render the meta tag only when present and let the frontend disable submit with
  a missing-config error, or
- raise on missing credentials in production.

Recommendation:

- Render conditionally in the layout.
- Let each UI surface show a user-facing "login is temporarily unavailable"
  error if the meta key is missing.

**Step 3: Commit**

```bash
git add app/views/layouts/application.html.erb app/views/layouts/inertia.html.erb
git commit -m "Expose Turnstile site key via meta tags"
```

### Task 3: Add Turnstile to the React login form

**Files:**

- Modify: `app/components/LoginForm.tsx`
- Reuse: `app/helpers/meta.ts`

**Step 1: Read the site key from the meta tag**

Use `getMeta` or `requireMeta` from `app/helpers/meta.ts` to read
`turnstile-site-key`.

Implementation guidance:

- Avoid a new API route for the site key.
- Keep the site key lookup near the top of `LoginForm`.
- Treat a missing key as a hard block only for the "send login code" path.

**Step 2: Render the widget only during the login-code request step**

Add the `Turnstile` component from `react-turnstile` when `loginCodeRequested`
is `false`.

Recommended widget choices:

- Use the default managed widget mode.
- Set `siteKey` from the meta tag.
- Provide callbacks for `onSuccess`, `onExpire`, and `onError`.

Recommended local state:

```tsx
const [turnstileToken, setTurnstileToken] = useState<string | null>(null);
const turnstileRef = useRef<TurnstileInstance | null>(null);
```

Behavior:

- `onSuccess(token)` stores the token.
- `onExpire()` clears the token.
- `onError()` clears the token and surfaces a helpful message.

**Step 3: Gate submit behavior on token presence**

Update the existing submit readiness logic so the "send login code" button
requires:

- valid phone number
- non-empty Turnstile token

Do not require Turnstile for the later "sign in" step that submits the OTP code.

**Step 4: Send the token in the existing JSON request**

Extend the current payload:

```ts
data: {
  login_request: {
    phone_number: phoneNumber,
    turnstile_response: turnstileToken,
  },
}
```

**Step 5: Reset the widget after any consumed attempt**

Because tokens are single-use, call `turnstileRef.current?.reset()` and clear
local token state when:

- the request fails after Cloudflare validation
- the user taps the retry icon to change phone number
- the widget expires or errors

Recommendation:

- On successful login-code creation, keep the UI moving to the OTP state and
  remove or hide the widget entirely.

**Step 6: Commit**

```bash
git add app/components/LoginForm.tsx
git commit -m "Add Turnstile to React login form"
```

### Task 4: Add Turnstile to the server-rendered login form

**Files:**

- Modify: `app/views/sessions/new.html.erb`
- Optionally modify: `app/views/layouts/application.html.erb`

**Step 1: Load Cloudflare's widget script**

Add the official script to the page head when rendering the server-side login
form:

```erb
<%- content_for :head do -%>
  <script
    src="https://challenges.cloudflare.com/turnstile/v0/api.js"
    async
    defer
  ></script>
<%- end -%>
```

If `sessions/new.html.erb` already needs page-specific head content later, keep
all such content in a single `content_for :head` block.

**Step 2: Render the widget inside the form**

Insert the widget container before the submit button:

```erb
<div
  class="cf-turnstile self-center"
  data-sitekey="<%= Rails.application.credentials.turnstile.site_key! %>"
  data-action="login_request"
></div>
```

Notes:

- `data-action="login_request"` is useful because the controller can compare the
  returned `action` value from Siteverify.
- Use the existing Tailwind utility style conventions already present in the
  template.

**Step 3: Keep submit UX sensible**

Cloudflare examples often disable submit until a token exists. That is
acceptable here, but not strictly required if the backend remains authoritative.

Recommendation:

- Keep frontend logic minimal on the ERB form.
- Let the controller be the final authority.
- If you disable the submit button initially, make sure there is a path to
  re-enable it on token refresh.

**Step 4: Commit**

```bash
git add app/views/sessions/new.html.erb
git commit -m "Add Turnstile to server-rendered login form"
```

### Task 5: Enforce Turnstile in `LoginRequestsController#create`

**Files:**

- Modify: `app/controllers/login_requests_controller.rb`

**Step 1: Split token verification from request creation**

Before `LoginRequest.create(...)`, add controller-level verification flow:

1. Extract the Turnstile token from request params.
2. Reject immediately if the token is missing.
3. Verify the token with Cloudflare Siteverify.
4. Reject if Siteverify says `success: false`.
5. Optionally reject if `action != "login_request"` when action is present.
6. Optionally reject if `hostname` does not match the current request host in
   production.
7. Only then call `LoginRequest.create(...)`.

**Step 2: Add a small private verifier method inside the controller**

Stay with option 2 and keep the verification logic in this controller. A
reasonable shape is:

```ruby
def verify_turnstile!
  token = turnstile_token or return render_turnstile_error(...)

  response = Faraday.post(
    "https://challenges.cloudflare.com/turnstile/v0/siteverify",
    {
      secret: Rails.application.credentials.turnstile.secret_key!,
      response: token,
      remoteip: request.remote_ip,
      idempotency_key: request.request_id,
    },
  )

  body = JSON.parse(response.body)
  return if body["success"]

  render_turnstile_error(...)
end
```

Implementation notes:

- Prefer using `Faraday` because the app already uses it elsewhere.
- Keep parsing and response handling local to this controller.
- Avoid over-abstracting into a new service for this implementation.
- Use `request.request_id` as the `idempotency_key`; it is a good fit for
  Cloudflare's current API.

**Step 3: Add clear failure rendering helpers**

Create one helper that renders the user-facing failure in both formats:

- JSON:

```ruby
render json: { error: "Please complete the anti-bot check and try again." },
       status: :unprocessable_content
```

- HTML:
  - rebuild `@login_request` with the submitted phone number
  - set `flash.now[:alert]`
  - render `"sessions/new"` with `status: :unprocessable_content`

Use a second message for stale/duplicate tokens if you want sharper UX, for
example:

- `"Your verification expired. Please try again."`

**Step 4: Guard non-production behavior**

Pick one of these and document the exact choice in code comments:

- Preferred:
  - Use Cloudflare's documented test site key and secret in development/test
    credentials.
- Acceptable fallback:
  - Skip verification entirely outside production with an explicit guard.

Recommendation:

- Prefer test keys over a blanket bypass, because it keeps more of the real flow
  intact for manual verification.
- If time or environment constraints make that awkward, use a narrow
  `Rails.env.production?` guard now and leave a TODO for proper non-production
  verification.

**Step 5: Preserve existing rate limiting**

Do not remove or weaken the current `rate_limit` declaration. Turnstile and rate
limiting should coexist.

**Step 6: Commit**

```bash
git add app/controllers/login_requests_controller.rb
git commit -m "Verify Turnstile in login requests controller"
```

### Task 6: Align response handling and manual verification flow

**Files:**

- Modify: `app/components/LoginForm.tsx`
- Modify: `app/views/sessions/new.html.erb`
- Modify: `app/controllers/login_requests_controller.rb`

**Step 1: Make retry behavior explicit in React**

Ensure the React form handles these states cleanly:

- missing token
- widget error
- expired token
- backend rejection after a token was sent

At minimum:

- clear `turnstileToken`
- reset the widget
- keep the user on the phone-entry step

**Step 2: Make retry behavior explicit in HTML**

On HTML failure:

- keep the user on `/login`
- show a visible alert
- let them solve a fresh widget and resubmit

**Step 3: Run formatting and lightweight validation**

Run:

```bash
mise exec -- bin/fix
```

Expected:

- formatting, lint, and type checks for touched files pass

Do not add broader test work in this pass.

**Step 4: Manual smoke-check the two flows**

Verify manually in development:

1. React login form:
   - no Turnstile solved -> cannot complete the send-code flow
   - solved widget + valid phone -> reaches OTP step
   - repeat submit with stale token -> receives retryable error
2. Server-rendered login form:
   - widget renders
   - valid solve + submit -> reaches `/login/enter_code`
   - missing/invalid token -> stays on `/login` with clear alert

**Step 5: Commit**

```bash
git add app/components/LoginForm.tsx app/views/sessions/new.html.erb app/controllers/login_requests_controller.rb
git commit -m "Polish Turnstile login request UX"
```

## Explicit Non-Goals

- Do not add Turnstile to `POST /login` or OTP verification.
- Do not extract a reusable verification service in this pass.
- Do not remove the existing request rate limit.
- Do not add new backend abstractions unless implementation reveals a hard need.
- Do not add automated tests in this pass.

## Risks To Watch During Implementation

- Reusing an already-consumed token will produce `timeout-or-duplicate`; the
  React form must reset the widget after failed submissions.
- If the HTML form uses frontend-only gating without backend enforcement, the
  endpoint will still be vulnerable. The controller check is mandatory.
- Missing production credentials can lock out logins entirely. Decide whether
  missing config should fail loudly at boot, at render time, or at submit time.
- Hostname and action checks are useful, but implement them carefully so local
  development and alternate app hosts do not get blocked unintentionally.

## Source Notes

- Cloudflare Turnstile docs reviewed: latest public docs available on March
  9, 2026.
- Key references used for this plan:
  - Get started: `https://developers.cloudflare.com/turnstile/get-started/`
  - Server-side validation:
    `https://developers.cloudflare.com/turnstile/get-started/server-side-validation/`
  - Testing guidance:
    `https://developers.cloudflare.com/turnstile/troubleshooting/testing/`
  - `react-turnstile` docs via Context7: `/marsidev/react-turnstile`
