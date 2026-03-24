# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class User < ApplicationRecord
  has_secure_password

  # == Normalizations ==

  normalizes :email_address, with: ->(address) { address.strip.downcase }

  # == Associations ==

  has_many :sessions, dependent: :destroy
end
