# typed: true
# frozen_string_literal: true

class RenameTokenOnDevices < ActiveRecord::Migration[8.1]
  def change
    rename_column :devices, :token, :push_token
  end
end
