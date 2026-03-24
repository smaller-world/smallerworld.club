# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: whatsapp_group_memberships
#
#  id         :uuid             not null, primary key
#  admin      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :uuid             not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_whatsapp_group_memberships_on_group_id  (group_id)
#  index_whatsapp_group_memberships_on_user_id   (user_id)
#  index_whatsapp_group_memberships_uniqueness   (group_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (group_id => whatsapp_groups.id)
#  fk_rails_...  (user_id => whatsapp_users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WhatsappGroupMembership < ApplicationRecord
  # == Associations ==

  belongs_to :group, class_name: "WhatsappGroup"
  belongs_to :user, class_name: "WhatsappUser"

  # == Validations ==

  validates_associated :user
end
