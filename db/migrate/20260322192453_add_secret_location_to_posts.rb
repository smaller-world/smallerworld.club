# typed: true
# frozen_string_literal: true

class AddSecretLocationToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :secret_location, :st_point, geographic: true
  end
end
