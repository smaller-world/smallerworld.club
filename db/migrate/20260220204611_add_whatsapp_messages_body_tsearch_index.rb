class AddWhatsappMessagesBodyTsearchIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :whatsapp_messages,
              "to_tsvector('simple', coalesce(body, ''))",
              using: :gin,
              name: "index_whatsapp_messages_on_body_tsearch",
              algorithm: :concurrently
  end
end
