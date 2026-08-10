# typed: true
# frozen_string_literal: true

class AddResolutionToReports < ActiveRecord::Migration[8.1]
  def change
    add_column :reports, :resolution, :string
    add_index :reports, :resolution
    add_belongs_to :reports,
      :moderator,
      null: true,
      foreign_key: { to_table: "users" },
      type: :uuid

    # Existing resolved reports predate the uphold/dismiss distinction. They
    # were resolved under semantics where resolving un-hid the post, which is
    # what dismissing now means.
    up_only do
      execute(<<~SQL.squish)
        UPDATE reports
        SET resolution = 'dismissed'
        WHERE resolved_at IS NOT NULL
      SQL
    end
  end
end
