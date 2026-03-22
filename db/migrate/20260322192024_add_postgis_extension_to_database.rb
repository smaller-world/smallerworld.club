# typed: true
# frozen_string_literal: true

class AddPostgisExtensionToDatabase < ActiveRecord::Migration[8.1]
  def change
    enable_extension "postgis"
  end
end
