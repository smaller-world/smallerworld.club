# typed: true
# frozen_string_literal: true

class RemoveOauthAttributesOnUsers < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    up_only do
      execute <<~SQL.squish
        DELETE FROM users;
      SQL
    end

    transaction do
      change_table :users do |t|
        t.remove :oauth_provider
        t.remove :oauth_first_name
        t.remove :oauth_last_name
        t.remove :oauth_uid
        t.change_null :phone_number, false
      end
    end
  end
end
