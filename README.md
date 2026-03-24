# happytown.life

_a home for third-space hosts and guests._

## setup

> [!IMPORTANT]
>
> ensure you have [`mise`](https://mise.jdx.dev) installed on your machine.

```bash
# Install dev tools and dependencies:
mise install

# Set up local dev environment and run dev server:
mise setup

# OR: Only run the development server:
mise dev
```

## TODOs

### whatsapp group agent

- [ ] **dynamic chat context:** initial chat context is 6 most recent messages.
      what if we dynamically loaded it according to if the bot recently replied,
      etc. i.e. if there's a current active "conversational" set of
      back-and-forths, extend chat context up to 20 messages.
- [ ] **opaque tool calls:** hide invocations of `send_message_history_link`
      from the bot when loading messages.
