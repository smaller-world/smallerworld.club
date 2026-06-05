class RenameInstallationIdToIdentifierOnDevices < ActiveRecord::Migration[8.1]
  def change
    rename_column :devices, :installation_id, :identifier
  end
end
