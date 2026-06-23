# frozen_string_literal: true

class CreatePasskitTables < ActiveRecord::Migration[8.1]
  def change
    create_table :passkit_passes, id: :uuid do |t|
      t.string :generator_type
      t.string :klass, null: false
      t.uuid :generator_id
      t.string :serial_number, null: false, index: { unique: true }
      t.string :authentication_token, null: false
      t.json :data
      # t.integer :version, null: false
      t.timestamps null: false
      t.index [ :generator_type, :generator_id ], name: "index_passkit_passes_on_generator"
    end

    create_table :passkit_devices, id: :uuid do |t|
      t.string :identifier, null: false, index: { unique: true }
      t.string :push_token, null: false
      t.timestamps null: false
    end

    create_table :passkit_registrations, id: :uuid do |t|
      t.belongs_to :passkit_pass, null: false, foreign_key: true, type: :uuid, index: true
      t.belongs_to :passkit_device, null: false, foreign_key: true, type: :uuid, index: true
      t.timestamps null: false
      t.index [ :passkit_pass_id, :passkit_device_id ], name: "index_passkit_registrations_uniqueness", unique: true
    end

    create_table :passkit_logs, id: :uuid do |t|
      t.text :content, null: false
      t.timestamps null: false
    end
  end
end
