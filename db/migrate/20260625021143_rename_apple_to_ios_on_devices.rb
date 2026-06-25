# typed: true
# frozen_string_literal: true

class RenameAppleToIosOnDevices < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE devices
      SET platform = 'ios'
      WHERE platform = 'apple';
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE devices
      SET platform = 'apple'
      WHERE platform = 'ios';
    SQL
  end
end
