# AGENTS.md

A Rails 8 app: Phlex views/components, Tailwind v4, Hotwire (+ a Hotwire Native
iOS shell), Sorbet, Action Policy, Minitest.

## Docs

- [CONTEXT.md](CONTEXT.md) — domain glossary. Read before naming anything.
- [docs/design.md](docs/design.md) — the visual language. Read before writing
  UI.
- [docs/testing.md](docs/testing.md) — test types, fixtures, builder helpers.
- [docs/adr/](docs/adr/) — decisions and why they were made.

## Commands

```sh
mise run test          # unit + integration
mise run test:system   # browser (Capybara + Playwright)
bin/tapioca dsl        # regenerate RBIs after schema/route changes
bundle exec srb tc     # typecheck
bundle exec rubocop -a # lint
```

Run `bin/tapioca dsl` before `srb tc` when routes or columns changed, or Sorbet
will report missing path helpers and attributes that do exist.

## Code style

Match the surrounding file. A few things that aren't obvious from reading it:

**Prefer binding a nilable in the condition over `T.must`.** It's a stricter
check and it narrows the type for Sorbet:

```ruby
# good
if @report.resolved? && (resolution = @report.resolution)
  resolution.text
end

# avoid
if @report.resolved?
  T.must(@report.resolution).text
end
```

**Beware `where.not` on a nullable column.** It compiles to `col != 'x'`, which
is `NULL` — and therefore false — for rows where the column is null, silently
dropping them. Match null explicitly: `where(col: [nil, "y"])`.

**Section headers** (`# == Associations ==`, `# == Helpers ==`) organize models,
controllers and components. Keep to the order already in the file.

**UI copy is all lowercase**, always. See [docs/design.md](docs/design.md).

## Admin

`/admin/*` is gated by `Admin::AdminController#verify_admin!`, which 404s rather
than 403s. Admins come from `credentials.admin_phone_numbers` via `User#admin?`.
Admin authorization lives in `Admin::`-namespaced policies and must be passed
explicitly: `authorize!(record, with: Admin::SomePolicy)`. Nothing in the app
links to the admin area.
