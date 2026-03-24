# Agent Instructions

## Docs

- WhatsApp group agent: `docs/whatsapp_group_agent.md`
  - Use only when changing `app/agents/whatsapp_*.rb` or
    `app/models/whatsapp_*.rb`

## Tooling

- `mise install` - install devtools and dependencies
- `mise dev` - run dev server
- `mise test [-i <name>]` - run tests (excluding system tests)
- `mise test:system [-i <name>]` - run system tests
- `mise x -- ...` (run ad-hoc command with tools installed by mise)
  - `mise x -- bunx ...` (run ad-hoc command from NPM)
  - `mise x -- bundle e ...` (run ad-hoc command from Rubygems)

## Commit Attribution

- AI commits MUST include attribute, e.g.

```text
Co-Authored-By: (model)
```

## Sorbet / Tapioca

- After adding or updating a gem, run `mise x -- bin/tapioca gems` to regenerate
  RBI files
- After adding or changing a model, run `mise x -- bin/tapioca dsl <ModelName>`
  to regenerate DSL RBI files
- Never restore RBI files from git — always regenerate them

## Key Conventions

- Search with `rg` / `rg --files`
- Keep edits scoped; do not revert unrelated local changes
- Prefer project scripts in `bin/` and `mise run ...` when available (see
  available tasks with `mise tasks`)
- Run targeted verification before completion: `mise test` (or relevant subset)
- Use `mise x -- bin/rails generate [model/migration]` to generate stubs for new
  models and migrations, then edit the generated files (do not write from
  scratch)
