# typed: true
# frozen_string_literal: true

class DeprecatePostTypeGrants < ActiveRecord::Migration[8.1]
  def change
    rename_table :post_type_grants, :deprecated_post_type_grants
  end
end
