# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: whatsapp_users
#
#  id                   :uuid             not null, primary key
#  display_name         :string
#  lid                  :string           not null
#  metadata_imported_at :timestamptz
#  phone_number         :string
#  phone_number_jid     :string
#  profile_picture_url  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_whatsapp_users_on_lid                   (lid) UNIQUE
#  index_whatsapp_users_on_metadata_imported_at  (metadata_imported_at)
#  index_whatsapp_users_on_phone_number          (phone_number) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WhatsappUser < ApplicationRecord
  include WhatsappMessaging
  include NormalizesPhoneNumber

  # == Attributes ==

  sig { returns(T.nilable(Phonelib::Phone)) }
  def phone
    if (number = phone_number)
      Phonelib.parse(number)
    end
  end

  sig { returns(T::Boolean) }
  def metadata_imported? = metadata_imported_at?

  # == Associations ==

  has_many :group_memberships,
           class_name: "WhatsappGroupMembership",
           dependent: :destroy,
           inverse_of: :user,
           foreign_key: :user_id
  has_many :groups, through: :group_memberships

  # == Normalizations ==

  normalizes_phone_number :phone_number

  # == Validations ==

  validates :lid, presence: true, uniqueness: true
  validates :phone_number,
            phone: { possible: true, types: :mobile, extensions: false },
            allow_nil: true

  # == Hooks ==

  after_create_commit :import_metadata_later

  # == Mentions ==

  sig { returns(T.nilable(String)) }
  def phone_mention_token
    if (phone = self.phone)
      "@" + phone.sanitized
    end
  end

  sig { returns(String) }
  def lid_mention_token
    "@" + lid.delete_suffix("@lid")
  end

  sig { returns(T::Array[String]) }
  def mention_tokens
    [ phone_mention_token, lid_mention_token ].compact
  end

  # == Metadata ==

  sig { void }
  def import_metadata
    phone_number_jid = wa_sender_api.phone_number_jid_for_user(lid:)
    phone_number = phone_number_jid&.delete_suffix("@s.whatsapp.net")
    profile_picture_url = if phone_number
      wa_sender_api.contact_profile_picture_url(phone_number:)
    end
    update!(phone_number:, phone_number_jid:, profile_picture_url:, metadata_imported_at: Time.current)
  end

  sig do
    params(options: T.untyped)
      .returns(T.any(ImportWhatsappUserMetadataJob, FalseClass))
  end
  def import_metadata_later(**options)
    ImportWhatsappUserMetadataJob
      .set(**options)
      .perform_later(self)
  end

  # == Methods ==

  sig { returns(T::Boolean) }
  def application_user?
    lid == application_user_lid
  end

  # == Helpers ==

  sig { params(payload: T::Hash[String, T.untyped]).returns(WhatsappUser) }
  def self.from_webhook_payload(payload)
    event = payload.fetch("event")
    case event
    when "messages.upsert"
      messages = payload.dig("data", "messages")
      key = messages.fetch("key")

      lid = if key.fetch("fromMe")
        application_user_lid
      else
        key.fetch("participantLid")
      end
      phone_number_jid = key["participantPn"]
      phone_number = key["cleanedParticipantPn"]
      display_name = messages["pushName"]

      user = WhatsappUser.find_or_initialize_by(lid:) do |user|
        user.phone_number = phone_number
        user.phone_number_jid = phone_number_jid
      end
      user.display_name = display_name
      user
    else
      raise "Unsupported event: #{event}"
    end
  end

  sig { params(jids: T::Array[String]).returns(WhatsappUser::PrivateRelation) }
  def self.from_mentioned_jids(jids)
    where(phone_number_jid: jids).or(where(lid: jids))
  end

  private

  sig { returns(WaSenderApi) }
  def wa_sender_api
    HappyTown.application.wa_sender_api
  end
end
