# frozen_string_literal: true

class CreateWhatsappGroups < ActiveRecord::Migration[8.1]
  def change
    create_table(:whatsapp_groups, id: :uuid) do |t|
      t.string :jid, null: false, index: { unique: true }
      t.string :subject
      t.text :description

      t.timestamps
    end
  end
end
