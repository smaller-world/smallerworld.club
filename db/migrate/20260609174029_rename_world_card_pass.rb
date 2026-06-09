# typed: true
# frozen_string_literal: true

class RenameWorldCardPass < ActiveRecord::Migration[8.1]
  def change
    up_only do
      execute <<~SQL.squish
        UPDATE passkit_passes
        SET klass = 'Passkit::WorldCardPass'
      SQL
    end
  end
end
