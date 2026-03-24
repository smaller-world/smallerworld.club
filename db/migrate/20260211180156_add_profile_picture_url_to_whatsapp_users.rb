class AddProfilePictureUrlToWhatsappUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_users, :profile_picture_url, :string
  end
end
