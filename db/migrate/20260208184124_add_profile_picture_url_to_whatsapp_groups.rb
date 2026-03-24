# frozen_string_literal: true

class AddProfilePictureUrlToWhatsappGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :whatsapp_groups, :profile_picture_url, :string
  end
end
