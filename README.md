# smallerworld.club

_a place to share your feelings with friends._

## setup

> [!IMPORTANT]
>
> ensure you have [`mise`](https://mise.jdx.dev) installed on your machine.

local development uses podman for postgresql; rails and bun run on your host. on
macos, install [podman desktop](https://podman-desktop.io/), complete its
onboarding to install the podman cli and create a machine. start the machine
yourself with `podman machine start` or through podman desktop before running
setup or development. on linux, install podman. ensure `podman info` succeeds
before continuing.

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

## TODOs

- [x] auto-detect timezone changes on any user-authenticated page

## feedback

- what happens if i add this card to my wallet? will it drain my credit card?
- the world icon on the key grants page looks too much like a button
- firefox focus apple wallet card DOES NOT WORK
- create your world icon looks fucking icon
- accept world key from card does not redirect to world
