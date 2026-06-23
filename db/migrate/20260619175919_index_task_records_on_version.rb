# typed: true
# frozen_string_literal: true

class IndexTaskRecordsOnVersion < ActiveRecord::Migration[8.1]
  def change
    up_only do
      execute <<~SQL.squish
        DELETE FROM task_records
        WHERE ctid NOT IN (
          SELECT MIN(ctid)
          FROM task_records
          GROUP BY version
        );
      SQL
    end
    add_index :task_records, :version, unique: true
  end
end
