# typed: true
# frozen_string_literal: true

class AddIpAddressToLoginRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :login_requests, :ip_address, :inet
    add_index :login_requests, [ :created_at, :ip_address ]
  end
end
