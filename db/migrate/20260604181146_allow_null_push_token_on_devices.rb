class AllowNullPushTokenOnDevices < ActiveRecord::Migration[8.1]
  def change
    change_column_null :devices, :push_token, true
  end
end
