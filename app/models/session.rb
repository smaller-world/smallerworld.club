# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: sessions
#
#  id                                   :uuid             not null, primary key
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  phone_number_verification_request_id :uuid             not null
#  user_id                              :uuid             not null
#
# Indexes
#
#  index_sessions_on_phone_number_verification_request_id  (phone_number_verification_request_id)
#  index_sessions_on_user_id                               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (phone_number_verification_request_id => phone_number_verification_requests.id)
#  fk_rails_...  (user_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Session < ApplicationRecord
  # == Associations ==

  belongs_to :user
  belongs_to :phone_number_verification_request
end
