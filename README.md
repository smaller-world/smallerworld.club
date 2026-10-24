# smallerworld.club

_a place to share your feelings with friends._

## setup

> [!IMPORTANT]
>
> ensure you have [`mise`](https://mise.jdx.dev) installed on your machine.

local development uses podman for postgresql; rails and bun run on your host.
node.js and npm are not required. use `bunx --bun` when running javascript
package executables so their node shebangs run with bun. on macos, install
[podman desktop](https://podman-desktop.io/), complete its onboarding to install
the podman cli and create a machine. start the machine yourself with
`podman machine start` or through podman desktop before running setup or
development. on linux, install podman. ensure `podman info` succeeds before
continuing.

database data persists in the `smallerworld_postgres` podman volume across
container restarts. postgresql is available at `127.0.0.1:5432`.

```bash
# Make sure you have the required system dependencies:
brew install tmux libpq libvips

# Install dev tools and dependencies:
mise install

# Set up local dev environment:
mise setup

# Run the development server:
mise dev
```

## verification

run setup and all ci checks with rails' step-by-step output:

```bash
mise ci
```

ensure podman is running and playwright browsers are installed first
(`bunx --bun playwright install --only-shell`). ci starts postgres if needed and
stops it afterward only if ci started it. an already-running database is left
running. the checks use the same tasks as github actions and can also run
individually:

```bash
mise run audit:ruby
mise run audit:js
mise run check --all
mise run test:all -v
```

## TODOs

- [x] auto-detect timezone changes on any user-authenticated page

## feedback

- what happens if i add this card to my wallet? will it drain my credit card?
- the world icon on the key grants page looks too much like a button
- firefox focus apple wallet card DOES NOT WORK
- create your world icon looks fucking icon
- accept world key from card does not redirect to world
