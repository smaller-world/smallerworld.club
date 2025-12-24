# typed: true
# frozen_string_literal: true

class AllowNilBodyHtmlOnPosts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :posts, :body_html, true
  end
end
