# WhatsApp Group Agent

Happytown operates a WhatsApp bot, named "Happy Town". It is an autonomous AI
agent that can be added to a WhatsApp group chat, to augment it with additional
features such as:

- Message history recording / archival / search
- (UNIMPLEMENTED) Screening pending group members

## Architecture & Framework

The bot is built using the
[**ActiveAgent** framework](https://docs.activeagents.ai/agents), which follows
a Rails-idiomatic approach to AI integrations.

### Core Logic

- **Agent Class**: `app/agents/whatsapp_group_agent.rb`
  - Defines actions (e.g., `reply`, `introduce_yourself`).
  - Configures the LLM provider (`OpenRouter`).
  - Manages tool inclusion.
- **Base Class**: `app/agents/application_agent.rb`
  - Handles global logging, tagging, and shared configuration.

### Tool System

Tools are modularized as `ActiveSupport::Concern` modules within
`app/agents/whatsapp_group_agent/`.

- **Standard Tools**: `send_message`, `send_reply`, `load_previous_messages`,
  `send_message_history_link`.
- **Convention**: Each tool has a JSON descriptor (e.g., `SEND_REPLY_TOOL`) and
  a corresponding Ruby method.

### Prompt System

Prompts are managed as Rails views in `app/views/agents/whatsapp_group/`.

- `instructions.md.erb`: The system-level persona (Happy Town robot).
- `reply.md.erb`: The context-aware prompt for replying to messages.
- `_message.md.erb`: Partial for consistent message formatting for the LLM.

## Message Lifecycle

1.  **Ingestion**: `WaSenderApiController#webhook` receives a `messages.upsert`
    event.
2.  **Persistence**: A `WhatsappMessage` is created.
3.  **Trigger**: `after_create_commit` on `WhatsappMessage` calls
    `send_reply_later` if the message requires a reply (mentions the bot or is a
    reply to the bot).
4.  **Async Job**: `SendWhatsappGroupReplyJob` executes `message.send_reply`.
5.  **Generation**: The `WhatsappGroupAgent` renders templates, calls the LLM
    via OpenRouter, executes tools, and logs the result.

## Development & Extension

### Adding Functionality

1.  **New Tool**: Create a module in `app/agents/whatsapp_group_agent/`, include
    it in the agent class, and add the tool constant to relevant prompt views.
2.  **Changing Persona**: Edit
    `app/views/agents/whatsapp_group/instructions.md.erb`.
3.  **Updating Routing**: Modify `requires_reply?` in
    `app/models/whatsapp_message.rb`.

### Testing

- **Location**: `test/agents/whatsapp_group_agent_test.rb`
- **Pattern**: Use `generate_now` to test the agent synchronously. Verify tool
  calls by parsing the JSON output format defined in the prompt templates.
