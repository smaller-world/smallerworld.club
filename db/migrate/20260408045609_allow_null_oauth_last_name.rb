# typed: true
# frozen_string_literal: true

class AllowNullOauthLastName < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :oauth_last_name, true
  end
end
