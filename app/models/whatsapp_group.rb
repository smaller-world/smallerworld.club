# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: whatsapp_groups
#
#  id                          :uuid             not null, primary key
#  description                 :text
#  intro_sent_at               :timestamptz
#  jid                         :string           not null
#  memberships_imported_at     :timestamptz
#  message_history_enabled_at  :timestamptz      not null
#  message_history_window_days :integer
#  metadata_imported_at        :timestamptz
#  profile_picture_url         :string
#  subject                     :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_whatsapp_groups_on_intro_sent_at                (intro_sent_at)
#  index_whatsapp_groups_on_jid                          (jid) UNIQUE
#  index_whatsapp_groups_on_memberships_imported_at      (memberships_imported_at)
#  index_whatsapp_groups_on_metadata_imported_at         (metadata_imported_at)
#  index_whatsapp_groups_on_subject_description_tsearch  (((setweight(to_tsvector('simple'::regconfig, (COALESCE(subject, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('simple'::regconfig, COALESCE(description, ''::text)), 'B'::"char")))) USING gin
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class WhatsappGroup < ApplicationRecord
  extend FriendlyId
  include PgSearch::Model

  # == FriendlyId ==

  module FinderMethods
    include FriendlyId::FinderMethods

    private

    def parse_friendly_id(value)
      value.split("-").last
    end
  end

  friendly_id do |config|
    config.base = :id
    config.finder_methods = FinderMethods
  end

  sig { returns(T.nilable(String)) }
  def friendly_id
    if (subject = self[:subject]) && (id = self[:id])
      "#{subject[..32].strip.parameterize}-#{id.delete("-")}"
    end
  end

  # == Attributes ==

  sig { returns(T::Boolean) }
  def intro_sent? = intro_sent_at?

  sig { returns(T::Boolean) }
  def metadata_imported? = metadata_imported_at?

  sig { returns(T::Boolean) }
  def memberships_imported? = memberships_imported_at?

  sig { returns(T::Boolean) }
  def message_history_enabled? = message_history_enabled_at?

  # == Associations ==

  has_many :messages,
           class_name: "WhatsappMessage",
           dependent: :destroy,
           inverse_of: :group,
           foreign_key: :group_id
  has_many :memberships,
           class_name: "WhatsappGroupMembership",
           dependent: :destroy,
           inverse_of: :group,
           foreign_key: :group_id
  has_many :users, through: :memberships

  # == Validations ==

  validates :message_history_window_days,
            numericality: { greater_than: 0 },
            allow_nil: true

  # == Hooks ==

  after_commit :send_intro_later, if: :metadata_imported?, unless: :intro_sent?
  after_create_commit :import_metadata_later
  after_create_commit :import_memberships_later

  # == Scopes ==

  pg_search_scope :search,
                  against: {
                    subject: "A",
                    description: "B",
                  },
                  using: {
                    tsearch: {},
                  }

  scope :by_recent_activity, -> {
    subquery = <<~SQL.squish
      (
        SELECT MAX(whatsapp_messages.timestamp)
        FROM whatsapp_messages
        WHERE whatsapp_messages.group_id = whatsapp_groups.id
      ) DESC NULLS LAST
    SQL
    order(Arel.sql(subquery))
  }
  # scope :with_recent_activity, -> {
  #   recent_messages = WhatsappMessage.where("timestamp > ?", 1.day.ago)
  #   where(id: recent_messages.select(:group_id)).by_recent_activity
  # }

  # == Metadata ==

  sig { void }
  def import_metadata
    metadata = wa_sender_api.group_metadata(jid:)
    profile_picture_url = wa_sender_api.group_profile_picture_url(jid:)
    update!(
      subject: metadata["subject"],
      description: metadata["desc"],
      profile_picture_url:,
      metadata_imported_at: Time.current,
    )
  end

  sig do
    params(options: T.untyped)
      .returns(T.any(ImportWhatsappGroupMetadataJob, FalseClass))
  end
  def import_metadata_later(**options)
    ImportWhatsappGroupMetadataJob
      .set(**options)
      .perform_later(self)
  end

  # == Memberships ==

  sig { void }
  def import_memberships
    participants = wa_sender_api.group_participants(jid:)
    transaction do
      self.memberships = participants.map do |data|
        user = WhatsappUser.find_or_create_by(lid: data.fetch("id"))
        WhatsappGroupMembership.new(user:, admin: data["admin"])
      end
    end
  end

  sig do
    params(options: T.untyped)
      .returns(T.any(ImportWhatsappGroupMembershipsJob, FalseClass))
  end
  def import_memberships_later(**options)
    ImportWhatsappGroupMembershipsJob
      .set(**options)
      .perform_later(self)
  end

  # == Messaging ==

  sig { params(text: String, mentioned_jids: T.nilable(T::Array[String])).void }
  def send_message(text:, mentioned_jids: nil)
    wa_sender_api.send_message(to: jid, text:, mentioned_jids:)
  end

  sig do
    params(text: String, reply_to: T.nilable(String), options: T.untyped)
      .returns(T.any(SendWhatsappGroupMessageJob, FalseClass))
  end
  def send_message_later(text, reply_to: nil, **options)
    SendWhatsappGroupMessageJob
      .set(**options)
      .perform_later(self, text, reply_to:)
  end

  sig do
    params(
      history_url: String,
      instructions_video_url: String,
    ).void
  end
  def send_message_history_link(history_url:, instructions_video_url:)
    send_message(text: "*see older messages:* #{history_url}")
    instructions = <<~EOF.squish
      you can pin that message so new group members can see past messages.
      this video shows you how to do it.
    EOF
    wa_sender_api.send_video_message(
      to: jid,
      video_url: instructions_video_url,
      text: instructions,
    )
  end

  sig { void }
  def send_typing_indicator
    wa_sender_api.update_presence(jid:, type: "composing")
  end

  sig { returns(ActiveAgent::Generation) }
  def intro_prompt
    WhatsappGroupAgent.with(group: self).introduce_yourself
  end

  sig { void }
  def send_intro
    intro_prompt.generate_now
    update!(intro_sent_at: Time.current)
  end

  sig do
    params(options: T.untyped)
      .returns(T.any(SendWhatsappGroupIntroJob, FalseClass))
  end
  def send_intro_later(**options)
    SendWhatsappGroupIntroJob.set(**options).perform_later(self)
  end

  private

  # == Helpers ==

  sig { returns(WaSenderApi) }
  def wa_sender_api
    HappyTown.application.wa_sender_api
  end
end
