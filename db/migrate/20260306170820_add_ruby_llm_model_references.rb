class AddRubyLlmModelReferences < ActiveRecord::Migration[8.1]
  def change
    add_reference :ai_chats, :model, type: :uuid, foreign_key: { to_table: "ai_models" }
    add_reference :ai_tool_calls, :message, type: :uuid, null: false, foreign_key: { to_table: "ai_chat_messages" }
    add_reference :ai_chat_messages, :chat, type: :uuid, null: false, foreign_key: { to_table: "ai_chats" }
    add_reference :ai_chat_messages, :model, type: :uuid, foreign_key: { to_table: "ai_models" }
    add_reference :ai_chat_messages, :tool_call, type: :uuid, foreign_key: { to_table: "ai_tool_calls" }
  end
end
