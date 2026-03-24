# ActiveAgents vs RubyLLM

This document compares the current `ActiveAgent` implementation in Happytown's
WhatsApp bot with the `RubyLLM::Agent` architecture. It is grounded in the code
that exists today and in the official framework docs:

- ActiveAgents: <https://docs.activeagents.ai/>
- RubyLLM Agents: <https://rubyllm.com/agents/>
- RubyLLM Rails integration: <https://rubyllm.com/rails/>

## Current ActiveAgent architecture in this app

Happytown currently uses `ActiveAgent` in one place: the WhatsApp group agent
stack.

### Entrypoints and orchestration

- [`app/agents/application_agent.rb`](/Users/kai/Projects/happytown.life/app/agents/application_agent.rb)
  defines `ApplicationAgent < ActiveAgent::Base`.
- [`app/agents/whatsapp_group_agent.rb`](/Users/kai/Projects/happytown.life/app/agents/whatsapp_group_agent.rb)
  defines the concrete agent.
- [`app/models/whatsapp_group.rb`](/Users/kai/Projects/happytown.life/app/models/whatsapp_group.rb)
  and
  [`app/models/whatsapp_message.rb`](/Users/kai/Projects/happytown.life/app/models/whatsapp_message.rb)
  are the app-facing entrypoints. They call:
  - `WhatsappGroupAgent.with(group:).introduce_yourself.generate_now`
  - `WhatsappGroupAgent.with(group:, message:).reply.generate_now`
- [`app/jobs/send_whatsapp_group_intro_job.rb`](/Users/kai/Projects/happytown.life/app/jobs/send_whatsapp_group_intro_job.rb)
  and
  [`app/jobs/send_whatsapp_group_reply_job.rb`](/Users/kai/Projects/happytown.life/app/jobs/send_whatsapp_group_reply_job.rb)
  own the async execution boundary.

The important point is that the app owns the workflow. `ActiveAgent` is the LLM
execution layer inside a job-triggered Rails workflow, not the system that owns
message ingestion, persistence, or business state.

### Action-oriented agent class

`WhatsappGroupAgent` is organized like a small Rails controller:

- `generate_with` configures provider, model, temperature, and instructions.
- Public instance methods are actions:
  - `introduce_yourself`
  - `reply`
- Each action builds a tool list, chooses response formatting, then calls
  `prompt`.
- Shared context is prepared with callbacks like `before_action`.

This matches the core `ActiveAgent` mental model: agent class as controller,
action method as endpoint, prompt template as view.

### Prompt rendering

Prompt content lives in ERB templates under
[`app/views/agents/whatsapp_group`](/Users/kai/Projects/happytown.life/app/views/agents/whatsapp_group):

- `instructions.md.erb`
- `introduce_yourself.md.erb`
- `reply.md.erb`
- `_message.md.erb`

The templates render real Rails domain objects into the prompt:

- group metadata
- recent message history
- the incoming WhatsApp message
- tool instructions and output contract

This is a strong fit for `ActiveAgent`, because ERB view rendering is a
first-class part of the framework's architecture.

### Tool system

Tools are currently modularized as concerns in
[`app/agents/whatsapp_group_agent`](/Users/kai/Projects/happytown.life/app/agents/whatsapp_group_agent):

- `send_message_tool.rb`
- `send_reply_tool.rb`
- `configure_message_history_tool.rb`
- `send_message_history_link_tool.rb`
- `message_loading_tools.rb`

Each tool module contains:

- a tool descriptor constant, which is a manual JSON schema hash
- an instance method that performs the tool action

This gives the agent class one combined execution surface, but the framework
does not give us a first-class tool object abstraction. The schema definition,
runtime behavior, and dependency access all live together inside the agent
instance.

### Lifecycle hooks and logging

`WhatsappGroupAgent` currently uses framework callbacks to wrap generation:

- `before_action :set_instructions_context`
- `around_generation :send_typing_indicator_while`
- `around_generation :log_completion_after`

These hooks are doing real application work:

- injecting prompt context
- sending WhatsApp typing indicators while the model runs
- logging and validating the model's final JSON output

### Response contract

The current implementation does not rely on framework-native persisted tool call
records. Instead, the prompt requires the model to return JSON like:

```json
{
  "tools_used": ["send_reply", "search_messages"]
}
```

The tests then parse this manual JSON contract in
[`test/agents/whatsapp_group_agent_test.rb`](/Users/kai/Projects/happytown.life/test/agents/whatsapp_group_agent_test.rb).

That is an important architectural signal: today, tool-call auditing is
prompt-driven and application-enforced, not framework-backed.

### Persistence model

There is no `ActiveAgent` persistence layer in this app.

The app persists:

- WhatsApp groups
- WhatsApp messages
- WhatsApp users
- app-level workflow timestamps like `intro_sent_at` and `reply_sent_at`

The app does not persist:

- LLM chats
- assistant messages as first-class records
- tool call records
- generation transcripts owned by the framework

`ActiveAgent` is therefore operating as a stateless generation layer over
app-owned business data.

## RubyLLM architecture

RubyLLM uses a different center of gravity.

### Agent as reusable chat configuration

`RubyLLM::Agent` is primarily a reusable package of:

- instructions
- model/provider configuration
- tools
- runtime callbacks

Instead of action methods that naturally map to Rails views, the default model
is a configured agent that participates in chat runs.

This is still compatible with Rails, but the architecture is more chat-centric
than action-centric.

### First-class tool objects

RubyLLM gives tools a dedicated class abstraction:

- tool classes inherit from `RubyLLM::Tool`
- parameters are declared with `param`
- execution happens in `execute`
- tool lifecycle can be observed with callbacks such as `on_tool_call` and
  `on_tool_result`

This separates schema declaration from agent class structure more cleanly than
the current concern-based `ActiveAgent` pattern.

### Prompt conventions

RubyLLM's Rails docs lean toward prompt files under `app/prompts`, rather than
Rails views under `app/views/agents/...`.

That does not prevent us from still rendering ERB-backed prompt fragments, but
the default convention is different:

- `ActiveAgent`: views are central
- `RubyLLM`: agent config and chat flow are central, with prompts attached to
  that flow

### Rails-backed persistence

RubyLLM has a meaningful Rails integration layer that can persist chat state.

The docs describe a Rails-backed approach where you wire:

- a chat model with `acts_as_chat`
- a message model with `acts_as_message`
- a tool call model with `acts_as_tool_call`
- an agent with `chat_model`

In that setup, RubyLLM can persist:

- system instructions
- user messages
- assistant messages
- tool calls and tool results

This is the biggest architectural difference relative to the current app.

### Runtime model

RubyLLM assumes the chat run itself is a useful first-class artifact. That
changes what the framework "owns":

- not just model invocation
- but also the execution transcript and tool-call history

For a Rails app, that can be a strength if you want durable LLM state,
debuggability, and auditing.

## Core differences

### 1. Action-centric vs chat-centric

`ActiveAgent` maps naturally to controller-style actions:

- `with(params).reply.generate_now`
- prompt view selected by action name

`RubyLLM::Agent` maps more naturally to a configured chat runtime:

- agent instructions and tools are stable
- app code drives chat creation and message flow

For Happytown, this means we will need an app-owned wrapper for the two existing
flows even after moving to RubyLLM:

- intro flow
- reply flow

Those flows are product concepts. They should not disappear just because the
framework is more chat-oriented.

### 2. View-driven prompts vs agent/prompt-path conventions

`ActiveAgent` is unusually aligned with Rails views. Our current prompts take
advantage of that heavily.

RubyLLM can still support prompt files and rendered context, but the migration
will need to choose how much of the current ERB prompt structure we preserve.

The safest interpretation is:

- keep prompt content mostly intact
- move it into RubyLLM-friendly prompt locations
- keep app helpers and rendering where that improves readability

### 3. Tool hashes vs tool classes

Current tools are lightweight and local, but they mix several concerns:

- schema definition
- execution code
- access to app state through the enclosing agent

RubyLLM's tool classes are cleaner, but migrating to them forces us to decide
how tool context is injected:

- pass IDs and reload records
- pass preloaded objects
- attach chat/agent context and derive records from there

That is an implementation detail the migration plan must make explicit.

### 4. Prompt-enforced auditing vs persisted execution records

Today we ask the model to tell us which tools it used. That works, but it is a
soft contract enforced through prompting.

RubyLLM's Rails-backed architecture lets us record tool calls directly in the
persistence layer. That is more trustworthy and better aligned with debugging.

### 5. Framework-owned persistence

This is the largest strategic difference.

Current app:

- WhatsApp models are the only durable conversation state
- LLM execution is transient

RubyLLM Rails-backed mode:

- chat/message/tool-call records become first-class data

That creates duplication with WhatsApp message storage, but not necessarily bad
duplication. The WhatsApp tables can remain the business source of truth, while
RubyLLM persistence becomes the execution/audit source of truth.

## Options for Happytown

### Option 1: Thin port to RubyLLM without Rails-backed persistence

Use `RubyLLM::Agent` mainly as a replacement for model/tool orchestration, while
continuing to treat WhatsApp models as the only stored conversation state.

Pros:

- smallest schema change
- closest to current architecture
- easiest to migrate incrementally

Cons:

- gives up one of RubyLLM's strongest Rails capabilities
- keeps tool auditing largely app-managed
- leaves less execution history for debugging

### Option 2: Rails-backed RubyLLM agent

Adopt RubyLLM's Rails persistence layer and treat chat/message/tool-call records
as execution state for the WhatsApp bot.

Pros:

- better observability and auditability
- first-class persisted tool call history
- aligns with the framework's Rails integration
- removes the need for the current prompt-enforced `tools_used` JSON contract

Cons:

- adds schema and model surface area
- introduces a second persisted representation of conversation state
- requires a more opinionated migration

### Option 3: Hybrid phased path

Treat the target architecture as Option 2, but get there through staged
coexistence:

1. introduce RubyLLM alongside `ActiveAgent`
2. migrate one flow at a time
3. verify parity
4. remove `ActiveAgent` once the RubyLLM path is stable

Pros:

- lowers migration risk
- keeps the destination architecture strong
- makes rollback simpler

Cons:

- temporary dual-framework complexity
- short-term duplicated code paths

## Recommended direction

Use Option 2 as the destination architecture and Option 3 as the rollout
strategy.

That means:

- target `RubyLLM::Agent` with Rails-backed chat persistence
- keep WhatsApp models as product/business state
- use RubyLLM persistence as execution and audit state
- migrate through staged coexistence rather than single-cutover replacement

This direction fits the repo better than a pure thin port because the current
pain points are exactly where RubyLLM's Rails integration is strongest:

- tool-call observability
- execution history
- cleaner tool abstraction
- better separation between app workflow and LLM runtime state

## What should stay the same

The migration should preserve these product-level behaviors:

- `WhatsappGroup` and `WhatsappMessage` remain the app-facing orchestration
  entrypoints
- jobs remain the async boundary
- intro and reply remain distinct flows
- the WhatsApp domain models remain canonical for business events
- the prompt persona and message-history behavior remain intact

The framework should change. The product workflow should not.
