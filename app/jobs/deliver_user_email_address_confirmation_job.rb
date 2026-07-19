# typed: strict
# frozen_string_literal: true

class DeliverUserEmailAddressConfirmationJob < ApplicationJob
  # == Configuration ==

  limits_concurrency key: ->(user) { user }, on_conflict: :discard

  # == Job ==

  sig { params(user: User).void }
  def perform(user)
    user.deliver_email_address_confirmation!
  end
end
