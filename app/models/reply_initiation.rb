# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: reply_initiations
#
#  id         :uuid             not null, primary key
#  platform   :string           not null
#  created_at :timestamptz      not null
#  post_id    :uuid             not null
#  replier_id :uuid             not null
#
# Indexes
#
#  index_reply_initiations_on_post_id     (post_id)
#  index_reply_initiations_on_replier_id  (replier_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (replier_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class ReplyInitiation < ApplicationRecord
  # == Attributes ==

  enumerize :platform, in: [ :sms, :whatsapp, :telegram ]

  # == Associations ==

  belongs_to :post
  belongs_to :replier, class_name: "User"

  sig { returns(Post) }
  def post!
    post or raise ActiveRecord::RecordNotFound, "Missing associated post"
  end

  sig { params(native: T::Boolean).returns(String) }
  def reply_url(native: false)
    post!.reply_url(platform: platform.to_sym, native:)
  end
end
