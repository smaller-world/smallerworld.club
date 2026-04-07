# The `usage` Field in mise Tasks

## Recommended: Using the Usage Field

The recommended way to define arguments is using the `usage` field:

```toml
[tasks.test]
usage = '''
arg "<file>" help="Test file to run" default="all"
flag "--format <format>" help="Output format" default="text"
flag "-v --verbose" help="Enable verbose output"
'''
run = 'cargo test ${usage_file?} --format ${usage_format?}'
```

**Key Points:**

- Arguments defined in the `usage` field are available as environment variables
  prefixed with `usage_`
- See the Task Arguments page for complete documentation

---

## Deprecation Notice: Tera Template Functions

> **Deprecated** - Removal in 2026.11.0
>
> Using Tera template functions (`arg()`, `option()`, `flag()`) in run scripts
> is deprecated and will be removed in mise 2026.11.0. Versions >= 2026.5.0 will
> show a deprecation warning.

### Why it's being removed:

- Template functions return empty strings during spec collection (two-pass
  parsing issue)
- Complex and unpredictable shell escaping rules
- Doesn't work consistently between TOML/file tasks

**Please migrate to using the `usage` field instead.** See the migration guide.

---

## Deprecated Tera Template Syntax (Not Recommended)

<details>
<summary>Click to see deprecated Tera template syntax</summary>

You can define arguments using Tera template functions (deprecated):

```toml
[tasks.test]
run = [
    'cargo test {{arg(name="cargo_test_args", var=true)}}',
    './scripts/test-e2e.sh {{option(name="e2e_args")}}',
]
```

Then running `mise run test foo bar` will pass `foo bar` to `cargo test`.
`mise run test --e2e-args baz` will pass `baz` to `./scripts/test-e2e.sh`.

### Positional Arguments

Defined in scripts with `{{arg()}}`. Used for positional arguments where the
order matters.

**Example:**

```toml
[tasks.test]
run = 'cargo test {{arg(name="file")}}'
# execute: mise run test my-test-file
# runs: cargo test my-test-file
```

**Options:**

- `i`: The index of the argument. This can be used to specify the order of
  arguments. Defaults to the order they're defined in the scripts.
- `name`: The name of the argument. This is used for help/error messages.
- `var`: If true, multiple arguments can be passed.
- `default`: The default value if the argument is not provided.

### Options

Defined in scripts with `{{option()}}`. Used for named arguments where the order
doesn't matter.

**Example:**

```toml
[tasks.test]
run = 'cargo test {{option(name="file")}}'
# execute: mise run test --file my-test-file
# runs: cargo test my-test-file
```

**Options:**

- `name`: The name of the argument. This is used for help/error messages.
- `var`: If true, multiple values can be passed.
- `default`: The default value if the option is not provided.

### Flags

Flags are like options except they don't take values. Defined in scripts with
`{{flag()}}`.

**Examples:**

```toml
[tasks.echo]
run = 'echo {{flag(name="myflag")}}'
# execute: mise run echo --myflag
# runs: echo true
```

```toml
[tasks.maybeClean]
run = '''
if [ '{{flag(name='clean')}}' = 'true' ]; then
  echo 'cleaning'
fi
'''
# execute: mise run maybeClean --clean
# runs: echo cleaning
```

**Options:**

- `name`: The name of the flag. This is used for help/error messages.

The value will be `true` if the flag is passed, and `false` otherwise.

</details>
