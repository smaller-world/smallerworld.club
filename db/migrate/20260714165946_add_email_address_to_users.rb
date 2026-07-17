# typed: true
# frozen_string_literal: true

class AddEmailAddressToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_address, :string
    add_column :users, :unconfirmed_email_address, :string
    add_column :users, :email_address_confirmed_at, :timestamptz
    add_column :users, :email_address_confirmation_sent_at, :timestamptz
  end
end
