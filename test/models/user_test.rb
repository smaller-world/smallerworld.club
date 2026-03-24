# typed: true
# frozen_string_literal: true

require "test_helper"

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
class UserTest < ActiveSupport::TestCase
  extend T::Sig

  # == Tests ==

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")

    assert_equal("downcased@example.com", user.email_address)
  end
end
