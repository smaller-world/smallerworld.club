# RubyLLM Migration Plan

This document proposes how Happytown should migrate its WhatsApp bot from
`ActiveAgent` to `RubyLLM::Agent`.

Chosen direction:

- Destination architecture: Rails-backed `RubyLLM::Agent`
- Rollout strategy: staged coexistence (reply flow only, intro stays on
  ActiveAgent)

This is intentionally not a thin compatibility port. The plan is to adopt the
parts of RubyLLM that materially improve the system:

- first-class tool objects
- persisted chat/message/tool-call records
- better observability of agent execution

## Goals

- Replace `ActiveAgent` in the WhatsApp bot stack.
- Preserve current product behavior for intro and reply flows.
- Keep WhatsApp models as the source of truth for business events.
- Add RubyLLM-backed execution persistence for debugging and auditing.
- Remove the prompt-enforced `tools_used` JSON contract once RubyLLM persistence
  replaces it.

## Non-goals

- Re-architect WhatsApp ingestion, jobs, or domain models.
- Replace WhatsApp message storage with RubyLLM message storage.
- Generalize this into a multi-agent platform in the same migration.
- Rewrite prompt behavior beyond what is required to preserve parity.

## Target architecture

### 1. Application boundary stays app-owned

The app should continue to own:

- webhook ingestion
- WhatsApp group and message persistence
- async jobs
- business decisions like `requires_reply?`, `intro_sent?`, and
  `message_history_enabled?`

RubyLLM should own:

- agent configuration
- tool schema and execution records
- execution transcript persistence

The existing app-facing flows stay explicit:

- intro flow
- reply flow

They should remain visible in app code even if RubyLLM's runtime is chat-based.

### 2. Agent class is standalone — no base class abstraction

There is only one RubyLLM agent in this migration: `WhatsappGroupReplyAgent`.
The intro flow stays on `ActiveAgent` until the reply flow is proven.

`WhatsappGroupReplyAgent < RubyLLM::Agent` is the single new agent class. Shared
concerns like `TaggedLogging`, `UrlHelpers`, and `Pagy::Method` should be
extracted into modules included directly by the agent and/or tool classes where
needed.

The `ApplicationAgent` abstraction from `ActiveAgent` does not carry over.

### 3. Rails-backed persistence with one chat per run

Add RubyLLM's Rails persistence layer:

- `WhatsappGroupReplyAgentChat` using `acts_as_chat`
- `WhatsappGroupReplyAgentMessage` using `acts_as_message`
- `WhatsappGroupReplyAgentToolCall` using `acts_as_tool_call`

Those records represent agent execution state, not product truth.

**One chat per run, not per group.** Each reply invocation creates a new
`WhatsappGroupReplyAgentChat`. The chat is associated with the WhatsApp group
via a foreign key so audit queries like
`WhatsappGroupReplyAgentChat.where(whatsapp_group: group)` work naturally.

A long-lived chat per group is the wrong model because:

- the agent is stateless by design — context is rebuilt from WhatsApp messages
  each time
- RubyLLM replays persisted messages as conversation history, which would
  accumulate stale context across runs
- per-run chats still give a full audit trail, just queried by group

### 4. Prompt templates stay where they are

Keep the current prompt content in `app/views/agents/whatsapp_group`. Do not
move prompts to `app/prompts`.

The ERB templates render real Rails domain objects into the prompt context. That
rendering works today and does not need to change locations.

For tool return values that currently use `render_to_string` (e.g., message
formatting in `MessageLoadingTools`), replace with a plain Ruby helper. Tool
classes should not depend on Rails view rendering.

### 5. Tools become first-class classes with explicit context

Replace each concern-backed tool with a dedicated `RubyLLM::Tool` class:

- `SendMessageTool`
- `SendReplyTool`
- `ConfigureMessageHistoryTool`
- `SendMessageHistoryLinkTool`
- message loading/search tools

Each tool class should:

- declare parameters with RubyLLM's `param` DSL
- execute one business action
- return structured, compact results

**Context injection via `initialize`**, not ID passing:

```ruby
tools do
  [
    SendReplyTool.new(group: chat.whatsapp_group, message: chat.whatsapp_message),
    SearchMessagesTool.new(group: chat.whatsapp_group),
  ]
end
```

Tools receive their dependencies at instantiation time. This keeps them testable
and avoids hidden mutable state.

### 6. Lifecycle behavior uses explicit wrappers

Current behavior implemented via `before_action` and `around_generation` must be
re-homed explicitly:

- prompt context setup becomes explicit pre-run setup code
- typing-indicator behavior wraps the `chat.ask(...)` call with a thread and
  `ensure` block
- completion logging becomes post-run instrumentation

The typing indicator pattern stays as a thread with `ensure` — this is the
safest approach because `ensure` guarantees cleanup even when the generation
errors. RubyLLM's `on_end_message` callback does not fire on exceptions, so it
cannot replace `ensure`.

```ruby
def ask_with_typing_indicator(chat, ...)
  indicator_thread = Thread.new do
    loop do
      group.send_typing_indicator
      sleep(rand(0.8..2.0))
    end
  end
  chat.ask(...)
ensure
  indicator_thread&.kill
end
```

### 7. Response auditing changes

Delete the architectural dependency on the model returning:

```json
{
  "tools_used": [...]
}
```

After RubyLLM persistence is in place, tests and debugging should read actual
tool call records instead of parsing a prompt-enforced summary.

### 8. Provider configuration

RubyLLM has built-in OpenRouter support. Configuration:

```ruby
RubyLLM.configure do |config|
  config.openrouter_api_key = ENV['OPENROUTER_API_KEY']
end
```

```ruby
class WhatsappGroupReplyAgent < RubyLLM::Agent
  model "stepfun/step-3.5-flash:free", provider: :openrouter
  # ...
end
```

## Coexistence strategy

The existing `ActiveAgent` code stays **completely untouched** during
development. Only the reply flow is migrated:

- `WhatsappGroupReplyAgent` — the new RubyLLM agent class (reply only)
- New tool classes under `app/tools/` (or similar)
- Intro flow remains on `WhatsappGroupAgent` via `ActiveAgent`

This avoids any risk to the running system during development. Cutover happens
by swapping which agent the reply job calls, not by modifying the old code. The
intro flow migrates later in a separate effort once the reply flow is proven.

## Execution plan

### Phase 1: Install RubyLLM and add persistence models

- Add the `ruby_llm` gem.
- Generate Rails-backed chat/message/tool-call models.
- Wire associations from the chat model to `WhatsappGroup` and optionally to the
  triggering `WhatsappMessage`.
- Configure RubyLLM with the OpenRouter API key.
- Leave `ActiveAgent` fully intact.

Acceptance criteria:

- app boots with both frameworks present
- RubyLLM tables/models exist
- no existing WhatsApp behavior changes

### Phase 2: Build the new agent and tool classes

- Create `WhatsappGroupReplyAgent < RubyLLM::Agent`.
- Port reply-relevant tool definitions to `RubyLLM::Tool` classes with
  `initialize`-based context injection.
- Extract a plain Ruby helper for message formatting (replacing
  `render_to_string` usage in tools).
- Wire prompt rendering to reuse existing ERB templates.

Acceptance criteria:

- `WhatsappGroupReplyAgent` can execute the reply flow in isolation
- all reply-relevant tools exist as RubyLLM tool classes
- prompts render equivalent context

### Phase 3: Migrate reply flow and update tests

- Update reply tests to assert product behavior and persisted tool call records
  (replacing the `tools_used` JSON contract)
- Route the reply job/model entrypoint through `WhatsappGroupReplyAgent`
- Keep the old `ActiveAgent` reply path available until parity is proven
- Intro flow stays on `ActiveAgent` unchanged

Acceptance criteria:

- reply flow behaves identically from the user's perspective
- persisted RubyLLM tool calls match expected behavior
- reply tests no longer depend on `tools_used` JSON
- intro tests still pass unchanged

### Phase 4: Clean up reply migration

Once reply is fully routed through `WhatsappGroupReplyAgent` and verified:

- remove the reply action from `WhatsappGroupAgent`
- remove reply-specific tool concerns that are no longer used
- remove the `tools_used` JSON response contract from `ApplicationAgent` (if
  intro doesn't depend on it) or scope it to intro only

Acceptance criteria:

- reply is fully served by `WhatsappGroupReplyAgent`
- old reply code paths are removed
- intro still works via `ActiveAgent`
- targeted WhatsApp agent tests pass

### Phase 5: Migrate intro and remove ActiveAgent (future)

This phase is out of scope for the current migration. It happens after the reply
flow is stable in production.

- migrate `introduce_yourself` to a `WhatsappGroupIntroAgent` (or similar)
- remove `activeagent` and `openai` from `Gemfile`
- remove `config/active_agent.yml`
- remove `WhatsappGroupAgent`, `ApplicationAgent`, and associated views
- remove `ActiveAgent`-specific response typing and callback code

Acceptance criteria:

- no runtime references to `ActiveAgent` remain
- all WhatsApp agent tests pass
- docs reflect the new architecture

## Testing and verification

### Product behavior tests

Preserve these checks:

- intro sends the expected introduction behavior
- intro asks about enabling message history
- reply sends a reply when the message requires one
- reply can search messages
- reply can send a message-history link when appropriate
- reply still mentions the sender when needed

### Execution-state tests

Add RubyLLM-specific checks:

- a `WhatsappGroupReplyAgentChat` is created for each reply run
- the chat is associated with the correct WhatsApp group
- messages are persisted for each run
- tool calls are persisted for each tool execution
- the triggering WhatsApp message is associated when relevant

### Failure-path tests

Preserve current failure semantics:

- tool errors still surface clearly
- failed reply runs still behave correctly around retries/Sentry
- `reply_sent_at` and `intro_sent_at` are only updated on successful completion

### Verification commands

Before considering the migration complete, run the smallest relevant test subset
first, then widen:

```sh
mise test -i whatsapp_group_agent
mise test -i whatsapp_message
mise test -i whatsapp_group
```

If additional RubyLLM-specific model tests are added, include those in the
targeted verification pass before broader test runs.

## Resolved decisions

These decisions are fixed for this migration:

- Use Rails-backed RubyLLM, not a thin stateless port.
- Migrate reply flow only; intro stays on `ActiveAgent` until proven.
- `WhatsappGroupReplyAgent` inherits directly from `RubyLLM::Agent` — no base
  class.
- One chat per run, not per group.
- Keep prompt templates in `app/views/agents/whatsapp_group`.
- Tool context via `initialize`, not ID passing.
- Typing indicators use thread + `ensure`, not RubyLLM callbacks.
- Keep WhatsApp models as business truth.
- Use RubyLLM persistence as execution and audit state.
- Preserve intro and reply as explicit app-level flows.
- Remove `openai` gem alongside `activeagent` in the future cleanup phase.

## Risks and mitigations

### Risk: duplicated conversation state

RubyLLM persistence duplicates some information already represented in WhatsApp
tables.

Mitigation:

- define WhatsApp tables as business truth
- define RubyLLM tables as execution truth
- keep associations explicit to avoid ambiguity

### Risk: tool context becomes implicit or brittle

Moving from concern methods to tool classes can hide how records are loaded.

Mitigation:

- inject dependencies via tool `initialize`
- keep tool classes small and single-purpose

### Risk: callback behavior regresses

`ActiveAgent` callbacks currently handle typing indicators and logging.

Mitigation:

- move that behavior into explicit wrappers around `chat.ask(...)`
- test the user-visible effects and the logging path separately

### Risk: prompt parity drifts during migration

Prompt migrations often change behavior accidentally.

Mitigation:

- keep prompt templates in existing location
- change style only after parity is proven

### Risk: OpenRouter model not in RubyLLM registry

The free-tier model may not be in the built-in registry.

Mitigation:

- use `assume_model_exists: true` with explicit `provider: :openrouter`
- verify model access in Phase 1 before building the agent

## Reference: current file layout

These are the files involved in the current `ActiveAgent` implementation that
the implementation agent needs to be aware of:

### Agent and tools (ActiveAgent — reply-relevant files)

- `app/agents/application_agent.rb` — base class, holds
  `TOOL_CALL_INFO_RESPONSE_FORMAT`
- `app/agents/whatsapp_group_agent.rb` — the agent class with `reply` action
- `app/agents/whatsapp_group_agent/send_reply_tool.rb`
- `app/agents/whatsapp_group_agent/configure_message_history_tool.rb`
- `app/agents/whatsapp_group_agent/send_message_history_link_tool.rb`
- `app/agents/whatsapp_group_agent/message_loading_tools.rb`

### Prompt templates

- `app/views/agents/whatsapp_group/instructions.md.erb` — persona and group
  context
- `app/views/agents/whatsapp_group/reply.md.erb` — reply flow prompt with tool
  docs, recent message history, and the incoming message
- `app/views/agents/whatsapp_group/_message.md.erb` — partial for rendering a
  single WhatsApp message (used by both prompt templates and tool return values)

### Jobs and models

- `app/jobs/send_whatsapp_group_reply_job.rb` — calls `message.send_reply`
- `app/models/whatsapp_message.rb` — `send_reply` calls the agent
- `app/models/whatsapp_group.rb` — group model, owns `send_message`,
  `send_typing_indicator`, `message_history_enabled?`

### Tests

- `test/agents/whatsapp_group_agent_test.rb` — current tests parse `tools_used`
  JSON from the response; the reply tests need to be rewritten

### Helpers

- `app/helpers/whatsapp_group_agent_helper.rb` — provides
  `whatsapp_user_identity`, `message_body_with_inlined_mentions`,
  `quoted_message_body_with_inlined_mentions`, `quoted_participant_identity`,
  `humanize_message_history_window`
- `app/agents/whatsapp_group_agent/send_message_tool.rb` — defines
  `mentioned_jids_in` helper (used by `SendReplyTool` and
  `SendMessageHistoryLinkTool`); this tool itself is intro-only

### Key implementation notes

1. **Reply tool list** (from `WhatsappGroupAgent#reply`):
   - `SEND_REPLY_TOOL` — always
   - `CONFIGURE_MESSAGE_HISTORY_TOOL` — always
   - `MESSAGE_LOADING_TOOLS` (3 tools: load_before, load_after, search) — always
   - `SEND_MESSAGE_HISTORY_LINK_TOOL` — only when
     `group.message_history_enabled?`

2. **`tool_choice: "required"`** — the current agent forces tool use; the
   RubyLLM agent should preserve this behavior.

3. **`json_response_format_supported?`** — currently only returns true for
   `gpt-5-nano`. With RubyLLM, the `tools_used` JSON output contract is being
   removed entirely, so this check may not be needed. However, if the prompt
   still asks for JSON output, verify whether the model supports it.

4. **`render_to_string` in `MessageLoadingTools#load_group_messages`** — this
   renders the `_message.md.erb` partial to format messages returned by tools.
   The RubyLLM tool classes cannot use `render_to_string`. Extract the message
   formatting logic into a plain Ruby helper (e.g.,
   `WhatsappMessageFormatter.format(message)`) that both tools and prompts can
   use.

5. **`SendMessageHistoryLinkTool` calls `send_message`** — the current
   implementation delegates to the `SendMessageTool#send_message` method. In the
   new architecture, this tool needs to call `group.send_message` directly
   instead.

6. **`mentioned_jids_in`** — shared helper for resolving @-mentions in message
   text to WhatsApp LIDs. Currently defined in `SendMessageTool`. Extract to a
   shared module or model method for use by `SendReplyTool` and
   `SendMessageHistoryLinkTool`.

7. **`WhatsappMessaging` concern** (`app/concerns/whatsapp_messaging.rb`) — only
   provides `application_user_lid` (the bot's own WhatsApp LID from config).
   Include in the new agent or tools if needed.

8. **Typing indicator** — `WhatsappGroup#send_typing_indicator` is the method to
   call. The thread loop pattern is documented in section 6 of the target
   architecture.

9. **Instructions prompt** — `instructions.md.erb` is shared between intro and
   reply. The RubyLLM agent should use the same persona/context content. The
   template references `@group` and uses helpers from
   `WhatsappGroupAgentHelper`.

10. **The `<OUTPUT_FORMAT>` section in `reply.md.erb`** — this is the
    `tools_used` JSON contract. It should be **removed** from the new agent's
    prompt since RubyLLM persists tool calls natively.

## End state

At the end of this migration:

- the WhatsApp bot runs on `RubyLLM::Agent`
- chats, messages, and tool calls are persisted through RubyLLM's Rails
  integration
- app jobs and WhatsApp models still own workflow decisions
- `ActiveAgent` and `openai` gems are fully removed
- tool usage is observed through real execution records instead of prompt
  conventions
