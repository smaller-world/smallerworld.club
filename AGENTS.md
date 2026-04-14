## Development Workflow

### Mise tasks (`mise.toml`)

Use `mise run <task>` for all common operations. Key tasks:

| Task                       | Purpose                                                   |
| -------------------------- | --------------------------------------------------------- |
| `mise run dev`             | Start Overmind dev server                                 |
| `mise run restart`         | Restart Overmind processes                                |
| `mise run setup`           | Initial project setup                                     |
| `mise run annotate`        | Update model schema annotations (`bin/annotaterb models`) |
| `mise run tapioca:dsl`     | Regenerate Sorbet RBI from Rails DSL                      |
| `mise run tapioca:gems`    | Regenerate Sorbet RBI from gems                           |
| `mise run test`            | Run Minitest (pass files or `-v` for verbose)             |
| `mise run test:system`     | Run system tests                                          |
| `mise run fix`             | Auto-fix linter/formatter issues via `hk fix`             |
| `mise run check`           | Run linter/formatter checks via `hk check`                |
| `mise run fly:ssh`         | SSH into production Fly app                               |
| `mise run fly:console`     | Open Rails console on production                          |
| `mise run fly:eval`        | Evaluate Ruby on production                               |
| `mise run attach <target>` | Attach to Overmind process (default: `web`)               |

### Post-migration workflow

After running `bin/rails db:migrate`, always re-annotate models and regenerate
Sorbet RBI:

```bash
mise run annotate       # bin/annotaterb models – updates schema annotations
mise run tapioca:dsl    # bin/tapioca dsl – regenerates Sorbet RBI files
```

### Tapioca DSL compilers

Custom compilers live in `sorbet/tapioca/compilers/`. When running
`mise run tapioca:dsl`, pass the **target constant name** (the class being
compiled), not the compiler class name:

```bash
# Correct — pass the constant whose RBI you want to regenerate:
mise run tapioca:dsl -- Components::Dialog

# Wrong — the compiler class is not a valid argument:
mise run tapioca:dsl -- Tapioca::Dsl::Compilers::PhlexCustomElements
```

Running without arguments regenerates all DSL RBIs.

### Branding assets

Never hand-craft brand SVGs. Always download from the official source:

- **Google**:
  `https://developers.google.com/static/identity/images/signin-assets.zip` —
  extract the G icon from `Web (mobile + desktop)/svg/` (full button SVGs; pull
  just the `<path>` elements from the clip group).
- **Apple**: Use official Apple Developer brand assets.

## Learned Workspace Facts

- The repository contains `app/components/shadcn/*.tsx` source files that may
  need editor-level TypeScript diagnostic suppression (for example via file
  associations or per-file ts-nocheck) while keeping TypeScript validation
  active elsewhere.
