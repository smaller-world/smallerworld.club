# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: reflections
#
#  id         :uuid             not null, primary key
#  date       :date             not null
#  emoji      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  author_id  :uuid             not null
#
# Indexes
#
#  index_reflections_on_author_id  (author_id)
#  index_reflections_uniqueness    (date,author_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Reflection < ApplicationRecord
  include NormalizesText

  # == Configuration ==

  sig { override.returns(String) }
  def to_param
    date.iso8601
  end

  # == Associations ==

  belongs_to :author, class_name: "User"

  sig { returns(User) }
  def author!
    author or raise ActiveRecord::RecordNotFound, "Missing author"
  end

  # == Attachments ==

  has_rich_text :body, encrypted: true

  # == Normalizations

  nilify_blanks :emoji

  # == Validations ==

  validates :emoji, emoji: true, allow_nil: true
  validates :body, presence: true

  # == Hooks ==

  after_save_commit :broadcast_items_reload

  # == Methods ==

  sig { returns(String) }
  def plain_body
    rich_text_body.to_plain_text.gsub("\n\n", "\n")
  end

  private

  # == Callbacks ==

  sig { void }
  def broadcast_items_reload
    broadcast_action_to(
      author!,
      :reflections,
      action: :reload,
      target: "reflections",
      render: false,
    )
  end
end
