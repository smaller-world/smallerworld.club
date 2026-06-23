# frozen_string_literal: true

class AllowNullOwnerOnDevices < ActiveRecord::Migration[8.1]
  def change
    change_column_null :devices, :owner_id, true
  end
end
