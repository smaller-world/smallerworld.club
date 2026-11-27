# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: post_types
#
#  id         :uuid             not null, primary key
#  icon       :string
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  world_id   :uuid             not null
#
# Indexes
#
#  index_post_types_on_id_and_world_id  (id,world_id) UNIQUE
#  index_post_types_on_world_id         (world_id)
#  index_post_types_uniqueness          (world_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (world_id => worlds.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class PostType < ApplicationRecord
  # == Attributes ==

  sig { returns(T::Boolean) }
  def default?
    PostType.default_type_names.include?(name)
  end

  sig { returns(T::Boolean) }
  def custom? = !default?

  sig { returns(String) }
  def icon
    super || default_icon
  end

  sig { returns(String) }
  def default_icon
    "huge/tag-01"
  end

  # == Associations ==

  belongs_to :world
  has_many :deprecated_post_type_grants, class_name: "Deprecated::PostTypeGrant", dependent: :destroy

  has_many :posts, inverse_of: :type, foreign_key: :type_id, dependent: :destroy

  sig { returns World }
  def world!
    world or raise ActiveRecord::RecordNotFound, "Missing associated world"
  end

  # == Validations ==

  validates :name,
    presence: true,
    uniqueness: { scope: :world, message: "already exists" }

  # == Default Types ==

  sig { returns(PostType) }
  def self.journal_entry_type = new(name: "journal entry", icon: "huge/book-edit")

  sig { returns(PostType) }
  def self.poem_type = new(name: "poem", icon: "huge/quill-write-01")

  sig { returns(PostType) }
  def self.invitation_type = new(name: "invitation", icon: "huge/mail-open-love")

  sig { returns(PostType) }
  def self.ask_type = new(name: "ask", icon: "huge/waving-hand-02")

  sig { returns(T::Array[PostType]) }
  def self.default_types
    [ journal_entry_type, poem_type, invitation_type, ask_type ]
  end

  sig { returns(T::Array[String]) }
  def self.default_type_names
    @default_type_names ||= T.let(
      default_types.map(&:name).freeze,
      T.nilable(T::Array[String]),
    )
  end
end
