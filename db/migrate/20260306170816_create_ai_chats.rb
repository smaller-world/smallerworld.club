class CreateAIChats < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_chats, id: :uuid, &:timestamps
  end
end
