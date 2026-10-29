# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: registrations
#
#  id                                   :uuid             not null, primary key
#  completed_at                         :timestamptz
#  created_at                           :timestamptz      not null
#  created_user_id                      :uuid
#  phone_number_verification_request_id :uuid             not null
#
# Indexes
#
#  index_registrations_on_created_user_id                       (created_user_id) UNIQUE
#  index_registrations_on_phone_number_verification_request_id  (phone_number_verification_request_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (created_user_id => users.id)
#  fk_rails_...  (phone_number_verification_request_id => phone_number_verification_requests.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Registration < ApplicationRecord
  # == Errors ==

  class AlreadyCompleted < ApplicationError; end

  # == Attributes ==

  sig { returns(T::Boolean) }
  def completed? = completed_at?

  # == Associations ==

  belongs_to :phone_number_verification_request
  belongs_to :created_user,
    class_name: "User",
    inverse_of: :registration,
    optional: true

  sig { returns(PhoneNumberVerificationRequest) }
  def phone_number_verification_request!
    phone_number_verification_request or
      raise ActiveRecord::RecordNotFound, "Missing associated phone number verification request"
  end

  sig { returns(User) }
  def user
    if (user = created_user)
      user
    else
      User.new(phone_number: phone_number_verification_request&.verified_phone_number)
    end
  end

  # == Validations ==

  validate :validate_verified_phone_number_verification_request, on: :create

  # == Tokens ==

  generates_token_for :completion do
    completed?
  end

  sig { params(token: String).returns(T.nilable(Registration)) }
  def self.find_by_token(token)
    find_by_token_for(:completion, token)
  end

  sig { returns(String) }
  def generate_token
    generate_token_for(:completion)
  end

  # == Methods ==

  sig { params(user_attributes: T.untyped, block: T.nilable(T.proc.params(user: User).void)).returns(User) }
  def complete!(**user_attributes, &block)
    with_lock do
      raise AlreadyCompleted, "Registration already completed" if completed?

      verification_request = phone_number_verification_request!
      create_created_user!(
        phone_number: verification_request.verified_phone_number,
        **user_attributes,
        &block
      ).tap do
        update!(completed_at: Time.current)
      end
    end
  end

  private

  # == Helpers ==

  sig { void }
  def validate_verified_phone_number_verification_request
    verification_request = phone_number_verification_request or return
    unless verification_request.verified?
      errors.add(:phone_number_verification_request, "must be verified")
    end
  end
end
